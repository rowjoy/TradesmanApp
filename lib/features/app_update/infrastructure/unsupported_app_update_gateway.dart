import '../domain/app_update_models.dart';

class UnsupportedAppUpdateGateway implements AppUpdateGateway {
  const UnsupportedAppUpdateGateway();

  @override
  AppUpdatePlatform get platform => AppUpdatePlatform.unsupported;

  @override
  Stream<AppUpdateInstallStatus> get installStatuses =>
      const Stream<AppUpdateInstallStatus>.empty();

  @override
  Future<AppUpdateOffer?> checkForUpdate(AppUpdateCheckRequest request) async {
    return null;
  }

  @override
  Future<AppUpdateActionResult> startUpdate(AppUpdateOffer offer) async {
    return AppUpdateActionResult.unsupported;
  }

  @override
  Future<AppUpdateActionResult> completeUpdate() async {
    return AppUpdateActionResult.unsupported;
  }
}
