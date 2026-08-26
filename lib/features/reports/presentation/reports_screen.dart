import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/banner_ad_widget.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../../l10n/l10n.dart';
import '../../onboarding/domain/entities/local_profile.dart';
import '../../onboarding/presentation/controllers/onboarding_controller.dart';
import '../application/report_controller.dart';
import '../domain/report_models.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportControllerProvider);
    final controller = ref.read(reportControllerProvider.notifier);
    final profileMode = ref.watch(
      currentProfileProvider.select((profile) => profile?.workMode),
    );
    ref.listen<String?>(
      reportControllerProvider.select((value) => value.errorCode),
      (_, error) {
        if (error == 'report_export_failed') {
          AppFeedback.error(context, context.l10n.reportExportFailed);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.reportsTitle)),
      body: Column(
        children: [
          const BannerAdWidget(placement: AdPlacement.reports),
          SizedBox(
            height: 2,
            child: state.refreshing
                ? const LinearProgressIndicator()
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              child: state.report.when(
                loading: () => const AppListSkeleton(),
                error: (_, __) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 80),
                    const Icon(Icons.error_outline, size: 44),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.reportLoadFailed,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: controller.refresh,
                      child: Text(context.l10n.retry),
                    ),
                  ],
                ),
                data: (report) => _ReportBody(
                  report: report,
                  profileMode: profileMode,
                  exporting: state.exporting,
                  onPreset: controller.setPreset,
                  onScope: controller.setScope,
                  onParty: controller.setParty,
                  onCustomRange: controller.setCustomRange,
                  onExport: (format, origin) async {
                    final success = await controller.exportAndShare(
                      format,
                      origin: origin,
                    );
                    if (success && context.mounted) {
                      AppFeedback.success(
                        context,
                        context.l10n.reportExportCreated,
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({
    required this.report,
    required this.profileMode,
    required this.exporting,
    required this.onPreset,
    required this.onScope,
    required this.onParty,
    required this.onCustomRange,
    required this.onExport,
  });

  final OfflineReport report;
  final WorkMode? profileMode;
  final bool exporting;
  final Future<void> Function(ReportRangePreset) onPreset;
  final Future<void> Function(ReportScope) onScope;
  final Future<void> Function(ReportParty?) onParty;
  final Future<void> Function(DateTime, DateTime) onCustomRange;
  final Future<void> Function(ReportExportFormat, Rect?) onExport;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.yMMMd(locale);
    final end = report.filter.endUtc.toLocal().subtract(
      const Duration(days: 1),
    );
    return ListView(
      key: const PageStorageKey('reports-list'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Text(
          context.l10n.reportsOfflineDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<ReportRangePreset>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: ReportRangePreset.weekly,
                label: Text(context.l10n.m05Weekly),
              ),
              ButtonSegment(
                value: ReportRangePreset.monthly,
                label: Text(context.l10n.m05Monthly),
              ),
              ButtonSegment(
                value: ReportRangePreset.custom,
                label: Text(context.l10n.m05CustomRange),
              ),
            ],
            selected: {report.filter.preset},
            onSelectionChanged: (values) {
              final selected = values.first;
              if (selected == ReportRangePreset.custom) {
                _chooseRange(context);
              } else {
                onPreset(selected);
              }
            },
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.date_range_outlined),
            title: Text(
              '${date.format(report.filter.startUtc.toLocal())} – '
              '${date.format(end)}',
            ),
            subtitle: Text(context.l10n.reportEndDateInclusive),
            trailing: IconButton(
              tooltip: context.l10n.m05CustomRange,
              onPressed: () => _chooseRange(context),
              icon: const Icon(Icons.edit_calendar_outlined),
            ),
          ),
        ),
        if (profileMode == WorkMode.both) ...[
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<ReportScope>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: ReportScope.both,
                  label: Text(context.l10n.reportAllWork),
                ),
                ButtonSegment(
                  value: ReportScope.worker,
                  label: Text(context.l10n.m05WorkerPay),
                ),
                ButtonSegment(
                  value: ReportScope.tradesman,
                  label: Text(context.l10n.m05BusinessMoney),
                ),
              ],
              selected: {report.filter.scope},
              onSelectionChanged: (values) => onScope(values.first),
            ),
          ),
        ],
        if (report.parties.isNotEmpty) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedPartyKey(report.filter),
            isExpanded: true,
            decoration: InputDecoration(
              labelText: report.filter.scope == ReportScope.worker
                  ? context.l10n.reportEmployerStatement
                  : report.filter.scope == ReportScope.tradesman
                  ? context.l10n.reportCustomerStatement
                  : context.l10n.reportPartyStatement,
              prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
            ),
            items: [
              DropdownMenuItem(
                value: '',
                child: Text(context.l10n.reportAllParties),
              ),
              for (final party in report.parties)
                DropdownMenuItem(
                  value: '${party.type.name}:${party.id}',
                  child: Text(
                    '${party.type == ReportPartyType.employer ? context.l10n.m05Employer : context.l10n.newCustomer}: ${party.name}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (value) {
              if (value == null || value.isEmpty) {
                onParty(null);
                return;
              }
              onParty(
                report.parties.firstWhere(
                  (party) => '${party.type.name}:${party.id}' == value,
                ),
              );
            },
          ),
        ],
        const SizedBox(height: 20),
        if (report.filter.scope != ReportScope.tradesman) ...[
          _SectionTitle(
            icon: Icons.badge_outlined,
            title: context.l10n.reportWorkerSummary,
          ),
          const SizedBox(height: 8),
          _WorkerSummary(report: report),
          const SizedBox(height: 20),
        ],
        if (report.filter.scope != ReportScope.worker) ...[
          _SectionTitle(
            icon: Icons.business_center_outlined,
            title: context.l10n.reportIncomeSummary,
          ),
          const SizedBox(height: 8),
          _BusinessSummary(report: report),
          const SizedBox(height: 20),
        ],
        if (report.worker.missingCalculationCount > 0 ||
            report.business.missingCalculationCount > 0) ...[
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: ListTile(
              leading: const Icon(Icons.warning_amber_rounded),
              title: Text(context.l10n.reportMissingRateWarning),
            ),
          ),
          const SizedBox(height: 12),
        ],
        _SectionTitle(
          icon: Icons.receipt_long_outlined,
          title: context.l10n.reportStatementLines,
        ),
        const SizedBox(height: 8),
        if (report.lines.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Text(
                context.l10n.reportNoRecords,
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...report.lines.map((line) => _ReportLineTile(line: line)),
        const SizedBox(height: 20),
        Text(
          context.l10n.reportExportPrivacyNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
        Builder(
          builder: (buttonContext) => Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: exporting
                      ? null
                      : () => onExport(
                          ReportExportFormat.csv,
                          _shareOrigin(buttonContext),
                        ),
                  icon: const Icon(Icons.table_view_outlined),
                  label: Text(context.l10n.exportCsv),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: exporting
                      ? null
                      : () => onExport(
                          ReportExportFormat.pdf,
                          _shareOrigin(buttonContext),
                        ),
                  icon: exporting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(
                    exporting
                        ? context.l10n.reportCreatingExport
                        : context.l10n.exportPdf,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _chooseRange(BuildContext context) async {
    final initial = DateTimeRange(
      start: report.filter.startUtc.toLocal(),
      end: report.filter.endUtc.toLocal().subtract(const Duration(days: 1)),
    );
    final value = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDateRange: initial,
      helpText: context.l10n.m05CustomRange,
    );
    if (value != null) await onCustomRange(value.start, value.end);
  }
}

Rect? _shareOrigin(BuildContext context) {
  final renderObject = context.findRenderObject();
  if (renderObject is! RenderBox || !renderObject.hasSize) return null;
  return renderObject.localToGlobal(Offset.zero) & renderObject.size;
}

class _WorkerSummary extends StatelessWidget {
  const _WorkerSummary({required this.report});

  final OfflineReport report;

  @override
  Widget build(BuildContext context) => _MetricWrap(
    children: [
      _Metric(
        context.l10n.m05RecordedHours,
        _hours(report.worker.recordedSeconds),
      ),
      _Metric(
        context.l10n.reportBillableHours,
        _hours(report.worker.billableSeconds),
      ),
      _Metric(
        context.l10n.m05ExpectedGross,
        _money(
          context,
          report.worker.expectedGrossMinor,
          report.filter.currencyCode,
        ),
      ),
      _Metric(
        context.l10n.m05ReceivedGross,
        _money(
          context,
          report.worker.receivedGrossMinor,
          report.filter.currencyCode,
        ),
      ),
      _Metric(
        context.l10n.m05Deductions,
        _money(
          context,
          report.worker.deductionsMinor,
          report.filter.currencyCode,
        ),
      ),
      _Metric(
        context.l10n.m05NetPayment,
        _money(
          context,
          report.worker.netPaymentMinor,
          report.filter.currencyCode,
        ),
      ),
      _Metric(
        context.l10n.reportPossibleDifference,
        _money(
          context,
          report.worker.possibleDifferenceMinor,
          report.filter.currencyCode,
        ),
        warning: report.worker.possibleDifferenceMinor != 0,
      ),
    ],
  );
}

class _BusinessSummary extends StatelessWidget {
  const _BusinessSummary({required this.report});

  final OfflineReport report;

  @override
  Widget build(BuildContext context) => _MetricWrap(
    children: [
      _Metric(
        context.l10n.m05RecordedHours,
        _hours(report.business.recordedSeconds),
      ),
      _Metric(
        context.l10n.reportBillableHours,
        _hours(report.business.billableSeconds),
      ),
      _Metric(
        context.l10n.reportBillableWork,
        _money(
          context,
          report.business.billableWorkMinor,
          report.filter.currencyCode,
        ),
      ),
      _Metric(
        context.l10n.reportInvoiced,
        _money(
          context,
          report.business.invoicedMinor,
          report.filter.currencyCode,
        ),
      ),
      _Metric(
        context.l10n.reportPaid,
        _money(context, report.business.paidMinor, report.filter.currencyCode),
      ),
      _Metric(
        context.l10n.reportOutstanding,
        _money(
          context,
          report.business.outstandingMinor,
          report.filter.currencyCode,
        ),
        warning: report.business.outstandingMinor > 0,
      ),
      _Metric(
        context.l10n.reportExpenses,
        _money(
          context,
          report.business.expensesMinor,
          report.filter.currencyCode,
        ),
      ),
      _Metric(
        context.l10n.reportNetCash,
        _money(
          context,
          report.business.netCashMinor,
          report.filter.currencyCode,
        ),
      ),
    ],
  );
}

class _MetricWrap extends StatelessWidget {
  const _MetricWrap({required this.children});

  final List<_Metric> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 720 ? 4 : 2;
      final width = (constraints.maxWidth - (columns - 1) * 8) / columns;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, {this.warning = false});

  final String label;
  final String value;
  final bool warning;

  @override
  Widget build(BuildContext context) => Card(
    color: warning
        ? Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.55)
        : null,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 5),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 21),
      const SizedBox(width: 8),
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    ],
  );
}

class _ReportLineTile extends StatelessWidget {
  const _ReportLineTile({required this.line});

  final ReportLine line;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final displayTitle = switch (line.type) {
      ReportLineType.payslip => context.l10n.m05Payslip,
      ReportLineType.payment => context.l10n.reportPayment,
      _ => line.title,
    };
    final amount = line.creditMinor != 0
        ? _money(context, line.creditMinor, line.currencyCode)
        : line.debitMinor != 0
        ? '-${_money(context, line.debitMinor, line.currencyCode)}'
        : line.billableSeconds != 0
        ? _hours(line.billableSeconds)
        : '';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(child: Icon(_lineIcon(line.type), size: 20)),
        title: Text(displayTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          [
            DateFormat.yMMMd(locale).format(line.occurredAtUtc.toLocal()),
            if (line.partyName != null) line.partyName!,
            _lineLabel(context, line.type),
          ].join(' · '),
        ),
        trailing: amount.isEmpty
            ? null
            : Text(amount, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

String _selectedPartyKey(ReportFilter filter) =>
    filter.hasParty ? '${filter.partyType!.name}:${filter.partyId}' : '';

String _hours(int seconds) => '${(seconds / 3600).toStringAsFixed(2)} h';

String _money(BuildContext context, int minor, String currency) =>
    NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toLanguageTag(),
      name: currency,
    ).format(minor / 100);

IconData _lineIcon(ReportLineType type) => switch (type) {
  ReportLineType.workerTime => Icons.badge_outlined,
  ReportLineType.businessTime => Icons.timer_outlined,
  ReportLineType.payslip => Icons.payments_outlined,
  ReportLineType.invoice => Icons.request_quote_outlined,
  ReportLineType.payment => Icons.account_balance_wallet_outlined,
  ReportLineType.expense => Icons.receipt_long_outlined,
};

String _lineLabel(BuildContext context, ReportLineType type) => switch (type) {
  ReportLineType.workerTime => context.l10n.reportWorkerTime,
  ReportLineType.businessTime => context.l10n.reportBusinessTime,
  ReportLineType.payslip => context.l10n.m05Payslip,
  ReportLineType.invoice => context.l10n.reportInvoice,
  ReportLineType.payment => context.l10n.reportPayment,
  ReportLineType.expense => context.l10n.reportExpense,
};
