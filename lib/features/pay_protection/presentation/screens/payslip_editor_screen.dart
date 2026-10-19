import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/money/money.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../l10n/l10n.dart';
import '../../../proof/presentation/controllers/audit_controller.dart';
import '../../data/pay_protection_repository.dart';
import '../../domain/pay_protection_models.dart';
import '../../infrastructure/evidence_file_service.dart';
import '../controllers/pay_protection_controller.dart';

class PayslipEditorScreen extends ConsumerStatefulWidget {
  const PayslipEditorScreen({super.key, required this.payPeriodId});
  final String payPeriodId;

  @override
  ConsumerState<PayslipEditorScreen> createState() =>
      _PayslipEditorScreenState();
}

class _PayslipEditorScreenState extends ConsumerState<PayslipEditorScreen> {
  final _gross = TextEditingController();
  final _deductions = TextEditingController(text: '0');
  final _net = TextEditingController();
  final _reference = TextEditingController();
  PayPeriod? _period;
  PreparedEvidenceFile? _file;
  DateTime? _payDate;
  bool _loading = true;
  bool _picking = false;
  bool _saving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final detail = await ref
        .read(payProtectionRepositoryProvider)
        .detail(widget.payPeriodId);
    if (!mounted) return;
    _period = detail?.period;
    final payslip = detail?.payslip;
    if (payslip != null && detail != null) {
      _gross.text = _inputAmount(
        payslip.grossMinor,
        detail.period.currencyCode,
      );
      _deductions.text = _inputAmount(
        payslip.deductionsMinor,
        detail.period.currencyCode,
      );
      _net.text = _inputAmount(payslip.netMinor, detail.period.currencyCode);
      _reference.text = payslip.reference ?? '';
      _payDate = payslip.payDateUtc?.toLocal();
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _gross.dispose();
    _deductions.dispose();
    _net.dispose();
    _reference.dispose();
    if (!_saved && _file != null) {
      unawaited(ref.read(evidenceFileServiceProvider).discard(_file!));
    }
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() => _picking = true);
    try {
      final file = await ref
          .read(evidenceFileServiceProvider)
          .pickAndPrepare(EvidencePickKind.payslip);
      if (file != null && mounted) {
        final previous = _file;
        setState(() => _file = file);
        if (previous != null && previous.localPath != file.localPath) {
          unawaited(ref.read(evidenceFileServiceProvider).discard(previous));
        }
      }
    } on EvidenceFileTooLargeException {
      if (mounted) _message(context.l10n.evidenceFileTooLarge);
    } catch (_) {
      if (mounted)
        // ignore: curly_braces_in_flow_control_structures
        _message(context.l10n.m05FileCouldNotBePrepared);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _payDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked != null && mounted) setState(() => _payDate = picked);
  }

  Future<void> _save() async {
    final period = _period;
    if (period == null) return;
    final gross = Money.tryParse(
      _gross.text,
      currencyCode: period.currencyCode,
    );
    final deductions = Money.tryParse(
      _deductions.text,
      currencyCode: period.currencyCode,
    );
    final net = Money.tryParse(_net.text, currencyCode: period.currencyCode);
    if (gross == null || deductions == null || net == null) {
      _message(context.l10n.m05EnterValidGrossDeductionsAndNetAmounts);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(payProtectionRepositoryProvider)
          .savePayslip(
            payPeriodId: widget.payPeriodId,
            currencyCode: period.currencyCode,
            grossMinor: gross.minorUnits,
            deductionsMinor: deductions.minorUnits,
            netMinor: net.minorUnits,
            payDateUtc: _payDate == null
                ? null
                : DateTime.utc(_payDate!.year, _payDate!.month, _payDate!.day),
            reference: _reference.text,
            file: _file,
          );
      invalidatePayProtection(ref, periodId: widget.payPeriodId);
      ref.invalidate(auditEventsProvider);
      _saved = true;
      if (mounted) context.pop(true);
    } catch (_) {
      if (mounted) {
        _message(context.l10n.m05PayslipCouldNotBeSaved);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String value) => AppFeedback.error(context, value);

  @override
  Widget build(BuildContext context) {
    final period = _period;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.m05RecordPayslip)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : period == null
          ? Center(child: Text(context.l10n.m05PayPeriodNotFound))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_outlined),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          context.l10n.m05EnterValuesExactlyAsShownOCRIs,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _MoneyField(
                  controller: _gross,
                  label: context.l10n.m05ReceivedGross,
                  currency: period.currencyCode,
                ),
                const SizedBox(height: 12),
                _MoneyField(
                  controller: _deductions,
                  label: context.l10n.m05Deductions,
                  currency: period.currencyCode,
                ),
                const SizedBox(height: 12),
                _MoneyField(
                  controller: _net,
                  label: context.l10n.m05NetPayment,
                  currency: period.currencyCode,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _reference,
                  decoration: InputDecoration(
                    labelText: context.l10n.m05PayslipReferenceOptional,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.event_outlined),
                    title: Text(context.l10n.m05PayDate),
                    subtitle: Text(
                      _payDate == null
                          ? context.l10n.m05NotSet
                          : AppFormatters.date(_payDate!),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.attach_file_rounded),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                context.l10n.m05PayslipPhotoOrPDF,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_file != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _file!.originalFilename,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'SHA-256 ${_file!.sha256.substring(0, 16)}…',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _picking ? null : _pickFile,
                          icon: _picking
                              ? const SizedBox.square(
                                  dimension: 17,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.upload_file_outlined),
                          label: Text(
                            _file == null
                                ? context.l10n.m05ChooseFile
                                : context.l10n.m05ReplaceFile,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(context.l10n.m05SaveAndCompare),
                ),
              ],
            ),
    );
  }
}

class _MoneyField extends StatelessWidget {
  const _MoneyField({
    required this.controller,
    required this.label,
    required this.currency,
  });

  final TextEditingController controller;
  final String label;
  final String currency;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label, prefixText: '$currency '),
  );
}

String _inputAmount(int? minor, String currency) {
  if (minor == null) return '';
  final formatted = AppFormatters.currencyMinor(
    minor,
    currencyCode: currency,
    locale: 'en',
  );
  return formatted.replaceAll(RegExp(r'[^0-9.-]'), '');
}
