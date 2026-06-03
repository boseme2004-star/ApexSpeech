import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:apex_speech/data/services/audio_recording_service.dart';
import 'package:apex_speech/domain/entities/speech.dart';
import 'package:apex_speech/domain/usecases/speech_usecases.dart';

enum RecordingState { idle, recording, processing, done, error }

class HomeViewModel extends ChangeNotifier {
  final UploadSpeechUseCase _uploadSpeechUseCase;
  final GetSpeechHistoryUseCase _getSpeechHistoryUseCase;
  final DeleteSpeechUseCase _deleteSpeechUseCase;
  final RequestAnalysisUseCase _requestAnalysisUseCase;
  final AudioRecordingService _audioRecordingService;

  HomeViewModel({
    required UploadSpeechUseCase uploadSpeechUseCase,
    required GetSpeechHistoryUseCase getSpeechHistoryUseCase,
    required DeleteSpeechUseCase deleteSpeechUseCase,
    required RequestAnalysisUseCase requestAnalysisUseCase,
    required AudioRecordingService audioRecordingService,
  })  : _uploadSpeechUseCase = uploadSpeechUseCase,
        _getSpeechHistoryUseCase = getSpeechHistoryUseCase,
        _deleteSpeechUseCase = deleteSpeechUseCase,
        _requestAnalysisUseCase = requestAnalysisUseCase,
        _audioRecordingService = audioRecordingService;

  // ─── State ────────────────────────────────────────────────────
  RecordingState _recordingState = RecordingState.idle;
  List<Speech> _speeches = [];
  Speech? _lastUploadedSpeech;
  String? _errorMessage;
  Duration _recordingDuration = Duration.zero;
  double _amplitude = 0.0;

  Timer? _durationTimer;

  // ─── Getters ──────────────────────────────────────────────────
  RecordingState get recordingState => _recordingState;
  List<Speech> get speeches => List.unmodifiable(_speeches);
  Speech? get lastUploadedSpeech => _lastUploadedSpeech;
  String? get errorMessage => _errorMessage;
  Duration get recordingDuration => _recordingDuration;
  double get amplitude => _amplitude;
  bool get isRecording => _recordingState == RecordingState.recording;
  bool get isProcessing => _recordingState == RecordingState.processing;

  // ─── Load History ─────────────────────────────────────────────
  Future<void> loadSpeeches(String userId) async {
    try {
      _speeches = await _getSpeechHistoryUseCase(userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ─── Start Recording ──────────────────────────────────────────
  Future<void> startRecording() async {
    try {
      await _audioRecordingService.startRecording();
      _recordingState = RecordingState.recording;
      _recordingDuration = Duration.zero;
      _startDurationTimer();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ─── Stop Recording & Upload ──────────────────────────────────
  Future<Speech?> stopAndUpload(String userId) async {
    _stopDurationTimer();
    final duration = _recordingDuration;

    final file = await _audioRecordingService.stopRecording();
    if (file == null) {
      _setError('Recording failed — no audio captured.');
      return null;
    }

    _recordingState = RecordingState.processing;
    notifyListeners();

    try {
      final speech = await _uploadSpeechUseCase(
        audioFile: file,
        userId: userId,
        duration: duration,
      );

      // Trigger AI analysis
      await _requestAnalysisUseCase(speech.id);

      _lastUploadedSpeech = speech;
      _speeches.insert(0, speech);
      _recordingState = RecordingState.done;
      notifyListeners();
      return speech;
    } catch (e) {
      _setError(e.toString());
      _recordingState = RecordingState.error;
      notifyListeners();
      return null;
    }
  }

  // ─── Delete Speech ────────────────────────────────────────────
  Future<void> deleteSpeech(String speechId) async {
    try {
      await _deleteSpeechUseCase(speechId);
      _speeches.removeWhere((s) => s.id == speechId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ─── Timer Helpers ────────────────────────────────────────────
  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _recordingDuration += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  void resetState() {
    _recordingState = RecordingState.idle;
    _recordingDuration = Duration.zero;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _recordingState = RecordingState.error;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopDurationTimer();
    super.dispose();
  }
}
