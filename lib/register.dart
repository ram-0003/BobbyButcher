import 'package:bobbybutcher/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'CustomBottomNavigationBar.dart';

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

String? validatePassword(String value) {
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Timestamp currentTimestamp = Timestamp.now();

  bool _isPasswordVisible = false;
  bool _isTermsAccepted = false;

  Future<void> _registerWithEmailAndPassword() async {
    if (_formKey.currentState!.validate() && _isTermsAccepted) {
      try {
        // Check if email is already in use
        final List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(_emailController.text.trim());

        if (signInMethods.isNotEmpty) {
          // If signInMethods is not empty, the email is already in use
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("The email address is already in use. Please use a different email.")),
          );
        } else {
          // Proceed with creating a new user
          UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          User? user = userCredential.user;
          if (user != null) {
            // Store additional user data in Firestore
            await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
              'username': _usernameController.text.trim(),
              'email': user.email,
              'uid': user.uid,
              'notifications':[
                {
                  "timestamp": currentTimestamp,
                  "message": "Welcome to our app! We are thrilled to have you on board. Stay tuned for updates and offers."
                }
              ]
            });

            // Show success message and navigate to login page
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Account created successfully!")),
            );

            // Clear fields and navigate to login page after a short delay
            _emailController.clear();
            _passwordController.clear();
            _usernameController.clear();

            Future.delayed(const Duration(seconds: 1), () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              ); // Navigate to Login Page
            });
          }
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Error creating account")),
        );
      }
    } else if (!_isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please accept the Terms of Service")),
      );
    }
  }

  Future<User?> _signInWithGoogle() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: <String>['email'],
      clientId: "603719090779-bccfbju1dnfh2c09mrgo92log61fsu7e.apps.googleusercontent.com", // Correct client ID
    );


    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
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

  void _navigateToLogin() {
    Navigator.pushNamed(context, '/login');
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
                'Create your new\naccount',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),
              Text(
                'Create an account to start looking for the Fresh Meat you like',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

              const SizedBox(height: 22),

              // Email Field
              const Text('Email Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                validator: (value) => value!.contains('@') ? null : 'Enter a valid email',
                decoration: const InputDecoration(
                  hintText: 'Enter Email',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              // Username Field
              const Text('User Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _usernameController,
                validator: (value) => value!.isEmpty ? 'Enter a username' : null,
                decoration: const InputDecoration(
                  hintText: 'Enter Username',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 22),

              // Password Field
              const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
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

              const SizedBox(height: 20),

              // Terms Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _isTermsAccepted,
                    onChanged: (value) {
                      setState(() {
                        _isTermsAccepted = value!;
                      });
                    },
                    activeColor: const Color(0xFFFE8C00),
                  ),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        text: 'I Agree with ',
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(color: Color(0xFFFE8C00)),
                          ),
                          TextSpan(
                            text: ' and ',
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(color: Color(0xFFFE8C00)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Register Button
              ElevatedButton(
                onPressed: _registerWithEmailAndPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFE8C00),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Register'),
              ),

              const SizedBox(height: 20),

              // Or Register with Google
              const Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.black26,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
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

              // Already have an account? Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don`t have an account? "),
                  TextButton(
                    onPressed: _navigateToLogin,
                    child: const Text(
                      "Sign In",
                      style: TextStyle(color: Color(0xFFFE8C00)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
