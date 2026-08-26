import 'package:intl/intl.dart';

import '../money/currency_catalog.dart';

class AppFormatters {
  /// Legacy display helper. New financial domain code passes integer minor units.
  static String currency(double amount, {String symbol = '£'}) {
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
    return formatter.format(amount);
  }

  static String currencyMinor(
    int minorUnits, {
    required String currencyCode,
    String? locale,
  }) {
    final digits = CurrencyCatalog.fractionDigits(currencyCode);
    final formatter = NumberFormat.simpleCurrency(
      name: currencyCode,
      locale: locale,
      decimalDigits: digits,
    );
    return formatter.format(minorUnits / CurrencyCatalog.scale(currencyCode));
  }

  static String minorInput(int minorUnits, {required String currencyCode}) {
    final digits = CurrencyCatalog.fractionDigits(currencyCode);
    return (minorUnits / CurrencyCatalog.scale(currencyCode)).toStringAsFixed(
      digits,
    );
  }

  static String duration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }

  static String time(DateTime dt) => DateFormat('HH:mm').format(dt);

  static String date(DateTime dt) => DateFormat('d MMM yyyy').format(dt);

  static String dateShort(DateTime dt) => DateFormat('d MMM').format(dt);
}
