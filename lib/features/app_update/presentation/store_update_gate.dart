import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upgrader/upgrader.dart';

final appStoreUpgraderProvider = Provider<Upgrader>((ref) {
  final upgrader = Upgrader(
    checkOnResume: true,
    durationUntilAlertAgain: Duration.zero,
  );
  ref.onDispose(upgrader.dispose);
  return upgrader;
});

class ForcedUpgradeAlert extends UpgradeAlert {
  ForcedUpgradeAlert({
    super.key,
    required Upgrader upgrader,
    super.navigatorKey,
    super.child,
  }) : super(
         upgrader: upgrader,
         showIgnore: false,
         showLater: false,
         barrierDismissible: false,
         shouldPopScope: _neverPop,
       );

  static bool _neverPop() => false;

  @override
  ForcedUpgradeAlertState createState() => ForcedUpgradeAlertState();
}

class ForcedUpgradeAlertState extends UpgradeAlertState {
  @override
  void onUserUpdated(BuildContext context, bool shouldPop) {
    super.onUserUpdated(context, false);
  }

  @override
  void showTheDialog({
    Key? key,
    required BuildContext context,
    required String? title,
    required String message,
    required String? releaseNotes,
    required bool barrierDismissible,
    required UpgraderMessages messages,
  }) {
    if (!context.mounted) {
      displayed = false;
      return;
    }

    unawaited(widget.upgrader.saveLastAlerted());
    final isCupertinoApp =
        context.findAncestorWidgetOfExactType<CupertinoApp>() != null;
    Widget dialogBuilder(BuildContext context) => PopScope(
      canPop: onCanPop(),
      child: alertDialog(
        key,
        title ?? '',
        message,
        releaseNotes,
        context,
        widget.dialogStyle == UpgradeDialogStyle.cupertino,
        messages,
      ),
    );

    final Future<void> dialogClosed;
    if (isCupertinoApp) {
      dialogClosed = showCupertinoDialog<void>(
        barrierDismissible: barrierDismissible,
        context: context,
        builder: dialogBuilder,
      );
    } else {
      dialogClosed = showDialog<void>(
        barrierDismissible: barrierDismissible,
        context: context,
        builder: dialogBuilder,
      );
    }
    unawaited(dialogClosed.whenComplete(_restoreRequiredDialog));
  }

  void _restoreRequiredDialog() {
    if (!mounted) return;
    displayed = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || displayed || !widget.upgrader.shouldDisplayUpgrade()) {
        return;
      }
      final navigatorContext = widget.navigatorKey?.currentContext;
      checkVersion(context: navigatorContext ?? context);
    });
  }
}
