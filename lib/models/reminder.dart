class Reminder {
  final int? id;
  final String name;
  final String avatar;
  final String? avatarImagePath;
  final int lunarMonth;
  final int lunarDay;
  final int? solarMonth;
  final int? solarDay;
  final int? birthYear;
  final int advanceDays;
  final int notifyIntervalSeconds;
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reminder({
    this.id,
    required this.name,
    required this.avatar,
    this.avatarImagePath,
    required this.lunarMonth,
    required this.lunarDay,
    this.solarMonth,
    this.solarDay,
    this.birthYear,
    required this.advanceDays,
    required this.notifyIntervalSeconds,
    this.enabled = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Reminder copyWith({
    int? id,
    String? name,
    String? avatar,
    String? avatarImagePath,
    int? lunarMonth,
    int? lunarDay,
    int? solarMonth,
    int? solarDay,
    int? birthYear,
    int? advanceDays,
    int? notifyIntervalSeconds,
    bool? enabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      avatarImagePath: avatarImagePath ?? this.avatarImagePath,
      lunarMonth: lunarMonth ?? this.lunarMonth,
      lunarDay: lunarDay ?? this.lunarDay,
      solarMonth: solarMonth ?? this.solarMonth,
      solarDay: solarDay ?? this.solarDay,
      birthYear: birthYear ?? this.birthYear,
      advanceDays: advanceDays ?? this.advanceDays,
      notifyIntervalSeconds: notifyIntervalSeconds ?? this.notifyIntervalSeconds,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'avatar': avatar,
      'avatar_image_path': avatarImagePath,
      'lunar_month': lunarMonth,
      'lunar_day': lunarDay,
      'solar_month': solarMonth,
      'solar_day': solarDay,
      'birth_year': birthYear,
      'advance_days': advanceDays,
      'notify_interval_seconds': notifyIntervalSeconds,
      'enabled': enabled ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int?,
      name: map['name'] as String,
      avatar: map['avatar'] as String,
      avatarImagePath: map['avatar_image_path'] as String?,
      lunarMonth: map['lunar_month'] as int,
      lunarDay: map['lunar_day'] as int,
      solarMonth: map['solar_month'] as int?,
      solarDay: map['solar_day'] as int?,
      birthYear: map['birth_year'] as int?,
      advanceDays: map['advance_days'] as int,
      notifyIntervalSeconds: map['notify_interval_seconds'] as int,
      enabled: (map['enabled'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  String get lunarBirthdayText => '$lunarMonth月$lunarDay日';
}
