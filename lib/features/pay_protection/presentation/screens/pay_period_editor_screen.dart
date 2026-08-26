import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/money/currency_catalog.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/inline_animated_picker.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../l10n/l10n.dart';
import '../../../onboarding/presentation/controllers/onboarding_controller.dart';
import '../../data/pay_protection_repository.dart';
import '../../domain/pay_protection_models.dart';
import '../controllers/pay_protection_controller.dart';

class PayPeriodEditorScreen extends ConsumerStatefulWidget {
  const PayPeriodEditorScreen({super.key});

  @override
  ConsumerState<PayPeriodEditorScreen> createState() =>
      _PayPeriodEditorScreenState();
}

class _PayPeriodEditorScreenState extends ConsumerState<PayPeriodEditorScreen> {
  final _notes = TextEditingController();
  PayPeriodType _type = PayPeriodType.weekly;
  String _employerId = '';
  late String _currencyCode;
  late DateTime _start;
  late DateTime _endInclusive;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _currencyCode = ref.read(currentProfileProvider)?.currencyCode ?? 'GBP';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _start = today.subtract(Duration(days: today.weekday - DateTime.monday));
    _endInclusive = _endFor(_start, _type);
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  DateTime _endFor(DateTime start, PayPeriodType type) => switch (type) {
    PayPeriodType.weekly => start.add(const Duration(days: 6)),
    PayPeriodType.fortnightly => start.add(const Duration(days: 13)),
    PayPeriodType.fourWeekly => start.add(const Duration(days: 27)),
    PayPeriodType.monthly => DateTime(start.year, start.month + 1, 0),
    PayPeriodType.custom => _endInclusive,
  };

  Future<void> _pickDate({required bool start}) async {
    final current = start ? _start : _endInclusive;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (start) {
        _start = picked;
        if (_type != PayPeriodType.custom) {
          _endInclusive = _endFor(_start, _type);
        } else if (_endInclusive.isBefore(_start)) {
          _endInclusive = _start;
        }
      } else {
        _endInclusive = picked;
      }
    });
  }

  Future<void> _save() async {
    if (_endInclusive.isBefore(_start)) {
      _message(
        context.l10n.m05EndDateMustBeAfterStart,
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final startUtc = DateTime.utc(_start.year, _start.month, _start.day);
      final endExclusiveUtc = DateTime.utc(
        _endInclusive.year,
        _endInclusive.month,
        _endInclusive.day + 1,
      );
      final id = await ref
          .read(payProtectionRepositoryProvider)
          .createPeriod(
            periodType: _type,
            startAtUtc: startUtc,
            endAtUtc: endExclusiveUtc,
            currencyCode: _currencyCode,
            employerId: _employerId.isEmpty ? null : _employerId,
            notes: _notes.text,
          );
      invalidatePayProtection(ref, periodId: id);
      if (mounted) {
        AppFeedback.success(
          context,
          context.l10n.m05PayPeriodCreatedAndExpectedPayCalculated,
        );
        context.replace(AppRoutes.payPeriod(id));
      }
    } catch (_) {
      if (mounted) {
        _message(
          context.l10n.m05CouldNotCreatePayPeriod,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String value) => AppFeedback.error(context, value);

  @override
  Widget build(BuildContext context) {
    final employers = ref.watch(payProtectionEmployersProvider);
    final employerItems = employers.asData?.value ?? const [];
    final employerIds = ['', ...employerItems.map((item) => item.id)];
    String employerLabel(String id) {
      if (id.isEmpty) return context.l10n.m05AllEmployers;
      for (final item in employerItems) {
        if (item.id == id) return item.name;
      }
      return context.l10n.m05Employer;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.m05NewPayPeriod),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.calculate_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.m05CompletedWorkerShiftsInThisDateRange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          InlineAnimatedPicker<PayPeriodType>(
            label: context.l10n.paySchedule,
            value: _type,
            options: PayPeriodType.values,
            optionLabel: (value) => _periodLabel(context, value),
            leading: const Icon(Icons.calendar_view_week_outlined),
            onChanged: (value) => setState(() {
              _type = value;
              if (value != PayPeriodType.custom) {
                _endInclusive = _endFor(_start, value);
              }
            }),
          ),
          const SizedBox(height: 14),
          InlineAnimatedPicker<String>(
            label: context.l10n.m05EmployerScope,
            value: _employerId,
            options: employerIds,
            optionLabel: employerLabel,
            leading: const Icon(Icons.business_outlined),
            onChanged: (value) => setState(() => _employerId = value),
          ),
          if (employers.isLoading) const LinearProgressIndicator(),
          const SizedBox(height: 14),
          InlineAnimatedPicker<String>(
            label: context.l10n.m05PayCurrency,
            value: _currencyCode,
            options: CurrencyCatalog.currencies
                .map((item) => item.code)
                .toList(growable: false),
            optionLabel: (value) => CurrencyCatalog.currency(value).label(
              languageCode: Localizations.localeOf(context).languageCode,
            ),
            leading: const Icon(Icons.currency_exchange_rounded),
            onChanged: (value) => setState(() => _currencyCode = value),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DateCard(
                  label: context.l10n.m05From,
                  date: _start,
                  onTap: () => _pickDate(start: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateCard(
                  label: context.l10n.m05To,
                  date: _endInclusive,
                  onTap: _type == PayPeriodType.custom
                      ? () => _pickDate(start: false)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: context.l10n.m05PrivateNoteOptional,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.shield_outlined),
            label: Text(
              context.l10n.m05CalculateAndSave,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({required this.label, required this.date, this.onTap});

  final String label;
  final DateTime date;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 7),
            Row(
              children: [
                const Icon(Icons.event_outlined, size: 19),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

String _periodLabel(BuildContext context, PayPeriodType value) =>
    switch (value) {
      PayPeriodType.weekly => context.l10n.m05Weekly,
      PayPeriodType.fortnightly => context.l10n.m05Fortnightly,
      PayPeriodType.fourWeekly => context.l10n.m05FourWeekly,
      PayPeriodType.monthly => context.l10n.m05Monthly,
      PayPeriodType.custom => context.l10n.m05CustomRange,
    };
