import 'package:apex_speech/domain/entities/app_user.dart';
import 'package:apex_speech/domain/repositories/auth_repository.dart';

/// Use Case: Sign In
/// Single responsibility — orchestrates sign-in business logic
class SignInUseCase {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  Future<AppUser> call({required String email, required String password}) async {
    // Business rule: trim whitespace before auth
    final cleanEmail = email.trim().toLowerCase();
    return await _authRepository.signIn(
      email: cleanEmail,
      password: password,
    );
  }
}

/// Use Case: Sign Up
class SignUpUseCase {
  final AuthRepository _authRepository;

  SignUpUseCase(this._authRepository);

  Future<AppUser> call({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();
    return await _authRepository.signUp(
      name: cleanName,
      email: cleanEmail,
      password: password,
    );
  }
}

/// Use Case: Sign Out
class SignOutUseCase {
  final AuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  Future<void> call() async {
    await _authRepository.signOut();
  }
}

/// Use Case: Get Current User
class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  Future<AppUser?> call() async {
    return await _authRepository.getCurrentUser();
  }
}
