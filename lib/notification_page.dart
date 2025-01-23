import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Map<String, dynamic>? userData; // To store user data
  bool isLoading = true; // To manage loading state

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      // Get current user UID
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Fetch document from Firestore
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
        isLoading = false;
      });
    } catch (e) {
      // Handle errors
      print('Error fetching user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = userData?['notifications'] as List<dynamic>?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading spinner
          : notifications == null || notifications.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 200,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 25),
                const Text(
                  "No notifications yet",
                  style: TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 70),
                  child: Text(
                    "Hit the orange button down below to explore and get updates.",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final timestamp = (notification['timestamp'] as Timestamp)
              .toDate(); // Convert Firestore Timestamp
          final message = notification['message'] ?? 'No message';

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}',
              ),
              leading: const Icon(Icons.notifications),
            ),
          );
        },
      ),
    );
  }
}
