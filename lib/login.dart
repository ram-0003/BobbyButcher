import 'package:bobbybutcher/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'CustomBottomNavigationBar.dart';
import 'forgotpassword.dart';

// Create the PasswordField widget
class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final bool isPasswordVisible;
  final ValueChanged<bool> onVisibilityChanged;

  const PasswordField({
    super.key,
    required this.controller,
    required this.validator,
    required this.isPasswordVisible,
    required this.onVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !isPasswordVisible,
      validator: validator,
      decoration: InputDecoration(
        hintText: 'Enter Password',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () => onVisibilityChanged(!isPasswordVisible),
        ),
      ),
    );
  }
}

// Password validation function
String? validatePassword(String value) {
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false; // Toggle password visibility

  // Login using Email and Password
  Future<User?> _loginUsingEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login successful")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No User found for that email")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error signing in. Please try again.")),
        );
      }
      return null;
    }
  }

  // Google Sign-In Function
  Future<User?> _signInWithGoogle() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: <String>['email'],
      clientId: "603719090779-bccfbju1dnfh2c09mrgo92log61fsu7e.apps.googleusercontent.com", // Correct client ID
    );


    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      print('available');
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential = await auth.signInWithCredential(credential);
        user = userCredential.user;

        if(user != null){
          // Store user data if it doesn't exist
          final existuser = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: user.email)
              .get();

          if (existuser.size == 0) {
            try {
              String uid = FirebaseAuth.instance.currentUser!.uid;
              await FirebaseFirestore.instance.collection('user').doc(user.uid).set({
                'firstname': user.displayName,
                'lastname': "",
                'email': user.email,
                'mobile': user.phoneNumber ?? "",
                'imageUrl': user.photoURL ?? "",
                'uid': user.uid,
                'status': 'null',
              });
              print('User data stored ${user.email}');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Google login successful")),
              );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            } catch (error) {
              print('Error! Saving user data $error');
            }
          }
          else{
            print('Un-available');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Google login successful")),
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          }
        }


      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Error signing in with Google")),
        );
      }
    }
    return user;
  }

  // Sign In with Email and Password Button
  Future<void> _signInWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) {
      await _loginUsingEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        context: context,
      );
    }
  }

  // Navigate to Register Page
  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 76),
              const Text(
                'Login to your\naccount.',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Please sign in to your account',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),
              const Text('Email Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10), // Add spacing between text and field
              TextFormField(
                controller: _emailController,
                validator: (value) => value!.contains('@') ? null : 'Enter a valid email',
                decoration: const InputDecoration(
                  hintText: 'Enter Email',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 22),
              const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10), // Add spacing between text and field
              PasswordField(
                controller: _passwordController,
                validator: (value) => validatePassword(value!),
                isPasswordVisible: _isPasswordVisible,
                onVisibilityChanged: (visible) {
                  setState(() {
                    _isPasswordVisible = visible;
                  });
                },
              ),

              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                    );
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFE8C00), // Orange color
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _signInWithEmailAndPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFE8C00), // Orange color
                  foregroundColor: Colors.white, // White text color
                  minimumSize: const Size(double.infinity, 50), // Full-width button with increased height
                ),
                child: const Text('Sign In'),
              ),

              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.black26,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0), // Add horizontal space
                    child: Text(
                      'Or sign in with',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.black26,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signInWithGoogle,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(), // Make the button round
                  padding: const EdgeInsets.all(16), // Adjust padding to make sure the icon fits perfectly
                  backgroundColor: Colors.white, // Set background color
                  foregroundColor: Colors.black, // Set foreground color (icon color)
                ),
                child: Image.asset(
                  'lib/assets/google.jpg', // Load Google icon from assets
                  height: 24.0, // Set the size of the icon
                  width: 24.0, // Ensure the width matches the height
                ),
              ),

              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Don’t have an account?',
                      style: TextStyle(fontSize: 14),
                    ),
                    TextButton(
                      onPressed: _navigateToRegister,
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFE8C00), // Orange color
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
