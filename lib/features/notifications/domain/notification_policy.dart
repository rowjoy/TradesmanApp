import 'package:flutter/widgets.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../l10n/generated/app_localizations.dart';
import 'notification_models.dart';

/// Pure, deterministic Module 04 planning policy. SQLite remains the source of
/// truth; this class only turns saved work intent into a bounded OS schedule.
class NotificationPolicy {
  const NotificationPolicy({
    this.horizon = const Duration(days: 30),
    this.maxPending = 48,
    this.dailyCap = 6,
  });

  final Duration horizon;
  final int maxPending;
  final int dailyCap;

  List<PlannedNotification> build({
    required DateTime nowUtc,
    required List<WorkAlertSource> work,
    required Map<AlertCategory, AlertPreference> preferences,
    required MotivationSettings motivation,
    required String languageCode,
    required String deviceTimeZone,
  }) {
    // This policy runs in a background isolate, whose timezone database is
    // independent from the UI isolate initialized by the platform gateway.
    tz_data.initializeTimeZones();
    final now = nowUtc.toUtc();
    final end = now.add(horizon);
    final candidates = <PlannedNotification>[];
    final digestSources = <String, List<WorkAlertSource>>{};

    for (final source in work) {
      if (source.status == 'completed' || source.status == 'cancelled') {
        continue;
      }
      final location = _location(source.ianaTimeZone);
      final startLocal = tz.TZDateTime.from(source.startUtc, location);

      _addRelative(
        candidates,
        source,
        AlertCategory.tomorrowPreview,
        source.startUtc.subtract(
          Duration(
            seconds: _offsetSeconds(
              source,
              AlertCategory.tomorrowPreview,
              preferences,
            ),
          ),
        ),
        preferences,
        now,
        end,
        languageCode,
      );
      _addRelative(
        candidates,
        source,
        AlertCategory.prepare,
        source.startUtc.subtract(
          Duration(
            seconds: _offsetSeconds(source, AlertCategory.prepare, preferences),
          ),
        ),
        preferences,
        now,
        end,
        languageCode,
      );
      _addRelative(
        candidates,
        source,
        AlertCategory.startsSoon,
        source.startUtc.subtract(
          Duration(
            seconds: _offsetSeconds(
              source,
              AlertCategory.startsSoon,
              preferences,
            ),
          ),
        ),
        preferences,
        now,
        end,
        languageCode,
      );

      if ((source.usesGlobalDefaults || source.morningEnabled) &&
          _preference(preferences, AlertCategory.morningDigest).enabled) {
        final dateKey = _dateKey(startLocal);
        digestSources
            .putIfAbsent('${source.ianaTimeZone}|$dateKey', () => [])
            .add(source);
      }

      if (source.status == 'inProgress') {
        if (source.usesGlobalDefaults || source.endEnabled) {
          _addRelative(
            candidates,
            source,
            AlertCategory.scheduledEnd,
            source.endUtc,
            preferences,
            now,
            end,
            languageCode,
          );
        }
        final clockIn = source.actualClockInUtc;
        if (clockIn != null) {
          final breakAt = clockIn.add(
            Duration(
              seconds:
                  _preference(
                    preferences,
                    AlertCategory.breakReminder,
                  ).offsetSeconds ??
                  4 * 60 * 60,
            ),
          );
          if (breakAt.isBefore(source.endUtc)) {
            _addRelative(
              candidates,
              source,
              AlertCategory.breakReminder,
              breakAt,
              preferences,
              now,
              end,
              languageCode,
            );
          }
        }
      }
    }

    for (final entry in digestSources.entries) {
      final parts = entry.key.split('|');
      final location = _location(parts.first);
      final date = entry.value
          .map((item) => tz.TZDateTime.from(item.startUtc, location))
          .reduce((a, b) => a.isBefore(b) ? a : b);
      final preference = _preference(preferences, AlertCategory.morningDigest);
      final minute = preference.deliveryTimeMinutes ?? 7 * 60;
      final local = tz.TZDateTime(
        location,
        date.year,
        date.month,
        date.day,
        minute ~/ 60,
        minute % 60,
      );
      final occurrence = 'digest:${parts.first}:${_dateKey(local)}';
      final scheduled = _applyQuietHours(
        local.toUtc(),
        parts.first,
        preference,
        critical: false,
      );
      if (!_inside(scheduled, now, end)) continue;
      final count = entry.value.length;
      final strings = _strings(languageCode);
      final copy = (
        strings.notificationMorningDigestTitle(count),
        strings.notificationMorningDigestBody,
      );
      final containsJobs = entry.value.any((item) => item.entityType == 'job');
      final containsShifts = entry.value.any(
        (item) => item.entityType == 'shift',
      );
      final route = containsShifts && !containsJobs
          ? '/work-calendar?flow=worker'
          : containsJobs && !containsShifts
          ? '/work-calendar?flow=tradesman'
          : '/work-calendar';
      candidates.add(
        _plan(
          occurrenceId: occurrence,
          category: AlertCategory.morningDigest,
          entityType: 'calendar',
          entityId: _dateKey(local),
          scheduledForUtc: scheduled,
          timeZone: parts.first,
          route: route,
          title: copy.$1,
          body: copy.$2,
          priority: 40,
          requestedLocal: local.toIso8601String(),
        ),
      );
    }

    _addMotivation(
      candidates,
      now: now,
      end: end,
      settings: motivation,
      languageCode: languageCode,
      deviceTimeZone: deviceTimeZone,
    );

    final deduped = <String, PlannedNotification>{};
    for (final item in candidates) {
      final minute = item.scheduledForUtc.millisecondsSinceEpoch ~/ 60000;
      final key = '${item.entityType}:${item.entityId}:$minute';
      final existing = deduped[key];
      if (existing == null || item.priority > existing.priority) {
        deduped[key] = item;
      }
    }

    final byPriority = deduped.values.toList()
      ..sort((a, b) {
        final priority = b.priority.compareTo(a.priority);
        return priority != 0
            ? priority
            : a.scheduledForUtc.compareTo(b.scheduledForUtc);
      });
    final dayCounts = <String, int>{};
    final bounded = <PlannedNotification>[];
    for (final item in byPriority) {
      final local = tz.TZDateTime.from(
        item.scheduledForUtc,
        _location(item.ianaTimeZone),
      );
      final day = '${item.ianaTimeZone}:${_dateKey(local)}';
      if ((dayCounts[day] ?? 0) >= dailyCap) continue;
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
      bounded.add(item);
    }
    bounded.sort((a, b) => a.scheduledForUtc.compareTo(b.scheduledForUtc));
    return bounded.length <= maxPending
        ? bounded
        : bounded.sublist(0, maxPending);
  }

  void _addRelative(
    List<PlannedNotification> output,
    WorkAlertSource source,
    AlertCategory category,
    DateTime requestedUtc,
    Map<AlertCategory, AlertPreference> preferences,
    DateTime now,
    DateTime end,
    String languageCode,
  ) {
    final preference = _preference(preferences, category);
    if (!preference.enabled) return;
    final critical = switch (category) {
      AlertCategory.prepare ||
      AlertCategory.startsSoon ||
      AlertCategory.breakReminder ||
      AlertCategory.scheduledEnd => true,
      _ => false,
    };
    final scheduled = _applyQuietHours(
      requestedUtc.toUtc(),
      source.ianaTimeZone,
      preference,
      critical: critical,
    );
    if (!_inside(scheduled, now, end)) return;
    final local = tz.TZDateTime.from(scheduled, _location(source.ianaTimeZone));
    final occurrence =
        '${source.entityType}:${source.entityId}:${category.name}:${source.startUtc.toIso8601String()}';
    final workStartLocal = tz.TZDateTime.from(
      source.startUtc,
      _location(source.ianaTimeZone),
    );
    final copy = _copy(
      category,
      languageCode,
      workStartLocal,
      source.title,
      preference.privateLockScreenText,
    );
    output.add(
      _plan(
        occurrenceId: occurrence,
        category: category,
        entityType: source.entityType,
        entityId: source.entityId,
        scheduledForUtc: scheduled,
        timeZone: source.ianaTimeZone,
        route: source.routeIntent,
        title: copy.$1,
        body: copy.$2,
        priority: _priority(category),
        sourceStart: source.startUtc,
        sourceEnd: source.endUtc,
        requestedLocal: local.toIso8601String(),
      ),
    );
  }

  void _addMotivation(
    List<PlannedNotification> output, {
    required DateTime now,
    required DateTime end,
    required MotivationSettings settings,
    required String languageCode,
    required String deviceTimeZone,
  }) {
    if (!settings.enabled || (settings.pausedUntilUtc?.isAfter(now) ?? false)) {
      return;
    }
    final location = _location(deviceTimeZone);
    final localNow = tz.TZDateTime.from(now, location);
    for (var days = 0; days < 7; days++) {
      final date = localNow.add(Duration(days: days));
      final dayBit = 1 << (date.weekday - 1);
      if ((settings.allowedDaysMask & dayBit) == 0) continue;
      final minute = settings.deliveryTimeMinutes;
      var local = tz.TZDateTime(
        location,
        date.year,
        date.month,
        date.day,
        minute ~/ 60,
        minute % 60,
      );
      if (_inQuiet(
        local.hour * 60 + local.minute,
        settings.quietStartMinutes,
        settings.quietEndMinutes,
      )) {
        local = _quietEnd(local, settings.quietEndMinutes);
      }
      final scheduled = local.toUtc();
      if (!_inside(scheduled, now, end)) continue;
      const cooldown = Duration(hours: 1);
      if (output.any(
        (item) =>
            item.priority > 10 &&
            item.scheduledForUtc.difference(scheduled).abs() < cooldown,
      )) {
        continue;
      }
      final strings = _strings(languageCode);
      final genericMessage = strings.notificationMotivationBody;
      final message = settings.privateLockScreenText
          ? genericMessage
          : settings.customMessage?.trim().isNotEmpty == true
          ? settings.customMessage!.trim()
          : genericMessage;
      final occurrence = 'motivation:${_dateKey(local)}:${settings.tone}';
      output.add(
        _plan(
          occurrenceId: occurrence,
          category: AlertCategory.motivation,
          entityType: 'home',
          entityId: _dateKey(local),
          scheduledForUtc: scheduled,
          timeZone: deviceTimeZone,
          route: '/home',
          title: strings.appTitle,
          body: message,
          priority: 10,
          requestedLocal: local.toIso8601String(),
        ),
      );
    }
  }

  PlannedNotification _plan({
    required String occurrenceId,
    required AlertCategory category,
    required String entityType,
    required String entityId,
    required DateTime scheduledForUtc,
    required String timeZone,
    required String route,
    required String title,
    required String body,
    required int priority,
    DateTime? sourceStart,
    DateTime? sourceEnd,
    String? requestedLocal,
  }) {
    final payload = NotificationPayload(
      entityType: entityType,
      entityId: entityId,
      routeIntent: route,
      type: category.name,
      occurrenceId: occurrenceId,
    ).encode();
    final fingerprint = deterministicNotificationId(
      '$scheduledForUtc|$title|$body|$payload',
    ).toRadixString(16);
    return PlannedNotification(
      occurrenceId: occurrenceId,
      category: category,
      entityType: entityType,
      entityId: entityId,
      scheduledForUtc: scheduledForUtc.toUtc(),
      ianaTimeZone: timeZone,
      routeIntent: route,
      title: title,
      body: body,
      payload: payload,
      priority: priority,
      contentFingerprint: fingerprint,
      sourceStartUtc: sourceStart?.toUtc(),
      sourceEndUtc: sourceEnd?.toUtc(),
      requestedLocalTime: requestedLocal,
    );
  }

  (String, String) _copy(
    AlertCategory category,
    String languageCode,
    tz.TZDateTime local,
    String workTitle,
    bool private,
  ) {
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final time = '$hour:$minute';
    final subject = private ? '' : ' · $workTitle';
    final strings = _strings(languageCode);
    return switch (category) {
      AlertCategory.tomorrowPreview => (
        strings.notificationUpcomingTitle(subject),
        strings.notificationUpcomingBody,
      ),
      AlertCategory.prepare => (
        strings.notificationPrepareTitle(subject),
        strings.notificationPrepareBody,
      ),
      AlertCategory.startsSoon => (
        strings.notificationStartsSoonTitle(subject),
        strings.notificationStartsSoonBody(time),
      ),
      AlertCategory.breakReminder => (
        strings.notificationBreakTitle,
        strings.notificationBreakBody,
      ),
      AlertCategory.scheduledEnd => (
        strings.notificationFinishTitle,
        strings.notificationFinishBody,
      ),
      _ => (strings.appTitle, strings.notificationReviewPlanBody),
    };
  }

  AppLocalizations _strings(String languageCode) =>
      lookupAppLocalizations(Locale(languageCode));

  AlertPreference _preference(
    Map<AlertCategory, AlertPreference> values,
    AlertCategory category,
  ) => values[category] ?? AlertPreference.defaults(category);

  int _offsetSeconds(
    WorkAlertSource source,
    AlertCategory category,
    Map<AlertCategory, AlertPreference> preferences,
  ) {
    if (source.usesGlobalDefaults) {
      final global = _preference(preferences, category).offsetSeconds;
      if (global != null) return global;
    }
    return switch (category) {
      AlertCategory.tomorrowPreview => source.previewOffsetSeconds,
      AlertCategory.prepare => source.prepareOffsetSeconds,
      AlertCategory.startsSoon => source.startOffsetSeconds,
      _ => 0,
    };
  }

  DateTime _applyQuietHours(
    DateTime utc,
    String zone,
    AlertPreference preference, {
    required bool critical,
  }) {
    if (critical) return utc;
    final location = _location(zone);
    final local = tz.TZDateTime.from(utc, location);
    if (!_inQuiet(
      local.hour * 60 + local.minute,
      preference.quietStartMinutes,
      preference.quietEndMinutes,
    )) {
      return utc;
    }
    return _quietEnd(local, preference.quietEndMinutes).toUtc();
  }

  bool _inQuiet(int minute, int start, int end) => start == end
      ? false
      : start < end
      ? minute >= start && minute < end
      : minute >= start || minute < end;

  tz.TZDateTime _quietEnd(tz.TZDateTime local, int endMinutes) {
    final onSameDay = local.hour * 60 + local.minute < endMinutes;
    return tz.TZDateTime(
      local.location,
      local.year,
      local.month,
      local.day + (onSameDay ? 0 : 1),
      endMinutes ~/ 60,
      endMinutes % 60,
    );
  }

  bool _inside(DateTime value, DateTime start, DateTime end) =>
      value.isAfter(start.add(const Duration(seconds: 5))) &&
      !value.isAfter(end);

  int _priority(AlertCategory category) => switch (category) {
    AlertCategory.scheduledEnd => 100,
    AlertCategory.startsSoon => 90,
    AlertCategory.breakReminder => 80,
    AlertCategory.prepare => 70,
    AlertCategory.tomorrowPreview => 50,
    AlertCategory.morningDigest => 40,
    AlertCategory.motivation => 10,
  };

  tz.Location _location(String name) {
    try {
      return tz.getLocation(name);
    } catch (_) {
      return tz.UTC;
    }
  }

  String _dateKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
