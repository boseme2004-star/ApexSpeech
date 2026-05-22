import 'dart:async';

import 'package:flutter/material.dart';

import 'signup_screen.dart';

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

      const Duration(seconds: 2),

      () {

        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (context) =>
                const SignupScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.deepPurple,

      body: Center(

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            const Icon(

              Icons.mic,

              size: 100,

              color: Colors.white,
            ),

            const SizedBox(height: 30),

            const Text(

              "Welcome to\nApex Speech",

              textAlign: TextAlign.center,

              style: TextStyle(

                color: Colors.white,

                fontSize: 34,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            const Text(

              "Train your voice with confidence",

              textAlign: TextAlign.center,

              style: TextStyle(

                color: Colors.white70,

                fontSize: 18,
              ),
            ),

            const SizedBox(height: 40),

            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}