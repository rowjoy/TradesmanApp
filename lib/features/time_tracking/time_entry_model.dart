import '../../core/money/earnings_calculator.dart';
import '../../core/money/work_earnings_calculator.dart';

enum TrackedWorkType { job, shift }

class CompletedClockOutStats {
  const CompletedClockOutStats({
    required this.count,
    required this.firstClockOutUtc,
    required this.latestClockOutUtc,
  });

  final int count;
  final DateTime? firstClockOutUtc;
  final DateTime? latestClockOutUtc;
}

TrackedWorkType trackedWorkTypeFromStorage(String value) =>
    TrackedWorkType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => TrackedWorkType.job,
    );

class WorkItemReference {
  const WorkItemReference({required this.type, required this.id});

  const WorkItemReference.job(String id)
    : this(type: TrackedWorkType.job, id: id);
  const WorkItemReference.shift(String id)
    : this(type: TrackedWorkType.shift, id: id);

  final TrackedWorkType type;
  final String id;

  String get entityTable => type == TrackedWorkType.job ? 'jobs' : 'shifts';
  String get idColumn => type == TrackedWorkType.job ? 'job_id' : 'shift_id';

  @override
  bool operator ==(Object other) =>
      other is WorkItemReference && other.type == type && other.id == id;

  @override
  int get hashCode => Object.hash(type, id);
}

class BreakEntry {
  const BreakEntry({
    required this.id,
    required this.timeEntryId,
    required this.breakStart,
    this.breakEnd,
    this.isPaid = false,
  });

  factory BreakEntry.fromMap(Map<String, Object?> map) => BreakEntry(
    id: map['id']! as String,
    timeEntryId: map['time_entry_id']! as String,
    breakStart: DateTime.parse(map['break_start']! as String).toUtc(),
    breakEnd: map['break_end'] == null
        ? null
        : DateTime.parse(map['break_end']! as String).toUtc(),
    isPaid: (map['is_paid'] as int? ?? 0) == 1,
  );

  final String id;
  final String timeEntryId;
  final DateTime breakStart;
  final DateTime? breakEnd;
  final bool isPaid;

  Duration durationAt(DateTime nowUtc) {
    final value = (breakEnd ?? nowUtc.toUtc()).difference(breakStart);
    return value.isNegative ? Duration.zero : value;
  }
}

class TimeEntry {
  const TimeEntry({
    required this.id,
    required this.workItem,
    required this.clockIn,
    required this.status,
    required this.pricingType,
    required this.currencyCode,
    required this.overtimeAfterSeconds,
    required this.overtimeMultiplierNumerator,
    required this.overtimeMultiplierDenominator,
    required this.premiumMultiplierNumerator,
    required this.premiumMultiplierDenominator,
    required this.roundingIncrementSeconds,
    required this.roundingDirection,
    required this.calculationEngineVersion,
    this.clockOut,
    this.scheduledStartAtUtc,
    this.scheduledEndAtUtc,
    this.baseRateMinor,
    this.fixedPriceMinor,
    this.extraPayMinor = 0,
    this.rawDurationSeconds,
    this.unpaidBreakSeconds,
    this.billableDurationSeconds,
    this.calculationSnapshotJson,
    this.correctionReason,
    this.manuallyEditedAtUtc,
    this.breaks = const [],
  });

  factory TimeEntry.fromMap(
    Map<String, Object?> map, {
    List<BreakEntry> breaks = const [],
  }) {
    final type = trackedWorkTypeFromStorage(
      map['work_item_type'] as String? ?? 'job',
    );
    final id = type == TrackedWorkType.job
        ? map['job_id']! as String
        : map['shift_id']! as String;
    return TimeEntry(
      id: map['id']! as String,
      workItem: WorkItemReference(type: type, id: id),
      clockIn: DateTime.parse(map['clock_in']! as String).toUtc(),
      clockOut: map['clock_out'] == null
          ? null
          : DateTime.parse(map['clock_out']! as String).toUtc(),
      status: map['status'] as String? ?? 'running',
      scheduledStartAtUtc: _date(map['scheduled_start_at_utc']),
      scheduledEndAtUtc: _date(map['scheduled_end_at_utc']),
      pricingType: workPricingTypeFromStorage(
        map['pricing_type'] as String? ?? 'hourly',
      ),
      currencyCode: map['currency_code'] as String? ?? 'GBP',
      baseRateMinor: map['base_rate_minor'] as int?,
      fixedPriceMinor: map['fixed_price_minor'] as int?,
      extraPayMinor: map['extra_pay_minor'] as int? ?? 0,
      overtimeAfterSeconds:
          map['overtime_after_seconds'] as int? ?? 8 * 60 * 60,
      overtimeMultiplierNumerator:
          map['overtime_multiplier_numerator'] as int? ?? 3,
      overtimeMultiplierDenominator:
          map['overtime_multiplier_denominator'] as int? ?? 2,
      premiumMultiplierNumerator:
          map['premium_multiplier_numerator'] as int? ?? 1,
      premiumMultiplierDenominator:
          map['premium_multiplier_denominator'] as int? ?? 1,
      roundingIncrementSeconds: map['rounding_increment_seconds'] as int? ?? 60,
      roundingDirection: map['rounding_direction'] as String? ?? 'nearest',
      calculationEngineVersion: map['calculation_engine_version'] as int? ?? 2,
      rawDurationSeconds: map['raw_duration_seconds'] as int?,
      unpaidBreakSeconds: map['unpaid_break_seconds'] as int?,
      billableDurationSeconds: map['billable_duration_seconds'] as int?,
      calculationSnapshotJson: map['calculation_snapshot_json'] as String?,
      correctionReason: map['correction_reason'] as String?,
      manuallyEditedAtUtc: _date(map['manually_edited_at_utc']),
      breaks: breaks,
    );
  }

  final String id;
  final WorkItemReference workItem;
  final DateTime clockIn;
  final DateTime? clockOut;
  final String status;
  final DateTime? scheduledStartAtUtc;
  final DateTime? scheduledEndAtUtc;
  final WorkPricingType pricingType;
  final String currencyCode;
  final int? baseRateMinor;
  final int? fixedPriceMinor;
  final int extraPayMinor;
  final int overtimeAfterSeconds;
  final int overtimeMultiplierNumerator;
  final int overtimeMultiplierDenominator;
  final int premiumMultiplierNumerator;
  final int premiumMultiplierDenominator;
  final int roundingIncrementSeconds;
  final String roundingDirection;
  final int calculationEngineVersion;
  final int? rawDurationSeconds;
  final int? unpaidBreakSeconds;
  final int? billableDurationSeconds;
  final String? calculationSnapshotJson;
  final String? correctionReason;
  final DateTime? manuallyEditedAtUtc;
  final List<BreakEntry> breaks;

  bool get isActive =>
      clockOut == null && (status == 'running' || status == 'paused');
  bool get isOnBreak => breaks.isNotEmpty && breaks.last.breakEnd == null;
  bool get wasCorrected => manuallyEditedAtUtc != null;

  Duration totalElapsedAt(DateTime nowUtc) {
    final value = (clockOut ?? nowUtc.toUtc()).difference(clockIn);
    return value.isNegative ? Duration.zero : value;
  }

  Duration unpaidBreakDurationAt(DateTime nowUtc) => breaks
      .where((entry) => !entry.isPaid)
      .fold(
        Duration.zero,
        (total, entry) => total + _breakWithinSession(entry, nowUtc),
      );

  Duration paidBreakDurationAt(DateTime nowUtc) => breaks
      .where((entry) => entry.isPaid)
      .fold(
        Duration.zero,
        (total, entry) => total + _breakWithinSession(entry, nowUtc),
      );

  Duration workedDurationAt(DateTime nowUtc) {
    final value = totalElapsedAt(nowUtc) - unpaidBreakDurationAt(nowUtc);
    return value.isNegative ? Duration.zero : value;
  }

  Duration billableDurationAt(DateTime nowUtc) => Duration(
    seconds: BillingRoundingRule(
      incrementSeconds: roundingIncrementSeconds,
      direction: _roundingDirection(roundingDirection),
    ).apply(workedDurationAt(nowUtc).inSeconds),
  );

  WorkEarningsResult earningsAt(DateTime nowUtc) {
    return const WorkEarningsCalculator().calculate(
      rawSeconds: totalElapsedAt(nowUtc).inSeconds,
      unpaidBreakSeconds: unpaidBreakDurationAt(nowUtc).inSeconds,
      currencyCode: currencyCode,
      pricingType: pricingType,
      baseRateMinor: baseRateMinor,
      fixedPriceMinor: fixedPriceMinor,
      extraPayMinor: extraPayMinor,
      overtimeAfterSeconds: overtimeAfterSeconds,
      overtimeMultiplierNumerator: overtimeMultiplierNumerator,
      overtimeMultiplierDenominator: overtimeMultiplierDenominator,
      premiumMultiplierNumerator: premiumMultiplierNumerator,
      premiumMultiplierDenominator: premiumMultiplierDenominator,
      rounding: BillingRoundingRule(
        incrementSeconds: roundingIncrementSeconds,
        direction: _roundingDirection(roundingDirection),
      ),
    );
  }

  Duration _breakWithinSession(BreakEntry entry, DateTime nowUtc) {
    final sessionEnd = clockOut ?? nowUtc.toUtc();
    final breakEnd = entry.breakEnd ?? nowUtc.toUtc();
    final start = entry.breakStart.isAfter(clockIn)
        ? entry.breakStart
        : clockIn;
    final end = breakEnd.isBefore(sessionEnd) ? breakEnd : sessionEnd;
    final value = end.difference(start);
    return value.isNegative ? Duration.zero : value;
  }
}

DateTime? _date(Object? value) =>
    value == null ? null : DateTime.tryParse(value as String)?.toUtc();

BillingRoundingDirection _roundingDirection(String value) =>
    BillingRoundingDirection.values.firstWhere(
      (direction) => direction.name == value,
      orElse: () => BillingRoundingDirection.nearest,
    );
