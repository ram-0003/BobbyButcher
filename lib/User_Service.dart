// user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetches the current user's data from Firestore
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final User? user = _auth.currentUser; // Get the current user
      if (user != null) {
        // Fetch user data from Firestore based on UID
        final DocumentSnapshot docSnapshot =
        await _firestore.collection('users').doc(user.uid).get();

        if (docSnapshot.exists) {
          // Return the user data as a Map<String, dynamic>
          return docSnapshot.data() as Map<String, dynamic>;
        } else {
          print("User data not found.");
        }
      } else {
        print("No user is logged in.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    return null; // Return null if user data is not found or an error occurs
  }
}
