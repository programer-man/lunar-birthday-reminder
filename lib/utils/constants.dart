import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // 主题中国红（与闪屏、图标一致）
  static const Color primaryRed = Color(0xFFC62828);

  // 提前通知天数（需求2：1~7天）
  static const int defaultAdvanceDays = 1;
  static const int minAdvanceDays = 1;
  static const int maxAdvanceDays = 7;

  // 通知间隔（需求3：15秒 ~ 2小时），默认1小时
  static const int defaultNotifyIntervalSeconds = 3600;
  static const int minNotifyIntervalSeconds = 15;
  static const int maxNotifyIntervalSeconds = 7200;

  // 通知间隔的可选项（秒），用于表单下拉选择
  static const List<int> intervalPresetSeconds = [
    15, 30, 60, 300, 600, 1800, 3600, 7200,
  ];

  // 头像 emoji 选项
  static const List<String> avatarEmojis = [
    '😀', '😎', '🥰', '😇', '🤩', '🥳', '😺', '🐶',
    '🐱', '🐰', '🦊', '🐼', '🐯', '🦁', '🐸', '🦄',
    '🌸', '🌻', '🍀', '⭐',
  ];

  static String formatInterval(int seconds) {
    if (seconds < 60) return '$seconds 秒';
    if (seconds < 3600) return '${seconds ~/ 60} 分钟';
    return '${seconds ~/ 3600} 小时';
  }
}
