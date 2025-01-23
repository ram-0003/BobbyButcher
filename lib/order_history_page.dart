import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  // List to hold orders
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true; // To manage loading state

  @override
  void initState() {
    super.initState();
    _fetchOrders(); // Fetch orders when the page is initialized
  }

  Future<void> _fetchOrders() async {
    try {
      // Get the current user UID (Assuming you have FirebaseAuth set up)
      final User? user = FirebaseAuth.instance.currentUser; // Replace with actual UID from FirebaseAuth

      // Fetch orders where the user_uid matches the current user's UID
      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('user_uid', isEqualTo: user?.uid)
          .get();

      // Map the documents to a list of order data
      final orderList = querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      setState(() {
        orders = orderList;
        isLoading = false; // Update loading state
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Update loading state
      });
      print('Error fetching orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          "Order History",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading indicator
          : orders.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            const Icon(
              Icons.shopping_cart_outlined,
              size: 200,
              color: Colors.grey,
            ),
            const SizedBox(height: 25),
            const Text(
              "No orders yet",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 70),
              child: Text(
                "Hit the orange button down below to create an order",
                style: TextStyle(fontSize: 20),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: ListTile(
              title: Text('Order ID: ${order['orderId']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Amount: ${order['amount']}'),
                  Text('Status: ${order['status']}'),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        },
        child: const Text(
          'Start Ordering',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
