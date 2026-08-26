import 'earnings_calculator.dart';
import 'money.dart';

enum WorkPricingType { hourly, daily, fixed, mixed }

WorkPricingType workPricingTypeFromStorage(String value) =>
    WorkPricingType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => WorkPricingType.hourly,
    );

class WorkEarningsResult {
  const WorkEarningsResult({
    required this.rawSeconds,
    required this.unpaidBreakSeconds,
    required this.billableSeconds,
    required this.regularSeconds,
    required this.overtimeSeconds,
    required this.regularPay,
    required this.overtimePay,
    required this.premiumPay,
    required this.fixedPay,
    required this.extraPay,
  });

  final int rawSeconds;
  final int unpaidBreakSeconds;
  final int billableSeconds;
  final int regularSeconds;
  final int overtimeSeconds;
  final Money regularPay;
  final Money overtimePay;
  final Money premiumPay;
  final Money fixedPay;
  final Money extraPay;

  Money get total =>
      regularPay + overtimePay + premiumPay + fixedPay + extraPay;

  Map<String, Object> toSnapshot({required int engineVersion}) => {
    'engineVersion': engineVersion,
    'rawSeconds': rawSeconds,
    'unpaidBreakSeconds': unpaidBreakSeconds,
    'billableSeconds': billableSeconds,
    'regularSeconds': regularSeconds,
    'overtimeSeconds': overtimeSeconds,
    'regularPayMinor': regularPay.minorUnits,
    'overtimePayMinor': overtimePay.minorUnits,
    'premiumPayMinor': premiumPay.minorUnits,
    'fixedPayMinor': fixedPay.minorUnits,
    'extraPayMinor': extraPay.minorUnits,
    'totalMinor': total.minorUnits,
    'currencyCode': total.currencyCode,
  };
}

class WorkEarningsCalculator {
  const WorkEarningsCalculator();

  static const engineVersion = 2;

  WorkEarningsResult calculate({
    required int rawSeconds,
    required int unpaidBreakSeconds,
    required String currencyCode,
    required WorkPricingType pricingType,
    int? baseRateMinor,
    int? fixedPriceMinor,
    int extraPayMinor = 0,
    int overtimeAfterSeconds = 8 * 60 * 60,
    int overtimeMultiplierNumerator = 3,
    int overtimeMultiplierDenominator = 2,
    int premiumMultiplierNumerator = 1,
    int premiumMultiplierDenominator = 1,
    BillingRoundingRule rounding = const BillingRoundingRule(),
  }) {
    if (rawSeconds < 0 || unpaidBreakSeconds < 0 || extraPayMinor < 0) {
      throw ArgumentError('Durations cannot be negative.');
    }
    if (overtimeAfterSeconds < 0 ||
        overtimeMultiplierNumerator <= 0 ||
        overtimeMultiplierDenominator <= 0 ||
        premiumMultiplierNumerator <= 0 ||
        premiumMultiplierDenominator <= 0) {
      throw ArgumentError('Rate rules must use positive values.');
    }

    final zero = Money(minorUnits: 0, currencyCode: currencyCode);
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

    var regularPay = zero;
    var overtimePay = zero;
    var premiumPay = zero;
    if (pricingType == WorkPricingType.hourly ||
        pricingType == WorkPricingType.mixed) {
      final baseRate = Money(
        minorUnits: baseRateMinor ?? 0,
        currencyCode: currencyCode,
      );
      final premiumRate = baseRate.multiplyRatio(
        premiumMultiplierNumerator,
        premiumMultiplierDenominator,
      );
      final overtimeRate = premiumRate.multiplyRatio(
        overtimeMultiplierNumerator,
        overtimeMultiplierDenominator,
      );
      regularPay = _payForSeconds(baseRate, regularSeconds);
      overtimePay = _payForSeconds(
        baseRate.multiplyRatio(
          overtimeMultiplierNumerator,
          overtimeMultiplierDenominator,
        ),
        overtimeSeconds,
      );
      final premiumRegular = _payForSeconds(premiumRate, regularSeconds);
      final premiumOvertime = _payForSeconds(overtimeRate, overtimeSeconds);
      premiumPay =
          (premiumRegular + premiumOvertime) - (regularPay + overtimePay);
    } else if (pricingType == WorkPricingType.daily && billableSeconds > 0) {
      regularPay = Money(
        minorUnits: baseRateMinor ?? 0,
        currencyCode: currencyCode,
      );
    }

    final includesFixed =
        pricingType == WorkPricingType.fixed ||
        pricingType == WorkPricingType.mixed;
    final fixedPay = Money(
      minorUnits: includesFixed && billableSeconds > 0
          ? (fixedPriceMinor ?? 0)
          : 0,
      currencyCode: currencyCode,
    );
    final extraPay = Money(
      minorUnits: billableSeconds > 0 ? extraPayMinor : 0,
      currencyCode: currencyCode,
    );

    return WorkEarningsResult(
      rawSeconds: rawSeconds,
      unpaidBreakSeconds: unpaidBreakSeconds,
      billableSeconds: billableSeconds,
      regularSeconds: regularSeconds,
      overtimeSeconds: overtimeSeconds,
      regularPay: regularPay,
      overtimePay: overtimePay,
      premiumPay: premiumPay,
      fixedPay: fixedPay,
      extraPay: extraPay,
    );
  }

  Money _payForSeconds(Money hourlyRate, int seconds) {
    final numerator = hourlyRate.minorUnits * seconds;
    const secondsPerHour = 3600;
    return Money(
      minorUnits: (numerator + secondsPerHour ~/ 2) ~/ secondsPerHour,
      currencyCode: hourlyRate.currencyCode,
    );
  }
}
