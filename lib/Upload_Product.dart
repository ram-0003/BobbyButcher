import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadProductPage extends StatefulWidget {
  const UploadProductPage({super.key});

  @override
  _UploadProductPageState createState() => _UploadProductPageState();
}

class _UploadProductPageState extends State<UploadProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _discountPriceController = TextEditingController();
  final TextEditingController _deliveryChargeController = TextEditingController();
  final TextEditingController _deliveryTimeDurationController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _productImages = [];
  final List<String> _imageUrls = [];

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _productImages = pickedFiles.map((file) => File(file.path)).toList();
    });
    }

  Future<void> _uploadImages() async {
    for (var imageFile in _productImages) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('products/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(imageFile);
      final imageUrl = await storageRef.getDownloadURL();
      _imageUrls.add(imageUrl);
    }
  }

  Future<void> _uploadProduct() async {
    if (_formKey.currentState!.validate()) {
      await _uploadImages();

      await FirebaseFirestore.instance.collection('products').add({
        'product_name': _productNameController.text.trim(),
        'product_price': double.parse(_productPriceController.text.trim()),
        'discount_price': double.parse(_discountPriceController.text.trim()),
        'delivery_charge': double.parse(_deliveryChargeController.text.trim()),
        'delivery_time_duration': _deliveryTimeDurationController.text.trim(),
        'rating': double.parse(_ratingController.text.trim()),
        'description': _descriptionController.text.trim(),
        'category': _categoryController.text.trim(),
        'product_image': _imageUrls,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product uploaded successfully!')),
      );

      _clearForm();
    }
  }

  void _clearForm() {
    _productNameController.clear();
    _productPriceController.clear();
    _discountPriceController.clear();
    _deliveryChargeController.clear();
    _deliveryTimeDurationController.clear();
    _ratingController.clear();
    _descriptionController.clear();
    _categoryController.clear();
    _productImages.clear();
    _imageUrls.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // This is the back arrow icon
          onPressed: () {
            Navigator.pop(context); // This will pop the current screen
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _productNameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter product name' : null,
                ),
                TextFormField(
                  controller: _productPriceController,
                  decoration: const InputDecoration(labelText: 'Product Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter product price' : null,
                ),
                TextFormField(
                  controller: _discountPriceController,
                  decoration: const InputDecoration(labelText: 'Discount Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter discount price' : null,
                ),
                TextFormField(
                  controller: _deliveryChargeController,
                  decoration: const InputDecoration(labelText: 'Delivery Charge'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter delivery charge' : null,
                ),
                TextFormField(
                  controller: _deliveryTimeDurationController,
                  decoration:
                  const InputDecoration(labelText: 'Delivery Time Duration'),
                  validator: (value) => value!.isEmpty
                      ? 'Please enter delivery time duration'
                      : null,
                ),
                TextFormField(
                  controller: _ratingController,
                  decoration: const InputDecoration(labelText: 'Rating'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter rating' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter description' : null,
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter category' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImages,
                  child: const Text('Select Images'),
                ),
                const SizedBox(height: 10),
                _productImages.isNotEmpty
                    ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _productImages
                      .map((image) => Image.file(
                    image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ))
                      .toList(),
                )
                    : const Text('No images selected'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _uploadProduct,
                  child: const Text('Upload Product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
