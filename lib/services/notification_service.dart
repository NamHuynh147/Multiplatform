import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// SERVICE: thông báo đến giờ học
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();
  }

  /// Hiện thông báo ngay (để demo nhanh)
  static Future<void> showNow(String title, String body) async {
    await _plugin.show(0, title, body, _details());
  }

  /// Hẹn giờ thông báo vào [time] (nếu đã qua trong hôm nay thì dời sang ngày mai)
  static Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    var t = tz.TZDateTime.from(time, tz.local);
    if (t.isBefore(tz.TZDateTime.now(tz.local))) {
      t = t.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      t,
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static NotificationDetails _details() => const NotificationDetails(
        android: AndroidNotificationDetails(
          'class_channel',
          'Giờ học',
          channelDescription: 'Thông báo đến giờ học',
          importance: Importance.max,
          priority: Priority.high,
        ),
      );
}
