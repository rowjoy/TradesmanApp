import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tradesman_manager/features/work/domain/work_models.dart';

import '../../core/money/money.dart';
import '../../core/router/app_router.dart';
import '../../core/time/schedule_window.dart';
import '../../core/time/time_zone_options.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/inline_animated_picker.dart';
import '../../l10n/l10n.dart';
import '../customers/customer_model.dart';
import '../customers/customer_provider.dart';
import '../money/presentation/controllers/money_summary_controller.dart';
import '../notifications/application/notification_controller.dart';
import '../notifications/presentation/notification_permission_prompt.dart';
import '../notifications/presentation/work_reminder_options.dart';
import '../onboarding/presentation/controllers/onboarding_controller.dart';
import '../proof/presentation/controllers/audit_controller.dart';
import '../showcase/data/showcase_repository.dart';
import '../showcase/presentation/app_showcase.dart';
import '../work/data/work_repository.dart';
import '../work/presentation/controllers/work_controller.dart';
import '../work/presentation/widgets/schedule_editor.dart';
import 'job_model.dart';
import 'job_provider.dart';

class AddJobScreen extends ConsumerStatefulWidget {
  const AddJobScreen({super.key, this.jobId});
  final String? jobId;

  @override
  ConsumerState<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends ConsumerState<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerGuideKey = GlobalKey();
  final _detailsGuideKey = GlobalKey();
  final _scheduleGuideKey = GlobalKey();
  final _pricingGuideKey = GlobalKey();
  final _saveGuideKey = GlobalKey();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _address = TextEditingController();
  final _rate = TextEditingController(text: '25');
  final _fixedPrice = TextEditingController();
  final _notes = TextEditingController();
  late final ScheduleEditorController _schedule;
  Timer? _draftTimer;
  Job? _existing;
  String? _customerId;
  String? _serviceId;
  PricingType _pricingType = PricingType.hourly;
  JobStatus _status = JobStatus.scheduled;
  bool _reminders = true;
  bool _useGlobalReminderDefaults = true;
  int _previewSeconds = 86400;
  int _prepareSeconds = 7200;
  int _startSeconds = 1800;
  bool _morningReminder = true;
  bool _endReminder = true;
  bool _loading = true;
  bool _saving = false;
  bool _guideQueued = false;

  @override
  void initState() {
    super.initState();
    _schedule = ScheduleEditorController();
    for (final controller in [_title, _description, _address, _rate, _fixedPrice, _notes]) {
      controller.addListener(_queueDraft);
    }
    _load();
  }

  Future<void> _load() async {
    final deviceTimeZone = await deviceTimeZoneIdentifier();
    if (widget.jobId != null) {
      _existing = await ref.read(jobRepositoryProvider).getById(widget.jobId!);
      final job = _existing;
      if (job != null) {
        final currency = ref.read(currentProfileProvider)?.currencyCode ?? 'GBP';
        _title.text = job.title;
        _description.text = job.description ?? '';
        _address.text = job.address ?? '';
        _rate.text = job.hourlyRateMinor == null ? '' : AppFormatters.minorInput(job.hourlyRateMinor!, currencyCode: currency);
        _fixedPrice.text = job.fixedPriceMinor == null ? '' : AppFormatters.minorInput(job.fixedPriceMinor!, currencyCode: currency);
        _notes.text = job.notes ?? '';
        _customerId = job.customerId;
        _serviceId = job.serviceId;
        _pricingType = job.pricingType;
        _status = job.status;
        _reminders = job.remindersEnabled;
        _useGlobalReminderDefaults = job.reminderUsesGlobalDefaults;
        _previewSeconds = job.reminderPreviewOffsetSeconds;
        _prepareSeconds = job.reminderPrepareOffsetSeconds;
        _startSeconds = job.reminderStartOffsetSeconds;
        _morningReminder = job.reminderMorningEnabled;
        _endReminder = job.reminderEndEnabled;
        if (job.schedule != null) _schedule.replace(job.schedule!);
      }
    } else {
      final draft = await ref.read(workRepositoryProvider).loadDraft('job');
      if (draft != null) _restoreDraft(draft);
    }
    if (!mounted) return;
    _schedule.useDeviceTimeZone(deviceTimeZone);
    setState(() => _loading = false);
    _queueGuide();
  }

  void _queueGuide() {
    if (_guideQueued) return;
    _guideQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _guideQueued = false;
      if (!mounted || _loading) return;
      final repository = ref.read(showcaseRepositoryProvider);
      if (await repository.isScreenGuideCompleted('job_editor')) return;
      if (!mounted) return;
      final started = AppShowcaseCoordinator.instance.start(
        keys: [_customerGuideKey, _detailsGuideKey, _scheduleGuideKey, _pricingGuideKey, _saveGuideKey],
        onComplete: () => repository.completeScreenGuide('job_editor'),
      );
      if (!started) {
        Future<void>.delayed(const Duration(milliseconds: 350), _queueGuide);
      }
    });
  }

  void _restoreDraft(Map<String, Object?> draft) {
    _title.text = draft['title'] as String? ?? '';
    _description.text = draft['description'] as String? ?? '';
    _address.text = draft['address'] as String? ?? '';
    _rate.text = draft['rate'] as String? ?? '';
    _fixedPrice.text = draft['fixedPrice'] as String? ?? '';
    _notes.text = draft['notes'] as String? ?? '';
    _customerId = draft['customerId'] as String?;
    _serviceId = draft['serviceId'] as String?;
    _pricingType = pricingTypeFromString(draft['pricingType'] as String? ?? 'hourly');
    _status = jobStatusFromString(draft['status'] as String? ?? 'scheduled');
    _reminders = draft['reminders'] as bool? ?? true;
    _useGlobalReminderDefaults = draft['useGlobalReminderDefaults'] as bool? ?? true;
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
        draftType: 'job',
        linkedEntityId: widget.jobId,
        payload: {
          'title': _title.text,
          'description': _description.text,
          'address': _address.text,
          'rate': _rate.text,
          'fixedPrice': _fixedPrice.text,
          'notes': _notes.text,
          'customerId': _customerId,
          'serviceId': _serviceId,
          'pricingType': _pricingType.name,
          'status': _status.name,
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
    if (_customerId == null) {
      AppFeedback.error(context, context.l10n.requiredField);
      return;
    }
    final schedule = _schedule.window;
    if (!schedule.isValid) {
      AppFeedback.error(context, context.l10n.invalidSchedule);
      return;
    }
    setState(() => _saving = true);
    _draftTimer?.cancel();
    try {
      final currency = ref.read(currentProfileProvider)?.currencyCode ?? 'GBP';
      final hourlyMinor = _pricingType == PricingType.fixed || _rate.text.trim().isEmpty
          ? null
          : Money.tryParse(_rate.text.trim(), currencyCode: currency)?.minorUnits;
      final fixedMinor = (_pricingType != PricingType.fixed && _pricingType != PricingType.mixed) || _fixedPrice.text.trim().isEmpty
          ? null
          : Money.tryParse(_fixedPrice.text.trim(), currencyCode: currency)?.minorUnits;
      final repository = ref.read(jobRepositoryProvider);
      if (_existing == null) {
        await repository.create(
          customerId: _customerId!,
          serviceId: _serviceId,
          title: _title.text.trim(),
          description: _blank(_description.text),
          address: _blank(_address.text),
          schedule: schedule,
          pricingType: _pricingType,
          status: _status,
          hourlyRateMinor: hourlyMinor,
          fixedPriceMinor: fixedMinor,
          notes: _blank(_notes.text),
          remindersEnabled: _reminders,
          reminderUsesGlobalDefaults: _useGlobalReminderDefaults,
          reminderPreviewOffsetSeconds: _previewSeconds,
          reminderPrepareOffsetSeconds: _prepareSeconds,
          reminderStartOffsetSeconds: _startSeconds,
          reminderMorningEnabled: _morningReminder,
          reminderEndEnabled: _endReminder,
        );
      } else {
        await repository.update(
          _existing!.copyWith(
            customerId: _customerId,
            serviceId: _serviceId,
            title: _title.text.trim(),
            description: _description.text,
            address: _address.text,
            schedule: schedule,
            scheduledDate: schedule.startLocal,
            estimatedDurationMinutes: schedule.elapsed.inMinutes,
            pricingType: _pricingType,
            status: _status,
            hourlyRateMinor: hourlyMinor,
            fixedPriceMinor: fixedMinor,
            notes: _notes.text,
            reminderUsesGlobalDefaults: _useGlobalReminderDefaults,
            reminderPreviewOffsetSeconds: _previewSeconds,
            reminderPrepareOffsetSeconds: _prepareSeconds,
            reminderStartOffsetSeconds: _startSeconds,
            reminderMorningEnabled: _morningReminder,
            reminderEndEnabled: _endReminder,
          ),
          remindersEnabled: _reminders,
        );
      }
      invalidateWorkData(ref, flow: WorkFlow.tradesman);
      ref.invalidate(moneySummaryProvider);
      ref.invalidate(auditEventsProvider);
      final showPermissionPrompt = await ref.read(notificationControllerProvider.notifier).workSaved(remindersEnabled: _reminders, hasSchedule: true);
      if (mounted) {
        if (showPermissionPrompt) {
          await showNotificationPrePermissionDialog(context, ref);
          if (!mounted) return;
        }
        AppFeedback.success(context, context.l10n.savedOnDevice);
        context.pop();
      }
    } catch (x) {
      print('Failed to save job: $x');
      // if (mounted) {
      //   AppFeedback.error(context, context.l10n.saveFailed);
      // }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    _schedule.dispose();
    for (final controller in [_title, _description, _address, _rate, _fixedPrice, _notes]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(allCustomersProvider);
    final services = ref.watch(servicesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.jobId == null ? context.l10n.newJob : context.l10n.editJob),
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
                cacheExtent: 5000,
                padding: const EdgeInsets.all(16),
                children: [
                  AppShowcase(
                    showcaseKey: _customerGuideKey,
                    title: context.l10n.customers,
                    description: '${context.l10n.newCustomer} · ${context.l10n.customerName}',
                    isFirst: true,
                    child: customers.when(
                      data: (items) => _CustomerField(
                        customers: items,
                        selectedId: _customerId,
                        onChanged: (value) {
                          setState(() => _customerId = value);
                          _queueDraft();
                        },
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => Text(context.l10n.peopleLoadFailed),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => context.push(AppRoutes.newCustomer),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(context.l10n.newCustomer),
                    ),
                  ),
                  services.when(
                    data: (items) => InlineAnimatedPicker<String>(
                      label: context.l10n.serviceOptional,
                      value: _serviceId ?? '',
                      options: ['', ...items.map((item) => item.id)],
                      optionLabel: (value) {
                        if (value.isEmpty) return context.l10n.notStarted;
                        for (final item in items) {
                          if (item.id == value) return item.name;
                        }
                        return context.l10n.notStarted;
                      },
                      leading: const Icon(Icons.design_services_outlined),
                      onChanged: (value) {
                        setState(() => _serviceId = value.isEmpty ? null : value);
                        final selected = items.where((item) => item.id == value).firstOrNull;
                        if (selected?.defaultRateMinor != null) {
                          final currency = ref.read(currentProfileProvider)?.currencyCode ?? 'GBP';
                          _rate.text = AppFormatters.minorInput(selected!.defaultRateMinor!, currencyCode: currency);
                        }
                        _queueDraft();
                      },
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => Text(context.l10n.peopleLoadFailed),
                  ),
                  const SizedBox(height: 14),
                  InlineAnimatedPicker<JobStatus>(
                    label: context.l10n.jobStatusTitle,
                    value: _status,
                    options: JobStatus.values,
                    optionLabel: (value) => _jobStatusLabel(context, value),
                    leading: const Icon(Icons.account_tree_outlined),
                    onChanged: (value) {
                      setState(() => _status = value);
                      _queueDraft();
                    },
                  ),
                  const SizedBox(height: 14),
                  AppShowcase(
                    showcaseKey: _detailsGuideKey,
                    title: context.l10n.jobTitleLabel,
                    description: '${context.l10n.descriptionLabel} · ${context.l10n.addressLabel}',
                    child: TextFormField(
                      controller: _title,
                      decoration: InputDecoration(labelText: '${context.l10n.jobTitleLabel} *'),
                      validator: (value) => value == null || value.trim().isEmpty ? context.l10n.requiredField : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _description,
                    decoration: InputDecoration(labelText: context.l10n.descriptionLabel),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _address,
                    decoration: InputDecoration(labelText: context.l10n.addressLabel),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 14),
                  AppShowcase(
                    showcaseKey: _scheduleGuideKey,
                    title: context.l10n.scheduleTitle,
                    description:
                        '${context.l10n.startLabel} · ${context.l10n.endLabel} · '
                        '${context.l10n.savedOnDevice}',
                    child: ScheduleEditor(controller: _schedule, onChanged: _queueDraft, deviceTimeZoneOnly: true),
                  ),
                  const SizedBox(height: 18),
                  AppShowcase(
                    showcaseKey: _pricingGuideKey,
                    title: context.l10n.pricingLabel,
                    description:
                        '${context.l10n.methodHourly} · ${context.l10n.methodDaily} · '
                        '${context.l10n.methodFixed} · ${context.l10n.remindersEnabled}',
                    child: InlineAnimatedPicker<PricingType>(
                      label: context.l10n.pricingLabel,
                      value: _pricingType,
                      options: PricingType.values,
                      optionLabel: (value) => switch (value) {
                        PricingType.hourly => context.l10n.methodHourly,
                        PricingType.daily => context.l10n.methodDaily,
                        PricingType.fixed => context.l10n.methodFixed,
                        PricingType.mixed => context.l10n.methodMixed,
                      },
                      leading: const Icon(Icons.sell_outlined),
                      onChanged: (value) {
                        setState(() => _pricingType = value);
                        _queueDraft();
                      },
                    ),
                  ),
                  if (_pricingType != PricingType.fixed) ...[
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _rate,
                      decoration: InputDecoration(
                        labelText: _pricingType == PricingType.daily ? context.l10n.dailyRateOptional : context.l10n.hourlyRateOptional,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                  if (_pricingType == PricingType.fixed || _pricingType == PricingType.mixed) ...[
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _fixedPrice,
                      decoration: InputDecoration(labelText: context.l10n.fixedPriceOptional),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
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
                    decoration: InputDecoration(labelText: context.l10n.notesLabel),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  AppShowcase(
                    showcaseKey: _saveGuideKey,
                    title: context.l10n.saveJob,
                    description: '${context.l10n.savedOnDevice} · ${context.l10n.offlineNotificationsTitle}',
                    isLast: true,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(context.l10n.saveJob),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

String _jobStatusLabel(BuildContext context, JobStatus status) {
  final bn = Localizations.localeOf(context).languageCode == 'bn';
  return switch (status) {
    JobStatus.lead => bn ? 'নতুন কাজ' : 'Lead / received',
    JobStatus.quoted => bn ? 'কোট পাঠানো' : 'Quote sent',
    JobStatus.accepted => bn ? 'গৃহীত' : 'Accepted',
    JobStatus.scheduled => context.l10n.statusScheduled,
    JobStatus.inProgress => bn ? 'কাজ চলছে' : 'In progress',
    JobStatus.paused => bn ? 'বিরতিতে' : 'Paused',
    JobStatus.completed => context.l10n.statusCompleted,
    JobStatus.invoiced => bn ? 'ইনভয়েস পাঠানো' : 'Invoiced',
    JobStatus.partiallyPaid => bn ? 'আংশিক পরিশোধ' : 'Partially paid',
    JobStatus.paid => bn ? 'পরিশোধিত' : 'Paid',
    JobStatus.cancelled => bn ? 'বাতিল' : 'Cancelled',
  };
}

class _CustomerField extends StatelessWidget {
  const _CustomerField({required this.customers, required this.selectedId, required this.onChanged});
  final List<Customer> customers;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => InlineAnimatedPicker<String>(
    label: '${context.l10n.customers} *',
    value: selectedId ?? '',
    options: ['', ...customers.map((item) => item.id)],
    optionLabel: (value) {
      if (value.isEmpty) return context.l10n.requiredField;
      for (final customer in customers) {
        if (customer.id == value) return customer.name;
      }
      return context.l10n.requiredField;
    },
    leading: const Icon(Icons.person_outline_rounded),
    onChanged: (value) => onChanged(value.isEmpty ? null : value),
  );
}

String? _blank(String value) => value.trim().isEmpty ? null : value.trim();

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
