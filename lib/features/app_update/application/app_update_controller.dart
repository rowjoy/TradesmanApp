import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/providers/app_metadata_provider.dart';
import '../domain/app_update_models.dart';
import '../infrastructure/android_in_app_update_gateway.dart';
import '../infrastructure/apple_app_store_gateway.dart';
import '../infrastructure/unsupported_app_update_gateway.dart';

typedef AppMetadataLoader = Future<AppMetadata> Function();

/// Coordinates store checks and update actions without owning any UI.
///
/// Every external failure becomes a non-blocking state. Presentation code may
/// report it, but startup and the local workspace remain usable.
class AppUpdateController extends StateNotifier<AppUpdateState> {
  AppUpdateController({
    required AppUpdateGateway gateway,
    required AppMetadataLoader loadMetadata,
  }) : _gateway = gateway,
       _loadMetadata = loadMetadata,
       super(const AppUpdateState()) {
    _installStatusSubscription = _gateway.installStatuses.listen(
      _handleInstallStatus,
      onError: (_, __) => _setFailure('install_status_failed'),
    );
  }

  final AppUpdateGateway _gateway;
  final AppMetadataLoader _loadMetadata;
  final Set<String> _dismissedOfferIds = <String>{};

  StreamSubscription<AppUpdateInstallStatus>? _installStatusSubscription;
  bool _hasChecked = false;
  bool _isChecking = false;
  bool _isStarting = false;
  bool _resumeCheckPending = false;

  Future<void> checkForUpdate({bool force = false}) {
    return _checkForUpdate(force: force, resumed: false);
  }

  /// Reconciles Play update state whenever the application returns to the
  /// foreground. A previously started immediate update is resumed, and a
  /// downloaded flexible update becomes actionable again.
  Future<void> onResumed() {
    if (_isChecking || _isStarting) {
      _resumeCheckPending = true;
      return Future<void>.value();
    }
    return _checkForUpdate(force: true, resumed: true);
  }

  Future<void> _checkForUpdate({
    required bool force,
    required bool resumed,
  }) async {
    if (_isChecking || _isStarting || (_hasChecked && !force)) return;
    _isChecking = true;
    final showChecking =
        !resumed &&
        (state.phase == AppUpdatePhase.idle ||
            state.phase == AppUpdatePhase.failed);
    if (showChecking) {
      state = const AppUpdateState(phase: AppUpdatePhase.checking);
    }

    try {
      final metadata = await _loadMetadata();
      final offer = await _gateway.checkForUpdate(
        AppUpdateCheckRequest(
          packageName: metadata.packageName,
          installedVersion: metadata.version,
          installedBuildNumber: metadata.buildNumber,
        ),
      );
      _hasChecked = true;
      if (!mounted) return;
      await _applyCheckedOffer(offer);
    } catch (_) {
      _hasChecked = true;
      _setFailure('update_check_failed');
    } finally {
      _isChecking = false;
      _runPendingResumeCheck();
    }
  }

  Future<void> _applyCheckedOffer(AppUpdateOffer? offer) async {
    if (offer == null) {
      state = const AppUpdateState();
      return;
    }
    if (offer.isReadyToInstall) {
      state = AppUpdateState(
        phase: AppUpdatePhase.readyToInstall,
        offer: offer,
      );
      return;
    }
    if (offer.isUpdateInProgress) {
      await _startOffer(offer);
      return;
    }
    if (!offer.isMandatory && _dismissedOfferIds.contains(offer.id)) {
      state = AppUpdateState(phase: AppUpdatePhase.dismissed, offer: offer);
      return;
    }
    if (state.offer?.id == offer.id &&
        (state.phase == AppUpdatePhase.available ||
            state.phase == AppUpdatePhase.downloading ||
            state.phase == AppUpdatePhase.installing)) {
      return;
    }
    state = AppUpdateState(phase: AppUpdatePhase.available, offer: offer);
  }

  /// Records "Later" for this offer for the current application session.
  /// Mandatory offers cannot be dismissed by presentation UI.
  bool dismissUpdate() {
    final offer = state.offer;
    if (offer == null || offer.isMandatory) return false;
    _dismissedOfferIds.add(offer.id);
    state = AppUpdateState(phase: AppUpdatePhase.dismissed, offer: offer);
    return true;
  }

  Future<void> startUpdate() async {
    final offer = state.offer;
    if (offer == null || state.phase == AppUpdatePhase.readyToInstall) return;
    await _startOffer(offer);
  }

  Future<void> _startOffer(AppUpdateOffer offer) async {
    if (_isStarting) return;
    _isStarting = true;
    state = AppUpdateState(phase: AppUpdatePhase.starting, offer: offer);
    try {
      final result = await _gateway.startUpdate(offer);
      if (!mounted) return;
      switch (result) {
        case AppUpdateActionResult.accepted:
          // Returning from the App Store must not immediately re-present the
          // same optional offer during this application session.
          if (offer.flow == AppUpdateFlow.storeRedirect && !offer.isMandatory) {
            _dismissedOfferIds.add(offer.id);
          }
          state = AppUpdateState(
            phase: switch (offer.flow) {
              // in_app_update 4.2.5 resolves startFlexibleUpdate only after
              // Play reports that the download has completed.
              AppUpdateFlow.flexible => AppUpdatePhase.readyToInstall,
              AppUpdateFlow.immediate => AppUpdatePhase.installing,
              AppUpdateFlow.storeRedirect => AppUpdatePhase.redirectedToStore,
            },
            offer: offer,
          );
          break;
        case AppUpdateActionResult.canceled:
          if (offer.isMandatory) {
            state = AppUpdateState(
              phase: AppUpdatePhase.available,
              offer: offer,
            );
          } else {
            _dismissedOfferIds.add(offer.id);
            state = AppUpdateState(
              phase: AppUpdatePhase.dismissed,
              offer: offer,
            );
          }
          break;
        case AppUpdateActionResult.failed:
        case AppUpdateActionResult.unsupported:
          _setFailure('update_start_failed', offer: offer);
          break;
      }
    } catch (_) {
      _setFailure('update_start_failed', offer: offer);
    } finally {
      _isStarting = false;
      _runPendingResumeCheck();
    }
  }

  Future<void> completeUpdate() async {
    final offer = state.offer;
    if (_isStarting ||
        offer == null ||
        state.phase != AppUpdatePhase.readyToInstall) {
      return;
    }
    _isStarting = true;
    state = AppUpdateState(phase: AppUpdatePhase.installing, offer: offer);
    try {
      final result = await _gateway.completeUpdate();
      if (!mounted) return;
      if (result == AppUpdateActionResult.accepted) {
        state = AppUpdateState(phase: AppUpdatePhase.installing, offer: offer);
      } else {
        _setFailure('update_complete_failed', offer: offer);
      }
    } catch (_) {
      _setFailure('update_complete_failed', offer: offer);
    } finally {
      _isStarting = false;
    }
  }

  void _handleInstallStatus(AppUpdateInstallStatus status) {
    if (!mounted) return;
    final offer = state.offer;
    if (offer == null) return;
    switch (status) {
      case AppUpdateInstallStatus.pending:
      case AppUpdateInstallStatus.downloading:
        state = AppUpdateState(phase: AppUpdatePhase.downloading, offer: offer);
        break;
      case AppUpdateInstallStatus.downloaded:
        state = AppUpdateState(
          phase: AppUpdatePhase.readyToInstall,
          offer: offer,
        );
        break;
      case AppUpdateInstallStatus.installing:
        state = AppUpdateState(phase: AppUpdatePhase.installing, offer: offer);
        break;
      case AppUpdateInstallStatus.installed:
        state = AppUpdateState(phase: AppUpdatePhase.completed, offer: offer);
        break;
      case AppUpdateInstallStatus.canceled:
        if (offer.isMandatory) {
          state = AppUpdateState(phase: AppUpdatePhase.available, offer: offer);
        } else {
          _dismissedOfferIds.add(offer.id);
          state = AppUpdateState(phase: AppUpdatePhase.dismissed, offer: offer);
        }
        break;
      case AppUpdateInstallStatus.failed:
        _setFailure('update_install_failed', offer: offer);
        break;
      case AppUpdateInstallStatus.unknown:
        break;
    }
  }

  void _setFailure(String errorCode, {AppUpdateOffer? offer}) {
    if (!mounted) return;
    state = AppUpdateState(
      phase: AppUpdatePhase.failed,
      offer: offer ?? state.offer,
      errorCode: errorCode,
    );
  }

  void _runPendingResumeCheck() {
    if (!mounted || !_resumeCheckPending || _isChecking || _isStarting) return;
    _resumeCheckPending = false;
    unawaited(_checkForUpdate(force: true, resumed: true));
  }

  @override
  void dispose() {
    unawaited(_installStatusSubscription?.cancel());
    super.dispose();
  }
}

final androidInAppUpdateClientProvider = Provider<AndroidInAppUpdateClient>((
  ref,
) {
  return const PlayCoreInAppUpdateClient();
});

final appleAppStoreConfigProvider = Provider<AppleAppStoreConfig>((ref) {
  return const AppleAppStoreConfig.fromEnvironment();
});

final appStoreHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final externalAppStoreUrlLauncherProvider = Provider<ExternalUrlLauncher>((
  ref,
) {
  return launchExternalAppStoreUrl;
});

final appUpdateGatewayProvider = Provider<AppUpdateGateway>((ref) {
  if (kIsWeb) return const UnsupportedAppUpdateGateway();
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => AndroidAppUpdateGateway(
      client: ref.watch(androidInAppUpdateClientProvider),
    ),
    TargetPlatform.iOS => AppleAppStoreGateway(
      lookupClient: AppleAppStoreLookupClient(
        httpClient: ref.watch(appStoreHttpClientProvider),
        config: ref.watch(appleAppStoreConfigProvider),
      ),
      externalUrlLauncher: ref.watch(externalAppStoreUrlLauncherProvider),
    ),
    _ => const UnsupportedAppUpdateGateway(),
  };
});

final appUpdateControllerProvider =
    StateNotifierProvider<AppUpdateController, AppUpdateState>((ref) {
      return AppUpdateController(
        gateway: ref.watch(appUpdateGatewayProvider),
        loadMetadata: () => ref.read(appMetadataProvider.future),
      );
    });
