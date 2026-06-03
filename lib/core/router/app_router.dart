import 'package:flutter/material.dart';
import 'package:apex_speech/core/constants/app_constants.dart';
import 'package:apex_speech/presentation/screens/login_screen.dart';
import 'package:apex_speech/presentation/screens/signup_screen.dart';
import 'package:apex_speech/presentation/screens/home_screen.dart';
import 'package:apex_speech/presentation/screens/feedback_screen.dart';
import 'package:apex_speech/presentation/screens/playback_screen.dart';

/// Centralized route management
/// All navigation lives here — screens know nothing about routing
class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.loginRoute:
        return _fadeRoute(const LoginScreen(), settings);

      case AppConstants.signupRoute:
        return _fadeRoute(const SignupScreen(), settings);

      case AppConstants.homeRoute:
        return _fadeRoute(const HomeScreen(), settings);

      case AppConstants.feedbackRoute:
        final speechId = settings.arguments as String;
        return _slideRoute(FeedbackScreen(speechId: speechId), settings);

      case AppConstants.playbackRoute:
        final speechId = settings.arguments as String;
        return _slideRoute(PlaybackScreen(speechId: speechId), settings);

      default:
        return _fadeRoute(
          Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: AppConstants.mediumAnimation,
    );
  }

  static PageRouteBuilder _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: AppConstants.mediumAnimation,
    );
  }
}
