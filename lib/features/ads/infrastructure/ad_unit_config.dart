import 'package:flutter/foundation.dart';

enum AdPlacement { appShell, people, calendar, reports }

enum AdBuildMode { debug, profile, release }

abstract final class AdUnitConfig {
  static const androidTestBannerId = 'ca-app-pub-3940256099942544/9214589741';
  static const iosTestBannerId = 'ca-app-pub-3940256099942544/2435281174';

  static const _androidReleaseBanner = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER_ID',
    defaultValue: 'ca-app-pub-2681549212751095/2645338964',
  );
  static const _iosReleaseBanner = String.fromEnvironment(
    'ADMOB_IOS_BANNER_ID',
  );

  static final RegExp _bannerIdPattern = RegExp(r'^ca-app-pub-\d+/\d+$');

  static String? bannerId(AdPlacement placement) {
    return resolveBannerId(
      placement: placement,
      platform: defaultTargetPlatform,
      buildMode: _currentBuildMode,
      isWeb: kIsWeb,
      androidReleaseBannerId: _androidReleaseBanner,
      iosReleaseBannerId: _iosReleaseBanner,
    );
  }

  static String? resolveBannerId({
    required AdPlacement placement,
    required TargetPlatform platform,
    required AdBuildMode buildMode,
    required bool isWeb,
    required String androidReleaseBannerId,
    required String iosReleaseBannerId,
  }) {
    if (isWeb) return null;

    final isAndroid = platform == TargetPlatform.android;
    final isIos = platform == TargetPlatform.iOS;
    if (!isAndroid && !isIos) return null;

    if (buildMode != AdBuildMode.release) {
      return isAndroid ? androidTestBannerId : iosTestBannerId;
    }

    final androidId = androidReleaseBannerId.trim();
    final candidate = (isAndroid ? androidReleaseBannerId : iosReleaseBannerId)
        .trim();
    if (!isValidBannerId(candidate)) return null;
    if (isIos && candidate == androidId) return null;
    return candidate;
  }

  static bool isValidBannerId(String value) {
    return _bannerIdPattern.hasMatch(value.trim());
  }

  static AdBuildMode get _currentBuildMode {
    if (kReleaseMode) return AdBuildMode.release;
    if (kProfileMode) return AdBuildMode.profile;
    return AdBuildMode.debug;
  }
}
