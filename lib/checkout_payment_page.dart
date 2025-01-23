import 'package:bobbybutcher/services/stripe_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'CustomBottomNavigationBar.dart';
import 'login.dart';
import 'order_history_page.dart';

class payment extends StatefulWidget {
  final List<Map<String,dynamic>> cart;
  final double totalPrice;
  const payment({super.key, required this.cart, required this.totalPrice});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<payment> {
  String _selectedPaymentMethod = 'UPI';
  String _selectedDeliveryMethod = 'Door delivery';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Checkout',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Payment',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildPaymentMethodSection(),
              const SizedBox(height: 24),
              const SizedBox(height: 16),
              _buildDeliveryMethodSection(),
              const SizedBox(height: 24),
              _buildTotalAmount(),
              const SizedBox(height: 16),
              _buildProceedButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1)],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Text(
                'Payment method',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
              ),
            ],
          ),
          RadioListTile(
            value: 'UPI',
            groupValue: _selectedPaymentMethod,
            activeColor: Colors.orange,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value.toString();
              });
            },
            title: const Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.orange),
                SizedBox(width: 8),
                Text('UPI'),
              ],
            ),
          ),
          const Divider(),
          RadioListTile(
            value: 'Bank Account',
            groupValue: _selectedPaymentMethod,
            activeColor: Colors.orange,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value.toString();
              });
            },
            title: const Row(
              children: [
                Icon(Icons.account_balance, color: Colors.pink),
                SizedBox(width: 8),
                Text('Add Bank account'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryMethodSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1)],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Text(
                'Delivery method',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
              ),
            ],
          ),
          RadioListTile(
            value: 'Door delivery',
            groupValue: _selectedDeliveryMethod,
            activeColor: Colors.orange,
            onChanged: (value) {
              setState(() {
                _selectedDeliveryMethod = value.toString();
              });
            },
            title: const Text('Door delivery'),
          ),
          const Divider(),
          RadioListTile(
            value: 'Pick up',
            groupValue: _selectedDeliveryMethod,
            activeColor: Colors.orange,
            onChanged: (value) {
              setState(() {
                _selectedDeliveryMethod = value.toString();
              });
            },
            title: const Text('Pick up'),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAmount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(
          width: 10,
        ),
        const Text(
          'Total',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        ),
        const SizedBox(
          width: 230,
        ),
        Text(
          '${widget.totalPrice}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget _buildProceedButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      onPressed: () async {
        final FirebaseAuth auth = FirebaseAuth.instance;
        User? currentUser = auth.currentUser;

        if (currentUser != null) {
          // Get the current user's UID
          String uid = currentUser.uid;

          // Make payment request using your payment service (e.g., Stripe)
          final paymentDetails = await StripeService.instance.makePayment(widget.totalPrice.toInt());

          if (paymentDetails != null) {
            // Extract payment details
            String paymentId = paymentDetails['paymentId'];
            String orderId = paymentDetails['orderId'];
            String paidAt = paymentDetails['paymentTimestamp'];
            int amount = widget.totalPrice.toInt();

            try {
              // Update Firestore with the new order
              CollectionReference orders = FirebaseFirestore.instance.collection('orders');
              await orders.add({
                'user_uid': uid,
                'paymentId': paymentId,
                'orderId': orderId,
                'paidAt': paidAt,
                'amount': amount,
                'products': widget.cart,
                'status': 'In Order', // Initial order status
              });

              // Clear the cart in the user's document in Firestore
              DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
              await userDoc.update({
                'cart': [], // Clear the cart field
              });

              // Show success dialog
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Payment Successful'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment ID: $paymentId'),
                        Text('Order ID: $orderId'),
                        Text('Paid At: $paidAt'),
                        Text('Amount: \$${amount.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const MainScreen()),
                        );
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            } catch (e) {
              // Handle Firestore update error
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating order: $e')),
              );
            }
          } else {
            // Payment failed or was canceled
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment failed or was cancelled.')),
            );
          }
        } else {
          // User is not signed in
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not signed in.')),
          );
        }
      },

      child: const Center(
        child: Text(
          'Proceed to Payment',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
