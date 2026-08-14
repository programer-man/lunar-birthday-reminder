import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// 关于页：展示应用信息、开发者、版权与联系方式。
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 24),
          const Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppConstants.primaryRed,
              child: Icon(Icons.nightlight_round, size: 48, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              '忆辰',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '版本 1.0.0',
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            '开发信息',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _infoRow(context, '开发者', 'zhangxiaoyuan'),
          _infoRow(context, '联系方式', 'wx: zy67699900'),
          const SizedBox(height: 24),
          _infoRow(context, '版权', '© 2026 zhangxiaoyuan 版权所有'),
          const SizedBox(height: 40),
          Center(
            child: Text(
              '记住亲友的每一个生日',
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
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
            width: 80,
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
}
