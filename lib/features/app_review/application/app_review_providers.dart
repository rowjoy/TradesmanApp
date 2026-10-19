import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../time_tracking/time_tracking_provider.dart';
import '../infrastructure/in_app_review_gateway.dart';
import 'app_review_service.dart';

final appReviewPlatformConfigProvider = Provider<AppReviewPlatformConfig>((
  ref,
) {
  return AppReviewPlatformConfig(
    platform: defaultTargetPlatform,
    appStoreId: const String.fromEnvironment('APP_STORE_ID'),
    isWeb: kIsWeb,
  );
});

final appReviewGatewayProvider = Provider<AppReviewGateway>((ref) {
  final config = ref.watch(appReviewPlatformConfigProvider);
  if (config.isWeb ||
      (config.platform != TargetPlatform.android &&
          config.platform != TargetPlatform.iOS)) {
    return const UnsupportedAppReviewGateway();
  }
  return InAppReviewGateway(config: config);
});

final reviewAttemptStoreProvider = Provider<ReviewAttemptStore>((ref) {
  return SharedPreferencesReviewAttemptStore();
});

final storeListingSupportedProvider = Provider<bool>((ref) {
  return ref.watch(appReviewGatewayProvider).canOpenStoreListing;
});

final appReviewServiceProvider = Provider<AppReviewService>((ref) {
  return AppReviewService(
    loadStats: () =>
        ref.read(timeTrackingRepositoryProvider).completedClockOutStats(),
    gateway: ref.watch(appReviewGatewayProvider),
    attemptStore: ref.watch(reviewAttemptStoreProvider),
  );
});
