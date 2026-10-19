import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/money/money.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_feedback.dart';
import '../../l10n/l10n.dart';
import '../customers/customer_model.dart';
import '../customers/customer_provider.dart';
import '../marketing/data/marketing_repository.dart';
import '../marketing/domain/marketing_profile.dart';
import '../money/presentation/controllers/money_summary_controller.dart';
import '../notifications/application/notification_controller.dart';
import '../onboarding/presentation/controllers/onboarding_controller.dart';
import '../reports/application/report_controller.dart';
import '../reports/infrastructure/report_export_service.dart';
import '../time_tracking/time_entry_model.dart';
import '../time_tracking/time_tracking_provider.dart';
import '../work/domain/work_models.dart';
import '../work/presentation/controllers/work_controller.dart';
import 'job_finance_repository.dart';
import 'job_model.dart';
import 'job_provider.dart';

class JobWorkspaceScreen extends ConsumerStatefulWidget {
  const JobWorkspaceScreen({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<JobWorkspaceScreen> createState() => _JobWorkspaceScreenState();
}

class _JobWorkspaceScreenState extends ConsumerState<JobWorkspaceScreen> {
  final _vat = TextEditingController();
  final _signatureKey = GlobalKey();
  final List<Offset?> _signaturePoints = [];
  Job? _job;
  Customer? _customer;
  MarketingProfile _business = const MarketingProfile.empty();
  JobFinanceLedger _ledger = const JobFinanceLedger.empty();
  TimeEntry? _latestEntry;
  bool _loading = true;
  bool _busy = false;
  bool _editingSignature = false;

  bool get _bn => Localizations.localeOf(context).languageCode == 'bn';
  String t(String en, String bn) => _bn ? bn : en;
  String get _currency =>
      _customer?.billingCurrencyCode ??
      ref.read(currentProfileProvider)?.currencyCode ??
      'GBP';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _vat.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final job = await ref.read(jobRepositoryProvider).getById(widget.jobId);
      if (job == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final values = await Future.wait<Object?>([
        ref.read(customerRepositoryProvider).getById(job.customerId),
        ref.read(marketingRepositoryProvider).load(),
        ref.read(jobFinanceRepositoryProvider).load(job.id),
        ref
            .read(timeTrackingRepositoryProvider)
            .latestCompletedForWork(WorkItemReference.job(job.id)),
      ]);
      if (!mounted) return;
      final ledger = values[2]! as JobFinanceLedger;
      setState(() {
        _job = job;
        _customer = values[0] as Customer?;
        _business = values[1]! as MarketingProfile;
        _ledger = ledger;
        _latestEntry = values[3] as TimeEntry?;
        _vat.text = (ledger.vatBasisPoints / 100).toStringAsFixed(2);
        _editingSignature = ledger.signatureBytes == null;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _workSubtotalMinor {
    final job = _job;
    if (job == null) return 0;
    final latest = _latestEntry;
    if (latest != null) {
      return latest
          .earningsAt(latest.clockOut ?? DateTime.now().toUtc())
          .total
          .minorUnits;
    }
    final minutes = job.estimatedDurationMinutes ?? 0;
    final timed = switch (job.pricingType) {
      PricingType.daily => job.hourlyRateMinor ?? 0,
      PricingType.hourly || PricingType.mixed =>
        (((job.hourlyRateMinor ?? 0) * minutes) / 60).round(),
      PricingType.fixed => 0,
    };
    final fixed =
        job.pricingType == PricingType.fixed ||
            job.pricingType == PricingType.mixed
        ? job.fixedPriceMinor ?? 0
        : 0;
    return timed + fixed;
  }

  int get _expensesMinor =>
      _ledger.expenses.fold(0, (total, item) => total + item.amountMinor);
  int get _subtotalMinor => _workSubtotalMinor + _expensesMinor;
  int get _vatBasisPoints =>
      (((double.tryParse(_vat.text.trim()) ?? 0) * 100).round())
          .clamp(0, 10000)
          .toInt();
  int get _taxMinor => (_subtotalMinor * _vatBasisPoints / 10000).round();
  int get _totalMinor => _subtotalMinor + _taxMinor;
  int get _paidMinor =>
      _ledger.payments.fold(0, (total, item) => total + item.amountMinor);
  int get _outstandingMinor =>
      (_totalMinor - _paidMinor).clamp(0, _totalMinor).toInt();

  String money(int value) => AppFormatters.currencyMinor(
    value,
    currencyCode: _currency,
    locale: Localizations.localeOf(context).toLanguageTag(),
  );

  @override
  Widget build(BuildContext context) {
    final job = _job;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.manageJobTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : job == null
          ? Center(child: Text(t('Job not found', 'জব পাওয়া যায়নি')))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  _lifecycleCard(job),
                  const SizedBox(height: 12),
                  _summaryCard(),
                  const SizedBox(height: 12),
                  _expensesCard(),
                  const SizedBox(height: 12),
                  _paymentsCard(),
                  const SizedBox(height: 12),
                  _signatureCard(),
                  const SizedBox(height: 12),
                  _documentsCard(),
                ],
              ),
            ),
    );
  }

  Widget _lifecycleCard(Job job) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (_customer != null) ...[
            const SizedBox(height: 4),
            Text(_customer!.name),
          ],
          const SizedBox(height: 14),
          DropdownButtonFormField<JobStatus>(
            initialValue: job.status,
            decoration: InputDecoration(
              labelText: context.l10n.jobStatusTitle,
              prefixIcon: const Icon(Icons.account_tree_outlined),
            ),
            items: [
              for (final value in JobStatus.values)
                DropdownMenuItem(
                  value: value,
                  child: Text(_statusLabel(value)),
                ),
            ],
            onChanged: _busy
                ? null
                : (value) {
                    if (value != null) _setStatus(value);
                  },
          ),
        ],
      ),
    ),
  );

  Widget _summaryCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.costsAndPaymentsTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _vat,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: t('VAT / tax %', 'ভ্যাট / ট্যাক্স %'),
              suffixIcon: IconButton(
                tooltip: t('Save VAT', 'ভ্যাট সেভ করুন'),
                onPressed: _busy ? null : _saveVat,
                icon: const Icon(Icons.save_outlined),
              ),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _saveVat(),
          ),
          const SizedBox(height: 12),
          _amountRow(t('Work subtotal', 'কাজের সাবটোটাল'), _workSubtotalMinor),
          _amountRow(t('Expenses', 'খরচ'), _expensesMinor),
          _amountRow(t('VAT / tax', 'ভ্যাট / ট্যাক্স'), _taxMinor),
          const Divider(),
          _amountRow(t('Total', 'মোট'), _totalMinor, strong: true),
          _amountRow(t('Paid', 'পরিশোধিত'), _paidMinor),
          _amountRow(
            t('Outstanding balance', 'বকেয়া ব্যালেন্স'),
            _outstandingMinor,
            strong: true,
          ),
        ],
      ),
    ),
  );

  Widget _amountRow(String label, int value, {bool strong = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: strong ? const TextStyle(fontWeight: FontWeight.w800) : null,
          ),
        ),
        Text(
          money(value),
          style: TextStyle(fontWeight: strong ? FontWeight.w800 : null),
        ),
      ],
    ),
  );

  Widget _expensesCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t('Job expenses', 'জবের খরচ'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: t('Add expense', 'খরচ যোগ করুন'),
                onPressed: _busy ? null : _addExpense,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          if (_ledger.expenses.isEmpty)
            Text(t('No expenses added.', 'কোনো খরচ যোগ হয়নি।'))
          else
            for (final item in _ledger.expenses)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.receipt_long_outlined),
                title: Text(item.description),
                subtitle: Text(
                  AppFormatters.date(item.occurredAtUtc.toLocal()),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(money(item.amountMinor)),
                    IconButton(
                      tooltip: t('Delete', 'মুছুন'),
                      onPressed: _busy ? null : () => _deleteExpense(item.id),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
        ],
      ),
    ),
  );

  Widget _paymentsCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t('Payments', 'পেমেন্ট'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: _busy ? null : _addPayment,
                icon: const Icon(Icons.add_card_outlined),
                label: Text(t('Add payment', 'পেমেন্ট যোগ করুন')),
              ),
            ],
          ),
          if (_ledger.payments.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              t('No payment received yet.', 'এখনো কোনো পেমেন্ট পাওয়া যায়নি।'),
            ),
          ] else
            for (final item in _ledger.payments)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.payments_outlined),
                title: Text(money(item.amountMinor)),
                subtitle: Text(
                  '${item.method} · ${AppFormatters.date(item.paidAtUtc.toLocal())}'
                  '${item.reference?.trim().isNotEmpty == true ? ' · ${item.reference}' : ''}',
                ),
              ),
        ],
      ),
    ),
  );

  Widget _signatureCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t('Customer signature', 'কাস্টমারের স্বাক্ষর'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (!_editingSignature && _ledger.signatureBytes != null)
            Container(
              height: 150,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.memory(_ledger.signatureBytes!, fit: BoxFit.contain),
            )
          else
            RepaintBoundary(
              key: _signatureKey,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) => setState(() {
                  _signaturePoints.add(details.localPosition);
                }),
                onPanUpdate: (details) => setState(() {
                  _signaturePoints.add(details.localPosition);
                }),
                onPanEnd: (_) => setState(() => _signaturePoints.add(null)),
                child: CustomPaint(
                  painter: _SignaturePainter(_signaturePoints),
                  child: const SizedBox(height: 150, width: double.infinity),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              if (!_editingSignature && _ledger.signatureBytes != null)
                OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                          _editingSignature = true;
                          _signaturePoints.clear();
                        }),
                  icon: const Icon(Icons.draw_outlined),
                  label: Text(t('Replace', 'পরিবর্তন')),
                )
              else ...[
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => setState(_signaturePoints.clear),
                  child: Text(t('Clear', 'মুছুন')),
                ),
                FilledButton.icon(
                  onPressed: _busy || _signaturePoints.isEmpty
                      ? null
                      : _saveSignature,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(t('Save signature', 'স্বাক্ষর সেভ করুন')),
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  );

  Widget _documentsCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.jobDocumentsTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            t(
              'Saved offline. Share with the device Email, WhatsApp, or another app.',
              'অফলাইনে সেভ হয়। ডিভাইসের Email, WhatsApp বা অন্য app-এ শেয়ার করুন।',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _documentButton(
                JobFinancialDocumentType.quote,
                Icons.request_quote_outlined,
                t('Quote', 'কোট'),
              ),
              _documentButton(
                JobFinancialDocumentType.confirmation,
                Icons.task_alt_outlined,
                t('Confirmation', 'কনফার্মেশন'),
              ),
              _documentButton(
                JobFinancialDocumentType.invoice,
                Icons.description_outlined,
                t('Invoice', 'ইনভয়েস'),
              ),
              _documentButton(
                JobFinancialDocumentType.receipt,
                Icons.receipt_outlined,
                t('Receipt', 'রসিদ'),
              ),
            ],
          ),
          if (_busy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    ),
  );

  Widget _documentButton(
    JobFinancialDocumentType type,
    IconData icon,
    String label,
  ) => OutlinedButton.icon(
    onPressed: _busy ? null : () => _export(type),
    icon: Icon(icon),
    label: Text(label),
  );

  Future<void> _setStatus(JobStatus status) async {
    final job = _job;
    if (job == null || job.status == status) return;
    setState(() => _busy = true);
    try {
      await _persistStatus(job.id, status);
      if (!mounted) return;
      setState(() => _job = job.copyWith(status: status));
      _invalidate();
      AppFeedback.success(
        context,
        t('Job status updated.', 'জব স্ট্যাটাস আপডেট হয়েছে।'),
      );
    } catch (_) {
      if (mounted) {
        AppFeedback.error(
          context,
          t('Status was not saved.', 'স্ট্যাটাস সেভ হয়নি।'),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveVat() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(jobFinanceRepositoryProvider)
          .saveVatBasisPoints(widget.jobId, _vatBasisPoints);
      if (mounted) {
        AppFeedback.success(context, t('VAT saved.', 'ভ্যাট সেভ হয়েছে।'));
      }
    } catch (_) {
      if (mounted) {
        AppFeedback.error(context, t('VAT was not saved.', 'ভ্যাট সেভ হয়নি।'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addExpense() async {
    final result = await _amountDialog(
      title: t('Add expense', 'খরচ যোগ করুন'),
      label: t('Description', 'বিবরণ'),
      amountLabel: t('Amount', 'পরিমাণ'),
    );
    if (result == null) return;
    final amount = Money.tryParse(
      result.amount,
      currencyCode: _currency,
    )?.minorUnits;
    if (amount == null || amount <= 0 || result.label.trim().isEmpty) {
      AppFeedback.error(
        context,
        t('Enter a valid description and amount.', 'সঠিক বিবরণ ও পরিমাণ দিন।'),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(jobFinanceRepositoryProvider)
          .addExpense(
            jobId: widget.jobId,
            description: result.label,
            amountMinor: amount,
          );
      await _reloadLedger();
    } catch (_) {
      if (mounted) {
        AppFeedback.error(
          context,
          t('Expense was not saved.', 'খরচ সেভ হয়নি।'),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteExpense(String id) async {
    setState(() => _busy = true);
    try {
      await ref.read(jobFinanceRepositoryProvider).deleteExpense(id);
      await _reloadLedger();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addPayment() async {
    final job = _job;
    if (job == null) return;
    final result = await _paymentDialog();
    if (result == null) return;
    final amount = Money.tryParse(
      result.amount,
      currencyCode: _currency,
    )?.minorUnits;
    if (amount == null || amount <= 0) {
      AppFeedback.error(
        context,
        t('Enter a valid payment amount.', 'সঠিক পেমেন্ট পরিমাণ দিন।'),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(jobFinanceRepositoryProvider)
          .saveVatBasisPoints(job.id, _vatBasisPoints);
      final invoice = await _issueInvoice();
      await ref
          .read(jobFinanceRepositoryProvider)
          .addPayment(
            invoiceId: invoice.id,
            amountMinor: amount,
            method: result.method,
            reference: result.reference,
          );
      await _reloadLedger();
      final status = _paidMinor >= _totalMinor && _totalMinor > 0
          ? JobStatus.paid
          : JobStatus.partiallyPaid;
      await _persistStatus(job.id, status);
      if (mounted) setState(() => _job = job.copyWith(status: status));
      _invalidate();
      if (mounted) {
        AppFeedback.success(context, t('Payment saved.', 'পেমেন্ট সেভ হয়েছে।'));
      }
    } catch (_) {
      if (mounted) {
        AppFeedback.error(
          context,
          t('Payment was not saved.', 'পেমেন্ট সেভ হয়নি।'),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveSignature() async {
    if (_signaturePoints.isEmpty) return;
    setState(() => _busy = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary = _signatureKey.currentContext?.findRenderObject();
      if (boundary is! RenderRepaintBoundary || !boundary.hasSize) {
        throw StateError('Signature is not ready.');
      }
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (data == null) throw StateError('Signature capture failed.');
      await ref
          .read(jobFinanceRepositoryProvider)
          .saveSignature(widget.jobId, data.buffer.asUint8List());
      await _reloadLedger();
      if (mounted) {
        setState(() {
          _editingSignature = false;
          _signaturePoints.clear();
        });
        AppFeedback.success(
          context,
          t('Signature saved.', 'স্বাক্ষর সেভ হয়েছে।'),
        );
      }
    } catch (_) {
      if (mounted) {
        AppFeedback.error(
          context,
          t('Signature was not saved.', 'স্বাক্ষর সেভ হয়নি।'),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _export(JobFinancialDocumentType type) async {
    final job = _job;
    final customer = _customer;
    if (job == null || customer == null) return;
    if (type == JobFinancialDocumentType.receipt && _ledger.payments.isEmpty) {
      AppFeedback.info(
        context,
        t(
          'Add a payment before creating a receipt.',
          'রসিদ তৈরির আগে পেমেন্ট যোগ করুন।',
        ),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final repository = ref.read(jobFinanceRepositoryProvider);
      await repository.saveVatBasisPoints(job.id, _vatBasisPoints);
      var reference = 'CONF-${_short(job.id)}';
      switch (type) {
        case JobFinancialDocumentType.quote:
          reference = await repository.issueQuote(
            jobId: job.id,
            customerId: job.customerId,
            description: job.title,
            subtotalMinor: _subtotalMinor,
            taxMinor: _taxMinor,
            totalMinor: _totalMinor,
            snapshot: _snapshot(),
          );
          await _advanceStatus(JobStatus.quoted);
          break;
        case JobFinancialDocumentType.confirmation:
          await _advanceStatus(JobStatus.accepted);
          break;
        case JobFinancialDocumentType.invoice:
          final invoice = await _issueInvoice();
          reference = invoice.number;
          await _advanceStatus(
            _paidMinor >= _totalMinor && _totalMinor > 0
                ? JobStatus.paid
                : _paidMinor > 0
                ? JobStatus.partiallyPaid
                : JobStatus.invoiced,
          );
          break;
        case JobFinancialDocumentType.receipt:
          final payment = _ledger.payments.first;
          reference = await repository.issueReceipt(payment, _snapshot());
          break;
      }
      await _reloadLedger();
      final value = JobFinancialDocument(
        type: type,
        reference: reference,
        jobReference: job.id,
        jobTitle: job.title,
        jobStatus: _job?.status.name ?? job.status.name,
        jobDescription: job.description,
        workAddress: job.address,
        customerName: customer.name,
        customerPhone: customer.phone,
        customerEmail: customer.email,
        customerAddress: customer.address,
        currencyCode: _currency,
        workSubtotalMinor: _workSubtotalMinor,
        expensesMinor: _expensesMinor,
        vatBasisPoints: _vatBasisPoints,
        taxMinor: _taxMinor,
        totalMinor: _totalMinor,
        paidMinor: _paidMinor,
        outstandingMinor: _outstandingMinor,
        expenses: [
          for (final item in _ledger.expenses)
            JobDocumentExpense(
              description: item.description,
              amountMinor: item.amountMinor,
            ),
        ],
        payments: [
          for (final item in _ledger.payments)
            JobDocumentPayment(
              amountMinor: item.amountMinor,
              method: item.method,
              paidAtUtc: item.paidAtUtc,
              reference: item.reference,
            ),
        ],
        businessName: _business.displayName,
        businessPhone: _business.phone,
        businessEmail: _business.email,
        businessWebsite: _business.website,
        businessAddress: _business.address,
        businessLogoBytes: _business.logoBytes,
        signatureBytes: _ledger.signatureBytes,
      );
      final export = await ref
          .read(reportExportServiceProvider)
          .createJobFinancialDocument(value);
      if (!mounted) return;
      final size = MediaQuery.sizeOf(context);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(export.path)],
          subject: '${_documentLabel(type)}: ${job.title}',
          text: 'WorkProof ${_documentLabel(type)} · $reference',
          sharePositionOrigin: Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: 1,
            height: 1,
          ),
        ),
      );
      if (mounted) {
        AppFeedback.success(
          context,
          t(
            'PDF saved and ready to share.',
            'পিডিএফ সেভ হয়ে শেয়ারের জন্য প্রস্তুত।',
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        AppFeedback.error(
          context,
          t('PDF could not be created.', 'পিডিএফ তৈরি হয়নি।'),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<JobInvoiceRecord> _issueInvoice() {
    final job = _job!;
    return ref
        .read(jobFinanceRepositoryProvider)
        .issueInvoice(
          jobId: job.id,
          customerId: job.customerId,
          description: job.title,
          subtotalMinor: _subtotalMinor,
          taxMinor: _taxMinor,
          totalMinor: _totalMinor,
          snapshot: _snapshot(),
        );
  }

  Map<String, Object?> _snapshot() => {
    'jobId': widget.jobId,
    'currencyCode': _currency,
    'workSubtotalMinor': _workSubtotalMinor,
    'expensesMinor': _expensesMinor,
    'vatBasisPoints': _vatBasisPoints,
    'taxMinor': _taxMinor,
    'totalMinor': _totalMinor,
    'paidMinor': _paidMinor,
    'outstandingMinor': _outstandingMinor,
  };

  Future<void> _advanceStatus(JobStatus target) async {
    final job = _job;
    if (job == null || job.status == JobStatus.cancelled) return;
    if (_statusRank(target) < _statusRank(job.status)) return;
    await _persistStatus(job.id, target);
    if (mounted) setState(() => _job = job.copyWith(status: target));
    _invalidate();
  }

  Future<void> _persistStatus(String jobId, JobStatus status) async {
    await ref.read(jobRepositoryProvider).updateStatus(jobId, status);
    await ref.read(notificationControllerProvider.notifier).reconcile();
  }

  Future<void> _reloadLedger() async {
    final ledger = await ref
        .read(jobFinanceRepositoryProvider)
        .load(widget.jobId);
    if (mounted) setState(() => _ledger = ledger);
    ref.invalidate(reportControllerProvider);
    ref.invalidate(moneySummaryProvider);
  }

  void _invalidate() {
    invalidateWorkData(ref, flow: WorkFlow.tradesman);
    ref.invalidate(reportControllerProvider);
    ref.invalidate(moneySummaryProvider);
  }

  Future<_AmountResult?> _amountDialog({
    required String title,
    required String label,
    required String amountLabel,
  }) {
    return showDialog<_AmountResult>(
      context: context,
      builder: (_) => _AmountDialog(
        title: title,
        label: label,
        amountLabel: amountLabel,
        currency: _currency,
        cancelLabel: t('Cancel', 'বাতিল'),
        addLabel: t('Add', 'যোগ করুন'),
      ),
    );
  }

  Future<_PaymentResult?> _paymentDialog() {
    return showDialog<_PaymentResult>(
      context: context,
      builder: (_) => _PaymentDialog(
        initialAmount: AppFormatters.minorInput(
          _outstandingMinor,
          currencyCode: _currency,
        ),
        currency: _currency,
        title: t('Add payment', 'পেমেন্ট যোগ করুন'),
        amountLabel: t('Amount', 'পরিমাণ'),
        methodLabel: t('Method', 'পদ্ধতি'),
        referenceLabel: t('Reference (optional)', 'রেফারেন্স (ঐচ্ছিক)'),
        cancelLabel: t('Cancel', 'বাতিল'),
        saveLabel: t('Save', 'সেভ'),
      ),
    );
  }

  String _statusLabel(JobStatus status) => switch (status) {
    JobStatus.lead => t('Lead / received', 'নতুন কাজ'),
    JobStatus.quoted => t('Quote sent', 'কোট পাঠানো'),
    JobStatus.accepted => t('Accepted', 'গৃহীত'),
    JobStatus.scheduled => t('Scheduled', 'নির্ধারিত'),
    JobStatus.inProgress => t('In progress', 'কাজ চলছে'),
    JobStatus.paused => t('Paused', 'বিরতিতে'),
    JobStatus.completed => t('Completed', 'সম্পন্ন'),
    JobStatus.invoiced => t('Invoiced', 'ইনভয়েস পাঠানো'),
    JobStatus.partiallyPaid => t('Partially paid', 'আংশিক পরিশোধ'),
    JobStatus.paid => t('Paid', 'পরিশোধিত'),
    JobStatus.cancelled => t('Cancelled', 'বাতিল'),
  };

  String _documentLabel(JobFinancialDocumentType type) => switch (type) {
    JobFinancialDocumentType.quote => 'Quote',
    JobFinancialDocumentType.confirmation => 'Confirmation',
    JobFinancialDocumentType.invoice => 'Invoice',
    JobFinancialDocumentType.receipt => 'Receipt',
  };

  int _statusRank(JobStatus status) => switch (status) {
    JobStatus.lead => 0,
    JobStatus.quoted => 1,
    JobStatus.accepted => 2,
    JobStatus.scheduled => 3,
    JobStatus.inProgress || JobStatus.paused => 4,
    JobStatus.completed => 5,
    JobStatus.invoiced => 6,
    JobStatus.partiallyPaid => 7,
    JobStatus.paid => 8,
    JobStatus.cancelled => 99,
  };

  String _short(String value) {
    final safe = value.replaceAll(RegExp('[^A-Za-z0-9]'), '');
    return (safe.length <= 8 ? safe : safe.substring(0, 8)).toUpperCase();
  }
}

class _AmountResult {
  const _AmountResult(this.label, this.amount);
  final String label;
  final String amount;
}

class _PaymentResult {
  const _PaymentResult(this.amount, this.method, this.reference);
  final String amount;
  final String method;
  final String reference;
}

class _AmountDialog extends StatefulWidget {
  const _AmountDialog({
    required this.title,
    required this.label,
    required this.amountLabel,
    required this.currency,
    required this.cancelLabel,
    required this.addLabel,
  });

  final String title;
  final String label;
  final String amountLabel;
  final String currency;
  final String cancelLabel;
  final String addLabel;

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  final _label = TextEditingController();
  final _amount = TextEditingController();

  @override
  void dispose() {
    _label.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _label,
            decoration: InputDecoration(labelText: widget.label),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '${widget.amountLabel} (${widget.currency})',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.cancelLabel),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, _AmountResult(_label.text, _amount.text)),
          child: Text(widget.addLabel),
        ),
      ],
    );
  }
}

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({
    required this.initialAmount,
    required this.currency,
    required this.title,
    required this.amountLabel,
    required this.methodLabel,
    required this.referenceLabel,
    required this.cancelLabel,
    required this.saveLabel,
  });

  final String initialAmount;
  final String currency;
  final String title;
  final String amountLabel;
  final String methodLabel;
  final String referenceLabel;
  final String cancelLabel;
  final String saveLabel;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  late final TextEditingController _amount;
  final _reference = TextEditingController();
  String _method = 'bank';

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(text: widget.initialAmount);
  }

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amount,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '${widget.amountLabel} (${widget.currency})',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _method,
            decoration: InputDecoration(labelText: widget.methodLabel),
            items: [
              for (final value in const ['bank', 'cash', 'card', 'other'])
                DropdownMenuItem(value: value, child: Text(value)),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _method = value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reference,
            decoration: InputDecoration(labelText: widget.referenceLabel),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            _PaymentResult(_amount.text, _method, _reference.text),
          ),
          child: Text(widget.saveLabel),
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  const _SignaturePainter(this.points);
  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    final border = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
      border,
    );
    final ink = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (var index = 0; index < points.length - 1; index++) {
      final start = points[index];
      final end = points[index + 1];
      if (start != null && end != null) canvas.drawLine(start, end, ink);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
