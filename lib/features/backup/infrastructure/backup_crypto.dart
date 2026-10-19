import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Streaming authenticated backup envelope.
///
/// Each 1 MiB chunk has its own random nonce and AES-GCM tag. This keeps peak
/// memory bounded for evidence-heavy workspaces and detects wrong passwords or
/// any byte-level corruption before restore.
abstract final class BackupCrypto {
  static const magic = <int>[0x57, 0x50, 0x52, 0x42, 0x4B, 0x30, 0x30, 0x32];
  static const _saltLength = 16;
  static const _nonceLength = 12;
  static const _macLength = 16;
  static const _iterations = 310000;
  static const _chunkSize = 1024 * 1024;

  static Future<void> encryptFile({
    required String inputPath,
    required String outputPath,
    required String password,
  }) async {
    final salt = _randomBytes(_saltLength);
    final key = await _derive(password, salt, _iterations);
    final output = await File(outputPath).open(mode: FileMode.write);
    try {
      await output.writeFrom(magic);
      await output.writeFrom(salt);
      await output.writeFrom(_u32(_iterations));
      var index = 0;
      await for (final chunk in File(inputPath).openRead()) {
        if (chunk.isEmpty) continue;
        final nonce = _randomBytes(_nonceLength);
        final box = await AesGcm.with256bits().encrypt(
          chunk,
          secretKey: key,
          nonce: nonce,
          aad: _chunkAad(index),
        );
        await output.writeFrom(_u32(box.cipherText.length));
        await output.writeFrom(nonce);
        await output.writeFrom(box.cipherText);
        await output.writeFrom(box.mac.bytes);
        index++;
      }
      await output.writeFrom(_u32(0));
      await output.flush();
    } finally {
      await output.close();
    }
  }

  static Future<void> decryptFile({
    required String inputPath,
    required String outputPath,
    required String password,
  }) async {
    final input = await File(inputPath).open();
    final output = await File(outputPath).open(mode: FileMode.write);
    try {
      final fileMagic = await _readExact(input, magic.length);
      if (!_equals(fileMagic, magic)) {
        throw const FormatException('Not a WorkProof backup.');
      }
      final salt = await _readExact(input, _saltLength);
      final iterations = _readU32(await _readExact(input, 4));
      if (iterations < 100000 || iterations > 1000000) {
        throw const FormatException('Unsupported backup key parameters.');
      }
      final key = await _derive(password, salt, iterations);
      var index = 0;
      while (true) {
        final length = _readU32(await _readExact(input, 4));
        if (length == 0) break;
        if (length > _chunkSize * 2) {
          throw const FormatException('Invalid backup chunk size.');
        }
        final nonce = await _readExact(input, _nonceLength);
        final cipherText = await _readExact(input, length);
        final mac = await _readExact(input, _macLength);
        final clear = await AesGcm.with256bits().decrypt(
          SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
          secretKey: key,
          aad: _chunkAad(index),
        );
        await output.writeFrom(clear);
        index++;
      }
      if (await input.position() != await input.length()) {
        throw const FormatException('Unexpected data after backup envelope.');
      }
      await output.flush();
    } on SecretBoxAuthenticationError {
      throw const FormatException('Wrong password or damaged backup.');
    } finally {
      await input.close();
      await output.close();
    }
  }

  static Future<SecretKey> _derive(
    String password,
    List<int> salt,
    int iterations,
  ) {
    return Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    ).deriveKeyFromPassword(password: password, nonce: salt);
  }

  static List<int> _chunkAad(int index) => [...magic, ..._u64(index)];

  static Uint8List _u32(int value) =>
      (ByteData(4)..setUint32(0, value, Endian.big)).buffer.asUint8List();

  static int _readU32(List<int> bytes) =>
      ByteData.sublistView(Uint8List.fromList(bytes)).getUint32(0, Endian.big);

  static Uint8List _u64(int value) =>
      (ByteData(8)..setUint64(0, value, Endian.big)).buffer.asUint8List();

  static Future<Uint8List> _readExact(RandomAccessFile file, int length) async {
    final output = BytesBuilder(copy: false);
    while (output.length < length) {
      final bytes = await file.read(length - output.length);
      if (bytes.isEmpty) {
        throw const FormatException('Truncated WorkProof backup.');
      }
      output.add(bytes);
    }
    return output.takeBytes();
  }

  static bool _equals(List<int> left, List<int> right) {
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
