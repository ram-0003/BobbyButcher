import 'package:bobbybutcher/const.dart';
import 'package:bobbybutcher/profile_settings.dart';
import 'package:bobbybutcher/recipe_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'CustomBottomNavigationBar.dart';
import 'MainPage.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'notification_page.dart';
import 'order_history_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
  await _setup();
}

Future<void> _setup() async{
  Stripe.publishableKey = stripePublishableKey;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(),
      // home: UploadScreen(),
      // home:PaymentPage(),
      // home:UploadProductPage(),
      // home: ProfileSettingsScreen(),
      // home: payment(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // List of pages to show for each bottom navigation tab
  final List<Widget> _pages = [
    const HomePage(),
    const OrderHistoryPage(),
    const RecipePage(),
    const NotificationPage(),
    const ProfileSettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}