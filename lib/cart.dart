import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Payment.dart';
import 'User_Service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final UserService _userService = UserService();
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> cart = [];
  bool loading = false;

  //updatd
  Future<void> decreaseQuantity(Map<String, dynamic> item) async {
    int currentQuantity = item['quantity'] ?? 0;

    if (currentQuantity > 1) {
      final updatedItem = {
        'uid': item['uid'],
        'quantity': currentQuantity - 1,
      };

      final userDoc = FirebaseFirestore.instance.collection('users').doc(userData!['uid']);

      // Optimistically update the UI
      setState(() {
        item['quantity'] = currentQuantity - 1;
      });

      try {
        await userDoc.update({
          'cart': FieldValue.arrayRemove([{'uid': item['uid'], 'quantity': currentQuantity}]),
        });
        await userDoc.update({
          'cart': FieldValue.arrayUnion([updatedItem]),
        });
      } catch (e) {
        print("Failed to decrease item quantity: $e");
        // Revert the UI update if Firestore operation fails
        setState(() {
          item['quantity'] = currentQuantity; // Revert back
        });
      }
    } else {
      await removeFromCart(item['uid'], currentQuantity);
      setState(() {
        cart.removeWhere((cartItem) => cartItem['uid'] == item['uid']);
      });
    }
  }


  // Function to increase the quantity
  Future<void> increaseQuantity(Map<String, dynamic> item) async {
    // Get the current quantity
    int currentQuantity = item['quantity'] ?? 0;

    // Update the quantity by adding 1
    final updatedItem = {
      'uid': item['uid'],
      'quantity': currentQuantity + 1,
    };

    // Reference to the user's cart document in Firestore
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userData!['uid']);

    // Remove the old item with the old quantity
    await userDoc.update({
      'cart': FieldValue.arrayRemove([{
        'uid': item['uid'],
        'quantity': currentQuantity,
      }]),
    });

    // Add the updated item with the new quantity
    await userDoc.update({
      'cart': FieldValue.arrayUnion([updatedItem]),
    });

    print("Item quantity increased to ${currentQuantity + 1}");

    // Trigger UI update by calling setState
    setState(() {
      // Update the local state with the new quantity (if the item is in your local list)
      item['quantity'] = currentQuantity + 1;
    });
  }

  //updated

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() {
      loading = true;
      cart=[];
    });

    // Fetch the current user data
    userData = await _userService.getCurrentUserData();


    List<Map<String, dynamic>> updatedcart = [];

    if (userData != null && userData!['cart'] != null) {
      // Get the wishlist array from the user data
      List<dynamic> wish = userData!['cart'];

      for (var item in wish) {
        if (item['uid'] != null) {
          try {
            // Fetch each product document using the UID
            final DocumentSnapshot productDoc = await FirebaseFirestore.instance
                .collection('products')
                .doc(item['uid'])
                .get();

            if (productDoc.exists) {
              // Add the product data to the updated wishlist
              updatedcart.add({
                'uid': item['uid'],
                'quantity' : item['quantity'],
                ...productDoc.data() as Map<String, dynamic>, // Add product data to each wishlist item
              });
            }
          } catch (e) {
            print("Error fetching product with UID ${item['uid']}: $e");
          }
        }
      }
    }
    print(updatedcart);
    setState(() {
      loading = false;
      // Update the state with the complete wishlist data
      cart = updatedcart;
    });
  }

  Future<void> removeFromCart(String itemUid, int quantity) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(userData!['uid']);

      // Find the item to remove from the wishlist array by matching its uid
      final itemToRemove = {
        'uid': itemUid,
        'quantity': quantity,
      };

      await userDoc.update({
        'cart': FieldValue.arrayRemove([itemToRemove]),
      });
      print("Item removed from wishlist in Firestore.");
      fetchUserData();
    } catch (e) {
      print("Failed to remove item from wishlist: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 27),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Cart',
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/assets/iwwa_swipe.png',
                  width: 15, // Set the width for the image
                  height: 15, // Set the height for the image
                ),
                const SizedBox(width: 8),
                const Text(
                  'Swipe on an item to delete',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return Dismissible(
                  key: Key(item['uid']),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) async{
                    final itemUid = item['uid'];
                    int quantity = item['quantity'];
                    await removeFromCart(itemUid,quantity);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: _buildCartItem(item),
                );
              },
            ),
          ),
          // The single button at the bottom of the page
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0), // Increased padding
            child: ElevatedButton(
              onPressed: () {
                // Action when the button is clicked, for example navigate or proceed
                print('Complete Orders');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentPage()),
                );
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.orange),
                padding: WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(vertical: 20, horizontal: 40)), // Increased padding
                minimumSize: WidgetStateProperty.all(const Size(double.infinity, 60)), // Ensures the button takes the full width and is taller
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50), // Circular button
                  ),
                ),
              ),
              child: const Text(
                'Complete Orders',
                style: TextStyle(color: Colors.white, fontSize: 14), // Adjust font size as needed
              ),
            ),
          ),

        ],
      ),
    );
  }

  // Builds each individual cart item card
  Widget _buildCartItem(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate the font size based on the width of the card
            double fontSize = constraints.maxWidth / 20; // Adjust the divisor for fine-tuning the size

            return Row(
              children: [
                // Image with circular border
                Container(
                  width: 55, // Fixed width
                  height: 52, // Fixed height
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE00F0F), // Border color #E00F0F
                      width: 1, // Border width
                    ),
                  ),
                  child: ClipOval(
                    child: item['product_image'] != null && item['product_image'].isNotEmpty
                        ? Image.network(
                      item['product_image'][0], // Load image from assets
                      width: 55,
                      height: 52,
                      fit: BoxFit.cover, // Ensures the image fills the container
                    )
                        : Image.asset(
                      'lib/assets/placeholder_image.png', // Use a placeholder image
                      width: 55,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          item['product_name'] ?? 'No Name',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: fontSize, // Dynamically adjust font size
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Row(
                          children: [
                            Text(
                              'Rs ${item['discount_price'] ?? 0}  |',
                              style: TextStyle(
                                fontSize: fontSize * 0.7, // Slightly smaller font size for price
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Rs ${item['product_price'] ?? 0}',
                              style: TextStyle(
                                fontSize: fontSize * 0.7, // Slightly smaller font size for crossed-out price
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${item['discount_price'] != null && item['product_price'] != null && item['product_price'] > 0 ? ((100-(item['discount_price'] / item['product_price']) * 100)).toStringAsFixed(0) : '0'}% off',
                              style: TextStyle(
                                fontSize: fontSize * 0.7, // Slightly smaller font size for discount
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Quantity adjuster
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      // Decrease button
                      GestureDetector(
                        onTap: () async {
                          await decreaseQuantity(item);  //Decrease function when tapped
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(Icons.remove, size: 12, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Quantity text inside a white square background
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '${item['quantity'] ?? '0'}',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: fontSize * 0.8, // Dynamically adjust quantity font size
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Increase button
                      GestureDetector(
                        onTap: () async {
                          await increaseQuantity(item);  //Increase function when tapped
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(Icons.add, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

}
