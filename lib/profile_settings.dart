import 'dart:io';
import 'package:bobbybutcher/personal_date.dart';
import 'package:bobbybutcher/profile_option.dart';
import 'package:bobbybutcher/settings.dart';
import 'package:bobbybutcher/wishlist.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'AddAccountPage.dart';
import 'HelpCenterPage.dart';
import 'Video_Upload.dart';
import 'cart.dart';
import 'login.dart';
import 'notification_page.dart';
import 'order_history_page.dart';
import 'order_tile.dart';
import 'models.dart' as custom;


class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  Map<String, dynamic>? userData; // Holds current user data
  final ImagePicker picker = ImagePicker(); // Image picker initialization

  bool isLoading = false; // Track loading state

  final List<custom.Order> orders = [
    custom.Order(
      orderId: '88833777',
      itemName: 'Full Chicken',
      status: 'In Delivery',
      itemCount: 14,
      price: 300.0,
    ),
  ];
  final List<custom.ProfileOptionData> profileOptions = [
    custom.ProfileOptionData(icon: Icons.person, label: 'Personal Data'),
    custom.ProfileOptionData(icon: Icons.settings, label: 'Settings'),
    custom.ProfileOptionData(icon: Icons.credit_card, label: 'Extra Card'),
    custom.ProfileOptionData(icon: Icons.shopping_bag, label: 'Orders'),
    custom.ProfileOptionData(icon: Icons.upload_file, label: 'Upload Recipe'),
    custom.ProfileOptionData(icon: Icons.notifications, label: 'Notification'), // New Option
    custom.ProfileOptionData(icon: Icons.shopping_cart, label: 'Cart'), // New Option
    custom.ProfileOptionData(icon: Icons.favorite, label: 'View Wishlist'), // New Option
  ];

  @override
  void initState() {
    super.initState();
    fetchCurrentUserData();
  }

  Future<void> fetchCurrentUserData() async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      // Get the current user's UID
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('No user is currently logged in.');

      // Fetch the user's document from Firestore
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!userDoc.exists) throw Exception('User document does not exist.');

      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
        isLoading = false; // Stop loading
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loading on error
      });
      print('Error fetching user data: $e');
    }
  }

  Future<void> uploadProfilePicture() async {
    try {
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() {
        isLoading = true; // Start loading during upload
      });

      // Upload the file to Firebase Storage
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('No user is currently logged in.');

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$uid.jpg');
      await storageRef.putFile(File(pickedFile.path));

      // Get the download URL and update Firestore
      final downloadUrl = await storageRef.getDownloadURL();
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profilePicture': downloadUrl,
      });

      setState(() {
        userData?['profilePicture'] = downloadUrl;
        isLoading = false; // Stop loading
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loading on error
      });
      print('Error uploading profile picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile picture section
            GestureDetector(
              onTap: uploadProfilePicture,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: userData?['profilePicture'] != null
                    ? NetworkImage(userData!['profilePicture'])
                    : null,
                child: userData?['profilePicture'] == null
                    ? const Icon(Icons.camera_alt, size: 30)
                    : null,
              ),
            ),
            const SizedBox(height: 10),

            // User data section
            isLoading
                ? const CircularProgressIndicator()
                : userData != null
                ? Column(
              children: [
                Text(
                  userData!['username'] ?? 'No Name',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userData!['email'] ?? 'No Email',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            )
                : const Text('Failed to load user data'),

            const SizedBox(height: 20),

            // Orders section
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Orders',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'See All',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                  ...orders.map((item) => OrderTile(order: item)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Profile options section
            Container(
              color: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: profileOptions.map((option) {
                  return ProfileOption(
                    icon: option.icon,
                    label: option.label,
                    onTap: () {
                      switch (option.label) {
                        case 'Personal Data':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PersonalDataScreen()),
                          );
                          break;
                        case 'Upload Recipe':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CreateRecipePage()),
                          );
                          break;
                        case 'Orders':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const OrderHistoryPage()),
                          );
                          break;
                        case 'Settings':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SettingsPage()),
                          );
                          break;
                        case 'Notification': // New Case
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const NotificationPage()),
                          );
                          break;
                        case 'Cart': // New Case
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CartPage()),
                          );
                          break;
                        case 'View Wishlist': // New Case
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const WishlistPage()),
                          );
                          break;
                        default:
                          print('Option not implemented: ${option.label}');
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            // Add this below the Profile options section in your build method
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Support',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Help Center option
                  ListTile(
                    leading: const Icon(Icons.help_outline, color: Colors.black),
                    title: const Text('Help Center'),
                    onTap: () {
                      // Navigate to Help Center Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HelpCenterPage()),
                      );
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),

                  // Request Account Deletion option
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.black),
                    title: const Text('Request Account Deletion'),
                    onTap: () {
                      // Handle account deletion request
                      print('Request Account Deletion');
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),

                  // Add another account option
                  ListTile(
                    leading: const Icon(Icons.person_add_alt, color: Colors.black),
                    title: const Text('Add another account'),
                    onTap: () {
                      // Navigate to Add Account Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddAccountPage()),
                      );
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),

                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.center,  // This will center the button
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Handle sign-out logic
                          FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          'Sign Out',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Button background color
                          side: const BorderSide(color: Colors.red), // Border color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                          ),
                          minimumSize: const Size(double.infinity, 50), // Ensure the button spans full width and has a good height
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}


