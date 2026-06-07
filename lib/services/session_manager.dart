import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static int? userId;
  static String? username;
  static String? email;

  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';
  static const String _keyEmail = 'email';

  // Save session to memory and device storage
  static Future<void> setUser(Map<String, dynamic> user) async {
    userId = user['userId'];
    username = user['username'];
    email = user['email'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId!);
    await prefs.setString(_keyUsername, username ?? '');
    await prefs.setString(_keyEmail, email ?? '');
    print('SESSION SAVED: userId=$userId');
  }

  // Load session from device storage on app start
  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt(_keyUserId);
    username = prefs.getString(_keyUsername);
    email = prefs.getString(_keyEmail);
    print('SESSION LOADED: userId=$userId');
  }

  // Clear session on logout
  static Future<void> clear() async {
    userId = null;
    username = null;
    email = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyEmail);
    print('SESSION CLEARED');
  }

  static bool get isLoggedIn => userId != null;
}