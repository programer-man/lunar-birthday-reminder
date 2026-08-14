import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/reminder.dart';
import '../services/database_service.dart';
import '../services/lunar_service.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  List<Reminder> _reminders = [];
  bool _loading = false;

  List<Reminder> get reminders => _reminders;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _reminders = await _db.getAllReminders();
    _sort();
    _loading = false;
    notifyListeners();
    _rescheduleNotifications();
  }

  Future<void> add(Reminder r) async {
    final id = await _db.insertReminder(r);
    _reminders.add(r.copyWith(id: id));
    _sort();
    notifyListeners();
    _rescheduleNotifications();
  }

  Future<void> update(Reminder r) async {
    await _db.updateReminder(r);
    final index = _reminders.indexWhere((e) => e.id == r.id);
    if (index != -1) {
      _reminders[index] = r;
      _sort();
      notifyListeners();
    }
    _rescheduleNotifications();
  }

  Future<void> delete(int id) async {
    await _db.deleteReminder(id);
    _reminders.removeWhere((e) => e.id == id);
    notifyListeners();
    _rescheduleNotifications();
  }

  Future<void> toggle(Reminder r) async {
    await update(r.copyWith(enabled: !r.enabled));
  }

  void _rescheduleNotifications() {
    unawaited(NotificationService.instance.scheduleAll(_reminders));
  }

  void _sort() {
    final lunar = LunarService.instance;
    _reminders.sort(
      (a, b) => lunar
          .daysUntilNextBirthday(a)
          .compareTo(lunar.daysUntilNextBirthday(b)),
    );
  }
}
