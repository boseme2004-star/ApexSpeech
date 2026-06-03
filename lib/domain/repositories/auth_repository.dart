import 'package:apex_speech/domain/entities/app_user.dart';

/// Abstract contract for authentication operations
/// Implementations live in the data layer (DIP — Dependency Inversion Principle)
abstract class AuthRepository {
  /// Returns the currently authenticated user, or null if not authenticated
  Future<AppUser?> getCurrentUser();

  /// Sign in with email and password
  /// Throws [AuthException] on failure
  Future<AppUser> signIn({required String email, required String password});

  /// Create a new user account
  /// Throws [AuthException] on failure  
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  });

  /// Sign out the current user
  Future<void> signOut();

  /// Stream of auth state changes — emits null on sign-out
  Stream<AppUser?> get authStateChanges;

  /// Delete the current user account
  Future<void> deleteAccount();
}

/// Typed authentication exceptions for clean error handling
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException: $message (code: $code)';
}
