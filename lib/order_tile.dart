import 'package:flutter/material.dart';
import 'models.dart';

class OrderTile extends StatelessWidget {
  final Order order;

  const OrderTile({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Order ID ${order.orderId}',
              style: const TextStyle(color: Colors.grey),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                order.status,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        const Divider(),
        ListTile(
          title: Text(order.itemName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Rs ${order.price}',
              style: const TextStyle(color: Colors.orange)),
          trailing: Text('${order.itemCount} items',
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ),
      ],
    );
  }
}
