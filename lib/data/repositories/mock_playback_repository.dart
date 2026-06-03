// =============================================================
//  data/repositories/mock_playback_repository.dart
//
//  OOP  : Polymorphism — implements PlaybackRepository
//  SOLID: OCP — swap for JustAudioPlaybackRepository in prod
//         without changing a single line elsewhere
// =============================================================

import 'dart:async';
import '../../domain/entities/speech_recording.dart';
import '../../domain/repositories/playback_repository.dart';

class MockPlaybackRepository implements PlaybackRepository {
  // State
  Duration _position = Duration.zero;
  Duration _duration = const Duration(minutes: 1, seconds: 32);
  PlaybackStatus _status = PlaybackStatus.idle;
  double _speed = 1.0;
  Timer? _ticker;

  // Stream controllers
  final _positionCtrl = StreamController<Duration>.broadcast();
  final _durationCtrl = StreamController<Duration>.broadcast();
  final _statusCtrl = StreamController<PlaybackStatus>.broadcast();

  @override
  Stream<Duration> get positionStream => _positionCtrl.stream;
  @override
  Stream<Duration> get durationStream => _durationCtrl.stream;
  @override
  Stream<PlaybackStatus> get statusStream => _statusCtrl.stream;

  @override
  Future<void> load(SpeechRecording recording) async {
    _emit(PlaybackStatus.loading);
    await Future.delayed(const Duration(milliseconds: 800));
    _duration = recording.duration;
    _position = Duration.zero;
    _durationCtrl.add(_duration);
    _positionCtrl.add(_position);
    _emit(PlaybackStatus.idle);
  }

  @override
  Future<void> play() async {
    _emit(PlaybackStatus.playing);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _position += Duration(milliseconds: (500 * _speed).round());
      if (_position >= _duration) {
        _position = _duration;
        _positionCtrl.add(_position);
        _emit(PlaybackStatus.completed);
        _ticker?.cancel();
      } else {
        _positionCtrl.add(_position);
      }
    });
  }

  @override
  Future<void> pause() async {
    _ticker?.cancel();
    _emit(PlaybackStatus.paused);
  }

  @override
  Future<void> seekTo(Duration position) async {
    _position = position.clamp(Duration.zero, _duration);
    _positionCtrl.add(_position);
    // If completed, reset to paused
    if (_status == PlaybackStatus.completed) {
      _emit(PlaybackStatus.paused);
    }
  }

  @override
  Future<void> skipForward(int seconds) =>
      seekTo(_position + Duration(seconds: seconds));

  @override
  Future<void> skipBackward(int seconds) =>
      seekTo(_position - Duration(seconds: seconds));

  @override
  Future<void> setSpeed(double speed) async {
    _speed = speed;
  }

  @override
  Future<void> dispose() async {
    _ticker?.cancel();
    await _positionCtrl.close();
    await _durationCtrl.close();
    await _statusCtrl.close();
  }

  void _emit(PlaybackStatus s) {
    _status = s;
    _statusCtrl.add(s);
  }
}
