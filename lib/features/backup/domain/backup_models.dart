import 'dart:io';

enum RestoreMode { merge, replace }

class BackupArtifact {
  const BackupArtifact({
    required this.file,
    required this.createdAtUtc,
    required this.sizeBytes,
    required this.sha256,
    required this.recordCount,
    required this.evidenceFileCount,
  });

  final File file;
  final DateTime createdAtUtc;
  final int sizeBytes;
  final String sha256;
  final int recordCount;
  final int evidenceFileCount;
}

class BackupPreview {
  const BackupPreview({
    required this.createdAtUtc,
    required this.schemaVersion,
    required this.recordCount,
    required this.evidenceFileCount,
    required this.sourceDocumentsPath,
  });

  final DateTime createdAtUtc;
  final int schemaVersion;
  final int recordCount;
  final int evidenceFileCount;
  final String sourceDocumentsPath;
}

class PreparedRestore {
  const PreparedRestore({
    required this.stagingDirectory,
    required this.preview,
    required this.databaseFile,
    required this.evidenceDirectory,
    required this.evidenceKeyFile,
  });

  final Directory stagingDirectory;
  final BackupPreview preview;
  final File databaseFile;
  final Directory evidenceDirectory;
  final File evidenceKeyFile;
}

class BackupHistorySummary {
  const BackupHistorySummary({
    required this.completedAtUtc,
    required this.fileSizeBytes,
    required this.status,
  });

  final DateTime completedAtUtc;
  final int? fileSizeBytes;
  final String status;
}
