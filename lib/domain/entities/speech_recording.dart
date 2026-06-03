// =============================================================
//  domain/entities/speech_recording.dart
//
//  Pure domain entity — no Flutter, no Firebase.
//  Represents a single recorded speech session.
//
//  OOP  : Encapsulation — computed helpers hide logic details
//  SOLID: SRP — one class, one concern: the recording data
// =============================================================

import 'package:equatable/equatable.dart';

enum PlaybackStatus { idle, loading, playing, paused, completed, error }

class SpeechRecording extends Equatable {
  final String id;
  final String userId;
  final String audioUrl;
  final String? localPath; // prefer local file over network
  final Duration duration;
  final DateTime recordedAt;
  final bool hasAnalysis;

  const SpeechRecording({
    required this.id,
    required this.userId,
    required this.audioUrl,
    this.localPath,
    required this.duration,
    required this.recordedAt,
    this.hasAnalysis = false,
  });

  // ─── Computed helpers ─────────────────────────────────────

  /// Prefer local file when available — avoids network latency
  String get playbackSource => localPath ?? audioUrl;

  bool get isLocal => localPath != null;

  String get formattedDuration => _formatDuration(duration);

  String get formattedDate {
    final d = recordedAt;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  static String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  SpeechRecording copyWith({bool? hasAnalysis}) {
    return SpeechRecording(
      id: id,
      userId: userId,
      audioUrl: audioUrl,
      localPath: localPath,
      duration: duration,
      recordedAt: recordedAt,
      hasAnalysis: hasAnalysis ?? this.hasAnalysis,
    );
  }

  @override
  List<Object?> get props => [id, userId, audioUrl];

  @override
  String toString() => 'SpeechRecording(id: $id, duration: $duration)';
}
