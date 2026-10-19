import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../application/app_update_controller.dart';
import '../domain/app_update_models.dart';
import 'app_update_dialog.dart';

/// Connects update state to route-safe dialogs and non-blocking progress UI.
class AppUpdateCoordinator extends ConsumerStatefulWidget {
  const AppUpdateCoordinator({
    super.key,
    required this.enabled,
    required this.child,
    this.presentationAllowed,
  });

  final bool enabled;
  final Widget child;
  final bool Function()? presentationAllowed;

  @override
  ConsumerState<AppUpdateCoordinator> createState() =>
      _AppUpdateCoordinatorState();
}

class _AppUpdateCoordinatorState extends ConsumerState<AppUpdateCoordinator>
    with WidgetsBindingObserver {
  bool _dialogOpen = false;
  String? _presentedOfferId;
  String? _lastFailureCode;
  Timer? _presentationRetry;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
  _updateSnackBarController;
  AppUpdatePhase? _updateSnackBarPhase;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.enabled) return;
      unawaited(
        ref.read(appUpdateControllerProvider.notifier).checkForUpdate(),
      );
    });
  }

  @override
  void didUpdateWidget(covariant AppUpdateCoordinator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.enabled && widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !widget.enabled) return;
        final controller = ref.read(appUpdateControllerProvider.notifier);
        unawaited(controller.onResumed());
        _handleState(ref.read(appUpdateControllerProvider));
      });
    } else if (oldWidget.enabled && !widget.enabled) {
      _presentationRetry?.cancel();
      _presentationRetry = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !widget.enabled) return;
        unawaited(ref.read(appUpdateControllerProvider.notifier).onResumed());
        _handleState(ref.read(appUpdateControllerProvider));
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _presentationRetry?.cancel();
    _updateSnackBarController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AppUpdateState>(appUpdateControllerProvider, (_, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleState(next);
      });
    });
    return widget.child;
  }

  void _handleState(AppUpdateState next) {
    if (!widget.enabled) return;
    switch (next.phase) {
      case AppUpdatePhase.available:
        _clearUpdateSnackBar();
        final offer = next.offer;
        if (offer != null) unawaited(_presentOffer(offer));
        break;
      case AppUpdatePhase.starting:
      case AppUpdatePhase.downloading:
      case AppUpdatePhase.installing:
        _showProgress();
        break;
      case AppUpdatePhase.readyToInstall:
        if (_canPresentNow()) {
          _showReadyToInstall();
        } else {
          _schedulePresentationRetry();
        }
        break;
      case AppUpdatePhase.failed:
        _clearUpdateSnackBar();
        if (next.offer?.id == _presentedOfferId) _presentedOfferId = null;
        final errorCode = next.errorCode;
        if (errorCode != null &&
            errorCode != 'update_check_failed' &&
            errorCode != _lastFailureCode) {
          _lastFailureCode = errorCode;
          _showFailure();
        }
        break;
      case AppUpdatePhase.idle:
      case AppUpdatePhase.completed:
      case AppUpdatePhase.dismissed:
      case AppUpdatePhase.redirectedToStore:
        _clearUpdateSnackBar();
        break;
      case AppUpdatePhase.checking:
        break;
    }
  }

  Future<void> _presentOffer(AppUpdateOffer offer) async {
    if (_dialogOpen || _presentedOfferId == offer.id) return;
    if (!_canPresentNow()) {
      _schedulePresentationRetry();
      return;
    }
    _dialogOpen = true;
    _presentedOfferId = offer.id;
    AppUpdateDialogAction? action;
    var presentationFailed = false;
    try {
      action = await AppUpdateDialog.show(context, offer: offer);
    } catch (_) {
      presentationFailed = true;
    } finally {
      _dialogOpen = false;
    }
    if (!mounted) return;
    if (presentationFailed) {
      _presentedOfferId = null;
      _schedulePresentationRetry();
      return;
    }
    final controller = ref.read(appUpdateControllerProvider.notifier);
    if (action == AppUpdateDialogAction.update) {
      _presentedOfferId = null;
      unawaited(controller.startUpdate());
    } else if (!offer.isMandatory) {
      controller.dismissUpdate();
    } else {
      _presentedOfferId = null;
      _schedulePresentationRetry();
    }
  }

  bool _canPresentNow() {
    if (!mounted || !widget.enabled || _dialogOpen) return false;
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
      return false;
    }
    if (widget.presentationAllowed?.call() == false) return false;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return false;
    final rootNavigator = Navigator.maybeOf(context, rootNavigator: true);
    return rootNavigator == null || !rootNavigator.canPop();
  }

  void _schedulePresentationRetry() {
    if (!mounted || !widget.enabled) return;
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
      return;
    }
    if (_presentationRetry?.isActive ?? false) return;
    _presentationRetry = Timer(const Duration(milliseconds: 750), () {
      _presentationRetry = null;
      if (!mounted || !widget.enabled) return;
      _handleState(ref.read(appUpdateControllerProvider));
    });
  }

  void _showProgress() {
    if (_updateSnackBarController != null) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    _trackUpdateSnackBar(
      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(days: 1),
          content: Row(
            children: [
              const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(context.l10n.installingUpdate)),
            ],
          ),
        ),
      ),
      AppUpdatePhase.installing,
    );
  }

  void _showReadyToInstall() {
    if (_updateSnackBarController != null &&
        _updateSnackBarPhase == AppUpdatePhase.readyToInstall) {
      return;
    }
    _clearUpdateSnackBar();
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    _trackUpdateSnackBar(
      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(days: 1),
          content: Text(context.l10n.updateDownloadReadyMessage),
          action: SnackBarAction(
            label: context.l10n.restartToUpdate,
            onPressed: () {
              _clearUpdateSnackBar();
              unawaited(
                ref.read(appUpdateControllerProvider.notifier).completeUpdate(),
              );
            },
          ),
        ),
      ),
      AppUpdatePhase.readyToInstall,
    );
  }

  void _trackUpdateSnackBar(
    ScaffoldFeatureController<SnackBar, SnackBarClosedReason> controller,
    AppUpdatePhase phase,
  ) {
    _updateSnackBarController = controller;
    _updateSnackBarPhase = phase;
    unawaited(
      controller.closed.then((_) {
        if (identical(_updateSnackBarController, controller)) {
          _updateSnackBarController = null;
          _updateSnackBarPhase = null;
        }
      }),
    );
  }

  void _showFailure() {
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(context.l10n.updateFailed)));
  }

  void _clearUpdateSnackBar() {
    final controller = _updateSnackBarController;
    _updateSnackBarController = null;
    _updateSnackBarPhase = null;
    controller?.close();
  }
}
