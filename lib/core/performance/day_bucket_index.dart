/// Builds an end-exclusive overlap count in O(items + touched days), avoiding
/// a full list scan for every calendar cell.
abstract final class DayBucketIndex {
  static Map<int, int> countOverlaps({
    required DateTime rangeStart,
    required int dayCount,
    required Iterable<({DateTime start, DateTime end})> intervals,
  }) {
    final start = _day(rangeStart);
    final end = _nextDate(start, dayCount);
    final counts = <int, int>{};
    for (final interval in intervals) {
      if (!interval.end.isAfter(interval.start)) continue;
      var day = _day(interval.start);
      if (day.isBefore(start)) day = start;
      final last = _day(
        interval.end.subtract(const Duration(microseconds: 1)),
      );
      while (!day.isAfter(last) && day.isBefore(end)) {
        final key = dateKey(day);
        counts[key] = (counts[key] ?? 0) + 1;
        day = _nextDate(day, 1);
      }
    }
    return counts;
  }

  static int dateKey(DateTime value) =>
      (value.year * 10000) + (value.month * 100) + value.day;

  static DateTime _day(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  // Calendar-date construction stays correct over 23/25-hour DST days.
  static DateTime _nextDate(DateTime value, int days) =>
      DateTime(value.year, value.month, value.day + days);
}
