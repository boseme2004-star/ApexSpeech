import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('apex_speech.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE recordings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        audio_path TEXT NOT NULL,
        transcript TEXT,
        word_count INTEGER,
        filler_word_count INTEGER,
        repeated_word_count INTEGER,
        speaking_speed REAL,
        frequent_words TEXT,
        ai_feedback TEXT,
        date_created TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        goal TEXT,
        about TEXT
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE profile ADD COLUMN about TEXT');
    }
  }

  // ── Recording CRUD ──

  Future<int> insertRecording(Map<String, dynamic> recording) async {
    final db = await database;
    return await db.insert('recordings', recording);
  }

  Future<List<Map<String, dynamic>>> getAllRecordings() async {
    final db = await database;
    return await db.query('recordings', orderBy: 'date_created DESC');
  }

  Future<Map<String, dynamic>?> getRecordingById(int id) async {
    final db = await database;
    final results = await db.query(
      'recordings',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateRecording(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      'recordings',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteRecording(int id) async {
    final db = await database;
    return await db.delete(
      'recordings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── Progress Stats ──

  Future<Map<String, dynamic>> getProgressStats() async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_recordings,
        AVG(speaking_speed) as avg_speaking_speed,
        AVG(filler_word_count) as avg_filler_words,
        AVG(word_count) as avg_word_count
      FROM recordings
    ''');
    return results.first;
  }

  Future<List<Map<String, dynamic>>> getRecentRecordings(int limit) async {
    final db = await database;
    return await db.query(
      'recordings',
      orderBy: 'date_created DESC',
      limit: limit,
    );
  }

  // ── Profile CRUD ──

  Future<int> insertProfile(Map<String, dynamic> profile) async {
    final db = await database;
    return await db.insert('profile', profile);
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final db = await database;
    final results = await db.query('profile', limit: 1);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateProfile(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      'profile',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}