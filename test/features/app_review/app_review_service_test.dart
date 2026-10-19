import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/features/app_review/application/app_review_service.dart';
import 'package:tradesman_manager/features/app_review/infrastructure/in_app_review_gateway.dart';
import 'package:tradesman_manager/features/time_tracking/time_entry_model.dart';

void main() {
  final first = DateTime.utc(2026, 1, 1, 9);

  AppReviewService buildService({
    required CompletedClockOutStats stats,
    _FakeReviewGateway? gateway,
    _FakeAttemptStore? store,
    Object? statsError,
  }) {
    return AppReviewService(
      loadStats: () async {
        if (statsError case final error?) throw error;
        return stats;
      },
      gateway: gateway ?? _FakeReviewGateway(),
      attemptStore: store ?? _FakeAttemptStore(),
    );
  }

  CompletedClockOutStats stats({required int count, required Duration span}) {
    return CompletedClockOutStats(
      count: count,
      firstClockOutUtc: first,
      latestClockOutUtc: first.add(span),
    );
  }

  test('does not request before three completed clock-outs', () async {
    final gateway = _FakeReviewGateway();
    final store = _FakeAttemptStore();
    final service = buildService(
      stats: stats(count: 2, span: const Duration(days: 30)),
      gateway: gateway,
      store: store,
    );

    await service.maybeRequestReview(canPresent: () => true);

    expect(gateway.availabilityChecks, 0);
    expect(gateway.requestCount, 0);
    expect(store.markCalls, 0);
  });

  test(
    'does not request when completed clock-outs span under seven days',
    () async {
      final gateway = _FakeReviewGateway();
      final service = buildService(
        stats: stats(
          count: 3,
          span: const Duration(days: 6, hours: 23, minutes: 59),
        ),
        gateway: gateway,
      );

      await service.maybeRequestReview(canPresent: () => true);

      expect(gateway.availabilityChecks, 0);
      expect(gateway.requestCount, 0);
    },
  );

  test(
    'marks attempted before requesting at the exact seven-day boundary',
    () async {
      final store = _FakeAttemptStore();
      final gateway = _FakeReviewGateway(attemptStore: store);
      final service = buildService(
        stats: stats(count: 3, span: const Duration(days: 7)),
        gateway: gateway,
        store: store,
      );

      await service.maybeRequestReview(canPresent: () => true);

      expect(gateway.availabilityChecks, 1);
      expect(store.markCalls, 1);
      expect(gateway.attemptedWhenRequested, isTrue);
      expect(gateway.requestCount, 1);
    },
  );

  test(
    'does not request again when an attempt was already persisted',
    () async {
      final gateway = _FakeReviewGateway();
      final store = _FakeAttemptStore(attempted: true);
      final service = buildService(
        stats: stats(count: 8, span: const Duration(days: 40)),
        gateway: gateway,
        store: store,
      );

      await service.maybeRequestReview(canPresent: () => true);

      expect(gateway.availabilityChecks, 0);
      expect(gateway.requestCount, 0);
      expect(store.markCalls, 0);
    },
  );

  test(
    'does not consume the attempt when native review is unavailable',
    () async {
      final gateway = _FakeReviewGateway(available: false);
      final store = _FakeAttemptStore();
      final service = buildService(
        stats: stats(count: 3, span: const Duration(days: 7)),
        gateway: gateway,
        store: store,
      );

      await service.maybeRequestReview(canPresent: () => true);

      expect(gateway.availabilityChecks, 1);
      expect(store.markCalls, 0);
      expect(gateway.requestCount, 0);
    },
  );

  test(
    'rechecks presentation immediately before consuming the attempt',
    () async {
      var presentationChecks = 0;
      final gateway = _FakeReviewGateway();
      final store = _FakeAttemptStore();
      final service = buildService(
        stats: stats(count: 3, span: const Duration(days: 7)),
        gateway: gateway,
        store: store,
      );

      await service.maybeRequestReview(
        canPresent: () => ++presentationChecks == 1,
      );

      expect(presentationChecks, 2);
      expect(store.markCalls, 0);
      expect(gateway.requestCount, 0);
    },
  );

  test('concurrent eligible calls produce only one review request', () async {
    final availability = Completer<bool>();
    final gateway = _FakeReviewGateway(availability: availability.future);
    final store = _FakeAttemptStore();
    final service = buildService(
      stats: stats(count: 3, span: const Duration(days: 7)),
      gateway: gateway,
      store: store,
    );

    final firstCall = service.maybeRequestReview(canPresent: () => true);
    final secondCall = service.maybeRequestReview(canPresent: () => true);
    await Future<void>.delayed(Duration.zero);
    expect(gateway.availabilityChecks, 1);

    availability.complete(true);
    await Future.wait([firstCall, secondCall]);

    expect(store.markCalls, 1);
    expect(gateway.requestCount, 1);
  });

  test(
    'presentation loss while persisting does not consume the attempt',
    () async {
      var canPresent = true;
      final markCompletion = Completer<void>();
      final gateway = _FakeReviewGateway();
      final store = _FakeAttemptStore(markCompletion: markCompletion.future);
      final service = buildService(
        stats: stats(count: 3, span: const Duration(days: 7)),
        gateway: gateway,
        store: store,
      );

      final request = service.maybeRequestReview(canPresent: () => canPresent);
      await Future<void>.delayed(Duration.zero);
      expect(store.markCalls, 1);

      canPresent = false;
      markCompletion.complete();
      await request;

      expect(gateway.requestCount, 0);
      expect(store.clearCalls, 1);
      expect(store.attempted, isFalse);
    },
  );

  test('query and plugin failures fail open without escaping', () async {
    final queryGateway = _FakeReviewGateway();
    final queryService = buildService(
      stats: stats(count: 3, span: const Duration(days: 7)),
      statsError: StateError('database unavailable'),
      gateway: queryGateway,
    );
    await expectLater(
      queryService.maybeRequestReview(canPresent: () => true),
      completes,
    );
    expect(queryGateway.requestCount, 0);

    final requestStore = _FakeAttemptStore();
    final requestGateway = _FakeReviewGateway(
      requestError: StateError('store unavailable'),
    );
    final requestService = buildService(
      stats: stats(count: 3, span: const Duration(days: 7)),
      gateway: requestGateway,
      store: requestStore,
    );
    await expectLater(
      requestService.maybeRequestReview(canPresent: () => true),
      completes,
    );
    expect(requestStore.attempted, isTrue);
    expect(requestGateway.requestCount, 1);

    await requestService.maybeRequestReview(canPresent: () => true);
    expect(requestGateway.requestCount, 1);
  });

  test('store listing support is limited to configured mobile stores', () {
    expect(
      const AppReviewPlatformConfig(
        platform: TargetPlatform.android,
        appStoreId: '',
      ).canOpenStoreListing,
      isTrue,
    );
    expect(
      const AppReviewPlatformConfig(
        platform: TargetPlatform.iOS,
        appStoreId: '1234567890',
      ).canOpenStoreListing,
      isTrue,
    );
    expect(
      const AppReviewPlatformConfig(
        platform: TargetPlatform.iOS,
        appStoreId: 'workproof',
      ).canOpenStoreListing,
      isFalse,
    );
    expect(
      const AppReviewPlatformConfig(
        platform: TargetPlatform.android,
        appStoreId: '',
        isWeb: true,
      ).canOpenStoreListing,
      isFalse,
    );
  });
}

class _FakeAttemptStore implements ReviewAttemptStore {
  _FakeAttemptStore({this.attempted = false, this.markCompletion});

  bool attempted;
  final Future<void>? markCompletion;
  int markCalls = 0;
  int clearCalls = 0;

  @override
  Future<void> clearAttempted() async {
    clearCalls++;
    attempted = false;
  }

  @override
  Future<bool> hasAttempted() async => attempted;

  @override
  Future<void> markAttempted() async {
    markCalls++;
    attempted = true;
    await markCompletion;
  }
}

class _FakeReviewGateway implements AppReviewGateway {
  _FakeReviewGateway({
    this.available = true,
    this.availability,
    this.requestError,
    this.attemptStore,
  });

  final bool available;
  final Future<bool>? availability;
  final Object? requestError;
  final _FakeAttemptStore? attemptStore;
  int availabilityChecks = 0;
  int requestCount = 0;
  bool? attemptedWhenRequested;

  @override
  bool get canOpenStoreListing => true;

  @override
  Future<bool> isAvailable() async {
    availabilityChecks++;
    return availability ?? available;
  }

  @override
  Future<void> openStoreListing() async {}

  @override
  Future<void> requestReview() async {
    requestCount++;
    attemptedWhenRequested = attemptStore?.attempted;
    if (requestError case final error?) throw error;
  }
}
