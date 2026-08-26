import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/app_clock.dart';
import '../domain/notification_models.dart';

class NotificationRepository {
  NotificationRepository({required AppClock clock, required IdGenerator ids})
    : _clock = clock,
      _ids = ids;

  static const workspaceId = 'local-workspace';
  static const permissionKey = 'notification_permission_state';
  static const lastReconcileKey = 'notification_last_reconcile_utc';

  final AppClock _clock;
  final IdGenerator _ids;

  Future<List<WorkAlertSource>> loadWorkSources() async {
    final db = await DatabaseHelper.instance.database;
    final sources = <WorkAlertSource>[];
    final jobRows = await db.rawQuery(
      '''
      SELECT j.*,
             (SELECT clock_in FROM time_entries t
              WHERE t.job_id = j.id AND t.clock_out IS NULL
                AND t.deleted_at IS NULL LIMIT 1) AS actual_clock_in
      FROM jobs j
      WHERE j.workspace_id = ? AND j.deleted_at IS NULL
        AND j.reminders_enabled = 1
        AND j.start_at_utc IS NOT NULL AND j.end_at_utc IS NOT NULL
        AND j.status NOT IN ('completed', 'paid', 'cancelled')
    ''',
      [workspaceId],
    );
    for (final row in jobRows) {
      sources.add(_source(row, 'job'));
    }
    final shiftRows = await db.rawQuery(
      '''
      SELECT s.*,
             (SELECT clock_in FROM time_entries t
              WHERE t.shift_id = s.id AND t.clock_out IS NULL
                AND t.deleted_at IS NULL LIMIT 1) AS actual_clock_in
      FROM shifts s
      WHERE s.workspace_id = ? AND s.deleted_at IS NULL
        AND s.reminders_enabled = 1
        AND s.status NOT IN ('completed', 'cancelled')
    ''',
      [workspaceId],
    );
    for (final row in shiftRows) {
      sources.add(_source(row, 'shift'));
    }
    return sources;
  }

  WorkAlertSource _source(Map<String, Object?> row, String type) =>
      WorkAlertSource(
        entityType: type,
        entityId: row['id']! as String,
        title: row['title']! as String,
        startUtc: DateTime.parse(row['start_at_utc']! as String).toUtc(),
        endUtc: DateTime.parse(row['end_at_utc']! as String).toUtc(),
        ianaTimeZone: row['iana_time_zone'] as String? ?? 'Etc/UTC',
        status: row['status'] as String? ?? 'scheduled',
        previewOffsetSeconds:
            row['reminder_preview_offset_seconds'] as int? ?? 86400,
        prepareOffsetSeconds:
            row['reminder_prepare_offset_seconds'] as int? ?? 7200,
        startOffsetSeconds:
            row['reminder_start_offset_seconds'] as int? ?? 1800,
        morningEnabled: (row['reminder_morning_enabled'] as int? ?? 1) == 1,
        endEnabled: (row['reminder_end_enabled'] as int? ?? 1) == 1,
        usesGlobalDefaults:
            (row['reminder_uses_global_defaults'] as int? ?? 1) == 1,
        actualClockInUtc: DateTime.tryParse(
          row['actual_clock_in'] as String? ?? '',
        )?.toUtc(),
      );

  Future<Map<AlertCategory, AlertPreference>> loadPreferences() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'job_alert_preferences',
      where: 'workspace_id = ?',
      whereArgs: [workspaceId],
    );
    final values = <AlertCategory, AlertPreference>{
      for (final category in AlertCategory.values)
        category: AlertPreference.defaults(category),
    };
    for (final row in rows) {
      final preference = AlertPreference.fromMap(row);
      values[preference.category] = preference;
    }
    return values;
  }

  Future<void> savePreference(AlertPreference value) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('job_alert_preferences', {
      'id': 'alert:${value.category.name}',
      'workspace_id': workspaceId,
      'category': value.category.name,
      'enabled': value.enabled ? 1 : 0,
      'offset_seconds': value.offsetSeconds,
      'delivery_time_minutes': value.deliveryTimeMinutes,
      'quiet_start_minutes': value.quietStartMinutes,
      'quiet_end_minutes': value.quietEndMinutes,
      'private_lock_screen_text': value.privateLockScreenText ? 1 : 0,
      'cooldown_seconds': value.cooldownSeconds,
      'sound_enabled': value.soundEnabled ? 1 : 0,
      'vibration_enabled': value.vibrationEnabled ? 1 : 0,
      'updated_at': _clock.nowUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<MotivationSettings> loadMotivation() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'motivation_settings',
      where: 'workspace_id = ?',
      whereArgs: [workspaceId],
      limit: 1,
    );
    return rows.isEmpty
        ? const MotivationSettings()
        : MotivationSettings.fromMap(rows.first);
  }

  Future<void> saveMotivation(MotivationSettings value) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('motivation_settings', {
      'workspace_id': workspaceId,
      'enabled': value.enabled ? 1 : 0,
      'delivery_time_minutes': value.deliveryTimeMinutes,
      'tone': value.tone,
      'allowed_days_mask': value.allowedDaysMask,
      'paused_until_utc': value.pausedUntilUtc?.toIso8601String(),
      'private_lock_screen_text': value.privateLockScreenText ? 1 : 0,
      'custom_message': value.customMessage,
      'quiet_start_minutes': value.quietStartMinutes,
      'quiet_end_minutes': value.quietEndMinutes,
      'updated_at': _clock.nowUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<NotificationPermissionState> loadPermission() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [permissionKey],
      limit: 1,
    );
    return notificationPermissionFromStorage(
      rows.isEmpty ? null : rows.first['value'] as String?,
    );
  }

  Future<void> savePermission(NotificationPermissionState value) =>
      _setSetting(permissionKey, value.name);

  Future<void> saveLastReconcile(DateTime value) =>
      _setSetting(lastReconcileKey, value.toUtc().toIso8601String());

  Future<void> _setSetting(String key, String value) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('app_settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<ReconcileBatch> prepareReconcile({
    required List<PlannedNotification> desired,
    required Set<int> pendingOsIds,
    required bool canSchedule,
  }) async {
    final db = await DatabaseHelper.instance.database;
    return db.transaction((txn) async {
      final rows = await txn.query('notifications');
      final byOccurrence = <String, Map<String, Object?>>{};
      final usedIds = <int, String>{};
      for (final row in rows) {
        final occurrence = row['occurrence_id'] as String?;
        final osId = row['os_notification_id'] as int?;
        if (occurrence != null) byOccurrence[occurrence] = row;
        if (occurrence != null && osId != null) usedIds[osId] = occurrence;
      }
      final desiredIds = desired.map((item) => item.occurrenceId).toSet();
      final cancel = <int>{};
      final schedule = <StoredNotification>[];
      final now = _clock.nowUtc().toIso8601String();

      for (final row in rows) {
        final occurrence = row['occurrence_id'] as String?;
        if (occurrence == null || desiredIds.contains(occurrence)) continue;
        final osId = row['os_notification_id'] as int?;
        if (osId != null && row['status'] != 'cancelled') cancel.add(osId);
        await txn.update(
          'notifications',
          {'status': 'cancelled', 'updated_at': now},
          where: 'id = ?',
          whereArgs: [row['id']],
        );
        await txn.update(
          'notification_deliveries',
          {'status': 'cancelled'},
          where: 'occurrence_id = ?',
          whereArgs: [occurrence],
        );
      }

      for (final plan in desired) {
        final existing = byOccurrence[plan.occurrenceId];
        final id = existing?['id'] as String? ?? _ids.next();
        final osId =
            existing?['os_notification_id'] as int? ??
            _allocateOsId(plan.occurrenceId, usedIds);
        usedIds[osId] = plan.occurrenceId;
        final changed =
            existing == null ||
            existing['content_fingerprint'] != plan.contentFingerprint ||
            existing['scheduled_for_utc'] !=
                plan.scheduledForUtc.toIso8601String();
        final missingFromOs = !pendingOsIds.contains(osId);
        if (changed && existing != null) cancel.add(osId);
        final shouldSchedule = canSchedule && (changed || missingFromOs);
        final status = canSchedule
            ? shouldSchedule
                  ? 'pending'
                  : 'scheduled'
            : 'pending_permission';
        final notificationRow = <String, Object?>{
          'id': id,
          'workspace_id': workspaceId,
          'entity_type': plan.entityType,
          'entity_id': plan.entityId,
          'notification_type': plan.category.name,
          'source_start_at_utc': plan.sourceStartUtc?.toIso8601String(),
          'source_end_at_utc': plan.sourceEndUtc?.toIso8601String(),
          'iana_time_zone': plan.ianaTimeZone,
          'requested_local_time': plan.requestedLocalTime,
          'offset_seconds': null,
          'os_notification_id': osId,
          'payload_version': 1,
          'scheduler_version': 1,
          'status': status,
          'scheduled_for_utc': plan.scheduledForUtc.toIso8601String(),
          'occurrence_id': plan.occurrenceId,
          'route_intent': plan.routeIntent,
          'payload_json': plan.payload,
          'title_text': plan.title,
          'body_text': plan.body,
          'content_fingerprint': plan.contentFingerprint,
          'content_locale': null,
          'last_error_code': null,
          'created_at': existing?['created_at'] ?? now,
          'updated_at': now,
        };
        if (existing == null) {
          await txn.insert('notifications', notificationRow);
        } else {
          notificationRow.remove('id');
          await txn.update(
            'notifications',
            notificationRow,
            where: 'id = ?',
            whereArgs: [id],
          );
        }
        await txn.insert('notification_deliveries', {
          'id': 'delivery:${plan.occurrenceId}',
          'notification_id': id,
          'occurrence_id': plan.occurrenceId,
          'scheduled_for_utc': plan.scheduledForUtc.toIso8601String(),
          'status': status,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
        if (shouldSchedule) {
          schedule.add(
            StoredNotification(
              id: id,
              occurrenceId: plan.occurrenceId,
              osNotificationId: osId,
              status: status,
              scheduledForUtc: plan.scheduledForUtc,
              contentFingerprint: plan.contentFingerprint,
              plan: plan,
            ),
          );
        }
      }
      return ReconcileBatch(cancelIds: cancel.toList(), schedule: schedule);
    });
  }

  int _allocateOsId(String occurrence, Map<int, String> used) {
    for (var probe = 0; probe < 10000; probe++) {
      final candidate = deterministicNotificationId(occurrence, probe: probe);
      final owner = used[candidate];
      if (owner == null || owner == occurrence) return candidate;
    }
    throw StateError('notification_id_space_exhausted');
  }

  Future<void> markScheduled(String id) async {
    final db = await DatabaseHelper.instance.database;
    final now = _clock.nowUtc().toIso8601String();
    await db.transaction((txn) async {
      await txn.update(
        'notifications',
        {
          'status': 'scheduled',
          'last_scheduled_at': now,
          'last_error_code': null,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      await txn.update(
        'notification_deliveries',
        {'status': 'scheduled'},
        where: 'notification_id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<void> markNeedsAttention(String id, String safeCode) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'notifications',
      {
        'status': 'needs_attention',
        'last_error_code': safeCode,
        'updated_at': _clock.nowUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<({int pending, int attention})> statusCounts() async {
    final db = await DatabaseHelper.instance.database;
    final pending =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM notifications WHERE status IN ('pending', 'pending_permission', 'scheduled')",
          ),
        ) ??
        0;
    final attention =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM notifications WHERE status = 'needs_attention'",
          ),
        ) ??
        0;
    return (pending: pending, attention: attention);
  }

  Future<bool> targetExists(NotificationPayload payload) async {
    if (payload.entityType == 'calendar' || payload.entityType == 'home') {
      return true;
    }
    if (payload.entityType != 'job' && payload.entityType != 'shift') {
      return false;
    }
    final db = await DatabaseHelper.instance.database;
    final table = payload.entityType == 'job' ? 'jobs' : 'shifts';
    final rows = await db.query(
      table,
      columns: ['id'],
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [payload.entityId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> markOpened(String occurrenceId) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'notification_deliveries',
      {'opened_at_utc': _clock.nowUtc().toIso8601String(), 'status': 'opened'},
      where: 'occurrence_id = ?',
      whereArgs: [occurrenceId],
    );
  }
}

final notificationRepositoryProvider = Provider(
  (ref) => NotificationRepository(
    clock: ref.watch(appClockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);
