import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/reminder.dart';
import '../providers/reminder_provider.dart';
import '../services/lunar_service.dart';
import '../utils/constants.dart';
import '../widgets/reminder_avatar.dart';
import 'add_edit_screen.dart';

class DetailScreen extends StatelessWidget {
  final Reminder reminder;
  const DetailScreen({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    final lunar = LunarService.instance;
    final zodiac = lunar.zodiacOf(reminder);
    final age = lunar.ageOf(reminder);
    final constellation = lunar.constellationOf(reminder);
    return Scaffold(
      appBar: AppBar(title: Text(reminder.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(child: ReminderAvatar(reminder: reminder, radius: 40)),
          const SizedBox(height: 24),
          _infoRow(context, '姓名', reminder.name),
          _infoRow(context, '阴历生日', reminder.lunarBirthdayText),
          _infoRow(
            context,
            '距生日',
            lunar.countdownText(lunar.daysUntilNextBirthday(reminder)),
          ),
          if (reminder.solarMonth != null && reminder.solarDay != null)
            _infoRow(
              context,
              '阳历生日',
              '${reminder.solarMonth}月${reminder.solarDay}日',
            ),
          if (reminder.birthYear != null)
            _infoRow(context, '出生年份', '${reminder.birthYear} 年'),
          if (age != null) _infoRow(context, '年龄', '$age 岁'),
          if (zodiac != null) _infoRow(context, '生肖', zodiac),
          if (constellation != null) _infoRow(context, '星座', constellation),
          _infoRow(context, '提前通知', '提前 ${reminder.advanceDays} 天'),
          _infoRow(
            context,
            '通知间隔',
            AppConstants.formatInterval(reminder.notifyIntervalSeconds),
          ),
          _infoRow(context, '状态', reminder.enabled ? '已启用' : '已停用'),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditScreen(reminder: reminder),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('编辑'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('删除'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除提醒'),
        content: Text('确定删除「${reminder.name}」的生日提醒吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ReminderProvider>().delete(reminder.id!);
              Navigator.pop(context);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
