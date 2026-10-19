import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tradesman_manager/features/app_update/domain/app_update_models.dart';
import 'package:tradesman_manager/features/app_update/infrastructure/apple_app_store_gateway.dart';

void main() {
  const request = AppUpdateCheckRequest(packageName: 'com.workproof.workhelper', installedVersion: '1.9.0', installedBuildNumber: '9');

  test('uses configured App Store ID and country', () async {
    Uri? requestedUri;
    final client = MockClient((request) async {
      requestedUri = request.url;
      return http.Response(_lookupBody(version: '1.10.0'), 200);
    });
    final gateway = AppleAppStoreGateway(
      lookupClient: AppleAppStoreLookupClient(
        httpClient: client,
        config: const AppleAppStoreConfig(appStoreId: '123456789', countryCode: 'GB'),
      ),
    );

    final offer = await gateway.checkForUpdate(request);

    expect(requestedUri?.queryParameters['id'], '123456789');
    expect(requestedUri?.queryParameters['bundleId'], isNull);
    expect(requestedUri?.queryParameters['country'], 'gb');
    expect(offer?.availableVersion, '1.10.0');
    expect(offer?.flow, AppUpdateFlow.storeRedirect);
    expect(offer?.isMandatory, isFalse);
  });

  test('falls back to bundle ID when App Store ID is absent', () async {
    Uri? requestedUri;
    final client = MockClient((request) async {
      requestedUri = request.url;
      return http.Response(_lookupBody(version: '2.0'), 200);
    });
    final gateway = AppleAppStoreGateway(
      lookupClient: AppleAppStoreLookupClient(
        httpClient: client,
        config: const AppleAppStoreConfig(appStoreId: ''),
      ),
    );

    await gateway.checkForUpdate(request);

    expect(requestedUri?.queryParameters['bundleId'], 'com.workproof.workhelper');
    expect(requestedUri?.queryParameters['id'], isNull);
  });

  test('rejects a response for a different bundle', () async {
    final client = MockClient((_) async {
      return http.Response(_lookupBody(version: '2.0', bundleId: 'com.someone.else'), 200);
    });
    final gateway = AppleAppStoreGateway(
      lookupClient: AppleAppStoreLookupClient(
        httpClient: client,
        config: const AppleAppStoreConfig(appStoreId: '123456789'),
      ),
    );

    expect(await gateway.checkForUpdate(request), isNull);
  });

  test('rejects a non-HTTPS store URL', () {
    expect(
      AppleAppStoreRelease.parseLookupResponse(
        _lookupBody(version: '2.0', url: 'itms-apps://example.invalid/app'),
        expectedBundleId: request.packageName,
      ),
      isNull,
    );
  });

  test('opens validated store URL through injected external launcher', () async {
    final client = MockClient((_) async {
      return http.Response(_lookupBody(version: '2.0'), 200);
    });
    Uri? launchedUrl;
    final gateway = AppleAppStoreGateway(
      lookupClient: AppleAppStoreLookupClient(
        httpClient: client,
        config: const AppleAppStoreConfig(appStoreId: '123456789'),
      ),
      externalUrlLauncher: (uri) async {
        launchedUrl = uri;
        return true;
      },
    );
    final offer = await gateway.checkForUpdate(request);

    final result = await gateway.startUpdate(offer!);

    expect(result, AppUpdateActionResult.accepted);
    expect(launchedUrl, Uri.parse('https://apps.apple.com/app/id123456789'));
  });
}

String _lookupBody({required String version, String bundleId = 'com.workproof.workhelper', String url = 'https://apps.apple.com/app/id123456789'}) {
  return jsonEncode({
    'resultCount': 1,
    'results': [
      {'bundleId': bundleId, 'version': version, 'trackViewUrl': url},
    ],
  });
}
