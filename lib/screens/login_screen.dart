import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(

        child: SingleChildScrollView(

          child: Padding(
            padding: const EdgeInsets.all(25),

            child: Form(

              key: _formKey,

              child: Column(
                children: [

                  const SizedBox(height: 60),

                  // APP ICON
                  Icon(
                    Icons.mic,
                    size: 100,
                    color: Colors.deepPurple,
                  ),

                  const SizedBox(height: 20),

                  // TITLE
                  const Text(
                    "Welcome Back",

                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Login to continue",

                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // EMAIL FIELD
                  TextFormField(
                    controller: emailController,

                    keyboardType:
                        TextInputType.emailAddress,

                    validator: (value) {

                      if (value == null ||
                          value.isEmpty) {

                        return "Enter your email";
                      }

                      return null;
                    },

                    decoration: InputDecoration(

                      labelText: "Email",

                      prefixIcon:
                          const Icon(Icons.email),

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PASSWORD FIELD
                  TextFormField(

                    controller: passwordController,

                    obscureText: obscurePassword,

                    validator: (value) {

                      if (value == null ||
                          value.isEmpty) {

                        return "Enter your password";
                      }

                      return null;
                    },

                    decoration: InputDecoration(

                      labelText: "Password",

                      prefixIcon:
                          const Icon(Icons.lock),

                      suffixIcon: IconButton(

                        icon: Icon(

                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),

                        onPressed: () {

                          setState(() {

                            obscurePassword =
                                !obscurePassword;
                          });
                        },
                      ),

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // LOGIN BUTTON
                  SizedBox(

                    width: double.infinity,

                    child: ElevatedButton(

                      style:
                          ElevatedButton.styleFrom(

                        backgroundColor:
                            Colors.deepPurple,

                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 18,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),

                      onPressed: () {

                        if (_formKey.currentState!
                            .validate()) {

                          Navigator.pushReplacementNamed(
                            context,
                            '/home',
                          );
                        }
                      },

                      child: const Text(

                        "Login",

                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // SIGNUP BUTTON
                  TextButton(

                    onPressed: () {

                      Navigator.pushReplacementNamed(
                        context,
                        '/signup',
                      );
                    },

                    child: const Text(
                      "Don't have an account? Sign up",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}