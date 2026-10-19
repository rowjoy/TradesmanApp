import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../l10n/l10n.dart';
import '../../customers/customer_provider.dart';
import '../../jobs/job_provider.dart';
import '../../notifications/application/notification_controller.dart';
import '../../onboarding/presentation/controllers/onboarding_controller.dart';
import '../../pay_protection/data/pay_protection_repository.dart';
import '../../time_tracking/time_tracking_provider.dart';
import '../../work/data/work_repository.dart';
import '../application/backup_controller.dart';
import '../domain/backup_models.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(
      Future.microtask(
        () => ref.read(backupControllerProvider.notifier).initialize(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(backupControllerProvider);
    return PopScope(
      canPop: !state.busy,
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.backupRestoreTitle)),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
          children: [
            _SafetyCard(),
            const SizedBox(height: 16),
            _SectionTitle(context.l10n.createBackupTitle),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(context.l10n.createBackupDescription),
                    if (state.latest != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.lastBackupLabel(
                          _formatDate(context, state.latest!.completedAtUtc),
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: state.busy ? null : _createBackup,
                      icon: state.action == BackupAction.creating
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.lock_outline_rounded),
                      label: Text(
                        state.action == BackupAction.creating
                            ? context.l10n.creatingBackup
                            : context.l10n.createEncryptedBackup,
                      ),
                    ),
                    if (state.artifact != null) ...[
                      const SizedBox(height: 12),
                      _BackupCreatedSummary(artifact: state.artifact!),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: state.busy ? null : _shareBackup,
                        icon: const Icon(Icons.ios_share_rounded),
                        label: Text(context.l10n.shareBackup),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle(context.l10n.restoreBackupTitle),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(context.l10n.restoreBackupDescription),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: state.busy ? null : _selectBackup,
                      icon: state.action == BackupAction.validating
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.file_open_outlined),
                      label: Text(
                        state.action == BackupAction.validating
                            ? context.l10n.verifyingBackup
                            : context.l10n.chooseBackupFile,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: state.busy ? null : _selectRecovery,
                      icon: const Icon(Icons.history_rounded),
                      label: Text(context.l10n.useLatestRecovery),
                    ),
                    if (state.prepared case final prepared?) ...[
                      const SizedBox(height: 16),
                      _RestorePreview(preview: prepared.preview),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.chooseRestoreMode,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonalIcon(
                        onPressed: state.busy
                            ? null
                            : () => _restore(RestoreMode.merge),
                        icon: const Icon(Icons.merge_rounded),
                        label: Text(context.l10n.mergeRestore),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: state.busy
                            ? null
                            : () => _restore(RestoreMode.replace),
                        icon: const Icon(Icons.restore_page_outlined),
                        label: Text(context.l10n.replaceRestore),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.restoreRollbackNote,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (state.action == BackupAction.restoring) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                      const SizedBox(height: 8),
                      Text(context.l10n.restoringBackup),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBackup() async {
    final active = await ref.read(activeTimeEntryProvider.future);
    if (!mounted) return;
    if (active != null) {
      AppFeedback.info(context, context.l10n.restoreBlockedByTimer);
      return;
    }
    final password = await _passwordDialog(
      context,
      title: context.l10n.createBackupPassword,
      confirm: true,
    );
    if (password == null) return;
    final ok = await ref
        .read(backupControllerProvider.notifier)
        .createBackup(password);
    if (!mounted) return;
    if (ok) {
      AppFeedback.success(context, context.l10n.backupCreatedSuccess);
    } else {
      _showControllerError();
    }
  }

  Future<void> _shareBackup() async {
    final box = context.findRenderObject() as RenderBox?;
    try {
      await ref
          .read(backupControllerProvider.notifier)
          .shareLatest(
            origin: box == null
                ? null
                : box.localToGlobal(Offset.zero) & box.size,
          );
    } catch (_) {
      if (mounted) AppFeedback.error(context, context.l10n.shareBackupFailed);
    }
  }

  Future<void> _selectBackup() async {
    final active = await ref.read(activeTimeEntryProvider.future);
    if (!mounted) return;
    if (active != null) {
      AppFeedback.info(context, context.l10n.restoreBlockedByTimer);
      return;
    }
    final password = await _passwordDialog(
      context,
      title: context.l10n.enterBackupPassword,
    );
    if (password == null) return;
    final result = await ref
        .read(backupControllerProvider.notifier)
        .chooseAndValidateBackup(password);
    if (!mounted || result == null) return;
    if (result) {
      AppFeedback.success(context, context.l10n.backupVerifiedSuccess);
    } else {
      _showControllerError();
    }
  }

  Future<void> _selectRecovery() async {
    final active = await ref.read(activeTimeEntryProvider.future);
    if (!mounted) return;
    if (active != null) {
      AppFeedback.info(context, context.l10n.restoreBlockedByTimer);
      return;
    }
    final result = await ref
        .read(backupControllerProvider.notifier)
        .prepareLatestRecovery();
    if (!mounted) return;
    if (result) {
      AppFeedback.success(context, context.l10n.recoveryVerifiedSuccess);
    } else {
      _showControllerError();
    }
  }

  Future<void> _restore(RestoreMode mode) async {
    final active = await ref.read(activeTimeEntryProvider.future);
    if (!mounted) return;
    if (active != null) {
      AppFeedback.info(context, context.l10n.restoreBlockedByTimer);
      return;
    }
    final confirmed = await _confirmRestore(context, mode);
    if (!confirmed) return;
    final currentNotifications = ref.read(
      notificationControllerProvider.notifier,
    );
    final ok = await restoreWithNotificationRebuild(
      currentNotifications: currentNotifications,
      restore: () => ref.read(backupControllerProvider.notifier).restore(mode),
      recreateNotifications: () async {
        await ref
            .read(onboardingControllerProvider.notifier)
            .reloadAfterRestore();
        ref.invalidate(notificationControllerProvider);
        return ref.read(notificationControllerProvider.notifier);
      },
    );
    if (!mounted) return;
    if (!ok) {
      _showControllerError();
      return;
    }
    ref.invalidate(customerRepositoryProvider);
    ref.invalidate(jobRepositoryProvider);
    ref.invalidate(workRepositoryProvider);
    ref.invalidate(payProtectionRepositoryProvider);
    ref.invalidate(timeTrackingRepositoryProvider);
    AppFeedback.success(context, context.l10n.restoreCompletedSuccess);
    context.go(AppRoutes.startup);
  }

  void _showControllerError() {
    final code = ref.read(backupControllerProvider).errorCode;
    final message = switch (code) {
      'wrong_password_or_damaged' => context.l10n.wrongPasswordOrDamaged,
      'unsupported_backup' => context.l10n.unsupportedBackup,
      'backup_integrity_failed' => context.l10n.backupIntegrityFailed,
      'restore_failed_rolled_back' => context.l10n.restoreFailedRolledBack,
      'restore_validation_failed' => context.l10n.restoreValidationFailed,
      'no_recovery_snapshot' => context.l10n.noRecoverySnapshot,
      _ => context.l10n.backupOperationFailed,
    };
    AppFeedback.error(context, message);
  }

  String _formatDate(BuildContext context, DateTime value) => DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).add_jm().format(value.toLocal());
}

Future<bool> restoreWithNotificationRebuild({
  required NotificationController currentNotifications,
  required Future<bool> Function() restore,
  required Future<NotificationController> Function() recreateNotifications,
}) async {
  try {
    await currentNotifications.suspendSchedulingForDataRestore();
  } catch (_) {
    return false;
  }

  late final bool restored;
  try {
    restored = await restore();
  } catch (error, stackTrace) {
    await currentNotifications.resumeSchedulingAfterDataRestore();
    Error.throwWithStackTrace(error, stackTrace);
  }
  if (!restored) {
    await currentNotifications.resumeSchedulingAfterDataRestore();
    return false;
  }

  try {
    final restoredNotifications = await recreateNotifications();
    await restoredNotifications.initialize();
    if (!restoredNotifications.isInitialized) {
      await restoredNotifications.initialize();
    }
    if (!restoredNotifications.isInitialized) return false;
    return restoredNotifications.rebuildScheduleAfterDataRestore();
  } catch (_) {
    await currentNotifications.resumeSchedulingAfterDataRestore();
    return false;
  }
}

class _SafetyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.secondaryContainer,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.backupSafetyTitle,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(context.l10n.backupSafetyDescription),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _BackupCreatedSummary extends StatelessWidget {
  const _BackupCreatedSummary({required this.artifact});

  final BackupArtifact artifact;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        context.l10n.backupCreatedSummary(
          artifact.recordCount,
          artifact.evidenceFileCount,
          _formatBytes(artifact.sizeBytes),
        ),
      ),
    ),
  );
}

class _RestorePreview extends StatelessWidget {
  const _RestorePreview({required this.preview});

  final BackupPreview preview;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_outlined),
              const SizedBox(width: 8),
              Text(
                context.l10n.verifiedBackupPreview,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(context.l10n.backupRecordsCount(preview.recordCount)),
          Text(context.l10n.backupEvidenceCount(preview.evidenceFileCount)),
          Text(context.l10n.backupSchemaVersion(preview.schemaVersion)),
        ],
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
  );
}

Future<String?> _passwordDialog(
  BuildContext context, {
  required String title,
  bool confirm = false,
}) => showDialog<String>(
  context: context,
  builder: (_) => _PasswordDialog(title: title, confirm: confirm),
);

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({required this.title, required this.confirm});

  final String title;
  final bool confirm;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _first = TextEditingController();
  final _second = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  void _submit() {
    if (_first.text.length < 10) {
      setState(() => _error = context.l10n.backupPasswordHint);
      return;
    }
    if (widget.confirm && _first.text != _second.text) {
      setState(() => _error = context.l10n.passwordsDoNotMatch);
      return;
    }
    Navigator.pop(context, _first.text);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: Text(widget.title),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.l10n.backupPasswordWarning),
        const SizedBox(height: 12),
        TextField(
          controller: _first,
          autofocus: true,
          obscureText: true,
          textInputAction: widget.confirm
              ? TextInputAction.next
              : TextInputAction.done,
          onSubmitted: widget.confirm ? null : (_) => _submit(),
          decoration: InputDecoration(
            labelText: context.l10n.backupPassword,
            helperText: context.l10n.backupPasswordHint,
            errorText: _error,
          ),
        ),
        if (widget.confirm) ...[
          const SizedBox(height: 10),
          TextField(
            controller: _second,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: context.l10n.confirmBackupPassword,
            ),
          ),
        ],
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.cancelLabel),
      ),
      FilledButton(onPressed: _submit, child: Text(context.l10n.continueLabel)),
    ],
  );
}

Future<bool> _confirmRestore(BuildContext context, RestoreMode mode) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: Icon(
            mode == RestoreMode.replace
                ? Icons.warning_amber_rounded
                : Icons.merge_rounded,
          ),
          title: Text(
            mode == RestoreMode.replace
                ? context.l10n.confirmReplaceRestore
                : context.l10n.confirmMergeRestore,
          ),
          content: Text(
            mode == RestoreMode.replace
                ? context.l10n.replaceRestoreWarning
                : context.l10n.mergeRestoreDescription,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.cancelLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(context.l10n.restoreNow),
            ),
          ],
        ),
      ) ??
      false;
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
