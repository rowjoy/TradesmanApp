import 'package:flutter/material.dart';

import '../../../core/widgets/inline_animated_picker.dart';
import '../../../l10n/l10n.dart';

class WorkReminderOptions extends StatelessWidget {
  const WorkReminderOptions({
    super.key,
    required this.previewSeconds,
    required this.prepareSeconds,
    required this.startSeconds,
    required this.morningEnabled,
    required this.endEnabled,
    required this.usesGlobalDefaults,
    required this.onPreviewChanged,
    required this.onPrepareChanged,
    required this.onStartChanged,
    required this.onMorningChanged,
    required this.onEndChanged,
    required this.onUsesGlobalDefaultsChanged,
  });

  final int previewSeconds;
  final int prepareSeconds;
  final int startSeconds;
  final bool morningEnabled;
  final bool endEnabled;
  final bool usesGlobalDefaults;
  final ValueChanged<int> onPreviewChanged;
  final ValueChanged<int> onPrepareChanged;
  final ValueChanged<int> onStartChanged;
  final ValueChanged<bool> onMorningChanged;
  final ValueChanged<bool> onEndChanged;
  final ValueChanged<bool> onUsesGlobalDefaultsChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        leading: const Icon(Icons.tune_outlined),
        title: Text(context.l10n.m04ReminderDetails),
        subtitle: Text(context.l10n.m04DefaultsAreReadyChangeOnlyIfNeeded),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.l10n.m04UseAppDefaults),
            subtitle: Text(context.l10n.m04TimingChangesInSettingsWillApplyTo),
            value: usesGlobalDefaults,
            onChanged: onUsesGlobalDefaultsChanged,
          ),
          if (!usesGlobalDefaults) ...[
            _OffsetField(
              label: context.l10n.m04PreviousDayPreview,
              value: previewSeconds,
              values: const [43200, 86400, 172800],
              labels: [
                context.l10n.m04HoursBefore(12),
                context.l10n.m04HoursBefore(24),
                context.l10n.m04HoursBefore(48),
              ],
              onChanged: onPreviewChanged,
            ),
            _OffsetField(
              label: context.l10n.m04PreparationAlert,
              value: prepareSeconds,
              values: const [3600, 7200, 10800],
              labels: [
                context.l10n.m04HoursBefore(1),
                context.l10n.m04HoursBefore(2),
                context.l10n.m04HoursBefore(3),
              ],
              onChanged: onPrepareChanged,
            ),
            _OffsetField(
              label: context.l10n.m04StartsSoonAlert,
              value: startSeconds,
              values: const [900, 1800, 3600],
              labels: [
                context.l10n.m04MinutesBefore(15),
                context.l10n.m04MinutesBefore(30),
                context.l10n.m04HoursBefore(1),
              ],
              onChanged: onStartChanged,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.m04700MorningDigest),
              value: morningEnabled,
              onChanged: onMorningChanged,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.m04EndAlertForActiveWork),
              subtitle: Text(context.l10n.m04OnlyShownAfterClockIn),
              value: endEnabled,
              onChanged: onEndChanged,
            ),
          ],
        ],
      ),
    );
  }
}

class _OffsetField extends StatelessWidget {
  const _OffsetField({
    required this.label,
    required this.value,
    required this.values,
    required this.labels,
    required this.onChanged,
  });
  final String label;
  final int value;
  final List<int> values;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => InlineAnimatedPicker<int>(
    label: label,
    value: values.contains(value) ? value : values.first,
    options: values,
    optionLabel: (value) => labels[values.indexOf(value)],
    leading: const Icon(Icons.schedule_outlined),
    onChanged: onChanged,
  );
}
