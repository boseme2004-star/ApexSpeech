/// Core application constants — single source of truth
class AppConstants {
  AppConstants._(); // Prevent instantiation (Singleton concept)

  // App Identity
  static const String appName = 'Apex Speech';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String speechesCollection = 'speeches';
  static const String feedbackCollection = 'feedback';

  // Firebase Storage Paths
  static const String audioStoragePath = 'audio/';

  // Routes
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String homeRoute = '/home';
  static const String feedbackRoute = '/feedback';
  static const String playbackRoute = '/playback';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;

  // Audio
  static const int maxRecordingSeconds = 300; // 5 minutes
  static const String audioExtension = '.m4a';

  // UI
  static const double borderRadius = 16.0;
  static const double cardBorderRadius = 20.0;
  static const double buttonBorderRadius = 12.0;
  static const double pagePadding = 24.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'No internet connection. Please check your network.';
  static const String audioPermissionError = 'Microphone permission is required to record speech.';
}
