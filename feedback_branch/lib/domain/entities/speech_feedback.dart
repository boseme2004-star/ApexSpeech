// =============================================================
//  domain/entities/speech_feedback.dart
//
//  Pure domain entity — no Flutter, no Firebase, no framework.
//  This is the core data the entire feedback feature revolves around.
//
//  OOP  : Encapsulation — computed properties hide formula details
//  SOLID: SRP — one class, one concern: representing feedback data
// =============================================================

import 'package:equatable/equatable.dart';

// ─── Score category value object ─────────────────────────────

/// Represents a single scored dimension of a speech
class ScoreCategory extends Equatable {
  final String label;
  final double score; // 0–100
  final String emoji;

  const ScoreCategory({
    required this.label,
    required this.score,
    required this.emoji,
  });

  /// Semantic level derived from score — no magic numbers scattered around
  ScoreLevel get level {
    if (score >= 85) return ScoreLevel.excellent;
    if (score >= 70) return ScoreLevel.good;
    if (score >= 55) return ScoreLevel.fair;
    return ScoreLevel.needsWork;
  }

  @override
  List<Object?> get props => [label, score];
}

enum ScoreLevel { excellent, good, fair, needsWork }

// ─── Main feedback entity ─────────────────────────────────────

class SpeechFeedback extends Equatable {
  final String id;
  final String speechId;
  final double paceScore;
  final double toneScore;
  final double clarityScore;
  final double confidenceScore;
  final List<String> fillerWords;
  final int fillerWordCount;
  final String summary;
  final List<String> suggestions;
  final List<String> strengths;
  final int wordsPerMinute;
  final DateTime analyzedAt;

  const SpeechFeedback({
    required this.id,
    required this.speechId,
    required this.paceScore,
    required this.toneScore,
    required this.clarityScore,
    required this.confidenceScore,
    required this.fillerWords,
    required this.fillerWordCount,
    required this.summary,
    required this.suggestions,
    required this.strengths,
    required this.wordsPerMinute,
    required this.analyzedAt,
  });

  // ─── Computed properties (encapsulation) ─────────────────

  double get overallScore =>
      (paceScore + toneScore + clarityScore + confidenceScore) / 4;

  String get grade {
    final s = overallScore;
    if (s >= 85) return 'Excellent';
    if (s >= 70) return 'Good';
    if (s >= 55) return 'Fair';
    return 'Needs Work';
  }

  String get gradeSummary {
    switch (grade) {
      case 'Excellent':
        return 'Outstanding delivery — keep it up!';
      case 'Good':
        return 'Solid performance with room to grow';
      case 'Fair':
        return 'Good foundation — focus on the suggestions';
      default:
        return 'Keep practising — every session counts';
    }
  }

  /// All four categories as a list — DRY, drives the UI loop
  List<ScoreCategory> get categories => [
        ScoreCategory(label: 'Pace',       score: paceScore,       emoji: '⚡'),
        ScoreCategory(label: 'Tone',       score: toneScore,       emoji: '🎵'),
        ScoreCategory(label: 'Clarity',    score: clarityScore,    emoji: '💎'),
        ScoreCategory(label: 'Confidence', score: confidenceScore, emoji: '🔥'),
      ];

  /// Immutable update — never mutate the entity
  SpeechFeedback copyWith({
    double? paceScore,
    double? toneScore,
    double? clarityScore,
    double? confidenceScore,
  }) {
    return SpeechFeedback(
      id:               id,
      speechId:         speechId,
      paceScore:        paceScore        ?? this.paceScore,
      toneScore:        toneScore        ?? this.toneScore,
      clarityScore:     clarityScore     ?? this.clarityScore,
      confidenceScore:  confidenceScore  ?? this.confidenceScore,
      fillerWords:      fillerWords,
      fillerWordCount:  fillerWordCount,
      summary:          summary,
      suggestions:      suggestions,
      strengths:        strengths,
      wordsPerMinute:   wordsPerMinute,
      analyzedAt:       analyzedAt,
    );
  }

  @override
  List<Object?> get props => [id, speechId, analyzedAt];

  @override
  String toString() =>
      'SpeechFeedback(id: $id, overall: ${overallScore.toStringAsFixed(1)})';
}
