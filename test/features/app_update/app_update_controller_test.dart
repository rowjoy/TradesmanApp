import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/core/providers/app_metadata_provider.dart';
import 'package:tradesman_manager/features/app_update/application/app_update_controller.dart';
import 'package:tradesman_manager/features/app_update/domain/app_update_models.dart';

void main() {
  const metadata = AppMetadata(appName: 'WorkProof', packageName: 'com.workproof.workhelper', version: '1.0.0', buildNumber: '10');

  test('checks once and suppresses a dismissed optional offer this session', () async {
    final gateway = _FakeGateway(offer: _optionalOffer);
    final controller = AppUpdateController(gateway: gateway, loadMetadata: () async => metadata);
    addTearDown(() async {
      controller.dispose();
      await gateway.close();
    });

    await controller.checkForUpdate();
    await controller.checkForUpdate();
    expect(gateway.checkCount, 1);
    expect(controller.state.phase, AppUpdatePhase.available);

    expect(controller.dismissUpdate(), isTrue);
    await controller.onResumed();

    expect(gateway.checkCount, 2);
    expect(controller.state.phase, AppUpdatePhase.dismissed);
  });

  test('check failure is represented without throwing', () async {
    final gateway = _FakeGateway(checkError: StateError('offline'));
    final controller = AppUpdateController(gateway: gateway, loadMetadata: () async => metadata);
    addTearDown(() async {
      controller.dispose();
      await gateway.close();
    });

    await expectLater(controller.checkForUpdate(), completes);

    expect(controller.state.phase, AppUpdatePhase.failed);
    expect(controller.state.errorCode, 'update_check_failed');
  });

  test('resumes a developer-triggered immediate update', () async {
    final gateway = _FakeGateway(
      offer: const AppUpdateOffer(
        platform: AppUpdatePlatform.android,
        flow: AppUpdateFlow.immediate,
        installedVersion: '1.0.0',
        availableBuildNumber: 11,
        isMandatory: true,
        isUpdateInProgress: true,
      ),
    );
    final controller = AppUpdateController(gateway: gateway, loadMetadata: () async => metadata);
    addTearDown(() async {
      controller.dispose();
      await gateway.close();
    });

    await controller.onResumed();

    expect(gateway.startCount, 1);
    expect(controller.state.phase, AppUpdatePhase.installing);
  });

  test('does not re-present an optional store redirect after resume', () async {
    final storeOffer = AppUpdateOffer(
      platform: AppUpdatePlatform.ios,
      flow: AppUpdateFlow.storeRedirect,
      installedVersion: '1.0.0',
      availableVersion: '1.1.0',
      isMandatory: false,
      storeUrl: Uri.https('apps.apple.com', '/app/id123'),
    );
    final gateway = _FakeGateway(offer: storeOffer);
    final controller = AppUpdateController(gateway: gateway, loadMetadata: () async => metadata);
    addTearDown(() async {
      controller.dispose();
      await gateway.close();
    });

    await controller.checkForUpdate();
    await controller.startUpdate();
    expect(controller.state.phase, AppUpdatePhase.redirectedToStore);

    await controller.onResumed();

    expect(gateway.checkCount, 2);
    expect(gateway.startCount, 1);
    expect(controller.state.phase, AppUpdatePhase.dismissed);
  });

  test('install listener exposes a downloaded flexible update', () async {
    final gateway = _FakeGateway(offer: _optionalOffer);
    final controller = AppUpdateController(gateway: gateway, loadMetadata: () async => metadata);
    addTearDown(() async {
      controller.dispose();
      await gateway.close();
    });
    await controller.checkForUpdate();
    await controller.startUpdate();

    gateway.emit(AppUpdateInstallStatus.downloaded);
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.phase, AppUpdatePhase.readyToInstall);
    await controller.completeUpdate();
    expect(gateway.completeCount, 1);
    expect(controller.state.phase, AppUpdatePhase.installing);
  });

  test('a canceled mandatory flow remains actionable', () async {
    final gateway = _FakeGateway(offer: _mandatoryOffer, startResult: AppUpdateActionResult.canceled);
    final controller = AppUpdateController(gateway: gateway, loadMetadata: () async => metadata);
    addTearDown(() async {
      controller.dispose();
      await gateway.close();
    });

    await controller.checkForUpdate();
    await controller.startUpdate();

    expect(controller.state.phase, AppUpdatePhase.available);
    expect(controller.state.offer?.isMandatory, isTrue);

    gateway.emit(AppUpdateInstallStatus.canceled);
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.phase, AppUpdatePhase.available);
  });

  test('a resume during a native update action is reconciled afterwards', () async {
    final startCompleter = Completer<AppUpdateActionResult>();
    final gateway = _FakeGateway(offer: _mandatoryOffer, startCompleter: startCompleter);
    final controller = AppUpdateController(gateway: gateway, loadMetadata: () async => metadata);
    addTearDown(() async {
      controller.dispose();
      await gateway.close();
    });

    await controller.checkForUpdate();
    final starting = controller.startUpdate();
    await Future<void>.delayed(Duration.zero);

    await controller.onResumed();
    startCompleter.complete(AppUpdateActionResult.accepted);
    await starting;
    await Future<void>.delayed(Duration.zero);

    expect(gateway.checkCount, 2);
    expect(controller.state.phase, AppUpdatePhase.installing);
  });
}

const _optionalOffer = AppUpdateOffer(
  platform: AppUpdatePlatform.android,
  flow: AppUpdateFlow.flexible,
  installedVersion: '1.0.0',
  availableBuildNumber: 11,
  isMandatory: false,
);

const _mandatoryOffer = AppUpdateOffer(
  platform: AppUpdatePlatform.android,
  flow: AppUpdateFlow.immediate,
  installedVersion: '1.0.0',
  availableBuildNumber: 11,
  isMandatory: true,
);

class _FakeGateway implements AppUpdateGateway {
  _FakeGateway({this.offer, this.checkError, this.startResult = AppUpdateActionResult.accepted, this.startCompleter});

  final AppUpdateOffer? offer;
  final Object? checkError;
  final AppUpdateActionResult startResult;
  final Completer<AppUpdateActionResult>? startCompleter;
  final StreamController<AppUpdateInstallStatus> _statuses = StreamController<AppUpdateInstallStatus>.broadcast();

  int checkCount = 0;
  int startCount = 0;
  int completeCount = 0;

  @override
  AppUpdatePlatform get platform => AppUpdatePlatform.android;

  @override
  Stream<AppUpdateInstallStatus> get installStatuses => _statuses.stream;

  @override
  Future<AppUpdateOffer?> checkForUpdate(AppUpdateCheckRequest request) async {
    checkCount++;
    if (checkError case final error?) throw error;
    return offer;
  }

  @override
  Future<AppUpdateActionResult> startUpdate(AppUpdateOffer offer) async {
    startCount++;
    final completer = startCompleter;
    if (completer != null) return completer.future;
    return startResult;
  }

  @override
  Future<AppUpdateActionResult> completeUpdate() async {
    completeCount++;
    return AppUpdateActionResult.accepted;
  }

  void emit(AppUpdateInstallStatus status) => _statuses.add(status);

  Future<void> close() => _statuses.close();
}
