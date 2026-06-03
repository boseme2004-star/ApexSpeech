// =============================================================
//  domain/usecases/feedback_usecases.dart
//
//  OOP  : Single Responsibility — one class, one operation
//  SOLID: SRP + DIP — depends on abstract repo, not Firebase
//
//  Each use case is a callable class (operator call pattern).
//  ViewModels call use cases — never repositories directly.
// =============================================================

import '../entities/speech_feedback.dart';
import '../repositories/feedback_repository.dart';

// ─── Get feedback ─────────────────────────────────────────────

class GetFeedbackUseCase {
  final FeedbackRepository _repository;

  const GetFeedbackUseCase(this._repository);

  Future<SpeechFeedback> call(String speechId) {
    if (speechId.trim().isEmpty) {
      throw const FeedbackNotFoundException('Speech ID cannot be empty');
    }
    return _repository.getFeedback(speechId);
  }
}

// ─── Watch feedback (real-time stream) ───────────────────────

class WatchFeedbackUseCase {
  final FeedbackRepository _repository;

  const WatchFeedbackUseCase(this._repository);

  Stream<SpeechFeedback?> call(String speechId) {
    return _repository.watchFeedback(speechId);
  }
}

// ─── Request analysis ─────────────────────────────────────────

class RequestAnalysisUseCase {
  final FeedbackRepository _repository;

  const RequestAnalysisUseCase(this._repository);

  Future<void> call(String speechId) {
    return _repository.requestAnalysis(speechId);
  }
}
