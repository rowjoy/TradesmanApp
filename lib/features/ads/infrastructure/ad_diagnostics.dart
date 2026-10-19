import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_unit_config.dart';

typedef AdDiagnosticSink = void Function(String message);

abstract final class AdDiagnostics {
  static String formatBannerLoadFailure({
    required AdPlacement placement,
    required String adUnitId,
    required LoadAdError error,
  }) {
    return '[Ads] Banner load failed: '
        'placement=${placement.name}, '
        'unit=$adUnitId, '
        'code=${error.code}, '
        'domain=${error.domain}, '
        'message=${error.message}, '
        'responseInfo=${error.responseInfo}';
  }

  static void logBannerLoadFailure({
    required AdPlacement placement,
    required String adUnitId,
    required LoadAdError error,
    bool enabled = kDebugMode,
    AdDiagnosticSink? sink,
  }) {
    if (!enabled) return;
    (sink ?? debugPrint)(
      formatBannerLoadFailure(
        placement: placement,
        adUnitId: adUnitId,
        error: error,
      ),
    );
  }
}
