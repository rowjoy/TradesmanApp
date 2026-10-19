import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:tradesman_manager/core/ids/id_generator.dart';
import 'package:tradesman_manager/core/time/app_clock.dart';
import 'package:tradesman_manager/features/notifications/application/notification_controller.dart';
import 'package:tradesman_manager/features/notifications/data/notification_repository.dart';
import 'package:tradesman_manager/features/notifications/domain/notification_models.dart';
import 'package:tradesman_manager/features/notifications/infrastructure/local_notification_gateway.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  late _MemoryRepository repository;
  late _DeviceGateway gateway;
  late NotificationController controller;

  setUp(() {
    final events = <String>[];
    repository = _MemoryRepository(events);
    gateway = _DeviceGateway(events);
    controller = NotificationController(
      repository: repository,
      gateway: gateway,
      clock: const _Clock(),
      languageCode: () => 'en',
    );
  });

  tearDown(() {
    controller.dispose();
    gateway.dispose();
  });

  test('initialize retries gateway failure and resumes scheduling', () async {
    gateway.initializationFailures = 1;

    await controller.initialize();
    await controller.initialize();

    expect(controller.state.permission, NotificationPermissionState.granted);
    expect(controller.state.initialized, isTrue);
    expect(controller.state.attentionCount, 0);
    expect(repository.plans, isNotEmpty);
    expect(gateway.deliveredPlans, isNotEmpty);
    expect(gateway.initializationAttempts, 2);
  });

  test('repair retries failed initialization before reconciling', () async {
    gateway.initializationFailures = 1;
    await controller.initialize();

    await controller.refreshPermissionAndRepair();

    expect(gateway.initializationAttempts, 2);
    expect(controller.state.initialized, isTrue);
    expect(gateway.deliveredPlans, isNotEmpty);
  });

  test('repair plans motivation using the refreshed device timezone', () async {
    await controller.initialize();
    final original = repository.plans.last.firstWhere(
      (plan) => plan.category == AlertCategory.motivation,
    );
    expect(
      original.scheduledForUtc.isAtSameMomentAs(DateTime.utc(2026, 10, 18, 7)),
      isTrue,
    );
    gateway.deviceTimeZone = 'Asia/Dhaka';

    await controller.refreshPermissionAndRepair();

    final repaired = repository.plans.last.firstWhere(
      (plan) => plan.category == AlertCategory.motivation,
    );
    expect(repaired.ianaTimeZone, 'Asia/Dhaka');
    expect(
      repaired.scheduledForUtc.isAtSameMomentAs(DateTime.utc(2026, 10, 18, 1)),
      isTrue,
    );
  });

  test(
    'obsolete cancellation is acknowledged only after device success',
    () async {
      repository.cancellationPending = true;
      gateway.pending.add(42);
      gateway.cancellationGate = Completer<void>();

      final initializing = controller.initialize();
      await gateway.cancellationStarted.future;

      expect(repository.cancelled, isFalse);
      expect(repository.cancellationPending, isTrue);
      gateway.cancellationGate!.complete();
      await initializing;

      expect(repository.cancelled, isTrue);
      expect(
        repository.events,
        containsAllInOrder([
          'cancel:42',
          'device-cancelled:42',
          'acknowledge:42',
        ]),
      );
    },
  );

  test('failed obsolete cancellation remains retryable on repair', () async {
    repository.cancellationPending = true;
    gateway.pending.add(42);
    gateway.cancellationFailures = 1;
    await controller.initialize();
    expect(repository.cancelled, isFalse);

    await controller.refreshPermissionAndRepair();

    expect(repository.cancelled, isTrue);
    expect(repository.cancellationPending, isFalse);
    expect(gateway.pending, isNot(contains(42)));
    expect(
      repository.events.where((event) => event == 'cancel:42'),
      hasLength(2),
    );
  });

  test(
    'changed plan waits for cancellation before reusing its device ID',
    () async {
      repository.cancellationPending = true;
      repository.replacement = _replacement();
      gateway.pending.add(42);
      gateway.cancellationFailures = 1;

      await controller.initialize();

      expect(gateway.deliveredPlans, isEmpty);
      expect(repository.scheduledIds, isEmpty);
      expect(repository.cancellationPending, isTrue);

      await controller.refreshPermissionAndRepair();

      expect(repository.cancelled, isFalse);
      expect(repository.scheduledIds, ['replacement']);
      expect(gateway.pending, contains(42));
      expect(
        repository.events,
        containsAllInOrder([
          'cancel:42',
          'cancel:42',
          'device-cancelled:42',
          'acknowledge:42',
          'schedule:42',
          'scheduled:replacement',
        ]),
      );
    },
  );

  test(
    'restore suspension clears pending schedules and blocks reconciliation',
    () async {
      await controller.initialize();
      gateway.deliveredPlans.clear();
      gateway.pending.add(999);

      await controller.suspendSchedulingForDataRestore();
      await controller.reconcile();

      expect(gateway.pending, isEmpty);
      expect(gateway.deliveredPlans, isEmpty);
      expect(repository.events, contains('cancel-all-pending'));
    },
  );

  test(
    'failed restore suspension repairs cleared schedules and reports failure',
    () async {
      await controller.initialize();
      gateway.deliveredPlans.clear();
      gateway.cancelAllPendingFailures = 1;

      await expectLater(
        controller.suspendSchedulingForDataRestore(),
        throwsStateError,
      );

      expect(gateway.deliveredPlans, isNotEmpty);
      expect(gateway.pending, isNotEmpty);
    },
  );

  test(
    'resuming after failed restore rebuilds the original schedule',
    () async {
      await controller.initialize();
      gateway.deliveredPlans.clear();

      await controller.suspendSchedulingForDataRestore();
      await controller.resumeSchedulingAfterDataRestore();

      expect(gateway.deliveredPlans, isNotEmpty);
      expect(gateway.pending, isNotEmpty);
    },
  );
}

class _Clock implements AppClock {
  const _Clock();

  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 18);
}

class _Ids implements IdGenerator {
  @override
  String next() => 'unused';
}

// Exercises the real controller and policy without a platform SQLite database.
// Cancellation remains queued until the controller explicitly acknowledges it.
class _MemoryRepository extends NotificationRepository {
  _MemoryRepository(this.events) : super(clock: const _Clock(), ids: _Ids());

  final List<String> events;
  final plans = <List<PlannedNotification>>[];
  final scheduledIds = <String>[];
  bool cancellationPending = false;
  bool cancelled = false;
  StoredNotification? replacement;
  NotificationPermissionState permission = NotificationPermissionState.unknown;

  @override
  Future<NotificationPermissionState> loadPermission() async => permission;

  @override
  Future<void> savePermission(NotificationPermissionState value) async {
    permission = value;
  }

  @override
  Future<Map<AlertCategory, AlertPreference>> loadPreferences() async => {
    for (final category in AlertCategory.values)
      category: AlertPreference.defaults(category),
  };

  @override
  Future<MotivationSettings> loadMotivation() async =>
      const MotivationSettings(enabled: true);

  @override
  Future<List<WorkAlertSource>> loadWorkSources() async => [];

  @override
  Future<ReconcileBatch> prepareReconcile({
    required List<PlannedNotification> desired,
    required Set<int> pendingOsIds,
    required bool canSchedule,
  }) async {
    plans.add(desired);
    return ReconcileBatch(
      cancelIds: cancellationPending ? [42] : [],
      schedule: !canSchedule
          ? []
          : replacement != null
          ? [replacement!]
          : cancellationPending || cancelled
          ? []
          : [
              for (var i = 0; i < desired.length; i++)
                StoredNotification(
                  id: 'notification-$i',
                  occurrenceId: desired[i].occurrenceId,
                  osNotificationId: 100 + i,
                  status: 'pending',
                  scheduledForUtc: desired[i].scheduledForUtc,
                  contentFingerprint: desired[i].contentFingerprint,
                  plan: desired[i],
                ),
            ],
    );
  }

  @override
  Future<void> markCancelled(int osId) async {
    expect(osId, 42);
    events.add('acknowledge:$osId');
    cancellationPending = false;
    cancelled = replacement == null;
  }

  @override
  Future<void> markScheduled(String id) async {
    events.add('scheduled:$id');
    scheduledIds.add(id);
  }

  @override
  Future<void> markNeedsAttention(String id, String safeCode) async {
    fail('Unexpected schedule failure: $id / $safeCode');
  }

  @override
  Future<({int pending, int attention})> statusCounts() async =>
      (pending: scheduledIds.length, attention: 0);

  @override
  Future<void> saveLastReconcile(DateTime value) async {}
}

class _DeviceGateway implements NotificationGateway {
  _DeviceGateway(this.events);

  final List<String> events;
  final _taps = StreamController<String>.broadcast();
  final pending = <int>{};
  final deliveredPlans = <StoredNotification>[];
  final cancellationStarted = Completer<void>();
  Completer<void>? cancellationGate;
  int initializationAttempts = 0;
  int initializationFailures = 0;
  int cancellationFailures = 0;
  int cancelAllPendingFailures = 0;
  String deviceTimeZone = 'Etc/UTC';
  String _localTimeZone = 'Etc/UTC';

  @override
  Stream<String> get taps => _taps.stream;

  @override
  String get localTimeZone => _localTimeZone;

  @override
  Future<String?> initialize() async {
    initializationAttempts++;
    if (initializationFailures > 0) {
      initializationFailures--;
      throw StateError('Device initialization unavailable');
    }
    await refreshTimeZone();
    return null;
  }

  @override
  Future<void> refreshTimeZone() async {
    _localTimeZone = deviceTimeZone;
  }

  @override
  Future<bool?> permissionEnabled() async => true;

  @override
  Future<Set<int>> pendingIds() async => {...pending};

  @override
  Future<void> cancel(int id) async {
    events.add('cancel:$id');
    if (!cancellationStarted.isCompleted) cancellationStarted.complete();
    await cancellationGate?.future;
    if (cancellationFailures > 0) {
      cancellationFailures--;
      throw StateError('Device cancellation unavailable');
    }
    pending.remove(id);
    events.add('device-cancelled:$id');
  }

  @override
  Future<void> cancelAllPending() async {
    events.add('cancel-all-pending');
    pending.clear();
    if (cancelAllPendingFailures > 0) {
      cancelAllPendingFailures--;
      throw StateError('Device schedule cleanup unavailable');
    }
  }

  @override
  Future<void> schedule(StoredNotification notification) async {
    events.add('schedule:${notification.osNotificationId}');
    deliveredPlans.add(notification);
    pending.add(notification.osNotificationId);
  }

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> openSettings() async {}

  @override
  Future<void> showTest({
    required String title,
    required String body,
    required String payload,
  }) async {}

  @override
  void dispose() {
    _taps.close();
  }
}

StoredNotification _replacement() {
  final time = DateTime.utc(2026, 10, 18, 9);
  final plan = PlannedNotification(
    occurrenceId: 'replacement-occurrence',
    category: AlertCategory.startsSoon,
    entityType: 'job',
    entityId: 'job-42',
    scheduledForUtc: time,
    ianaTimeZone: 'Etc/UTC',
    routeIntent: '/work/jobs/job-42',
    title: 'Updated work reminder',
    body: 'The start time changed',
    payload: '{}',
    priority: 1,
    contentFingerprint: 'updated-content',
  );
  return StoredNotification(
    id: 'replacement',
    occurrenceId: plan.occurrenceId,
    osNotificationId: 42,
    status: 'pending',
    scheduledForUtc: time,
    contentFingerprint: plan.contentFingerprint,
    plan: plan,
  );
}
