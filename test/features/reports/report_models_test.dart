import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/features/reports/domain/report_models.dart';

void main() {
  test('worker possible difference remains deterministic in minor units', () {
    const summary = WorkerReportSummary(
      recordedSeconds: 8 * 3600,
      billableSeconds: 8 * 3600,
      expectedGrossMinor: 12500,
      receivedGrossMinor: 12000,
      deductionsMinor: 1500,
      netPaymentMinor: 10500,
      missingCalculationCount: 0,
    );

    expect(summary.possibleDifferenceMinor, 500);
  });

  test('business net cash subtracts recorded expenses', () {
    const summary = BusinessReportSummary(
      recordedSeconds: 7200,
      billableSeconds: 7200,
      billableWorkMinor: 10000,
      invoicedMinor: 10000,
      paidMinor: 8000,
      outstandingMinor: 2000,
      expensesMinor: 1250,
      missingCalculationCount: 0,
    );

    expect(summary.netCashMinor, 6750);
  });

  test('report filter identity includes party and exclusive date range', () {
    final start = DateTime.utc(2026, 8, 10);
    final end = DateTime.utc(2026, 8, 17);
    final a = ReportFilter(
      startUtc: start,
      endUtc: end,
      preset: ReportRangePreset.weekly,
      scope: ReportScope.worker,
      currencyCode: 'GBP',
      partyType: ReportPartyType.employer,
      partyId: 'employer-1',
    );
    final b = a.copyWith();
    final allEmployers = a.copyWith(clearParty: true);

    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(allEmployers, isNot(a));
    expect(allEmployers.hasParty, isFalse);
  });
}
