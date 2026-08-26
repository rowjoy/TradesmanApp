import '../../../core/time/schedule_window.dart';

enum WorkFlow { worker, tradesman }

enum WorkItemStatus { scheduled, inProgress, completed, cancelled }

WorkItemStatus workItemStatusFromStorage(String value) =>
    WorkItemStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => WorkItemStatus.scheduled,
    );

class Employer {
  const Employer({
    required this.id,
    required this.name,
    this.contactName,
    this.phone,
    this.email,
    this.paySchedule,
    this.contractNotes,
    this.defaultRateMinor,
    this.officialReference,
  });

  factory Employer.fromMap(Map<String, Object?> map) => Employer(
    id: map['id']! as String,
    name: map['name']! as String,
    contactName: map['contact_name'] as String?,
    phone: map['phone'] as String?,
    email: map['email'] as String?,
    paySchedule: map['pay_schedule'] as String?,
    contractNotes: map['contract_notes'] as String?,
    defaultRateMinor: map['default_rate_minor'] as int?,
    officialReference: map['official_reference'] as String?,
  );

  final String id;
  final String name;
  final String? contactName;
  final String? phone;
  final String? email;
  final String? paySchedule;
  final String? contractNotes;
  final int? defaultRateMinor;
  final String? officialReference;
}

class Workplace {
  const Workplace({
    required this.id,
    required this.employerId,
    required this.name,
    required this.ianaTimeZone,
    this.address,
    this.notes,
  });

  factory Workplace.fromMap(Map<String, Object?> map) => Workplace(
    id: map['id']! as String,
    employerId: map['employer_id']! as String,
    name: map['name']! as String,
    address: map['address'] as String?,
    notes: map['notes'] as String?,
    ianaTimeZone: map['iana_time_zone'] as String? ?? 'Europe/London',
  );

  final String id;
  final String employerId;
  final String name;
  final String? address;
  final String? notes;
  final String ianaTimeZone;
}

class ServiceTemplate {
  const ServiceTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.pricingType,
    this.description,
    this.defaultRateMinor,
    this.defaultDurationMinutes,
  });

  factory ServiceTemplate.fromMap(Map<String, Object?> map) => ServiceTemplate(
    id: map['id']! as String,
    name: map['name']! as String,
    category: map['category'] as String? ?? 'General',
    pricingType: map['pricing_type'] as String? ?? 'hourly',
    description: map['description'] as String?,
    defaultRateMinor: map['default_rate_minor'] as int?,
    defaultDurationMinutes: map['default_duration_minutes'] as int?,
  );

  final String id;
  final String name;
  final String category;
  final String pricingType;
  final String? description;
  final int? defaultRateMinor;
  final int? defaultDurationMinutes;
}

class WorkerShift {
  const WorkerShift({
    required this.id,
    required this.title,
    required this.schedule,
    required this.status,
    required this.remindersEnabled,
    this.reminderUsesGlobalDefaults = true,
    this.reminderPreviewOffsetSeconds = 86400,
    this.reminderPrepareOffsetSeconds = 7200,
    this.reminderStartOffsetSeconds = 1800,
    this.reminderMorningEnabled = true,
    this.reminderEndEnabled = true,
    required this.breakMinutes,
    required this.breakIsPaid,
    this.employerId,
    this.workplaceId,
    this.hourlyRateMinor,
    this.notes,
  });

  factory WorkerShift.fromMap(Map<String, Object?> map) => WorkerShift(
    id: map['id']! as String,
    employerId: map['employer_id'] as String?,
    workplaceId: map['workplace_id'] as String?,
    title: map['title']! as String,
    schedule: ScheduleWindow.fromMap(map),
    status: workItemStatusFromStorage(map['status'] as String? ?? 'scheduled'),
    hourlyRateMinor: map['hourly_rate_minor'] as int?,
    remindersEnabled: (map['reminders_enabled'] as int? ?? 1) == 1,
    reminderUsesGlobalDefaults:
        (map['reminder_uses_global_defaults'] as int? ?? 1) == 1,
    reminderPreviewOffsetSeconds:
        map['reminder_preview_offset_seconds'] as int? ?? 86400,
    reminderPrepareOffsetSeconds:
        map['reminder_prepare_offset_seconds'] as int? ?? 7200,
    reminderStartOffsetSeconds:
        map['reminder_start_offset_seconds'] as int? ?? 1800,
    reminderMorningEnabled: (map['reminder_morning_enabled'] as int? ?? 1) == 1,
    reminderEndEnabled: (map['reminder_end_enabled'] as int? ?? 1) == 1,
    breakMinutes: map['break_minutes'] as int? ?? 0,
    breakIsPaid: (map['break_is_paid'] as int? ?? 0) == 1,
    notes: map['notes'] as String?,
  );

  final String id;
  final String? employerId;
  final String? workplaceId;
  final String title;
  final ScheduleWindow schedule;
  final WorkItemStatus status;
  final int? hourlyRateMinor;
  final bool remindersEnabled;
  final bool reminderUsesGlobalDefaults;
  final int reminderPreviewOffsetSeconds;
  final int reminderPrepareOffsetSeconds;
  final int reminderStartOffsetSeconds;
  final bool reminderMorningEnabled;
  final bool reminderEndEnabled;
  final int breakMinutes;
  final bool breakIsPaid;
  final String? notes;

  Duration get payableDuration {
    final breakDuration = breakIsPaid
        ? Duration.zero
        : Duration(minutes: breakMinutes);
    final result = schedule.elapsed - breakDuration;
    return result.isNegative ? Duration.zero : result;
  }
}

class CalendarWorkItem {
  const CalendarWorkItem({
    required this.id,
    required this.flow,
    required this.title,
    required this.startUtc,
    required this.endUtc,
    required this.startLocal,
    required this.endLocal,
    required this.ianaTimeZone,
    required this.status,
  });

  final String id;
  final WorkFlow flow;
  final String title;
  final DateTime startUtc;
  final DateTime endUtc;
  final DateTime startLocal;
  final DateTime endLocal;
  final String ianaTimeZone;
  final String status;

  bool touchesLocalDate(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = DateTime(date.year, date.month, date.day + 1);
    return startLocal.isBefore(dayEnd) && endLocal.isAfter(dayStart);
  }
}
