import 'dart:async';

import 'package:flutter/material.dart';

enum AppFeedbackType { success, error, info }

/// Consistent, accessible action feedback that survives normal route changes.
abstract final class AppFeedback {
  static const _noDescendantScaffoldsMessage =
      'ScaffoldMessenger.showSnackBar was called, but there are currently no '
      'descendant Scaffolds to present to.';

  static void success(BuildContext context, String message) =>
      show(context, message, type: AppFeedbackType.success);

  static void error(BuildContext context, String message) =>
      show(context, message, type: AppFeedbackType.error);

  static void info(BuildContext context, String message) =>
      show(context, message, type: AppFeedbackType.info);

  static void show(
    BuildContext context,
    String message, {
    AppFeedbackType type = AppFeedbackType.info,
  }) {
    final colors = Theme.of(context).colorScheme;
    final (icon, background, foreground) = switch (type) {
      AppFeedbackType.success => (
        Icons.check_circle_outline_rounded,
        colors.primaryContainer,
        colors.onPrimaryContainer,
      ),
      AppFeedbackType.error => (
        Icons.error_outline_rounded,
        colors.errorContainer,
        colors.onErrorContainer,
      ),
      AppFeedbackType.info => (
        Icons.info_outline_rounded,
        colors.secondaryContainer,
        colors.onSecondaryContainer,
      ),
    };
    final messenger = ScaffoldMessenger.of(context);
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: background,
      content: Row(
        children: [
          Icon(icon, color: foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: foreground)),
          ),
        ],
      ),
    );
    unawaited(_showAfterCurrentFrame(messenger, snackBar));
  }

  static Future<void> _showAfterCurrentFrame(
    ScaffoldMessengerState messenger,
    SnackBar snackBar,
  ) async {
    await WidgetsBinding.instance.endOfFrame;
    if (!messenger.mounted) return;

    try {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    } on AssertionError catch (error, stackTrace) {
      if (!error.toString().contains(_noDescendantScaffoldsMessage)) {
        Error.throwWithStackTrace(error, stackTrace);
      }
    }
  }
}
