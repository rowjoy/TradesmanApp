import 'money.dart';

enum BillingRoundingDirection { down, nearest, up }

class BillingRoundingRule {
  const BillingRoundingRule({
    this.incrementSeconds = 60,
    this.direction = BillingRoundingDirection.nearest,
  }) : assert(incrementSeconds > 0);

  final int incrementSeconds;
  final BillingRoundingDirection direction;

  int apply(int rawSeconds) {
    if (rawSeconds <= 0) return 0;
    final quotient = rawSeconds ~/ incrementSeconds;
    final remainder = rawSeconds.remainder(incrementSeconds);
    switch (direction) {
      case BillingRoundingDirection.down:
        return quotient * incrementSeconds;
      case BillingRoundingDirection.up:
        return (quotient + (remainder == 0 ? 0 : 1)) * incrementSeconds;
      case BillingRoundingDirection.nearest:
        return (quotient + (remainder * 2 >= incrementSeconds ? 1 : 0)) *
            incrementSeconds;
    }
  }
}

class EarningsBreakdown {
  const EarningsBreakdown({
    required this.rawSeconds,
    required this.billableSeconds,
    required this.regularSeconds,
    required this.overtimeSeconds,
    required this.regularPay,
    required this.overtimePay,
  });

  final int rawSeconds;
  final int billableSeconds;
  final int regularSeconds;
  final int overtimeSeconds;
  final Money regularPay;
  final Money overtimePay;

  Money get total => regularPay + overtimePay;
}

class EarningsCalculator {
  const EarningsCalculator();

  EarningsBreakdown hourly({
    required int rawSeconds,
    required int unpaidBreakSeconds,
    required Money hourlyRate,
    int overtimeAfterSeconds = 8 * 60 * 60,
    int overtimeMultiplierNumerator = 3,
    int overtimeMultiplierDenominator = 2,
    BillingRoundingRule rounding = const BillingRoundingRule(),
  }) {
    if (rawSeconds < 0 || unpaidBreakSeconds < 0) {
      throw ArgumentError('Durations cannot be negative.');
    }
    final workedSeconds = (rawSeconds - unpaidBreakSeconds)
        .clamp(0, rawSeconds)
        .toInt();
    final billableSeconds = rounding.apply(workedSeconds);
    final regularSeconds = billableSeconds
        .clamp(0, overtimeAfterSeconds)
        .toInt();
    final overtimeSeconds = (billableSeconds - regularSeconds)
        .clamp(0, billableSeconds)
        .toInt();
    final regularPay = _payForSeconds(hourlyRate, regularSeconds);
    final overtimeHourlyRate = hourlyRate.multiplyRatio(
      overtimeMultiplierNumerator,
      overtimeMultiplierDenominator,
    );
    final overtimePay = _payForSeconds(overtimeHourlyRate, overtimeSeconds);

    return EarningsBreakdown(
      rawSeconds: rawSeconds,
      billableSeconds: billableSeconds,
      regularSeconds: regularSeconds,
      overtimeSeconds: overtimeSeconds,
      regularPay: regularPay,
      overtimePay: overtimePay,
    );
  }

  Money _payForSeconds(Money hourlyRate, int seconds) {
    final numerator = hourlyRate.minorUnits * seconds;
    const secondsPerHour = 3600;
    final roundedMinor = (numerator + secondsPerHour ~/ 2) ~/ secondsPerHour;
    return Money(
      minorUnits: roundedMinor,
      currencyCode: hourlyRate.currencyCode,
    );
  }
}
