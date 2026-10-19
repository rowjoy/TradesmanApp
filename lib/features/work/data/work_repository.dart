import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/app_clock.dart';
import '../../../core/time/schedule_window.dart';
import '../domain/work_models.dart';

class WorkRepository {
  WorkRepository({required AppClock clock, required IdGenerator idGenerator})
    : _clock = clock,
      _idGenerator = idGenerator;

  static const workspaceId = 'local-workspace';
  final AppClock _clock;
  final IdGenerator _idGenerator;

  Future<List<Employer>> employers({String query = ''}) async {
    final db = await DatabaseHelper.instance.database;
    final term = query.trim();
    final rows = await db.query(
      'employers',
      where: term.isEmpty
          ? 'workspace_id = ? AND deleted_at IS NULL'
          : '''workspace_id = ? AND deleted_at IS NULL AND
               (name LIKE ? OR contact_name LIKE ? OR phone LIKE ? OR email LIKE ?)''',
      whereArgs: term.isEmpty
          ? [workspaceId]
          : [workspaceId, '%$term%', '%$term%', '%$term%', '%$term%'],
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(Employer.fromMap).toList(growable: false);
  }

  Future<List<Workplace>> workplaces({
    String query = '',
    String? employerId,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final clauses = ['workspace_id = ?', 'deleted_at IS NULL'];
    final args = <Object?>[workspaceId];
    if (employerId != null) {
      clauses.add('employer_id = ?');
      args.add(employerId);
    }
    if (query.trim().isNotEmpty) {
      clauses.add('(name LIKE ? OR address LIKE ?)');
      args.addAll(['%${query.trim()}%', '%${query.trim()}%']);
    }
    final rows = await db.query(
      'workplaces',
      where: clauses.join(' AND '),
      whereArgs: args,
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(Workplace.fromMap).toList(growable: false);
  }

  Future<List<ServiceTemplate>> services({String query = ''}) async {
    final db = await DatabaseHelper.instance.database;
    final term = query.trim();
    final rows = await db.query(
      'services',
      where: term.isEmpty
          ? '(workspace_id = ? OR workspace_id IS NULL) AND deleted_at IS NULL'
          : '''(workspace_id = ? OR workspace_id IS NULL) AND deleted_at IS NULL AND
               (name LIKE ? OR category LIKE ?)''',
      whereArgs: term.isEmpty
          ? [workspaceId]
          : [workspaceId, '%$term%', '%$term%'],
      orderBy: 'category COLLATE NOCASE, name COLLATE NOCASE',
    );
    return rows.map(ServiceTemplate.fromMap).toList(growable: false);
  }

  Future<List<WorkerShift>> shifts({
    String query = '',
    WorkItemStatus? status,
    DateTime? rangeStartUtc,
    DateTime? rangeEndUtc,
    int? limit,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final clauses = ['workspace_id = ?', 'deleted_at IS NULL'];
    final args = <Object?>[workspaceId];
    if (query.trim().isNotEmpty) {
      clauses.add('(title LIKE ? OR notes LIKE ?)');
      args.addAll(['%${query.trim()}%', '%${query.trim()}%']);
    }
    if (status != null) {
      clauses.add('status = ?');
      args.add(status.name);
    }
    if (rangeStartUtc != null && rangeEndUtc != null) {
      clauses.add('start_at_utc < ? AND end_at_utc > ?');
      args.addAll([
        rangeEndUtc.toIso8601String(),
        rangeStartUtc.toIso8601String(),
      ]);
    }
    final rows = await db.query(
      'shifts',
      where: clauses.join(' AND '),
      whereArgs: args,
      orderBy: 'start_at_utc ASC',
      limit: limit,
    );
    return rows.map(WorkerShift.fromMap).toList(growable: false);
  }

  Future<Employer?> employer(String id) =>
      _byId('employers', id, Employer.fromMap);
  Future<Workplace?> workplace(String id) =>
      _byId('workplaces', id, Workplace.fromMap);
  Future<ServiceTemplate?> service(String id) =>
      _byId('services', id, ServiceTemplate.fromMap);
  Future<WorkerShift?> shift(String id) =>
      _byId('shifts', id, WorkerShift.fromMap);

  Future<T?> _byId<T>(
    String table,
    String id,
    T Function(Map<String, Object?>) decode,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      table,
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : decode(rows.first);
  }

  Future<String> saveEmployer({
    String? id,
    required String name,
    String? contactName,
    String? phone,
    String? email,
    String? paySchedule,
    String? contractNotes,
    int? defaultRateMinor,
    String? officialReference,
  }) => _save(
    table: 'employers',
    entityType: 'employer',
    id: id,
    values: {
      'name': name.trim(),
      'contact_name': _blankToNull(contactName),
      'phone': _blankToNull(phone),
      'email': _blankToNull(email),
      'pay_schedule': _blankToNull(paySchedule),
      'contract_notes': _blankToNull(contractNotes),
      'default_rate_minor': defaultRateMinor,
      'official_reference': _blankToNull(officialReference),
    },
  );

  Future<String> saveWorkplace({
    String? id,
    required String employerId,
    required String name,
    String? address,
    String? notes,
    required String ianaTimeZone,
  }) => _save(
    table: 'workplaces',
    entityType: 'workplace',
    id: id,
    values: {
      'employer_id': employerId,
      'name': name.trim(),
      'address': _blankToNull(address),
      'notes': _blankToNull(notes),
      'iana_time_zone': ianaTimeZone,
    },
  );

  Future<String> saveService({
    String? id,
    required String name,
    required String category,
    String? description,
    required String pricingType,
    int? defaultRateMinor,
    int? defaultDurationMinutes,
  }) => _save(
    table: 'services',
    entityType: 'service',
    id: id,
    values: {
      'name': name.trim(),
      'category': category.trim(),
      'description': _blankToNull(description),
      'pricing_type': pricingType,
      'default_rate': null,
      'default_rate_minor': defaultRateMinor,
      'default_duration_minutes': defaultDurationMinutes,
      'tax_rate': 0.0,
      'tax_basis_points': 0,
      'is_custom': 1,
      'version': 1,
    },
  );

  Future<String> saveShift({
    String? id,
    String? employerId,
    String? workplaceId,
    required String title,
    required ScheduleWindow schedule,
    WorkItemStatus status = WorkItemStatus.scheduled,
    int? hourlyRateMinor,
    bool remindersEnabled = true,
    bool reminderUsesGlobalDefaults = true,
    int reminderPreviewOffsetSeconds = 86400,
    int reminderPrepareOffsetSeconds = 7200,
    int reminderStartOffsetSeconds = 1800,
    bool reminderMorningEnabled = true,
    bool reminderEndEnabled = true,
    int breakMinutes = 0,
    bool breakIsPaid = false,
    String? notes,
  }) {
    if (!schedule.isValid) {
      throw const FormatException('Shift end must be after shift start.');
    }
    return _save(
      table: 'shifts',
      entityType: 'shift',
      id: id,
      values: {
        'employer_id': employerId,
        'workplace_id': workplaceId,
        'title': title.trim(),
        ...schedule.toColumns(),
        'status': status.name,
        'hourly_rate_minor': hourlyRateMinor,
        'reminders_enabled': remindersEnabled ? 1 : 0,
        'reminder_uses_global_defaults': reminderUsesGlobalDefaults ? 1 : 0,
        'reminder_preview_offset_seconds': reminderPreviewOffsetSeconds,
        'reminder_prepare_offset_seconds': reminderPrepareOffsetSeconds,
        'reminder_start_offset_seconds': reminderStartOffsetSeconds,
        'reminder_morning_enabled': reminderMorningEnabled ? 1 : 0,
        'reminder_end_enabled': reminderEndEnabled ? 1 : 0,
        'break_minutes': breakMinutes,
        'break_is_paid': breakIsPaid ? 1 : 0,
        'notes': _blankToNull(notes),
      },
    );
  }

  Future<String> _save({
    required String table,
    required String entityType,
    required String? id,
    required Map<String, Object?> values,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final now = _clock.nowUtc();
    final entityId = id ?? _idGenerator.next();
    final isCreate = id == null;
    final row = <String, Object?>{
      'id': entityId,
      'workspace_id': workspaceId,
      ...values,
      'updated_at': now.toIso8601String(),
      'sync_status': isCreate ? 'pendingCreate' : 'pendingUpdate',
      'local_version': 1,
      if (isCreate) 'created_at': now.toIso8601String(),
    };
    await db.transaction((txn) async {
      if (isCreate) {
        await txn.insert(table, row);
      } else {
        row.remove('id');
        row.remove('workspace_id');
        row.remove('created_at');
        await txn.update(table, row, where: 'id = ?', whereArgs: [entityId]);
      }
      await _auditAndOutbox(
        txn,
        entityType: entityType,
        entityId: entityId,
        operation: isCreate ? 'create' : 'update',
        payload: row,
        now: now,
      );
      await txn.delete(
        'drafts',
        where:
            'workspace_id = ? AND draft_type = ? AND linked_entity_id ${id == null ? 'IS NULL' : '= ?'}',
        whereArgs: id == null
            ? [workspaceId, entityType]
            : [workspaceId, entityType, id],
      );
    });
    return entityId;
  }

  Future<void> softDelete({
    required String table,
    required String entityType,
    required String id,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final now = _clock.nowUtc();
    await db.transaction((txn) async {
      final count = await txn.update(
        table,
        {
          'deleted_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'sync_status': 'pendingDelete',
        },
        where: 'id = ? AND deleted_at IS NULL',
        whereArgs: [id],
      );
      if (count == 0) return;
      final operationId = _idGenerator.next();
      await txn.insert('tombstones', {
        'id': _idGenerator.next(),
        'workspace_id': workspaceId,
        'entity_type': entityType,
        'entity_id': id,
        'deleted_at_utc': now.toIso8601String(),
        'operation_id': operationId,
      });
      await _auditAndOutbox(
        txn,
        entityType: entityType,
        entityId: id,
        operation: 'delete',
        payload: const {},
        now: now,
        operationId: operationId,
      );
    });
  }

  Future<void> saveDraft({
    required String draftType,
    String? linkedEntityId,
    required Map<String, Object?> payload,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final now = _clock.nowUtc().toIso8601String();
    final where = linkedEntityId == null
        ? 'workspace_id = ? AND draft_type = ? AND linked_entity_id IS NULL'
        : 'workspace_id = ? AND draft_type = ? AND linked_entity_id = ?';
    final args = linkedEntityId == null
        ? <Object?>[workspaceId, draftType]
        : <Object?>[workspaceId, draftType, linkedEntityId];
    final existing = await db.query(
      'drafts',
      columns: ['id', 'created_at'],
      where: where,
      whereArgs: args,
      limit: 1,
    );
    final row = <String, Object?>{
      'workspace_id': workspaceId,
      'draft_type': draftType,
      'linked_entity_id': linkedEntityId,
      'payload_json': jsonEncode(payload),
      'updated_at': now,
    };
    if (existing.isEmpty) {
      await db.insert('drafts', {
        'id': _idGenerator.next(),
        ...row,
        'created_at': now,
      });
    } else {
      await db.update(
        'drafts',
        row,
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    }
  }

  Future<Map<String, Object?>?> loadDraft(
    String draftType, {
    String? linkedEntityId,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final where = linkedEntityId == null
        ? 'workspace_id = ? AND draft_type = ? AND linked_entity_id IS NULL'
        : 'workspace_id = ? AND draft_type = ? AND linked_entity_id = ?';
    final args = linkedEntityId == null
        ? <Object?>[workspaceId, draftType]
        : <Object?>[workspaceId, draftType, linkedEntityId];
    final rows = await db.query(
      'drafts',
      where: where,
      whereArgs: args,
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final decoded = jsonDecode(rows.first['payload_json']! as String);
    return decoded is Map<String, dynamic>
        ? decoded.cast<String, Object?>()
        : null;
  }

  Future<List<CalendarWorkItem>> calendarItems({
    required DateTime rangeStartUtc,
    required DateTime rangeEndUtc,
    required WorkFlow flow,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final table = flow == WorkFlow.worker ? 'shifts' : 'jobs';
    final rows = await db.query(
      table,
      columns: [
        'id',
        'title',
        'start_at_utc',
        'end_at_utc',
        'start_local',
        'end_local',
        'start_offset_minutes',
        'end_offset_minutes',
        'iana_time_zone',
        'status',
      ],
      where: '''workspace_id = ? AND deleted_at IS NULL AND
                start_at_utc IS NOT NULL AND end_at_utc IS NOT NULL AND
                start_at_utc < ? AND end_at_utc > ?''',
      whereArgs: [
        workspaceId,
        rangeEndUtc.toIso8601String(),
        rangeStartUtc.toIso8601String(),
      ],
      orderBy: 'start_at_utc ASC',
    );
    return rows
        .map((row) {
          final schedule = ScheduleWindow.fromMap(row);
          return CalendarWorkItem(
            id: row['id']! as String,
            flow: flow,
            title: row['title']! as String,
            startUtc: DateTime.parse(row['start_at_utc']! as String).toUtc(),
            endUtc: DateTime.parse(row['end_at_utc']! as String).toUtc(),
            startLocal: schedule.startLocal,
            endLocal: schedule.endLocal,
            ianaTimeZone: row['iana_time_zone'] as String? ?? 'Etc/UTC',
            status: row['status'] as String? ?? 'scheduled',
          );
        })
        .toList(growable: false);
  }

  Future<void> _auditAndOutbox(
    Transaction txn, {
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, Object?> payload,
    required DateTime now,
    String? operationId,
  }) async {
    await txn.insert('audit_logs', {
      'id': _idGenerator.next(),
      'workspace_id': workspaceId,
      'entity_type': entityType,
      'entity_id': entityId,
      'action': operation == 'create'
          ? 'created'
          : operation == 'delete'
          ? 'deleted'
          : 'updated',
      'summary_key': 'audit${_pascal(entityType)}${_pascal(operation)}',
      'occurred_at_utc': now.toIso8601String(),
    });
    await txn.insert('sync_outbox', {
      'id': _idGenerator.next(),
      'workspace_id': workspaceId,
      'entity_type': entityType,
      'entity_id': entityId,
      'operation_id': operationId ?? _idGenerator.next(),
      'operation': operation,
      'payload_json': jsonEncode(payload),
      'created_at_utc': now.toIso8601String(),
      'attempt_count': 0,
      'next_attempt_at_utc': now.toIso8601String(),
    });
  }

  String _pascal(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
  String? _blankToNull(String? value) =>
      value == null || value.trim().isEmpty ? null : value.trim();
}

final workRepositoryProvider = Provider(
  (ref) => WorkRepository(
    clock: ref.watch(appClockProvider),
    idGenerator: ref.watch(idGeneratorProvider),
  ),
);
