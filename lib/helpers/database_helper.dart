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
    // Recordings table
    await db.execute('''
      CREATE TABLE recordings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        audio_path TEXT NOT NULL,
        transcript TEXT,
        word_count INTEGER DEFAULT 0,
        filler_word_count INTEGER DEFAULT 0,
        repeated_word_count INTEGER DEFAULT 0,
        speaking_speed REAL DEFAULT 0,
        frequent_words TEXT,
        ai_feedback TEXT,
        date_created TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // Profile table
    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        goal TEXT,
        about TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // Create indexes for faster queries
    await db.execute(
      'CREATE INDEX idx_recordings_date ON recordings(date_created DESC)'
    );
    await db.execute(
      'CREATE INDEX idx_recordings_title ON recordings(title)'
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE profile ADD COLUMN about TEXT');
      await db.execute('ALTER TABLE recordings ADD COLUMN is_synced INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE profile ADD COLUMN is_synced INTEGER DEFAULT 0');
    }
  }

  // ── Recording CRUD ──

  Future<int> insertRecording(Map<String, dynamic> recording) async {
    try {
      final db = await database;
      return await db.insert(
        'recordings',
        recording,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('INSERT RECORDING ERROR: $e');
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getAllRecordings() async {
    try {
      final db = await database;
      return await db.query('recordings', orderBy: 'date_created DESC');
    } catch (e) {
      print('GET ALL RECORDINGS ERROR: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getRecordingById(int id) async {
    try {
      final db = await database;
      final results = await db.query(
        'recordings',
        where: 'id = ?',
        whereArgs: [id],
      );
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      print('GET RECORDING BY ID ERROR: $e');
      return null;
    }
  }

  // Search recordings by title or transcript keyword
  Future<List<Map<String, dynamic>>> searchRecordings(String query) async {
    try {
      final db = await database;
      return await db.query(
        'recordings',
        where: 'title LIKE ? OR transcript LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'date_created DESC',
      );
    } catch (e) {
      print('SEARCH RECORDINGS ERROR: $e');
      return [];
    }
  }

  // Filter recordings by date range
  Future<List<Map<String, dynamic>>> filterRecordingsByDate({
    required String from,
    required String to,
  }) async {
    try {
      final db = await database;
      return await db.query(
        'recordings',
        where: 'date_created BETWEEN ? AND ?',
        whereArgs: [from, to],
        orderBy: 'date_created DESC',
      );
    } catch (e) {
      print('FILTER RECORDINGS ERROR: $e');
      return [];
    }
  }

  Future<int> updateRecording(int id, Map<String, dynamic> data) async {
    try {
      final db = await database;
      return await db.update(
        'recordings',
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('UPDATE RECORDING ERROR: $e');
      return -1;
    }
  }

  // Rename recording title
  Future<int> renameRecording(int id, String newTitle) async {
    try {
      final db = await database;
      return await db.update(
        'recordings',
        {'title': newTitle, 'is_synced': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('RENAME RECORDING ERROR: $e');
      return -1;
    }
  }

  // Delete recording and its audio file
  Future<bool> deleteRecording(int id) async {
    try {
      final db = await database;

      // Get audio path first for file deletion
      final recording = await getRecordingById(id);
      if (recording != null) {
        final audioPath = recording['audio_path'] as String?;
        if (audioPath != null && audioPath.isNotEmpty) {
          final file = File(audioPath);
          if (await file.exists()) {
            await file.delete();
            print('AUDIO FILE DELETED: $audioPath');
          }
        }
      }

      await db.delete(
        'recordings',
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      print('DELETE RECORDING ERROR: $e');
      return false;
    }
  }

  // Get unsynced recordings for backend sync
  Future<List<Map<String, dynamic>>> getUnsyncedRecordings() async {
    try {
      final db = await database;
      return await db.query(
        'recordings',
        where: 'is_synced = ?',
        whereArgs: [0],
      );
    } catch (e) {
      print('GET UNSYNCED RECORDINGS ERROR: $e');
      return [];
    }
  }

  // Mark recording as synced
  Future<void> markRecordingSynced(int id) async {
    try {
      final db = await database;
      await db.update(
        'recordings',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('MARK SYNCED ERROR: $e');
    }
  }

  // ── Progress Stats ──

  Future<Map<String, dynamic>> getProgressStats() async {
    try {
      final db = await database;
      final results = await db.rawQuery('''
        SELECT 
          COUNT(*) as total_recordings,
          AVG(speaking_speed) as avg_speaking_speed,
          AVG(filler_word_count) as avg_filler_words,
          AVG(word_count) as avg_word_count,
          MAX(word_count) as best_word_count,
          MIN(filler_word_count) as best_filler_count
        FROM recordings
      ''');
      return results.first;
    } catch (e) {
      print('GET PROGRESS STATS ERROR: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getRecentRecordings(int limit) async {
    try {
      final db = await database;
      return await db.query(
        'recordings',
        orderBy: 'date_created DESC',
        limit: limit,
      );
    } catch (e) {
      print('GET RECENT RECORDINGS ERROR: $e');
      return [];
    }
  }

  // Export transcription as plain text
  Future<String> exportTranscriptionAsText(int id) async {
    try {
      final recording = await getRecordingById(id);
      if (recording == null) return '';

      return '''
APEX SPEECH - Transcription Export
====================================
Title: ${recording['title'] ?? 'Recording'}
Date: ${recording['date_created'] ?? ''}

TRANSCRIPT:
${recording['transcript'] ?? 'No transcript available'}

SPEECH ANALYSIS:
- Word Count: ${recording['word_count'] ?? 0}
- Filler Words: ${recording['filler_word_count'] ?? 0}
- Repeated Words: ${recording['repeated_word_count'] ?? 0}
- Speaking Speed: ${(recording['speaking_speed'] ?? 0.0).toStringAsFixed(1)} WPM

AI FEEDBACK:
${recording['ai_feedback'] ?? 'No feedback generated yet'}
====================================
''';
    } catch (e) {
      print('EXPORT ERROR: $e');
      return '';
    }
  }

  // ── Profile CRUD ──

  Future<int> insertProfile(Map<String, dynamic> profile) async {
    try {
      final db = await database;
      return await db.insert(
        'profile',
        profile,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('INSERT PROFILE ERROR: $e');
      return -1;
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final db = await database;
      final results = await db.query('profile', limit: 1);
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      print('GET PROFILE ERROR: $e');
      return null;
    }
  }

  Future<int> updateProfile(int id, Map<String, dynamic> data) async {
    try {
      final db = await database;
      return await db.update(
        'profile',
        {...data, 'is_synced': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('UPDATE PROFILE ERROR: $e');
      return -1;
    }
  }

  // ── Utility ──

  // Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete('recordings');
      await db.delete('profile');
      print('ALL DATA CLEARED');
    } catch (e) {
      print('CLEAR DATA ERROR: $e');
    }
  }

  // Get total DB size info
  Future<int> getTotalRecordingsCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM recordings');
      return result.first['count'] as int;
    } catch (e) {
      print('COUNT ERROR: $e');
      return 0;
    }
  }
}