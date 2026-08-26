import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/core/performance/day_bucket_index.dart';

void main() {
  test('counts overnight work on both touched dates', () {
    final counts = DayBucketIndex.countOverlaps(
      rangeStart: DateTime(2026, 8, 10),
      dayCount: 7,
      intervals: [
        (
          start: DateTime(2026, 8, 11, 22),
          end: DateTime(2026, 8, 12, 2),
        ),
      ],
    );

    expect(counts[20260811], 1);
    expect(counts[20260812], 1);
  });

  test('midnight end is exclusive and invalid ranges are ignored', () {
    final counts = DayBucketIndex.countOverlaps(
      rangeStart: DateTime(2026, 8, 10),
      dayCount: 7,
      intervals: [
        (
          start: DateTime(2026, 8, 13, 9),
          end: DateTime(2026, 8, 14),
        ),
        (
          start: DateTime(2026, 8, 15, 9),
          end: DateTime(2026, 8, 15, 9),
        ),
      ],
    );

    expect(counts[20260813], 1);
    expect(counts[20260814], isNull);
    expect(counts[20260815], isNull);
  });
}
