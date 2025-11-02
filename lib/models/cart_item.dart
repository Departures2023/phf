import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  int itemId;
  String itemName;
  String image;
  double price;
  String category;
  String description;
  int sellerId;
  String sellerName;
  Timestamp addedTime;
  int quantity;

  CartItem({
    required this.itemId,
    required this.itemName,
    required this.image,
    required this.price,
    required this.category,
    required this.description,
    required this.sellerId,
    required this.sellerName,
    required this.addedTime,
    this.quantity = 1,
  });

  CartItem.fromJson(Map<String, Object?> json)
      : this(
          itemId: json['itemId'] as int,
          itemName: json['itemName'] as String,
          image: json['image'] as String,
          price: json['price'] as double,
          category: json['category'] as String,
          description: json['description'] as String,
          sellerId: json['sellerId'] as int,
          sellerName: json['sellerName'] as String,
          addedTime: json['addedTime'] as Timestamp,
          quantity: json['quantity'] as int? ?? 1,
        );

  CartItem copyWith({
    int? itemId,
    String? itemName,
    String? image,
    double? price,
    String? category,
    String? description,
    int? sellerId,
    String? sellerName,
    Timestamp? addedTime,
    int? quantity,
  }) {
    return CartItem(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      image: image ?? this.image,
      price: price ?? this.price,
      category: category ?? this.category,
      description: description ?? this.description,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      addedTime: addedTime ?? this.addedTime,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'image': image,
      'price': price,
      'category': category,
      'description': description,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'addedTime': addedTime,
      'quantity': quantity,
    };
  }

  // Helper method to get total price for this cart item
  double get totalPrice => price * quantity;
}
