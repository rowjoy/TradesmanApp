import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_feedback.dart';
import '../../../l10n/l10n.dart';
import '../application/app_lock_controller.dart';

class SecuritySettingsScreen extends ConsumerWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appLockControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.securityPrivacyTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.lock_outline_rounded),
                  title: Text(context.l10n.enableAppLock),
                  subtitle: Text(context.l10n.appLockSubtitle),
                  value: state.enabled,
                  onChanged: state.busy
                      ? null
                      : (enabled) => enabled
                            ? _createPin(context, ref)
                            : _disableLock(context, ref),
                ),
                if (state.enabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.password_rounded),
                    title: Text(context.l10n.changePin),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: state.busy ? null : () => _changePin(context, ref),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint_rounded),
                    title: Text(context.l10n.useBiometrics),
                    subtitle: Text(
                      state.biometricsAvailable
                          ? context.l10n.biometricLockSubtitle
                          : context.l10n.biometricUnavailable,
                    ),
                    value: state.biometricsAvailable && state.biometricsEnabled,
                    onChanged: state.busy || !state.biometricsAvailable
                        ? null
                        : (value) async {
                            try {
                              await ref
                                  .read(appLockControllerProvider.notifier)
                                  .setBiometricsEnabled(
                                    value,
                                    context.l10n.biometricSetupReason,
                                  );
                            } catch (_) {
                              if (context.mounted) {
                                AppFeedback.error(
                                  context,
                                  context.l10n.biometricFailed,
                                );
                              }
                            }
                          },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_clock_outlined),
                    title: Text(context.l10n.lockNow),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        ref.read(appLockControllerProvider.notifier).lock(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.enhanced_encryption_outlined),
              title: Text(context.l10n.evidenceEncryptionTitle),
              subtitle: Text(context.l10n.evidenceEncryptionDescription),
              trailing: const Icon(Icons.verified_user_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createPin(BuildContext context, WidgetRef ref) async {
    final pin = await _pinDialog(context, confirm: true);
    if (pin == null) return;
    try {
      await ref.read(appLockControllerProvider.notifier).setPin(pin);
      if (context.mounted) {
        AppFeedback.success(context, context.l10n.securitySaved);
      }
    } catch (_) {
      if (context.mounted) {
        AppFeedback.error(context, context.l10n.securitySaveFailed);
      }
    }
  }

  Future<void> _changePin(BuildContext context, WidgetRef ref) async {
    final current = await _pinDialog(context, verifyOnly: true);
    if (current == null) return;
    final valid = await ref
        .read(appLockControllerProvider.notifier)
        .verifyPin(current);
    if (!valid || !context.mounted) {
      if (context.mounted) AppFeedback.error(context, context.l10n.wrongPin);
      return;
    }
    final next = await _pinDialog(context, confirm: true);
    if (next == null) return;
    await ref.read(appLockControllerProvider.notifier).setPin(next);
    if (context.mounted) {
      AppFeedback.success(context, context.l10n.securitySaved);
    }
  }

  Future<void> _disableLock(BuildContext context, WidgetRef ref) async {
    final current = await _pinDialog(context, verifyOnly: true);
    if (current == null) return;
    final valid = await ref
        .read(appLockControllerProvider.notifier)
        .verifyPin(current);
    if (!valid || !context.mounted) {
      if (context.mounted) AppFeedback.error(context, context.l10n.wrongPin);
      return;
    }
    await ref.read(appLockControllerProvider.notifier).disable();
    if (context.mounted) {
      AppFeedback.success(context, context.l10n.securitySaved);
    }
  }
}

Future<String?> _pinDialog(
  BuildContext context, {
  bool confirm = false,
  bool verifyOnly = false,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _PinDialog(confirm: confirm, verifyOnly: verifyOnly),
  );
}

class _PinDialog extends StatefulWidget {
  const _PinDialog({required this.confirm, required this.verifyOnly});

  final bool confirm;
  final bool verifyOnly;

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final _first = TextEditingController();
  final _second = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.verifyOnly ? context.l10n.enterPin : context.l10n.createPin,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _first,
            autofocus: true,
            obscureText: true,
            maxLength: 8,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: context.l10n.enterPin,
              helperText: context.l10n.pinDigitsHint,
              errorText: _error,
              counterText: '',
            ),
          ),
          if (widget.confirm) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _second,
              obscureText: true,
              maxLength: 8,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: context.l10n.confirmPin,
                counterText: '',
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
        FilledButton(
          onPressed: () {
            if (!RegExp(r'^\d{4,8}$').hasMatch(_first.text)) {
              setState(() => _error = context.l10n.pinDigitsHint);
              return;
            }
            if (widget.confirm && _first.text != _second.text) {
              setState(() => _error = context.l10n.pinMismatch);
              return;
            }
            Navigator.pop(context, _first.text);
          },
          child: Text(context.l10n.continueLabel),
        ),
      ],
    );
  }
}
