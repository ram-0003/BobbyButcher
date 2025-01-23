import 'package:bobbybutcher/wishlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'User_Service.dart';
import 'cart.dart';
import 'home_page.dart';

class ProductPage extends StatefulWidget {
  final String uid;
  const ProductPage({super.key, required this.uid});
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int activeImageIndex = 0;
  bool loading = false;
  bool isLiked = false;
  int quantity = 1;
  double scrollOffset = 0;
  int pricePerKg = 0;
  int totalPrice = 0;
  final UserService _userService = UserService();
  Map<String, dynamic>? userData;
  Product? selectedProduct;
  List<Product> recommended = [];


  @override
  void initState() {
    super.initState();
    fetchUserData();
    _fetchProductByUid();
    totalPrice = pricePerKg * quantity;
  }

  Future<void> fetchUserData() async {
    setState(() {
      loading = true;
    });

    // Fetch the current user data
    userData = await _userService.getCurrentUserData();

    if (userData != null && userData!['wishlist'] != null) {
      List<dynamic> wishlist = userData!['wishlist']; // Retrieve the wishlist array

      // Check if any item in the wishlist has a uid that matches widget.uid
      bool isMatch = wishlist.any((item) => item['uid'] == widget.uid);

      if (isMatch) {
        setState(() {
          isLiked = true; // Set isLiked to true if UID matches
        });
      }
    }

    setState(() {
      loading = false;
    });
  }


  Future<void> _fetchProductByUid() async {
    setState(() {
      loading = true;
    });
    try {
      // Fetch the document using the UID (document ID)
      final DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.uid) // The UID will be the document ID
          .get();

      if (docSnapshot.exists) {
        // Map the document data to a Product object
        final product = Product.fromFirestore(
          docSnapshot.data() as Map<String, dynamic>,
          docSnapshot.id, // Pass the document ID (UID)
        );

        // Update the state with the fetched product
        setState(() {
          pricePerKg = product.discountedPrice;
          totalPrice = product.discountedPrice;// Use 'discountedPrice' here
          selectedProduct = product;
          print("Fetched Product: $product");
        });

        // Fetch products with a different category
        final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('products')
            .where('category', isNotEqualTo: product.category) // Filter to exclude matching category
            .limit(10) // Optional: limit the number of recommendations
            .get();

        // Map the documents to Product objects and store in recommended list
        setState(() {
          recommended = querySnapshot.docs
              .map((doc) => Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
              .toList();
          print("Recommended Products: $recommended");
        });
      } else {
        print("Product with UID ${widget.uid} not found");
      }
    } catch (e) {
      print("Error fetching product by UID: $e");
    }
    setState(() {
      loading = false;
    });
  }


  void incrementQuantity() {
    setState(() {
      quantity++;
      totalPrice = pricePerKg * quantity;
    });
  }

  void decrementQuantity() {
    setState(() {
      if (quantity > 1) {
        quantity--;
        totalPrice = pricePerKg * quantity;
      }
    });
  }
  // Method to share content using share_plus
  void _shareContent() {
    Share.share(
      'Check out this amazing product! Here is some description or product details.', // Text to share
      subject: 'Amazing Product', // Optional: Subject for sharing
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    if(loading){
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    else{
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 44.0),
              child: Column(
                children: [
                  // Sticky Top Bar with glassy effect
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white, // Glassy look
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // This will place items at both ends
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.black,
                          ),
                          iconSize: 30,
                          padding:
                              const EdgeInsets.fromLTRB(6.67, 4.17, 7.5, 4.17),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const Text(
                          'About This Menu',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF101010),
                          ),
                          textAlign:
                              TextAlign.center, // Ensure the text is centered
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.share,
                            color: Colors.black,
                          ),
                          iconSize: 20,
                          padding: const EdgeInsets.only(top: 2.5),
                          onPressed: () {
                            _shareContent(); // Trigger the share functionality when pressed
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      SizedBox(
                        height: screenWidth * 0.5,
                        child: PageView.builder(
                          itemCount: selectedProduct?.images.length,
                          onPageChanged: (index) {
                            setState(() {
                              activeImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                              child: Image.network(
                                selectedProduct!.images[index],
                                fit: BoxFit.cover,
                                width:
                                    screenWidth, // Set width to match the screen width
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: GestureDetector(
                            onTap: () async {
                              setState(() {
                                isLiked = !isLiked;
                              });

                              try {
                                // Get the current user's UID
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  final String userUid = user.uid;

                                  // Define the cart item to add
                                  final Map<String, dynamic> wishItem = {
                                    'uid': widget.uid,                 // Replace 1 with the actual quantity if needed
                                  };
                                  if (isLiked) {
                                    // Add item to wishlist if `isLiked` is true
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(userUid)
                                        .update({
                                      'wishlist': FieldValue.arrayUnion([wishItem])
                                    });
                                  } else {
                                    // Remove item from wishlist if `isLiked` is false
                                    // First, fetch the user's wishlist to find the item to remove
                                    final userDoc = await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(userUid)
                                        .get();

                                    final userData = userDoc.data();
                                    if (userData != null && userData['wishlist'] != null) {
                                      List<dynamic> wishlist = userData['wishlist'];

                                      // Find the item in the wishlist with uid matching widget.uid
                                      final itemToRemove = wishlist.firstWhere(
                                            (item) => item['uid'] == widget.uid,
                                        orElse: () => null,
                                      );

                                      if (itemToRemove != null) {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(userUid)
                                            .update({
                                          'wishlist': FieldValue.arrayRemove([itemToRemove])
                                        });
                                      }
                                    }
                                  }

                                  // Add the cart item to the 'cart' array in the user's document


                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Item added to Wishlist successfully!"),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const WishlistPage(),
                                    ),
                                  );
                                } else {
                                  print("User not logged in.");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Failed Adding to wishlist!"),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } catch (e) {
                                print("Error adding item to cart: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Failed Adding to wishlist!"),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              // Background color to differentiate the icon shape
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              // Toggle between filled and outlined heart
                              color: Colors.red, // Icon color remains red
                              size: 20, // Icon size set to 20 as requested
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                              selectedProduct!.images.length, (index) {
                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              width: 12,
                              height: 4,
                              decoration: BoxDecoration(
                                color: activeImageIndex == index
                                    ? Colors.orange
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(color: Colors.black12),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                  // Overlapping Product Name, Price, Delivery Info, and Description Section
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedProduct!.title,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF101010),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Rs ${selectedProduct?.discountedPrice} | ',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFE8C00),
                              ),
                            ),
                            Text(
                              'Rs ${selectedProduct?.price}',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.lineThrough,
                                color: Color(0xFFFE8C00),
                              ),
                            ),
                            const Text(
                              ' / kg ',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFE8C00),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16), // Information Section
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: const Color(0x0fe8c000),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.local_shipping,
                                      color: Color(0xFFFE8C00), size: 15),
                                  const SizedBox(width: 8),
                                  Text(
                                    selectedProduct?.delivery_charge == 0.0
                                        ? 'Free Delivery'
                                        : '₹${selectedProduct?.delivery_charge}',
                                    style: const TextStyle(
                                      fontFamily: 'Action Sans',
                                      fontSize: 12,
                                      color: Color(0xFF878787),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      color: Color(0xFFFE8C00), size: 15),
                                  const SizedBox(width: 8),
                                  Text(
                                    selectedProduct!.delivery_time_duration,
                                    style: const TextStyle(
                                      fontFamily: 'Action Sans',
                                      fontSize: 12,
                                      color: Color(0xFF878787),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Color(0xFFFE8C00), size: 15),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${selectedProduct?.ratings}',
                                    style: const TextStyle(
                                      fontFamily: 'Action Sans',
                                      fontSize: 12,
                                      color: Color(0xFF878787),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: double.infinity,
                          height: 2,
                          margin: const EdgeInsets.only(left: 4, right: 4),
                          color:
                              const Color(0xFFEDEDED), // Light gray separator
                        ),
                        const SizedBox(height: 16),

                        // Description Section
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Description',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF101010),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                selectedProduct!.description,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: Color(0xFF878787),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recommended For You',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF101010),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            );
                          },
                          child: const Text(
                            'See All',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFE8C00),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Cards for Recommended Items
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recommended.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            width: 122.16,
                            height: 156,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductPage(
                                        uid: recommended[index].uid),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      recommended[index].images[0],
                                      // Image for all cards
                                      width: 120,
                                      height: 90.42,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      recommended[index].title,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF101010),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Quantity, Price, and Add to Cart Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: decrementQuantity,
                            child: const Icon(
                              Icons.remove,
                              size: 20,
                              color: Color(0xFFFE8C00),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$quantity kg',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF101010),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: incrementQuantity,
                            child: const Icon(
                              Icons.add,
                              size: 20,
                              color: Color(0xFFFE8C00),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₹${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFE8C00),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      try {
                        // Get the current user's UID
                        print('working1');
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          print('working2');
                          final String userUid = user.uid;

                          // Define the cart item to add
                          final Map<String, dynamic> cartItem = {
                            'uid': widget.uid,
                            'quantity': quantity, // Replace quantity with actual quantity if needed
                          };

                          // Retrieve the user's cart to check if the item already exists
                          final userDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userUid)
                              .get();

                          final userData = userDoc.data();
                          if (userData != null) {
                            print('working3');
                            List<dynamic> cart = userData['cart'] ?? [];

                            // Check if the item with the specified uid is already in the cart
                            final itemExistsInCart = cart.any((item) => item['uid'] == widget.uid);

                            if (!itemExistsInCart) {
                              // Add the item to the cart if it's not already there
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userUid)
                                  .update({
                                'cart': FieldValue.arrayUnion([cartItem])
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Item added to Cart successfully!"),
                                  duration: Duration(seconds: 2),
                                ),
                              );

                              // Navigate to the CartPage
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CartPage()),
                              );
                            } else {
                              // Show a message if the item is already in the cart
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Item is already in your cart."),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        } else {
                          print('working');
                          print("User not logged in.");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Failed Adding to Cart!"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        print("Error adding item to cart: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Failed Adding to Cart!"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      // Responsive width (80% of screen width)
                      height: 42,
                      // Fixed height, you can adjust if needed
                      decoration: BoxDecoration(
                        color: const Color(0xFFFE8C00),
                        borderRadius:
                            BorderRadius.circular(100), // Rounded corners
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // Center the content inside the button
                        children: [
                          Icon(Icons.shopping_cart,
                              color: Colors.white, size: 15),
                          SizedBox(width: 7),
                          Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
