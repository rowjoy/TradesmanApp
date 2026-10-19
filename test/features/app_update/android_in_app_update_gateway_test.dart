import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/features/app_update/domain/app_update_models.dart';
import 'package:tradesman_manager/features/app_update/infrastructure/android_in_app_update_gateway.dart';

void main() {
  const request = AppUpdateCheckRequest(packageName: 'com.workproof.workhelper', installedVersion: '1.0.0', installedBuildNumber: '10');

  test('priority four update is immediate and mandatory', () async {
    const gateway = AndroidAppUpdateGateway(
      client: _FakeAndroidClient(
        snapshot: AndroidUpdateSnapshot(
          availability: AndroidUpdateAvailability.available,
          immediateUpdateAllowed: true,
          flexibleUpdateAllowed: true,
          installStatus: AppUpdateInstallStatus.unknown,
          updatePriority: 4,
          availableVersionCode: 11,
        ),
      ),
    );

    final offer = await gateway.checkForUpdate(request);

    expect(offer?.flow, AppUpdateFlow.immediate);
    expect(offer?.isMandatory, isTrue);
    expect(offer?.availableBuildNumber, 11);
  });

  test('noncritical update prefers optional flexible flow', () async {
    const gateway = AndroidAppUpdateGateway(
      client: _FakeAndroidClient(
        snapshot: AndroidUpdateSnapshot(
          availability: AndroidUpdateAvailability.available,
          immediateUpdateAllowed: true,
          flexibleUpdateAllowed: true,
          installStatus: AppUpdateInstallStatus.unknown,
          updatePriority: 3,
          availableVersionCode: 11,
        ),
      ),
    );

    final offer = await gateway.checkForUpdate(request);

    expect(offer?.flow, AppUpdateFlow.flexible);
    expect(offer?.isMandatory, isFalse);
  });

  test('downloaded flexible update is ready to install', () async {
    const gateway = AndroidAppUpdateGateway(
      client: _FakeAndroidClient(
        snapshot: AndroidUpdateSnapshot(
          availability: AndroidUpdateAvailability.available,
          immediateUpdateAllowed: true,
          flexibleUpdateAllowed: true,
          installStatus: AppUpdateInstallStatus.downloaded,
          updatePriority: 1,
          availableVersionCode: 11,
        ),
      ),
    );

    final offer = await gateway.checkForUpdate(request);

    expect(offer?.isReadyToInstall, isTrue);
    expect(offer?.flow, AppUpdateFlow.flexible);
  });
}

class _FakeAndroidClient implements AndroidInAppUpdateClient {
  const _FakeAndroidClient({required this.snapshot});

  final AndroidUpdateSnapshot snapshot;

  @override
  Stream<AppUpdateInstallStatus> get installStatuses => const Stream<AppUpdateInstallStatus>.empty();

  @override
  Future<AndroidUpdateSnapshot> checkForUpdate() async => snapshot;

  @override
  Future<AppUpdateActionResult> completeFlexibleUpdate() async => AppUpdateActionResult.accepted;

  @override
  Future<AppUpdateActionResult> performImmediateUpdate() async => AppUpdateActionResult.accepted;

  @override
  Future<AppUpdateActionResult> startFlexibleUpdate() async => AppUpdateActionResult.accepted;
}
