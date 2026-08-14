import 'package:lunar/lunar.dart';

import '../models/reminder.dart';

/// 阴历换算与生日判断服务。
///
/// 核心规则：闰月不作区分，阴历闰月一律按同名平月处理（闰二月 = 二月）。
class LunarService {
  LunarService._();
  static final LunarService instance = LunarService._();

  /// 把阳历日期换算成阴历月日，闰月取绝对值（同名平月）。
  (int month, int day) _lunarMonthDay(DateTime solar) {
    final lunar = Solar.fromYmd(solar.year, solar.month, solar.day).getLunar();
    return (lunar.getMonth().abs(), lunar.getDay());
  }

  /// 今天的阴历月日。
  (int month, int day) todayLunarMonthDay() => _lunarMonthDay(DateTime.now());

  /// 今天是否是该提醒的生日。
  bool isBirthdayToday(Reminder reminder) =>
      daysUntilNextBirthday(reminder) == 0;

  /// 下次生日的阳历日期（当天 00:00）。
  ///
  /// 从起点起逐日往后找第一个「阴历月日」与提醒匹配的日子，最多找 400 天
  /// （覆盖一个农历年 + 闰月）。用日历日递增而非 24 小时递增，避免跨时区/夏令时偏差。
  DateTime nextBirthdayDate(Reminder reminder, {DateTime? from}) {
    final start = from ?? DateTime.now();
    for (int offset = 0; offset < 400; offset++) {
      final day = DateTime(start.year, start.month, start.day + offset);
      final (month, dayNum) = _lunarMonthDay(day);
      if (month == reminder.lunarMonth && dayNum == reminder.lunarDay) {
        return day;
      }
    }
    return start;
  }

  /// 距下次生日还有几天（今天为 0）。
  int daysUntilNextBirthday(Reminder reminder, {DateTime? from}) {
    final start = from ?? DateTime.now();
    final today = DateTime(start.year, start.month, start.day);
    return nextBirthdayDate(reminder, from: start).difference(today).inDays;
  }

  /// 距生日文案：0 →「今天」，其余 →「还有 X 天」。
  String countdownText(int days) => days == 0 ? '今天' : '还有 $days 天';

  /// 生肖（阴历），需出生年份；无则 null。
  String? zodiacOf(Reminder reminder) {
    final year = reminder.birthYear;
    if (year == null) return null;
    return Lunar.fromYmd(year, reminder.lunarMonth, reminder.lunarDay)
        .getYearShengXiao();
  }

  /// 年龄（周岁），需出生年份；无则 null。
  int? ageOf(Reminder reminder) {
    final year = reminder.birthYear;
    if (year == null) return null;
    final now = DateTime.now();
    final next = nextBirthdayDate(reminder);
    // 下次生日还在今年：今年的生日还没到（今天生日则正好满周岁）。
    if (next.year == now.year) {
      return now.year - year - (daysUntilNextBirthday(reminder) == 0 ? 0 : 1);
    }
    return now.year - year;
  }

  /// 星座（阳历），需阳历生日；无则 null。
  String? constellationOf(Reminder reminder) {
    final month = reminder.solarMonth;
    final day = reminder.solarDay;
    if (month == null || day == null) return null;
    return constellationOfSolar(month, day);
  }

  /// 按阳历月日返回星座。
  String constellationOfSolar(int month, int day) {
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return '水瓶';
    if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return '双鱼';
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return '白羊';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return '金牛';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 21)) return '双子';
    if ((month == 6 && day >= 22) || (month == 7 && day <= 22)) return '巨蟹';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return '狮子';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return '处女';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 23)) return '天秤';
    if ((month == 10 && day >= 24) || (month == 11 && day <= 22)) return '天蝎';
    if ((month == 11 && day >= 23) || (month == 12 && day <= 21)) return '射手';
    return '摩羯'; // 12/22 ~ 1/19
  }
}
