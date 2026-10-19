import 'dart:math' as math;

import 'currency_catalog.dart';

/// Deterministic currency value stored as integer minor units (pence/cents).
///
/// Currency conversion is intentionally outside this value object. Values with
/// different currency codes cannot be added or compared as money.
class Money implements Comparable<Money> {
  const Money({required this.minorUnits, required this.currencyCode});

  const Money.zero(this.currencyCode) : minorUnits = 0;

  final int minorUnits;
  final String currencyCode;

  static Money? tryParse(
    String input, {
    required String currencyCode,
    bool allowNegative = false,
  }) {
    final digits = CurrencyCatalog.fractionDigits(currencyCode);
    final normalized = input.trim().replaceAll(',', '');
    final pattern = digits == 0
        ? RegExp(r'^(-)?(\d+)$')
        : RegExp('^(-)?(\\d+)(?:\\.(\\d{0,$digits}))?\$');
    final match = pattern.firstMatch(normalized);
    if (match == null) return null;
    final isNegative = match.group(1) != null;
    if (isNegative && !allowNegative) return null;
    final major = int.tryParse(match.group(2)!);
    if (major == null) return null;
    final fraction = digits == 0
        ? ''
        : (match.group(3) ?? '').padRight(digits, '0');
    final minor = fraction.isEmpty ? 0 : int.parse(fraction);
    final value = major * CurrencyCatalog.scale(currencyCode) + minor;
    return Money(
      minorUnits: isNegative ? -value : value,
      currencyCode: currencyCode,
    );
  }

  Money operator +(Money other) {
    _requireSameCurrency(other);
    return Money(
      minorUnits: minorUnits + other.minorUnits,
      currencyCode: currencyCode,
    );
  }

  Money operator -(Money other) {
    _requireSameCurrency(other);
    return Money(
      minorUnits: minorUnits - other.minorUnits,
      currencyCode: currencyCode,
    );
  }

  Money multiplyRatio(int numerator, int denominator) {
    if (denominator <= 0) {
      throw ArgumentError.value(denominator, 'denominator', 'Must be positive');
    }
    final product = minorUnits * numerator;
    final sign = product.isNegative ? -1 : 1;
    final rounded = (product.abs() + denominator ~/ 2) ~/ denominator;
    return Money(minorUnits: rounded * sign, currencyCode: currencyCode);
  }

  Money clampToZero() =>
      Money(minorUnits: math.max(0, minorUnits), currencyCode: currencyCode);

  @override
  int compareTo(Money other) {
    _requireSameCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  void _requireSameCurrency(Money other) {
    if (currencyCode != other.currencyCode) {
      throw ArgumentError(
        'Currency mismatch: $currencyCode/${other.currencyCode}',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Money &&
      other.minorUnits == minorUnits &&
      other.currencyCode == currencyCode;

  @override
  int get hashCode => Object.hash(minorUnits, currencyCode);
}
