// =============================================================
//  data/repositories/mock_feedback_repository.dart
//
//  OOP  : Polymorphism — implements FeedbackRepository
//  SOLID: OCP — swap this for FirebaseFeedbackRepository
//         in production without touching any other file
//
//  Used for development / UI testing without a live backend.
// =============================================================

import 'dart:async';
import '../../domain/entities/speech_feedback.dart';
import '../../domain/repositories/feedback_repository.dart';

class MockFeedbackRepository implements FeedbackRepository {
  // Simulates the network delay of a real API call
  static const _delay = Duration(milliseconds: 1200);

  @override
  Future<SpeechFeedback> getFeedback(String speechId) async {
    await Future.delayed(_delay);
    return _buildMockFeedback(speechId);
  }

  @override
  Stream<SpeechFeedback?> watchFeedback(String speechId) async* {
    // Simulate: first emit null (analyzing), then emit result
    yield null;
    await Future.delayed(const Duration(seconds: 2));
    yield _buildMockFeedback(speechId);
  }

  @override
  Future<void> requestAnalysis(String speechId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // ─── Private factory ─────────────────────────────────────

  SpeechFeedback _buildMockFeedback(String speechId) {
    return SpeechFeedback(
      id:               'feedback_001',
      speechId:         speechId,
      paceScore:        72.0,
      toneScore:        68.0,
      clarityScore:     80.0,
      confidenceScore:  75.0,
      fillerWords:      ['um', 'uh', 'like', 'you know'],
      fillerWordCount:  14,
      wordsPerMinute:   138,
      summary:
          'Your delivery showed strong clarity and a well-paced rhythm. '
          'Focus on reducing filler words and adding more vocal variety '
          'to keep your audience fully engaged.',
      strengths: [
        'Clear articulation throughout',
        'Well-structured argument flow',
        'Confident opening statement',
      ],
      suggestions: [
        'Pause intentionally instead of saying "um" or "uh"',
        'Vary your pitch more — emphasise key words by raising your tone',
        'Aim for 120–150 words per minute for optimal comprehension',
        'Record yourself weekly to track progress over time',
      ],
      analyzedAt: DateTime.now(),
    );
  }
}
