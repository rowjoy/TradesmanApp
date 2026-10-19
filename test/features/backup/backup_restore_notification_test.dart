import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:tradesman_manager/core/ids/id_generator.dart';
import 'package:tradesman_manager/core/time/app_clock.dart';
import 'package:tradesman_manager/features/backup/presentation/backup_restore_screen.dart';
import 'package:tradesman_manager/features/notifications/application/notification_controller.dart';
import 'package:tradesman_manager/features/notifications/data/notification_repository.dart';
import 'package:tradesman_manager/features/notifications/domain/notification_models.dart';
import 'package:tradesman_manager/features/notifications/infrastructure/local_notification_gateway.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test(
    'successful restore rebuilds the restored schedule before returning',
    () async {
      final events = <String>[];
      final current = _Harness(events, label: 'current');
      final restored = _Harness(events, label: 'restored');
      await current.controller.initialize();
      events.clear();
      current.gateway.pending.add(777);

      final result = await restoreWithNotificationRebuild(
        currentNotifications: current.controller,
        restore: () async {
          events.add('restore');
          expect(current.gateway.pending, isEmpty);
          return true;
        },
        recreateNotifications: () async {
          events.add('reload-profile');
          await Future<void>.value();
          events.add('recreate');
          return restored.controller;
        },
      );

      expect(result, isTrue);
      expect(restored.controller.state.initialized, isTrue);
      expect(restored.gateway.pending, isNotEmpty);
      expect(
        events,
        containsAllInOrder([
          'current:cancel-all-pending',
          'restore',
          'reload-profile',
          'recreate',
          'restored:initialize',
          'restored:schedule',
        ]),
      );

      current.dispose();
      restored.dispose();
    },
  );

  test('restore success waits for a bounded initialization retry', () async {
    final events = <String>[];
    final current = _Harness(events, label: 'current');
    final restored = _Harness(events, label: 'restored');
    restored.gateway.initializationFailures = 1;
    await current.controller.initialize();

    final result = await restoreWithNotificationRebuild(
      currentNotifications: current.controller,
      restore: () async => true,
      recreateNotifications: () async => restored.controller,
    );

    expect(result, isTrue);
    expect(restored.controller.state.initialized, isTrue);
    expect(restored.gateway.initializationAttempts, 2);
    expect(restored.gateway.pending, isNotEmpty);

    current.dispose();
    restored.dispose();
  });

  test('persistent restored initialization failure is not success', () async {
    final events = <String>[];
    final current = _Harness(events, label: 'current');
    final restored = _Harness(events, label: 'restored');
    restored.gateway.initializationFailures = 2;
    await current.controller.initialize();

    final result = await restoreWithNotificationRebuild(
      currentNotifications: current.controller,
      restore: () async => true,
      recreateNotifications: () async => restored.controller,
    );

    expect(result, isFalse);
    expect(restored.controller.state.initialized, isFalse);
    expect(restored.gateway.initializationAttempts, 2);
    expect(restored.gateway.pending, isEmpty);

    current.dispose();
    restored.dispose();
  });

  test('persistent pending lookup failure is not restore success', () async {
    final events = <String>[];
    final current = _Harness(events, label: 'current');
    final restored = _Harness(events, label: 'restored');
    restored.gateway.pendingLookupFailures = 2;
    await current.controller.initialize();

    final result = await restoreWithNotificationRebuild(
      currentNotifications: current.controller,
      restore: () async => true,
      recreateNotifications: () async => restored.controller,
    );

    expect(result, isFalse);
    expect(restored.gateway.pending, isEmpty);

    current.dispose();
    restored.dispose();
  });

  test('persistent OS scheduling failure is not restore success', () async {
    final events = <String>[];
    final current = _Harness(events, label: 'current');
    final restored = _Harness(events, label: 'restored');
    restored.gateway.scheduleFailures = 2;
    await current.controller.initialize();

    final result = await restoreWithNotificationRebuild(
      currentNotifications: current.controller,
      restore: () async => true,
      recreateNotifications: () async => restored.controller,
    );

    expect(result, isFalse);
    expect(restored.gateway.pending, isEmpty);

    current.dispose();
    restored.dispose();
  });

  test('failed controller recreation repairs the restored schedule', () async {
    final events = <String>[];
    final current = _Harness(events, label: 'current');
    await current.controller.initialize();
    events.clear();

    final result = await restoreWithNotificationRebuild(
      currentNotifications: current.controller,
      restore: () async => true,
      recreateNotifications: () async => throw StateError('reload failed'),
    );

    expect(result, isFalse);
    expect(current.gateway.pending, isNotEmpty);
    expect(events.last, 'current:schedule');

    current.dispose();
  });

  test('failed restore result rebuilds the original schedule', () async {
    final events = <String>[];
    final current = _Harness(events, label: 'current');
    await current.controller.initialize();
    events.clear();
    current.gateway.pending.add(777);
    var recreated = false;

    final result = await restoreWithNotificationRebuild(
      currentNotifications: current.controller,
      restore: () async {
        events.add('restore-failed');
        return false;
      },
      recreateNotifications: () async {
        recreated = true;
        return current.controller;
      },
    );

    expect(result, isFalse);
    expect(recreated, isFalse);
    expect(current.gateway.pending, isNotEmpty);
    expect(
      events,
      containsAllInOrder([
        'current:cancel-all-pending',
        'restore-failed',
        'current:schedule',
      ]),
    );

    current.dispose();
  });

  test(
    'thrown restore repairs the original schedule before rethrowing',
    () async {
      final events = <String>[];
      final current = _Harness(events, label: 'current');
      await current.controller.initialize();
      current.gateway.pending.add(777);

      await expectLater(
        restoreWithNotificationRebuild(
          currentNotifications: current.controller,
          restore: () async => throw StateError('restore failed'),
          recreateNotifications: () async =>
              fail('must not recreate after failure'),
        ),
        throwsStateError,
      );

      expect(current.gateway.pending, isNotEmpty);
      expect(events.last, 'current:schedule');

      current.dispose();
    },
  );
}

class _Harness {
  _Harness(List<String> events, {required String label})
    : gateway = _Gateway(events, label: label),
      repository = _Repository(events, label: label) {
    controller = NotificationController(
      repository: repository,
      gateway: gateway,
      clock: const _Clock(),
      languageCode: () => 'en',
    );
  }

  final _Gateway gateway;
  final _Repository repository;
  late final NotificationController controller;

  void dispose() {
    controller.dispose();
    gateway.dispose();
  }
}

class _Clock implements AppClock {
  const _Clock();

  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 18);
}

class _Ids implements IdGenerator {
  @override
  String next() => 'notification-id';
}

class _Repository extends NotificationRepository {
  _Repository(this.events, {required this.label})
    : super(clock: const _Clock(), ids: _Ids());

  final List<String> events;
  final String label;

  @override
  Future<NotificationPermissionState> loadPermission() async =>
      NotificationPermissionState.granted;

  @override
  Future<void> savePermission(NotificationPermissionState value) async {}

  @override
  Future<Map<AlertCategory, AlertPreference>> loadPreferences() async => {
    for (final category in AlertCategory.values)
      category: AlertPreference.defaults(category),
  };

  @override
  Future<MotivationSettings> loadMotivation() async =>
      const MotivationSettings(enabled: true);

  @override
  Future<List<WorkAlertSource>> loadWorkSources() async => const [];

  @override
  Future<ReconcileBatch> prepareReconcile({
    required List<PlannedNotification> desired,
    required Set<int> pendingOsIds,
    required bool canSchedule,
  }) async {
    if (!canSchedule || desired.isEmpty) {
      return const ReconcileBatch(cancelIds: [], schedule: []);
    }
    final plan = desired.first;
    return ReconcileBatch(
      cancelIds: const [],
      schedule: [
        StoredNotification(
          id: '$label-notification',
          occurrenceId: plan.occurrenceId,
          osNotificationId: label == 'current' ? 101 : 202,
          status: 'pending',
          scheduledForUtc: plan.scheduledForUtc,
          contentFingerprint: plan.contentFingerprint,
          plan: plan,
        ),
      ],
    );
  }

  @override
  Future<void> markScheduled(String id) async {}

  @override
  Future<({int pending, int attention})> statusCounts() async =>
      (pending: 1, attention: 0);

  @override
  Future<void> saveLastReconcile(DateTime value) async {}
}

class _Gateway implements NotificationGateway {
  _Gateway(this.events, {required this.label});

  final List<String> events;
  final String label;
  final Set<int> pending = {};
  final _taps = StreamController<String>.broadcast();
  int initializationAttempts = 0;
  int initializationFailures = 0;
  int pendingLookupFailures = 0;
  int scheduleFailures = 0;

  @override
  Stream<String> get taps => _taps.stream;

  @override
  String get localTimeZone => 'Etc/UTC';

  @override
  Future<String?> initialize() async {
    initializationAttempts++;
    events.add('$label:initialize');
    if (initializationFailures > 0) {
      initializationFailures--;
      throw StateError('Notification initialization failed');
    }
    return null;
  }

  @override
  Future<void> refreshTimeZone() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool?> permissionEnabled() async => true;

  @override
  Future<void> openSettings() async {}

  @override
  Future<Set<int>> pendingIds() async {
    if (pendingLookupFailures > 0) {
      pendingLookupFailures--;
      throw StateError('Pending notification lookup failed');
    }
    return {...pending};
  }

  @override
  Future<void> cancelAllPending() async {
    events.add('$label:cancel-all-pending');
    pending.clear();
  }

  @override
  Future<void> showTest({
    required String title,
    required String body,
    required String payload,
  }) async {}

  @override
  Future<void> schedule(StoredNotification notification) async {
    events.add('$label:schedule');
    if (scheduleFailures > 0) {
      scheduleFailures--;
      throw StateError('OS scheduling failed');
    }
    pending.add(notification.osNotificationId);
  }

  @override
  Future<void> cancel(int id) async => pending.remove(id);

  @override
  void dispose() => _taps.close();
}
