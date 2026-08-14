import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reminder_provider.dart';
import '../services/lunar_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../widgets/reminder_avatar.dart';
import 'about_screen.dart';
import 'add_edit_screen.dart';
import 'detail_screen.dart';
import 'notification_guide_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool? _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReminderProvider>().load();
    });
    _checkNotificationStatus();
  }

  Future<void> _checkNotificationStatus() async {
    final enabled = await NotificationService.instance.areNotificationsEnabled();
    if (!mounted) return;
    setState(() => _notificationsEnabled = enabled);
  }

  Future<void> _openGuide() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationGuideScreen()),
    );
    _checkNotificationStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('忆辰'),
        actions: [
          IconButton(
            onPressed: _openGuide,
            icon: const Icon(Icons.help_outline),
            tooltip: '通知设置',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
            icon: const Icon(Icons.info_outline),
            tooltip: '关于',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_notificationsEnabled == false) _notificationBanner(),
          Expanded(
            child: Consumer<ReminderProvider>(
              builder: (context, provider, _) {
                if (provider.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.reminders.isEmpty) {
                  return const Center(child: Text('还没有提醒，点右下角「+」添加'));
                }
                return ListView.builder(
                  itemCount: provider.reminders.length,
                  itemBuilder: (context, index) {
                    final r = provider.reminders[index];
                    final days =
                        LunarService.instance.daysUntilNextBirthday(r);
                    final avatar = ReminderAvatar(reminder: r);
                    return ListTile(
                      leading: days == 0
                          ? Badge(
                              label: const Text('今'),
                              backgroundColor: AppConstants.primaryRed,
                              textColor: Colors.white,
                              child: avatar,
                            )
                          : avatar,
                      title: Text(r.name),
                      subtitle: Text(
                        '${r.lunarBirthdayText} · '
                        '${LunarService.instance.countdownText(days)}',
                      ),
                      trailing: r.enabled
                          ? const Icon(Icons.chevron_right)
                          : const Icon(Icons.notifications_off_outlined),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(reminder: r),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _notificationBanner() {
    return Material(
      color: const Color(0xFFFFEBEE),
      child: InkWell(
        onTap: _openGuide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: const [
              Icon(Icons.notifications_off_outlined, color: AppConstants.primaryRed),
              SizedBox(width: 12),
              Expanded(child: Text('通知权限未开启，生日提醒可能收不到')),
              Icon(Icons.chevron_right, color: AppConstants.primaryRed),
            ],
          ),
        ),
      ),
    );
  }
}
