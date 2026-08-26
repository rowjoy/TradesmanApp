import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/database/database_helper.dart';
import '../../core/ids/id_generator.dart';
import '../../core/time/app_clock.dart';
import '../../core/time/schedule_window.dart';
import 'job_model.dart';

class JobRepository {
  JobRepository({required AppClock clock, required IdGenerator idGenerator})
    : _clock = clock,
      _idGenerator = idGenerator;

  static const _workspaceId = 'local-workspace';
  final AppClock _clock;
  final IdGenerator _idGenerator;

  Future<List<Job>> getAll({
    JobStatus? status,
    DateTime? onDate,
    String query = '',
    int? limit,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final conditions = <String>['workspace_id = ?', 'deleted_at IS NULL'];
    final args = <Object?>[_workspaceId];
    if (status != null) {
      conditions.add('status = ?');
      args.add(status.name);
    }
    if (onDate != null) {
      final dayStart = DateTime(onDate.year, onDate.month, onDate.day);
      final dayEnd = DateTime(onDate.year, onDate.month, onDate.day + 1);
      conditions.add(
        'start_at_utc < ? AND COALESCE(end_at_utc, start_at_utc) > ?',
      );
      args.addAll([
        dayEnd.toUtc().toIso8601String(),
        dayStart.toUtc().toIso8601String(),
      ]);
    }
    if (query.trim().isNotEmpty) {
      conditions.add('(title LIKE ? OR address LIKE ? OR notes LIKE ?)');
      args.addAll([
        '%${query.trim()}%',
        '%${query.trim()}%',
        '%${query.trim()}%',
      ]);
    }
    final rows = await db.query(
      'jobs',
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'COALESCE(start_at_utc, scheduled_date) ASC, start_time ASC',
      limit: limit,
    );
    return rows.map(Job.fromMap).toList(growable: false);
  }

  Future<List<Job>> getTodayJobs({int? limit}) =>
      getAll(onDate: DateTime.now(), limit: limit);

  Future<Job> create({
    required String customerId,
    String? serviceId,
    required String title,
    String? description,
    String? address,
    DateTime? scheduledDate,
    String? startTime,
    ScheduleWindow? schedule,
    int? estimatedDurationMinutes,
    String priority = 'normal',
    PricingType pricingType = PricingType.hourly,
    JobStatus status = JobStatus.scheduled,
    int? hourlyRateMinor,
    int? fixedPriceMinor,
    String? notes,
    bool remindersEnabled = true,
    bool reminderUsesGlobalDefaults = true,
    int reminderPreviewOffsetSeconds = 86400,
    int reminderPrepareOffsetSeconds = 7200,
    int reminderStartOffsetSeconds = 1800,
    bool reminderMorningEnabled = true,
    bool reminderEndEnabled = true,
  }) async {
    final now = _clock.nowUtc();
    final job = Job(
      id: _idGenerator.next(),
      customerId: customerId,
      serviceId: serviceId,
      title: title,
      description: description,
      address: address,
      scheduledDate: scheduledDate ?? schedule?.startLocal,
      startTime: startTime,
      schedule: schedule,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? schedule?.elapsed.inMinutes,
      priority: priority,
      pricingType: pricingType,
      hourlyRateMinor: hourlyRateMinor,
      fixedPriceMinor: fixedPriceMinor,
      status: status,
      remindersEnabled: remindersEnabled,
      reminderUsesGlobalDefaults: reminderUsesGlobalDefaults,
      reminderPreviewOffsetSeconds: reminderPreviewOffsetSeconds,
      reminderPrepareOffsetSeconds: reminderPrepareOffsetSeconds,
      reminderStartOffsetSeconds: reminderStartOffsetSeconds,
      reminderMorningEnabled: reminderMorningEnabled,
      reminderEndEnabled: reminderEndEnabled,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    await _persist(job, operation: 'create');
    return job;
  }

  Future<Job> update(Job job, {bool? remindersEnabled}) async {
    final updated = job.copyWith(
      remindersEnabled: remindersEnabled,
      updatedAt: _clock.nowUtc(),
    );
    await _persist(updated, operation: 'update');
    return updated;
  }

  Future<void> _persist(Job job, {required String operation}) async {
    if (job.schedule != null && !job.schedule!.isValid) {
      throw const FormatException('Job end must be after job start.');
    }
    final db = await DatabaseHelper.instance.database;
    final now = _clock.nowUtc();
    final map = <String, Object?>{
      ...job.toMap(),
      'workspace_id': _workspaceId,
      'local_version': 1,
      'reminders_enabled': job.remindersEnabled ? 1 : 0,
      'sync_status': operation == 'create' ? 'pendingCreate' : 'pendingUpdate',
    };
    await db.transaction((txn) async {
      if (operation == 'create') {
        await txn.insert('jobs', map);
      } else {
        final updateMap = {...map}
          ..remove('id')
          ..remove('created_at');
        await txn.update(
          'jobs',
          updateMap,
          where: 'id = ?',
          whereArgs: [job.id],
        );
      }
      await _auditAndOutbox(txn, job.id, operation, map, now);
      await txn.delete(
        'drafts',
        where:
            'workspace_id = ? AND draft_type = ? AND linked_entity_id ${operation == 'create' ? 'IS NULL' : '= ?'}',
        whereArgs: operation == 'create'
            ? [_workspaceId, 'job']
            : [_workspaceId, 'job', job.id],
      );
    });
  }

  Future<void> updateStatus(String jobId, JobStatus status) async {
    final existing = await getById(jobId);
    if (existing == null) return;
    await update(existing.copyWith(status: status));
  }

  Future<void> softDelete(String jobId) async {
    final db = await DatabaseHelper.instance.database;
    final now = _clock.nowUtc();
    await db.transaction((txn) async {
      final count = await txn.update(
        'jobs',
        {
          'deleted_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'sync_status': 'pendingDelete',
        },
        where: 'id = ? AND deleted_at IS NULL',
        whereArgs: [jobId],
      );
      if (count == 0) return;
      final operationId = _idGenerator.next();
      await txn.insert('tombstones', {
        'id': _idGenerator.next(),
        'workspace_id': _workspaceId,
        'entity_type': 'job',
        'entity_id': jobId,
        'deleted_at_utc': now.toIso8601String(),
        'operation_id': operationId,
      });
      await _auditAndOutbox(
        txn,
        jobId,
        'delete',
        const {},
        now,
        operationId: operationId,
      );
    });
  }

  Future<Job?> getById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'jobs',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Job.fromMap(rows.first);
  }

  Future<void> _auditAndOutbox(
    Transaction txn,
    String jobId,
    String operation,
    Map<String, Object?> payload,
    DateTime now, {
    String? operationId,
  }) async {
    await txn.insert('audit_logs', {
      'id': _idGenerator.next(),
      'workspace_id': _workspaceId,
      'entity_type': 'job',
      'entity_id': jobId,
      'action': operation == 'create'
          ? 'created'
          : operation == 'delete'
          ? 'deleted'
          : 'updated',
      'summary_key': operation == 'create'
          ? 'auditJobCreated'
          : operation == 'delete'
          ? 'auditJobDeleted'
          : 'auditJobUpdated',
      'occurred_at_utc': now.toIso8601String(),
    });
    await txn.insert('sync_outbox', {
      'id': _idGenerator.next(),
      'workspace_id': _workspaceId,
      'entity_type': 'job',
      'entity_id': jobId,
      'operation_id': operationId ?? _idGenerator.next(),
      'operation': operation,
      'payload_json': jsonEncode(payload),
      'created_at_utc': now.toIso8601String(),
      'attempt_count': 0,
      'next_attempt_at_utc': now.toIso8601String(),
    });
  }
}

final jobRepositoryProvider = Provider(
  (ref) => JobRepository(
    clock: ref.watch(appClockProvider),
    idGenerator: ref.watch(idGeneratorProvider),
  ),
);

final jobSearchQueryProvider = StateProvider<String>((ref) => '');
final jobStatusFilterProvider = StateProvider<JobStatus?>((ref) => null);

final todayJobsProvider = FutureProvider<List<Job>>((ref) async {
  return ref.watch(jobRepositoryProvider).getTodayJobs();
});

final allJobsProvider = FutureProvider<List<Job>>((ref) async {
  final query = ref.watch(jobSearchQueryProvider);
  final status = ref.watch(jobStatusFilterProvider);
  return ref.watch(jobRepositoryProvider).getAll(query: query, status: status);
});
