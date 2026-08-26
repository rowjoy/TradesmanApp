import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../data/app_lock_repository.dart';

class AppLockState {
  const AppLockState({
    this.initializing = true,
    this.enabled = false,
    this.locked = false,
    this.biometricsEnabled = false,
    this.biometricsAvailable = false,
    this.busy = false,
    this.failedAttempts = 0,
    this.cooldownUntil,
    this.errorCode,
  });

  final bool initializing;
  final bool enabled;
  final bool locked;
  final bool biometricsEnabled;
  final bool biometricsAvailable;
  final bool busy;
  final int failedAttempts;
  final DateTime? cooldownUntil;
  final String? errorCode;

  AppLockState copyWith({
    bool? initializing,
    bool? enabled,
    bool? locked,
    bool? biometricsEnabled,
    bool? biometricsAvailable,
    bool? busy,
    int? failedAttempts,
    DateTime? cooldownUntil,
    bool clearCooldown = false,
    String? errorCode,
    bool clearError = false,
  }) => AppLockState(
    initializing: initializing ?? this.initializing,
    enabled: enabled ?? this.enabled,
    locked: locked ?? this.locked,
    biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
    biometricsAvailable: biometricsAvailable ?? this.biometricsAvailable,
    busy: busy ?? this.busy,
    failedAttempts: failedAttempts ?? this.failedAttempts,
    cooldownUntil: clearCooldown
        ? null
        : cooldownUntil ?? this.cooldownUntil,
    errorCode: clearError ? null : errorCode ?? this.errorCode,
  );
}

class AppLockController extends StateNotifier<AppLockState> {
  AppLockController(this._repository, this._auth)
    : super(const AppLockState());

  final AppLockRepository _repository;
  final LocalAuthentication _auth;
  Future<void>? _initializing;

  Future<void> initialize() => _initializing ??= _initialize();

  Future<void> _initialize() async {
    try {
      final settings = await _repository.load();
      final available = await _biometricsAvailable();
      state = state.copyWith(
        initializing: false,
        enabled: settings.enabled,
        locked: settings.enabled,
        biometricsEnabled: settings.biometricsEnabled && available,
        biometricsAvailable: available,
        clearError: true,
      );
    } catch (_) {
      // A secure-storage failure must not create an unrecoverable lockout.
      state = state.copyWith(
        initializing: false,
        enabled: false,
        locked: false,
        errorCode: 'secure_storage_unavailable',
      );
    }
  }

  Future<void> setPin(String pin) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      await _repository.setPin(pin);
      state = state.copyWith(
        enabled: true,
        locked: false,
        busy: false,
        failedAttempts: 0,
        clearCooldown: true,
      );
    } catch (_) {
      state = state.copyWith(busy: false, errorCode: 'pin_save_failed');
      rethrow;
    }
  }

  Future<bool> verifyPin(String pin) async {
    final cooldown = state.cooldownUntil;
    if (cooldown != null) {
      if (DateTime.now().isBefore(cooldown)) {
        state = state.copyWith(errorCode: 'cooldown');
        return false;
      }
      state = state.copyWith(failedAttempts: 0, clearCooldown: true);
    }
    state = state.copyWith(busy: true, clearError: true);
    try {
      final valid = await _repository.verifyPin(pin);
      if (valid) {
        state = state.copyWith(
          locked: false,
          busy: false,
          failedAttempts: 0,
          clearCooldown: true,
          clearError: true,
        );
        return true;
      }
      final attempts = state.failedAttempts + 1;
      state = state.copyWith(
        busy: false,
        failedAttempts: attempts,
        cooldownUntil: attempts >= 5
            ? DateTime.now().add(const Duration(seconds: 30))
            : null,
        errorCode: attempts >= 5 ? 'cooldown' : 'wrong_pin',
      );
      return false;
    } catch (_) {
      state = state.copyWith(busy: false, errorCode: 'secure_storage_error');
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics(String reason) async {
    if (!state.biometricsAvailable) return false;
    state = state.copyWith(busy: true, clearError: true);
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      state = state.copyWith(
        locked: authenticated ? false : state.locked,
        busy: false,
        failedAttempts: authenticated ? 0 : state.failedAttempts,
        clearError: authenticated,
      );
      return authenticated;
    } catch (_) {
      state = state.copyWith(busy: false, errorCode: 'biometric_failed');
      return false;
    }
  }

  Future<void> setBiometricsEnabled(bool enabled, String reason) async {
    if (enabled) {
      final authenticated = await authenticateWithBiometrics(reason);
      if (!authenticated) throw const FormatException('Biometric check failed.');
    }
    await _repository.setBiometricsEnabled(enabled);
    state = state.copyWith(biometricsEnabled: enabled, clearError: true);
  }

  Future<void> disable() async {
    await _repository.disable();
    state = state.copyWith(
      enabled: false,
      locked: false,
      biometricsEnabled: false,
      failedAttempts: 0,
      clearCooldown: true,
      clearError: true,
    );
  }

  void lock() {
    if (!state.enabled || state.locked) return;
    state = state.copyWith(locked: true, clearError: true);
  }

  Future<bool> _biometricsAvailable() async {
    try {
      return await _auth.canCheckBiometrics &&
          (await _auth.getAvailableBiometrics()).isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

final localAuthenticationProvider = Provider<LocalAuthentication>((ref) {
  final authentication = LocalAuthentication();
  ref.onDispose(() {
    authentication.stopAuthentication();
  });
  return authentication;
});

final appLockControllerProvider =
    StateNotifierProvider<AppLockController, AppLockState>((ref) {
      return AppLockController(
        ref.watch(appLockRepositoryProvider),
        ref.watch(localAuthenticationProvider),
      );
    });
