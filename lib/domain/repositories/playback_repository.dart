// =============================================================
//  domain/repositories/playback_repository.dart
//
//  OOP  : Abstraction — pure contract, no implementation
//  SOLID: DIP — ViewModel depends on this, never on just_audio
// =============================================================

import '../entities/speech_recording.dart';

abstract class PlaybackRepository {
  /// Load a recording ready for playback
  Future<void> load(SpeechRecording recording);

  /// Play from current position
  Future<void> play();

  /// Pause playback
  Future<void> pause();

  /// Seek to a specific position
  Future<void> seekTo(Duration position);

  /// Jump forward by [seconds]
  Future<void> skipForward(int seconds);

  /// Jump backward by [seconds]
  Future<void> skipBackward(int seconds);

  /// Set playback speed (0.5 – 2.0)
  Future<void> setSpeed(double speed);

  /// Clean up resources
  Future<void> dispose();

  /// Live position stream
  Stream<Duration> get positionStream;

  /// Total duration stream
  Stream<Duration> get durationStream;

  /// Playback state stream
  Stream<PlaybackStatus> get statusStream;
}

class PlaybackException implements Exception {
  final String message;
  const PlaybackException(this.message);

  @override
  String toString() => 'PlaybackException: $message';
}
