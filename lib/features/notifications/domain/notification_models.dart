import 'dart:convert';

enum AlertCategory {
  tomorrowPreview,
  morningDigest,
  prepare,
  startsSoon,
  breakReminder,
  scheduledEnd,
  motivation,
}

enum NotificationPermissionState { unknown, deferred, granted, denied }

NotificationPermissionState notificationPermissionFromStorage(String? value) {
  if (value == null) {
    return NotificationPermissionState.unknown;
  }

  return NotificationPermissionState.values.firstWhere(
    (item) => item.name == value,
    orElse: () => NotificationPermissionState.unknown,
  );
}

/// Safely converts SQLite values into bool.
///
/// SQLite commonly stores bool values as 0/1.
/// This also handles actual bool/string values safely.
bool _toBool(Object? value, {bool defaultValue = false}) {
  if (value == null) return defaultValue;

  if (value is bool) return value;

  if (value is int) {
    return value == 1;
  }

  if (value is String) {
    final normalized = value.toLowerCase().trim();

    if (normalized == '1' || normalized == 'true') {
      return true;
    }

    if (normalized == '0' || normalized == 'false') {
      return false;
    }
  }

  return defaultValue;
}

/// Safely converts an SQLite value to int.
int? _toInt(Object? value) {
  if (value == null) return null;

  if (value is int) return value;

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value.toString());
}

/// Safely converts an SQLite value to String.
String? _toStringValue(Object? value) {
  if (value == null) return null;

  final result = value.toString();

  return result.isEmpty ? null : result;
}

/// Converts DateTime to UTC safely.
DateTime? _toUtcDateTime(Object? value) {
  if (value == null) return null;

  if (value is DateTime) {
    return value.toUtc();
  }

  final parsed = DateTime.tryParse(value.toString());

  return parsed?.toUtc();
}

class AlertPreference {
  const AlertPreference({
    required this.category,
    required this.enabled,
    this.offsetSeconds,
    this.deliveryTimeMinutes,
    this.quietStartMinutes = 22 * 60,
    this.quietEndMinutes = 7 * 60,
    this.privateLockScreenText = true,
    this.cooldownSeconds = 3600,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  factory AlertPreference.defaults(AlertCategory category) {
    return AlertPreference(
      category: category,
      enabled: category != AlertCategory.motivation,
      offsetSeconds: switch (category) {
        AlertCategory.tomorrowPreview => 24 * 60 * 60,
        AlertCategory.prepare => 2 * 60 * 60,
        AlertCategory.startsSoon => 30 * 60,
        AlertCategory.breakReminder => 4 * 60 * 60,
        _ => null,
      },
      deliveryTimeMinutes: category == AlertCategory.morningDigest
          ? 7 * 60
          : null,
    );
  }

  factory AlertPreference.fromMap(Map<String, Object?> map) {
    final categoryName = _toStringValue(map['category']);

    final category = AlertCategory.values.firstWhere(
      (value) => value.name == categoryName,
      orElse: () => AlertCategory.startsSoon,
    );

    return AlertPreference(
      category: category,
      enabled: _toBool(map['enabled'], defaultValue: true),
      offsetSeconds: _toInt(map['offset_seconds']),
      deliveryTimeMinutes: _toInt(map['delivery_time_minutes']),
      quietStartMinutes: _toInt(map['quiet_start_minutes']) ?? 22 * 60,
      quietEndMinutes: _toInt(map['quiet_end_minutes']) ?? 7 * 60,
      privateLockScreenText: _toBool(
        map['private_lock_screen_text'],
        defaultValue: true,
      ),
      cooldownSeconds: _toInt(map['cooldown_seconds']) ?? 3600,
      soundEnabled: _toBool(map['sound_enabled'], defaultValue: true),
      vibrationEnabled: _toBool(map['vibration_enabled'], defaultValue: true),
    );
  }

  final AlertCategory category;
  final bool enabled;
  final int? offsetSeconds;
  final int? deliveryTimeMinutes;
  final int quietStartMinutes;
  final int quietEndMinutes;
  final bool privateLockScreenText;
  final int cooldownSeconds;
  final bool soundEnabled;
  final bool vibrationEnabled;

  AlertPreference copyWith({
    bool? enabled,
    int? offsetSeconds,
    int? deliveryTimeMinutes,
    int? quietStartMinutes,
    int? quietEndMinutes,
    bool? privateLockScreenText,
    int? cooldownSeconds,
    bool? soundEnabled,
    bool? vibrationEnabled,

    /// Set true if offsetSeconds should become null.
    bool clearOffsetSeconds = false,

    /// Set true if deliveryTimeMinutes should become null.
    bool clearDeliveryTimeMinutes = false,
  }) {
    return AlertPreference(
      category: category,
      enabled: enabled ?? this.enabled,
      offsetSeconds: clearOffsetSeconds
          ? null
          : offsetSeconds ?? this.offsetSeconds,
      deliveryTimeMinutes: clearDeliveryTimeMinutes
          ? null
          : deliveryTimeMinutes ?? this.deliveryTimeMinutes,
      quietStartMinutes: quietStartMinutes ?? this.quietStartMinutes,
      quietEndMinutes: quietEndMinutes ?? this.quietEndMinutes,
      privateLockScreenText:
          privateLockScreenText ?? this.privateLockScreenText,
      cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}

class WorkAlertSource {
  const WorkAlertSource({
    required this.entityType,
    required this.entityId,
    required this.title,
    required this.startUtc,
    required this.endUtc,
    required this.ianaTimeZone,
    required this.status,
    required this.previewOffsetSeconds,
    required this.prepareOffsetSeconds,
    required this.startOffsetSeconds,
    required this.morningEnabled,
    required this.endEnabled,
    this.usesGlobalDefaults = false,
    this.actualClockInUtc,
  });

  final String entityType;
  final String entityId;
  final String title;

  final DateTime startUtc;
  final DateTime endUtc;

  final String ianaTimeZone;
  final String status;

  final int previewOffsetSeconds;
  final int prepareOffsetSeconds;
  final int startOffsetSeconds;

  final bool morningEnabled;
  final bool endEnabled;

  final bool usesGlobalDefaults;

  final DateTime? actualClockInUtc;

  String get routeIntent {
    return entityType == 'job'
        ? '/work/jobs/$entityId'
        : '/work/shifts/$entityId';
  }
}

class MotivationSettings {
  const MotivationSettings({
    this.enabled = false,
    this.deliveryTimeMinutes = 7 * 60,
    this.tone = 'calm',
    this.allowedDaysMask = 127,
    this.pausedUntilUtc,
    this.privateLockScreenText = true,
    this.customMessage,
    this.quietStartMinutes = 22 * 60,
    this.quietEndMinutes = 7 * 60,
  });

  factory MotivationSettings.fromMap(Map<String, Object?> map) {
    return MotivationSettings(
      enabled: _toBool(map['enabled'], defaultValue: false),
      deliveryTimeMinutes: _toInt(map['delivery_time_minutes']) ?? 7 * 60,
      tone: _toStringValue(map['tone']) ?? 'calm',
      allowedDaysMask: _toInt(map['allowed_days_mask']) ?? 127,
      pausedUntilUtc: _toUtcDateTime(map['paused_until_utc']),
      privateLockScreenText: _toBool(
        map['private_lock_screen_text'],
        defaultValue: true,
      ),
      customMessage: _toStringValue(map['custom_message']),
      quietStartMinutes: _toInt(map['quiet_start_minutes']) ?? 22 * 60,
      quietEndMinutes: _toInt(map['quiet_end_minutes']) ?? 7 * 60,
    );
  }

  final bool enabled;
  final int deliveryTimeMinutes;
  final String tone;
  final int allowedDaysMask;
  final DateTime? pausedUntilUtc;
  final bool privateLockScreenText;
  final String? customMessage;
  final int quietStartMinutes;
  final int quietEndMinutes;

  MotivationSettings copyWith({
    bool? enabled,
    int? deliveryTimeMinutes,
    String? tone,
    int? allowedDaysMask,
    DateTime? pausedUntilUtc,
    bool? privateLockScreenText,
    String? customMessage,
    int? quietStartMinutes,
    int? quietEndMinutes,

    /// Allows pausedUntilUtc to be explicitly cleared.
    bool clearPausedUntilUtc = false,

    /// Allows customMessage to be explicitly cleared.
    bool clearCustomMessage = false,
  }) {
    return MotivationSettings(
      enabled: enabled ?? this.enabled,
      deliveryTimeMinutes: deliveryTimeMinutes ?? this.deliveryTimeMinutes,
      tone: tone ?? this.tone,
      allowedDaysMask: allowedDaysMask ?? this.allowedDaysMask,
      pausedUntilUtc: clearPausedUntilUtc
          ? null
          : pausedUntilUtc ?? this.pausedUntilUtc,
      privateLockScreenText:
          privateLockScreenText ?? this.privateLockScreenText,
      customMessage: clearCustomMessage
          ? null
          : customMessage ?? this.customMessage,
      quietStartMinutes: quietStartMinutes ?? this.quietStartMinutes,
      quietEndMinutes: quietEndMinutes ?? this.quietEndMinutes,
    );
  }
}

class PlannedNotification {
  const PlannedNotification({
    required this.occurrenceId,
    required this.category,
    required this.entityType,
    required this.entityId,
    required this.scheduledForUtc,
    required this.ianaTimeZone,
    required this.routeIntent,
    required this.title,
    required this.body,
    required this.payload,
    required this.priority,
    required this.contentFingerprint,
    this.sourceStartUtc,
    this.sourceEndUtc,
    this.requestedLocalTime,
  });

  final String occurrenceId;
  final AlertCategory category;

  final String entityType;
  final String entityId;

  final DateTime scheduledForUtc;
  final String ianaTimeZone;

  final String routeIntent;

  final String title;
  final String body;
  final String payload;

  final int priority;
  final String contentFingerprint;

  final DateTime? sourceStartUtc;
  final DateTime? sourceEndUtc;

  final String? requestedLocalTime;
}

class StoredNotification {
  const StoredNotification({
    required this.id,
    required this.occurrenceId,
    required this.osNotificationId,
    required this.status,
    required this.scheduledForUtc,
    required this.contentFingerprint,
    required this.plan,
  });

  final String id;
  final String occurrenceId;
  final int osNotificationId;
  final String status;
  final DateTime scheduledForUtc;
  final String contentFingerprint;
  final PlannedNotification plan;
}

class ReconcileBatch {
  const ReconcileBatch({required this.cancelIds, required this.schedule});

  final List<int> cancelIds;
  final List<StoredNotification> schedule;
}

class NotificationPayload {
  const NotificationPayload({
    required this.entityType,
    required this.entityId,
    required this.routeIntent,
    required this.type,
    required this.occurrenceId,
  });

  final String entityType;
  final String entityId;
  final String routeIntent;
  final String type;
  final String occurrenceId;

  String encode() {
    return jsonEncode({
      'v': 1,
      'entityType': entityType,
      'entityId': entityId,
      'routeIntent': routeIntent,
      'type': type,
      'occurrenceId': occurrenceId,
    });
  }

  static NotificationPayload? decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      if (decoded['v'] != 1) {
        return null;
      }

      final entityType = decoded['entityType'];
      final entityId = decoded['entityId'];
      final routeIntent = decoded['routeIntent'];
      final type = decoded['type'];
      final occurrenceId = decoded['occurrenceId'];

      if (entityType is! String ||
          entityId is! String ||
          routeIntent is! String ||
          type is! String ||
          occurrenceId is! String) {
        return null;
      }

      return NotificationPayload(
        entityType: entityType,
        entityId: entityId,
        routeIntent: routeIntent,
        type: type,
        occurrenceId: occurrenceId,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Generates a deterministic positive notification ID.
///
/// The same occurrenceId always generates the same ID.
/// `probe` can be incremented when a hash collision occurs.
int deterministicNotificationId(String occurrenceId, {int probe = 0}) {
  if (probe < 0) {
    throw ArgumentError.value(probe, 'probe', 'Probe cannot be negative.');
  }

  var hash = 0x811c9dc5;

  for (final unit in occurrenceId.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }

  final baseId = hash & 0x7fffffff;

  return (baseId + probe) & 0x7fffffff;
}
