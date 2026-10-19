import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/features/notifications/domain/notification_models.dart';
import 'package:tradesman_manager/features/notifications/domain/notification_policy.dart';

void main() {
  group('custom finish alert preference', () {
    late List<PlannedNotification> planned;

    setUp(() {
      planned = const NotificationPolicy().build(
        nowUtc: DateTime.utc(2026, 10, 18, 9),
        work: [
          WorkAlertSource(
            entityType: 'job',
            entityId: 'job-42',
            title: 'Kitchen installation',
            startUtc: DateTime.utc(2026, 10, 18, 8),
            endUtc: DateTime.utc(2026, 10, 18, 17),
            ianaTimeZone: 'UTC',
            status: 'inProgress',
            previewOffsetSeconds: 86400,
            prepareOffsetSeconds: 7200,
            startOffsetSeconds: 1800,
            morningEnabled: false,
            endEnabled: false,
            usesGlobalDefaults: false,
            actualClockInUtc: DateTime.utc(2026, 10, 18, 8),
          ),
        ],
        preferences: const {
          AlertCategory.scheduledEnd: AlertPreference(
            category: AlertCategory.scheduledEnd,
            enabled: true,
          ),
          AlertCategory.breakReminder: AlertPreference(
            category: AlertCategory.breakReminder,
            enabled: true,
            offsetSeconds: 10800,
          ),
        },
        motivation: const MotivationSettings(),
        languageCode: 'en',
        deviceTimeZone: 'UTC',
      );
    });

    test('disabling finish suppresses the scheduled end alert', () {
      expect(
        planned.where((item) => item.category == AlertCategory.scheduledEnd),
        isEmpty,
      );
    });

    test('disabling finish retains the globally enabled break reminder', () {
      expect(planned.map((item) => item.category), [
        AlertCategory.breakReminder,
      ]);
      final reminder = planned.single;
      expect(reminder.scheduledForUtc, DateTime.utc(2026, 10, 18, 11));
      expect(reminder.entityType, 'job');
      expect(reminder.entityId, 'job-42');
      expect(reminder.routeIntent, '/work/jobs/job-42');
    });
  });
}
