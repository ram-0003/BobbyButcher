import 'package:bobbybutcher/CustomBottomNavigationBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'OnboardingPage.dart';
import 'login.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    if (seenOnboarding) {
      // If onboarding has been seen, navigate directly to LoginPage
      _navigateToLogin();
    } else {
      // Set the flag to true, so onboarding won't show again in future launches
      await prefs.setBool('seenOnboarding', true);
      _navigateToOnboarding();
    }
  }

  void _navigateToOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingPage()),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}


class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkUserType();
  }

  Future<void> checkUserType() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Display a loading indicator while checking
    return const Center(child: CircularProgressIndicator());
  }
}
