import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../domain/app_update_models.dart';

enum AppUpdateDialogAction { update, later }

class AppUpdateDialog extends StatelessWidget {
  const AppUpdateDialog({super.key, required this.offer});

  final AppUpdateOffer offer;

  static Future<AppUpdateDialogAction?> show(
    BuildContext context, {
    required AppUpdateOffer offer,
  }) {
    return showDialog<AppUpdateDialogAction>(
      context: context,
      barrierDismissible: !offer.isMandatory,
      builder: (_) => AppUpdateDialog(offer: offer),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    final availableVersion = offer.availableVersion;
    return PopScope(
      canPop: !offer.isMandatory,
      child: AlertDialog(
        scrollable: true,
        icon: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          child: const Icon(Icons.system_update_alt_rounded),
        ),
        title: Text(strings.updateAvailableTitle, textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(strings.updateAvailableMessage, textAlign: TextAlign.center),
            if (availableVersion != null) ...[
              const SizedBox(height: 12),
              Text(
                strings.versionLabel(availableVersion),
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
            if (offer.isMandatory) ...[
              const SizedBox(height: 12),
              Text(
                strings.updateRequiredMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!offer.isMandatory)
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, AppUpdateDialogAction.later),
              child: Text(strings.later),
            ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, AppUpdateDialogAction.update),
            child: Text(strings.updateNow),
          ),
        ],
      ),
    );
  }
}
