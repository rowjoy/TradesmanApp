import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../application/app_lock_controller.dart';

class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  DateTime? _backgroundedAt;
  bool _privacyShieldVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(
      Future.microtask(
        () => ref.read(appLockControllerProvider.notifier).initialize(),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _backgroundedAt ??= DateTime.now();
      if (mounted && !_privacyShieldVisible) {
        setState(() => _privacyShieldVisible = true);
      }
      return;
    }
    if (state == AppLifecycleState.resumed && _backgroundedAt != null) {
      final elapsed = DateTime.now().difference(_backgroundedAt!);
      _backgroundedAt = null;
      if (elapsed >= const Duration(seconds: 15)) {
        ref.read(appLockControllerProvider.notifier).lock();
      }
      if (mounted && _privacyShieldVisible) {
        setState(() => _privacyShieldVisible = false);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appLockControllerProvider);
    if (state.initializing) {
      return const ColoredBox(
        color: Colors.white,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final privacyShield = state.enabled && _privacyShieldVisible;
    final blocked = state.enabled && (privacyShield || state.locked);
    return Stack(
      fit: StackFit.expand,
      children: [
        ExcludeSemantics(
          excluding: blocked,
          child: IgnorePointer(ignoring: blocked, child: widget.child),
        ),
        if (privacyShield)
          const _PrivacyShield()
        else if (state.enabled && state.locked)
          const _LockedScreen(),
      ],
    );
  }
}

class _PrivacyShield extends StatelessWidget {
  const _PrivacyShield();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surface,
    child: const Center(child: Icon(Icons.shield_outlined, size: 56)),
  );
}

class _LockedScreen extends ConsumerStatefulWidget {
  const _LockedScreen();

  @override
  ConsumerState<_LockedScreen> createState() => _LockedScreenState();
}

class _LockedScreenState extends ConsumerState<_LockedScreen> {
  final _pin = TextEditingController();

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    final unlocked = await ref
        .read(appLockControllerProvider.notifier)
        .verifyPin(_pin.text);
    if (!unlocked && mounted) {
      _pin.clear();
      FocusScope.of(context).requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appLockControllerProvider);
    final error = switch (state.errorCode) {
      'cooldown' => context.l10n.tooManyAttempts,
      'biometric_failed' => context.l10n.biometricFailed,
      'wrong_pin' => context.l10n.wrongPin,
      'secure_storage_error' => context.l10n.securitySaveFailed,
      _ => null,
    };
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 64),
                    const SizedBox(height: 18),
                    Text(
                      context.l10n.unlockWorkProof,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.enterPinToContinue,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _pin,
                      autofocus: true,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      maxLength: 8,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: context.l10n.enterPin,
                        errorText: error,
                        counterText: '',
                      ),
                      onSubmitted: (_) {
                        if (!state.busy) unawaited(_unlock());
                      },
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: state.busy ? null : _unlock,
                      icon: state.busy
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.lock_open_rounded),
                      label: Text(context.l10n.unlock),
                    ),
                    if (state.biometricsEnabled &&
                        state.biometricsAvailable) ...[
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: state.busy
                            ? null
                            : () => ref
                                  .read(appLockControllerProvider.notifier)
                                  .authenticateWithBiometrics(
                                    context.l10n.biometricUnlockReason,
                                  ),
                        icon: const Icon(Icons.fingerprint_rounded),
                        label: Text(context.l10n.unlockWithBiometrics),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
