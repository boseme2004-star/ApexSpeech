// =============================================================
//  presentation/viewmodels/feedback_viewmodel.dart
//
//  OOP  : Encapsulation — UI never touches use cases directly
//  SOLID: SRP — only manages feedback UI state
//         DIP — depends on use case abstractions, not repos
//
//  State machine pattern:
//  idle → loading → loaded
//                 ↘ error
//                 ↘ analyzing (still waiting for AI)
// =============================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/speech_feedback.dart';
import '../../domain/usecases/feedback_usecases.dart';

// ─── State enum ───────────────────────────────────────────────

enum FeedbackStatus {
  idle,
  loading,
  analyzing, // uploaded but AI not done yet
  loaded,
  error,
}

// ─── ViewModel ────────────────────────────────────────────────

class FeedbackViewModel extends ChangeNotifier {
  final GetFeedbackUseCase     _getFeedback;
  final WatchFeedbackUseCase   _watchFeedback;
  final RequestAnalysisUseCase _requestAnalysis;

  FeedbackViewModel({
    required GetFeedbackUseCase     getFeedback,
    required WatchFeedbackUseCase   watchFeedback,
    required RequestAnalysisUseCase requestAnalysis,
  })  : _getFeedback     = getFeedback,
        _watchFeedback   = watchFeedback,
        _requestAnalysis = requestAnalysis;

  // ─── Private state ──────────────────────────────────────

  FeedbackStatus   _status   = FeedbackStatus.idle;
  SpeechFeedback?  _feedback;
  String?          _error;
  int              _selectedTab = 0; // 0=overview 1=details 2=tips
  StreamSubscription<SpeechFeedback?>? _subscription;

  // ─── Public getters ──────────────────────────────────────

  FeedbackStatus  get status      => _status;
  SpeechFeedback? get feedback    => _feedback;
  String?         get error       => _error;
  int             get selectedTab => _selectedTab;

  bool get isLoading   => _status == FeedbackStatus.loading;
  bool get isAnalyzing => _status == FeedbackStatus.analyzing;
  bool get hasData     => _status == FeedbackStatus.loaded && _feedback != null;
  bool get hasError    => _status == FeedbackStatus.error;

  // ─── Load & watch ────────────────────────────────────────

  Future<void> loadFeedback(String speechId) async {
    _setStatus(FeedbackStatus.loading);
    _clearError();

    try {
      // Try fetching existing feedback first
      _feedback = await _getFeedback(speechId);
      _setStatus(FeedbackStatus.loaded);
    } catch (_) {
      // Not yet analyzed — request analysis and watch stream
      _setStatus(FeedbackStatus.analyzing);
      await _requestAnalysis(speechId);
      _watchStream(speechId);
    }
  }

  void _watchStream(String speechId) {
    _subscription?.cancel();
    _subscription = _watchFeedback(speechId).listen(
      (feedback) {
        if (feedback != null) {
          _feedback = feedback;
          _setStatus(FeedbackStatus.loaded);
        }
      },
      onError: (e) {
        _setError(e.toString());
        _setStatus(FeedbackStatus.error);
      },
    );
  }

  // ─── Tab navigation ──────────────────────────────────────

  void selectTab(int index) {
    if (_selectedTab == index) return;
    _selectedTab = index;
    notifyListeners();
  }

  // ─── Retry ───────────────────────────────────────────────

  Future<void> retry(String speechId) async {
    _feedback = null;
    await loadFeedback(speechId);
  }

  // ─── Private helpers ─────────────────────────────────────

  void _setStatus(FeedbackStatus s) {
    _status = s;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
