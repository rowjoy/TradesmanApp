import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tradesman_manager/core/widgets/banner_ad_widget.dart';
import 'package:tradesman_manager/features/ads/application/ads_consent_controller.dart';

void main() {
  test('unsupported platforms disable ads without throwing', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final controller = AdsConsentController();
    addTearDown(controller.dispose);

    await expectLater(controller.initialize(), completes);

    expect(controller.state.status, AdsConsentStatus.ready);
    expect(controller.state.adsReady, isFalse);
    expect(controller.state.errorCode, 'ads_unsupported_platform');
  });

  testWidgets('banner collapses when ads are unavailable', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                BannerAdWidget(),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(BannerAdWidget)).height, 0);
    expect(find.byType(AdWidget), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
