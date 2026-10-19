import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/inline_animated_picker.dart';
import '../../../l10n/l10n.dart';
import '../application/notification_controller.dart';
import '../domain/notification_models.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  final _customMessage = TextEditingController();

  @override
  void initState() {
    super.initState();
    unawaited(
      Future.microtask(() async {
        await ref.read(notificationControllerProvider.notifier).initialize();
        if (mounted) {
          _customMessage.text =
              ref
                  .read(notificationControllerProvider)
                  .motivation
                  .customMessage ??
              '';
        }
      }),
    );
  }

  @override
  void dispose() {
    _customMessage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationControllerProvider);
    final controller = ref.read(notificationControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.m04NotificationsJobAlerts)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PermissionCard(state: state, controller: controller),
          const SizedBox(height: 20),
          Text(
            context.l10n.m04WorkAlerts,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (final category in const [
                  AlertCategory.tomorrowPreview,
                  AlertCategory.morningDigest,
                  AlertCategory.prepare,
                  AlertCategory.startsSoon,
                  AlertCategory.breakReminder,
                  AlertCategory.scheduledEnd,
                ])
                  _AlertCategorySetting(
                    category: category,
                    preference:
                        state.preferences[category] ??
                        AlertPreference.defaults(category),
                    busy: state.busy,
                    onChanged: controller.savePreference,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.visibility_off_outlined),
              title: Text(context.l10n.m04PrivateLockScreenText),
              subtitle: Text(context.l10n.m04HidesJobCustomerAndWorkplaceNames),
              value: _privateText(state.preferences),
              onChanged: state.busy
                  ? null
                  : controller.setPrivateLockScreenText,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.m04OptionalMotivation,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.m04CalmDailyMessage),
                    subtitle: Text(
                      context.l10n.m04OffByDefaultAndSuppressedNearImportant,
                    ),
                    value: state.motivation.enabled,
                    onChanged: (value) => controller.saveMotivation(
                      state.motivation.copyWith(enabled: value),
                    ),
                  ),
                  if (state.motivation.enabled) ...[
                    InlineAnimatedPicker<int>(
                      label: context.l10n.m04DeliveryTime,
                      value: state.motivation.deliveryTimeMinutes,
                      options: const [420, 480, 540],
                      optionLabel: (minute) =>
                          '${(minute ~/ 60).toString().padLeft(2, '0')}:00',
                      leading: const Icon(Icons.schedule_outlined),
                      onChanged: (value) {
                        controller.saveMotivation(
                          state.motivation.copyWith(deliveryTimeMinutes: value),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _customMessage,
                      maxLength: 120,
                      decoration: InputDecoration(
                        labelText: context.l10n.m04CustomMessageOptional,
                      ),
                      onSubmitted: (value) => controller.saveMotivation(
                        state.motivation.copyWith(customMessage: value.trim()),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bedtime_outlined),
              title: Text(context.l10n.m04QuietHours22000700),
              subtitle: Text(
                context.l10n.m04PreviewAndMotivationWaitTimeSensitiveWork,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(context.l10n.m04OfflineDelivery),
              subtitle: Text(context.l10n.m04NoInternetIsNeededOSBatteryRules),
            ),
          ),
        ],
      ),
    );
  }

  bool _privateText(Map<AlertCategory, AlertPreference> values) => values.values
      .where((item) => item.category != AlertCategory.motivation)
      .every((item) => item.privateLockScreenText);
}

class _AlertCategorySetting extends StatelessWidget {
  const _AlertCategorySetting({
    required this.category,
    required this.preference,
    required this.busy,
    required this.onChanged,
  });

  final AlertCategory category;
  final AlertPreference preference;
  final bool busy;
  final ValueChanged<AlertPreference> onChanged;

  @override
  Widget build(BuildContext context) {
    final choices = _timingChoices(category);
    final selected = category == AlertCategory.morningDigest
        ? preference.deliveryTimeMinutes
        : preference.offsetSeconds;
    return Column(
      children: [
        SwitchListTile(
          secondary: Icon(_icon(category)),
          title: Text(_label(context, category)),
          subtitle: category == AlertCategory.scheduledEnd
              ? Text(context.l10n.m04OnlyWhileWorkIsActive)
              : null,
          value: preference.enabled,
          onChanged: busy
              ? null
              : (enabled) => onChanged(preference.copyWith(enabled: enabled)),
        ),
        if (preference.enabled && choices.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: InlineAnimatedPicker<int>(
              label: category == AlertCategory.morningDigest
                  ? context.l10n.m04DigestTime
                  : context.l10n.m04HowEarly,
              value: choices.contains(selected!) ? selected : choices.first,
              options: choices,
              optionLabel: (value) => _timingLabel(context, category, value),
              leading: const Icon(Icons.schedule_outlined),
              enabled: !busy,
              onChanged: busy
                  ? (_) {}
                  : (value) {
                      onChanged(
                        category == AlertCategory.morningDigest
                            ? preference.copyWith(deliveryTimeMinutes: value)
                            : preference.copyWith(offsetSeconds: value),
                      );
                    },
            ),
          ),
        const Divider(height: 1),
      ],
    );
  }
}

List<int> _timingChoices(AlertCategory category) => switch (category) {
  AlertCategory.tomorrowPreview => const [43200, 86400, 172800],
  AlertCategory.morningDigest => const [360, 420, 480],
  AlertCategory.prepare => const [3600, 7200, 10800],
  AlertCategory.startsSoon => const [900, 1800, 3600],
  _ => const [],
};

String _timingLabel(BuildContext context, AlertCategory category, int value) {
  if (category == AlertCategory.morningDigest) {
    return '${(value ~/ 60).toString().padLeft(2, '0')}:'
        '${(value % 60).toString().padLeft(2, '0')}';
  }
  if (value < 3600) {
    return context.l10n.m04MinutesBefore(value ~/ 60);
  }
  final hours = value ~/ 3600;
  return context.l10n.m04HoursBefore(hours);
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({required this.state, required this.controller});
  final NotificationState state;
  final NotificationController controller;

  @override
  Widget build(BuildContext context) {
    final granted = state.permission == NotificationPermissionState.granted;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  granted
                      ? Icons.notifications_active
                      : Icons.notifications_off_outlined,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    granted
                        ? (context.l10n.m04NotificationsEnabled)
                        : (context.l10n.m04NotificationPermissionNeeded),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.m04ReminderStatus(
                state.pendingCount,
                state.attentionCount,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (!granted)
                  FilledButton.icon(
                    onPressed: state.busy
                        ? null
                        : () async {
                            final allowed = await controller
                                .requestPermission();
                            if (!context.mounted) return;
                            if (allowed) {
                              AppFeedback.success(
                                context,
                                context.l10n.m04NotificationsEnabledMessage,
                              );
                            } else {
                              AppFeedback.info(
                                context,
                                context.l10n.m04NotificationsDeniedMessage,
                              );
                            }
                          },
                    icon: const Icon(Icons.notifications_outlined),
                    label: Text(context.l10n.m04Enable),
                  ),
                OutlinedButton.icon(
                  onPressed: state.busy
                      ? null
                      : () async {
                          await controller.refreshPermissionAndRepair();
                          if (context.mounted) {
                            AppFeedback.success(
                              context,
                              context.l10n.m04ScheduleRepairedMessage,
                            );
                          }
                        },
                  icon: const Icon(Icons.sync),
                  label: Text(context.l10n.m04RepairSchedule),
                ),
                if (granted)
                  FilledButton.tonalIcon(
                    onPressed: state.busy
                        ? null
                        : () async {
                            try {
                              final sent = await controller
                                  .sendTestNotification();
                              if (!context.mounted) return;
                              if (sent) {
                                AppFeedback.success(
                                  context,
                                  Localizations.localeOf(
                                            context,
                                          ).languageCode ==
                                          'bn'
                                      ? 'Test notification পাঠানো হয়েছে।'
                                      : 'Test notification sent.',
                                );
                              } else {
                                AppFeedback.info(
                                  context,
                                  context.l10n.m04NotificationPermissionNeeded,
                                );
                              }
                            } catch (_) {
                              if (context.mounted) {
                                AppFeedback.error(
                                  context,
                                  Localizations.localeOf(
                                            context,
                                          ).languageCode ==
                                          'bn'
                                      ? 'Test notification পাঠানো যায়নি।'
                                      : 'Test notification failed.',
                                );
                              }
                            }
                          },
                    icon: const Icon(Icons.notification_add_outlined),
                    label: Text(
                      Localizations.localeOf(context).languageCode == 'bn'
                          ? 'টেস্ট নোটিফিকেশন'
                          : 'Test notification',
                    ),
                  ),
                if (state.permission == NotificationPermissionState.denied)
                  TextButton(
                    onPressed: controller.openSystemSettings,
                    child: Text(context.l10n.m04SystemSettings),
                  ),
              ],
            ),
            if (state.busy) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}

String _label(BuildContext context, AlertCategory category) =>
    switch (category) {
      AlertCategory.tomorrowPreview => context.l10n.m04PreviousDayPreview,
      AlertCategory.morningDigest => context.l10n.m04700MorningDigest,
      AlertCategory.prepare => context.l10n.m04PreparationAlert,
      AlertCategory.startsSoon => context.l10n.m04StartsSoon,
      AlertCategory.breakReminder => context.l10n.m04ActiveWorkBreak,
      AlertCategory.scheduledEnd => context.l10n.m04ScheduledFinish,
      AlertCategory.motivation => context.l10n.m04Motivation,
    };

IconData _icon(AlertCategory category) => switch (category) {
  AlertCategory.tomorrowPreview => Icons.event_outlined,
  AlertCategory.morningDigest => Icons.wb_sunny_outlined,
  AlertCategory.prepare => Icons.inventory_2_outlined,
  AlertCategory.startsSoon => Icons.alarm_outlined,
  AlertCategory.breakReminder => Icons.free_breakfast_outlined,
  AlertCategory.scheduledEnd => Icons.timer_off_outlined,
  AlertCategory.motivation => Icons.spa_outlined,
};
