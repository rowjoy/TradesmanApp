import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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

  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    state = state.copyWith(
      status: AdsConsentStatus.gathering,
      clearError: true,
    );
    final completer = Completer<void>();
    final parameters = ConsentRequestParameters();
    ConsentInformation.instance.requestConsentInfoUpdate(
      parameters,
      () {
        ConsentForm.loadAndShowConsentFormIfRequired((formError) {
          unawaited(
            _finishConsent(
              errorCode: formError == null ? null : 'consent_form_failed',
            ).whenComplete(() {
              if (!completer.isCompleted) completer.complete();
            }),
          );
        });
      },
      (_) {
        unawaited(
          _finishConsent(errorCode: 'consent_update_failed').whenComplete(() {
            if (!completer.isCompleted) completer.complete();
          }),
        );
      },
    );
    await completer.future;
  }

  Future<PrivacyChoiceResult> showPrivacyChoices() async {
    if (state.errorCode != null) {
      _initialization = null;
      await initialize();
      if (state.errorCode != null && !state.privacyOptionsRequired) {
        return PrivacyChoiceResult.failed;
      }
    }
    final requirement = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    if (requirement != PrivacyOptionsRequirementStatus.required) {
      await _finishConsent();
      return PrivacyChoiceResult.notRequired;
    }
    state = state.copyWith(
      status: AdsConsentStatus.gathering,
      clearError: true,
    );
    final completer = Completer<PrivacyChoiceResult>();
    ConsentForm.showPrivacyOptionsForm((formError) {
      unawaited(
        _finishConsent(
          errorCode: formError == null ? null : 'privacy_options_failed',
        ).whenComplete(() {
          if (!completer.isCompleted) {
            completer.complete(
              formError == null
                  ? PrivacyChoiceResult.shown
                  : PrivacyChoiceResult.failed,
            );
          }
        }),
      );
    });
    return completer.future;
  }

  Future<void> _finishConsent({String? errorCode}) async {
    final canRequest = await ConsentInformation.instance.canRequestAds();
    final requirement = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    var initialized = state.sdkInitialized;
    if (canRequest && !initialized) {
      await MobileAds.instance.initialize();
      initialized = true;
    }
    state = AdsConsentState(
      status: AdsConsentStatus.ready,
      canRequestAds: canRequest,
      privacyOptionsRequired:
          requirement == PrivacyOptionsRequirementStatus.required,
      sdkInitialized: initialized,
      errorCode: errorCode,
    );
  }
}

final adsConsentControllerProvider =
    StateNotifierProvider<AdsConsentController, AdsConsentState>((ref) {
      return AdsConsentController();
    });
