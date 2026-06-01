import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Local notifications: a single daily mindfulness reminder.
class NotificationService {
  static const _reminderId = 100;
  static const _channelId = 'snapout_reminders';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Fall back to UTC if the platform timezone can't be resolved.
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(settings: const InitializationSettings(android: android));
    _ready = true;
  }

  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  /// Schedule (or reschedule) the daily reminder at [hour]:[minute].
  Future<void> scheduleDaily(int hour, int minute) async {
    await init();
    await _plugin.cancel(id: _reminderId);
    await _plugin.zonedSchedule(
      id: _reminderId,
      title: 'Take a breath',
      body: 'A mindful minute keeps the doomscroll away. Keep your streak going.',
      scheduledDate: _nextInstanceOf(hour, minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Reminders',
          channelDescription: 'Daily mindfulness nudge',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDaily() async {
    await init();
    await _plugin.cancel(id: _reminderId);
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
