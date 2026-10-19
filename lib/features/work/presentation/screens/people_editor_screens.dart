import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/money/currency_catalog.dart';
import '../../../../core/money/money.dart';
import '../../../../core/time/time_zone_options.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/inline_animated_picker.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../l10n/l10n.dart';
import '../../../customers/customer_model.dart';
import '../../../customers/customer_provider.dart';
import '../../../onboarding/presentation/controllers/onboarding_controller.dart';
import '../../../proof/presentation/controllers/audit_controller.dart';
import '../../data/work_repository.dart';
import '../../domain/work_models.dart';
import '../controllers/work_controller.dart';

class EmployerEditorScreen extends ConsumerStatefulWidget {
  const EmployerEditorScreen({super.key, this.employerId});
  final String? employerId;

  @override
  ConsumerState<EmployerEditorScreen> createState() =>
      _EmployerEditorScreenState();
}

class _EmployerEditorScreenState extends ConsumerState<EmployerEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _rate = TextEditingController();
  final _notes = TextEditingController();
  String _schedule = 'weekly';
  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.employerId != null) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final item = await ref
        .read(workRepositoryProvider)
        .employer(widget.employerId!);
    if (item != null && mounted) {
      _name.text = item.name;
      _contact.text = item.contactName ?? '';
      _phone.text = item.phone ?? '';
      _email.text = item.email ?? '';
      _notes.text = item.contractNotes ?? '';
      _schedule = item.paySchedule ?? 'weekly';
      if (item.defaultRateMinor != null) {
        final currency =
            ref.read(currentProfileProvider)?.currencyCode ?? 'GBP';
        _rate.text = AppFormatters.minorInput(
          item.defaultRateMinor!,
          currencyCode: currency,
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final currency = ref.read(currentProfileProvider)?.currencyCode ?? 'GBP';
      await ref
          .read(workRepositoryProvider)
          .saveEmployer(
            id: widget.employerId,
            name: _name.text,
            contactName: _contact.text,
            phone: _phone.text,
            email: _email.text,
            paySchedule: _schedule,
            contractNotes: _notes.text,
            defaultRateMinor: _rate.text.trim().isEmpty
                ? null
                : Money.tryParse(
                    _rate.text.trim(),
                    currencyCode: currency,
                  )?.minorUnits,
          );
      invalidateWorkDirectories(ref);
      invalidateWorkData(ref, flow: WorkFlow.worker);
      ref.invalidate(auditEventsProvider);
      if (mounted) {
        AppFeedback.success(context, context.l10n.savedOnDevice);
        context.pop(true);
      }
    } catch (_) {
      if (mounted) _showSaveError(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    for (final controller in [_name, _contact, _phone, _email, _rate, _notes]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.employerId == null
            ? context.l10n.newEmployer
            : context.l10n.editEmployer,
      ),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _requiredField(_name, context.l10n.employerName),
                _field(_contact, context.l10n.contactName),
                _field(
                  _phone,
                  context.l10n.phoneLabel,
                  type: TextInputType.phone,
                ),
                _field(
                  _email,
                  context.l10n.emailLabel,
                  type: TextInputType.emailAddress,
                ),
                InlineAnimatedPicker<String>(
                  label: context.l10n.paySchedule,
                  value: _schedule,
                  options: const [
                    'weekly',
                    'fortnightly',
                    'fourWeekly',
                    'monthly',
                  ],
                  optionLabel: (value) => switch (value) {
                    'weekly' => context.l10n.m05Weekly,
                    'fortnightly' => context.l10n.m05Fortnightly,
                    'fourWeekly' => context.l10n.m05FourWeekly,
                    _ => context.l10n.m05Monthly,
                  },
                  leading: const Icon(Icons.calendar_view_week_outlined),
                  onChanged: (value) => setState(() => _schedule = value),
                ),
                _field(
                  _rate,
                  context.l10n.defaultRateLabel,
                  type: const TextInputType.numberWithOptions(decimal: true),
                ),
                _field(_notes, context.l10n.contractNotes, lines: 4),
                _saveButton(context, _saving, _save),
              ].separatedBy(const SizedBox(height: 14)),
            ),
          ),
  );
}

class WorkplaceEditorScreen extends ConsumerStatefulWidget {
  const WorkplaceEditorScreen({super.key, this.workplaceId});
  final String? workplaceId;

  @override
  ConsumerState<WorkplaceEditorScreen> createState() =>
      _WorkplaceEditorScreenState();
}

class _WorkplaceEditorScreenState extends ConsumerState<WorkplaceEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _notes = TextEditingController();
  String? _employerId;
  String _zone = 'Etc/UTC';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final deviceTimeZone = await deviceTimeZoneIdentifier();
    final item = widget.workplaceId == null
        ? null
        : await ref.read(workRepositoryProvider).workplace(widget.workplaceId!);
    if (!mounted) return;
    if (item != null) {
      _name.text = item.name;
      _address.text = item.address ?? '';
      _notes.text = item.notes ?? '';
      _employerId = item.employerId;
    }
    _zone = deviceTimeZone;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_employerId == null) {
      AppFeedback.error(context, context.l10n.requiredField);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(workRepositoryProvider)
          .saveWorkplace(
            id: widget.workplaceId,
            employerId: _employerId!,
            name: _name.text,
            address: _address.text,
            notes: _notes.text,
            ianaTimeZone: _zone,
          );
      invalidateWorkDirectories(ref);
      invalidateWorkData(ref, flow: WorkFlow.worker);
      ref.invalidate(auditEventsProvider);
      if (mounted) {
        AppFeedback.success(context, context.l10n.savedOnDevice);
        context.pop(true);
      }
    } catch (_) {
      if (mounted) _showSaveError(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employers = ref.watch(employersProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.workplaceId == null
              ? context.l10n.newWorkplace
              : context.l10n.editWorkplace,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  employers.when(
                    data: (items) => InlineAnimatedPicker<String>(
                      label: '${context.l10n.employers} *',
                      value: _employerId ?? '',
                      options: ['', ...items.map((item) => item.id)],
                      optionLabel: (value) {
                        if (value.isEmpty) return context.l10n.requiredField;
                        for (final item in items) {
                          if (item.id == value) return item.name;
                        }
                        return context.l10n.requiredField;
                      },
                      leading: const Icon(Icons.business_outlined),
                      onChanged: (value) => setState(
                        () => _employerId = value.isEmpty ? null : value,
                      ),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => Text(context.l10n.peopleLoadFailed),
                  ),
                  _requiredField(_name, context.l10n.workplaceName),
                  _field(_address, context.l10n.addressLabel, lines: 2),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.public_outlined),
                    title: Text(context.l10n.timeZoneLabel),
                    subtitle: Text(_zone),
                  ),
                  _field(_notes, context.l10n.notesLabel, lines: 4),
                  _saveButton(context, _saving, _save),
                ].separatedBy(const SizedBox(height: 14)),
              ),
            ),
    );
  }
}

class CustomerEditorScreen extends ConsumerStatefulWidget {
  const CustomerEditorScreen({super.key, this.customerId});
  final String? customerId;

  @override
  ConsumerState<CustomerEditorScreen> createState() =>
      _CustomerEditorScreenState();
}

class _CustomerEditorScreenState extends ConsumerState<CustomerEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _notes = TextEditingController();
  Customer? _existing;
  late String _currencyCode;
  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _currencyCode =
        ref.read(currentProfileProvider)?.currencyCode ??
        CurrencyCatalog.currencies.first.code;
    if (widget.customerId != null) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _existing = await ref
        .read(customerRepositoryProvider)
        .getById(widget.customerId!);
    final item = _existing;
    if (item != null && mounted) {
      _name.text = item.name;
      _phone.text = item.phone ?? '';
      _email.text = item.email ?? '';
      _address.text = item.address ?? '';
      _notes.text = item.notes ?? '';
      _currencyCode = item.billingCurrencyCode ?? _currencyCode;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final repository = ref.read(customerRepositoryProvider);
      if (_existing == null) {
        await repository.create(
          name: _name.text,
          phone: _phone.text,
          email: _email.text,
          address: _address.text,
          notes: _notes.text,
          billingCurrencyCode: _currencyCode,
        );
      } else {
        await repository.update(
          _existing!.copyWith(
            name: _name.text,
            phone: _phone.text,
            email: _email.text,
            address: _address.text,
            notes: _notes.text,
            billingCurrencyCode: _currencyCode,
          ),
        );
      }
      ref.invalidate(customersListProvider);
      ref.invalidate(allCustomersProvider);
      invalidateWorkData(ref, flow: WorkFlow.tradesman);
      ref.invalidate(auditEventsProvider);
      if (mounted) {
        AppFeedback.success(context, context.l10n.savedOnDevice);
        context.pop(true);
      }
    } catch (_) {
      if (mounted) _showSaveError(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    for (final controller in [_name, _phone, _email, _address, _notes]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.customerId == null
            ? context.l10n.newCustomer
            : context.l10n.editCustomer,
      ),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _requiredField(_name, context.l10n.customerName),
                _field(
                  _phone,
                  context.l10n.phoneLabel,
                  type: TextInputType.phone,
                ),
                _field(
                  _email,
                  context.l10n.emailLabel,
                  type: TextInputType.emailAddress,
                ),
                _field(_address, context.l10n.addressLabel, lines: 2),
                InlineAnimatedPicker<String>(
                  label: context.l10n.customerBillingCurrency,
                  value: _currencyCode,
                  options: CurrencyCatalog.currencies
                      .map((item) => item.code)
                      .toList(growable: false),
                  optionLabel: (code) => CurrencyCatalog.currency(code).label(
                    languageCode: Localizations.localeOf(context).languageCode,
                  ),
                  leading: const Icon(Icons.currency_exchange_rounded),
                  onChanged: (value) => setState(() => _currencyCode = value),
                ),
                _field(_notes, context.l10n.notesLabel, lines: 4),
                _saveButton(context, _saving, _save),
              ].separatedBy(const SizedBox(height: 14)),
            ),
          ),
  );
}

class ServiceEditorScreen extends ConsumerStatefulWidget {
  const ServiceEditorScreen({super.key, this.serviceId});
  final String? serviceId;

  @override
  ConsumerState<ServiceEditorScreen> createState() =>
      _ServiceEditorScreenState();
}

class _ServiceEditorScreenState extends ConsumerState<ServiceEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _category = TextEditingController(text: 'General');
  final _description = TextEditingController();
  final _rate = TextEditingController();
  final _duration = TextEditingController(text: '60');
  String _pricing = 'hourly';
  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.serviceId != null) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final item = await ref
        .read(workRepositoryProvider)
        .service(widget.serviceId!);
    if (item != null && mounted) {
      _name.text = item.name;
      _category.text = item.category;
      _description.text = item.description ?? '';
      _pricing = item.pricingType;
      final currency = ref.read(currentProfileProvider)?.currencyCode ?? 'GBP';
      _rate.text = item.defaultRateMinor == null
          ? ''
          : AppFormatters.minorInput(
              item.defaultRateMinor!,
              currencyCode: currency,
            );
      _duration.text = item.defaultDurationMinutes?.toString() ?? '';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final currency = ref.read(currentProfileProvider)?.currencyCode ?? 'GBP';
      await ref
          .read(workRepositoryProvider)
          .saveService(
            id: widget.serviceId,
            name: _name.text,
            category: _category.text,
            description: _description.text,
            pricingType: _pricing,
            defaultRateMinor: _rate.text.trim().isEmpty
                ? null
                : Money.tryParse(
                    _rate.text.trim(),
                    currencyCode: currency,
                  )?.minorUnits,
            defaultDurationMinutes: int.tryParse(_duration.text),
          );
      invalidateWorkDirectories(ref);
      invalidateWorkData(ref, flow: WorkFlow.tradesman);
      ref.invalidate(auditEventsProvider);
      if (mounted) {
        AppFeedback.success(context, context.l10n.savedOnDevice);
        context.pop(true);
      }
    } catch (_) {
      if (mounted) _showSaveError(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _category,
      _description,
      _rate,
      _duration,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.serviceId == null
            ? context.l10n.newService
            : context.l10n.editService,
      ),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _requiredField(_name, context.l10n.serviceName),
                _requiredField(_category, context.l10n.categoryLabel),
                InlineAnimatedPicker<String>(
                  label: context.l10n.pricingLabel,
                  value: _pricing,
                  options: const ['hourly', 'daily', 'fixed', 'mixed'],
                  optionLabel: (value) => switch (value) {
                    'hourly' => context.l10n.methodHourly,
                    'daily' => context.l10n.methodDaily,
                    'fixed' => context.l10n.methodFixed,
                    _ => context.l10n.methodMixed,
                  },
                  leading: const Icon(Icons.sell_outlined),
                  onChanged: (value) => setState(() => _pricing = value),
                ),
                _field(
                  _rate,
                  context.l10n.defaultRateLabel,
                  type: const TextInputType.numberWithOptions(decimal: true),
                ),
                _field(
                  _duration,
                  context.l10n.durationMinutes,
                  type: TextInputType.number,
                ),
                _field(_description, context.l10n.descriptionLabel, lines: 4),
                _saveButton(context, _saving, _save),
              ].separatedBy(const SizedBox(height: 14)),
            ),
          ),
  );
}

Widget _field(
  TextEditingController controller,
  String label, {
  TextInputType? type,
  int lines = 1,
}) => TextFormField(
  controller: controller,
  decoration: InputDecoration(labelText: label),
  keyboardType: type,
  maxLines: lines,
);

Widget _requiredField(TextEditingController controller, String label) =>
    TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: '$label *'),
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Required' : null,
    );

Widget _saveButton(BuildContext context, bool saving, VoidCallback onPressed) =>
    Padding(
      padding: const EdgeInsets.only(top: 10),
      child: FilledButton(
        onPressed: saving ? null : onPressed,
        child: saving
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(context.l10n.saveLabel),
      ),
    );

void _showSaveError(BuildContext context) {
  AppFeedback.error(context, context.l10n.saveFailed);
}

extension _SeparatedWidgets on List<Widget> {
  List<Widget> separatedBy(Widget separator) {
    if (isEmpty) return this;
    return [
      for (var i = 0; i < length; i++) ...[if (i > 0) separator, this[i]],
    ];
  }
}
