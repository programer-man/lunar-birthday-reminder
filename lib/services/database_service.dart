import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/reminder.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static const _dbName = 'lunar_birthday_reminder.db';
  static const _table = 'reminders';

  Database? _db;

  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            avatar TEXT NOT NULL,
            avatar_image_path TEXT,
            lunar_month INTEGER NOT NULL,
            lunar_day INTEGER NOT NULL,
            solar_month INTEGER,
            solar_day INTEGER,
            birth_year INTEGER,
            advance_days INTEGER NOT NULL,
            notify_interval_seconds INTEGER NOT NULL,
            enabled INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              'ALTER TABLE $_table ADD COLUMN birth_year INTEGER');
          await db.execute(
              'ALTER TABLE $_table ADD COLUMN avatar_image_path TEXT');
        }
      },
    );
  }

  Future<int> insertReminder(Reminder r) async {
    final db = await database;
    return db.insert(_table, r.toMap());
  }

  Future<List<Reminder>> getAllReminders() async {
    final db = await database;
    final maps = await db.query(_table, orderBy: 'lunar_month, lunar_day');
    return maps.map((m) => Reminder.fromMap(m)).toList();
  }

  Future<int> updateReminder(Reminder r) async {
    final db = await database;
    return db.update(_table, r.toMap(), where: 'id = ?', whereArgs: [r.id]);
  }

  Future<int> deleteReminder(int id) async {
    final db = await database;
    return db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
