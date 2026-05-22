import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/playback_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: "Vocal Coach",

      // APP THEME
      theme: ThemeData(

        primarySwatch: Colors.deepPurple,

        scaffoldBackgroundColor: Colors.white,

        elevatedButtonTheme:
            ElevatedButtonThemeData(

          style: ElevatedButton.styleFrom(

            backgroundColor:
                Colors.deepPurple,

            foregroundColor:
                Colors.white,

            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(15),
            ),

            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
          ),
        ),
      ),

      // FIRST SCREEN
      initialRoute: '/',

      // APP ROUTES
      routes: {

        // Splash Screen
        '/': (context) =>
            SplashScreen(),

        // Login Screen
        '/login': (context) =>
            LoginScreen(),

        // Signup Screen
        '/signup': (context) =>
            SignupScreen(),

        // Home Screen
        '/home': (context) =>
            HomeScreen(),

        // Feedback Screen
        '/feedback': (context) =>
            FeedbackScreen(),

        // Playback Screen
        '/playback': (context) =>
            PlaybackScreen(),
      },
    );
  }
}