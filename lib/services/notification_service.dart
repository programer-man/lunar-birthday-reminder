import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder.dart';
import 'lunar_service.dart';

/// 本地通知服务：提前 X 天 + 生日当天按间隔反复提醒（系统定时通知）。
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const _channelId = 'birthday_reminders';
  static const _channelName = '生日提醒';
  static const _channelDescription = '阴历生日提前提醒与当天提醒';

  static const _notifyHour = 9;
  static const _endHour = 21;
  static const _maxPerDay = 48;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    // 本 App 面向中国（东八区），固定本地时区为上海。
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: settings);

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(channel);
    await android?.requestNotificationsPermission();

    _initialized = true;
  }

  /// 通知权限是否已开启（安卓13+运行时权限）。
  Future<bool> areNotificationsEnabled() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.areNotificationsEnabled() ?? true;
  }

  /// 请求通知权限（弹系统授权框）。
  Future<bool?> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return android?.requestNotificationsPermission();
  }

  /// 清空后重新为所有「启用」的提醒调度通知。
  Future<void> scheduleAll(List<Reminder> reminders) async {
    await init();
    await _plugin.cancelAll();

    int id = 0;
    for (final r in reminders.where((e) => e.enabled)) {
      id = await _scheduleReminder(r, id);
    }
  }

  Future<int> _scheduleReminder(Reminder r, int id) async {
    final birthday = LunarService.instance.nextBirthdayDate(r);
    final now = tz.TZDateTime.now(tz.local);
    const detail = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    // 提前通知：生日前 advanceDays 天的 9:00（已过则不补发）。
    final advanceAt = _atNine(birthday.subtract(Duration(days: r.advanceDays)));
    if (advanceAt.isAfter(now)) {
      await _zonedSchedule(
        id++,
        '还有 ${r.advanceDays} 天是「${r.name}」的生日',
        '阴历 ${r.lunarBirthdayText}',
        advanceAt,
        detail,
      );
    }

    // 生日当天：9:00 起每隔 interval 一条，直到 21:00（单日上限 48 条）。
    var t = _atNine(birthday);
    var scheduled = 0;
    while (t.hour < _endHour && scheduled < _maxPerDay) {
      if (t.isAfter(now)) {
        await _zonedSchedule(
          id++,
          '今天是「${r.name}」的生日',
          '阴历 ${r.lunarBirthdayText}',
          t,
          detail,
        );
        scheduled++;
      }
      t = t.add(Duration(seconds: r.notifyIntervalSeconds));
    }
    return id;
  }

  tz.TZDateTime _atNine(DateTime date) =>
      tz.TZDateTime(tz.local, date.year, date.month, date.day, _notifyHour);

  Future<void> _zonedSchedule(
    int id,
    String title,
    String body,
    tz.TZDateTime when,
    NotificationDetails details,
  ) {
    return _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: when,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
