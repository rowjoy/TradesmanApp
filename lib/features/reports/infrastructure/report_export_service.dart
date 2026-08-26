import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/ids/id_generator.dart';
import '../../../core/performance/background_task_runner.dart';
import '../../../core/time/app_clock.dart';
import '../data/report_repository.dart';
import '../domain/report_models.dart';

class ReportExportService {
  ReportExportService({
    required ReportRepository repository,
    required IdGenerator idGenerator,
    required AppClock clock,
  }) : _repository = repository,
       _idGenerator = idGenerator,
       _clock = clock;

  final ReportRepository _repository;
  final IdGenerator _idGenerator;
  final AppClock _clock;

  Future<PreparedReportExport> create(
    OfflineReport report,
    ReportExportFormat format,
  ) async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(root.path, 'workproof', 'reports'));
    await directory.create(recursive: true);
    final now = _clock.nowUtc();
    final id = _idGenerator.next();
    final stamp = _dateToken(report.filter.startUtc);
    final extension = format == ReportExportFormat.csv ? 'csv' : 'pdf';
    final filename =
        'workproof_${report.filter.scope.name}_${stamp}_$id.$extension';
    final outputPath = p.join(directory.path, filename);
    final request = _ReportExportRequest(
      report: report,
      format: format,
      outputPath: outputPath,
    );
    final digest = await BackgroundTaskRunner.run(
      () => _writeReport(request),
      debugName: 'workproof-report-export',
    );
    final export = PreparedReportExport(
      id: id,
      path: outputPath,
      filename: filename,
      sha256: digest,
      format: format,
      createdAtUtc: now,
    );
    await _repository.recordExport(export, report);
    return export;
  }

  Future<PreparedReportExport> createWorkOrder(
    WorkOrderDocument workOrder,
  ) async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(
      p.join(root.path, 'workproof', 'work_orders'),
    );
    await directory.create(recursive: true);
    final now = _clock.nowUtc();
    final id = _idGenerator.next();
    final filename =
        'workproof_work_${_fileToken(workOrder.reference)}_$id.pdf';
    final outputPath = p.join(directory.path, filename);
    final digest = await BackgroundTaskRunner.run(
      () => _writeWorkOrder(
        _WorkOrderExportRequest(
          workOrder: workOrder,
          outputPath: outputPath,
          generatedAtUtc: now,
        ),
      ),
      debugName: 'workproof-work-order-export',
    );
    return PreparedReportExport(
      id: id,
      path: outputPath,
      filename: filename,
      sha256: digest,
      format: ReportExportFormat.pdf,
      createdAtUtc: now,
    );
  }

  Future<PreparedReportExport> createJobFinancialDocument(
    JobFinancialDocument value,
  ) async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(root.path, 'workproof', 'documents'));
    await directory.create(recursive: true);
    final now = _clock.nowUtc();
    final id = _idGenerator.next();
    final filename =
        'workproof_${value.type.name}_${_fileToken(value.reference)}_$id.pdf';
    final outputPath = p.join(directory.path, filename);
    final bytes = await _jobFinancialPdf(value, generatedAtUtc: now);
    await File(outputPath).writeAsBytes(bytes, flush: true);
    return PreparedReportExport(
      id: id,
      path: outputPath,
      filename: filename,
      sha256: sha256.convert(bytes).toString(),
      format: ReportExportFormat.pdf,
      createdAtUtc: now,
    );
  }

  static String _dateToken(DateTime value) {
    final local = value.toLocal();
    return '${local.year.toString().padLeft(4, '0')}'
        '${local.month.toString().padLeft(2, '0')}'
        '${local.day.toString().padLeft(2, '0')}';
  }

  static String _fileToken(String value) {
    final safe = value.replaceAll(RegExp('[^A-Za-z0-9_-]'), '_');
    return safe.length <= 32 ? safe : safe.substring(0, 32);
  }
}

class WorkOrderDocument {
  const WorkOrderDocument({
    required this.reference,
    required this.title,
    required this.status,
    required this.priority,
    required this.pricingType,
    required this.currencyCode,
    required this.createdAtUtc,
    this.description,
    this.workAddress,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.customerAddress,
    this.serviceName,
    this.startLocal,
    this.endLocal,
    this.ianaTimeZone,
    this.hourlyRateMinor,
    this.fixedPriceMinor,
    this.notes,
  });

  final String reference;
  final String title;
  final String status;
  final String priority;
  final String pricingType;
  final String currencyCode;
  final DateTime createdAtUtc;
  final String? description;
  final String? workAddress;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? customerAddress;
  final String? serviceName;
  final DateTime? startLocal;
  final DateTime? endLocal;
  final String? ianaTimeZone;
  final int? hourlyRateMinor;
  final int? fixedPriceMinor;
  final String? notes;
}

enum JobFinancialDocumentType { quote, confirmation, invoice, receipt }

class JobDocumentExpense {
  const JobDocumentExpense({
    required this.description,
    required this.amountMinor,
  });

  final String description;
  final int amountMinor;
}

class JobDocumentPayment {
  const JobDocumentPayment({
    required this.amountMinor,
    required this.method,
    required this.paidAtUtc,
    this.reference,
  });

  final int amountMinor;
  final String method;
  final DateTime paidAtUtc;
  final String? reference;
}

class JobFinancialDocument {
  const JobFinancialDocument({
    required this.type,
    required this.reference,
    required this.jobReference,
    required this.jobTitle,
    required this.jobStatus,
    required this.customerName,
    required this.currencyCode,
    required this.workSubtotalMinor,
    required this.expensesMinor,
    required this.vatBasisPoints,
    required this.taxMinor,
    required this.totalMinor,
    required this.paidMinor,
    required this.outstandingMinor,
    required this.expenses,
    required this.payments,
    this.jobDescription,
    this.workAddress,
    this.customerPhone,
    this.customerEmail,
    this.customerAddress,
    this.businessName,
    this.businessPhone,
    this.businessEmail,
    this.businessWebsite,
    this.businessAddress,
    this.businessLogoBytes,
    this.signatureBytes,
  });

  final JobFinancialDocumentType type;
  final String reference;
  final String jobReference;
  final String jobTitle;
  final String jobStatus;
  final String customerName;
  final String currencyCode;
  final int workSubtotalMinor;
  final int expensesMinor;
  final int vatBasisPoints;
  final int taxMinor;
  final int totalMinor;
  final int paidMinor;
  final int outstandingMinor;
  final List<JobDocumentExpense> expenses;
  final List<JobDocumentPayment> payments;
  final String? jobDescription;
  final String? workAddress;
  final String? customerPhone;
  final String? customerEmail;
  final String? customerAddress;
  final String? businessName;
  final String? businessPhone;
  final String? businessEmail;
  final String? businessWebsite;
  final String? businessAddress;
  final Uint8List? businessLogoBytes;
  final Uint8List? signatureBytes;
}

class _ReportExportRequest {
  const _ReportExportRequest({
    required this.report,
    required this.format,
    required this.outputPath,
  });

  final OfflineReport report;
  final ReportExportFormat format;
  final String outputPath;
}

class _WorkOrderExportRequest {
  const _WorkOrderExportRequest({
    required this.workOrder,
    required this.outputPath,
    required this.generatedAtUtc,
  });

  final WorkOrderDocument workOrder;
  final String outputPath;
  final DateTime generatedAtUtc;
}

Future<String> _writeReport(_ReportExportRequest request) async {
  final Uint8List bytes;
  if (request.format == ReportExportFormat.csv) {
    bytes = Uint8List.fromList(utf8.encode(_csv(request.report)));
  } else {
    bytes = await _pdf(request.report);
  }
  final file = File(request.outputPath);
  await file.writeAsBytes(bytes, flush: true);
  return sha256.convert(bytes).toString();
}

Future<String> _writeWorkOrder(_WorkOrderExportRequest request) async {
  final bytes = await _workOrderPdf(request);
  await File(request.outputPath).writeAsBytes(bytes, flush: true);
  return sha256.convert(bytes).toString();
}

String _csv(OfflineReport report) {
  final buffer = StringBuffer()
    ..writeln(_csvRow(['WorkProof offline report']))
    ..writeln(_csvRow(['Scope', report.filter.scope.name]))
    ..writeln(
      _csvRow(['Range start UTC', report.filter.startUtc.toIso8601String()]),
    )
    ..writeln(
      _csvRow(['Range end UTC', report.filter.endUtc.toIso8601String()]),
    )
    ..writeln(_csvRow(['Currency', report.filter.currencyCode]))
    ..writeln(
      _csvRow(['Generated UTC', report.generatedAtUtc.toIso8601String()]),
    )
    ..writeln()
    ..writeln(
      _csvRow([
        'date_utc',
        'type',
        'party',
        'description',
        'reference',
        'recorded_seconds',
        'billable_seconds',
        'debit_minor',
        'credit_minor',
        'currency',
      ]),
    );
  for (final line in report.lines) {
    buffer.writeln(
      _csvRow([
        line.occurredAtUtc.toIso8601String(),
        line.type.name,
        line.partyName ?? '',
        line.title,
        line.reference ?? '',
        '${line.recordedSeconds}',
        '${line.billableSeconds}',
        '${line.debitMinor}',
        '${line.creditMinor}',
        line.currencyCode,
      ]),
    );
  }
  return buffer.toString();
}

String _csvRow(List<String> values) => values
    .map((value) {
      final escaped = value.replaceAll('"', '""');
      return '"$escaped"';
    })
    .join(',');

Future<Uint8List> _pdf(OfflineReport report) async {
  final document = pw.Document();
  final currency = report.filter.currencyCode;
  final selectedPartyName = report.parties
      .where(
        (party) =>
            party.id == report.filter.partyId &&
            party.type == report.filter.partyType,
      )
      .map((party) => party.name)
      .firstOrNull;
  String money(int value) => '$currency ${(value / 100).toStringAsFixed(2)}';
  String hours(int seconds) => (seconds / 3600).toStringAsFixed(2);

  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(34),
      header: (context) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'WORKPROOF',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal800,
            ),
          ),
          pw.Text('Offline report', style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
      ),
      build: (context) => [
        pw.SizedBox(height: 16),
        pw.Text(
          '${_pdfSafe(report.filter.scope.name).toUpperCase()} REPORT',
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          '${report.filter.startUtc.toLocal().toIso8601String().split('T').first} - '
          '${report.filter.endUtc.toLocal().subtract(const Duration(days: 1)).toIso8601String().split('T').first}',
        ),
        if (report.filter.hasParty)
          pw.Text(
            'Statement: ${_pdfSafe(selectedPartyName ?? 'Selected party')}',
          ),
        pw.SizedBox(height: 16),
        if (report.filter.scope != ReportScope.tradesman) ...[
          _pdfHeading('Worker pay summary'),
          _pdfSummaryGrid([
            ['Recorded hours', hours(report.worker.recordedSeconds)],
            ['Billable hours', hours(report.worker.billableSeconds)],
            ['Expected gross', money(report.worker.expectedGrossMinor)],
            ['Received gross', money(report.worker.receivedGrossMinor)],
            ['Deductions', money(report.worker.deductionsMinor)],
            ['Net payment', money(report.worker.netPaymentMinor)],
            [
              'Possible difference',
              money(report.worker.possibleDifferenceMinor),
            ],
          ]),
          pw.SizedBox(height: 14),
        ],
        if (report.filter.scope != ReportScope.worker) ...[
          _pdfHeading('Business income summary'),
          _pdfSummaryGrid([
            ['Recorded hours', hours(report.business.recordedSeconds)],
            ['Billable hours', hours(report.business.billableSeconds)],
            ['Billable work', money(report.business.billableWorkMinor)],
            ['Invoiced', money(report.business.invoicedMinor)],
            ['Paid', money(report.business.paidMinor)],
            ['Outstanding', money(report.business.outstandingMinor)],
            ['Expenses', money(report.business.expensesMinor)],
            ['Net cash', money(report.business.netCashMinor)],
          ]),
          pw.SizedBox(height: 14),
        ],
        if (report.worker.missingCalculationCount > 0 ||
            report.business.missingCalculationCount > 0)
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            margin: const pw.EdgeInsets.only(bottom: 12),
            color: PdfColors.amber50,
            child: pw.Text(
              'Some completed entries have no saved rate. Review totals before sharing.',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
        _pdfHeading('Statement lines'),
        if (report.lines.isEmpty)
          pw.Text('No records in this date range.')
        else
          _pdfLinesTable(report.lines, money: money, hours: hours),
        pw.SizedBox(height: 14),
        pw.Text(
          'Generated offline at ${report.generatedAtUtc.toIso8601String()}. '
          'Amounts are user-recorded records and are not legal, tax, or accounting advice.',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
      ],
    ),
  );
  return document.save();
}

Future<Uint8List> _workOrderPdf(_WorkOrderExportRequest request) async {
  final work = request.workOrder;
  final document = pw.Document();
  String money(int? value) => value == null
      ? 'Not set'
      : '${work.currencyCode} ${(value / 100).toStringAsFixed(2)}';
  String dateTime(DateTime? value) =>
      value?.toIso8601String().replaceFirst('T', ' ').split('.').first ??
      'Not set';
  final pricing = <List<String>>[
    ['Pricing type', work.pricingType],
    if (work.hourlyRateMinor != null)
      [
        work.pricingType == 'daily' ? 'Daily rate' : 'Hourly rate',
        money(work.hourlyRateMinor),
      ],
    if (work.fixedPriceMinor != null)
      ['Fixed price', money(work.fixedPriceMinor)],
  ];

  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(34),
      header: (context) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'WORKPROOF',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal800,
            ),
          ),
          pw.Text('Work confirmation', style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
      ),
      build: (_) => [
        pw.SizedBox(height: 16),
        pw.Text(
          'WORK DETAILS',
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Text(_pdfSafe(work.title), style: const pw.TextStyle(fontSize: 15)),
        pw.SizedBox(height: 16),
        _pdfHeading('Reference'),
        _pdfSummaryGrid([
          ['Work ID', _pdfSafe(work.reference)],
          ['Status', _pdfSafe(work.status)],
          ['Priority', _pdfSafe(work.priority)],
          ['Created UTC', work.createdAtUtc.toIso8601String()],
        ]),
        pw.SizedBox(height: 14),
        _pdfHeading('Customer'),
        _pdfSummaryGrid([
          ['Name', _pdfSafe(work.customerName ?? 'Not set')],
          ['Phone', _pdfSafe(work.customerPhone ?? 'Not set')],
          ['Email', _pdfSafe(work.customerEmail ?? 'Not set')],
          ['Address', _pdfSafe(work.customerAddress ?? 'Not set')],
        ]),
        pw.SizedBox(height: 14),
        _pdfHeading('Work'),
        _pdfSummaryGrid([
          ['Service', _pdfSafe(work.serviceName ?? 'Not set')],
          ['Work address', _pdfSafe(work.workAddress ?? 'Not set')],
          ['Description', _pdfSafe(work.description ?? 'Not set')],
          ['Start', dateTime(work.startLocal)],
          ['End', dateTime(work.endLocal)],
          ['Time zone', _pdfSafe(work.ianaTimeZone ?? 'Not set')],
        ]),
        pw.SizedBox(height: 14),
        _pdfHeading('Pricing'),
        _pdfSummaryGrid(pricing),
        if (work.notes?.trim().isNotEmpty == true) ...[
          pw.SizedBox(height: 14),
          _pdfHeading('Notes'),
          pw.Text(_pdfSafe(work.notes!.trim())),
        ],
        pw.SizedBox(height: 18),
        pw.Text(
          'Generated offline at ${request.generatedAtUtc.toIso8601String()}. '
          'This confirmation reflects information recorded by the user; review it before sharing.',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
      ],
    ),
  );
  return document.save();
}

Future<Uint8List> _jobFinancialPdf(
  JobFinancialDocument value, {
  required DateTime generatedAtUtc,
}) async {
  final document = pw.Document();
  final scale = value.currencyCode == 'JPY' ? 1 : 100;
  String money(int minor) =>
      '${value.currencyCode} ${(minor / scale).toStringAsFixed(scale == 1 ? 0 : 2)}';
  final title = switch (value.type) {
    JobFinancialDocumentType.quote => 'QUOTE',
    JobFinancialDocumentType.confirmation => 'WORK CONFIRMATION',
    JobFinancialDocumentType.invoice => 'INVOICE',
    JobFinancialDocumentType.receipt => 'PAYMENT RECEIPT',
  };
  final logo = value.businessLogoBytes == null
      ? null
      : pw.MemoryImage(value.businessLogoBytes!);
  final signature = value.signatureBytes == null
      ? null
      : pw.MemoryImage(value.signatureBytes!);
  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(34),
      header: (_) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Row(
            children: [
              if (logo != null) ...[
                pw.Container(
                  width: 34,
                  height: 34,
                  child: pw.Image(logo, fit: pw.BoxFit.contain),
                ),
                pw.SizedBox(width: 8),
              ],
              pw.Text(
                _pdfSafe(
                  value.businessName?.trim().isNotEmpty == true
                      ? value.businessName!.trim()
                      : 'WORKPROOF',
                ),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal800,
                ),
              ),
            ],
          ),
          pw.Text(title, style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
      footer: (context) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated offline by WorkProof',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ],
      ),
      build: (_) => [
        pw.SizedBox(height: 18),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Text('Reference: ${_pdfSafe(value.reference)}'),
        pw.SizedBox(height: 16),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: _pdfAddressBlock('FROM', [
                value.businessName ?? 'WorkProof user',
                value.businessAddress,
                value.businessPhone,
                value.businessEmail,
                value.businessWebsite,
              ]),
            ),
            pw.SizedBox(width: 16),
            pw.Expanded(
              child: _pdfAddressBlock('TO', [
                value.customerName,
                value.customerAddress,
                value.customerPhone,
                value.customerEmail,
              ]),
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        _pdfHeading('Job'),
        _pdfSummaryGrid([
          ['Job', _pdfSafe(value.jobTitle)],
          ['Job ID', _pdfSafe(value.jobReference)],
          ['Status', _pdfSafe(value.jobStatus)],
          if (value.jobDescription?.trim().isNotEmpty == true)
            ['Description', _pdfSafe(value.jobDescription!.trim())],
          if (value.workAddress?.trim().isNotEmpty == true)
            ['Work address', _pdfSafe(value.workAddress!.trim())],
        ]),
        pw.SizedBox(height: 16),
        _pdfHeading('Amounts'),
        _pdfSummaryGrid([
          ['Work subtotal', money(value.workSubtotalMinor)],
          ['Expenses', money(value.expensesMinor)],
          [
            'VAT (${(value.vatBasisPoints / 100).toStringAsFixed(2)}%)',
            money(value.taxMinor),
          ],
          ['Total', money(value.totalMinor)],
          ['Paid', money(value.paidMinor)],
          ['Outstanding', money(value.outstandingMinor)],
        ]),
        if (value.expenses.isNotEmpty) ...[
          pw.SizedBox(height: 16),
          _pdfHeading('Expenses'),
          _pdfSummaryGrid([
            for (final item in value.expenses)
              [_pdfSafe(item.description), money(item.amountMinor)],
          ]),
        ],
        if (value.payments.isNotEmpty) ...[
          pw.SizedBox(height: 16),
          _pdfHeading('Payments received'),
          _pdfSummaryGrid([
            for (final item in value.payments)
              [
                '${item.paidAtUtc.toLocal().toIso8601String().split('T').first} · ${_pdfSafe(item.method)}',
                money(item.amountMinor),
              ],
          ]),
        ],
        if (signature != null) ...[
          pw.SizedBox(height: 18),
          _pdfHeading('Signature'),
          pw.Container(
            width: 220,
            height: 80,
            padding: const pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
            ),
            child: pw.Image(signature, fit: pw.BoxFit.contain),
          ),
        ],
        pw.SizedBox(height: 18),
        pw.Text(
          'Generated at ${generatedAtUtc.toIso8601String()}. Review all amounts, tax, payment and customer details before sharing.',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
      ],
    ),
  );
  return document.save();
}

pw.Widget _pdfAddressBlock(String title, List<String?> values) {
  final lines = values
      .whereType<String>()
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
  return pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey100,
      border: pw.Border.all(color: PdfColors.grey300),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        for (final line in lines)
          pw.Text(_pdfSafe(line), style: const pw.TextStyle(fontSize: 9)),
      ],
    ),
  );
}

pw.Widget _pdfHeading(String value) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 7),
  child: pw.Text(
    value,
    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
  ),
);

pw.Widget _pdfSummaryGrid(List<List<String>> rows) => pw.Table(
  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
  children: [
    for (final row in rows)
      pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(row[0], style: const pw.TextStyle(fontSize: 9)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(
              row[1],
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
  ],
);

pw.Widget _pdfLinesTable(
  List<ReportLine> lines, {
  required String Function(int) money,
  required String Function(int) hours,
}) => pw.Table(
  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.4),
  columnWidths: const {
    0: pw.FlexColumnWidth(1.1),
    1: pw.FlexColumnWidth(1.1),
    2: pw.FlexColumnWidth(2.7),
    3: pw.FlexColumnWidth(0.8),
    4: pw.FlexColumnWidth(1.0),
    5: pw.FlexColumnWidth(1.0),
  },
  children: [
    pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.teal50),
      children: [
        for (final value in const [
          'Date',
          'Type',
          'Party / description',
          'Hours',
          'Debit',
          'Credit',
        ])
          _pdfCell(value, bold: true),
      ],
    ),
    for (final line in lines)
      pw.TableRow(
        children: [
          _pdfCell(
            line.occurredAtUtc.toLocal().toIso8601String().split('T').first,
          ),
          _pdfCell(line.type.name),
          _pdfCell(
            _pdfSafe(
              '${line.partyName == null ? '' : '${line.partyName} - '}${line.title}',
            ),
          ),
          _pdfCell(
            line.billableSeconds == 0 ? '' : hours(line.billableSeconds),
          ),
          _pdfCell(line.debitMinor == 0 ? '' : money(line.debitMinor)),
          _pdfCell(line.creditMinor == 0 ? '' : money(line.creditMinor)),
        ],
      ),
  ],
);

pw.Widget _pdfCell(String value, {bool bold = false}) => pw.Padding(
  padding: const pw.EdgeInsets.all(4),
  child: pw.Text(
    value,
    style: pw.TextStyle(
      fontSize: 7.5,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    ),
  ),
);

String _pdfSafe(String value) => value.runes
    .map((rune) => rune >= 32 && rune <= 126 ? String.fromCharCode(rune) : '?')
    .join();

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
