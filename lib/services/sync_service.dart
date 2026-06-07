import '../helpers/database_helper.dart';
import 'api_service.dart';
import 'session_manager.dart';

class SyncService {
  // Sync all unsynced local recordings to MySQL
  static Future<void> syncToServer() async {
    if (!SessionManager.isLoggedIn) return;

    final isOnline = await ApiService.isOnline();
    if (!isOnline) {
      print('SYNC: Device is offline, skipping sync');
      return;
    }

    final unsynced =
        await DatabaseHelper.instance.getUnsyncedRecordings();
    print('SYNC: Found ${unsynced.length} unsynced recordings');

    for (final recording in unsynced) {
      try {
        final result = await ApiService.saveTranscription(
          userId: SessionManager.userId!,
          transcript: recording['transcript'] ?? '',
          wordCount: recording['word_count'] ?? 0,
          fillerWordCount: recording['filler_word_count'] ?? 0,
          repeatedWordCount: recording['repeated_word_count'] ?? 0,
        );

        if (result != null) {
          await DatabaseHelper.instance
              .markRecordingSynced(recording['id']);
          print('SYNC: Synced recording ${recording['id']}');
        }
      } catch (e) {
        print('SYNC ERROR for recording ${recording['id']}: $e');
      }
    }
  }
}