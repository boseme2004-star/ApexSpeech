import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {

  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Signup"),
      ),

      body: Padding(
        padding: EdgeInsets.all(16),

        child: Column(
          children: [

            // Username field
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: "Username",
              ),
            ),

            SizedBox(height: 15),

            // Email field
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
              ),
            ),

            SizedBox(height: 15),

            // Password field
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
              ),
            ),

            SizedBox(height: 25),

            // Signup button
            ElevatedButton(

              onPressed: () {

                // For now just go back to login
                Navigator.pushNamed(context, '/login');

              },

              child: Text("Create Account"),
            ),

          ],
        ),
      ),
    );
  }
}