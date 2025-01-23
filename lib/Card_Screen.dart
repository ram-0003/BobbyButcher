
import 'package:flutter/material.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  String selectedCard = 'MasterCard'; // default selected card

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Extra Card"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back press
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            onPressed: () {
              // Handle delete action
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.orange.shade300,
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vigneshharidoss', // Dynamic data
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '•••• •••• ••••', // Masked card number
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '8374', // Last four digits
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Card holder name',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Expiry date',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Credit card',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  buildCustomContainer(
                    icon: Icons.credit_card,
                    title: 'MasterCard',
                    subtitle: '•••• 0783 7873',
                    imagePath: 'lib/assets/ms.PNG',
                    isSelected: selectedCard == 'MasterCard',
                    onTap: () {
                      setState(() {
                        selectedCard = 'MasterCard';
                      });
                    },
                  ),
                  buildCustomContainer(
                    icon: Icons.credit_card,
                    title: 'Paypal',
                    subtitle: '•••• 0582 4672',
                    imagePath: 'lib/assets/pp.png',
                    isSelected: selectedCard == 'Paypal',
                    onTap: () {
                      setState(() {
                        selectedCard = 'Paypal';
                      });
                    },
                  ),
                  buildCustomContainer(
                    icon: Icons.credit_card,
                    title: 'Apple Pay',
                    subtitle: '•••• 0582 4672',
                    imagePath: 'lib/assets/ap.png',
                    isSelected: selectedCard == 'Apple Pay',
                    onTap: () {
                      setState(() {
                        selectedCard = 'Apple Pay';
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 70, vertical: 30),
                  ),
                  onPressed: () {
                    // Handle add new card
                  },
                  child: const Text('Add New Card',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCustomContainer({
    required IconData icon,
    required String title,
    required String subtitle,
    required String imagePath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
            width: 2.0,
          ),
          color: isSelected ? Colors.orange.shade50 : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 32.0, color: isSelected ? Colors.orange : Colors.grey),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10.0),
            Image.asset(
              imagePath, // Different image for each card
              width: 40,
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}