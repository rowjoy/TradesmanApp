import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../domain/app_update_models.dart';
import '../domain/app_version.dart';

class AppleAppStoreConfig {
  const AppleAppStoreConfig({this.appStoreId = '', this.countryCode = 'us'});

  const AppleAppStoreConfig.fromEnvironment()
    : appStoreId = const String.fromEnvironment('APP_STORE_ID'),
      countryCode = const String.fromEnvironment(
        'APP_STORE_COUNTRY',
        defaultValue: 'us',
      );

  final String appStoreId;
  final String countryCode;

  String? get normalizedAppStoreId {
    final value = appStoreId.trim();
    return RegExp(r'^\d+$').hasMatch(value) ? value : null;
  }

  String get normalizedCountryCode {
    final value = countryCode.trim().toLowerCase();
    return RegExp(r'^[a-z]{2}$').hasMatch(value) ? value : 'us';
  }
}

class AppleAppStoreRelease {
  const AppleAppStoreRelease({
    required this.bundleId,
    required this.version,
    required this.trackViewUrl,
  });

  final String bundleId;
  final String version;
  final Uri trackViewUrl;

  static AppleAppStoreRelease? parseLookupResponse(
    String responseBody, {
    required String expectedBundleId,
  }) {
    final decoded = jsonDecode(responseBody);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid App Store lookup response');
    }
    final results = decoded['results'];
    if (results is! List) {
      throw const FormatException('Missing App Store lookup results');
    }

    final expected = expectedBundleId.trim().toLowerCase();
    for (final value in results) {
      if (value is! Map) continue;
      final bundleId = value['bundleId'];
      final version = value['version'];
      final trackViewUrl = value['trackViewUrl'];
      if (bundleId is! String ||
          version is! String ||
          trackViewUrl is! String ||
          bundleId.trim().toLowerCase() != expected ||
          NumericAppVersion.tryParse(version) == null) {
        continue;
      }
      final uri = Uri.tryParse(trackViewUrl);
      if (uri == null || !_isTrustedAppStoreUrl(uri)) continue;
      return AppleAppStoreRelease(
        bundleId: bundleId,
        version: version,
        trackViewUrl: uri,
      );
    }
    return null;
  }
}

class AppleAppStoreLookupClient {
  const AppleAppStoreLookupClient({
    required http.Client httpClient,
    required AppleAppStoreConfig config,
    this.timeout = const Duration(seconds: 5),
  }) : _httpClient = httpClient,
       _config = config;

  final http.Client _httpClient;
  final AppleAppStoreConfig _config;
  final Duration timeout;

  Future<AppleAppStoreRelease?> lookup({required String bundleId}) async {
    final query = <String, String>{
      'country': _config.normalizedCountryCode,
      if (_config.normalizedAppStoreId case final appStoreId?)
        'id': appStoreId
      else
        'bundleId': bundleId,
    };
    final uri = Uri.https('itunes.apple.com', '/lookup', query);
    final response = await _httpClient.get(uri).timeout(timeout);
    if (response.statusCode != 200) {
      throw AppleAppStoreLookupException('http_${response.statusCode}');
    }
    return AppleAppStoreRelease.parseLookupResponse(
      response.body,
      expectedBundleId: bundleId,
    );
  }
}

class AppleAppStoreLookupException implements Exception {
  const AppleAppStoreLookupException(this.code);

  final String code;

  @override
  String toString() => 'AppleAppStoreLookupException($code)';
}

typedef ExternalUrlLauncher = Future<bool> Function(Uri uri);

Future<bool> launchExternalAppStoreUrl(Uri uri) {
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

class AppleAppStoreGateway implements AppUpdateGateway {
  const AppleAppStoreGateway({
    required AppleAppStoreLookupClient lookupClient,
    ExternalUrlLauncher externalUrlLauncher = launchExternalAppStoreUrl,
  }) : _lookupClient = lookupClient,
       _externalUrlLauncher = externalUrlLauncher;

  final AppleAppStoreLookupClient _lookupClient;
  final ExternalUrlLauncher _externalUrlLauncher;

  @override
  AppUpdatePlatform get platform => AppUpdatePlatform.ios;

  @override
  Stream<AppUpdateInstallStatus> get installStatuses =>
      const Stream<AppUpdateInstallStatus>.empty();

  @override
  Future<AppUpdateOffer?> checkForUpdate(AppUpdateCheckRequest request) async {
    final release = await _lookupClient.lookup(bundleId: request.packageName);
    if (release == null ||
        !isAvailableVersionNewer(
          installedVersion: request.installedVersion,
          availableVersion: release.version,
        )) {
      return null;
    }
    return AppUpdateOffer(
      platform: platform,
      flow: AppUpdateFlow.storeRedirect,
      installedVersion: request.installedVersion,
      availableVersion: release.version,
      isMandatory: false,
      storeUrl: release.trackViewUrl,
    );
  }

  @override
  Future<AppUpdateActionResult> startUpdate(AppUpdateOffer offer) async {
    final url = offer.storeUrl;
    if (offer.platform != platform ||
        offer.flow != AppUpdateFlow.storeRedirect ||
        url == null ||
        !_isTrustedAppStoreUrl(url)) {
      return AppUpdateActionResult.unsupported;
    }
    final launched = await _externalUrlLauncher(url);
    return launched
        ? AppUpdateActionResult.accepted
        : AppUpdateActionResult.failed;
  }

  @override
  Future<AppUpdateActionResult> completeUpdate() async {
    return AppUpdateActionResult.unsupported;
  }
}

bool _isTrustedAppStoreUrl(Uri uri) {
  if (uri.scheme.toLowerCase() != 'https') return false;
  final host = uri.host.toLowerCase();
  return host == 'apps.apple.com' || host == 'itunes.apple.com';
}
