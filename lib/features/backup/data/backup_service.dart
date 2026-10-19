import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/performance/background_task_runner.dart';
import '../../../core/security/encrypted_file_codec.dart';
import '../../../core/security/secure_key_store.dart';
import '../../../core/time/app_clock.dart';
import '../domain/backup_models.dart';
import '../infrastructure/backup_crypto.dart';

class BackupService {
  BackupService({
    required SecureKeyStore keys,
    required AppClock clock,
    required IdGenerator ids,
  }) : _keys = keys,
       _clock = clock,
       _ids = ids;

  static const workspaceId = 'local-workspace';
  static const manifestVersion = 2;
  static const minimumPasswordLength = 10;

  final SecureKeyStore _keys;
  final AppClock _clock;
  final IdGenerator _ids;
  final DatabaseHelper _database = DatabaseHelper.instance;

  Future<BackupArtifact> createManualBackup(String password) async {
    _validatePassword(password);
    final documents = await getApplicationDocumentsDirectory();
    final backupDirectory = Directory(
      p.join(documents.path, 'workproof', 'backups'),
    );
    await backupDirectory.create(recursive: true);
    final createdAt = _clock.nowUtc();
    final stamp = _safeStamp(createdAt);
    final output = File(
      p.join(backupDirectory.path, 'WorkProof-$stamp.workproof'),
    );
    return _createBackup(
      password: password,
      output: output,
      type: 'manual',
      createdAt: createdAt,
      recordHistory: true,
    );
  }

  Future<File> createRecoverySnapshot({String reason = 'automatic'}) async {
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory(
      p.join(documents.path, 'workproof', 'recovery'),
    );
    await directory.create(recursive: true);
    final createdAt = _clock.nowUtc();
    final output = File(
      p.join(directory.path, 'Recovery-${_safeStamp(createdAt)}.workproof'),
    );
    await _createBackup(
      password: await _keys.recoverySecret(),
      output: output,
      type: 'recovery:$reason',
      createdAt: createdAt,
      recordHistory: false,
    );
    await _rotateRecoverySnapshots(directory, keep: 3);
    return output;
  }

  Future<BackupArtifact> _createBackup({
    required String password,
    required File output,
    required String type,
    required DateTime createdAt,
    required bool recordHistory,
  }) async {
    final temporary = await getTemporaryDirectory();
    final staging = await Directory(
      p.join(temporary.path, 'workproof-backup-${_ids.next()}'),
    ).create(recursive: true);
    final startedAt = _clock.nowUtc();
    final historyId = _ids.next();
    try {
      final documents = await getApplicationDocumentsDirectory();
      final databaseFile = await _database.createConsistentSnapshot(
        File(p.join(staging.path, 'database', 'workproof.db')),
      );
      final evidenceSource = Directory(
        p.join(documents.path, 'workproof', 'evidence'),
      );
      final packageDirectory = await Directory(
        p.join(staging.path, 'package'),
      ).create(recursive: true);
      final packagedDatabase = File(
        p.join(packageDirectory.path, 'database', 'workproof.db'),
      );
      await packagedDatabase.parent.create(recursive: true);
      await databaseFile.copy(packagedDatabase.path);

      final packagedEvidence = Directory(
        p.join(packageDirectory.path, 'evidence'),
      );
      if (await evidenceSource.exists()) {
        await _copyDirectory(evidenceSource, packagedEvidence);
      } else {
        await packagedEvidence.create(recursive: true);
      }

      final keyFile = File(
        p.join(packageDirectory.path, 'security', 'evidence_key.bin'),
      );
      await keyFile.parent.create(recursive: true);
      await keyFile.writeAsBytes(await _keys.evidenceKey(), flush: true);

      final counts = await _recordCounts();
      final entries = await BackgroundTaskRunner.run(
        () => _buildManifestEntriesWorker(packageDirectory.path),
        debugName: 'workproof-backup-hash-files',
      );
      final evidenceCount = entries
          .where(
            (entry) =>
                (entry['archivePath']! as String).startsWith('evidence/'),
          )
          .length;
      final manifest = <String, Object?>{
        'manifestVersion': manifestVersion,
        'schemaVersion': DatabaseHelper.schemaVersion,
        'createdAtUtc': createdAt.toIso8601String(),
        'workspaceId': workspaceId,
        'backupType': type,
        'sourceDocumentsPath': documents.path,
        'recordCounts': counts,
        'entries': entries,
      };
      await File(p.join(packageDirectory.path, 'manifest.json')).writeAsString(
        const JsonEncoder.withIndent('  ').convert(manifest),
        flush: true,
      );

      final zip = File(p.join(staging.path, 'payload.zip'));
      await BackgroundTaskRunner.run(
        () => _createArchiveWorker(packageDirectory.path, zip.path),
        debugName: 'workproof-backup-archive',
      );
      await output.parent.create(recursive: true);
      await BackgroundTaskRunner.run(
        () => BackupCrypto.encryptFile(
          inputPath: zip.path,
          outputPath: output.path,
          password: password,
        ),
        debugName: 'workproof-backup-encrypt',
      );
      final digest = await BackgroundTaskRunner.run(
        () => _sha256PathWorker(output.path),
        debugName: 'workproof-backup-hash-envelope',
      );
      final size = await output.length();
      final totalRecords = counts.values.fold<int>(
        0,
        (sum, value) => sum + value,
      );
      if (recordHistory) {
        await _writeHistory(
          id: historyId,
          type: type,
          status: 'completed',
          destination: p.basename(output.path),
          startedAt: startedAt,
          completedAt: _clock.nowUtc(),
          counts: counts,
          digest: digest,
          size: size,
        );
      }
      return BackupArtifact(
        file: output,
        createdAtUtc: createdAt,
        sizeBytes: size,
        sha256: digest,
        recordCount: totalRecords,
        evidenceFileCount: evidenceCount,
      );
    } catch (_) {
      if (recordHistory) {
        await _writeHistory(
          id: historyId,
          type: type,
          status: 'failed',
          destination: p.basename(output.path),
          startedAt: startedAt,
          completedAt: _clock.nowUtc(),
          errorCode: 'backup_failed',
        );
      }
      if (await output.exists()) await output.delete();
      rethrow;
    } finally {
      if (await staging.exists()) await staging.delete(recursive: true);
    }
  }

  Future<PreparedRestore> prepareRestore({
    required String backupPath,
    required String password,
  }) async {
    _validatePassword(password);
    final source = File(backupPath);
    if (!await source.exists()) {
      throw FileSystemException('Backup file does not exist.', backupPath);
    }
    if (await source.length() > 6 * 1024 * 1024 * 1024) {
      throw const FormatException('Backup file is too large.');
    }
    final temporary = await getTemporaryDirectory();
    final staging = await Directory(
      p.join(temporary.path, 'workproof-restore-${_ids.next()}'),
    ).create(recursive: true);
    try {
      final zip = File(p.join(staging.path, 'payload.zip'));
      await BackgroundTaskRunner.run(
        () => BackupCrypto.decryptFile(
          inputPath: source.path,
          outputPath: zip.path,
          password: password,
        ),
        debugName: 'workproof-backup-decrypt',
      );
      final extracted = await Directory(
        p.join(staging.path, 'extracted'),
      ).create(recursive: true);
      await BackgroundTaskRunner.run(
        () => _extractArchiveWorker(zip.path, extracted.path),
        debugName: 'workproof-backup-extract',
      );
      final manifestFile = File(p.join(extracted.path, 'manifest.json'));
      if (!await manifestFile.exists()) {
        throw const FormatException('Backup manifest is missing.');
      }
      final manifest = jsonDecode(await manifestFile.readAsString());
      if (manifest is! Map<String, dynamic>) {
        throw const FormatException('Backup manifest is invalid.');
      }
      final version = manifest['manifestVersion'];
      final schema = manifest['schemaVersion'];
      if (version is! int || version < 1 || version > manifestVersion) {
        throw const FormatException('Unsupported backup manifest version.');
      }
      if (schema is! int ||
          schema < 1 ||
          schema > DatabaseHelper.schemaVersion) {
        throw const FormatException('Unsupported backup database version.');
      }
      final rawEntries = manifest['entries'];
      if (rawEntries is! List || rawEntries.isEmpty) {
        throw const FormatException('Backup file list is missing.');
      }
      final evidenceCount = await BackgroundTaskRunner.run(
        () => _verifyManifestEntriesWorker(extracted.path, rawEntries),
        debugName: 'workproof-backup-verify-files',
      );
      final databaseFile = File(
        p.join(extracted.path, 'database', 'workproof.db'),
      );
      final keyFile = File(
        p.join(extracted.path, 'security', 'evidence_key.bin'),
      );
      if (!await databaseFile.exists() ||
          !await keyFile.exists() ||
          await keyFile.length() != 32) {
        throw const FormatException('Backup security data is incomplete.');
      }
      await _validateStagedDatabase(databaseFile, schema);
      final counts =
          (manifest['recordCounts'] as Map?)?.values.whereType<num>().fold<int>(
            0,
            (sum, value) => sum + value.toInt(),
          ) ??
          0;
      final createdAt = DateTime.tryParse('${manifest['createdAtUtc']}');
      if (createdAt == null) {
        throw const FormatException('Backup creation date is invalid.');
      }
      return PreparedRestore(
        stagingDirectory: staging,
        preview: BackupPreview(
          createdAtUtc: createdAt.toUtc(),
          schemaVersion: schema,
          recordCount: counts,
          evidenceFileCount: evidenceCount,
          sourceDocumentsPath: '${manifest['sourceDocumentsPath'] ?? ''}',
        ),
        databaseFile: databaseFile,
        evidenceDirectory: Directory(p.join(extracted.path, 'evidence')),
        evidenceKeyFile: keyFile,
      );
    } catch (_) {
      if (await staging.exists()) await staging.delete(recursive: true);
      rethrow;
    }
  }

  Future<PreparedRestore?> prepareLatestRecovery() async {
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory(
      p.join(documents.path, 'workproof', 'recovery'),
    );
    if (!await directory.exists()) return null;
    final files = await directory
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.workproof'))
        .cast<File>()
        .toList();
    if (files.isEmpty) return null;
    files.sort((left, right) => right.path.compareTo(left.path));
    return prepareRestore(
      backupPath: files.first.path,
      password: await _keys.recoverySecret(),
    );
  }

  Future<void> restore(PreparedRestore prepared, RestoreMode mode) async {
    await createRecoverySnapshot(reason: 'pre-import');
    final temporary = await getTemporaryDirectory();
    final rollback = await Directory(
      p.join(temporary.path, 'workproof-rollback-${_ids.next()}'),
    ).create(recursive: true);
    final documents = await getApplicationDocumentsDirectory();
    final evidenceDirectory = Directory(
      p.join(documents.path, 'workproof', 'evidence'),
    );
    final rollbackEvidence = Directory(p.join(rollback.path, 'evidence'));
    final rollbackDatabase = await _database.createConsistentSnapshot(
      File(p.join(rollback.path, 'workproof.db')),
    );
    final previousKey = await _keys.evidenceKey();
    final historyId = _ids.next();
    final startedAt = _clock.nowUtc();
    if (await evidenceDirectory.exists()) {
      await _copyDirectory(evidenceDirectory, rollbackEvidence);
    }
    try {
      if (mode == RestoreMode.replace) {
        await _replaceRestore(prepared, documents, evidenceDirectory);
      } else {
        await _mergeRestore(prepared, documents, evidenceDirectory);
      }
      await _database.reopenAndValidate();
      await _assertForeignKeys();
      await _writeHistory(
        id: historyId,
        type: 'restore',
        status: 'completed',
        destination: 'encrypted backup',
        startedAt: startedAt,
        completedAt: _clock.nowUtc(),
        restoreMode: mode.name,
      );
    } catch (_) {
      await _database.close();
      final databasePath = await _database.databaseFilePath;
      await rollbackDatabase.copy(databasePath);
      await _deleteSqliteSidecars(databasePath);
      if (await evidenceDirectory.exists()) {
        await evidenceDirectory.delete(recursive: true);
      }
      if (await rollbackEvidence.exists()) {
        await _copyDirectory(rollbackEvidence, evidenceDirectory);
      }
      await _keys.replaceEvidenceKey(previousKey);
      await _database.reopenAndValidate();
      await _writeHistory(
        id: historyId,
        type: 'restore',
        status: 'rolledBack',
        destination: 'encrypted backup',
        startedAt: startedAt,
        completedAt: _clock.nowUtc(),
        restoreMode: mode.name,
        errorCode: 'restore_rolled_back',
      );
      rethrow;
    } finally {
      if (await rollback.exists()) await rollback.delete(recursive: true);
      await discardPreparedRestore(prepared);
    }
  }

  Future<void> _replaceRestore(
    PreparedRestore prepared,
    Directory documents,
    Directory evidenceDirectory,
  ) async {
    await _rewriteAttachmentPaths(
      prepared.databaseFile,
      prepared.preview.sourceDocumentsPath,
      documents.path,
    );
    final databasePath = await _database.databaseFilePath;
    await _database.close();
    await prepared.databaseFile.copy(databasePath);
    await _deleteSqliteSidecars(databasePath);
    if (await evidenceDirectory.exists()) {
      await evidenceDirectory.delete(recursive: true);
    }
    if (await prepared.evidenceDirectory.exists()) {
      await _copyDirectory(prepared.evidenceDirectory, evidenceDirectory);
    }
    await _keys.replaceEvidenceKey(
      await prepared.evidenceKeyFile.readAsBytes(),
    );
  }

  Future<void> _mergeRestore(
    PreparedRestore prepared,
    Directory documents,
    Directory evidenceDirectory,
  ) async {
    await _rewriteAttachmentPaths(
      prepared.databaseFile,
      prepared.preview.sourceDocumentsPath,
      documents.path,
    );
    final incomingKey = await prepared.evidenceKeyFile.readAsBytes();
    final currentKey = await _keys.evidenceKey();
    if (await prepared.evidenceDirectory.exists()) {
      await BackgroundTaskRunner.run(
        () => _rekeyEvidenceTreeWorker(
          prepared.evidenceDirectory.path,
          incomingKey,
          currentKey,
        ),
        debugName: 'workproof-restore-rekey-evidence',
      );
      await _copyDirectory(
        prepared.evidenceDirectory,
        evidenceDirectory,
        overwrite: false,
      );
    }
    final db = await _database.database;
    await db.execute('PRAGMA foreign_keys = OFF');
    var attached = false;
    try {
      await db.execute('ATTACH DATABASE ? AS incoming', [
        prepared.databaseFile.path,
      ]);
      attached = true;
      final incomingTables = await db.rawQuery(
        "SELECT name FROM incoming.sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
      );
      final mainTables = (await db.rawQuery(
        "SELECT name FROM main.sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
      )).map((row) => row['name']).whereType<String>().toSet();
      await db.transaction((transaction) async {
        for (final row in incomingTables) {
          final table = row['name'];
          if (table is! String || !mainTables.contains(table)) continue;
          final incomingColumns = (await transaction.rawQuery(
            'PRAGMA incoming.table_info(${_quoteIdentifier(table)})',
          )).map((column) => column['name']).whereType<String>().toList();
          final mainColumns = (await transaction.rawQuery(
            'PRAGMA main.table_info(${_quoteIdentifier(table)})',
          )).map((column) => column['name']).whereType<String>().toSet();
          final common = incomingColumns.where(mainColumns.contains).toList();
          if (common.isEmpty) continue;
          final columns = common.map(_quoteIdentifier).join(', ');
          final quotedTable = _quoteIdentifier(table);
          await transaction.execute(
            'INSERT OR IGNORE INTO main.$quotedTable ($columns) '
            'SELECT $columns FROM incoming.$quotedTable',
          );
        }
      });
    } finally {
      if (attached) await db.execute('DETACH DATABASE incoming');
      await db.execute('PRAGMA foreign_keys = ON');
    }
  }

  Future<void> discardPreparedRestore(PreparedRestore prepared) async {
    if (await prepared.stagingDirectory.exists()) {
      await prepared.stagingDirectory.delete(recursive: true);
    }
  }

  Future<BackupHistorySummary?> latestBackup() async {
    final db = await _database.database;
    final rows = await db.query(
      'backup_history',
      where: "backup_type = 'manual'",
      orderBy: 'started_at_utc DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return BackupHistorySummary(
      completedAtUtc:
          DateTime.tryParse(
            '${row['completed_at_utc'] ?? row['started_at_utc']}',
          )?.toUtc() ??
          _clock.nowUtc(),
      fileSizeBytes: row['file_size_bytes'] as int?,
      status: '${row['status']}',
    );
  }

  Future<Map<String, int>> _recordCounts() async {
    final db = await _database.database;
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
    );
    final counts = <String, int>{};
    for (final row in tables) {
      final table = row['name'];
      if (table is! String || table == 'backup_history') continue;
      final value = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM ${_quoteIdentifier(table)}'),
      );
      counts[table] = value ?? 0;
    }
    return counts;
  }

  Future<void> _writeHistory({
    required String id,
    required String type,
    required String status,
    required String destination,
    required DateTime startedAt,
    DateTime? completedAt,
    Map<String, int>? counts,
    String? digest,
    int? size,
    String? restoreMode,
    String? errorCode,
  }) async {
    final db = await _database.database;
    await db.insert('backup_history', {
      'id': id,
      'workspace_id': workspaceId,
      'backup_type': type,
      'status': status,
      'destination_label': destination,
      'schema_version': DatabaseHelper.schemaVersion,
      'record_counts_json': counts == null ? null : jsonEncode(counts),
      'sha256': digest,
      'started_at_utc': startedAt.toIso8601String(),
      'completed_at_utc': completedAt?.toIso8601String(),
      'error_code': errorCode,
      'manifest_version': manifestVersion,
      'file_size_bytes': size,
      'restore_mode': restoreMode,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _assertForeignKeys() async {
    final db = await _database.database;
    final problems = await db.rawQuery('PRAGMA foreign_key_check');
    if (problems.isNotEmpty) {
      throw StateError('Restored database has broken relationships.');
    }
  }

  static Future<void> _rewriteAttachmentPaths(
    File databaseFile,
    String oldDocuments,
    String newDocuments,
  ) async {
    if (oldDocuments.isEmpty || oldDocuments == newDocuments) return;
    final db = await openDatabase(databaseFile.path, singleInstance: false);
    try {
      final columns = (await db.rawQuery(
        'PRAGMA table_info(attachments)',
      )).map((row) => row['name']).whereType<String>().toSet();
      final pathColumns = [
        'local_path',
        'shared_copy_path',
      ].where(columns.contains).toList();
      if (pathColumns.isEmpty) return;
      final rows = await db.query('attachments');
      await db.transaction((transaction) async {
        for (final row in rows) {
          final update = <String, Object?>{};
          for (final column in pathColumns) {
            final value = row[column];
            if (value is String && p.isWithin(oldDocuments, value)) {
              update[column] = p.join(
                newDocuments,
                p.relative(value, from: oldDocuments),
              );
            }
          }
          if (update.isNotEmpty) {
            await transaction.update(
              'attachments',
              update,
              where: 'id = ?',
              whereArgs: [row['id']],
            );
          }
        }
      });
    } finally {
      await db.close();
    }
  }

  static Future<void> _validateStagedDatabase(
    File databaseFile,
    int manifestSchema,
  ) async {
    final db = await openDatabase(
      databaseFile.path,
      readOnly: true,
      singleInstance: false,
    );
    try {
      final integrity = await db.rawQuery('PRAGMA integrity_check');
      if (integrity.isEmpty || integrity.first.values.first != 'ok') {
        throw const FormatException('Backup database integrity check failed.');
      }
      final foreignKeys = await db.rawQuery('PRAGMA foreign_key_check');
      if (foreignKeys.isNotEmpty) {
        throw const FormatException(
          'Backup database relationships are invalid.',
        );
      }
      final userVersion = Sqflite.firstIntValue(
        await db.rawQuery('PRAGMA user_version'),
      );
      if (userVersion != manifestSchema) {
        throw const FormatException(
          'Backup database version does not match its manifest.',
        );
      }
    } finally {
      await db.close();
    }
  }

  static Future<void> _rotateRecoverySnapshots(
    Directory directory, {
    required int keep,
  }) async {
    final files = await directory
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.workproof'))
        .cast<File>()
        .toList();
    files.sort((left, right) => right.path.compareTo(left.path));
    for (final file in files.skip(keep)) {
      await file.delete();
    }
  }

  static Future<void> _copyDirectory(
    Directory source,
    Directory destination, {
    bool overwrite = true,
  }) async {
    await destination.create(recursive: true);
    await for (final entity in source.list(
      recursive: true,
      followLinks: false,
    )) {
      final relative = p.relative(entity.path, from: source.path);
      final target = p.join(destination.path, relative);
      if (entity is Directory) {
        await Directory(target).create(recursive: true);
      } else if (entity is File) {
        final targetFile = File(target);
        await targetFile.parent.create(recursive: true);
        if (!overwrite && await targetFile.exists()) continue;
        await entity.copy(target);
      }
    }
  }

  static Future<void> _deleteSqliteSidecars(String databasePath) async {
    for (final suffix in ['-wal', '-shm', '-journal']) {
      final file = File('$databasePath$suffix');
      if (await file.exists()) await file.delete();
    }
  }

  static String _quoteIdentifier(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  static String _safeStamp(DateTime value) =>
      value.toUtc().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');

  static void _validatePassword(String password) {
    if (password.length < minimumPasswordLength) {
      throw const FormatException('Backup password is too short.');
    }
  }
}

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(
    keys: ref.watch(secureKeyStoreProvider),
    clock: ref.watch(appClockProvider),
    ids: ref.watch(idGeneratorProvider),
  );
});

Future<List<Map<String, Object?>>> _buildManifestEntriesWorker(
  String packagePath,
) async {
  final root = Directory(packagePath);
  final entries = <Map<String, Object?>>[];
  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    final archivePath = p
        .relative(entity.path, from: root.path)
        .replaceAll('\\', '/');
    entries.add({
      'archivePath': archivePath,
      'sizeBytes': await entity.length(),
      'sha256': await _sha256PathWorker(entity.path),
    });
  }
  entries.sort(
    (left, right) => (left['archivePath']! as String).compareTo(
      right['archivePath']! as String,
    ),
  );
  return entries;
}

Future<int> _verifyManifestEntriesWorker(
  String extractedPath,
  List<dynamic> rawEntries,
) async {
  var evidenceCount = 0;
  final seen = <String>{};
  for (final value in rawEntries) {
    if (value is! Map) throw const FormatException('Invalid backup entry.');
    final archivePath = value['archivePath'];
    final expectedSize = value['sizeBytes'];
    final expectedDigest = value['sha256'];
    if (archivePath is! String ||
        expectedSize is! int ||
        expectedDigest is! String ||
        !_isSafeArchivePath(archivePath) ||
        !seen.add(p.posix.normalize(archivePath))) {
      throw const FormatException('Invalid backup entry metadata.');
    }
    final file = File(
      p.join(extractedPath, p.joinAll(p.posix.split(archivePath))),
    );
    if (!await file.exists() ||
        await file.length() != expectedSize ||
        await _sha256PathWorker(file.path) != expectedDigest) {
      throw FormatException('Backup integrity check failed: $archivePath');
    }
    if (archivePath.startsWith('evidence/')) evidenceCount++;
  }
  return evidenceCount;
}

Future<String> _sha256PathWorker(String path) async =>
    (await sha256.bind(File(path).openRead()).first).toString();

Future<void> _createArchiveWorker(String sourcePath, String zipPath) async {
  final encoder = ZipFileEncoder();
  encoder.create(zipPath);
  try {
    final source = Directory(sourcePath);
    final entities = await source
        .list(recursive: true, followLinks: false)
        .where((entity) => entity is File)
        .cast<File>()
        .toList();
    entities.sort((left, right) => left.path.compareTo(right.path));
    for (final file in entities) {
      final archivePath = p
          .relative(file.path, from: source.path)
          .replaceAll('\\', '/');
      await encoder.addFile(file, archivePath);
    }
  } finally {
    await encoder.close();
  }
}

Future<void> _extractArchiveWorker(String zipPath, String outputPath) async {
  const maximumEntryBytes = 256 * 1024 * 1024;
  const maximumTotalBytes = 5 * 1024 * 1024 * 1024;
  const maximumEntries = 50000;
  final input = InputFileStream(zipPath);
  try {
    final archive = ZipDecoder().decodeStream(input);
    final seen = <String>{};
    var totalBytes = 0;
    for (final entry in archive) {
      if (seen.length >= maximumEntries) {
        throw const FormatException('Backup contains too many files.');
      }
      final name = entry.name.replaceAll('\\', '/');
      final normalized = p.posix.normalize(name);
      if (!_isSafeArchivePath(name) ||
          entry.isSymbolicLink ||
          !seen.add(normalized) ||
          entry.size > maximumEntryBytes) {
        throw const FormatException('Unsafe path in backup archive.');
      }
      totalBytes += entry.size;
      if (totalBytes > maximumTotalBytes) {
        throw const FormatException('Backup archive is too large.');
      }
      final destination = p.join(
        outputPath,
        p.joinAll(p.posix.split(normalized)),
      );
      if (entry.isFile) {
        await Directory(p.dirname(destination)).create(recursive: true);
        final output = OutputFileStream(destination);
        try {
          entry.writeContent(output);
        } finally {
          output.closeSync();
        }
      } else {
        await Directory(destination).create(recursive: true);
      }
    }
  } finally {
    input.closeSync();
  }
}

bool _isSafeArchivePath(String value) {
  if (value.isEmpty || value.contains('\u0000') || p.posix.isAbsolute(value)) {
    return false;
  }
  final normalized = p.posix.normalize(value);
  return normalized != '..' &&
      !normalized.startsWith('../') &&
      !p.posix.split(normalized).contains('..');
}

Future<void> _rekeyEvidenceTreeWorker(
  String rootPath,
  List<int> sourceKey,
  List<int> destinationKey,
) async {
  final root = Directory(rootPath);
  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    final stored = await entity.readAsBytes();
    final clear = EncryptedFileCodec.isEncrypted(stored)
        ? await EncryptedFileCodec.decrypt(stored, sourceKey)
        : stored;
    final encrypted = await EncryptedFileCodec.encrypt(clear, destinationKey);
    await entity.writeAsBytes(encrypted, flush: true);
  }
}
