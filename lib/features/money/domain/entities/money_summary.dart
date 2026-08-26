class MoneySummary {
  const MoneySummary({
    required this.expectedEarningsMinor,
    required this.trackedSeconds,
    required this.completedEntries,
    required this.currencyCode,
    this.invoicedMinor = 0,
    this.paidMinor = 0,
    this.outstandingMinor = 0,
    this.expensesMinor = 0,
  });

  final int expectedEarningsMinor;
  final int trackedSeconds;
  final int completedEntries;
  final String currencyCode;
  final int invoicedMinor;
  final int paidMinor;
  final int outstandingMinor;
  final int expensesMinor;
}
