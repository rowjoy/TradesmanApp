import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_helper.dart';
import '../performance/background_task_runner.dart';
import 'encrypted_file_codec.dart';
import 'secure_key_store.dart';

/// Resumable migration for evidence created before the WPE1 envelope existed.
///
/// Files are authenticated and replaced before the database marker is updated.
/// A process interruption is safe: the next pass recognizes an already-
/// encrypted file and completes the marker update.
class EvidenceEncryptionMigration {
  EvidenceEncryptionMigration(this._keys);

  final SecureKeyStore _keys;
  Future<void>? _running;

  Future<void> run() => _running ??= _migrate().whenComplete(() {
    _running = null;
  });

  Future<void> _migrate() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final columns = (await db.rawQuery(
        'PRAGMA table_info(attachments)',
      )).map((row) => row['name']).whereType<String>().toSet();
      if (!columns.contains('encryption_version')) return;
      final hasSharedCopy = columns.contains('shared_copy_path');
      final rows = await db.query(
        'attachments',
        columns: [
          'id',
          'local_path',
          'sha256',
          if (hasSharedCopy) 'shared_copy_path',
          if (hasSharedCopy) 'shared_copy_sha256',
        ],
        where: 'encryption_version = 0 AND deleted_at IS NULL',
      );
      if (rows.isEmpty) return;
      final key = await _keys.evidenceKey();
      final migrated = await BackgroundTaskRunner.run(
        () => _encryptLegacyEvidenceWorker(rows, key),
        debugName: 'workproof-encrypt-legacy-evidence',
      );
      if (migrated.isEmpty) return;
      await db.transaction((transaction) async {
        for (final id in migrated) {
          await transaction.update(
            'attachments',
            {'encryption_version': 1},
            where: 'id = ?',
            whereArgs: [id],
          );
        }
      });
    } catch (_) {
      // Resumable hardening must not block the user's offline workspace.
    }
  }
}

final evidenceEncryptionMigrationProvider = Provider(
  (ref) => EvidenceEncryptionMigration(ref.watch(secureKeyStoreProvider)),
);

Future<List<String>> _encryptLegacyEvidenceWorker(
  List<Map<String, Object?>> rows,
  List<int> key,
) async {
  final migrated = <String>[];
  for (final row in rows) {
    final id = row['id'];
    if (id is! String) continue;
    try {
      final files = <({String path, String digest})>[];
      final localPath = row['local_path'];
      final localDigest = row['sha256'];
      if (localPath is String && localDigest is String) {
        files.add((path: localPath, digest: localDigest));
      }
      final sharedPath = row['shared_copy_path'];
      final sharedDigest = row['shared_copy_sha256'];
      if (sharedPath is String && sharedDigest is String) {
        files.add((path: sharedPath, digest: sharedDigest));
      }
      if (files.isEmpty) continue;
      var valid = true;
      for (final entry in files) {
        final file = File(entry.path);
        if (!await file.exists()) {
          valid = false;
          break;
        }
        final stored = await file.readAsBytes();
        final clear = EncryptedFileCodec.isEncrypted(stored)
            ? await EncryptedFileCodec.decrypt(stored, key)
            : stored;
        if (sha256.convert(clear).toString() != entry.digest) {
          valid = false;
          break;
        }
        if (EncryptedFileCodec.isEncrypted(stored)) continue;
        final encrypted = await EncryptedFileCodec.encrypt(clear, key);
        final temporary = File('${file.path}.encrypting');
        try {
          await temporary.writeAsBytes(encrypted, flush: true);
          final verified = await EncryptedFileCodec.decrypt(
            await temporary.readAsBytes(),
            key,
          );
          if (sha256.convert(verified).toString() != entry.digest) {
            throw const FormatException('Evidence encryption check failed.');
          }
          await temporary.rename(file.path);
        } finally {
          if (await temporary.exists()) await temporary.delete();
        }
      }
      if (valid) migrated.add(id);
    } catch (_) {
      // Leave this attachment pending and continue hardening the remaining rows.
    }
  }
  return migrated;
}
