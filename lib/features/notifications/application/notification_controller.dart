import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/performance/background_task_runner.dart';
import '../../../core/time/app_clock.dart';
import '../../onboarding/presentation/controllers/onboarding_controller.dart';
import '../data/notification_repository.dart';
import '../domain/notification_models.dart';
import '../domain/notification_policy.dart';
import '../infrastructure/local_notification_gateway.dart';

class NotificationState {
  const NotificationState({
    this.permission = NotificationPermissionState.unknown,
    this.preferences = const {},
    this.motivation = const MotivationSettings(),
    this.pendingCount = 0,
    this.attentionCount = 0,
    this.busy = false,
    this.initialized = false,
    this.pendingRoute,
    this.lastReconcileUtc,
  });

  final NotificationPermissionState permission;
  final Map<AlertCategory, AlertPreference> preferences;
  final MotivationSettings motivation;
  final int pendingCount;
  final int attentionCount;
  final bool busy;
  final bool initialized;
  final String? pendingRoute;
  final DateTime? lastReconcileUtc;

  NotificationState copyWith({
    NotificationPermissionState? permission,
    Map<AlertCategory, AlertPreference>? preferences,
    MotivationSettings? motivation,
    int? pendingCount,
    int? attentionCount,
    bool? busy,
    bool? initialized,
    String? pendingRoute,
    bool clearPendingRoute = false,
    DateTime? lastReconcileUtc,
  }) => NotificationState(
    permission: permission ?? this.permission,
    preferences: preferences ?? this.preferences,
    motivation: motivation ?? this.motivation,
    pendingCount: pendingCount ?? this.pendingCount,
    attentionCount: attentionCount ?? this.attentionCount,
    busy: busy ?? this.busy,
    initialized: initialized ?? this.initialized,
    pendingRoute: clearPendingRoute ? null : pendingRoute ?? this.pendingRoute,
    lastReconcileUtc: lastReconcileUtc ?? this.lastReconcileUtc,
  );
}

class NotificationController extends StateNotifier<NotificationState> {
  NotificationController({
    required NotificationRepository repository,
    required NotificationGateway gateway,
    required AppClock clock,
    required String Function() languageCode,
  }) : _repository = repository,
       _gateway = gateway,
       _clock = clock,
       _languageCode = languageCode,
       super(const NotificationState());

  final NotificationRepository _repository;
  final NotificationGateway _gateway;
  final AppClock _clock;
  final String Function() _languageCode;
  StreamSubscription<String>? _tapSubscription;
  Future<void>? _initializing;
  bool _reconcileAgain = false;

  Future<void> initialize() => _initializing ??= _initialize();

  Future<void> _initialize() async {
    try {
      final launchPayload = await _gateway.initialize();
      _tapSubscription = _gateway.taps.listen(_handlePayload);
      var permission = await _repository.loadPermission();
      final actual = await _gateway.permissionEnabled();
      if (actual == true) permission = NotificationPermissionState.granted;
      if (actual == false &&
          permission == NotificationPermissionState.granted) {
        permission = NotificationPermissionState.denied;
      }
      await _repository.savePermission(permission);
      final preferences = await _repository.loadPreferences();
      final motivation = await _repository.loadMotivation();
      state = state.copyWith(
        permission: permission,
        preferences: preferences,
        motivation: motivation,
        initialized: true,
      );
      if (launchPayload != null) await _handlePayload(launchPayload);
      await reconcile();
    } catch (_) {
      state = state.copyWith(initialized: true, attentionCount: 1);
    }
  }

  Future<bool> workSaved({
    required bool remindersEnabled,
    required bool hasSchedule,
  }) async {
    await initialize();
    // A startup reconcile may have read work just before this save completed.
    // Always run one post-save pass so the new/edited work is present in the
    // platform schedule immediately.
    await reconcile();
    return remindersEnabled &&
        hasSchedule &&
        state.permission == NotificationPermissionState.unknown;
  }

  Future<void> deferPermission() async {
    await _repository.savePermission(NotificationPermissionState.deferred);
    state = state.copyWith(permission: NotificationPermissionState.deferred);
    await reconcile();
  }

  Future<bool> requestPermission() async {
    await initialize();
    final allowed = await _gateway.requestPermission();
    final permission = allowed
        ? NotificationPermissionState.granted
        : NotificationPermissionState.denied;
    await _repository.savePermission(permission);
    state = state.copyWith(permission: permission);
    await reconcile();
    return allowed;
  }

  Future<void> openSystemSettings() => _gateway.openSettings();

  Future<void> refreshPermissionAndRepair() async {
    await initialize();
    final allowed = await _gateway.permissionEnabled();
    if (allowed != null) {
      final permission = allowed
          ? NotificationPermissionState.granted
          : NotificationPermissionState.denied;
      await _repository.savePermission(permission);
      state = state.copyWith(permission: permission);
    }
    await reconcile();
  }

  Future<bool> sendTestNotification() async {
    await initialize();
    final enabled = await _gateway.permissionEnabled();
    if (enabled != true) {
      await _repository.savePermission(NotificationPermissionState.denied);
      state = state.copyWith(permission: NotificationPermissionState.denied);
      return false;
    }
    final bn = _languageCode() == 'bn';
    await _gateway.showTest(
      title: bn ? 'WorkProof নোটিফিকেশন সচল' : 'WorkProof notifications work',
      body: bn
          ? 'এই test alert আপনার ডিভাইস থেকে দেখানো হয়েছে।'
          : 'This test alert was delivered by your device.',
      payload: const NotificationPayload(
        entityType: 'home',
        entityId: 'notification-test',
        routeIntent: '/home',
        type: 'test',
        occurrenceId: 'notification-test',
      ).encode(),
    );
    return true;
  }

  Future<void> savePreference(AlertPreference value) async {
    await _repository.savePreference(value);
    final updated = {...state.preferences, value.category: value};
    state = state.copyWith(preferences: updated);
    await reconcile();
  }

  Future<void> saveMotivation(MotivationSettings value) async {
    await _repository.saveMotivation(value);
    state = state.copyWith(motivation: value);
    await reconcile();
  }

  Future<void> setPrivateLockScreenText(bool value) async {
    final updated = {...state.preferences};
    for (final category in AlertCategory.values) {
      if (category == AlertCategory.motivation) continue;
      final current = updated[category] ?? AlertPreference.defaults(category);
      final next = current.copyWith(privateLockScreenText: value);
      await _repository.savePreference(next);
      updated[category] = next;
    }
    final motivation = state.motivation.copyWith(privateLockScreenText: value);
    await _repository.saveMotivation(motivation);
    state = state.copyWith(preferences: updated, motivation: motivation);
    await reconcile();
  }

  Future<void> reconcile() async {
    if (state.busy) {
      _reconcileAgain = true;
      return;
    }
    state = state.copyWith(busy: true);
    try {
      final work = await _repository.loadWorkSources();
      final preferences = state.preferences.isEmpty
          ? await _repository.loadPreferences()
          : state.preferences;
      final motivation = state.initialized
          ? state.motivation
          : await _repository.loadMotivation();
      final nowUtc = _clock.nowUtc();
      final languageCode = _languageCode();
      final deviceTimeZone = _gateway.localTimeZone;
      final desired = await BackgroundTaskRunner.run(
        () => const NotificationPolicy().build(
          nowUtc: nowUtc,
          work: work,
          preferences: preferences,
          motivation: motivation,
          languageCode: languageCode,
          deviceTimeZone: deviceTimeZone,
        ),
        debugName: 'workproof-notification-plan',
      );
      final canSchedule =
          state.permission == NotificationPermissionState.granted;
      final pending = canSchedule ? await _gateway.pendingIds() : <int>{};
      final batch = await _repository.prepareReconcile(
        desired: desired,
        pendingOsIds: pending,
        canSchedule: canSchedule,
      );
      for (final id in batch.cancelIds) {
        try {
          await _gateway.cancel(id);
        } catch (_) {
          // Reconciliation remains repeatable; a later pass retries safely.
        }
      }
      for (final notification in batch.schedule) {
        try {
          await _gateway.schedule(notification);
          await _repository.markScheduled(notification.id);
        } catch (_) {
          await _repository.markNeedsAttention(
            notification.id,
            'os_schedule_failed',
          );
        }
      }
      final counts = await _repository.statusCounts();
      final now = _clock.nowUtc();
      await _repository.saveLastReconcile(now);
      state = state.copyWith(
        preferences: preferences,
        motivation: motivation,
        pendingCount: counts.pending,
        attentionCount: counts.attention,
        lastReconcileUtc: now,
      );
    } catch (_) {
      state = state.copyWith(attentionCount: state.attentionCount + 1);
    } finally {
      state = state.copyWith(busy: false);
      if (_reconcileAgain) {
        _reconcileAgain = false;
        unawaited(reconcile());
      }
    }
  }

  Future<void> _handlePayload(String raw) async {
    final payload = NotificationPayload.decode(raw);
    if (payload == null) return;
    await _repository.markOpened(payload.occurrenceId);
    final exists = await _repository.targetExists(payload);
    state = state.copyWith(
      pendingRoute: exists ? payload.routeIntent : '/work-calendar',
    );
  }

  void consumeRoute() => state = state.copyWith(clearPendingRoute: true);

  @override
  void dispose() {
    _tapSubscription?.cancel();
    super.dispose();
  }
}

final notificationGatewayProvider = Provider<NotificationGateway>((ref) {
  final gateway = LocalNotificationGateway();
  ref.onDispose(gateway.dispose);
  return gateway;
});

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationState>((ref) {
      return NotificationController(
        repository: ref.watch(notificationRepositoryProvider),
        gateway: ref.watch(notificationGatewayProvider),
        clock: ref.watch(appClockProvider),
        languageCode: () =>
            ref.read(currentProfileProvider)?.languageCode ?? 'en',
      );
    });
