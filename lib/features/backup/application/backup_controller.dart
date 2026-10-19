import 'dart:async';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../data/backup_service.dart';
import '../domain/backup_models.dart';

enum BackupAction { idle, creating, validating, restoring }

class BackupState {
  const BackupState({
    this.action = BackupAction.idle,
    this.latest,
    this.artifact,
    this.prepared,
    this.errorCode,
    this.restoreCompleted = false,
  });

  final BackupAction action;
  final BackupHistorySummary? latest;
  final BackupArtifact? artifact;
  final PreparedRestore? prepared;
  final String? errorCode;
  final bool restoreCompleted;

  bool get busy => action != BackupAction.idle;

  BackupState copyWith({
    BackupAction? action,
    BackupHistorySummary? latest,
    BackupArtifact? artifact,
    PreparedRestore? prepared,
    String? errorCode,
    bool clearError = false,
    bool clearPrepared = false,
    bool? restoreCompleted,
  }) => BackupState(
    action: action ?? this.action,
    latest: latest ?? this.latest,
    artifact: artifact ?? this.artifact,
    prepared: clearPrepared ? null : prepared ?? this.prepared,
    errorCode: clearError ? null : errorCode ?? this.errorCode,
    restoreCompleted: restoreCompleted ?? this.restoreCompleted,
  );
}

class BackupController extends StateNotifier<BackupState> {
  BackupController(this._service) : super(const BackupState());

  final BackupService _service;

  Future<void> initialize() async {
    state = state.copyWith(latest: await _service.latestBackup());
  }

  Future<bool> createBackup(String password) async {
    state = state.copyWith(
      action: BackupAction.creating,
      clearError: true,
      restoreCompleted: false,
    );
    try {
      final artifact = await _service.createManualBackup(password);
      state = state.copyWith(
        action: BackupAction.idle,
        artifact: artifact,
        latest: BackupHistorySummary(
          completedAtUtc: artifact.createdAtUtc,
          fileSizeBytes: artifact.sizeBytes,
          status: 'completed',
        ),
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        action: BackupAction.idle,
        errorCode: _errorCode(error, fallback: 'backup_failed'),
      );
      return false;
    }
  }

  Future<bool?> chooseAndValidateBackup(String password) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['workproof'],
      allowMultiple: false,
      withData: false,
    );
    final path = result == null || result.files.isEmpty
        ? null
        : result.files.single.path;
    if (path == null) return null;
    await clearPrepared();
    state = state.copyWith(
      action: BackupAction.validating,
      clearError: true,
      restoreCompleted: false,
    );
    try {
      final prepared = await _service.prepareRestore(
        backupPath: path,
        password: password,
      );
      state = state.copyWith(action: BackupAction.idle, prepared: prepared);
      return true;
    } catch (error) {
      state = state.copyWith(
        action: BackupAction.idle,
        errorCode: _errorCode(error, fallback: 'restore_validation_failed'),
      );
      return false;
    }
  }

  Future<bool> prepareLatestRecovery() async {
    await clearPrepared();
    state = state.copyWith(
      action: BackupAction.validating,
      clearError: true,
      restoreCompleted: false,
    );
    try {
      final prepared = await _service.prepareLatestRecovery();
      if (prepared == null) {
        state = state.copyWith(
          action: BackupAction.idle,
          errorCode: 'no_recovery_snapshot',
        );
        return false;
      }
      state = state.copyWith(action: BackupAction.idle, prepared: prepared);
      return true;
    } catch (error) {
      state = state.copyWith(
        action: BackupAction.idle,
        errorCode: _errorCode(error, fallback: 'restore_validation_failed'),
      );
      return false;
    }
  }

  Future<bool> restore(RestoreMode mode) async {
    final prepared = state.prepared;
    if (prepared == null) return false;
    state = state.copyWith(
      action: BackupAction.restoring,
      clearError: true,
      restoreCompleted: false,
    );
    try {
      await _service.restore(prepared, mode);
      state = state.copyWith(
        action: BackupAction.idle,
        clearPrepared: true,
        restoreCompleted: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        action: BackupAction.idle,
        clearPrepared: true,
        errorCode: _errorCode(error, fallback: 'restore_failed_rolled_back'),
      );
      return false;
    }
  }

  Future<void> shareLatest({Rect? origin}) async {
    final artifact = state.artifact;
    if (artifact == null) return;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(artifact.file.path)],
        sharePositionOrigin: origin,
      ),
    );
  }

  Future<void> clearPrepared() async {
    if (!mounted) return;

    final prepared = state.prepared;

    // await-এর আগেই state clear করুন।
    state = state.copyWith(clearPrepared: true);

    if (prepared != null) {
      await _discardPreparedSafely(prepared);
    }
  }

  Future<void> _discardPreparedSafely(PreparedRestore prepared) async {
    try {
      await _service.discardPreparedRestore(prepared);
    } catch (_) {
      // Temporary restore cleanup failure should not crash the app.
    }
  }

  void cleanupOnDispose() {
    if (!mounted) return;

    final prepared = state.prepared;
    if (prepared != null) {
      unawaited(_discardPreparedSafely(prepared));
    }
  }

  String _errorCode(Object error, {required String fallback}) {
    final value = error.toString().toLowerCase();
    if (value.contains('password') || value.contains('authentication')) {
      return 'wrong_password_or_damaged';
    }
    if (value.contains('unsupported')) return 'unsupported_backup';
    if (value.contains('integrity') || value.contains('checksum')) {
      return 'backup_integrity_failed';
    }
    return fallback;
  }
}

final backupControllerProvider =
    StateNotifierProvider.autoDispose<BackupController, BackupState>((ref) {
      final controller = BackupController(ref.watch(backupServiceProvider));

      ref.onDispose(controller.cleanupOnDispose);

      return controller;
    });
