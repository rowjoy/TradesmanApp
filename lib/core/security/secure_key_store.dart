import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureKeyStore {
  SecureKeyStore(this._storage);

  static const _evidenceKeyName = 'workproof_evidence_key_v1';
  static const _recoverySecretName = 'workproof_recovery_secret_v1';
  final FlutterSecureStorage _storage;

  Future<List<int>> evidenceKey() async {
    final existing = await _storage.read(key: _evidenceKeyName);
    if (existing != null) return base64Url.decode(existing);
    final value = _randomBytes(32);
    await replaceEvidenceKey(value);
    return value;
  }

  Future<void> replaceEvidenceKey(List<int> value) {
    if (value.length != 32) {
      throw const FormatException('Evidence key must contain 32 bytes.');
    }
    return _storage.write(key: _evidenceKeyName, value: base64UrlEncode(value));
  }

  Future<String> recoverySecret() async {
    final existing = await _storage.read(key: _recoverySecretName);
    if (existing != null) return existing;
    final value = base64UrlEncode(_randomBytes(32));
    await _storage.write(key: _recoverySecretName, value: value);
    return value;
  }

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);

  static List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
}

final secureKeyStoreProvider = Provider<SecureKeyStore>((ref) {
  return SecureKeyStore(const FlutterSecureStorage());
});
