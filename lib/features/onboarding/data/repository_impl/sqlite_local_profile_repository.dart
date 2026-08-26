import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/ids/id_generator.dart';
import '../../../../core/time/app_clock.dart';
import '../../../../core/time/schedule_window.dart';
import '../../../../core/time/time_zone_options.dart';
import '../../domain/entities/local_profile.dart';
import '../../domain/repositories/local_profile_repository.dart';

class SqliteLocalProfileRepository implements LocalProfileRepository {
  SqliteLocalProfileRepository({
    required DatabaseHelper databaseHelper,
    required AppClock clock,
    required IdGenerator idGenerator,
  }) : _databaseHelper = databaseHelper,
       _clock = clock,
       _idGenerator = idGenerator;

  static const profileId = 'local-profile';
  static const workspaceId = 'local-workspace';

  final DatabaseHelper _databaseHelper;
  final AppClock _clock;
  final IdGenerator _idGenerator;

  @override
  Future<LocalProfile?> load() async {
    try {
      final db = await _databaseHelper.database;
      final rows = await db.query(
        'profiles',
        where: 'id = ? AND onboarding_completed = 1',
        whereArgs: [profileId],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return _fromRow(rows.first);
    } catch (_) {
      throw const LocalStorageFailure(code: 'profile_load_failed');
    }
  }

  @override
  Future<LocalProfile> completeSetup(LocalProfileDraft draft) async {
    try {
      final db = await _databaseHelper.database;
      final now = _clock.nowUtc();
      await db.transaction((txn) async {
        final previous = await txn.query(
          'profiles',
          columns: ['created_at_utc', 'demo_data_loaded'],
          where: 'id = ?',
          whereArgs: [profileId],
          limit: 1,
        );
        final createdAt = previous.isEmpty
            ? now.toIso8601String()
            : previous.first['created_at_utc']! as String;
        final demoWasLoaded =
            previous.isNotEmpty &&
            (previous.first['demo_data_loaded'] as int? ?? 0) == 1;
        final profileRow = <String, Object?>{
          'id': profileId,
          'language_code': draft.languageCode,
          'work_mode': draft.workMode.name,
          'country_code': draft.countryCode,
          'currency_code': draft.currencyCode,
          'profession': draft.profession.trim(),
          'pay_method': draft.payMethod.name,
          'default_rate_minor': draft.defaultRateMinor,
          'theme_mode': draft.themePreference.name,
          'demo_data_loaded': (draft.loadDemoData || demoWasLoaded) ? 1 : 0,
          'onboarding_completed': 1,
          'created_at_utc': createdAt,
          'updated_at_utc': now.toIso8601String(),
        };
        if (previous.isEmpty) {
          await txn.insert('profiles', profileRow);
        } else {
          await txn.update(
            'profiles',
            profileRow,
            where: 'id = ?',
            whereArgs: [profileId],
          );
        }

        final workspaces = await txn.query(
          'workspaces',
          columns: ['id'],
          where: 'id = ?',
          whereArgs: [workspaceId],
          limit: 1,
        );
        final workspaceRow = <String, Object?>{
          'id': workspaceId,
          'owner_profile_id': profileId,
          'name': 'WorkProof',
          'mode': draft.workMode.name,
          'country_code': draft.countryCode,
          'currency_code': draft.currencyCode,
          'created_at_utc': createdAt,
          'updated_at_utc': now.toIso8601String(),
          'local_version': 1,
          'sync_status': 'localOnly',
        };
        if (workspaces.isEmpty) {
          await txn.insert('workspaces', workspaceRow);
        } else {
          await txn.update(
            'workspaces',
            workspaceRow,
            where: 'id = ?',
            whereArgs: [workspaceId],
          );
        }

        await txn.insert('workspace_members', {
          'id': 'local-owner-membership',
          'workspace_id': workspaceId,
          'profile_id': profileId,
          'role': 'owner',
          'created_at_utc': createdAt,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        await txn.update('customers', {
          'workspace_id': workspaceId,
        }, where: 'workspace_id IS NULL');
        await txn.update('services', {
          'workspace_id': workspaceId,
        }, where: 'workspace_id IS NULL');
        await txn.update('jobs', {
          'workspace_id': workspaceId,
        }, where: 'workspace_id IS NULL');

        if (draft.loadDemoData && !demoWasLoaded) {
          await _insertDemoData(txn, draft, now);
        }

        await txn.insert('audit_logs', {
          'id': _idGenerator.next(),
          'workspace_id': workspaceId,
          'entity_type': 'profile',
          'entity_id': profileId,
          'action': 'onboardingCompleted',
          'summary_key': 'auditOnboardingCompleted',
          'metadata_json': jsonEncode({'mode': draft.workMode.name}),
          'occurred_at_utc': now.toIso8601String(),
          'actor_type': 'localUser',
        });
      });
      final saved = await load();
      if (saved == null) {
        throw const LocalStorageFailure(code: 'profile_verify_failed');
      }
      return saved;
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const LocalStorageFailure(code: 'profile_save_failed');
    }
  }

  @override
  Future<LocalProfile> updatePreferences({
    required String languageCode,
    required WorkMode workMode,
    required String countryCode,
    required String currencyCode,
  }) async {
    try {
      final db = await _databaseHelper.database;
      final now = _clock.nowUtc();
      await db.transaction((txn) async {
        final updated = await txn.update(
          'profiles',
          {
            'language_code': languageCode,
            'work_mode': workMode.name,
            'country_code': countryCode,
            'currency_code': currencyCode,
            'updated_at_utc': now.toIso8601String(),
          },
          where: 'id = ? AND onboarding_completed = 1',
          whereArgs: [profileId],
        );
        if (updated == 0) {
          throw const LocalStorageFailure(code: 'profile_not_found');
        }
        await txn.update(
          'workspaces',
          {
            'mode': workMode.name,
            'country_code': countryCode,
            'currency_code': currencyCode,
            'updated_at_utc': now.toIso8601String(),
            'local_version': 2,
            'sync_status': 'localOnly',
          },
          where: 'id = ?',
          whereArgs: [workspaceId],
        );
        await txn.insert('audit_logs', {
          'id': _idGenerator.next(),
          'workspace_id': workspaceId,
          'entity_type': 'profile',
          'entity_id': profileId,
          'action': 'preferencesUpdated',
          'summary_key': 'auditPreferencesUpdated',
          'metadata_json': jsonEncode({
            'languageCode': languageCode,
            'workMode': workMode.name,
            'countryCode': countryCode,
            'currencyCode': currencyCode,
          }),
          'occurred_at_utc': now.toIso8601String(),
          'actor_type': 'localUser',
        });
      });
      final saved = await load();
      if (saved == null) {
        throw const LocalStorageFailure(code: 'profile_verify_failed');
      }
      return saved;
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const LocalStorageFailure(code: 'profile_preferences_save_failed');
    }
  }

  Future<void> _insertDemoData(
    Transaction txn,
    LocalProfileDraft draft,
    DateTime now,
  ) async {
    final localNow = now.toLocal();
    final tomorrow = DateTime(
      localNow.year,
      localNow.month,
      localNow.day + 1,
    );
    final startLocal = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9);
    final endLocal = startLocal.add(const Duration(hours: 8));
    final schedule = ScheduleWindow.fromLocal(
      startLocal: startLocal,
      endLocal: endLocal,
      ianaTimeZone: 'Europe/London',
      startOffsetMinutes: suggestedOffsetMinutes('Europe/London', startLocal),
      endOffsetMinutes: suggestedOffsetMinutes('Europe/London', endLocal),
    );
    if (draft.workMode == WorkMode.worker || draft.workMode == WorkMode.both) {
      await txn.insert('employers', {
        'id': 'demo-employer-v1',
        'workspace_id': workspaceId,
        'name': 'Sample Employer',
        'pay_schedule': 'weekly',
        'contract_notes': 'Editable demo record',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'sync_status': 'localOnly',
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      await txn.insert('workplaces', {
        'id': 'demo-workplace-v1',
        'workspace_id': workspaceId,
        'employer_id': 'demo-employer-v1',
        'name': 'Sample Workplace',
        'address': 'London',
        'notes': 'Editable demo record',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'sync_status': 'localOnly',
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      await txn.insert('shifts', {
        'id': 'demo-shift-v1',
        'workspace_id': workspaceId,
        'employer_id': 'demo-employer-v1',
        'workplace_id': 'demo-workplace-v1',
        'title': 'Sample day shift',
        ...schedule.toColumns(),
        'status': 'scheduled',
        'notes': 'Editable demo record',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'sync_status': 'localOnly',
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    if (draft.workMode == WorkMode.tradesman ||
        draft.workMode == WorkMode.both) {
      const customerId = 'demo-customer-v1';
      await txn.insert('customers', {
        'id': customerId,
        'workspace_id': workspaceId,
        'name': 'Sample Customer',
        'phone': null,
        'email': null,
        'address': 'London',
        'notes': 'Editable demo record',
        'billing_currency_code': draft.currencyCode,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'sync_status': 'localOnly',
        'version': 1,
        'local_version': 1,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      final isFixed = draft.payMethod == PayMethod.fixed;
      await txn.insert('jobs', {
        'id': 'demo-job-v1',
        'workspace_id': workspaceId,
        'customer_id': customerId,
        'title': 'Sample repair job',
        'description': 'Editable demo record',
        'address': 'London',
        'scheduled_date': startLocal.toIso8601String(),
        'start_time': '09:00',
        ...schedule.toColumns(),
        'estimated_duration_minutes': 480,
        'priority': 'normal',
        'pricing_type': isFixed ? 'fixed' : 'hourly',
        'hourly_rate': null,
        'fixed_price': null,
        'hourly_rate_minor': isFixed ? null : (draft.defaultRateMinor ?? 2500),
        'fixed_price_minor': isFixed ? (draft.defaultRateMinor ?? 20000) : null,
        'status': 'scheduled',
        'notes': null,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'sync_status': 'localOnly',
        'version': 1,
        'local_version': 1,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  LocalProfile _fromRow(Map<String, Object?> row) => LocalProfile(
    id: row['id']! as String,
    workspaceId: workspaceId,
    languageCode: row['language_code']! as String,
    workMode: workModeFromStorage(row['work_mode']! as String),
    countryCode: row['country_code']! as String,
    currencyCode: row['currency_code']! as String,
    profession: row['profession']! as String,
    payMethod: payMethodFromStorage(row['pay_method']! as String),
    defaultRateMinor: row['default_rate_minor'] as int?,
    themePreference: themePreferenceFromStorage(row['theme_mode']! as String),
    demoDataLoaded: (row['demo_data_loaded']! as int) == 1,
    onboardingCompleted: (row['onboarding_completed']! as int) == 1,
    createdAtUtc: DateTime.parse(row['created_at_utc']! as String).toUtc(),
    updatedAtUtc: DateTime.parse(row['updated_at_utc']! as String).toUtc(),
  );
}
