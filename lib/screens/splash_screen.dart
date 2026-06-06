import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 20),
      () {

        if (mounted) {

          Navigator.pushReplacementNamed(
            context,
            '/login',
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color.fromARGB(255, 158, 138, 192),

      body: Center(

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            // APP ICON
            const Icon(
              Icons.record_voice_over,
              size: 100,
              color: Color.fromARGB(255, 196, 128, 179),
            ),

            const SizedBox(height: 20),

            // APP NAME
            const Text(
              "Welcome to Apex Speech",

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // SUBTITLE
            const Text(
              "Improve your speaking confidence",

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 40),

            // LOADING INDICATOR
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}