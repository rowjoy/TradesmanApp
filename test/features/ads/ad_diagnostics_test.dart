import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tradesman_manager/features/ads/infrastructure/ad_diagnostics.dart';
import 'package:tradesman_manager/features/ads/infrastructure/ad_unit_config.dart';

void main() {
  test('debug failure log preserves every useful SDK field', () {
    final messages = <String>[];
    final error = _TestLoadAdError();

    AdDiagnostics.logBannerLoadFailure(
      placement: AdPlacement.reports,
      adUnitId: 'ca-app-pub-3940256099942544/9214589741',
      error: error,
      enabled: true,
      sink: messages.add,
    );

    expect(messages, hasLength(1));
    expect(messages.single, contains('reports'));
    expect(messages.single, contains('ca-app-pub-3940256099942544/9214589741'));
    expect(messages.single, contains('code=1'));
    expect(messages.single, contains('domain=com.google.android.gms.ads'));
    expect(messages.single, contains('message=No fill'));
    expect(messages.single, contains('response-123'));
    expect(messages.single, contains('test-adapter'));
  });

  test('disabled diagnostics emit nothing', () {
    final messages = <String>[];

    AdDiagnostics.logBannerLoadFailure(
      placement: AdPlacement.appShell,
      adUnitId: 'ca-app-pub-3940256099942544/9214589741',
      error: _TestLoadAdError(),
      enabled: false,
      sink: messages.add,
    );

    expect(messages, isEmpty);
  });
}

class _TestLoadAdError extends LoadAdError {
  _TestLoadAdError()
    : super(
        1,
        'com.google.android.gms.ads',
        'No fill',
        const _TestResponseInfo(),
      );
}

class _TestResponseInfo extends ResponseInfo {
  const _TestResponseInfo()
    : super(
        responseId: 'response-123',
        mediationAdapterClassName: 'test-adapter',
        responseExtras: const <String, dynamic>{'source': 'test'},
      );
}
