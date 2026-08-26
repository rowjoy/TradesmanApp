import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../core/performance/background_task_runner.dart';
import '../../../core/security/encrypted_file_codec.dart';
import '../../../core/security/secure_key_store.dart';
import '../domain/pay_protection_models.dart';

class MaterializedEvidence {
  const MaterializedEvidence({
    required this.sourcePath,
    required this.archivePath,
  });

  final String sourcePath;
  final String archivePath;
}

class EvidenceProtectionService {
  const EvidenceProtectionService(this._keys);

  final SecureKeyStore _keys;

  Future<List<MaterializedEvidence>> materializeForExport({
    required List<({EvidenceAttachment attachment, String archivePath})>
    entries,
    required Directory destination,
  }) async {
    if (entries.isEmpty) return const [];
    final keyBytes = await _keys.evidenceKey();
    final request = <String, Object?>{
      'destination': destination.path,
      'keyBytes': keyBytes,
      'entries': [
        for (final entry in entries)
          <String, Object?>{
            'sourcePath':
                entry.attachment.sharedCopyPath ?? entry.attachment.localPath,
            'expectedSha256':
                entry.attachment.sharedCopySha256 ?? entry.attachment.sha256,
            'originalFilename': entry.attachment.originalFilename,
            'archivePath': entry.archivePath,
          },
      ],
    };
    final values = await BackgroundTaskRunner.run(
      () => _materializeEvidenceWorker(request),
      debugName: 'workproof-evidence-decrypt-export',
    );
    return [
      for (final value in values)
        MaterializedEvidence(
          sourcePath: value['sourcePath']! as String,
          archivePath: value['archivePath']! as String,
        ),
    ];
  }

  Future<void> cleanup(Directory directory) async {
    if (!await directory.exists()) return;
    try {
      await directory.delete(recursive: true);
    } on FileSystemException {
      // App cache maintenance can retry an orphaned export staging directory.
    }
  }
}

final evidenceProtectionServiceProvider = Provider<EvidenceProtectionService>(
  (ref) => EvidenceProtectionService(ref.watch(secureKeyStoreProvider)),
);

Future<List<Map<String, Object?>>> _materializeEvidenceWorker(
  Map<String, Object?> request,
) async {
  final destination = Directory(request['destination']! as String);
  final keyBytes = (request['keyBytes']! as List).cast<int>();
  final entries = (request['entries']! as List).cast<Map>();
  await destination.create(recursive: true);
  final output = <Map<String, Object?>>[];
  for (var index = 0; index < entries.length; index++) {
    final entry = entries[index].cast<String, Object?>();
    final source = File(entry['sourcePath']! as String);
    if (!await source.exists()) {
      throw FileSystemException('Evidence file is missing.', source.path);
    }
    final storedBytes = await source.readAsBytes();
    final clearBytes = EncryptedFileCodec.isEncrypted(storedBytes)
        ? await EncryptedFileCodec.decrypt(storedBytes, keyBytes)
        : storedBytes;
    final actualDigest = sha256.convert(clearBytes).toString();
    if (actualDigest != entry['expectedSha256']) {
      throw const FormatException('Evidence integrity check failed.');
    }
    final originalName = entry['originalFilename']! as String;
    final safeBase = p
        .basenameWithoutExtension(originalName)
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final extension = p.extension(originalName);
    final outputPath = p.join(
      destination.path,
      '${index + 1}_${safeBase.isEmpty ? 'evidence' : safeBase}$extension',
    );
    await File(outputPath).writeAsBytes(clearBytes, flush: true);
    output.add({
      'sourcePath': outputPath,
      'archivePath': entry['archivePath']! as String,
    });
  }
  return output;
}
