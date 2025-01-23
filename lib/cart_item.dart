// cart_item.dart

class CartItem {
  final String id;
  final String title;
  final String imageUrl;
  final int price;
  final int discount;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.discount,
    required this.quantity,
  });
}
