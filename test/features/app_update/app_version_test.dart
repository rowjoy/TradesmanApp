import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/features/app_update/domain/app_version.dart';

void main() {
  group('NumericAppVersion', () {
    test('compares numeric components rather than text', () {
      expect(compareNumericAppVersions('1.10', '1.9'), greaterThan(0));
      expect(compareNumericAppVersions('2.0', '10.0'), lessThan(0));
    });

    test('normalizes omitted and trailing zero components', () {
      expect(compareNumericAppVersions('1.2', '1.2.0.0'), 0);
      expect(NumericAppVersion.parse('01.002.0').toString(), '1.2');
    });

    test('supports components larger than a machine integer', () {
      expect(
        compareNumericAppVersions('1.999999999999999999999999999999', '1.9'),
        greaterThan(0),
      );
    });

    test('fails closed for malformed store versions', () {
      expect(compareNumericAppVersions('1.2-beta', '1.1'), isNull);
      expect(compareNumericAppVersions('1..2', '1.1'), isNull);
      expect(
        isAvailableVersionNewer(
          installedVersion: '1.0.0',
          availableVersion: 'not-a-version',
        ),
        isFalse,
      );
    });
  });
}
