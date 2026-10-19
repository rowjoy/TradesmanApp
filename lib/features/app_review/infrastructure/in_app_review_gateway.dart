import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../application/app_review_service.dart';

class AppReviewPlatformConfig {
  const AppReviewPlatformConfig({
    required this.platform,
    required this.appStoreId,
    this.isWeb = false,
  });

  final TargetPlatform platform;
  final String appStoreId;
  final bool isWeb;

  bool get canOpenStoreListing {
    if (isWeb) return false;
    return switch (platform) {
      TargetPlatform.android => true,
      TargetPlatform.iOS => RegExp(r'^\d+$').hasMatch(appStoreId.trim()),
      _ => false,
    };
  }
}

class InAppReviewGateway implements AppReviewGateway {
  InAppReviewGateway({
    required AppReviewPlatformConfig config,
    InAppReview? review,
  }) : _config = config,
       _review = review ?? InAppReview.instance;

  final AppReviewPlatformConfig _config;
  final InAppReview _review;

  @override
  bool get canOpenStoreListing => _config.canOpenStoreListing;

  @override
  Future<bool> isAvailable() => _review.isAvailable();

  @override
  Future<void> requestReview() => _review.requestReview();

  @override
  Future<void> openStoreListing() {
    if (!canOpenStoreListing) {
      throw UnsupportedError('Store listing is not configured.');
    }
    return _review.openStoreListing(
      appStoreId: _config.platform == TargetPlatform.iOS
          ? _config.appStoreId.trim()
          : null,
    );
  }
}

class UnsupportedAppReviewGateway implements AppReviewGateway {
  const UnsupportedAppReviewGateway();

  @override
  bool get canOpenStoreListing => false;

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<void> openStoreListing() async {
    throw UnsupportedError('Store listing is not supported.');
  }

  @override
  Future<void> requestReview() async {}
}

class SharedPreferencesReviewAttemptStore implements ReviewAttemptStore {
  SharedPreferencesReviewAttemptStore({
    Future<SharedPreferences> Function()? loadPreferences,
  }) : _loadPreferences = loadPreferences ?? SharedPreferences.getInstance;

  static const _attemptedKey = 'workproof_review_attempted_v1';

  final Future<SharedPreferences> Function() _loadPreferences;

  @override
  Future<bool> hasAttempted() async {
    final preferences = await _loadPreferences();
    return preferences.getBool(_attemptedKey) ?? false;
  }

  @override
  Future<void> clearAttempted() async {
    final preferences = await _loadPreferences();
    final removed = await preferences.remove(_attemptedKey);
    if (!removed) throw StateError('Could not clear review attempt.');
  }

  @override
  Future<void> markAttempted() async {
    final preferences = await _loadPreferences();
    final saved = await preferences.setBool(_attemptedKey, true);
    if (!saved) throw StateError('Could not persist review attempt.');
  }
}
