import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/features/ads/infrastructure/ad_unit_config.dart';

void main() {
  const androidProductionBanner = 'ca-app-pub-2681549212751095/2645338964';
  const androidOverrideBanner = 'ca-app-pub-1111111111111111/2222222222';
  const iosProductionBanner = 'ca-app-pub-3333333333333333/4444444444';

  String? resolve({
    TargetPlatform platform = TargetPlatform.android,
    AdBuildMode buildMode = AdBuildMode.release,
    bool isWeb = false,
    String androidReleaseBannerId = androidProductionBanner,
    String iosReleaseBannerId = iosProductionBanner,
  }) {
    return AdUnitConfig.resolveBannerId(
      placement: AdPlacement.appShell,
      platform: platform,
      buildMode: buildMode,
      isWeb: isWeb,
      androidReleaseBannerId: androidReleaseBannerId,
      iosReleaseBannerId: iosReleaseBannerId,
    );
  }

  group('AdUnitConfig.resolveBannerId', () {
    test('uses the official Android test banner outside release mode', () {
      expect(
        resolve(buildMode: AdBuildMode.debug),
        AdUnitConfig.androidTestBannerId,
      );
      expect(
        resolve(buildMode: AdBuildMode.profile),
        AdUnitConfig.androidTestBannerId,
      );
    });

    test('uses the official iOS test banner outside release mode', () {
      expect(
        resolve(platform: TargetPlatform.iOS, buildMode: AdBuildMode.debug),
        AdUnitConfig.iosTestBannerId,
      );
      expect(
        resolve(platform: TargetPlatform.iOS, buildMode: AdBuildMode.profile),
        AdUnitConfig.iosTestBannerId,
      );
    });

    test('uses the Android production default and accepts an override', () {
      expect(resolve(), androidProductionBanner);
      expect(
        resolve(androidReleaseBannerId: androidOverrideBanner),
        androidOverrideBanner,
      );
    });

    test('trims a valid release override', () {
      expect(
        resolve(androidReleaseBannerId: '  $androidOverrideBanner\n'),
        androidOverrideBanner,
      );
    });

    test('keeps iOS release disabled until a distinct unit is configured', () {
      expect(
        resolve(platform: TargetPlatform.iOS, iosReleaseBannerId: ''),
        isNull,
      );
      expect(
        resolve(
          platform: TargetPlatform.iOS,
          iosReleaseBannerId: androidProductionBanner,
        ),
        isNull,
      );
      expect(resolve(platform: TargetPlatform.iOS), iosProductionBanner);
    });

    test('rejects web and unsupported target platforms', () {
      expect(resolve(isWeb: true), isNull);
      for (final platform in <TargetPlatform>{
        TargetPlatform.fuchsia,
        TargetPlatform.linux,
        TargetPlatform.macOS,
        TargetPlatform.windows,
      }) {
        expect(resolve(platform: platform), isNull, reason: '$platform');
      }
    });

    test('rejects malformed values and App IDs', () {
      for (final value in <String>[
        '',
        'ca-app-pub-2681549212751095~2564398166',
        'ca-app-pub-not-digits/2645338964',
        'ca-app-pub-2681549212751095/',
        '2681549212751095/2645338964',
      ]) {
        expect(resolve(androidReleaseBannerId: value), isNull, reason: value);
      }
    });
  });

  group('AdUnitConfig.isValidBannerId', () {
    test('recognizes only slash-shaped banner unit IDs', () {
      expect(AdUnitConfig.isValidBannerId(androidProductionBanner), isTrue);
      expect(
        AdUnitConfig.isValidBannerId(' $androidProductionBanner '),
        isTrue,
      );
      expect(
        AdUnitConfig.isValidBannerId('ca-app-pub-2681549212751095~2564398166'),
        isFalse,
      );
      expect(AdUnitConfig.isValidBannerId('bad-value'), isFalse);
    });
  });
}
