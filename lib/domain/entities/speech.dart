import 'package:equatable/equatable.dart';

/// Core domain entity — immutable, pure business object
/// No framework dependencies here (Clean Architecture)
class Speech extends Equatable {
  final String id;
  final String userId;
  final String audioUrl;
  final String? localPath;
  final DateTime createdAt;
  final Duration? duration;
  final SpeechFeedback? feedback;
  final SpeechStatus status;

  const Speech({
    required this.id,
    required this.userId,
    required this.audioUrl,
    this.localPath,
    required this.createdAt,
    this.duration,
    this.feedback,
    this.status = SpeechStatus.uploaded,
  });

  /// Immutable update pattern (no mutation)
  Speech copyWith({
    String? id,
    String? userId,
    String? audioUrl,
    String? localPath,
    DateTime? createdAt,
    Duration? duration,
    SpeechFeedback? feedback,
    SpeechStatus? status,
  }) {
    return Speech(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      audioUrl: audioUrl ?? this.audioUrl,
      localPath: localPath ?? this.localPath,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      feedback: feedback ?? this.feedback,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, userId, audioUrl, createdAt, status];

  @override
  String toString() => 'Speech(id: $id, userId: $userId, status: $status)';
}

/// Value object for AI-generated speech feedback
class SpeechFeedback extends Equatable {
  final double paceScore;         // Words per minute score (0–100)
  final double toneScore;         // Tone confidence score (0–100)
  final double clarityScore;      // Clarity/articulation score (0–100)
  final List<String> fillerWords; // Detected filler words
  final int fillerWordCount;
  final String summary;           // AI-generated narrative summary
  final List<String> suggestions; // Actionable improvement tips
  final DateTime analyzedAt;

  const SpeechFeedback({
    required this.paceScore,
    required this.toneScore,
    required this.clarityScore,
    required this.fillerWords,
    required this.fillerWordCount,
    required this.summary,
    required this.suggestions,
    required this.analyzedAt,
  });

  double get overallScore => (paceScore + toneScore + clarityScore) / 3;

  String get grade {
    if (overallScore >= 85) return 'Excellent';
    if (overallScore >= 70) return 'Good';
    if (overallScore >= 55) return 'Fair';
    return 'Needs Work';
  }

  @override
  List<Object?> get props => [paceScore, toneScore, clarityScore, analyzedAt];
}

/// Lifecycle states for a speech recording
enum SpeechStatus {
  recording,
  uploading,
  uploaded,
  analyzing,
  analyzed,
  failed,
}
