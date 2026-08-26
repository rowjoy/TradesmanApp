import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/backup_service.dart';

class BackupRecoveryCoordinator {
  BackupRecoveryCoordinator(this._service);

  static const _lastSnapshotKey = 'workproof_last_recovery_snapshot_utc';
  final BackupService _service;
  Future<void>? _running;

  Future<void> runIfDue() => _running ??= _run().whenComplete(() {
    _running = null;
  });

  Future<void> _run() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final lastValue = preferences.getString(_lastSnapshotKey);
      final last = lastValue == null ? null : DateTime.tryParse(lastValue)?.toUtc();
      final now = DateTime.now().toUtc();
      if (last != null && now.difference(last) < const Duration(hours: 24)) {
        return;
      }
      await _service.createRecoverySnapshot();
      await preferences.setString(_lastSnapshotKey, now.toIso8601String());
    } catch (_) {
      // Recovery is best-effort and must never block the local workspace UI.
    }
  }
}

final backupRecoveryCoordinatorProvider = Provider<BackupRecoveryCoordinator>(
  (ref) => BackupRecoveryCoordinator(ref.watch(backupServiceProvider)),
);
