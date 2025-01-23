import 'package:bobbybutcher/profile_settings.dart';
import 'package:bobbybutcher/recipe_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'notification_page.dart';
import 'order_history_page.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  _CustomBottomNavigationBarState createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  Map<String, dynamic>? userData;
  bool isLoading = false;

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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Dynamically build BottomNavigationBar items
    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.receipt_long_outlined),
        label: 'Order History',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.kitchen),
        label: 'Recipe',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.notifications_outlined),
        label: 'Notification',
      ),
      BottomNavigationBarItem(
        icon: CircleAvatar(
          radius: 12,
          backgroundImage: userData?['profilePicture'] != null
              ? NetworkImage(userData!['profilePicture']) // Show profile picture from network
              : const AssetImage('lib/assets/profile.jpg') as ImageProvider, // Fallback to asset image
          // child: userData?['profilePicture'] == null
          //     ? const Icon(Icons.camera_alt, size: 30) // Show icon only if no profile picture
          //     : null,
        ),
        label: 'Profile',
      ),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          final isSelected = index == widget.selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => widget.onItemTapped(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: isSelected ? const Offset(0, -8) : Offset.zero,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: isSelected
                            ? const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF6347), Color(0xFFFF826C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        )
                            : null,
                        child: IconTheme(
                          data: IconThemeData(
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                          child: items[index].icon,
                        ),
                      ),
                    ),
                    if (isSelected) // Only show label for the selected item
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          items[index].label!,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth < 360 ? 10 : 12, // Responsive font size
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}


// class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
//
//   Map<String, dynamic>? userData;
//   bool isLoading = false;
//   final List<BottomNavigationBarItem> _items = [
//     const BottomNavigationBarItem(
//       icon: Icon(Icons.home_outlined),
//       label: 'Home',
//     ),
//     const BottomNavigationBarItem(
//       icon: Icon(Icons.receipt_long_outlined),
//       label: 'Order History',
//     ),
//     const BottomNavigationBarItem(
//       icon: Icon(Icons.kitchen),
//       label: 'Recipe',
//     ),
//     const BottomNavigationBarItem(
//       icon: Icon(Icons.notifications_outlined),
//       label: 'Notification',
//     ),
//     const BottomNavigationBarItem(
//       icon: CircleAvatar(
//         radius: 12, // Adjust the size as needed
//         backgroundImage: AssetImage('lib/assets/profile.jpg'), // Replace with actual image path
//       ),
//       label: 'Profile',
//     ),
//
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchCurrentUserData();
//   }
//
//   Future<void> fetchCurrentUserData() async {
//     setState(() {
//       isLoading = true; // Start loading
//     });
//
//     try {
//       // Get the current user's UID
//       final String? uid = FirebaseAuth.instance.currentUser?.uid;
//       if (uid == null) throw Exception('No user is currently logged in.');
//
//       // Fetch the user's document from Firestore
//       DocumentSnapshot userDoc =
//       await FirebaseFirestore.instance.collection('users').doc(uid).get();
//       if (!userDoc.exists) throw Exception('User document does not exist.');
//
//       setState(() {
//         userData = userDoc.data() as Map<String, dynamic>?;
//         isLoading = false; // Stop loading
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false; // Stop loading on error
//       });
//       print('Error fetching user data: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: List.generate(_items.length, (index) {
//           final isSelected = index == widget.selectedIndex;
//           return Expanded(
//             child: GestureDetector(
//               onTap: () => widget.onItemTapped(index),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 4),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Transform.translate(
//                       offset: isSelected ? const Offset(0, -8) : Offset.zero,
//                       child: Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: isSelected
//                             ? const BoxDecoration(
//                           shape: BoxShape.circle,
//                           gradient: LinearGradient(
//                             colors: [Color(0xFFFF6347), Color(0xFFFF826C)],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                         )
//                             : null,
//                         child: IconTheme(
//                           data: IconThemeData(
//                             color: isSelected ? Colors.white : Colors.grey,
//                           ),
//                           child: _items[index].icon,
//                         ),
//                       ),
//                     ),
//                     if (isSelected) // Only show label for the selected item
//                       Padding(
//                         padding: const EdgeInsets.only(top: 4),
//                         child: Text(
//                           _items[index].label!,
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: screenWidth < 360 ? 10 : 12, // Responsive font size
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }


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