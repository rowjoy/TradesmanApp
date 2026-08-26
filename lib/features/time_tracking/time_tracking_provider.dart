import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/database/database_helper.dart';
import '../../core/ids/id_generator.dart';
import '../../core/money/earnings_calculator.dart';
import '../../core/money/work_earnings_calculator.dart';
import '../../core/time/app_clock.dart';
import 'time_entry_model.dart';

class ActiveWorkSessionException implements Exception {
  const ActiveWorkSessionException(this.activeEntry);
  final TimeEntry activeEntry;
}

class ClockInRequest {
  const ClockInRequest({
    required this.workItem,
    required this.currencyCode,
    required this.pricingType,
    this.scheduledStartAtUtc,
    this.scheduledEndAtUtc,
    this.baseRateMinor,
    this.fixedPriceMinor,
    this.extraPayMinor = 0,
    this.overtimeAfterSeconds = 8 * 60 * 60,
    this.overtimeMultiplierNumerator = 3,
    this.overtimeMultiplierDenominator = 2,
    this.premiumMultiplierNumerator = 1,
    this.premiumMultiplierDenominator = 1,
    this.roundingIncrementSeconds = 60,
    this.roundingDirection = BillingRoundingDirection.nearest,
  });

  final WorkItemReference workItem;
  final String currencyCode;
  final WorkPricingType pricingType;
  final DateTime? scheduledStartAtUtc;
  final DateTime? scheduledEndAtUtc;
  final int? baseRateMinor;
  final int? fixedPriceMinor;
  final int extraPayMinor;
  final int overtimeAfterSeconds;
  final int overtimeMultiplierNumerator;
  final int overtimeMultiplierDenominator;
  final int premiumMultiplierNumerator;
  final int premiumMultiplierDenominator;
  final int roundingIncrementSeconds;
  final BillingRoundingDirection roundingDirection;
}

class TimeCorrection {
  const TimeCorrection({
    required this.clockInUtc,
    required this.clockOutUtc,
    required this.reason,
  });

  final DateTime clockInUtc;
  final DateTime clockOutUtc;
  final String reason;
}

class TimeTrackingRepository {
  TimeTrackingRepository({
    required AppClock clock,
    required IdGenerator idGenerator,
  }) : _clock = clock,
       _idGenerator = idGenerator;

  static const _workspaceId = 'local-workspace';
  final AppClock _clock;
  final IdGenerator _idGenerator;

  Future<TimeEntry?> getActiveEntry() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'time_entries',
      where: '''workspace_id = ? AND clock_out IS NULL AND deleted_at IS NULL
                AND status IN ('running', 'paused')''',
      whereArgs: [_workspaceId],
      orderBy: 'clock_in DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : _hydrate(db, rows.first);
  }

  Future<TimeEntry?> getActiveEntryForWork(WorkItemReference workItem) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'time_entries',
      where:
          '''workspace_id = ? AND work_item_type = ? AND ${workItem.idColumn} = ?
                AND clock_out IS NULL AND deleted_at IS NULL
                AND status IN ('running', 'paused')''',
      whereArgs: [_workspaceId, workItem.type.name, workItem.id],
      orderBy: 'clock_in DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : _hydrate(db, rows.first);
  }

  Future<TimeEntry?> latestCompletedForWork(WorkItemReference workItem) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'time_entries',
      where:
          '''workspace_id = ? AND work_item_type = ? AND ${workItem.idColumn} = ?
                AND clock_out IS NOT NULL AND deleted_at IS NULL''',
      whereArgs: [_workspaceId, workItem.type.name, workItem.id],
      orderBy: 'clock_out DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : _hydrate(db, rows.first);
  }

  Future<List<TimeEntry>> historyForWork(
    WorkItemReference workItem, {
    int limit = 20,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'time_entries',
      where:
          '''workspace_id = ? AND work_item_type = ? AND ${workItem.idColumn} = ?
                AND deleted_at IS NULL''',
      whereArgs: [_workspaceId, workItem.type.name, workItem.id],
      orderBy: 'clock_in DESC',
      limit: limit,
    );
    if (rows.isEmpty) return const [];
    final ids = rows.map((row) => row['id']! as String).toList(growable: false);
    final breakRows = await db.query(
      'break_entries',
      where:
          'time_entry_id IN (${List.filled(ids.length, '?').join(',')}) '
          'AND deleted_at IS NULL',
      whereArgs: ids,
      orderBy: 'break_start ASC',
    );
    final breaksByEntry = <String, List<BreakEntry>>{};
    for (final row in breakRows) {
      breaksByEntry
          .putIfAbsent(row['time_entry_id']! as String, () => [])
          .add(BreakEntry.fromMap(row));
    }
    return rows
        .map(
          (row) => TimeEntry.fromMap(
            row,
            breaks: breaksByEntry[row['id']] ?? const <BreakEntry>[],
          ),
        )
        .toList(growable: false);
  }

  Future<TimeEntry> clockIn(ClockInRequest request) async {
    final db = await DatabaseHelper.instance.database;
    final now = _clock.nowUtc();
    return db.transaction<TimeEntry>((txn) async {
      final activeRows = await txn.query(
        'time_entries',
        where: '''workspace_id = ? AND clock_out IS NULL AND deleted_at IS NULL
                  AND status IN ('running', 'paused')''',
        whereArgs: [_workspaceId],
        orderBy: 'clock_in DESC',
        limit: 1,
      );
      if (activeRows.isNotEmpty) {
        final active = await _hydrate(txn, activeRows.first);
        if (active.workItem == request.workItem) return active;
        throw ActiveWorkSessionException(active);
      }

      final id = _idGenerator.next();
      final row = <String, Object?>{
        'id': id,
        'workspace_id': _workspaceId,
        'work_item_type': request.workItem.type.name,
        'job_id': request.workItem.type == TrackedWorkType.job
            ? request.workItem.id
            : null,
        'shift_id': request.workItem.type == TrackedWorkType.shift
            ? request.workItem.id
            : null,
        'clock_in': now.toIso8601String(),
        'clock_out': null,
        'status': 'running',
        'scheduled_start_at_utc': request.scheduledStartAtUtc
            ?.toUtc()
            .toIso8601String(),
        'scheduled_end_at_utc': request.scheduledEndAtUtc
            ?.toUtc()
            .toIso8601String(),
        'currency_code': request.currencyCode,
        'pricing_type': request.pricingType.name,
        'base_rate_minor': request.baseRateMinor,
        'fixed_price_minor': request.fixedPriceMinor,
        'extra_pay_minor': request.extraPayMinor,
        'overtime_after_seconds': request.overtimeAfterSeconds,
        'overtime_multiplier_numerator': request.overtimeMultiplierNumerator,
        'overtime_multiplier_denominator':
            request.overtimeMultiplierDenominator,
        'premium_multiplier_numerator': request.premiumMultiplierNumerator,
        'premium_multiplier_denominator': request.premiumMultiplierDenominator,
        'rounding_increment_seconds': request.roundingIncrementSeconds,
        'rounding_direction': request.roundingDirection.name,
        'calculation_engine_version': WorkEarningsCalculator.engineVersion,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'sync_status': 'pendingCreate',
        'version': 1,
        'local_version': 1,
      };
      await txn.insert('time_entries', row);
      await _setWorkStatus(txn, request.workItem, 'inProgress', now);
      await _audit(
        txn,
        entityId: id,
        action: 'clockedIn',
        summaryKey: 'auditClockedIn',
        metadata: {
          'workItemType': request.workItem.type.name,
          'workItemId': request.workItem.id,
        },
        now: now,
      );
      await _outbox(txn, id, 'create', row, now);
      return TimeEntry.fromMap(row);
    });
  }

  Future<BreakEntry> startBreak(
    String timeEntryId, {
    required bool isPaid,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final now = _clock.nowUtc();
    return db.transaction<BreakEntry>((txn) async {
      final entryRows = await txn.query(
        'time_entries',
        where: 'id = ? AND clock_out IS NULL AND deleted_at IS NULL',
        whereArgs: [timeEntryId],
        limit: 1,
      );
      if (entryRows.isEmpty) throw StateError('work_session_not_active');
      final openBreak = await txn.query(
        'break_entries',
        where: 'time_entry_id = ? AND break_end IS NULL AND deleted_at IS NULL',
        whereArgs: [timeEntryId],
        limit: 1,
      );
      if (openBreak.isNotEmpty) return BreakEntry.fromMap(openBreak.first);
      final breakId = _idGenerator.next();
      final row = <String, Object?>{
        'id': breakId,
        'time_entry_id': timeEntryId,
        'break_start': now.toIso8601String(),
        'break_end': null,
        'is_paid': isPaid ? 1 : 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'sync_status': 'pendingCreate',
        'version': 1,
        'local_version': 1,
      };
      await txn.insert('break_entries', row);
      await txn.update(
        'time_entries',
        {'status': 'paused', 'updated_at': now.toIso8601String()},
        where: 'id = ?',
        whereArgs: [timeEntryId],
      );
      await _audit(
        txn,
        entityId: timeEntryId,
        action: isPaid ? 'paidBreakStarted' : 'unpaidBreakStarted',
        summaryKey: isPaid
            ? 'auditPaidBreakStarted'
            : 'auditUnpaidBreakStarted',
        metadata: {'breakId': breakId},
        now: now,
      );
      await _outbox(txn, breakId, 'create', row, now, entityType: 'breakEntry');
      return BreakEntry.fromMap(row);
    });
  }

  Future<void> endBreak(String timeEntryId) async {
    final db = await DatabaseHelper.instance.database;
    final now = _clock.nowUtc();
    await db.transaction((txn) async {
      final rows = await txn.query(
        'break_entries',
        where: 'time_entry_id = ? AND break_end IS NULL AND deleted_at IS NULL',
        whereArgs: [timeEntryId],
        orderBy: 'break_start DESC',
        limit: 1,
      );
      if (rows.isEmpty) return;
      final breakId = rows.first['id']! as String;
      await txn.update(
        'break_entries',
        {
          'break_end': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'sync_status': 'pendingUpdate',
        },
        where: 'id = ?',
        whereArgs: [breakId],
      );
      await txn.update(
        'time_entries',
        {'status': 'running', 'updated_at': now.toIso8601String()},
        where: 'id = ? AND clock_out IS NULL',
        whereArgs: [timeEntryId],
      );
      await _audit(
        txn,
        entityId: timeEntryId,
        action: 'breakEnded',
        summaryKey: 'auditBreakEnded',
        metadata: {'breakId': breakId},
        now: now,
      );
      await _outbox(
        txn,
        breakId,
        'update',
        {'break_end': now.toIso8601String()},
        now,
        entityType: 'breakEntry',
      );
    });
  }

  Future<TimeEntry> clockOut(String timeEntryId) async {
    final db = await DatabaseHelper.instance.database;
    final now = _clock.nowUtc();
    return db.transaction<TimeEntry>((txn) async {
      final rows = await txn.query(
        'time_entries',
        where: 'id = ? AND deleted_at IS NULL',
        whereArgs: [timeEntryId],
        limit: 1,
      );
      if (rows.isEmpty) throw StateError('work_session_not_found');
      if (rows.first['clock_out'] != null) return _hydrate(txn, rows.first);
      await _closeOpenBreak(txn, timeEntryId, now);
      await txn.update(
        'time_entries',
        {
          'clock_out': now.toIso8601String(),
          'status': 'completed',
          'updated_at': now.toIso8601String(),
          'sync_status': 'pendingUpdate',
        },
        where: 'id = ? AND clock_out IS NULL',
        whereArgs: [timeEntryId],
      );
      final entry = await _recalculate(txn, timeEntryId, now);
      await _setWorkStatus(txn, entry.workItem, 'completed', now);
      await _audit(
        txn,
        entityId: timeEntryId,
        action: 'clockedOut',
        summaryKey: 'auditClockedOut',
        metadata: {
          'rawSeconds': entry.rawDurationSeconds,
          'billableSeconds': entry.billableDurationSeconds,
        },
        now: now,
      );
      await _outbox(txn, timeEntryId, 'update', {
        'clock_out': now.toIso8601String(),
        'status': 'completed',
        'calculation_snapshot_json': entry.calculationSnapshotJson,
      }, now);
      return entry;
    });
  }

  Future<TimeEntry> correctTime(
    String timeEntryId,
    TimeCorrection correction,
  ) async {
    if (!correction.clockOutUtc.isAfter(correction.clockInUtc)) {
      throw const FormatException('Corrected end must be after start.');
    }
    if (correction.reason.trim().length < 3) {
      throw const FormatException('A correction reason is required.');
    }
    final db = await DatabaseHelper.instance.database;
    final now = _clock.nowUtc();
    return db.transaction<TimeEntry>((txn) async {
      final count = await txn.update(
        'time_entries',
        {
          'clock_in': correction.clockInUtc.toUtc().toIso8601String(),
          'clock_out': correction.clockOutUtc.toUtc().toIso8601String(),
          'status': 'completed',
          'correction_reason': correction.reason.trim(),
          'manually_edited_at_utc': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'sync_status': 'pendingUpdate',
        },
        where: 'id = ? AND deleted_at IS NULL',
        whereArgs: [timeEntryId],
      );
      if (count == 0) throw StateError('work_session_not_found');
      final entry = await _recalculate(txn, timeEntryId, now);
      await _audit(
        txn,
        entityId: timeEntryId,
        action: 'timeCorrected',
        summaryKey: 'auditTimeCorrected',
        metadata: {
          'reason': correction.reason.trim(),
          'clockIn': correction.clockInUtc.toUtc().toIso8601String(),
          'clockOut': correction.clockOutUtc.toUtc().toIso8601String(),
        },
        now: now,
      );
      await _outbox(txn, timeEntryId, 'update', {
        'clock_in': correction.clockInUtc.toUtc().toIso8601String(),
        'clock_out': correction.clockOutUtc.toUtc().toIso8601String(),
        'correction_reason': correction.reason.trim(),
        'calculation_snapshot_json': entry.calculationSnapshotJson,
      }, now);
      return entry;
    });
  }

  Future<void> _closeOpenBreak(
    Transaction txn,
    String timeEntryId,
    DateTime now,
  ) async {
    await txn.update(
      'break_entries',
      {
        'break_end': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'sync_status': 'pendingUpdate',
      },
      where: 'time_entry_id = ? AND break_end IS NULL AND deleted_at IS NULL',
      whereArgs: [timeEntryId],
    );
  }

  Future<TimeEntry> _recalculate(
    Transaction txn,
    String timeEntryId,
    DateTime now,
  ) async {
    final rows = await txn.query(
      'time_entries',
      where: 'id = ?',
      whereArgs: [timeEntryId],
      limit: 1,
    );
    final breaks = await _getBreaksForEntry(txn, timeEntryId);
    final current = TimeEntry.fromMap(rows.first, breaks: breaks);
    final result = current.earningsAt(now);
    final snapshot = <String, Object>{
      ...result.toSnapshot(engineVersion: WorkEarningsCalculator.engineVersion),
      'pricingType': current.pricingType.name,
      'baseRateMinor': current.baseRateMinor ?? 0,
      'fixedPriceMinor': current.fixedPriceMinor ?? 0,
      'extraPayMinor': current.extraPayMinor,
      'overtimeAfterSeconds': current.overtimeAfterSeconds,
      'overtimeMultiplier':
          '${current.overtimeMultiplierNumerator}/${current.overtimeMultiplierDenominator}',
      'premiumMultiplier':
          '${current.premiumMultiplierNumerator}/${current.premiumMultiplierDenominator}',
      'roundingIncrementSeconds': current.roundingIncrementSeconds,
      'roundingDirection': current.roundingDirection,
    };
    await txn.update(
      'time_entries',
      {
        'raw_duration_seconds': result.rawSeconds,
        'unpaid_break_seconds': result.unpaidBreakSeconds,
        'billable_duration_seconds': result.billableSeconds,
        'calculation_snapshot_json': jsonEncode(snapshot),
        'calculation_engine_version': WorkEarningsCalculator.engineVersion,
        'updated_at': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [timeEntryId],
    );
    final updatedRows = await txn.query(
      'time_entries',
      where: 'id = ?',
      whereArgs: [timeEntryId],
      limit: 1,
    );
    return TimeEntry.fromMap(updatedRows.first, breaks: breaks);
  }

  Future<TimeEntry> _hydrate(
    DatabaseExecutor executor,
    Map<String, Object?> row,
  ) async {
    final breaks = await _getBreaksForEntry(executor, row['id']! as String);
    return TimeEntry.fromMap(row, breaks: breaks);
  }

  Future<List<BreakEntry>> _getBreaksForEntry(
    DatabaseExecutor executor,
    String timeEntryId,
  ) async {
    final rows = await executor.query(
      'break_entries',
      where: 'time_entry_id = ? AND deleted_at IS NULL',
      whereArgs: [timeEntryId],
      orderBy: 'break_start ASC',
    );
    return rows.map(BreakEntry.fromMap).toList(growable: false);
  }

  Future<void> _setWorkStatus(
    Transaction txn,
    WorkItemReference workItem,
    String status,
    DateTime now,
  ) async {
    await txn.update(
      workItem.entityTable,
      {
        'status': status,
        'updated_at': now.toIso8601String(),
        'sync_status': 'pendingUpdate',
      },
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [workItem.id],
    );
  }

  Future<void> _audit(
    Transaction txn, {
    required String entityId,
    required String action,
    required String summaryKey,
    required Map<String, Object?> metadata,
    required DateTime now,
  }) async {
    await txn.insert('audit_logs', {
      'id': _idGenerator.next(),
      'workspace_id': _workspaceId,
      'entity_type': 'timeEntry',
      'entity_id': entityId,
      'action': action,
      'summary_key': summaryKey,
      'metadata_json': jsonEncode(metadata),
      'occurred_at_utc': now.toIso8601String(),
    });
  }

  Future<void> _outbox(
    Transaction txn,
    String entityId,
    String operation,
    Map<String, Object?> payload,
    DateTime now, {
    String entityType = 'timeEntry',
  }) async {
    await txn.insert('sync_outbox', {
      'id': _idGenerator.next(),
      'workspace_id': _workspaceId,
      'entity_type': entityType,
      'entity_id': entityId,
      'operation_id': _idGenerator.next(),
      'operation': operation,
      'payload_json': jsonEncode(payload),
      'created_at_utc': now.toIso8601String(),
      'attempt_count': 0,
      'next_attempt_at_utc': now.toIso8601String(),
    });
  }
}

final timeTrackingRepositoryProvider = Provider(
  (ref) => TimeTrackingRepository(
    clock: ref.watch(appClockProvider),
    idGenerator: ref.watch(idGeneratorProvider),
  ),
);

final activeTimeEntryProvider = FutureProvider<TimeEntry?>((ref) {
  return ref.watch(timeTrackingRepositoryProvider).getActiveEntry();
});

final workTimeEntryProvider =
    FutureProvider.family<TimeEntry?, WorkItemReference>((ref, workItem) {
      return ref
          .watch(timeTrackingRepositoryProvider)
          .getActiveEntryForWork(workItem);
    });

final latestCompletedTimeEntryProvider =
    FutureProvider.family<TimeEntry?, WorkItemReference>((ref, workItem) {
      return ref
          .watch(timeTrackingRepositoryProvider)
          .latestCompletedForWork(workItem);
    });

final timeEntryHistoryProvider =
    FutureProvider.family<List<TimeEntry>, WorkItemReference>((ref, workItem) {
      return ref.watch(timeTrackingRepositoryProvider).historyForWork(workItem);
    });
