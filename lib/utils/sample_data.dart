import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/items.dart';
import '../models/users.dart';
import '../sevices/database_service.dart';

class SampleData {
  static final DatabaseService _databaseService = DatabaseService();

  static Future<void> addSampleUsers() async {
    try {
      // Sample users
      final users = [
        Users(
          userId: 1,
          name: "Sample User",
          password: "password",
          email: "user@example.com",
          avatar: "",
          buyerCredit: 4.2,
          sellerCredit: 3.8,
          itemSold: [1, 2, 3, 4, 5],
          itemBought: [6, 7, 8],
        ),
        Users(
          userId: 2,
          name: "John Doe",
          password: "password123",
          email: "john@example.com",
          avatar: "",
          buyerCredit: 4.5,
          sellerCredit: 4.0,
          itemSold: [1, 2],
          itemBought: [3, 4],
        ),
        Users(
          userId: 3,
          name: "Jane Smith",
          password: "password456",
          email: "jane@example.com",
          avatar: "",
          buyerCredit: 3.8,
          sellerCredit: 4.2,
          itemSold: [3, 4, 5],
          itemBought: [1, 2],
        ),
      ];

      for (final user in users) {
        _databaseService.addUser(user);
        print('Added user: ${user.name}');
      }
    } catch (e) {
      print('Error adding sample users: $e');
    }
  }

  static Future<void> addSampleItems() async {
    try {
      final now = Timestamp.now();
      
      // Sample items
      final items = [
        Items(
          itemId: 1,
          itemName: "Vintage Camera",
          image: "https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=400",
          price: 150.00,
          category: "Electronics",
          description: "Beautiful vintage camera in excellent condition. Perfect for photography enthusiasts.",
          launchTime: now,
          sellerId: 2,
          isSold: false,
        ),
        Items(
          itemId: 2,
          itemName: "Designer Handbag",
          image: "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400",
          price: 200.00,
          category: "Clothing",
          description: "Luxury designer handbag, barely used. Original packaging included.",
          launchTime: now,
          sellerId: 3,
          isSold: false,
        ),
        Items(
          itemId: 3,
          itemName: "Textbook - Calculus",
          image: "https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400",
          price: 75.00,
          category: "Class Items",
          description: "Calculus textbook, 3rd edition. Some highlighting but in good condition.",
          launchTime: now,
          sellerId: 2,
          isSold: false,
        ),
        Items(
          itemId: 4,
          itemName: "Coffee Maker",
          image: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400",
          price: 45.00,
          category: "Daily Necessities",
          description: "Automatic coffee maker, works perfectly. Great for dorm rooms.",
          launchTime: now,
          sellerId: 3,
          isSold: false,
        ),
        Items(
          itemId: 5,
          itemName: "Gaming Chair",
          image: "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400",
          price: 120.00,
          category: "Furniture",
          description: "Comfortable gaming chair with lumbar support. Barely used.",
          launchTime: now,
          sellerId: 2,
          isSold: false,
        ),
        Items(
          itemId: 6,
          itemName: "Bicycle",
          image: "https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400",
          price: 300.00,
          category: "Transportation",
          description: "Mountain bike in excellent condition. Recently serviced.",
          launchTime: now,
          sellerId: 3,
          isSold: false,
        ),
        Items(
          itemId: 7,
          itemName: "Laptop Stand",
          image: "https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400",
          price: 25.00,
          category: "Electronics",
          description: "Adjustable laptop stand for better ergonomics. Lightweight and portable.",
          launchTime: now,
          sellerId: 2,
          isSold: false,
        ),
        Items(
          itemId: 8,
          itemName: "Art Supplies Set",
          image: "https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=400",
          price: 35.00,
          category: "Class Items",
          description: "Complete set of art supplies including brushes, paints, and canvas.",
          launchTime: now,
          sellerId: 3,
          isSold: false,
        ),
      ];

      for (final item in items) {
        _databaseService.addItem(item);
        print('Added item: ${item.itemName}');
      }
    } catch (e) {
      print('Error adding sample items: $e');
    }
  }

  static Future<void> addAllSampleData() async {
    print('Adding sample data...');
    await addSampleUsers();
    await addSampleItems();
    print('Sample data added successfully!');
  }
}
