import 'package:flutter/material.dart';

class Order {
  final String orderId;
  final String itemName;
  final String status;
  final int itemCount;
  final double price;

  Order({
    required this.orderId,
    required this.itemName,
    required this.status,
    required this.itemCount,
    required this.price,
  });
}

class ProfileOptionData {
  final IconData icon;
  final String label;

  ProfileOptionData({required this.icon, required this.label});
}



