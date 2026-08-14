import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../models/reminder.dart';
import '../providers/reminder_provider.dart';
import '../utils/constants.dart';

class AddEditScreen extends StatefulWidget {
  final Reminder? reminder;
  const AddEditScreen({super.key, this.reminder});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _birthYearController;

  late String _avatar;
  String? _avatarImagePath;
  late int _lunarMonth;
  late int _lunarDay;
  late bool _hasSolarBirthday;
  late int _solarMonth;
  late int _solarDay;
  late int _advanceDays;
  late int _notifyIntervalSeconds;
  late bool _enabled;

  bool get _isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    _nameController = TextEditingController(text: r?.name ?? '');
    _birthYearController =
        TextEditingController(text: r?.birthYear?.toString() ?? '');
    _avatar = r?.avatar ?? AppConstants.avatarEmojis.first;
    _avatarImagePath = r?.avatarImagePath;
    _lunarMonth = r?.lunarMonth ?? 1;
    _lunarDay = r?.lunarDay ?? 1;
    _hasSolarBirthday = r?.solarMonth != null;
    _solarMonth = r?.solarMonth ?? 1;
    _solarDay = r?.solarDay ?? 1;
    _advanceDays = r?.advanceDays ?? AppConstants.defaultAdvanceDays;
    _notifyIntervalSeconds =
        r?.notifyIntervalSeconds ?? AppConstants.defaultNotifyIntervalSeconds;
    _enabled = r?.enabled ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthYearController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final reminder = Reminder(
      id: widget.reminder?.id,
      name: _nameController.text.trim(),
      avatar: _avatar,
      avatarImagePath: _avatarImagePath,
      lunarMonth: _lunarMonth,
      lunarDay: _lunarDay,
      solarMonth: _hasSolarBirthday ? _solarMonth : null,
      solarDay: _hasSolarBirthday ? _solarDay : null,
      birthYear: _parseBirthYear(),
      advanceDays: _advanceDays,
      notifyIntervalSeconds: _notifyIntervalSeconds,
      enabled: _enabled,
      updatedAt: DateTime.now(),
    );
    final provider = context.read<ReminderProvider>();
    if (_isEditing) {
      provider.update(reminder);
    } else {
      provider.add(reminder);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑提醒' : '新增提醒'),
        actions: [
          TextButton(
            onPressed: _save,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '姓名',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '请输入姓名' : null,
            ),
            const SizedBox(height: 24),
            _sectionTitle('头像'),
            const SizedBox(height: 12),
            Row(
              children: [
                _avatarPreview(),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('从相册选照片'),
                ),
                if (_avatarImagePath != null)
                  TextButton(
                    onPressed: () => setState(() => _avatarImagePath = null),
                    child: const Text('移除照片'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.avatarEmojis.map((e) {
                final selected = e == _avatar && _avatarImagePath == null;
                return InkWell(
                  onTap: () => setState(() {
                    _avatar = e;
                    _avatarImagePath = null;
                  }),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Text(e, style: const TextStyle(fontSize: 24)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _sectionTitle('阴历生日（必填）'),
            Row(
              children: [
                _dropdown(
                  value: _lunarMonth,
                  items: _range(1, 12),
                  label: (v) => '$v',
                  onChanged: (v) => setState(() => _lunarMonth = v!),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('月'),
                ),
                _dropdown(
                  value: _lunarDay,
                  items: _range(1, 30),
                  label: (v) => '$v',
                  onChanged: (v) => setState(() => _lunarDay = v!),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('日'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionTitle('出生年份（选填，用于算生肖和年龄）'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _birthYearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '例如 1990',
                border: OutlineInputBorder(),
              ),
              validator: _validateBirthYear,
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: _sectionTitle('阳历生日（可选）'),
              value: _hasSolarBirthday,
              onChanged: (v) => setState(() => _hasSolarBirthday = v),
            ),
            if (_hasSolarBirthday)
              Row(
                children: [
                  _dropdown(
                    value: _solarMonth,
                    items: _range(1, 12),
                    label: (v) => '$v',
                    onChanged: (v) => setState(() => _solarMonth = v!),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('月'),
                  ),
                  _dropdown(
                    value: _solarDay,
                    items: _range(1, 31),
                    label: (v) => '$v',
                    onChanged: (v) => setState(() => _solarDay = v!),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('日'),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            _sectionTitle('提前通知'),
            Row(
              children: [
                _dropdown(
                  value: _advanceDays,
                  items: _range(
                    AppConstants.minAdvanceDays,
                    AppConstants.maxAdvanceDays,
                  ),
                  label: (v) => '$v',
                  onChanged: (v) => setState(() => _advanceDays = v!),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('天'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionTitle('通知间隔'),
            _dropdown(
              value: _notifyIntervalSeconds,
              items: AppConstants.intervalPresetSeconds,
              label: AppConstants.formatInterval,
              onChanged: (v) => setState(() => _notifyIntervalSeconds = v!),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: _sectionTitle('启用提醒'),
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
            ),
          ],
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

  List<int> _range(int start, int end) {
    return List.generate(end - start + 1, (i) => start + i);
  }

  Widget _dropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) label,
    required void Function(T?) onChanged,
  }) {
    return DropdownButton<T>(
      value: value,
      items: items
          .map((e) => DropdownMenuItem<T>(value: e, child: Text(label(e))))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _avatarPreview() {
    final path = _avatarImagePath;
    if (path != null && path.isNotEmpty) {
      return CircleAvatar(radius: 28, backgroundImage: FileImage(File(path)));
    }
    return CircleAvatar(
      radius: 28,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Text(_avatar, style: const TextStyle(fontSize: 32)),
    );
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '${dir.path}/$fileName';
    await File(picked.path).copy(savedPath);
    if (!mounted) return;
    setState(() => _avatarImagePath = savedPath);
  }

  int? _parseBirthYear() {
    final text = _birthYearController.text.trim();
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  String? _validateBirthYear(String? v) {
    final text = v?.trim() ?? '';
    if (text.isEmpty) return null;
    final year = int.tryParse(text);
    final currentYear = DateTime.now().year;
    if (year == null || year < 1900 || year > currentYear) {
      return '请输入 1900~$currentYear 之间的年份';
    }
    return null;
  }
}
