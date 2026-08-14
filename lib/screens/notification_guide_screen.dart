import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../utils/constants.dart';

/// 通知设置引导页：教用户开启通知权限、自启动、电池白名单。
class NotificationGuideScreen extends StatefulWidget {
  const NotificationGuideScreen({super.key});

  @override
  State<NotificationGuideScreen> createState() =>
      _NotificationGuideScreenState();
}

class _NotificationGuideScreenState extends State<NotificationGuideScreen> {
  bool? _enabled;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final enabled = await NotificationService.instance.areNotificationsEnabled();
    if (!mounted) return;
    setState(() => _enabled = enabled);
  }

  Future<void> _requestPermission() async {
    await NotificationService.instance.requestPermission();
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('通知设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _statusCard(),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _requestPermission,
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('开启通知权限'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => AppSettings.openAppSettings(),
            icon: const Icon(Icons.settings_outlined),
            label: const Text('打开系统设置'),
          ),
          const SizedBox(height: 24),
          _sectionTitle('为什么可能收不到提醒？'),
          const SizedBox(height: 8),
          const Text(
            '安卓手机（尤其国产手机）为了省电，会限制 App 在后台运行和发通知。'
            '如果收不到生日提醒，通常是下面几个开关没打开：\n\n'
            '1. 通知权限：允许本 App 发通知\n'
            '2. 自启动：允许 App 在后台自动启动\n'
            '3. 电池/省电：把本 App 设为「不限制」或「允许后台运行」',
            style: TextStyle(height: 1.6),
          ),
          const SizedBox(height: 24),
          _sectionTitle('各品牌手机设置（供参考）'),
          const SizedBox(height: 8),
          _brandSteps('小米 / Redmi', [
            '设置 → 应用设置 → 应用管理 → 找到「阴历生日提醒」',
            '开启「自启动」',
            '省电策略改为「无限制」',
          ]),
          _brandSteps('华为 / 荣耀', [
            '设置 → 应用 → 应用启动管理 → 找到本 App',
            '关闭「自动管理」，手动开启「自启动」「关联启动」「后台活动」',
          ]),
          _brandSteps('OPPO / 一加', [
            '设置 → 应用管理 → 找到本 App',
            '开启「自启动」',
            '电池 → 允许「后台运行」',
          ]),
          _brandSteps('vivo / iQOO', [
            'i管家 → 应用管理 → 权限管理 → 找到本 App',
            '开启「自启动」',
            '电池 → 允许「后台高耗电」',
          ]),
        ],
      ),
    );
  }

  Widget _statusCard() {
    final enabled = _enabled;
    return Card(
      child: ListTile(
        leading: Icon(
          enabled == true
              ? Icons.notifications_active_outlined
              : Icons.notifications_off_outlined,
          color: enabled == true
              ? Colors.green
              : (enabled == false ? AppConstants.primaryRed : null),
        ),
        title: const Text('通知权限'),
        subtitle: Text(
          enabled == null
              ? '检测中…'
              : (enabled ? '已开启' : '未开启，提醒可能收不到'),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _brandSteps(String brand, List<String> steps) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(brand, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          ...steps.map(
            (s) => Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 2),
              child: Text('· $s', style: const TextStyle(height: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}
