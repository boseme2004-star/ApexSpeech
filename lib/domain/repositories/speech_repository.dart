import 'dart:io';
import 'package:apex_speech/domain/entities/speech.dart';

/// Abstract contract for speech data operations
/// Follows Interface Segregation — only what's needed
abstract class SpeechRepository {
  /// Upload a recorded audio file and create a Speech record
  Future<Speech> uploadSpeech({
    required File audioFile,
    required String userId,
    required Duration duration,
  });

  /// Fetch all speeches for a given user (ordered by date desc)
  Future<List<Speech>> getSpeeches(String userId);

  /// Fetch a single speech by ID
  Future<Speech?> getSpeechById(String speechId);

  /// Delete a speech and its associated audio file
  Future<void> deleteSpeech(String speechId);

  /// Trigger AI analysis for a speech (async — results stored in Firestore)
  Future<void> requestAnalysis(String speechId);

  /// Stream real-time updates for a speech (e.g., during analysis)
  Stream<Speech?> watchSpeech(String speechId);
}

/// Typed speech exceptions
class SpeechException implements Exception {
  final String message;
  final String? code;

  const SpeechException(this.message, {this.code});

  @override
  String toString() => 'SpeechException: $message';
}
