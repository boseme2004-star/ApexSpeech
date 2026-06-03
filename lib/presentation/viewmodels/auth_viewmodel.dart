import 'package:flutter/foundation.dart';
import 'package:apex_speech/domain/entities/app_user.dart';
import 'package:apex_speech/domain/repositories/auth_repository.dart';
import 'package:apex_speech/domain/usecases/auth_usecases.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

/// Manages all authentication state — no Flutter UI imports
/// Implements ChangeNotifier for Provider-based reactivity
class AuthViewModel extends ChangeNotifier {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthViewModel({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase {
    _checkCurrentUser();
  }

  // ─── State ────────────────────────────────────────────────────
  AuthState _state = AuthState.initial;
  AppUser? _currentUser;
  String? _errorMessage;

  // ─── Getters ──────────────────────────────────────────────────
  AuthState get state => _state;
  AppUser? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _state == AuthState.authenticated;

  // ─── Check Existing Session ───────────────────────────────────
  Future<void> _checkCurrentUser() async {
    _setState(AuthState.loading);
    final user = await _getCurrentUserUseCase();
    if (user != null) {
      _currentUser = user;
      _setState(AuthState.authenticated);
    } else {
      _setState(AuthState.unauthenticated);
    }
  }

  // ─── Sign In ──────────────────────────────────────────────────
  Future<bool> signIn({required String email, required String password}) async {
    _setState(AuthState.loading);
    _clearError();

    try {
      _currentUser = await _signInUseCase(email: email, password: password);
      _setState(AuthState.authenticated);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setState(AuthState.error);
      return false;
    } catch (_) {
      _setError('Unexpected error. Please try again.');
      _setState(AuthState.error);
      return false;
    }
  }

  // ─── Sign Up ──────────────────────────────────────────────────
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);
    _clearError();

    try {
      _currentUser = await _signUpUseCase(
        name: name,
        email: email,
        password: password,
      );
      _setState(AuthState.authenticated);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setState(AuthState.error);
      return false;
    } catch (_) {
      _setError('Unexpected error. Please try again.');
      _setState(AuthState.error);
      return false;
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────
  Future<void> signOut() async {
    await _signOutUseCase();
    _currentUser = null;
    _setState(AuthState.unauthenticated);
  }

  // ─── Private Helpers ──────────────────────────────────────────
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
