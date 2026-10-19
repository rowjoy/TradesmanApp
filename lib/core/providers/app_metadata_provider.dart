import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Store-facing metadata for the currently installed application.
class AppMetadata {
  const AppMetadata({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
  });

  factory AppMetadata.fromPackageInfo(PackageInfo packageInfo) => AppMetadata(
    appName: packageInfo.appName,
    packageName: packageInfo.packageName,
    version: packageInfo.version,
    buildNumber: packageInfo.buildNumber,
  );

  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;

  String get versionWithBuild =>
      buildNumber.isEmpty ? version : '$version+$buildNumber';
}

/// The native package lookup, cached for the lifetime of the provider scope.
///
/// Keeping this provider separate makes platform metadata straightforward to
/// replace in tests without repeatedly invoking a method channel.
final packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

/// A presentation- and feature-friendly view of [packageInfoProvider].
///
/// This provider is intentionally not auto-disposed: About and update checks
/// share one native lookup during an application session.
final appMetadataProvider = FutureProvider<AppMetadata>((ref) async {
  final packageInfo = await ref.watch(packageInfoProvider.future);
  return AppMetadata.fromPackageInfo(packageInfo);
});
