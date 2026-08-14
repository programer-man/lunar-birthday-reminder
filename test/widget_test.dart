import 'package:flutter_test/flutter_test.dart';
import 'package:lunar_birthday_reminder/models/reminder.dart';

void main() {
  test('Reminder toMap/fromMap 往返一致', () {
    final r = Reminder(
      name: '张三',
      avatar: '😀',
      lunarMonth: 2,
      lunarDay: 15,
      solarMonth: 3,
      solarDay: 20,
      advanceDays: 3,
      notifyIntervalSeconds: 3600,
    );
    final restored = Reminder.fromMap(r.toMap());

    expect(restored.name, r.name);
    expect(restored.avatar, r.avatar);
    expect(restored.lunarMonth, r.lunarMonth);
    expect(restored.lunarDay, r.lunarDay);
    expect(restored.solarMonth, r.solarMonth);
    expect(restored.solarDay, r.solarDay);
    expect(restored.advanceDays, r.advanceDays);
    expect(restored.notifyIntervalSeconds, r.notifyIntervalSeconds);
    expect(restored.enabled, r.enabled);
  });
}
