import '../../core/time/schedule_window.dart';

enum JobStatus {
  lead,
  quoted,
  accepted,
  scheduled,
  inProgress,
  paused,
  completed,
  invoiced,
  partiallyPaid,
  paid,
  cancelled,
}

enum PricingType { hourly, daily, fixed, mixed }

JobStatus jobStatusFromString(String value) {
  return JobStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => JobStatus.scheduled,
  );
}

PricingType pricingTypeFromString(String value) {
  return PricingType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => PricingType.hourly,
  );
}

class Job {
  final String id;
  final String customerId;
  final String? serviceId;
  final String title;
  final String? description;
  final String? address;
  final DateTime? scheduledDate;
  final String? startTime;
  final ScheduleWindow? schedule;
  final int? estimatedDurationMinutes;
  final String priority;
  final PricingType pricingType;
  final int? hourlyRateMinor;
  final int? fixedPriceMinor;
  final JobStatus status;
  final bool remindersEnabled;
  final bool reminderUsesGlobalDefaults;
  final int reminderPreviewOffsetSeconds;
  final int reminderPrepareOffsetSeconds;
  final int reminderStartOffsetSeconds;
  final bool reminderMorningEnabled;
  final bool reminderEndEnabled;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Job({
    required this.id,
    required this.customerId,
    this.serviceId,
    required this.title,
    this.description,
    this.address,
    this.scheduledDate,
    this.startTime,
    this.schedule,
    this.estimatedDurationMinutes,
    this.priority = 'normal',
    this.pricingType = PricingType.hourly,
    this.hourlyRateMinor,
    this.fixedPriceMinor,
    this.status = JobStatus.scheduled,
    this.remindersEnabled = true,
    this.reminderUsesGlobalDefaults = true,
    this.reminderPreviewOffsetSeconds = 86400,
    this.reminderPrepareOffsetSeconds = 7200,
    this.reminderStartOffsetSeconds = 1800,
    this.reminderMorningEnabled = true,
    this.reminderEndEnabled = true,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Job.fromMap(Map<String, dynamic> map) {
    final hasWindow = map['start_at_utc'] != null && map['end_at_utc'] != null;
    return Job(
      id: map['id'] as String,
      customerId: map['customer_id'] as String,
      serviceId: map['service_id'] as String?,
      title: map['title'] as String,
      description: map['description'] as String?,
      address: map['address'] as String?,
      scheduledDate: map['scheduled_date'] != null
          ? DateTime.tryParse(map['scheduled_date'] as String)
          : null,
      startTime: map['start_time'] as String?,
      schedule: hasWindow
          ? ScheduleWindow.fromMap(map.cast<String, Object?>())
          : null,
      estimatedDurationMinutes: map['estimated_duration_minutes'] as int?,
      priority: map['priority'] as String? ?? 'normal',
      pricingType: pricingTypeFromString(
        map['pricing_type'] as String? ?? 'hourly',
      ),
      hourlyRateMinor:
          (map['hourly_rate_minor'] as int?) ??
          ((map['hourly_rate'] as num?)?.toDouble() == null
              ? null
              : ((map['hourly_rate'] as num).toDouble() * 100).round()),
      fixedPriceMinor:
          (map['fixed_price_minor'] as int?) ??
          ((map['fixed_price'] as num?)?.toDouble() == null
              ? null
              : ((map['fixed_price'] as num).toDouble() * 100).round()),
      status: jobStatusFromString(map['status'] as String? ?? 'scheduled'),
      remindersEnabled: (map['reminders_enabled'] as int? ?? 1) == 1,
      reminderUsesGlobalDefaults:
          (map['reminder_uses_global_defaults'] as int? ?? 1) == 1,
      reminderPreviewOffsetSeconds:
          map['reminder_preview_offset_seconds'] as int? ?? 86400,
      reminderPrepareOffsetSeconds:
          map['reminder_prepare_offset_seconds'] as int? ?? 7200,
      reminderStartOffsetSeconds:
          map['reminder_start_offset_seconds'] as int? ?? 1800,
      reminderMorningEnabled:
          (map['reminder_morning_enabled'] as int? ?? 1) == 1,
      reminderEndEnabled: (map['reminder_end_enabled'] as int? ?? 1) == 1,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'service_id': serviceId,
      'title': title,
      'description': description,
      'address': address,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'start_time': startTime,
      if (schedule != null) ...schedule!.toColumns(),
      'estimated_duration_minutes': estimatedDurationMinutes,
      'priority': priority,
      'pricing_type': pricingType.name,
      // Legacy REAL columns are intentionally no longer authoritative.
      'hourly_rate': null,
      'fixed_price': null,
      'hourly_rate_minor': hourlyRateMinor,
      'fixed_price_minor': fixedPriceMinor,
      'status': status.name,
      'reminders_enabled': remindersEnabled ? 1 : 0,
      'reminder_uses_global_defaults': reminderUsesGlobalDefaults ? 1 : 0,
      'reminder_preview_offset_seconds': reminderPreviewOffsetSeconds,
      'reminder_prepare_offset_seconds': reminderPrepareOffsetSeconds,
      'reminder_start_offset_seconds': reminderStartOffsetSeconds,
      'reminder_morning_enabled': reminderMorningEnabled ? 1 : 0,
      'reminder_end_enabled': reminderEndEnabled ? 1 : 0,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_status': 'pendingCreate',
      'version': 1,
    };
  }

  Job copyWith({
    String? customerId,
    String? serviceId,
    String? title,
    String? description,
    String? address,
    DateTime? scheduledDate,
    String? startTime,
    ScheduleWindow? schedule,
    int? estimatedDurationMinutes,
    String? priority,
    PricingType? pricingType,
    int? hourlyRateMinor,
    int? fixedPriceMinor,
    JobStatus? status,
    bool? remindersEnabled,
    bool? reminderUsesGlobalDefaults,
    int? reminderPreviewOffsetSeconds,
    int? reminderPrepareOffsetSeconds,
    int? reminderStartOffsetSeconds,
    bool? reminderMorningEnabled,
    bool? reminderEndEnabled,
    String? notes,
    DateTime? updatedAt,
  }) {
    return Job(
      id: id,
      customerId: customerId ?? this.customerId,
      serviceId: serviceId ?? this.serviceId,
      title: title ?? this.title,
      description: description ?? this.description,
      address: address ?? this.address,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      startTime: startTime ?? this.startTime,
      schedule: schedule ?? this.schedule,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      priority: priority ?? this.priority,
      pricingType: pricingType ?? this.pricingType,
      hourlyRateMinor: hourlyRateMinor ?? this.hourlyRateMinor,
      fixedPriceMinor: fixedPriceMinor ?? this.fixedPriceMinor,
      status: status ?? this.status,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderUsesGlobalDefaults:
          reminderUsesGlobalDefaults ?? this.reminderUsesGlobalDefaults,
      reminderPreviewOffsetSeconds:
          reminderPreviewOffsetSeconds ?? this.reminderPreviewOffsetSeconds,
      reminderPrepareOffsetSeconds:
          reminderPrepareOffsetSeconds ?? this.reminderPrepareOffsetSeconds,
      reminderStartOffsetSeconds:
          reminderStartOffsetSeconds ?? this.reminderStartOffsetSeconds,
      reminderMorningEnabled:
          reminderMorningEnabled ?? this.reminderMorningEnabled,
      reminderEndEnabled: reminderEndEnabled ?? this.reminderEndEnabled,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
    );
  }
}
