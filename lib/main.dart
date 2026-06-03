import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:apex_speech/core/constants/app_constants.dart';
import 'package:apex_speech/core/di/injection_container.dart';
import 'package:apex_speech/core/router/app_router.dart';
import 'package:apex_speech/core/themes/app_theme.dart';
import 'package:apex_speech/presentation/viewmodels/auth_viewmodel.dart';
import 'package:apex_speech/presentation/viewmodels/home_viewmodel.dart';
import 'package:apex_speech/presentation/viewmodels/feedback_viewmodel.dart';
import 'package:apex_speech/presentation/viewmodels/playback_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar styling
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Initialize Firebase
  await Firebase.initializeApp();

  // Setup dependency injection
  setupDependencies();

  runApp(const ApexSpeechApp());
}

class ApexSpeechApp extends StatelessWidget {
  const ApexSpeechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ViewModels are injected via sl (service locator)
        // Each is a ChangeNotifier for Provider reactivity
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => sl<AuthViewModel>(),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (_) => sl<HomeViewModel>(),
        ),
        ChangeNotifierProvider<FeedbackViewModel>(
          create: (_) => sl<FeedbackViewModel>(),
        ),
        ChangeNotifierProvider<PlaybackViewModel>(
          create: (_) => sl<PlaybackViewModel>(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppConstants.loginRoute,
        // Auth gate: redirect to home if already logged in
        builder: (context, child) {
          return _AuthGate(child: child!);
        },
      ),
    );
  }
}

/// Listens to auth state and redirects automatically
class _AuthGate extends StatefulWidget {
  final Widget child;

  const _AuthGate({required this.child});

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthState();
    });
  }

  void _checkAuthState() {
    final authVM = context.read<AuthViewModel>();
    if (authVM.isAuthenticated) {
      Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
