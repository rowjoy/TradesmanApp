import 'dart:io';

import 'package:flutter/foundation.dart';

enum AdPlacement { dashboard, work, money, proof, reports }

abstract final class AdUnitConfig {
  static const _androidReleaseBanner = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER_ID',
  );
  static const _iosReleaseBanner = String.fromEnvironment(
    'ADMOB_IOS_BANNER_ID',
  );

  static String? bannerId(AdPlacement placement) {
    if (kIsWeb) return null;
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      }
      if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      }
      return null;
    }
    if (Platform.isAndroid && _androidReleaseBanner.isNotEmpty) {
      return _androidReleaseBanner;
    }
    if (Platform.isIOS && _iosReleaseBanner.isNotEmpty) {
      return _iosReleaseBanner;
    }
    return null;
  }
}
