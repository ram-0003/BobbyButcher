
import 'package:bobbybutcher/productDetail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'network_error.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentCity = "Detecting..."; // Initial placeholder text
  String selectedCategory = "All"; // Track selected category
  List<Product> products = [];
  bool loading = false;
  bool hasInternet = true;

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((status) {
      setState(() {
        hasInternet = status != ConnectivityResult.none;
      });
    });
    _getCurrentLocation(); // Detect current location on init
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      loading=true;
    });
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();

      // Map each document to a Product object including the document ID (UID)
      setState(() {
        products = snapshot.docs
            .map((doc) => Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        print(products);
      });
    } catch (e) {
      print("Error fetching products: $e");
    }
    setState(() {
      loading=false;
    });
  }


  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            currentCity = "Permission Denied";
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          currentCity = "Location Unavailable";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print("Position: ${position.latitude}, ${position.longitude}");

      // Call the function to get city from coordinates
      await _getCityFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        currentCity = "Error Fetching";
      });
      print("Error in getting location: $e");
    }
  }

  // Function to get city name using OpenCage API
  Future<void> _getCityFromCoordinates(double latitude, double longitude) async {
    const String apiKey = 'API'; // Replace with your OpenCage API key
    final Uri url = Uri.parse(
        'https://api.opencagedata.com/geocode/v1/json?key=$apiKey&q=$latitude+$longitude&language=en'
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print("API Response: $data"); // Log the full response for debugging

        // Try to get city, fallback to town, village, or country if city is not found
        final String city = data['results'][0]['components']['city'] ??
            data['results'][0]['components']['town'] ??
            data['results'][0]['components']['village'] ??
            data['results'][0]['components']['country'] ??
            "Location not found";

        setState(() {
          currentCity = city;
        });
      } else {
        setState(() {
          currentCity = "Failed to get city";
        });
      }
    } catch (e) {
      setState(() {
        currentCity = "Error: Location Not Found";
      });
      print("Error fetching city: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    if (!hasInternet) {
      return Network_error(
        onRetry: () {
          setState(() {}); // Reload current widget
        },
      );
    }
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView( // Prevents overflow
          child: Column(
            children: [
              // Top section with background image and location info
              Stack(
                children: [
                  // Background Image
                  Container(
                    constraints: const BoxConstraints(
                      minHeight: 300, // Minimum height set to 300
                    ),
                    height: screenHeight * 0.3,
                    width: double.infinity,
                    child: Image.asset(
                      'lib/assets/image.png', // Ensure the path is correct
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Location and Search Row
                  Positioned(
                    top: screenHeight * 0.2 * 0.2,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              currentCity,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(), // Push the search icon to the right
                            IconButton(
                              icon: const Icon(Icons.search, color: Colors.white),
                              onPressed: () {
                                // Add action for search icon tap
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.5 * 0.20),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double fontSize = constraints.maxWidth > 450 ? 30 : 24;
                            return Text(
                              constraints.maxWidth > 450
                                  ? "Provide the best Meat for you"
                                  : "Provide the best\nMeat for you",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis, // To handle text overflow if necessary
                              maxLines: 2, // Ensures text does not exceed two lines
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
              // Category Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Find by Category",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    // Category Icons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCategoryIcon("All", Icons.circle, selectedCategory == "All"),
                        _buildCategoryIcon("Chicken", Icons.restaurant_menu, selectedCategory == "Chicken"),
                        _buildCategoryIcon("Mutton", Icons.fastfood, selectedCategory == "Mutton"),
                        _buildCategoryIcon("Egg", Icons.egg, selectedCategory == "Eggs"),
                      ],
                    ),
                  ],
                ),
              ),
              // Product Grid Section
              loading == true ? const Center(child: CircularProgressIndicator(),) :
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  shrinkWrap: true, // Ensures GridView fits within the Column
                  physics: const NeverScrollableScrollPhysics(), // Disables GridView's own scrolling
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300, // Maximum width for each card (adjust as needed)
                    childAspectRatio: 0.75, // Adjusts height relative to width
                    crossAxisSpacing: 16, // Space between items horizontally
                    mainAxisSpacing: 16, // Space between items vertically
                  ),
                  itemCount: products
                      .where((product) => selectedCategory == "All" || product.category == selectedCategory)
                      .length,
                  itemBuilder: (context, index) {
                    final product =  products
                        .where((product) => selectedCategory == "All" || product.category == selectedCategory)
                        .toList();
                    return _buildProductCard(product[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }


  // Build a category icon
  Widget _buildCategoryIcon(String label, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label; // Update selected category
        });
      },
      child: Column(
        children: [
          // Icon container with background color, padding, and shadow
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFE8C00) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          // Label text with color change based on selection
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFE8C00) : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Build a product card
  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        // Define what happens when the card is tapped, e.g., navigate to ProductPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductPage(uid: product.uid,)),
        );
      },
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return Image.network(
                    product.images[0],
                    width: constraints.maxWidth,
                    height: constraints.maxWidth / 1.3, // Set height to half of the width
                    fit: BoxFit.cover,
                  );
                },
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹${product.discountedPrice.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 18, color: Colors.yellow),
                        const SizedBox(width: 4),
                        Text(
                          product.ratings.toString(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class Product {
  final String category;
  final String title;
  final int price;
  final int discountedPrice;
  final String description;
  final double ratings;
  final bool isFavorite;
  final List<String> images;
  final String uid;
  final double delivery_charge;
  final String delivery_time_duration;

  Product({
    required this.category,
    required this.title,
    required this.price,
    required this.discountedPrice,
    required this.description,
    required this.ratings,
    this.isFavorite = false,
    required this.images,
    required this.uid,
    required this.delivery_charge,
    required this.delivery_time_duration,
  });

  factory Product.fromFirestore(Map<String, dynamic> data, String uid) {
    return Product(
      category: data['category'] ?? '',
      title: data['product_name'] ?? '',
      price: (data['product_price'] as num).toInt(), // Convert to int
      discountedPrice: (data['discount_price'] as num).toInt(), // Convert to int
      description: data['description'] ?? '',
      ratings: (data['rating'] as num).toDouble(), // Convert to double
      images: List<String>.from(data['product_image'] ?? []),
      uid: uid ?? '',
      delivery_charge:data['delivery_charge']?? '',
      delivery_time_duration:data['delivery_time_duration'] ?? '',
    );
  }
}
