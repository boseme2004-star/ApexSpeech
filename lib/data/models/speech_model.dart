import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apex_speech/domain/entities/speech.dart';

/// Data Transfer Object — maps between Firestore and domain entities
/// Follows the Adapter pattern to isolate domain from data layer details
class SpeechModel {
  final String id;
  final String userId;
  final String audioUrl;
  final DateTime createdAt;
  final int? durationSeconds;
  final Map<String, dynamic>? feedbackData;
  final String status;

  const SpeechModel({
    required this.id,
    required this.userId,
    required this.audioUrl,
    required this.createdAt,
    this.durationSeconds,
    this.feedbackData,
    required this.status,
  });

  // ─── Factory: From Firestore document ────────────────────────
  factory SpeechModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SpeechModel(
      id: doc.id,
      userId: data['userId'] as String,
      audioUrl: data['audioUrl'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      durationSeconds: data['durationSeconds'] as int?,
      feedbackData: data['feedback'] as Map<String, dynamic>?,
      status: data['status'] as String? ?? 'uploaded',
    );
  }

  // ─── Factory: From domain entity ─────────────────────────────
  factory SpeechModel.fromEntity(Speech speech) {
    return SpeechModel(
      id: speech.id,
      userId: speech.userId,
      audioUrl: speech.audioUrl,
      createdAt: speech.createdAt,
      durationSeconds: speech.duration?.inSeconds,
      feedbackData: speech.feedback != null
          ? _feedbackToMap(speech.feedback!)
          : null,
      status: speech.status.name,
    );
  }

  // ─── To domain entity ─────────────────────────────────────────
  Speech toEntity() {
    return Speech(
      id: id,
      userId: userId,
      audioUrl: audioUrl,
      createdAt: createdAt,
      duration: durationSeconds != null
          ? Duration(seconds: durationSeconds!)
          : null,
      feedback: feedbackData != null ? _feedbackFromMap(feedbackData!) : null,
      status: SpeechStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => SpeechStatus.uploaded,
      ),
    );
  }

  // ─── To Firestore map ─────────────────────────────────────────
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'audioUrl': audioUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'durationSeconds': durationSeconds,
      'feedback': feedbackData,
      'status': status,
    };
  }

  // ─── Private helpers ──────────────────────────────────────────
  static Map<String, dynamic> _feedbackToMap(SpeechFeedback f) {
    return {
      'paceScore': f.paceScore,
      'toneScore': f.toneScore,
      'clarityScore': f.clarityScore,
      'fillerWords': f.fillerWords,
      'fillerWordCount': f.fillerWordCount,
      'summary': f.summary,
      'suggestions': f.suggestions,
      'analyzedAt': Timestamp.fromDate(f.analyzedAt),
    };
  }

  static SpeechFeedback _feedbackFromMap(Map<String, dynamic> m) {
    return SpeechFeedback(
      paceScore: (m['paceScore'] as num).toDouble(),
      toneScore: (m['toneScore'] as num).toDouble(),
      clarityScore: (m['clarityScore'] as num).toDouble(),
      fillerWords: List<String>.from(m['fillerWords'] as List),
      fillerWordCount: m['fillerWordCount'] as int,
      summary: m['summary'] as String,
      suggestions: List<String>.from(m['suggestions'] as List),
      analyzedAt: (m['analyzedAt'] as Timestamp).toDate(),
    );
  }
}
