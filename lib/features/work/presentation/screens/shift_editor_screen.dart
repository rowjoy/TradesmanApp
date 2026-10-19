import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/money/money.dart';
import '../../../../core/time/schedule_window.dart';
import '../../../../core/time/time_zone_options.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/inline_animated_picker.dart';
import '../../../../l10n/l10n.dart';
import '../../../notifications/application/notification_controller.dart';
import '../../../notifications/presentation/notification_permission_prompt.dart';
import '../../../notifications/presentation/work_reminder_options.dart';
import '../../../onboarding/presentation/controllers/onboarding_controller.dart';
import '../../../proof/presentation/controllers/audit_controller.dart';
import '../../data/work_repository.dart';
import '../../domain/work_models.dart';
import '../controllers/work_controller.dart';
import '../widgets/schedule_editor.dart';

class ShiftEditorScreen extends ConsumerStatefulWidget {
  const ShiftEditorScreen({super.key, this.shiftId});
  final String? shiftId;

  @override
  ConsumerState<ShiftEditorScreen> createState() => _ShiftEditorScreenState();
}

class _ShiftEditorScreenState extends ConsumerState<ShiftEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _rate = TextEditingController();
  final _breakMinutes = TextEditingController(text: '0');
  final _notes = TextEditingController();
  late final ScheduleEditorController _schedule;
  Timer? _draftTimer;
  String? _employerId;
  String? _workplaceId;
  bool _breakPaid = false;
  bool _reminders = true;
  bool _useGlobalReminderDefaults = true;
  int _previewSeconds = 86400;
  int _prepareSeconds = 7200;
  int _startSeconds = 1800;
  bool _morningReminder = true;
  bool _endReminder = true;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _schedule = ScheduleEditorController();
    for (final controller in [_title, _rate, _breakMinutes, _notes]) {
      controller.addListener(_queueDraft);
    }
    _load();
  }

  Future<void> _load() async {
    final deviceTimeZone = await deviceTimeZoneIdentifier();
    final repository = ref.read(workRepositoryProvider);
    final shift = widget.shiftId == null
        ? null
        : await repository.shift(widget.shiftId!);
    if (shift != null) {
      _title.text = shift.title;
      final currency = ref.read(currentProfileProvider)?.currencyCode ?? 'GBP';
      _rate.text = shift.hourlyRateMinor == null
          ? ''
          : AppFormatters.minorInput(
              shift.hourlyRateMinor!,
              currencyCode: currency,
            );
      _breakMinutes.text = shift.breakMinutes.toString();
      _notes.text = shift.notes ?? '';
      _employerId = shift.employerId;
      _workplaceId = shift.workplaceId;
      _breakPaid = shift.breakIsPaid;
      _reminders = shift.remindersEnabled;
      _useGlobalReminderDefaults = shift.reminderUsesGlobalDefaults;
      _previewSeconds = shift.reminderPreviewOffsetSeconds;
      _prepareSeconds = shift.reminderPrepareOffsetSeconds;
      _startSeconds = shift.reminderStartOffsetSeconds;
      _morningReminder = shift.reminderMorningEnabled;
      _endReminder = shift.reminderEndEnabled;
      _schedule.replace(shift.schedule);
    } else {
      final draft = await repository.loadDraft('shift');
      if (draft != null) _restoreDraft(draft);
    }
    if (!mounted) return;
    _schedule.useDeviceTimeZone(deviceTimeZone);
    setState(() => _loading = false);
  }

  void _restoreDraft(Map<String, Object?> draft) {
    _title.text = draft['title'] as String? ?? '';
    _rate.text = draft['rate'] as String? ?? '';
    _breakMinutes.text = draft['breakMinutes'] as String? ?? '0';
    _notes.text = draft['notes'] as String? ?? '';
    _employerId = draft['employerId'] as String?;
    _workplaceId = draft['workplaceId'] as String?;
    _breakPaid = draft['breakPaid'] as bool? ?? false;
    _reminders = draft['reminders'] as bool? ?? true;
    _useGlobalReminderDefaults =
        draft['useGlobalReminderDefaults'] as bool? ?? true;
    _previewSeconds = draft['previewSeconds'] as int? ?? 86400;
    _prepareSeconds = draft['prepareSeconds'] as int? ?? 7200;
    _startSeconds = draft['startSeconds'] as int? ?? 1800;
    _morningReminder = draft['morningReminder'] as bool? ?? true;
    _endReminder = draft['endReminder'] as bool? ?? true;
    final start = DateTime.tryParse(draft['startLocal'] as String? ?? '');
    final end = DateTime.tryParse(draft['endLocal'] as String? ?? '');
    if (start != null && end != null) {
      _schedule.replace(
        ScheduleWindow.fromLocal(
          startLocal: start,
          endLocal: end,
          ianaTimeZone: draft['ianaTimeZone'] as String? ?? 'Etc/UTC',
          startOffsetMinutes: draft['startOffsetMinutes'] as int? ?? 60,
          endOffsetMinutes: draft['endOffsetMinutes'] as int? ?? 60,
        ),
      );
    }
  }

  void _queueDraft() {
    if (_loading || _saving) return;
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 500), _saveDraft);
  }

  Future<void> _saveDraft() => ref
      .read(workRepositoryProvider)
      .saveDraft(
        draftType: 'shift',
        linkedEntityId: widget.shiftId,
        payload: {
          'title': _title.text,
          'rate': _rate.text,
          'breakMinutes': _breakMinutes.text,
          'notes': _notes.text,
          'employerId': _employerId,
          'workplaceId': _workplaceId,
          'breakPaid': _breakPaid,
          'reminders': _reminders,
          'useGlobalReminderDefaults': _useGlobalReminderDefaults,
          'previewSeconds': _previewSeconds,
          'prepareSeconds': _prepareSeconds,
          'startSeconds': _startSeconds,
          'morningReminder': _morningReminder,
          'endReminder': _endReminder,
          'startLocal': _schedule.startLocal.toIso8601String(),
          'endLocal': _schedule.endLocal.toIso8601String(),
          'ianaTimeZone': _schedule.ianaTimeZone,
          'startOffsetMinutes': _schedule.startOffsetMinutes,
          'endOffsetMinutes': _schedule.endOffsetMinutes,
        },
      );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final schedule = _schedule.window;
    if (!schedule.isValid) {
      AppFeedback.error(context, context.l10n.invalidSchedule);
      return;
    }
    setState(() => _saving = true);
    _draftTimer?.cancel();
    try {
      final currency = ref.read(currentProfileProvider)?.currencyCode ?? 'GBP';
      await ref
          .read(workRepositoryProvider)
          .saveShift(
            id: widget.shiftId,
            employerId: _employerId,
            workplaceId: _workplaceId,
            title: _title.text,
            schedule: schedule,
            hourlyRateMinor: _rate.text.trim().isEmpty
                ? null
                : Money.tryParse(
                    _rate.text.trim(),
                    currencyCode: currency,
                  )?.minorUnits,
            remindersEnabled: _reminders,
            reminderUsesGlobalDefaults: _useGlobalReminderDefaults,
            reminderPreviewOffsetSeconds: _previewSeconds,
            reminderPrepareOffsetSeconds: _prepareSeconds,
            reminderStartOffsetSeconds: _startSeconds,
            reminderMorningEnabled: _morningReminder,
            reminderEndEnabled: _endReminder,
            breakMinutes: int.tryParse(_breakMinutes.text) ?? 0,
            breakIsPaid: _breakPaid,
            notes: _notes.text,
          );
      invalidateWorkData(ref, flow: WorkFlow.worker);
      ref.invalidate(auditEventsProvider);
      final showPermissionPrompt = await ref
          .read(notificationControllerProvider.notifier)
          .workSaved(remindersEnabled: _reminders, hasSchedule: true);
      if (mounted) {
        if (showPermissionPrompt) {
          await showNotificationPrePermissionDialog(context, ref);
          if (!mounted) return;
        }
        AppFeedback.success(context, context.l10n.savedOnDevice);
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        AppFeedback.error(context, context.l10n.saveFailed);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    _schedule.dispose();
    for (final controller in [_title, _rate, _breakMinutes, _notes]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employers = ref.watch(employersProvider);
    final workplaces = ref.watch(workplacesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.shiftId == null
              ? context.l10n.newShift
              : context.l10n.editShift,
        ),
        actions: [
          IconButton(
            tooltip: context.l10n.saveDraft,
            onPressed: () async {
              await _saveDraft();
              if (!context.mounted) return;
              AppFeedback.info(context, context.l10n.draftSaved);
            },
            icon: const Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _title,
                    decoration: InputDecoration(
                      labelText: '${context.l10n.shiftTitleLabel} *',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? context.l10n.requiredField
                        : null,
                  ),
                  const SizedBox(height: 14),
                  employers.when(
                    data: (items) => InlineAnimatedPicker<String>(
                      label: context.l10n.employerOptional,
                      value: _employerId ?? '',
                      options: ['', ...items.map((item) => item.id)],
                      optionLabel: (value) {
                        if (value.isEmpty) return context.l10n.notStarted;
                        for (final item in items) {
                          if (item.id == value) return item.name;
                        }
                        return context.l10n.notStarted;
                      },
                      leading: const Icon(Icons.business_outlined),
                      onChanged: (value) {
                        setState(() {
                          _employerId = value.isEmpty ? null : value;
                          _workplaceId = null;
                        });
                        _queueDraft();
                      },
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => Text(context.l10n.peopleLoadFailed),
                  ),
                  const SizedBox(height: 14),
                  workplaces.when(
                    data: (items) {
                      final visible = _employerId == null
                          ? items
                          : items
                                .where((item) => item.employerId == _employerId)
                                .toList();
                      final selected =
                          visible.any((item) => item.id == _workplaceId)
                          ? _workplaceId!
                          : '';
                      return InlineAnimatedPicker<String>(
                        label: context.l10n.workplaceOptional,
                        value: selected,
                        options: ['', ...visible.map((item) => item.id)],
                        optionLabel: (value) {
                          if (value.isEmpty) return context.l10n.notStarted;
                          for (final item in visible) {
                            if (item.id == value) return item.name;
                          }
                          return context.l10n.notStarted;
                        },
                        leading: const Icon(Icons.location_on_outlined),
                        onChanged: (value) {
                          setState(
                            () => _workplaceId = value.isEmpty ? null : value,
                          );
                          _queueDraft();
                        },
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => Text(context.l10n.peopleLoadFailed),
                  ),
                  const SizedBox(height: 14),
                  ScheduleEditor(
                    controller: _schedule,
                    onChanged: _queueDraft,
                    deviceTimeZoneOnly: true,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _rate,
                    decoration: InputDecoration(
                      labelText: context.l10n.hourlyRateOptional,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _breakMinutes,
                    decoration: InputDecoration(
                      labelText: context.l10n.breakMinutes,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final parsed = int.tryParse(value ?? '');
                      return parsed == null || parsed < 0
                          ? context.l10n.invalidNumber
                          : null;
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.paidBreak),
                    value: _breakPaid,
                    onChanged: (value) {
                      setState(() => _breakPaid = value);
                      _queueDraft();
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.remindersEnabled),
                    subtitle: Text(context.l10n.reminderIntentNote),
                    value: _reminders,
                    onChanged: (value) {
                      setState(() => _reminders = value);
                      _queueDraft();
                    },
                  ),
                  if (_reminders) ...[
                    WorkReminderOptions(
                      previewSeconds: _previewSeconds,
                      prepareSeconds: _prepareSeconds,
                      startSeconds: _startSeconds,
                      morningEnabled: _morningReminder,
                      endEnabled: _endReminder,
                      usesGlobalDefaults: _useGlobalReminderDefaults,
                      onPreviewChanged: (value) {
                        setState(() => _previewSeconds = value);
                        _queueDraft();
                      },
                      onPrepareChanged: (value) {
                        setState(() => _prepareSeconds = value);
                        _queueDraft();
                      },
                      onStartChanged: (value) {
                        setState(() => _startSeconds = value);
                        _queueDraft();
                      },
                      onMorningChanged: (value) {
                        setState(() => _morningReminder = value);
                        _queueDraft();
                      },
                      onEndChanged: (value) {
                        setState(() => _endReminder = value);
                        _queueDraft();
                      },
                      onUsesGlobalDefaultsChanged: (value) {
                        setState(() => _useGlobalReminderDefaults = value);
                        _queueDraft();
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _notes,
                    decoration: InputDecoration(
                      labelText: context.l10n.notesLabel,
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(context.l10n.saveShift),
                  ),
                ],
              ),
            ),
    );
  }
}
