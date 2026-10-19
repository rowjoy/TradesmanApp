import 'package:in_app_update/in_app_update.dart';

import '../domain/app_update_models.dart';

enum AndroidUpdateAvailability {
  unknown,
  notAvailable,
  available,
  developerTriggeredInProgress,
}

class AndroidUpdateSnapshot {
  const AndroidUpdateSnapshot({
    required this.availability,
    required this.immediateUpdateAllowed,
    required this.flexibleUpdateAllowed,
    required this.installStatus,
    required this.updatePriority,
    this.availableVersionCode,
    this.clientVersionStalenessDays,
  });

  final AndroidUpdateAvailability availability;
  final bool immediateUpdateAllowed;
  final bool flexibleUpdateAllowed;
  final AppUpdateInstallStatus installStatus;
  final int updatePriority;
  final int? availableVersionCode;
  final int? clientVersionStalenessDays;
}

/// Narrow wrapper around the static plugin API so policy can be unit tested.
abstract interface class AndroidInAppUpdateClient {
  Stream<AppUpdateInstallStatus> get installStatuses;

  Future<AndroidUpdateSnapshot> checkForUpdate();

  Future<AppUpdateActionResult> performImmediateUpdate();

  Future<AppUpdateActionResult> startFlexibleUpdate();

  Future<AppUpdateActionResult> completeFlexibleUpdate();
}

class PlayCoreInAppUpdateClient implements AndroidInAppUpdateClient {
  const PlayCoreInAppUpdateClient();

  @override
  Stream<AppUpdateInstallStatus> get installStatuses =>
      InAppUpdate.installUpdateListener.map(_mapInstallStatus);

  @override
  Future<AndroidUpdateSnapshot> checkForUpdate() async {
    final info = await InAppUpdate.checkForUpdate();
    return AndroidUpdateSnapshot(
      availability: _mapAvailability(info.updateAvailability),
      immediateUpdateAllowed: info.immediateUpdateAllowed,
      flexibleUpdateAllowed: info.flexibleUpdateAllowed,
      installStatus: _mapInstallStatus(info.installStatus),
      updatePriority: info.updatePriority,
      availableVersionCode: info.availableVersionCode,
      clientVersionStalenessDays: info.clientVersionStalenessDays,
    );
  }

  @override
  Future<AppUpdateActionResult> performImmediateUpdate() async {
    final result = await InAppUpdate.performImmediateUpdate();
    return _mapActionResult(result);
  }

  @override
  Future<AppUpdateActionResult> startFlexibleUpdate() async {
    final result = await InAppUpdate.startFlexibleUpdate();
    return _mapActionResult(result);
  }

  @override
  Future<AppUpdateActionResult> completeFlexibleUpdate() async {
    await InAppUpdate.completeFlexibleUpdate();
    return AppUpdateActionResult.accepted;
  }
}

/// Google Play update policy for WorkProof.
///
/// Priority 4-5 releases use the immediate flow when Play permits it. Other
/// releases prefer a flexible, dismissible update. An immediate-only update
/// below the critical threshold remains optional.
class AndroidAppUpdateGateway implements AppUpdateGateway {
  const AndroidAppUpdateGateway({
    required AndroidInAppUpdateClient client,
    this.immediatePriorityThreshold = 4,
  }) : _client = client;

  final AndroidInAppUpdateClient _client;
  final int immediatePriorityThreshold;

  @override
  AppUpdatePlatform get platform => AppUpdatePlatform.android;

  @override
  Stream<AppUpdateInstallStatus> get installStatuses => _client.installStatuses;

  @override
  Future<AppUpdateOffer?> checkForUpdate(AppUpdateCheckRequest request) async {
    final snapshot = await _client.checkForUpdate();
    final common = (
      installedVersion: request.installedVersion,
      availableBuildNumber: snapshot.availableVersionCode,
      priority: snapshot.updatePriority,
      stalenessDays: snapshot.clientVersionStalenessDays,
    );

    if (snapshot.installStatus == AppUpdateInstallStatus.downloaded) {
      return AppUpdateOffer(
        platform: platform,
        flow: AppUpdateFlow.flexible,
        installedVersion: common.installedVersion,
        availableBuildNumber: common.availableBuildNumber,
        priority: common.priority,
        stalenessDays: common.stalenessDays,
        isMandatory: false,
        installStatus: AppUpdateInstallStatus.downloaded,
      );
    }

    if (snapshot.availability ==
        AndroidUpdateAvailability.developerTriggeredInProgress) {
      return AppUpdateOffer(
        platform: platform,
        flow: AppUpdateFlow.immediate,
        installedVersion: common.installedVersion,
        availableBuildNumber: common.availableBuildNumber,
        priority: common.priority,
        stalenessDays: common.stalenessDays,
        isMandatory: snapshot.updatePriority >= immediatePriorityThreshold,
        installStatus: snapshot.installStatus,
        isUpdateInProgress: true,
      );
    }

    if (snapshot.availability != AndroidUpdateAvailability.available) {
      return null;
    }

    final isCritical = snapshot.updatePriority >= immediatePriorityThreshold;
    if (isCritical && snapshot.immediateUpdateAllowed) {
      return AppUpdateOffer(
        platform: platform,
        flow: AppUpdateFlow.immediate,
        installedVersion: common.installedVersion,
        availableBuildNumber: common.availableBuildNumber,
        priority: common.priority,
        stalenessDays: common.stalenessDays,
        isMandatory: true,
        installStatus: snapshot.installStatus,
      );
    }
    if (snapshot.flexibleUpdateAllowed) {
      return AppUpdateOffer(
        platform: platform,
        flow: AppUpdateFlow.flexible,
        installedVersion: common.installedVersion,
        availableBuildNumber: common.availableBuildNumber,
        priority: common.priority,
        stalenessDays: common.stalenessDays,
        isMandatory: false,
        installStatus: snapshot.installStatus,
      );
    }
    if (snapshot.immediateUpdateAllowed) {
      return AppUpdateOffer(
        platform: platform,
        flow: AppUpdateFlow.immediate,
        installedVersion: common.installedVersion,
        availableBuildNumber: common.availableBuildNumber,
        priority: common.priority,
        stalenessDays: common.stalenessDays,
        isMandatory: false,
        installStatus: snapshot.installStatus,
      );
    }
    return null;
  }

  @override
  Future<AppUpdateActionResult> startUpdate(AppUpdateOffer offer) {
    if (offer.platform != platform) {
      return Future.value(AppUpdateActionResult.unsupported);
    }
    return switch (offer.flow) {
      AppUpdateFlow.immediate => _client.performImmediateUpdate(),
      AppUpdateFlow.flexible => _client.startFlexibleUpdate(),
      AppUpdateFlow.storeRedirect => Future.value(
        AppUpdateActionResult.unsupported,
      ),
    };
  }

  @override
  Future<AppUpdateActionResult> completeUpdate() {
    return _client.completeFlexibleUpdate();
  }
}

AndroidUpdateAvailability _mapAvailability(UpdateAvailability availability) {
  if (availability == UpdateAvailability.updateNotAvailable) {
    return AndroidUpdateAvailability.notAvailable;
  }
  if (availability == UpdateAvailability.updateAvailable) {
    return AndroidUpdateAvailability.available;
  }
  if (availability == UpdateAvailability.developerTriggeredUpdateInProgress) {
    return AndroidUpdateAvailability.developerTriggeredInProgress;
  }
  return AndroidUpdateAvailability.unknown;
}

AppUpdateInstallStatus _mapInstallStatus(InstallStatus status) {
  if (status == InstallStatus.pending) return AppUpdateInstallStatus.pending;
  if (status == InstallStatus.downloading) {
    return AppUpdateInstallStatus.downloading;
  }
  if (status == InstallStatus.downloaded) {
    return AppUpdateInstallStatus.downloaded;
  }
  if (status == InstallStatus.installing) {
    return AppUpdateInstallStatus.installing;
  }
  if (status == InstallStatus.installed) {
    return AppUpdateInstallStatus.installed;
  }
  if (status == InstallStatus.canceled) {
    return AppUpdateInstallStatus.canceled;
  }
  if (status == InstallStatus.failed) return AppUpdateInstallStatus.failed;
  return AppUpdateInstallStatus.unknown;
}

AppUpdateActionResult _mapActionResult(AppUpdateResult result) {
  if (result == AppUpdateResult.success) {
    return AppUpdateActionResult.accepted;
  }
  if (result == AppUpdateResult.userDeniedUpdate) {
    return AppUpdateActionResult.canceled;
  }
  return AppUpdateActionResult.failed;
}
