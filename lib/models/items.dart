import 'package:cloud_firestore/cloud_firestore.dart';

class Items {
  int itemId;
  String itemName;
  String image;
  double price;
  String category;
  String description;
  Timestamp launchTime;
  int sellerId; // Link to the user who is selling this item
  int? buyerId; // Link to the user who bought this item (null if not sold)
  bool isSold; // Whether the item has been sold

  Items({
    required this.itemId,
    required this.itemName, 
    required this.image, 
    required this.price, 
    required this.category,
    required this.description,
    required this.launchTime,
    required this.sellerId,
    this.buyerId,
    this.isSold = false,
  });

  Items.fromJson(Map<String, Object?> json) 
      : this(
        itemId: json['itemId'] as int,
        itemName: json['itemName'] as String, 
        image: json['image'] as String, 
        price: json['price'] as double, 
        category: json['category'] as String,
        description: json['description'] as String? ?? '',
        launchTime: json['launchTime'] as Timestamp,
        sellerId: json['sellerId'] as int,
        buyerId: json['buyerId'] as int?,
        isSold: json['isSold'] as bool? ?? false,
      );
  
  Items copyWith({
    int? itemId,
    String? itemName,
    String? image,
    double? price,
    String? category,
    String? description,
    Timestamp? launchTime,
    int? sellerId,
    int? buyerId,
    bool? isSold,
  }) {
    return Items(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      image: image ?? this.image,
      price: price ?? this.price,
      category: category ?? this.category,
      description: description ?? this.description,
      launchTime: launchTime ?? this.launchTime,
      sellerId: sellerId ?? this.sellerId,
      buyerId: buyerId ?? this.buyerId,
      isSold: isSold ?? this.isSold,
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
      'launchTime': launchTime,
      'sellerId': sellerId,
      'buyerId': buyerId,
      'isSold': isSold,
    };
  }
}