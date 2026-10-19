enum AppUpdatePlatform { android, ios, unsupported }

enum AppUpdateFlow { flexible, immediate, storeRedirect }

enum AppUpdateInstallStatus {
  unknown,
  pending,
  downloading,
  downloaded,
  installing,
  installed,
  canceled,
  failed,
}

enum AppUpdateActionResult { accepted, canceled, failed, unsupported }

enum AppUpdatePhase {
  idle,
  checking,
  available,
  starting,
  downloading,
  readyToInstall,
  installing,
  redirectedToStore,
  completed,
  dismissed,
  failed,
}

class AppUpdateCheckRequest {
  const AppUpdateCheckRequest({
    required this.packageName,
    required this.installedVersion,
    required this.installedBuildNumber,
  });

  final String packageName;
  final String installedVersion;
  final String installedBuildNumber;
}

class AppUpdateOffer {
  const AppUpdateOffer({
    required this.platform,
    required this.flow,
    required this.installedVersion,
    required this.isMandatory,
    this.availableVersion,
    this.availableBuildNumber,
    this.priority,
    this.stalenessDays,
    this.storeUrl,
    this.installStatus = AppUpdateInstallStatus.unknown,
    this.isUpdateInProgress = false,
  });

  final AppUpdatePlatform platform;
  final AppUpdateFlow flow;
  final String installedVersion;
  final String? availableVersion;
  final int? availableBuildNumber;
  final bool isMandatory;
  final int? priority;
  final int? stalenessDays;
  final Uri? storeUrl;
  final AppUpdateInstallStatus installStatus;
  final bool isUpdateInProgress;

  bool get isReadyToInstall =>
      installStatus == AppUpdateInstallStatus.downloaded;

  String get id => [
    platform.name,
    availableVersion ?? '',
    availableBuildNumber?.toString() ?? '',
    flow.name,
  ].join(':');
}

class AppUpdateState {
  const AppUpdateState({
    this.phase = AppUpdatePhase.idle,
    this.offer,
    this.errorCode,
  });

  final AppUpdatePhase phase;
  final AppUpdateOffer? offer;
  final String? errorCode;

  bool get hasActionableUpdate =>
      phase == AppUpdatePhase.available ||
      phase == AppUpdatePhase.readyToInstall;

  bool get isBusy => switch (phase) {
    AppUpdatePhase.checking ||
    AppUpdatePhase.starting ||
    AppUpdatePhase.downloading ||
    AppUpdatePhase.installing => true,
    _ => false,
  };
}

abstract interface class AppUpdateGateway {
  AppUpdatePlatform get platform;

  Stream<AppUpdateInstallStatus> get installStatuses;

  Future<AppUpdateOffer?> checkForUpdate(AppUpdateCheckRequest request);

  Future<AppUpdateActionResult> startUpdate(AppUpdateOffer offer);

  Future<AppUpdateActionResult> completeUpdate();
}
