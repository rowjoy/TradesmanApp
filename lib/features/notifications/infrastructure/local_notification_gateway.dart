import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/notification_models.dart';

abstract interface class NotificationGateway {
  Stream<String> get taps;
  String get localTimeZone;
  Future<String?> initialize();
  Future<bool> requestPermission();
  Future<bool?> permissionEnabled();
  Future<void> openSettings();
  Future<Set<int>> pendingIds();
  Future<void> showTest({
    required String title,
    required String body,
    required String payload,
  });
  Future<void> schedule(StoredNotification notification);
  Future<void> cancel(int id);
  void dispose();
}

class LocalNotificationGateway implements NotificationGateway {
  LocalNotificationGateway({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final _tapController = StreamController<String>.broadcast();
  String _localTimeZone = 'Etc/UTC';

  @override
  Stream<String> get taps => _tapController.stream;

  @override
  String get localTimeZone => _localTimeZone;

  @override
  Future<String?> initialize() async {
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      _localTimeZone = zone.identifier;
      tz.setLocalLocation(tz.getLocation(_localTimeZone));
    } catch (_) {
      _localTimeZone = 'Etc/UTC';
      tz.setLocalLocation(tz.UTC);
    }
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_workproof'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) _tapController.add(payload);
      },
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    return launch?.didNotificationLaunchApp == true
        ? launch?.notificationResponse?.payload
        : null;
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    final macos = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    if (macos != null) {
      return await macos.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return true;
  }

  @override
  Future<bool?> permissionEnabled() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) return android.areNotificationsEnabled();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosState = await ios?.checkPermissions();
    if (iosState != null) return iosState.isEnabled;
    final macos = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    final macState = await macos?.checkPermissions();
    return macState?.isEnabled;
  }

  @override
  Future<void> openSettings() async {
    await _plugin.openAppNotificationSettings();
  }

  @override
  Future<Set<int>> pendingIds() async =>
      (await _plugin.pendingNotificationRequests())
          .map((item) => item.id)
          .toSet();

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  @override
  Future<void> showTest({
    required String title,
    required String body,
    required String payload,
  }) => _plugin.show(
    id: 1900000001,
    title: title,
    body: body,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'workproof_test_alerts_v1',
        'Notification tests',
        channelDescription: 'User-requested WorkProof test notifications',
        icon: 'ic_stat_workproof',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: payload,
  );

  @override
  Future<void> schedule(StoredNotification notification) async {
    final item = notification.plan;
    await _plugin.zonedSchedule(
      id: notification.osNotificationId,
      title: item.title,
      body: item.body,
      scheduledDate: tz.TZDateTime.from(
        item.scheduledForUtc,
        _location(item.ianaTimeZone),
      ),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'workproof_work_alerts_v1',
          'Work reminders',
          channelDescription: 'Offline reminders for saved jobs and shifts',
          icon: 'ic_stat_workproof',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        macOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: item.payload,
    );
  }

  @override
  void dispose() {
    _tapController.close();
  }

  tz.Location _location(String name) {
    try {
      return tz.getLocation(name);
    } catch (_) {
      return tz.local;
    }
  }
}
