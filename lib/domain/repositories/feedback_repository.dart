// =============================================================
//  domain/repositories/feedback_repository.dart
//
//  OOP  : Abstraction — contract only, no implementation details
//  SOLID: DIP — high-level modules depend on this abstraction,
//         not on Firebase or any concrete data source
// =============================================================

import '../entities/speech_feedback.dart';

abstract class FeedbackRepository {
  /// Fetch feedback for a given speech ID
  /// Throws [FeedbackNotFoundException] if not found
  Future<SpeechFeedback> getFeedback(String speechId);

  /// Stream real-time updates while analysis is running
  Stream<SpeechFeedback?> watchFeedback(String speechId);

  /// Trigger AI analysis — result arrives via [watchFeedback]
  Future<void> requestAnalysis(String speechId);
}

// ─── Domain exceptions ────────────────────────────────────────

class FeedbackNotFoundException implements Exception {
  final String message;
  const FeedbackNotFoundException(this.message);

  @override
  String toString() => 'FeedbackNotFoundException: $message';
}

class FeedbackAnalysisException implements Exception {
  final String message;
  const FeedbackAnalysisException(this.message);

  @override
  String toString() => 'FeedbackAnalysisException: $message';
}
