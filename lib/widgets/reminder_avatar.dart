import 'dart:io';

import 'package:flutter/material.dart';

import '../models/reminder.dart';

/// 统一头像展示：有相册图片则显示图片，否则显示表情。
class ReminderAvatar extends StatelessWidget {
  final Reminder reminder;
  final double radius;

  const ReminderAvatar({super.key, required this.reminder, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final path = reminder.avatarImagePath;
    if (path != null && path.isNotEmpty) {
      return CircleAvatar(radius: radius, backgroundImage: FileImage(File(path)));
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Text(reminder.avatar, style: TextStyle(fontSize: radius * 1.2)),
    );
  }
}
