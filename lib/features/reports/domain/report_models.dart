enum ReportRangePreset { weekly, monthly, custom }

enum ReportScope { worker, tradesman, both }

enum ReportPartyType { employer, customer }

enum ReportLineType {
  workerTime,
  businessTime,
  payslip,
  invoice,
  payment,
  expense,
}

enum ReportExportFormat { csv, pdf }

class ReportFilter {
  const ReportFilter({
    required this.startUtc,
    required this.endUtc,
    required this.preset,
    required this.scope,
    required this.currencyCode,
    this.partyType,
    this.partyId,
  });

  final DateTime startUtc;
  final DateTime endUtc;
  final ReportRangePreset preset;
  final ReportScope scope;
  final String currencyCode;
  final ReportPartyType? partyType;
  final String? partyId;

  bool get hasParty => partyType != null && partyId != null;

  ReportFilter copyWith({
    DateTime? startUtc,
    DateTime? endUtc,
    ReportRangePreset? preset,
    ReportScope? scope,
    String? currencyCode,
    ReportPartyType? partyType,
    String? partyId,
    bool clearParty = false,
  }) => ReportFilter(
    startUtc: startUtc ?? this.startUtc,
    endUtc: endUtc ?? this.endUtc,
    preset: preset ?? this.preset,
    scope: scope ?? this.scope,
    currencyCode: currencyCode ?? this.currencyCode,
    partyType: clearParty ? null : partyType ?? this.partyType,
    partyId: clearParty ? null : partyId ?? this.partyId,
  );

  @override
  bool operator ==(Object other) =>
      other is ReportFilter &&
      other.startUtc == startUtc &&
      other.endUtc == endUtc &&
      other.preset == preset &&
      other.scope == scope &&
      other.currencyCode == currencyCode &&
      other.partyType == partyType &&
      other.partyId == partyId;

  @override
  int get hashCode => Object.hash(
    startUtc,
    endUtc,
    preset,
    scope,
    currencyCode,
    partyType,
    partyId,
  );
}

class ReportParty {
  const ReportParty({required this.id, required this.name, required this.type});

  final String id;
  final String name;
  final ReportPartyType type;
}

class ReportLine {
  const ReportLine({
    required this.id,
    required this.type,
    required this.occurredAtUtc,
    required this.title,
    required this.currencyCode,
    this.partyId,
    this.partyName,
    this.reference,
    this.recordedSeconds = 0,
    this.billableSeconds = 0,
    this.debitMinor = 0,
    this.creditMinor = 0,
  });

  final String id;
  final ReportLineType type;
  final DateTime occurredAtUtc;
  final String title;
  final String? partyId;
  final String? partyName;
  final String? reference;
  final int recordedSeconds;
  final int billableSeconds;
  final int debitMinor;
  final int creditMinor;
  final String currencyCode;
}

class WorkerReportSummary {
  const WorkerReportSummary({
    required this.recordedSeconds,
    required this.billableSeconds,
    required this.expectedGrossMinor,
    required this.receivedGrossMinor,
    required this.deductionsMinor,
    required this.netPaymentMinor,
    required this.missingCalculationCount,
  });

  static const empty = WorkerReportSummary(
    recordedSeconds: 0,
    billableSeconds: 0,
    expectedGrossMinor: 0,
    receivedGrossMinor: 0,
    deductionsMinor: 0,
    netPaymentMinor: 0,
    missingCalculationCount: 0,
  );

  final int recordedSeconds;
  final int billableSeconds;
  final int expectedGrossMinor;
  final int receivedGrossMinor;
  final int deductionsMinor;
  final int netPaymentMinor;
  final int missingCalculationCount;

  int get possibleDifferenceMinor => expectedGrossMinor - receivedGrossMinor;
}

class BusinessReportSummary {
  const BusinessReportSummary({
    required this.recordedSeconds,
    required this.billableSeconds,
    required this.billableWorkMinor,
    required this.invoicedMinor,
    required this.paidMinor,
    required this.outstandingMinor,
    required this.expensesMinor,
    required this.missingCalculationCount,
  });

  static const empty = BusinessReportSummary(
    recordedSeconds: 0,
    billableSeconds: 0,
    billableWorkMinor: 0,
    invoicedMinor: 0,
    paidMinor: 0,
    outstandingMinor: 0,
    expensesMinor: 0,
    missingCalculationCount: 0,
  );

  final int recordedSeconds;
  final int billableSeconds;
  final int billableWorkMinor;
  final int invoicedMinor;
  final int paidMinor;
  final int outstandingMinor;
  final int expensesMinor;
  final int missingCalculationCount;

  int get netCashMinor => paidMinor - expensesMinor;
}

class OfflineReport {
  const OfflineReport({
    required this.filter,
    required this.generatedAtUtc,
    required this.worker,
    required this.business,
    required this.lines,
    required this.parties,
  });

  final ReportFilter filter;
  final DateTime generatedAtUtc;
  final WorkerReportSummary worker;
  final BusinessReportSummary business;
  final List<ReportLine> lines;
  final List<ReportParty> parties;

  bool get isEmpty => lines.isEmpty;
}

class PreparedReportExport {
  const PreparedReportExport({
    required this.id,
    required this.path,
    required this.filename,
    required this.sha256,
    required this.format,
    required this.createdAtUtc,
  });

  final String id;
  final String path;
  final String filename;
  final String sha256;
  final ReportExportFormat format;
  final DateTime createdAtUtc;
}
