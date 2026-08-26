import 'dart:convert';

enum PayPeriodType { weekly, fortnightly, fourWeekly, monthly, custom }

enum PayPeriodStatus { open, reviewed, exported }

enum PayConfidence { complete, estimated, needsReview }

enum EvidenceType { note, photo, document, payslip, signature }

PayPeriodType payPeriodTypeFromStorage(String value) =>
    PayPeriodType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => PayPeriodType.custom,
    );

PayPeriodStatus payPeriodStatusFromStorage(String value) =>
    PayPeriodStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => PayPeriodStatus.open,
    );

PayConfidence payConfidenceFromStorage(String value) =>
    PayConfidence.values.firstWhere(
      (item) => item.name == value,
      orElse: () => PayConfidence.needsReview,
    );

EvidenceType evidenceTypeFromStorage(String value) =>
    EvidenceType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => EvidenceType.document,
    );

class PayCalculationBreakdown {
  const PayCalculationBreakdown({
    required this.recordedSeconds,
    required this.regularPayMinor,
    required this.overtimePayMinor,
    required this.premiumPayMinor,
    required this.allowancesMinor,
    required this.entryCount,
    required this.missingRateCount,
    required this.sourceTimeEntryIds,
  });

  factory PayCalculationBreakdown.fromJson(String? source) {
    if (source == null || source.isEmpty) return empty;
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) return empty;
    int integer(String key) => (decoded[key] as num?)?.toInt() ?? 0;
    final sourceIds = decoded['sourceTimeEntryIds'];
    return PayCalculationBreakdown(
      recordedSeconds: integer('recordedSeconds'),
      regularPayMinor: integer('regularPayMinor'),
      overtimePayMinor: integer('overtimePayMinor'),
      premiumPayMinor: integer('premiumPayMinor'),
      allowancesMinor: integer('allowancesMinor'),
      entryCount: integer('entryCount'),
      missingRateCount: integer('missingRateCount'),
      sourceTimeEntryIds: sourceIds is List
          ? sourceIds.whereType<String>().toList(growable: false)
          : const [],
    );
  }

  static const empty = PayCalculationBreakdown(
    recordedSeconds: 0,
    regularPayMinor: 0,
    overtimePayMinor: 0,
    premiumPayMinor: 0,
    allowancesMinor: 0,
    entryCount: 0,
    missingRateCount: 0,
    sourceTimeEntryIds: [],
  );

  final int recordedSeconds;
  final int regularPayMinor;
  final int overtimePayMinor;
  final int premiumPayMinor;
  final int allowancesMinor;
  final int entryCount;
  final int missingRateCount;
  final List<String> sourceTimeEntryIds;

  int get expectedGrossMinor =>
      regularPayMinor + overtimePayMinor + premiumPayMinor + allowancesMinor;

  Map<String, Object?> toJson() => {
    'recordedSeconds': recordedSeconds,
    'regularPayMinor': regularPayMinor,
    'overtimePayMinor': overtimePayMinor,
    'premiumPayMinor': premiumPayMinor,
    'allowancesMinor': allowancesMinor,
    'entryCount': entryCount,
    'missingRateCount': missingRateCount,
    'sourceTimeEntryIds': sourceTimeEntryIds,
  };
}

class PayPeriod {
  const PayPeriod({
    required this.id,
    required this.periodType,
    required this.startAtUtc,
    required this.endAtUtc,
    required this.expectedGrossMinor,
    required this.currencyCode,
    required this.status,
    required this.confidence,
    required this.breakdown,
    required this.createdAtUtc,
    this.employerId,
    this.employerName,
    this.receivedGrossMinor,
    this.deductionsMinor,
    this.netPaymentMinor,
    this.notes,
  });

  final String id;
  final String? employerId;
  final String? employerName;
  final PayPeriodType periodType;
  final DateTime startAtUtc;
  final DateTime endAtUtc;
  final int expectedGrossMinor;
  final int? receivedGrossMinor;
  final int? deductionsMinor;
  final int? netPaymentMinor;
  final String currencyCode;
  final PayPeriodStatus status;
  final PayConfidence confidence;
  final PayCalculationBreakdown breakdown;
  final String? notes;
  final DateTime createdAtUtc;

  int? get possibleDifferenceMinor => receivedGrossMinor == null
      ? null
      : expectedGrossMinor - receivedGrossMinor!;
}

class PayslipRecord {
  const PayslipRecord({
    required this.id,
    required this.payPeriodId,
    required this.currencyCode,
    required this.createdAtUtc,
    this.grossMinor,
    this.deductionsMinor,
    this.netMinor,
    this.payDateUtc,
    this.reference,
    this.attachmentId,
  });

  final String id;
  final String payPeriodId;
  final int? grossMinor;
  final int? deductionsMinor;
  final int? netMinor;
  final DateTime? payDateUtc;
  final String? reference;
  final String currencyCode;
  final String? attachmentId;
  final DateTime createdAtUtc;
}

class PayAdjustment {
  const PayAdjustment({
    required this.id,
    required this.type,
    required this.label,
    required this.amountMinor,
    required this.createdAtUtc,
  });

  final String id;
  final String type;
  final String label;
  final int amountMinor;
  final DateTime createdAtUtc;
}

class EvidenceAttachment {
  const EvidenceAttachment({
    required this.id,
    required this.originalFilename,
    required this.mimeType,
    required this.sizeBytes,
    required this.sha256,
    required this.localPath,
    required this.metadataStripped,
    required this.originalRetained,
    this.sharedCopyPath,
    this.sharedCopySha256,
  });

  final String id;
  final String originalFilename;
  final String mimeType;
  final int sizeBytes;
  final String sha256;
  final String localPath;
  final String? sharedCopyPath;
  final String? sharedCopySha256;
  final bool metadataStripped;
  final bool originalRetained;
}

class EvidenceItem {
  const EvidenceItem({
    required this.id,
    required this.type,
    required this.capturedAtUtc,
    required this.selectedForExport,
    this.description,
    this.attachment,
  });

  final String id;
  final EvidenceType type;
  final String? description;
  final DateTime capturedAtUtc;
  final bool selectedForExport;
  final EvidenceAttachment? attachment;
}

class PayPeriodDetail {
  const PayPeriodDetail({
    required this.period,
    required this.adjustments,
    required this.evidence,
    required this.auditEvents,
    this.payslip,
  });

  final PayPeriod period;
  final PayslipRecord? payslip;
  final List<PayAdjustment> adjustments;
  final List<EvidenceItem> evidence;
  final List<PayAuditEvent> auditEvents;

  int get evidenceCount => evidence.length;
}

class PayAuditEvent {
  const PayAuditEvent({
    required this.action,
    required this.summaryKey,
    required this.occurredAtUtc,
  });

  final String action;
  final String summaryKey;
  final DateTime occurredAtUtc;
}

class PreparedEvidenceFile {
  const PreparedEvidenceFile({
    required this.originalFilename,
    required this.mimeType,
    required this.sizeBytes,
    required this.sha256,
    required this.localPath,
    required this.metadataStripped,
    required this.originalRetained,
    this.sharedCopyPath,
    this.sharedCopySha256,
  });

  final String originalFilename;
  final String mimeType;
  final int sizeBytes;
  final String sha256;
  final String localPath;
  final String? sharedCopyPath;
  final String? sharedCopySha256;
  final bool metadataStripped;
  final bool originalRetained;
}

class WorkProofExport {
  const WorkProofExport({
    required this.id,
    required this.pdfPath,
    required this.zipPath,
    required this.pdfSha256,
    required this.zipSha256,
    required this.generatedAtUtc,
  });

  final String id;
  final String pdfPath;
  final String zipPath;
  final String pdfSha256;
  final String zipSha256;
  final DateTime generatedAtUtc;
}
