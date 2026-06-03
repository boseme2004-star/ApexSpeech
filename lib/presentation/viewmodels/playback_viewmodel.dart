// =============================================================
//  presentation/viewmodels/playback_viewmodel.dart
//
//  OOP  : Encapsulation — UI never touches use cases directly
//  SOLID: SRP — only manages playback UI state
//
//  State machine:
//  idle → loading → idle (ready)
//               ↘ playing → paused → playing
//                         ↘ completed
//                         ↘ error
// =============================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/speech_recording.dart';
import '../../domain/usecases/playback_usecases.dart';

class PlaybackViewModel extends ChangeNotifier {
  // ─── Use cases ────────────────────────────────────────────
  final LoadRecordingUseCase _loadRecording;
  final PlayUseCase _play;
  final PauseUseCase _pause;
  final SeekUseCase _seek;
  final SkipForwardUseCase _skipForward;
  final SkipBackwardUseCase _skipBackward;
  final SetSpeedUseCase _setSpeed;

  PlaybackViewModel({
    required LoadRecordingUseCase loadRecording,
    required PlayUseCase play,
    required PauseUseCase pause,
    required SeekUseCase seek,
    required SkipForwardUseCase skipForward,
    required SkipBackwardUseCase skipBackward,
    required SetSpeedUseCase setSpeed,
  })  : _loadRecording = loadRecording,
        _play = play,
        _pause = pause,
        _seek = seek,
        _skipForward = skipForward,
        _skipBackward = skipBackward,
        _setSpeed = setSpeed;

  // ─── Private state ────────────────────────────────────────
  PlaybackStatus _status = PlaybackStatus.idle;
  SpeechRecording? _recording;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _speed = 1.0;
  String? _error;

  final List<StreamSubscription> _subs = [];

  // ─── Getters ──────────────────────────────────────────────
  PlaybackStatus get status => _status;
  SpeechRecording? get recording => _recording;
  Duration get position => _position;
  Duration get duration => _duration;
  double get speed => _speed;
  String? get error => _error;

  bool get isLoading => _status == PlaybackStatus.loading;
  bool get isPlaying => _status == PlaybackStatus.playing;
  bool get isPaused => _status == PlaybackStatus.paused;
  bool get isCompleted => _status == PlaybackStatus.completed;
  bool get isIdle => _status == PlaybackStatus.idle;
  bool get hasError => _status == PlaybackStatus.error;

  /// Progress 0.0 – 1.0 for the slider
  double get progress {
    if (_duration.inMilliseconds == 0) return 0;
    return (_position.inMilliseconds / _duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  String get formattedPosition => _fmt(_position);
  String get formattedDuration => _fmt(_duration);

  // ─── Actions ──────────────────────────────────────────────

  Future<void> loadRecording(
    SpeechRecording recording, {
    required Stream<Duration> positionStream,
    required Stream<Duration> durationStream,
    required Stream<PlaybackStatus> statusStream,
  }) async {
    _recording = recording;
    _cancelSubs();

    // Subscribe to streams from the repository
    _subs.add(positionStream.listen((p) {
      _position = p;
      notifyListeners();
    }));
    _subs.add(durationStream.listen((d) {
      _duration = d;
      notifyListeners();
    }));
    _subs.add(statusStream.listen((s) {
      _status = s;
      notifyListeners();
    }));

    try {
      await _loadRecording(recording);
    } catch (e) {
      _status = PlaybackStatus.error;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (isCompleted) {
      await _seek(Duration.zero);
      await _play();
    } else if (isPlaying) {
      await _pause();
    } else {
      await _play();
    }
  }

  Future<void> seekTo(double sliderValue) async {
    final target = Duration(
      milliseconds: (sliderValue * _duration.inMilliseconds).round(),
    );
    await _seek(target);
  }

  Future<void> skipForward() => _skipForward();
  Future<void> skipBackward() => _skipBackward();

  Future<void> changeSpeed(double speed) async {
    _speed = speed;
    await _setSpeed(speed);
    notifyListeners();
  }

  // ─── Helpers ──────────────────────────────────────────────

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _cancelSubs() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
  }

  @override
  void dispose() {
    _cancelSubs();
    super.dispose();
  }
}
