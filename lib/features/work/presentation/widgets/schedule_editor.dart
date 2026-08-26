import 'package:flutter/material.dart';

import '../../../../core/time/schedule_window.dart';
import '../../../../core/time/time_zone_options.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/inline_animated_picker.dart';
import '../../../../l10n/l10n.dart';

class ScheduleEditorController extends ChangeNotifier {
  ScheduleEditorController({ScheduleWindow? initial}) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    startLocal =
        initial?.startLocal ??
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9);
    endLocal =
        initial?.endLocal ??
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 17);
    ianaTimeZone = initial?.ianaTimeZone ?? 'Europe/London';
    startOffsetMinutes =
        initial?.startOffsetMinutes ??
        suggestedOffsetMinutes(ianaTimeZone, startLocal);
    endOffsetMinutes =
        initial?.endOffsetMinutes ??
        suggestedOffsetMinutes(ianaTimeZone, endLocal);
  }

  late DateTime startLocal;
  late DateTime endLocal;
  late String ianaTimeZone;
  late int startOffsetMinutes;
  late int endOffsetMinutes;
  bool _usesDeviceTimeZone = false;

  ScheduleWindow get window => ScheduleWindow.fromLocal(
    startLocal: startLocal,
    endLocal: endLocal,
    ianaTimeZone: ianaTimeZone,
    startOffsetMinutes: startOffsetMinutes,
    endOffsetMinutes: endOffsetMinutes,
  );

  void replace(ScheduleWindow value) {
    startLocal = value.startLocal;
    endLocal = value.endLocal;
    ianaTimeZone = value.ianaTimeZone;
    startOffsetMinutes = value.startOffsetMinutes;
    endOffsetMinutes = value.endOffsetMinutes;
    notifyListeners();
  }

  void setStart(DateTime value) {
    final previousDuration = endLocal.difference(startLocal);
    startLocal = value;
    startOffsetMinutes = _offsetFor(startLocal);
    if (!endLocal.isAfter(startLocal)) {
      endLocal = startLocal.add(
        previousDuration.isNegative
            ? const Duration(hours: 8)
            : previousDuration,
      );
      endOffsetMinutes = _offsetFor(endLocal);
    }
    notifyListeners();
  }

  void setEnd(DateTime value) {
    endLocal = value;
    endOffsetMinutes = _offsetFor(endLocal);
    notifyListeners();
  }

  void setZone(String value) {
    _usesDeviceTimeZone = false;
    ianaTimeZone = value;
    startOffsetMinutes = suggestedOffsetMinutes(value, startLocal);
    endOffsetMinutes = suggestedOffsetMinutes(value, endLocal);
    notifyListeners();
  }

  void setStartOffset(int value) {
    startOffsetMinutes = value;
    notifyListeners();
  }

  void setEndOffset(int value) {
    endOffsetMinutes = value;
    notifyListeners();
  }

  void useDeviceTimeZone(String identifier) {
    _usesDeviceTimeZone = true;
    ianaTimeZone = identifier;
    startOffsetMinutes = deviceOffsetMinutes(startLocal);
    endOffsetMinutes = deviceOffsetMinutes(endLocal);
    notifyListeners();
  }

  int _offsetFor(DateTime value) => _usesDeviceTimeZone
      ? deviceOffsetMinutes(value)
      : suggestedOffsetMinutes(ianaTimeZone, value);
}

class ScheduleEditor extends StatefulWidget {
  const ScheduleEditor({
    super.key,
    required this.controller,
    this.onChanged,
    this.deviceTimeZoneOnly = false,
  });
  final ScheduleEditorController controller;
  final VoidCallback? onChanged;
  final bool deviceTimeZoneOnly;

  @override
  State<ScheduleEditor> createState() => _ScheduleEditorState();
}

class _ScheduleEditorState extends State<ScheduleEditor> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void didUpdateWidget(covariant ScheduleEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_changed);
      widget.controller.addListener(_changed);
    }
  }

  void _changed() {
    if (mounted) setState(() {});
    widget.onChanged?.call();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  Future<void> _pickDate({required bool start}) async {
    final current = start
        ? widget.controller.startLocal
        : widget.controller.endLocal;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    final value = DateTime(
      picked.year,
      picked.month,
      picked.day,
      current.hour,
      current.minute,
    );
    start ? widget.controller.setStart(value) : widget.controller.setEnd(value);
  }

  Future<void> _pickTime({required bool start}) async {
    final current = start
        ? widget.controller.startLocal
        : widget.controller.endLocal;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (picked == null) return;
    final value = DateTime(
      current.year,
      current.month,
      current.day,
      picked.hour,
      picked.minute,
    );
    start ? widget.controller.setStart(value) : widget.controller.setEnd(value);
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.window;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.scheduleTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _DateTimeRow(
              label: context.l10n.startLabel,
              value: widget.controller.startLocal,
              onDate: () => _pickDate(start: true),
              onTime: () => _pickTime(start: true),
            ),
            const SizedBox(height: 12),
            _DateTimeRow(
              label: context.l10n.endLabel,
              value: widget.controller.endLocal,
              onDate: () => _pickDate(start: false),
              onTime: () => _pickTime(start: false),
            ),
            const SizedBox(height: 14),
            if (widget.deviceTimeZoneOnly)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.public_outlined),
                title: Text(context.l10n.timeZoneLabel),
                subtitle: Text(
                  '${widget.controller.ianaTimeZone} · '
                  '${_offsetLabel(widget.controller.startOffsetMinutes)}'
                  '${widget.controller.startOffsetMinutes == widget.controller.endOffsetMinutes ? '' : ' → ${_offsetLabel(widget.controller.endOffsetMinutes)}'}',
                ),
              )
            else ...[
              InlineAnimatedPicker<String>(
                key: ValueKey('zone-${widget.controller.ianaTimeZone}'),
                label: context.l10n.timeZoneLabel,
                value: widget.controller.ianaTimeZone,
                options: supportedTimeZones
                    .map((zone) => zone.ianaName)
                    .toList(),
                optionLabel: (value) {
                  for (final zone in supportedTimeZones) {
                    if (zone.ianaName == value) return zone.label;
                  }
                  return value;
                },
                leading: const Icon(Icons.public_outlined),
                onChanged: widget.controller.setZone,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _OffsetField(
                      label: context.l10n.startUtcOffset,
                      value: widget.controller.startOffsetMinutes,
                      onChanged: widget.controller.setStartOffset,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _OffsetField(
                      label: context.l10n.endUtcOffset,
                      value: widget.controller.endOffsetMinutes,
                      onChanged: widget.controller.setEndOffset,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.timelapse, size: 18),
                  label: Text(AppFormatters.duration(value.elapsed)),
                ),
                if (value.crossesLocalDate)
                  Chip(
                    avatar: const Icon(Icons.nights_stay_outlined, size: 18),
                    label: Text(context.l10n.overnightLabel),
                  ),
                if (!value.isValid)
                  Chip(
                    avatar: const Icon(Icons.error_outline, size: 18),
                    label: Text(context.l10n.invalidSchedule),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTimeRow extends StatelessWidget {
  const _DateTimeRow({
    required this.label,
    required this.value,
    required this.onDate,
    required this.onTime,
  });
  final String label;
  final DateTime value;
  final VoidCallback onDate;
  final VoidCallback onTime;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onDate,
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: Text(AppFormatters.date(value)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onTime,
              icon: const Icon(Icons.schedule, size: 18),
              label: Text(AppFormatters.time(value)),
            ),
          ),
        ],
      ),
    ],
  );
}

class _OffsetField extends StatelessWidget {
  const _OffsetField({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = <int>{
      for (var minutes = -720; minutes <= 840; minutes += 30) minutes,
      value,
    }.toList()..sort();
    return InlineAnimatedPicker<int>(
      key: ValueKey('$label-$value'),
      label: label,
      value: value,
      options: options,
      optionLabel: _offsetLabel,
      leading: const Icon(Icons.schedule_outlined),
      maxExpandedHeight: 260,
      onChanged: onChanged,
    );
  }
}

String _offsetLabel(int minutes) {
  final sign = minutes < 0 ? '−' : '+';
  final absolute = minutes.abs();
  return 'UTC$sign${(absolute ~/ 60).toString().padLeft(2, '0')}:${(absolute % 60).toString().padLeft(2, '0')}';
}
