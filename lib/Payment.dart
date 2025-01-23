import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'User_Service.dart';
import 'checkout_payment_page.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final UserService _userService = UserService();
  Map<String, dynamic>? userData;
  Map<String, dynamic>? currentAddress;
  List<Map<String, dynamic>> cart = [];
  bool loading = false;
  List<Map<String, dynamic>> savedAddresses = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() {
      loading = true;
      cart = [];
    });

    userData = await _userService.getCurrentUserData();
    setState(() {
      savedAddresses = (userData?['Address'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      currentAddress = userData?['Current_Address'] ?? {};
    });
    List<Map<String, dynamic>> updatedCart = [];

    if (userData != null && userData!['cart'] != null) {
      List<dynamic> cartItems = userData!['cart'];

      for (var item in cartItems) {
        if (item['uid'] != null) {
          try {
            final DocumentSnapshot productDoc = await FirebaseFirestore.instance
                .collection('products')
                .doc(item['uid'])
                .get();



            if (productDoc.exists) {
              updatedCart.add({
                'uid': item['uid'],
                'quantity': item['quantity'],
                ...productDoc.data() as Map<String, dynamic>,
              });
            }
          } catch (e) {
            print("Error fetching product with UID ${item['uid']}: $e");
          }
        }
      }
    }

    setState(() {
      loading = false;
      cart = updatedCart;
      //savedAddresses i want to save the productdoc of 'Address'[]
    });
  }

  Future<void> _saveAddress(String name, String phone, String address, String city) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print("User is not logged in.");
      return;
    }

    Map<String, dynamic> addressData = {
      'name': name,
      'phoneNo': phone,
      'address': address,
      'city': city,
    };

    try {
      DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);

      await userDocRef.update({
        'Address': FieldValue.arrayUnion([addressData]),  // Add new address to the array
        'Current_Address': addressData,                   // Set as the current address field
      });

      setState(() {
        currentAddress = addressData;
      });

      // Refresh saved addresses list
      fetchUserData();
    } catch (e) {
      print("Error saving address: $e");
    }
  }

  Future<void> _showAddAddressDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController cityController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New Address"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, Icons.person, "Name"),
              _buildTextField(phoneController, Icons.phone, "Phone No."),
              _buildTextField(addressController, Icons.home, "Address"),
              _buildTextField(cityController, Icons.location_city, "City"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _saveAddress(
                  nameController.text,
                  phoneController.text,
                  addressController.text,
                  cityController.text,
                );
                Navigator.pop(context);
              },
              child: const Text("Save Address"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSelectAddressDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Address"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: savedAddresses.map((address) {
              return ListTile(
                title: Text(address['address'] ?? 'No address'),
                subtitle: Text(
                    '${address['city'] ?? ''}, ${address['phone'] ?? ''}'),
                onTap: () async {
                  // Update currentAddress with the selected address
                  setState(() {
                    currentAddress = address;
                  });

                  // Update Firestore with the selected address for the current user
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .update({'Current_Address': currentAddress});

                  // Close the dialog
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Close the current dialog and open the add address dialog
                Navigator.pop(context);
                await _showAddAddressDialog();
              },
              child: const Text("New Address"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }



  Widget _buildTextField(TextEditingController controller, IconData icon, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.orange),
          labelText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double productTotal = 0.0;
    double deliveryCharge = 0.0;
    double tax = 0.0;
    double totalPrice = 0.0;
    double productTotal1 = 0.0;
    List<Map<String, dynamic>> itemDetails = cart.map((item) {
      int quantity = item['quantity'] as int;
      double discountPrice = item['discount_price'] * quantity;
      double discountedAmount = discountPrice * 0.9;
      double discountedAmount1 = discountPrice ;

      productTotal += discountedAmount;
      productTotal1 += discountedAmount1;

      if (item['delivery_charge'] > deliveryCharge) {
        deliveryCharge = item['delivery_charge'];
      }

      return {
        'name': item['product_name'],
        'quantity': quantity,
        'price': discountedAmount,
      };
    }).toList();

    tax = productTotal1 * 0.1;
    totalPrice = productTotal + deliveryCharge + tax;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "You deserve a better meal",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              // Display selected products at the top
              if (cart.isNotEmpty)
                Column(
                  children: cart.map((item) {
                    int quantity = item['quantity'];
                    double discountPrice = item['discount_price'] * quantity * 0.9;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Image.network(
                            item['product_image'][0],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['product_name'],
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Rs ${discountPrice.toStringAsFixed(2)} | $quantity items",
                                style: const TextStyle(color: Colors.orange),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              const Divider(),
              const Text(
                "Details Transaction",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...itemDetails.map((itemDetail) => _buildTransactionDetail(
                "${itemDetail['name']} (${itemDetail['quantity']})",
                itemDetail['price'],
              )),
              _buildTransactionDetail("Delivery Charge", deliveryCharge),
              _buildTransactionDetail("Tax 10%", tax),
              const Divider(),
              _buildTransactionDetail("Total Price", totalPrice, isTotal: true),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                "Deliver to:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              currentAddress != null && currentAddress!.isNotEmpty
                  ? Column(
                children: [
                  _buildUserDetail(Icons.person,"Name",currentAddress?['name'] ?? 'Not Available',),
                  _buildUserDetail(Icons.phone,"Phone No.",currentAddress?['phoneNo'] ?? 'Not Available',),
                  _buildUserDetail(Icons.home,"Address",currentAddress?['address'] ?? 'Not Available',),
                  _buildUserDetail(Icons.location_city,"City",currentAddress?['city'] ?? 'Not Available',),
                  TextButton(
                    onPressed: _showSelectAddressDialog,
                    child: const Text("Change Address"),
                  ),
                ],
              )
                  : Column(
                children: [
                  const Text("No address available"),
                  TextButton(
                    onPressed: _showAddAddressDialog,
                    child: const Text("Add New Address"),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => payment(cart: cart, totalPrice: totalPrice,)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                    backgroundColor: Colors.orange,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text("Checkout Now"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionDetail(String title, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(
            "Rs ${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 16,
              color: isTotal ? Colors.orange : Colors.black,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetail(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange, size: 24),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Flexible(child: Text(value)),
      ],
    );
  }
}