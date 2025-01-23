import 'package:flutter/material.dart';

class AddAccountPage extends StatelessWidget {
  const AddAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Account'),
        backgroundColor: Colors.orange,
        elevation: 0,
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AddAccountPage()',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
