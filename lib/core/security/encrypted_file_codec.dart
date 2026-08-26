import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Authenticated AES-256-GCM envelope used for evidence stored on device.
///
/// Layout: `WPE1 | 12-byte nonce | ciphertext | 16-byte authentication tag`.
abstract final class EncryptedFileCodec {
  static const _magic = <int>[0x57, 0x50, 0x45, 0x31]; // WPE1
  static const _nonceLength = 12;
  static const _macLength = 16;
  static const _aad = <int>[0x57, 0x6F, 0x72, 0x6B, 0x50, 0x72, 0x6F, 0x6F, 0x66];

  static bool isEncrypted(List<int> bytes) =>
      bytes.length >= _magic.length + _nonceLength + _macLength &&
      _startsWith(bytes, _magic);

  static Future<Uint8List> encrypt(
    List<int> plainBytes,
    List<int> keyBytes,
  ) async {
    _validateKey(keyBytes);
    final nonce = _randomBytes(_nonceLength);
    final box = await AesGcm.with256bits().encrypt(
      plainBytes,
      secretKey: SecretKey(keyBytes),
      nonce: nonce,
      aad: _aad,
    );
    return Uint8List.fromList([
      ..._magic,
      ...nonce,
      ...box.cipherText,
      ...box.mac.bytes,
    ]);
  }

  static Future<Uint8List> decrypt(
    List<int> encryptedBytes,
    List<int> keyBytes,
  ) async {
    _validateKey(keyBytes);
    if (!isEncrypted(encryptedBytes)) {
      throw const FormatException('Unsupported encrypted evidence format.');
    }
    final nonceStart = _magic.length;
    final cipherStart = nonceStart + _nonceLength;
    final macStart = encryptedBytes.length - _macLength;
    final clear = await AesGcm.with256bits().decrypt(
      SecretBox(
        encryptedBytes.sublist(cipherStart, macStart),
        nonce: encryptedBytes.sublist(nonceStart, cipherStart),
        mac: Mac(encryptedBytes.sublist(macStart)),
      ),
      secretKey: SecretKey(keyBytes),
      aad: _aad,
    );
    return Uint8List.fromList(clear);
  }

  static void _validateKey(List<int> keyBytes) {
    if (keyBytes.length != 32) {
      throw const FormatException('AES-256 key must contain 32 bytes.');
    }
  }

  static bool _startsWith(List<int> value, List<int> prefix) {
    for (var index = 0; index < prefix.length; index++) {
      if (value[index] != prefix[index]) return false;
    }
    return true;
  }

  static List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
}
