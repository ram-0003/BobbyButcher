import 'package:bobbybutcher/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Function to handle the password reset
  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.sendPasswordResetEmail(email: _emailController.text.trim());

        // Show confirmation message and navigate to login page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Check your email to reset your password")),
        );

        // Navigate to Login page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } on FirebaseAuthException catch (e) {
        // Display error if the email is not associated with an account
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Error resetting password")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Pops the current screen off the stack
          },
        ),// Your app title goes here
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 76),

              // Forgot Password Header
              const Text(
                'Forgot password?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              // Instruction Text
              const Text(
                'Enter your email address and we’ll send you a confirmation code to reset your password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF878787),
                ),
              ),

              const SizedBox(height: 22),

              // Email Label
              const Text(
                'Email Address',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101010),
                ),
              ),

              const SizedBox(height: 10),

              // Email Text Field
              TextFormField(
                controller: _emailController,
                validator: (value) => value!.contains('@') ? null : 'Enter a valid email',
                decoration: InputDecoration(
                  hintText: 'Enter Email',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Color(0xFFD6D6D6)),
                  ),
                ),
              ),

              const SizedBox(height: 170),

              // Continue Button
              ElevatedButton(
                onPressed: _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFE8C00),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(327, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
