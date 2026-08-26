import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/core/money/money.dart';
import 'package:tradesman_manager/core/time/schedule_window.dart';

void main() {
  group('deterministic money', () {
    test('parses decimal input into integer minor units', () {
      final value = Money.tryParse('1,234.56', currencyCode: 'GBP');

      expect(value, const Money(minorUnits: 123456, currencyCode: 'GBP'));
    });

    test('does not accept negative input unless explicitly allowed', () {
      expect(Money.tryParse('-5.00', currencyCode: 'GBP'), isNull);
      expect(
        Money.tryParse(
          '-5.00',
          currencyCode: 'GBP',
          allowNegative: true,
        ),
        const Money(minorUnits: -500, currencyCode: 'GBP'),
      );
    });
  });

  test('schedule elapsed time follows saved UTC offsets across DST', () {
    final window = ScheduleWindow.fromLocal(
      startLocal: DateTime(2026, 3, 29, 1, 30),
      endLocal: DateTime(2026, 3, 29, 3, 30),
      ianaTimeZone: 'Europe/London',
      startOffsetMinutes: 0,
      endOffsetMinutes: 60,
    );

    expect(window.isValid, isTrue);
    expect(window.elapsed, const Duration(hours: 1));
  });
}
