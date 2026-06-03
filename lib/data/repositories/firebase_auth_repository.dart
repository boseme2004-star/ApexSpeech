import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apex_speech/core/constants/app_constants.dart';
import 'package:apex_speech/domain/entities/app_user.dart';
import 'package:apex_speech/domain/repositories/auth_repository.dart';
import 'package:apex_speech/data/models/user_model.dart';

/// Firebase implementation of AuthRepository
/// Encapsulates all Firebase Auth details — UI layers never touch Firebase directly
class FirebaseAuthRepository implements AuthRepository {
  // Singleton-style injected services
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // ─── Auth State Stream ────────────────────────────────────────
  @override
  Stream<AppUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await _fetchUserProfile(user.uid);
    });
  }

  // ─── Get Current User ─────────────────────────────────────────
  @override
  Future<AppUser?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return await _fetchUserProfile(user.uid);
  }

  // ─── Sign In ──────────────────────────────────────────────────
  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      return await _fetchUserProfile(user.uid) ??
          _userFromFirebase(user, 'User');
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code), code: e.code);
    }
  }

  // ─── Sign Up ──────────────────────────────────────────────────
  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user!;

      // Update display name
      await firebaseUser.updateDisplayName(name);

      // Create user profile in Firestore
      final appUser = AppUser(
        id: firebaseUser.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      await _saveUserProfile(appUser);
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code), code: e.code);
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────
  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // ─── Delete Account ───────────────────────────────────────────
  @override
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    // Delete Firestore profile
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .delete();

    // Delete Firebase Auth account
    await user.delete();
  }

  // ─── Private Helpers ──────────────────────────────────────────
  Future<AppUser?> _fetchUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc).toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveUserProfile(AppUser user) async {
    final model = UserModel.fromEntity(user);
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.id)
        .set(model.toFirestore());
  }

  AppUser _userFromFirebase(User user, String fallbackName) {
    return AppUser(
      id: user.uid,
      name: user.displayName ?? fallbackName,
      email: user.email ?? '',
      createdAt: DateTime.now(),
    );
  }

  /// Maps Firebase error codes to user-friendly messages
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return AppConstants.networkError;
      default:
        return AppConstants.genericError;
    }
  }
}
