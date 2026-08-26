import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/core/security/encrypted_file_codec.dart';
import 'package:tradesman_manager/features/backup/infrastructure/backup_crypto.dart';

void main() {
  group('evidence encryption', () {
    test('round-trips and rejects a modified authentication tag', () async {
      final key = List<int>.generate(32, (index) => index);
      final clear = List<int>.generate(2048, (index) => index % 251);
      final encrypted = await EncryptedFileCodec.encrypt(clear, key);

      expect(EncryptedFileCodec.isEncrypted(encrypted), isTrue);
      expect(await EncryptedFileCodec.decrypt(encrypted, key), clear);

      encrypted[encrypted.length - 1] ^= 1;
      await expectLater(
        EncryptedFileCodec.decrypt(encrypted, key),
        throwsA(anything),
      );
    });
  });

  group('backup envelope', () {
    late Directory temporary;

    setUp(() async {
      temporary = await Directory.systemTemp.createTemp('workproof-crypto-test');
    });

    tearDown(() async {
      if (await temporary.exists()) await temporary.delete(recursive: true);
    });

    test('round-trips a streamed file and rejects the wrong password', () async {
      final source = File('${temporary.path}/source.bin');
      final encrypted = File('${temporary.path}/backup.workproof');
      final restored = File('${temporary.path}/restored.bin');
      final clear = List<int>.generate(180000, (index) => index % 239);
      await source.writeAsBytes(clear);

      await BackupCrypto.encryptFile(
        inputPath: source.path,
        outputPath: encrypted.path,
        password: 'correct horse battery staple',
      );
      await BackupCrypto.decryptFile(
        inputPath: encrypted.path,
        outputPath: restored.path,
        password: 'correct horse battery staple',
      );
      expect(await restored.readAsBytes(), clear);

      await expectLater(
        BackupCrypto.decryptFile(
          inputPath: encrypted.path,
          outputPath: '${temporary.path}/wrong.bin',
          password: 'incorrect password',
        ),
        throwsFormatException,
      );
    });
  });
}
