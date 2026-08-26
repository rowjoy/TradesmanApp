import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/money/money.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/inline_animated_picker.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../l10n/l10n.dart';
import '../../../proof/presentation/controllers/audit_controller.dart';
import '../../data/pay_protection_repository.dart';
import '../../domain/pay_protection_models.dart';
import '../../infrastructure/workproof_export_service.dart';
import '../controllers/pay_protection_controller.dart';

class PayPeriodDetailScreen extends ConsumerStatefulWidget {
  const PayPeriodDetailScreen({super.key, required this.payPeriodId});

  final String payPeriodId;

  @override
  ConsumerState<PayPeriodDetailScreen> createState() =>
      _PayPeriodDetailScreenState();
}

class _PayPeriodDetailScreenState extends ConsumerState<PayPeriodDetailScreen> {
  bool _exporting = false;

  Future<void> _openPayslip(String periodId) async {
    final saved = await context.push<bool>(AppRoutes.payPayslip(periodId));
    if (!mounted || saved != true) return;
    invalidatePayProtection(ref, periodId: periodId);
    AppFeedback.success(
      context,
      context.l10n.m05PayslipSavedPayComparisonUpdated,
    );
  }

  Future<void> _openEvidence(String periodId) async {
    final saved = await context.push<bool>(AppRoutes.newPayEvidence(periodId));
    if (!mounted || saved != true) return;
    invalidatePayProtection(ref, periodId: periodId);
    AppFeedback.success(
      context,
      context.l10n.m05EvidenceSavedWithAnIntegrityChecksum,
    );
  }

  Future<void> _export(PayPeriodDetail detail) async {
    setState(() => _exporting = true);
    try {
      final export = await ref
          .read(workProofExportServiceProvider)
          .generate(detail);
      invalidatePayProtection(ref, periodId: widget.payPeriodId);
      ref.invalidate(auditEventsProvider);
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      final origin = box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size;
      await ref
          .read(workProofExportServiceProvider)
          .share(export, sharePositionOrigin: origin);
      if (mounted) {
        AppFeedback.success(
          context,
          context.l10n.m05PDFZIPPackCreatedOfflineSHA256,
        );
      }
    } catch (_) {
      if (mounted) {
        AppFeedback.error(
          context,
          context.l10n.m05ExportCouldNotBeCreated,
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(payPeriodDetailProvider(widget.payPeriodId));
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.m05PayReview)),
      body: detail.when(
        loading: () => const AppListSkeleton(itemCount: 5),
        error: (_, __) => _ErrorBody(
          onRetry: () =>
              ref.invalidate(payPeriodDetailProvider(widget.payPeriodId)),
        ),
        data: (value) => value == null
            ? Center(
                child: Text(
                  context.l10n.m05PayPeriodNotFound,
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(payPeriodDetailProvider(widget.payPeriodId));
                  await ref.read(
                    payPeriodDetailProvider(widget.payPeriodId).future,
                  );
                },
                child: ListView(
                  key: PageStorageKey('pay-period-${widget.payPeriodId}'),
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  children: [
                    _ComparisonHero(detail: value),
                    const SizedBox(height: 14),
                    _QuickActions(
                      period: value.period,
                      onPayslip: () => _openPayslip(value.period.id),
                      onEvidence: () => _openEvidence(value.period.id),
                    ),
                    const SizedBox(height: 22),
                    _SectionTitle(
                      icon: Icons.calculate_outlined,
                      title: context.l10n.m05SavedCalculation,
                    ),
                    const SizedBox(height: 9),
                    _CalculationCard(detail: value),
                    const SizedBox(height: 12),
                    _AdjustmentComposer(period: value.period),
                    const SizedBox(height: 22),
                    _SectionTitle(
                      icon: Icons.attachment_outlined,
                      title: context.l10n.m05EvidenceTimeline,
                      trailing: Text('${value.evidenceCount}'),
                    ),
                    const SizedBox(height: 9),
                    if (value.evidence.isEmpty)
                      _EvidenceEmpty(
                        onAdd: () => _openEvidence(value.period.id),
                      )
                    else
                      Card(
                        child: Column(
                          children: [
                            for (var i = 0; i < value.evidence.length; i++) ...[
                              _EvidenceTile(
                                item: value.evidence[i],
                                onSelected: (selected) async {
                                  await ref
                                      .read(payProtectionRepositoryProvider)
                                      .setEvidenceSelected(
                                        value.evidence[i].id,
                                        selected: selected,
                                      );
                                  ref.invalidate(
                                    payPeriodDetailProvider(widget.payPeriodId),
                                  );
                                },
                              ),
                              if (i != value.evidence.length - 1)
                                const Divider(height: 1),
                            ],
                          ],
                        ),
                      ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer.withValues(alpha: .55),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.privacy_tip_outlined),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              context.l10n.m05ExportsUseSelectedEvidenceAndPrivacyShare,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _exporting ? null : () => _export(value),
                      icon: _exporting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.folder_zip_outlined),
                      label: Text(
                        context.l10n.m05CreatePDFZIPEvidencePack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.m05ThisIsAUserCreatedRecordNot,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ComparisonHero extends StatelessWidget {
  const _ComparisonHero({required this.detail});
  final PayPeriodDetail detail;

  @override
  Widget build(BuildContext context) {
    final period = detail.period;
    final difference = period.possibleDifferenceMinor;
    final needsReview = difference != null && difference != 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: needsReview
              ? const [Color(0xFF5D3A10), Color(0xFF8A591B)]
              : const [Color(0xFF0D5453), Color(0xFF123C3B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  period.employerName ??
                      context.l10n.m05AllEmployers,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  period.currencyCode,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${AppFormatters.date(period.startAtUtc.toLocal())} – '
            '${AppFormatters.date(period.endAtUtc.toLocal().subtract(const Duration(days: 1)))}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _HeroMoney(
                  label: context.l10n.m05ExpectedGross,
                  value: _money(period.expectedGrossMinor, period.currencyCode),
                ),
              ),
              Expanded(
                child: _HeroMoney(
                  label: context.l10n.m05ReceivedGross,
                  value: period.receivedGrossMinor == null
                      ? '—'
                      : _money(period.receivedGrossMinor!, period.currencyCode),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  needsReview
                      ? Icons.info_outline_rounded
                      : Icons.check_circle_outline_rounded,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    difference == null
                        ? context.l10n.m05AddAPayslipToComparePayment
                        : needsReview
                        ? difference > 0
                              ? context.l10n.m05PossibleDifferenceReview(
                                  _money(difference, period.currencyCode),
                                )
                              : context.l10n.m05ReceivedAboveExpectedReview(
                                  _money(difference.abs(), period.currencyCode),
                                )
                        : context.l10n.m05ExpectedAndReceivedGrossMatch,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMoney extends StatelessWidget {
  const _HeroMoney({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 5),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    ],
  );
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.period,
    required this.onPayslip,
    required this.onEvidence,
  });
  final PayPeriod period;
  final VoidCallback onPayslip;
  final VoidCallback onEvidence;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: onPayslip,
          icon: const Icon(Icons.receipt_long_outlined),
          label: Text(
            period.receivedGrossMinor == null
                ? context.l10n.m05AddPayslip
                : context.l10n.m05EditPayslip,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: onEvidence,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: Text(context.l10n.m05AddEvidence),
        ),
      ),
    ],
  );
}

class _CalculationCard extends StatelessWidget {
  const _CalculationCard({required this.detail});
  final PayPeriodDetail detail;

  @override
  Widget build(BuildContext context) {
    final period = detail.period;
    final base = period.breakdown;
    final adjustmentTotal = detail.adjustments.fold<int>(
      0,
      (sum, item) => sum + item.amountMinor,
    );
    return Card(
      child: Column(
        children: [
          _CalcLine(
            icon: Icons.timer_outlined,
            label: context.l10n.m05RecordedHours,
            value: AppFormatters.duration(
              Duration(seconds: base.recordedSeconds),
            ),
          ),
          _CalcLine(
            label: context.l10n.regularPay,
            value: _money(base.regularPayMinor, period.currencyCode),
          ),
          _CalcLine(
            label: context.l10n.m05Overtime,
            value: _money(base.overtimePayMinor, period.currencyCode),
          ),
          _CalcLine(
            label: context.l10n.m05Premiums,
            value: _money(base.premiumPayMinor, period.currencyCode),
          ),
          _CalcLine(
            label: context.l10n.m05AllowancesAdjustments,
            value: _money(
              base.allowancesMinor + adjustmentTotal,
              period.currencyCode,
            ),
          ),
          const Divider(height: 1),
          _CalcLine(
            label: context.l10n.m05ExpectedGross,
            value: _money(period.expectedGrossMinor, period.currencyCode),
            strong: true,
          ),
          _CalcLine(
            label: context.l10n.m05Deductions,
            value: period.deductionsMinor == null
                ? '—'
                : _money(period.deductionsMinor!, period.currencyCode),
          ),
          _CalcLine(
            label: context.l10n.m05NetPayment,
            value: period.netPaymentMinor == null
                ? '—'
                : _money(period.netPaymentMinor!, period.currencyCode),
            strong: true,
          ),
          if (period.confidence != PayConfidence.complete)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.errorContainer.withValues(alpha: .5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.rule_folder_outlined),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      base.entryCount == 0
                          ? context.l10n.m05NoCompletedShiftsWereFoundInThis
                          : context.l10n.m05MissingRateReview(
                              base.missingRateCount,
                            ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CalcLine extends StatelessWidget {
  const _CalcLine({
    required this.label,
    required this.value,
    this.icon,
    this.strong = false,
  });
  final IconData? icon;
  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
    child: Row(
      children: [
        if (icon != null) ...[Icon(icon, size: 19), const SizedBox(width: 9)],
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontWeight: strong ? FontWeight.w700 : null),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: strong ? FontWeight.w900 : FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    ),
  );
}

class _AdjustmentComposer extends ConsumerStatefulWidget {
  const _AdjustmentComposer({required this.period});
  final PayPeriod period;

  @override
  ConsumerState<_AdjustmentComposer> createState() =>
      _AdjustmentComposerState();
}

class _AdjustmentComposerState extends ConsumerState<_AdjustmentComposer> {
  final _label = TextEditingController();
  final _amount = TextEditingController();
  String _type = 'allowance';
  bool _open = false;
  bool _saving = false;

  @override
  void dispose() {
    _label.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final money = Money.tryParse(
      _amount.text,
      currencyCode: widget.period.currencyCode,
      allowNegative: true,
    );
    if (_label.text.trim().isEmpty || money == null || money.minorUnits == 0) {
      AppFeedback.error(
        context,
        context.l10n.m05EnterALabelAndValidAmount,
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(payProtectionRepositoryProvider)
          .addAdjustment(
            payPeriodId: widget.period.id,
            type: _type,
            label: _label.text,
            amountMinor: money.minorUnits,
          );
      invalidatePayProtection(ref, periodId: widget.period.id);
      ref.invalidate(auditEventsProvider);
      _label.clear();
      _amount.clear();
      if (mounted) {
        setState(() => _open = false);
        AppFeedback.success(context, context.l10n.adjustmentSaved);
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
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Row(
              children: [
                const Icon(Icons.playlist_add_rounded),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.m05AddExpectedPayAdjustment,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                AnimatedRotation(
                  turns: _open ? .5 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: !_open
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Column(
                      children: [
                        InlineAnimatedPicker<String>(
                          label: context.l10n.m05AdjustmentType,
                          value: _type,
                          options: const [
                            'allowance',
                            'overtimeCorrection',
                            'manualCorrection',
                          ],
                          optionLabel: (value) => switch (value) {
                            'allowance' => context.l10n.m05Allowance,
                            'overtimeCorrection' => context.l10n.m05OvertimeCorrection,
                            _ => context.l10n.m05ManualCorrection,
                          },
                          onChanged: (value) => setState(() => _type = value),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _label,
                          decoration: InputDecoration(
                            labelText: context.l10n.m05ReasonLabel,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _amount,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: InputDecoration(
                            labelText: context.l10n.m05AmountWithCurrency(
                              widget.period.currencyCode,
                            ),
                            helperText: context.l10n.m05UseAMinusSignOnlyForA,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _saving ? null : _save,
                          child: Text(
                            context.l10n.m05SaveAdjustment,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    ),
  );
}

class _EvidenceTile extends StatelessWidget {
  const _EvidenceTile({required this.item, required this.onSelected});
  final EvidenceItem item;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final attachment = item.attachment;
    return CheckboxListTile(
      value: item.selectedForExport,
      onChanged: (value) => onSelected(value ?? false),
      controlAffinity: ListTileControlAffinity.trailing,
      secondary: CircleAvatar(child: Icon(_evidenceIcon(item.type), size: 20)),
      title: Text(
        item.description?.trim().isNotEmpty == true
            ? item.description!
            : attachment?.originalFilename ?? item.type.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        attachment == null
            ? AppFormatters.date(item.capturedAtUtc.toLocal())
            : 'SHA-256 ${attachment.sha256.substring(0, 12)}… · '
                  '${attachment.metadataStripped ? context.l10n.m05MetadataStripped : context.l10n.m05ReviewMetadata}',
      ),
    );
  }
}

class _EvidenceEmpty extends StatelessWidget {
  const _EvidenceEmpty({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            context.l10n.m05NoEvidenceAttachedYet,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(context.l10n.m05AddEvidence),
          ),
        ],
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title, this.trailing});
  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 21),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      if (trailing != null) trailing!,
    ],
  );
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.m05CouldNotLoadPayPeriod,
        ),
        TextButton(
          onPressed: onRetry,
          child: Text(context.l10n.m05Retry),
        ),
      ],
    ),
  );
}

IconData _evidenceIcon(EvidenceType type) => switch (type) {
  EvidenceType.note => Icons.notes_rounded,
  EvidenceType.photo => Icons.photo_outlined,
  EvidenceType.document => Icons.description_outlined,
  EvidenceType.payslip => Icons.receipt_long_outlined,
  EvidenceType.signature => Icons.draw_outlined,
};

String _money(int minor, String currency) =>
    AppFormatters.currencyMinor(minor, currencyCode: currency);
