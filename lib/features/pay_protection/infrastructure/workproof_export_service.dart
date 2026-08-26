import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../core/money/currency_catalog.dart';
import '../../../core/performance/background_task_runner.dart';
import '../../../core/time/app_clock.dart';
import '../../../core/utils/formatters.dart';
import '../data/pay_protection_repository.dart';
import '../domain/pay_protection_models.dart';
import 'evidence_protection_service.dart';

class WorkProofExportService {
  WorkProofExportService(this._repository, this._clock, this._protection);

  final PayProtectionRepository _repository;
  final AppClock _clock;
  final EvidenceProtectionService _protection;

  Future<WorkProofExport> generate(PayPeriodDetail detail) async {
    final generatedAt = _clock.nowUtc();
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(
      p.join(root.path, 'workproof', 'exports', detail.period.id),
    );
    await directory.create(recursive: true);
    final stamp = generatedAt.toIso8601String().replaceAll(
      RegExp(r'[:.]'),
      '-',
    );
    final pdfPath = p.join(directory.path, 'WorkProof-$stamp.pdf');
    final zipPath = p.join(directory.path, 'WorkProof-$stamp.zip');
    final manifestPath = p.join(directory.path, 'manifest-$stamp.json');

    final pdfResult = await BackgroundTaskRunner.run(
      () async {
        final document = WorkProofExportService._buildPdf(detail, generatedAt);
        final bytes = await document.save();
        return (
          bytes: TransferableTypedData.fromList([bytes]),
          digest: sha256.convert(bytes).toString(),
        );
      },
      debugName: 'workproof-pdf-build',
    );
    final pdfBytes = pdfResult.bytes.materialize().asUint8List();
    await File(pdfPath).writeAsBytes(pdfBytes, flush: true);
    final pdfDigest = pdfResult.digest;

    final selectedEvidence = detail.evidence
        .where((item) => item.selectedForExport)
        .toList(growable: false);
    final manifest = <String, Object?>{
      'manifestVersion': 1,
      'generatedAtUtc': generatedAt.toIso8601String(),
      'workspaceId': PayProtectionRepository.workspaceId,
      'payPeriod': {
        'id': detail.period.id,
        'employerId': detail.period.employerId,
        'employerName': detail.period.employerName,
        'startAtUtc': detail.period.startAtUtc.toIso8601String(),
        'endAtUtc': detail.period.endAtUtc.toIso8601String(),
        'currencyCode': detail.period.currencyCode,
        'expectedGrossMinor': detail.period.expectedGrossMinor,
        'receivedGrossMinor': detail.period.receivedGrossMinor,
        'deductionsMinor': detail.period.deductionsMinor,
        'netPaymentMinor': detail.period.netPaymentMinor,
        'possibleDifferenceMinor': detail.period.possibleDifferenceMinor,
        'confidence': detail.period.confidence.name,
        'calculation': detail.period.breakdown.toJson(),
      },
      'files': [
        {
          'archivePath': 'summary/WorkProof-summary.pdf',
          'sha256': pdfDigest,
          'mimeType': 'application/pdf',
        },
        for (var index = 0; index < selectedEvidence.length; index++)
          if (selectedEvidence[index].attachment case final attachment?)
            {
              'evidenceId': selectedEvidence[index].id,
              'archivePath': _archiveEvidencePath(index, attachment),
              'originalFilename': attachment.originalFilename,
              'mimeType': attachment.mimeType,
              'originalSha256': attachment.sha256,
              'sharedCopySha256':
                  attachment.sharedCopySha256 ?? attachment.sha256,
              'metadataStripped': attachment.metadataStripped,
              'originalRetainedPrivately': attachment.originalRetained,
            },
      ],
      'evidence': [
        for (final item in selectedEvidence)
          {
            'id': item.id,
            'type': item.type.name,
            'description': item.description,
            'capturedAtUtc': item.capturedAtUtc.toIso8601String(),
            'attachmentId': item.attachment?.id,
          },
      ],
      'audit': [
        for (final event in detail.auditEvents)
          {
            'action': event.action,
            'summaryKey': event.summaryKey,
            'occurredAtUtc': event.occurredAtUtc.toIso8601String(),
          },
        {
          'action': 'exportGenerated',
          'summaryKey': 'auditWorkProofExported',
          'occurredAtUtc': generatedAt.toIso8601String(),
        },
      ],
      'disclaimer':
          'This pack is a user-created record, not legal advice or a finding of underpayment. Review original records and seek appropriate advice when needed.',
    };
    await File(
      manifestPath,
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(manifest));

    final archiveEntries = <({String sourcePath, String archivePath})>[
      (sourcePath: pdfPath, archivePath: 'summary/WorkProof-summary.pdf'),
      (sourcePath: manifestPath, archivePath: 'manifest.json'),
    ];
    final staging = Directory(p.join(directory.path, '.staging-$stamp'));
    final evidenceEntries =
        <({EvidenceAttachment attachment, String archivePath})>[];
    for (var index = 0; index < selectedEvidence.length; index++) {
      final attachment = selectedEvidence[index].attachment;
      if (attachment == null) continue;
      evidenceEntries.add((
        attachment: attachment,
        archivePath: _archiveEvidencePath(index, attachment),
      ));
    }
    late final String zipDigest;
    try {
      final materialized = await _protection.materializeForExport(
        entries: evidenceEntries,
        destination: staging,
      );
      archiveEntries.addAll([
        for (final entry in materialized)
          (sourcePath: entry.sourcePath, archivePath: entry.archivePath),
      ]);
      zipDigest = await BackgroundTaskRunner.run(
        () => _createZipInBackground(zipPath, archiveEntries),
        debugName: 'workproof-zip-build',
      );
    } finally {
      await _protection.cleanup(staging);
    }

    return _repository.recordExport(
      payPeriodId: detail.period.id,
      pdfPath: pdfPath,
      zipPath: zipPath,
      pdfSha256: pdfDigest,
      zipSha256: zipDigest,
      manifest: manifest,
    );
  }

  Future<void> share(
    WorkProofExport export, {
    Rect? sharePositionOrigin,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        subject: 'WorkProof evidence pack',
        text: 'WorkProof evidence pack — verify checksums in manifest.json.',
        files: [XFile(export.zipPath)],
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  static pw.Document _buildPdf(
    PayPeriodDetail detail,
    DateTime generatedAt,
  ) {
    final period = detail.period;
    final document = pw.Document();
    String money(int? minor) {
      if (minor == null) return 'Not recorded';
      final digits = CurrencyCatalog.fractionDigits(period.currencyCode);
      final major = minor / CurrencyCatalog.scale(period.currencyCode);
      return '${period.currencyCode} ${major.toStringAsFixed(digits)}';
    }

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
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
            pw.Text('Evidence pack', style: const pw.TextStyle(fontSize: 9)),
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
          pw.SizedBox(height: 18),
          pw.Text(
            'Pay Protection summary',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '${_pdfSafe(period.employerName ?? 'All employers')} | '
            '${AppFormatters.date(period.startAtUtc.toLocal())} - '
            '${AppFormatters.date(period.endAtUtc.toLocal().subtract(const Duration(days: 1)))}',
          ),
          pw.SizedBox(height: 18),
          _summaryBox('Expected gross', money(period.expectedGrossMinor)),
          pw.SizedBox(height: 8),
          _summaryBox('Received gross', money(period.receivedGrossMinor)),
          pw.SizedBox(height: 8),
          _summaryBox(
            'Possible difference',
            money(period.possibleDifferenceMinor),
            warning: (period.possibleDifferenceMinor ?? 0) != 0,
          ),
          pw.SizedBox(height: 18),
          _heading('Calculation record'),
          _line(
            'Recorded time',
            AppFormatters.duration(
              Duration(seconds: period.breakdown.recordedSeconds),
            ),
          ),
          _line('Regular pay', money(period.breakdown.regularPayMinor)),
          _line('Overtime pay', money(period.breakdown.overtimePayMinor)),
          _line('Premium pay', money(period.breakdown.premiumPayMinor)),
          _line(
            'Allowances / adjustments',
            money(
              period.expectedGrossMinor -
                  period.breakdown.regularPayMinor -
                  period.breakdown.overtimePayMinor -
                  period.breakdown.premiumPayMinor,
            ),
          ),
          _line('Deductions', money(period.deductionsMinor)),
          _line('Net payment', money(period.netPaymentMinor)),
          pw.SizedBox(height: 18),
          _heading('Evidence timeline'),
          if (detail.evidence.where((item) => item.selectedForExport).isEmpty)
            pw.Text('No evidence items selected for this export.'),
          for (final item in detail.evidence.where(
            (item) => item.selectedForExport,
          ))
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${item.type.name.toUpperCase()} | ${item.capturedAtUtc.toLocal().toIso8601String()}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  if (item.description != null)
                    pw.Text(_pdfSafe(item.description!)),
                  if (item.attachment != null)
                    pw.Text(
                      'SHA-256: ${item.attachment!.sha256}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                ],
              ),
            ),
          pw.SizedBox(height: 18),
          _heading('Audit summary'),
          if (detail.auditEvents.isEmpty)
            pw.Text('No audit events recorded for this period.'),
          for (final event in detail.auditEvents)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 5),
              child: pw.Text(
                '${event.occurredAtUtc.toIso8601String()} | ${_pdfSafe(event.action)}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
          pw.Text(
            '${generatedAt.toIso8601String()} | exportGenerated',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 18),
          _heading('Review note'),
          pw.Text(
            'A possible difference is a prompt to review the payslip and original records. It is not a legal conclusion or an accusation. Full UTF-8 notes and file checksums are preserved in manifest.json.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Generated offline at ${generatedAt.toIso8601String()}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ],
      ),
    );
    return document;
  }

  static pw.Widget _summaryBox(
    String label,
    String value, {
    bool warning = false,
  }) =>
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: warning ? PdfColors.amber50 : PdfColors.teal50,
          border: pw.Border.all(
            color: warning ? PdfColors.amber700 : PdfColors.teal700,
          ),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label),
            pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ],
        ),
      );

  static pw.Widget _heading(String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Text(
      value,
      style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
    ),
  );

  static pw.Widget _line(String label, String value) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 5),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [pw.Text(label), pw.Text(value)],
    ),
  );

  static String _archiveEvidencePath(int index, EvidenceAttachment attachment) {
    final extension = p.extension(attachment.originalFilename);
    final safe = p
        .basenameWithoutExtension(attachment.originalFilename)
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return 'evidence/${index + 1}_${safe.isEmpty ? 'file' : safe}$extension';
  }

  static String _pdfSafe(String value) => String.fromCharCodes(
    value.runes.map((rune) => rune >= 32 && rune <= 255 ? rune : 63),
  );
}

final workProofExportServiceProvider = Provider(
  (ref) => WorkProofExportService(
    ref.watch(payProtectionRepositoryProvider),
    ref.watch(appClockProvider),
    ref.watch(evidenceProtectionServiceProvider),
  ),
);

Future<String> _createZipInBackground(
  String zipPath,
  List<({String sourcePath, String archivePath})> entries,
) async {
  final encoder = ZipFileEncoder();
  encoder.create(zipPath);
  try {
    for (final entry in entries) {
      await encoder.addFile(File(entry.sourcePath), entry.archivePath);
    }
  } finally {
    await encoder.close();
  }
  return sha256.convert(await File(zipPath).readAsBytes()).toString();
}
