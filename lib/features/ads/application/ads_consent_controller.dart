import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const _adsOperationTimeout = Duration(seconds: 45);

bool get _adsPlatformSupported =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

enum AdsConsentStatus { idle, gathering, ready }

enum PrivacyChoiceResult { shown, notRequired, failed }

class AdsConsentState {
  const AdsConsentState({
    this.status = AdsConsentStatus.idle,
    this.canRequestAds = false,
    this.privacyOptionsRequired = false,
    this.sdkInitialized = false,
    this.errorCode,
  });

  final AdsConsentStatus status;
  final bool canRequestAds;
  final bool privacyOptionsRequired;
  final bool sdkInitialized;
  final String? errorCode;

  bool get adsReady => canRequestAds && sdkInitialized;

  AdsConsentState copyWith({
    AdsConsentStatus? status,
    bool? canRequestAds,
    bool? privacyOptionsRequired,
    bool? sdkInitialized,
    String? errorCode,
    bool clearError = false,
  }) => AdsConsentState(
    status: status ?? this.status,
    canRequestAds: canRequestAds ?? this.canRequestAds,
    privacyOptionsRequired:
        privacyOptionsRequired ?? this.privacyOptionsRequired,
    sdkInitialized: sdkInitialized ?? this.sdkInitialized,
    errorCode: clearError ? null : errorCode ?? this.errorCode,
  );
}

class AdsConsentController extends StateNotifier<AdsConsentState> {
  AdsConsentController() : super(const AdsConsentState());

  Future<void>? _initialization;

  Future<void> initialize() => _initialization ??= _initializeSafely();

  Future<void> _initializeSafely() async {
    if (!_adsPlatformSupported) {
      _markAdsUnavailable('ads_unsupported_platform');
      return;
    }
    try {
      await _initialize();
    } catch (_) {
      _markAdsUnavailable('ads_initialization_failed');
    }
  }

  Future<void> _initialize() async {
    state = state.copyWith(
      status: AdsConsentStatus.gathering,
      clearError: true,
    );
    final completer = Completer<void>();
    var settling = false;

    Future<void> settle({String? errorCode}) async {
      if (settling || completer.isCompleted) return;
      settling = true;
      await _finishConsentSafely(errorCode: errorCode);
      if (!completer.isCompleted) completer.complete();
    }

    final timeout = Timer(_adsOperationTimeout, () {
      if (completer.isCompleted) return;
      _markAdsUnavailable('consent_timeout');
      completer.complete();
    });
    final parameters = ConsentRequestParameters();
    try {
      ConsentInformation.instance.requestConsentInfoUpdate(parameters, () {
        try {
          ConsentForm.loadAndShowConsentFormIfRequired((formError) {
            unawaited(
              settle(
                errorCode: formError == null ? null : 'consent_form_failed',
              ),
            );
          });
        } catch (_) {
          unawaited(settle(errorCode: 'consent_form_failed'));
        }
      }, (_) => unawaited(settle(errorCode: 'consent_update_failed')));
    } catch (_) {
      await settle(errorCode: 'consent_update_failed');
    }
    await completer.future;
    timeout.cancel();
  }

  Future<PrivacyChoiceResult> showPrivacyChoices() async {
    if (!_adsPlatformSupported) return PrivacyChoiceResult.failed;
    try {
      if (state.errorCode != null) {
        _initialization = null;
        await initialize();
        if (state.errorCode != null && !state.privacyOptionsRequired) {
          return PrivacyChoiceResult.failed;
        }
      }
      final requirement = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus()
          .timeout(_adsOperationTimeout);
      if (requirement != PrivacyOptionsRequirementStatus.required) {
        final refreshed = await _finishConsentSafely();
        return refreshed
            ? PrivacyChoiceResult.notRequired
            : PrivacyChoiceResult.failed;
      }
      state = state.copyWith(
        status: AdsConsentStatus.gathering,
        clearError: true,
      );
      final completer = Completer<PrivacyChoiceResult>();
      final timeout = Timer(_adsOperationTimeout, () {
        if (completer.isCompleted) return;
        state = state.copyWith(
          status: AdsConsentStatus.ready,
          errorCode: 'privacy_options_timeout',
        );
        completer.complete(PrivacyChoiceResult.failed);
      });
      try {
        ConsentForm.showPrivacyOptionsForm((formError) {
          unawaited(_completePrivacyChoice(completer, formError));
        });
      } catch (_) {
        timeout.cancel();
        state = state.copyWith(
          status: AdsConsentStatus.ready,
          errorCode: 'privacy_options_failed',
        );
        return PrivacyChoiceResult.failed;
      }
      final result = await completer.future;
      timeout.cancel();
      return result;
    } catch (_) {
      state = state.copyWith(
        status: AdsConsentStatus.ready,
        errorCode: 'privacy_options_failed',
      );
      return PrivacyChoiceResult.failed;
    }
  }

  Future<void> _finishConsent({String? errorCode}) async {
    final canRequest = await ConsentInformation.instance
        .canRequestAds()
        .timeout(_adsOperationTimeout);
    final requirement = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus()
        .timeout(_adsOperationTimeout);
    var initialized = state.sdkInitialized;
    var resolvedError = errorCode;
    if (canRequest && !initialized) {
      try {
        await MobileAds.instance.initialize().timeout(_adsOperationTimeout);
        initialized = true;
      } catch (_) {
        resolvedError = 'mobile_ads_initialization_failed';
      }
    }
    state = AdsConsentState(
      status: AdsConsentStatus.ready,
      canRequestAds: canRequest,
      privacyOptionsRequired:
          requirement == PrivacyOptionsRequirementStatus.required,
      sdkInitialized: initialized,
      errorCode: resolvedError,
    );
  }

  Future<bool> _finishConsentSafely({String? errorCode}) async {
    try {
      await _finishConsent(errorCode: errorCode);
      return true;
    } catch (_) {
      _markAdsUnavailable('ads_initialization_failed');
      return false;
    }
  }

  Future<void> _completePrivacyChoice(
    Completer<PrivacyChoiceResult> completer,
    FormError? formError,
  ) async {
    if (completer.isCompleted) return;
    final refreshed = await _finishConsentSafely(
      errorCode: formError == null ? null : 'privacy_options_failed',
    );
    if (completer.isCompleted) return;
    completer.complete(
      formError == null && refreshed
          ? PrivacyChoiceResult.shown
          : PrivacyChoiceResult.failed,
    );
  }

  void _markAdsUnavailable(String errorCode) {
    state = AdsConsentState(
      status: AdsConsentStatus.ready,
      errorCode: errorCode,
    );
  }
}

final adsConsentControllerProvider =
    StateNotifierProvider<AdsConsentController, AdsConsentState>((ref) {
      return AdsConsentController();
    });
