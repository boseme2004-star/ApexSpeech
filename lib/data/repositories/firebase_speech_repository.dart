import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:apex_speech/core/constants/app_constants.dart';
import 'package:apex_speech/domain/entities/speech.dart';
import 'package:apex_speech/domain/repositories/speech_repository.dart';
import 'package:apex_speech/data/models/speech_model.dart';

/// Firebase implementation of SpeechRepository
/// Handles audio upload to Storage + metadata to Firestore
class FirebaseSpeechRepository implements SpeechRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final Uuid _uuid;

  FirebaseSpeechRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    Uuid? uuid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _uuid = uuid ?? const Uuid();

  // ─── Upload Speech ────────────────────────────────────────────
  @override
  Future<Speech> uploadSpeech({
    required File audioFile,
    required String userId,
    required Duration duration,
  }) async {
    try {
      final speechId = _uuid.v4();
      final fileName = '$speechId${AppConstants.audioExtension}';
      final storageRef = _storage.ref().child(
            '${AppConstants.audioStoragePath}$userId/$fileName',
          );

      // Upload audio to Firebase Storage
      final uploadTask = await storageRef.putFile(
        audioFile,
        SettableMetadata(contentType: 'audio/m4a'),
      );
      final audioUrl = await uploadTask.ref.getDownloadURL();

      // Create speech document in Firestore
      final speech = Speech(
        id: speechId,
        userId: userId,
        audioUrl: audioUrl,
        localPath: audioFile.path,
        createdAt: DateTime.now(),
        duration: duration,
        status: SpeechStatus.uploaded,
      );

      final model = SpeechModel.fromEntity(speech);
      await _firestore
          .collection(AppConstants.speechesCollection)
          .doc(speechId)
          .set(model.toFirestore());

      return speech;
    } catch (e) {
      throw SpeechException('Failed to upload speech: ${e.toString()}');
    }
  }

  // ─── Get Speeches ─────────────────────────────────────────────
  @override
  Future<List<Speech>> getSpeeches(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.speechesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SpeechModel.fromFirestore(doc).toEntity())
          .toList();
    } catch (e) {
      throw SpeechException('Failed to load speeches: ${e.toString()}');
    }
  }

  // ─── Get Speech By ID ─────────────────────────────────────────
  @override
  Future<Speech?> getSpeechById(String speechId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.speechesCollection)
          .doc(speechId)
          .get();

      if (!doc.exists) return null;
      return SpeechModel.fromFirestore(doc).toEntity();
    } catch (e) {
      throw SpeechException('Failed to fetch speech: ${e.toString()}');
    }
  }

  // ─── Delete Speech ────────────────────────────────────────────
  @override
  Future<void> deleteSpeech(String speechId) async {
    try {
      final speech = await getSpeechById(speechId);
      if (speech == null) return;

      // Delete from Storage
      final storageRef = _storage.refFromURL(speech.audioUrl);
      await storageRef.delete();

      // Delete from Firestore
      await _firestore
          .collection(AppConstants.speechesCollection)
          .doc(speechId)
          .delete();
    } catch (e) {
      throw SpeechException('Failed to delete speech: ${e.toString()}');
    }
  }

  // ─── Request AI Analysis (placeholder for future AI service) ──
  @override
  Future<void> requestAnalysis(String speechId) async {
    try {
      // Update status to "analyzing"
      await _firestore
          .collection(AppConstants.speechesCollection)
          .doc(speechId)
          .update({'status': SpeechStatus.analyzing.name});

      // TODO: Trigger Cloud Function / external AI service
      // For MVP: generate mock feedback after delay
      await Future.delayed(const Duration(seconds: 2));
      await _saveMockFeedback(speechId);
    } catch (e) {
      await _firestore
          .collection(AppConstants.speechesCollection)
          .doc(speechId)
          .update({'status': SpeechStatus.failed.name});
      throw SpeechException('Analysis failed: ${e.toString()}');
    }
  }

  // ─── Watch Speech (real-time) ─────────────────────────────────
  @override
  Stream<Speech?> watchSpeech(String speechId) {
    return _firestore
        .collection(AppConstants.speechesCollection)
        .doc(speechId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return SpeechModel.fromFirestore(doc).toEntity();
    });
  }

  // ─── Mock Feedback (MVP placeholder) ─────────────────────────
  Future<void> _saveMockFeedback(String speechId) async {
    final mockFeedback = {
      'paceScore': 72.0,
      'toneScore': 68.0,
      'clarityScore': 80.0,
      'fillerWords': ['um', 'uh', 'like', 'you know'],
      'fillerWordCount': 14,
      'summary':
          'Your delivery showed good structure with clear articulation. Consider reducing filler words and maintaining a more consistent pace throughout.',
      'suggestions': [
        'Practice pausing instead of saying "um" or "uh"',
        'Vary your vocal tone for emphasis on key points',
        'Aim for 120–150 words per minute for optimal clarity',
        'Record yourself regularly to track progress',
      ],
      'analyzedAt': Timestamp.now(),
    };

    await _firestore
        .collection(AppConstants.speechesCollection)
        .doc(speechId)
        .update({
      'feedback': mockFeedback,
      'status': SpeechStatus.analyzed.name,
    });
  }
}
