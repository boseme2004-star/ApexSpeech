import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {

  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() =>
      _SignupScreenState();
}

class _SignupScreenState
    extends State<SignupScreen> {

  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SingleChildScrollView(

        child: Padding(

          padding: const EdgeInsets.all(25),

          child: Form(

            key: _formKey,

            child: Column(

              children: [

                const SizedBox(height: 70),

                // APP ICON
                const Icon(
                  Icons.person_add,
                  size: 100,
                  color: Color.fromARGB(255, 136, 127, 151),
                ),

                const SizedBox(height: 20),

                // TITLE
                const Text(

                  "Create Account",

                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(

                  "Sign up to continue",

                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                // USERNAME FIELD
                TextFormField(

                  controller: usernameController,

                  validator: (value) {

                    if (value == null ||
                        value.isEmpty) {

                      return "Enter username";
                    }

                    if (value.length < 6) {
                      return 'Username must be at least 6 characters';
                    }
                  

                    // ONLY LETTERS & NUMBERS
                    if (!RegExp(r'^[a-zA-Z0-9]+$')
                        .hasMatch(value)) {

                      return
                          "Only letters and numbers allowed";

                    
                    }

                    return null;
                  },

                  decoration: InputDecoration(

                    labelText: "Username",

                    prefixIcon:
                        const Icon(Icons.person),

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // EMAIL FIELD
                TextFormField(

                  controller: emailController,

                  validator: (value) {

                    if (value == null ||
                        value.isEmpty) {

                      return "Enter email";
                    }

                    // EMAIL VALIDATION
                    if (!RegExp(
                      r'^[^@]+@[^@]+\.[^@]+',
                    ).hasMatch(value)) {

                      return "Enter valid email";
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

                      return "Enter password";
                    }

                    if (value.length < 6) {

                      return
                          "Password must be at least 6 characters";
                    }

                    // ONLY LETTERS & NUMBERS
                    if (!RegExp(r'^[a-zA-Z0-9]+$')
                        .hasMatch(value)) {

                      return
                          "Password can only contain letters and numbers";
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

                // SIGNUP BUTTON
                SizedBox(

                  width: double.infinity,

                  child: ElevatedButton(

                    style:
                        ElevatedButton.styleFrom(

                      backgroundColor:
                          const Color.fromARGB(255, 221, 150, 206),

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

                      Navigator.pushReplacementNamed(
                      context,
                      '/home',
                    );

                      if (_formKey.currentState!
                          .validate()) {

                        ScaffoldMessenger.of(context)
                            .showSnackBar(

                          const SnackBar(

                            content: Text(
                              "Account Created Successfully",
                            ),
                          ),
                        );
                      }
                    },

                    child: const Text(

                      "Create Account",

                      style: TextStyle(
                        fontSize: 18,
                        color: Color.fromARGB(255, 22, 22, 22),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // LOGIN BUTTON
                TextButton(

                  onPressed: () {

                    Navigator.pushReplacementNamed(
                      context,
                      '/login',
                    );
                  },

                  child: const Text(
                    "Already have an account? Login",
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