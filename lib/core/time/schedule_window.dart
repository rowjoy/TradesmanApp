/// A scheduled wall-clock interval with enough information to survive
/// overnight work, time-zone changes, and daylight-saving transitions.
class ScheduleWindow {
  const ScheduleWindow({
    required this.startLocal,
    required this.endLocal,
    required this.startUtc,
    required this.endUtc,
    required this.ianaTimeZone,
    required this.startOffsetMinutes,
    required this.endOffsetMinutes,
  });

  factory ScheduleWindow.fromLocal({
    required DateTime startLocal,
    required DateTime endLocal,
    required String ianaTimeZone,
    required int startOffsetMinutes,
    int? endOffsetMinutes,
  }) {
    final resolvedEndOffset = endOffsetMinutes ?? startOffsetMinutes;
    final startUtc = _wallTimeToUtc(startLocal, startOffsetMinutes);
    final endUtc = _wallTimeToUtc(endLocal, resolvedEndOffset);
    return ScheduleWindow(
      startLocal: _wallTime(startLocal),
      endLocal: _wallTime(endLocal),
      startUtc: startUtc,
      endUtc: endUtc,
      ianaTimeZone: ianaTimeZone,
      startOffsetMinutes: startOffsetMinutes,
      endOffsetMinutes: resolvedEndOffset,
    );
  }

  factory ScheduleWindow.fromMap(Map<String, Object?> map) {
    final startUtc = DateTime.parse(map['start_at_utc']! as String).toUtc();
    final endUtc = DateTime.parse(map['end_at_utc']! as String).toUtc();
    final startOffset = map['start_offset_minutes'] as int? ?? 0;
    final endOffset = map['end_offset_minutes'] as int? ?? startOffset;
    return ScheduleWindow(
      startLocal:
          _parseWallTime(map['start_local'] as String?) ??
          startUtc.add(Duration(minutes: startOffset)),
      endLocal:
          _parseWallTime(map['end_local'] as String?) ??
          endUtc.add(Duration(minutes: endOffset)),
      startUtc: startUtc,
      endUtc: endUtc,
      ianaTimeZone: map['iana_time_zone'] as String? ?? 'Etc/UTC',
      startOffsetMinutes: startOffset,
      endOffsetMinutes: endOffset,
    );
  }

  final DateTime startLocal;
  final DateTime endLocal;
  final DateTime startUtc;
  final DateTime endUtc;
  final String ianaTimeZone;
  final int startOffsetMinutes;
  final int endOffsetMinutes;

  Duration get elapsed => endUtc.difference(startUtc);
  bool get isValid => endUtc.isAfter(startUtc);
  bool get crossesLocalDate => !_sameDate(startLocal, endLocal);

  Map<String, Object?> toColumns() => {
    'start_at_utc': startUtc.toIso8601String(),
    'end_at_utc': endUtc.toIso8601String(),
    'start_local': _wallTime(startLocal).toIso8601String(),
    'end_local': _wallTime(endLocal).toIso8601String(),
    'iana_time_zone': ianaTimeZone,
    'start_offset_minutes': startOffsetMinutes,
    'end_offset_minutes': endOffsetMinutes,
  };

  static DateTime _wallTimeToUtc(DateTime value, int offsetMinutes) =>
      DateTime.utc(
        value.year,
        value.month,
        value.day,
        value.hour,
        value.minute,
        value.second,
        value.millisecond,
        value.microsecond,
      ).subtract(Duration(minutes: offsetMinutes));

  static DateTime _wallTime(DateTime value) => DateTime(
    value.year,
    value.month,
    value.day,
    value.hour,
    value.minute,
    value.second,
    value.millisecond,
    value.microsecond,
  );

  static DateTime? _parseWallTime(String? value) {
    if (value == null) return null;
    final parsed = DateTime.tryParse(value);
    return parsed == null ? null : _wallTime(parsed);
  }

  static bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
