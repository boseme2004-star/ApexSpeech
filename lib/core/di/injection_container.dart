import 'package:get_it/get_it.dart';
import 'package:apex_speech/data/repositories/firebase_auth_repository.dart';
import 'package:apex_speech/data/repositories/firebase_speech_repository.dart';
import 'package:apex_speech/data/services/audio_recording_service.dart';
import 'package:apex_speech/domain/repositories/auth_repository.dart';
import 'package:apex_speech/domain/repositories/speech_repository.dart';
import 'package:apex_speech/domain/usecases/auth_usecases.dart';
import 'package:apex_speech/domain/usecases/speech_usecases.dart';
import 'package:apex_speech/presentation/viewmodels/auth_viewmodel.dart';
import 'package:apex_speech/presentation/viewmodels/home_viewmodel.dart';
import 'package:apex_speech/presentation/viewmodels/feedback_viewmodel.dart';
import 'package:apex_speech/presentation/viewmodels/playback_viewmodel.dart';

final GetIt sl = GetIt.instance;

/// Registers all dependencies — called once at app startup
/// Follows Dependency Inversion Principle throughout
void setupDependencies() {
  // ─── Services (Singletons) ────────────────────────────────────
  sl.registerLazySingleton<AudioRecordingService>(
    () => AudioRecordingService(),
  );

  // ─── Repositories ─────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => FirebaseAuthRepository(),
  );

  sl.registerLazySingleton<SpeechRepository>(
    () => FirebaseSpeechRepository(),
  );

  // ─── Auth Use Cases ───────────────────────────────────────────
  sl.registerFactory(() => SignInUseCase(sl<AuthRepository>()));
  sl.registerFactory(() => SignUpUseCase(sl<AuthRepository>()));
  sl.registerFactory(() => SignOutUseCase(sl<AuthRepository>()));
  sl.registerFactory(() => GetCurrentUserUseCase(sl<AuthRepository>()));

  // ─── Speech Use Cases ─────────────────────────────────────────
  sl.registerFactory(() => UploadSpeechUseCase(sl<SpeechRepository>()));
  sl.registerFactory(() => GetSpeechHistoryUseCase(sl<SpeechRepository>()));
  sl.registerFactory(() => DeleteSpeechUseCase(sl<SpeechRepository>()));
  sl.registerFactory(() => RequestAnalysisUseCase(sl<SpeechRepository>()));
  sl.registerFactory(() => WatchSpeechUseCase(sl<SpeechRepository>()));

  // ─── ViewModels ───────────────────────────────────────────────
  sl.registerFactory(
    () => AuthViewModel(
      signInUseCase: sl<SignInUseCase>(),
      signUpUseCase: sl<SignUpUseCase>(),
      signOutUseCase: sl<SignOutUseCase>(),
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
    ),
  );

  sl.registerFactory(
    () => HomeViewModel(
      uploadSpeechUseCase: sl<UploadSpeechUseCase>(),
      getSpeechHistoryUseCase: sl<GetSpeechHistoryUseCase>(),
      deleteSpeechUseCase: sl<DeleteSpeechUseCase>(),
      requestAnalysisUseCase: sl<RequestAnalysisUseCase>(),
      audioRecordingService: sl<AudioRecordingService>(),
    ),
  );

  sl.registerFactory(
    () => FeedbackViewModel(
      watchSpeechUseCase: sl<WatchSpeechUseCase>(),
    ),
  );

  sl.registerFactory(
    () => PlaybackViewModel(
      audioRecordingService: sl<AudioRecordingService>(),
    ),
  );
}
