import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SingleChildScrollView(

        child: Padding(
          padding: EdgeInsets.all(25),

          child: Form(

            key: _formKey,

            child: Column(
              children: [

                SizedBox(height: 100),

                Icon(
                  Icons.mic,
                  size: 100,
                  color: Colors.deepPurple,
                ),

                SizedBox(height: 20),

                Text(
                  "Welcome Back",

                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  "Login to continue",

                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                SizedBox(height: 40),

                // EMAIL
                TextFormField(
                  controller: emailController,

                  validator: (value) {

                    if (value == null || value.isEmpty) {
                      return "Enter your email";
                    }

                    return null;
                  },

                  decoration: InputDecoration(
                    labelText: "Email",

                    prefixIcon: Icon(Icons.email),

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // PASSWORD
                TextFormField(
                  controller: passwordController,
                  obscureText: true,

                  validator: (value) {

                    if (value == null || value.isEmpty) {
                      return "Enter your password";
                    }

                    return null;
                  },

                  decoration: InputDecoration(
                    labelText: "Password",

                    prefixIcon: Icon(Icons.lock),

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                ),

                SizedBox(height: 30),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 18,
                      ),

                      backgroundColor:
                          Colors.deepPurple,

                      shape: RoundedRectangleBorder(
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

                    child: Text(
                      "Login",

                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                TextButton(

                  onPressed: () {

                    Navigator.pushNamed(
                      context,
                      '/signup',
                    );

                  },

                  child: Text(
                    "Don't have an account? Sign up",
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}