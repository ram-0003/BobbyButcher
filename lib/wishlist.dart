import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'CustomBottomNavigationBar.dart';
import 'User_Service.dart';
// Assuming the CartItem model is the same.

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  // Sample data for wishlist items with asset image
  final UserService _userService = UserService();
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> wishlist = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() {
      loading = true;
      wishlist=[];
    });

    // Fetch the current user data
    userData = await _userService.getCurrentUserData();

    List<Map<String, dynamic>> updatedWishlist = [];

    if (userData != null && userData!['wishlist'] != null) {
      // Get the wishlist array from the user data
      List<dynamic> wish = userData!['wishlist'];

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
              updatedWishlist.add({
                'uid': item['uid'],
                ...productDoc.data() as Map<String, dynamic>, // Add product data to each wishlist item
              });
            }
          } catch (e) {
            print("Error fetching product with UID ${item['uid']}: $e");
          }
        }
      }
    }
    print(updatedWishlist);
    setState(() {
      loading = false;
      // Update the state with the complete wishlist data
      wishlist = updatedWishlist;
    });
  }

  Future<void> removeFromWishlist(String itemUid) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(userData!['uid']);

      // Find the item to remove from the wishlist array by matching its uid
      final itemToRemove = {
        'uid': itemUid,
      };

      await userDoc.update({
        'wishlist': FieldValue.arrayRemove([itemToRemove]),
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
          'Wishlist',
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
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final item = wishlist[index];
                return Dismissible(
                  key: Key(item['product_name']),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) async {
                    final itemUid = item['uid'];
                    await removeFromWishlist(itemUid);
                    setState(() {
                      wishlist.remove(item); // Remove item from the UI list
                    });
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: _buildWishlistItem(item),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0), // Increased padding
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
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
                'Add more wishlist',
                style: TextStyle(color: Colors.white, fontSize: 14), // Adjust font size as needed
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds each individual wishlist item card
  Widget _buildWishlistItem(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate font size based on the available width of the card
            double fontSize = constraints.maxWidth > 300 ? 14 : 10; // Adjust the size based on card width
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
                          item['product_name'] ?? 'No Name', // Fallback for missing name
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: fontSize, // Dynamic font size based on available width
                            fontWeight: FontWeight.bold, // Bold text
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
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Rs ${item['product_price'] ?? 0}',
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${item['discount_price'] != null && item['product_price'] != null && item['product_price'] > 0 ? (100-((item['discount_price'] / item['product_price']) * 100)).toStringAsFixed(0) : '0'}% off',
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Add button
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red, // Red background for the Add button container
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      // Add button text
                      Container(
                        width: 50,
                        height: 23,
                        decoration: BoxDecoration(
                          color: Colors.red, // White background for Add button
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            'Add', // Add button text
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: fontSize - 2, // Slightly smaller font size for the button
                              fontWeight: FontWeight.w700,
                              color: Colors.white, // Text color
                            ),
                          ),
                        ),
                      ),
                      // Plus icon
                      const Padding(
                        padding: EdgeInsets.only(right: 8), // Adjust the value to move the icon left
                        child: Icon(
                          Icons.add, // Plus icon
                          color: Colors.white,
                          size: 17,
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
