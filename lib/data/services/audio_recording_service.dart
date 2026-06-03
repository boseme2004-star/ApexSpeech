import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:apex_speech/core/constants/app_constants.dart';
import 'package:uuid/uuid.dart';

/// Encapsulates all audio recording logic
/// Follows Single Responsibility Principle — only handles recording
class AudioRecordingService {
  final AudioRecorder _recorder;
  final Uuid _uuid;

  String? _currentFilePath;
  bool _isRecording = false;

  // Singleton pattern
  static final AudioRecordingService _instance = AudioRecordingService._internal();
  factory AudioRecordingService() => _instance;

  AudioRecordingService._internal()
      : _recorder = AudioRecorder(),
        _uuid = const Uuid();

  bool get isRecording => _isRecording;
  String? get currentFilePath => _currentFilePath;

  // ─── Permission Check ─────────────────────────────────────────
  Future<bool> requestPermissions() async {
    final micStatus = await Permission.microphone.request();
    return micStatus.isGranted;
  }

  // ─── Start Recording ──────────────────────────────────────────
  Future<String> startRecording() async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception(AppConstants.audioPermissionError);
    }

    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${_uuid.v4()}${AppConstants.audioExtension}';
    _currentFilePath = '${dir.path}/$fileName';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: _currentFilePath!,
    );

    _isRecording = true;
    return _currentFilePath!;
  }

  // ─── Stop Recording ───────────────────────────────────────────
  Future<File?> stopRecording() async {
    if (!_isRecording) return null;

    final path = await _recorder.stop();
    _isRecording = false;

    if (path == null) return null;
    return File(path);
  }

  // ─── Pause / Resume ───────────────────────────────────────────
  Future<void> pauseRecording() async {
    if (_isRecording) await _recorder.pause();
  }

  Future<void> resumeRecording() async {
    await _recorder.resume();
  }

  // ─── Amplitude Stream (for visualizer) ───────────────────────
  Stream<Amplitude> get amplitudeStream {
    return _recorder.onAmplitudeChanged(
      const Duration(milliseconds: 100),
    );
  }

  // ─── Cleanup ──────────────────────────────────────────────────
  Future<void> dispose() async {
    await _recorder.dispose();
  }

  /// Delete a local audio file
  Future<void> deleteLocalFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
