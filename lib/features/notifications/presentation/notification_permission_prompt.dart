import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../application/notification_controller.dart';

Future<void> showNotificationPrePermissionDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final enable = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.notifications_active_outlined),
      title: Text(context.l10n.m04RemindYouAboutWork),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.m04WorkProofCanScheduleJobAndShiftAlerts),
          const SizedBox(height: 14),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text(context.l10n.m04WorkStartsSoon),
              subtitle: Text(context.l10n.m04WorkAndCustomerNamesStayPrivateOn),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(context.l10n.m04NotNow),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(context.l10n.m04Enable),
        ),
      ],
    ),
  );
  if (enable == true) {
    await ref.read(notificationControllerProvider.notifier).requestPermission();
  } else {
    await ref.read(notificationControllerProvider.notifier).deferPermission();
  }
}
