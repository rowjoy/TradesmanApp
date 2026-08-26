import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/performance/background_task_runner.dart';
import '../../../core/security/secure_key_store.dart';

class AppLockSettings {
  const AppLockSettings({
    required this.enabled,
    required this.biometricsEnabled,
  });

  final bool enabled;
  final bool biometricsEnabled;
}

class AppLockRepository {
  AppLockRepository(this._keys);

  static const _pinSalt = 'app_lock_pin_salt_v1';
  static const _pinHash = 'app_lock_pin_hash_v1';
  static const _biometrics = 'app_lock_biometrics_v1';
  static const _iterations = 310000;
  final SecureKeyStore _keys;

  Future<AppLockSettings> load() async {
    final hash = await _keys.read(_pinHash);
    return AppLockSettings(
      enabled: hash != null,
      biometricsEnabled: hash != null && await _keys.read(_biometrics) == '1',
    );
  }

  Future<void> setPin(String pin) async {
    _validatePin(pin);
    final salt = _randomBytes(16);
    final hash = await _derive(pin, salt);
    await _keys.write(_pinSalt, base64UrlEncode(salt));
    await _keys.write(_pinHash, base64UrlEncode(hash));
  }

  Future<bool> verifyPin(String pin) async {
    final saltValue = await _keys.read(_pinSalt);
    final hashValue = await _keys.read(_pinHash);
    if (saltValue == null || hashValue == null) return false;
    final actual = await _derive(pin, base64Url.decode(saltValue));
    return _constantTimeEquals(actual, base64Url.decode(hashValue));
  }

  Future<void> setBiometricsEnabled(bool enabled) =>
      _keys.write(_biometrics, enabled ? '1' : '0');

  Future<void> disable() async {
    await _keys.delete(_pinSalt);
    await _keys.delete(_pinHash);
    await _keys.delete(_biometrics);
  }

  Future<List<int>> _derive(String pin, List<int> salt) async {
    return BackgroundTaskRunner.run(
      () => _derivePinWorker(pin, salt, _iterations),
      debugName: 'workproof-pin-derive',
    );
  }

  static void _validatePin(String pin) {
    if (!RegExp(r'^\d{4,8}$').hasMatch(pin)) {
      throw const FormatException('PIN must contain 4 to 8 digits.');
    }
  }

  static bool _constantTimeEquals(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    var difference = 0;
    for (var index = 0; index < left.length; index++) {
      difference |= left[index] ^ right[index];
    }
    return difference == 0;
  }

  static List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
}

final appLockRepositoryProvider = Provider<AppLockRepository>((ref) {
  return AppLockRepository(ref.watch(secureKeyStoreProvider));
});

Future<List<int>> _derivePinWorker(
  String pin,
  List<int> salt,
  int iterations,
) async {
  final algorithm = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: iterations,
    bits: 256,
  );
  final key = await algorithm.deriveKeyFromPassword(
    password: pin,
    nonce: salt,
  );
  return key.extractBytes();
}
