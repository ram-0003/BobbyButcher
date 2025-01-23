import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  Map<String, dynamic>? userData; // To store user data
  bool isLoading = true; // To manage loading state
  bool isEditing = false; // To toggle between view and edit modes
  String? selectedGender; // State to track selected gender
  TextEditingController fullNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Fetch document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      setState(() {
        userData = userDoc.data() as Map<String, dynamic>;
        selectedGender = userData?['gender'] ?? "Gender";
        fullNameController.text = userData?['username'] ?? '';
        dobController.text = userData?['dateOfBirth'] ?? '';
        phoneController.text = userData?['phone'] ?? '';
        emailController.text = userData?['email'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveUserData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Update document in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'username': fullNameController.text,
        'dateOfBirth': dobController.text,
        'gender': selectedGender,
        'phone': phoneController.text,
        'email': emailController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data saved successfully!')),
      );

      setState(() {
        isEditing = false;
      });
    } catch (e) {
      print('Error saving data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving data!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Personal Data',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: userData?['profilePicture'] != null
                      ? NetworkImage(userData!['profilePicture'])
                      : const AssetImage('lib/assets/profile.jpg')
                  as ImageProvider,
                ),
                if (isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 16),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Edit Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    isEditing = !isEditing;
                  });
                },
                child: Text(
                  isEditing ? "Cancel" : "Edit",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),

            // Full Name Field
            CustomTextField(
              label: "Full Name",
              controller: fullNameController,
              isEnabled: isEditing,
            ),

            // Date of Birth Field
            CustomTextField(
              label: "Date of birth",
              controller: dobController,
              isEnabled: isEditing,
            ),

            // Gender Field
            CustomDropdownField(
              label: "Gender",
              options: const ["Gender", "Male", "Female", "Other"],
              selectedValue: selectedGender,
              isEnabled: isEditing,
              onChanged: (String? newValue) {
                if (isEditing) {
                  setState(() {
                    selectedGender = newValue;
                  });
                }
              },
            ),

            // Phone Field
            CustomTextField(
              label: "Phone",
              controller: phoneController,
              isEnabled: isEditing,
            ),

            // Email Field
            CustomTextField(
              label: "Email",
              controller: emailController,
              isEnabled: isEditing,
            ),

            const SizedBox(height: 30),

            // Save Button
            if (isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveUserData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isEnabled;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: isEnabled,
          decoration: InputDecoration(
            hintText: "Enter $label",
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class CustomDropdownField extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? selectedValue;
  final bool isEnabled;
  final ValueChanged<String?> onChanged;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.options,
    this.selectedValue,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: selectedValue ?? options.first,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: isEnabled ? onChanged : null,
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
