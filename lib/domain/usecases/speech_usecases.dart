import 'dart:io';
import 'package:apex_speech/domain/entities/speech.dart';
import 'package:apex_speech/domain/repositories/speech_repository.dart';

/// Use Case: Upload Speech Recording
class UploadSpeechUseCase {
  final SpeechRepository _speechRepository;

  UploadSpeechUseCase(this._speechRepository);

  Future<Speech> call({
    required File audioFile,
    required String userId,
    required Duration duration,
  }) async {
    // Business rule: reject empty recordings
    if (duration.inSeconds < 3) {
      throw const SpeechException('Recording must be at least 3 seconds long.');
    }
    return await _speechRepository.uploadSpeech(
      audioFile: audioFile,
      userId: userId,
      duration: duration,
    );
  }
}

/// Use Case: Get Speech History
class GetSpeechHistoryUseCase {
  final SpeechRepository _speechRepository;

  GetSpeechHistoryUseCase(this._speechRepository);

  Future<List<Speech>> call(String userId) async {
    return await _speechRepository.getSpeeches(userId);
  }
}

/// Use Case: Delete Speech
class DeleteSpeechUseCase {
  final SpeechRepository _speechRepository;

  DeleteSpeechUseCase(this._speechRepository);

  Future<void> call(String speechId) async {
    await _speechRepository.deleteSpeech(speechId);
  }
}

/// Use Case: Request AI Analysis
class RequestAnalysisUseCase {
  final SpeechRepository _speechRepository;

  RequestAnalysisUseCase(this._speechRepository);

  Future<void> call(String speechId) async {
    await _speechRepository.requestAnalysis(speechId);
  }
}

/// Use Case: Watch speech for real-time updates
class WatchSpeechUseCase {
  final SpeechRepository _speechRepository;

  WatchSpeechUseCase(this._speechRepository);

  Stream<Speech?> call(String speechId) {
    return _speechRepository.watchSpeech(speechId);
  }
}
