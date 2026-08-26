import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/performance/background_task_runner.dart';
import '../../../core/security/encrypted_file_codec.dart';
import '../../../core/security/secure_key_store.dart';
import '../domain/pay_protection_models.dart';

enum EvidencePickKind { photo, document, payslip }

class EvidenceFileTooLargeException implements Exception {
  const EvidenceFileTooLargeException();
}

class EvidenceFileService {
  const EvidenceFileService(this._keys);

  static const maxEvidenceBytes = 25 * 1024 * 1024;
  final SecureKeyStore _keys;

  Future<PreparedEvidenceFile?> pickAndPrepare(EvidencePickKind kind) async {
    final result = await FilePicker.pickFiles(
      type: switch (kind) {
        EvidencePickKind.photo => FileType.image,
        EvidencePickKind.document => FileType.custom,
        EvidencePickKind.payslip => FileType.custom,
      },
      allowedExtensions: switch (kind) {
        EvidencePickKind.photo => null,
        EvidencePickKind.document => const ['pdf', 'txt', 'csv', 'doc', 'docx'],
        EvidencePickKind.payslip => const ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      },
      allowMultiple: false,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final picked = result.files.single;
    final sourcePath = picked.path;
    if (sourcePath == null) {
      throw const FileSystemException('Selected file has no readable path.');
    }
    return prepare(File(sourcePath), originalName: picked.name);
  }

  Future<PreparedEvidenceFile> prepare(
    File source, {
    required String originalName,
  }) async {
    final size = await source.length();
    if (size > maxEvidenceBytes) {
      throw const EvidenceFileTooLargeException();
    }
    final root = await getApplicationDocumentsDirectory();
    final evidenceDirectory = Directory(
      p.join(root.path, 'workproof', 'evidence', 'local-workspace'),
    );
    final safeName = _safeFilename(originalName);
    final extension = p.extension(safeName).toLowerCase();
    final mimeType = _mimeType(extension);
    final keyBytes = await _keys.evidenceKey();
    final workerRequest = <String, Object?>{
      'sourcePath': source.path,
      'directoryPath': evidenceDirectory.path,
      'safeName': safeName,
      'extension': extension,
      'isImage': _isImage(extension),
      'keyBytes': keyBytes,
    };
    final prepared = await BackgroundTaskRunner.run(
      () => _prepareEvidenceInBackground(workerRequest),
      debugName: 'workproof-evidence-prepare',
    );

    return PreparedEvidenceFile(
      originalFilename: originalName,
      mimeType: mimeType,
      sizeBytes: size,
      sha256: prepared['digest']! as String,
      localPath: prepared['originalPath']! as String,
      sharedCopyPath: prepared['sharedPath']! as String,
      sharedCopySha256: prepared['sharedDigest']! as String,
      metadataStripped: prepared['metadataStripped']! as bool,
      originalRetained: true,
    );
  }

  Future<void> discard(PreparedEvidenceFile file) async {
    for (final path in {file.localPath, file.sharedCopyPath}) {
      if (path == null || path.isEmpty) continue;
      final candidate = File(path);
      if (await candidate.exists()) {
        try {
          await candidate.delete();
        } on FileSystemException {
          // A later app-storage cleanup can safely retry this orphan.
        }
      }
    }
  }

  bool _isImage(String extension) => const {
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
    '.gif',
    '.heic',
  }.contains(extension);

  String _mimeType(String extension) => switch (extension) {
    '.jpg' || '.jpeg' => 'image/jpeg',
    '.png' => 'image/png',
    '.webp' => 'image/webp',
    '.gif' => 'image/gif',
    '.heic' => 'image/heic',
    '.pdf' => 'application/pdf',
    '.txt' => 'text/plain',
    '.csv' => 'text/csv',
    '.doc' => 'application/msword',
    '.docx' =>
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    _ => 'application/octet-stream',
  };

  String _safeFilename(String source) {
    final base = p.basename(source).replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return base.isEmpty ? 'evidence.bin' : base;
  }
}

final evidenceFileServiceProvider = Provider(
  (ref) => EvidenceFileService(ref.watch(secureKeyStoreProvider)),
);

/// Pure file/image work executed in a worker isolate. Keeping decode, resize,
/// JPEG encoding and SHA-256 off the UI isolate prevents picker completion from
/// freezing animations or scrolling for large photos.
Future<Map<String, Object?>> _prepareEvidenceInBackground(
  Map<String, Object?> request,
) async {
  final source = File(request['sourcePath']! as String);
  final directory = Directory(request['directoryPath']! as String);
  final safeName = request['safeName']! as String;
  final extension = request['extension']! as String;
  final isImage = request['isImage']! as bool;
  final keyBytes = (request['keyBytes']! as List).cast<int>();
  await directory.create(recursive: true);

  final bytes = await source.readAsBytes();
  final digest = sha256.convert(bytes).toString();
  final prefix = digest.substring(0, 12);
  final unique = DateTime.now().microsecondsSinceEpoch;
  final originalPath = p.join(
    directory.path,
    '${prefix}_${unique}_$safeName.wpe',
  );
  final created = <String>[];
  try {
    final encryptedOriginal = await EncryptedFileCodec.encrypt(bytes, keyBytes);
    await File(originalPath).writeAsBytes(encryptedOriginal, flush: true);
    created.add(originalPath);

    String? sharedPath;
    String? sharedDigest;
    var metadataStripped = false;
    if (isImage) {
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        final resized = decoded.width > 1800
            ? img.copyResize(decoded, width: 1800)
            : decoded;
        final privacyBytes = img.encodeJpg(resized, quality: 84);
        sharedPath = p.join(
          directory.path,
          '${prefix}_${unique}_share.jpg.wpe',
        );
        final encryptedShare = await EncryptedFileCodec.encrypt(
          privacyBytes,
          keyBytes,
        );
        await File(sharedPath).writeAsBytes(encryptedShare, flush: true);
        created.add(sharedPath);
        sharedDigest = sha256.convert(privacyBytes).toString();
        metadataStripped = true;
      }
    }

    sharedPath ??= p.join(
      directory.path,
      '${prefix}_${unique}_share${extension.isEmpty ? '.bin' : extension}.wpe',
    );
    if (!await File(sharedPath).exists()) {
      final encryptedShare = await EncryptedFileCodec.encrypt(bytes, keyBytes);
      await File(sharedPath).writeAsBytes(encryptedShare, flush: true);
      created.add(sharedPath);
      sharedDigest = digest;
    }
    return {
      'digest': digest,
      'originalPath': originalPath,
      'sharedPath': sharedPath,
      'sharedDigest': sharedDigest ?? digest,
      'metadataStripped': metadataStripped,
    };
  } catch (_) {
    for (final path in created) {
      try {
        await File(path).delete();
      } on FileSystemException {
        // Best-effort rollback; app-storage maintenance can retry later.
      }
    }
    rethrow;
  }
}
