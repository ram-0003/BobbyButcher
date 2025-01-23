import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
        backgroundColor: Colors.orange,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // FAQ 1
              _buildFAQTile(
                context,
                question: 'How do I reset my password?',
                answer: "To reset your password, first, sign out of your account. This will take you to the login page. On the login screen, you'll see a 'Forgot Password' button. Click on it, and you'll be directed to the password reset page. On that page, enter your registered email address and submit the form. After submitting, check your inbox for an email with a password reset link. Click the link in the email to change your password.",
              ),

              // FAQ 2
              _buildFAQTile(
                context,
                question: 'How do I contact support?',
                answer: 'You can contact support by clicking on the "Contact Support" button under the Help Center section.',
              ),

              // FAQ 3
              _buildFAQTile(
                context,
                question: 'How can I delete my account?',
                answer: 'To delete your account, go to the settings page and select "Request Account Deletion."',
              ),

              // More FAQs can be added similarly
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build each FAQ item
  Widget _buildFAQTile(BuildContext context, {required String question, required String answer}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
