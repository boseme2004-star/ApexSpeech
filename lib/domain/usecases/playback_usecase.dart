// =============================================================
//  domain/usecases/playback_usecases.dart
//
//  OOP  : Single Responsibility — one class, one action
//  SOLID: SRP + DIP — depend on abstract PlaybackRepository
// =============================================================

import '../entities/speech_recording.dart';
import '../repositories/playback_repository.dart';

class LoadRecordingUseCase {
  final PlaybackRepository _repository;
  const LoadRecordingUseCase(this._repository);

  Future<void> call(SpeechRecording recording) => _repository.load(recording);
}

class PlayUseCase {
  final PlaybackRepository _repository;
  const PlayUseCase(this._repository);

  Future<void> call() => _repository.play();
}

class PauseUseCase {
  final PlaybackRepository _repository;
  const PauseUseCase(this._repository);

  Future<void> call() => _repository.pause();
}

class SeekUseCase {
  final PlaybackRepository _repository;
  const SeekUseCase(this._repository);

  Future<void> call(Duration position) => _repository.seekTo(position);
}

class SkipForwardUseCase {
  final PlaybackRepository _repository;
  const SkipForwardUseCase(this._repository);

  Future<void> call([int seconds = 10]) => _repository.skipForward(seconds);
}

class SkipBackwardUseCase {
  final PlaybackRepository _repository;
  const SkipBackwardUseCase(this._repository);

  Future<void> call([int seconds = 10]) => _repository.skipBackward(seconds);
}

class SetSpeedUseCase {
  final PlaybackRepository _repository;
  const SetSpeedUseCase(this._repository);

  Future<void> call(double speed) {
    // Business rule: clamp to allowed range
    final clamped = speed.clamp(0.5, 2.0);
    return _repository.setSpeed(clamped);
  }
}
