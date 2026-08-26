import 'package:flutter_timezone/flutter_timezone.dart';

class TimeZoneOption {
  const TimeZoneOption(
    this.ianaName,
    this.standardOffsetMinutes,
    this.label, {
    this.usesEuropeanDst = false,
  });

  final String ianaName;
  final int standardOffsetMinutes;
  final String label;
  final bool usesEuropeanDst;
}

/// Small offline launch list. The IANA identifier is persisted, so a future
/// tz-data service can resolve historical transitions without a schema change.
const supportedTimeZones = <TimeZoneOption>[
  TimeZoneOption(
    'Europe/London',
    0,
    'Europe/London (UK)',
    usesEuropeanDst: true,
  ),
  TimeZoneOption('Etc/UTC', 0, 'Etc/UTC'),
  TimeZoneOption('Europe/Dublin', 0, 'Europe/Dublin', usesEuropeanDst: true),
  TimeZoneOption('Europe/Paris', 60, 'Europe/Paris', usesEuropeanDst: true),
  TimeZoneOption('Asia/Dhaka', 360, 'Asia/Dhaka'),
];

TimeZoneOption timeZoneOption(String ianaName) => supportedTimeZones.firstWhere(
  (zone) => zone.ianaName == ianaName,
  orElse: () => supportedTimeZones.first,
);

/// Offline launch-market offset suggestion. The chosen offsets are persisted
/// as the calculation snapshot and remain user-editable in the schedule form.
int suggestedOffsetMinutes(String ianaName, DateTime localWallTime) {
  final zone = timeZoneOption(ianaName);
  if (!zone.usesEuropeanDst) return zone.standardOffsetMinutes;
  final dstStart = _lastSunday(localWallTime.year, DateTime.march);
  final dstEnd = _lastSunday(localWallTime.year, DateTime.october);
  final day = DateTime(
    localWallTime.year,
    localWallTime.month,
    localWallTime.day,
  );
  final inSummer = !day.isBefore(dstStart) && day.isBefore(dstEnd);
  return zone.standardOffsetMinutes + (inSummer ? 60 : 0);
}

DateTime _lastSunday(int year, int month) {
  final last = DateTime(year, month + 1, 0);
  return last.subtract(Duration(days: last.weekday % DateTime.sunday));
}

/// Returns the IANA identifier configured by the operating system.
Future<String> deviceTimeZoneIdentifier() async {
  try {
    return (await FlutterTimezone.getLocalTimezone()).identifier;
  } catch (_) {
    return 'Etc/UTC';
  }
}

/// Resolves a future wall time with the device's own DST configuration.
int deviceOffsetMinutes(DateTime localWallTime) => DateTime(
  localWallTime.year,
  localWallTime.month,
  localWallTime.day,
  localWallTime.hour,
  localWallTime.minute,
  localWallTime.second,
).timeZoneOffset.inMinutes;
