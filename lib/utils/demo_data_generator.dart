import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/users.dart';
import '../models/items.dart';
import '../sevices/database_service.dart';

/// Comprehensive Demo Data Generator for PHF Marketplace
/// 
/// This utility creates realistic demo data including:
/// - Multiple users with varied profiles
/// - Diverse items across all categories
/// - Realistic transactions with different statuses
/// - Chat conversations between buyers and sellers
/// - Notifications for various scenarios
/// - Ratings and reviews
class DemoDataGenerator {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final DatabaseService _databaseService = DatabaseService();

  /// Generate all demo data for video presentation
  static Future<void> generateAllDemoData() async {
    try {
      print('🎬 Starting comprehensive demo data generation...');
      
      // Step 0: Clear existing demo data first
      await _clearExistingDemoData();
      
      // Step 1: Create diverse users
      await _createDemoUsers();
      
      // Step 2: Create diverse items across all categories
      await _createDemoItems();
      
      // Step 3: Create realistic transactions
      await _createDemoTransactions();
      
      // Step 4: Create notifications
      await _createDemoNotifications();
      
      // Step 5: Create chat rooms and messages
      await _createDemoChats();
      
      // Step 6: Update user arrays to match transactions
      await _updateUserArrays();
      
      print('Demo data generation completed successfully!');
      print('📊 Your app is now ready for the demo video!');
      print('🖼️ All items now have relevant product images from Unsplash!');
    } catch (e) {
      print('Error generating demo data: $e');
      rethrow;
    }
  }

  /// Clear existing demo data to ensure fresh start
  static Future<void> _clearExistingDemoData() async {
    try {
      print('🧹 Clearing existing demo data...');
      
      // Clear demo users (userId >= 1000)
      final QuerySnapshot usersSnapshot = await _firestore
          .collection('users')
          .where('userId', isGreaterThanOrEqualTo: 1000)
          .get();
      
      for (var doc in usersSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Clear demo items (itemId >= 2000)
      final QuerySnapshot itemsSnapshot = await _firestore
          .collection('items')
          .where('itemId', isGreaterThanOrEqualTo: 2000)
          .get();
      
      for (var doc in itemsSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Clear demo transactions
      final QuerySnapshot transactionsSnapshot = await _firestore
          .collection('purchase_orders')
          .get();
      
      for (var doc in transactionsSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Clear demo notifications
      final QuerySnapshot notificationsSnapshot = await _firestore
          .collection('notifications')
          .get();
      
      for (var doc in notificationsSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Clear demo chat rooms
      final QuerySnapshot chatRoomsSnapshot = await _firestore
          .collection('chat_rooms')
          .get();
      
      for (var doc in chatRoomsSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Clear demo messages
      final QuerySnapshot messagesSnapshot = await _firestore
          .collection('messages')
          .get();
      
      for (var doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }
      
      print('Existing demo data cleared!');
    } catch (e) {
      print('Error clearing demo data: $e');
      // Don't rethrow - continue with generation
    }
  }

  /// Create diverse demo users with realistic profiles
  static Future<void> _createDemoUsers() async {
    try {
      print('👥 Creating demo users...');
      
      final List<Users> demoUsers = [
        // Student sellers
        Users(
          userId: 1001,
          name: "Emily Chen",
          email: "emily.chen@university.edu",
          password: "demo123",
          avatar: "https://i.pravatar.cc/150?img=1",
          buyerCredit: 4.8,
          sellerCredit: 4.9,
          itemSold: [],
          itemBought: [],
        ),
        Users(
          userId: 1002,
          name: "Marcus Johnson",
          email: "marcus.j@university.edu",
          password: "demo123",
          avatar: "https://i.pravatar.cc/150?img=12",
          buyerCredit: 4.5,
          sellerCredit: 4.7,
          itemSold: [],
          itemBought: [],
        ),
        Users(
          userId: 1003,
          name: "Sarah Williams",
          email: "sarah.w@university.edu",
          password: "demo123",
          avatar: "https://i.pravatar.cc/150?img=5",
          buyerCredit: 4.9,
          sellerCredit: 4.6,
          itemSold: [],
          itemBought: [],
        ),
        Users(
          userId: 1004,
          name: "David Park",
          email: "david.park@university.edu",
          password: "demo123",
          avatar: "https://i.pravatar.cc/150?img=13",
          buyerCredit: 4.3,
          sellerCredit: 4.8,
          itemSold: [],
          itemBought: [],
        ),
        Users(
          userId: 1005,
          name: "Jessica Martinez",
          email: "jessica.m@university.edu",
          password: "demo123",
          avatar: "https://i.pravatar.cc/150?img=9",
          buyerCredit: 4.7,
          sellerCredit: 4.5,
          itemSold: [],
          itemBought: [],
        ),
        Users(
          userId: 1006,
          name: "Alex Thompson",
          email: "alex.t@university.edu",
          password: "demo123",
          avatar: "https://i.pravatar.cc/150?img=15",
          buyerCredit: 4.6,
          sellerCredit: 4.9,
          itemSold: [],
          itemBought: [],
        ),
        Users(
          userId: 1007,
          name: "Olivia Rodriguez",
          email: "olivia.r@university.edu",
          password: "demo123",
          avatar: "https://i.pravatar.cc/150?img=10",
          buyerCredit: 4.8,
          sellerCredit: 4.4,
          itemSold: [],
          itemBought: [],
        ),
        Users(
          userId: 1008,
          name: "Ryan Lee",
          email: "ryan.lee@university.edu",
          password: "demo123",
          avatar: "https://i.pravatar.cc/150?img=14",
          buyerCredit: 4.4,
          sellerCredit: 4.7,
          itemSold: [],
          itemBought: [],
        ),
        Users(
          userId: 1009,
          name: "Kevin Tang",
          email: "tangkevi@grinnell.edu",
          password: "demo123",
          avatar: "https://i.pravatar.cc/150?img=3",
          buyerCredit: 4.9,
          sellerCredit: 4.8,
          itemSold: [],
          itemBought: [],
        ),
      ];

      for (final user in demoUsers) {
        _databaseService.addUser(user);
        print('Created user: ${user.name}');
      }
    } catch (e) {
      print('Error creating demo users: $e');
      rethrow;
    }
  }

  /// Create diverse items across all categories
  static Future<void> _createDemoItems() async {
    try {
      print('📦 Creating demo items...');
      
      final List<Items> demoItems = [
        // Electronics
        Items(
          itemId: 2001,
          itemName: "MacBook Pro 14\" M2",
          image: "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400&h=300&fit=crop&auto=format",
          price: 1499.99,
          category: "Electronics",
          description: "Excellent condition, barely used. Includes original box and charger. Perfect for students!",
          sellerId: 1001,
          launchTime: Timestamp.now(),
          isSold: false,
        ),
        Items(
          itemId: 2002,
          itemName: "iPad Air 5th Gen",
          image: "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400&h=300&fit=crop&auto=format",
          price: 449.99,
          category: "Electronics",
          description: "256GB, WiFi + Cellular. Great for note-taking and digital art.",
          sellerId: 1002,
          launchTime: Timestamp.now(),
          isSold: false,
        ),
        Items(
          itemId: 2003,
          itemName: "Sony WH-1000XM5 Headphones",
          image: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=300&fit=crop&auto=format",
          price: 299.99,
          category: "Electronics",
          description: "Industry-leading noise cancellation. Perfect for studying.",
          sellerId: 1003,
          launchTime: Timestamp.now(),
          isSold: true,
          buyerId: 1007,
        ),
        Items(
          itemId: 2004,
          itemName: "iPhone 14 Pro",
          image: "https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5?w=400&h=300&fit=crop&auto=format",
          price: 899.99,
          category: "Electronics",
          description: "128GB, Space Black. Mint condition with AppleCare+.",
          sellerId: 1004,
          launchTime: Timestamp.now(),
          isSold: false,
        ),
        
        // Class Items
        Items(
          itemId: 2005,
          itemName: "Calculus: Early Transcendentals (9th Ed)",
          image: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400&h=300&fit=crop&auto=format",
          price: 85.00,
          category: "Class Items",
          description: "Stewart's Calculus textbook. Minimal highlighting, excellent condition.",
          sellerId: 1001,
          launchTime: Timestamp.now(),
          isSold: true,
          buyerId: 1005,
        ),
        Items(
          itemId: 2006,
          itemName: "Organic Chemistry Complete Set",
          image: "https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400&h=300&fit=crop&auto=format",
          price: 120.00,
          category: "Class Items",
          description: "Includes textbook, solutions manual, and molecular model kit.",
          sellerId: 1002,
          launchTime: Timestamp.now(),
          isSold: false,
        ),
        Items(
          itemId: 2007,
          itemName: "TI-84 Plus CE Calculator",
          image: "https://images.unsplash.com/photo-1611532736579-6b16e2b50449?w=400&h=300&fit=crop&auto=format",
          price: 75.00,
          category: "Class Items",
          description: "Graphing calculator in coral pink. Perfect for math and science.",
          sellerId: 1006,
          launchTime: Timestamp.now(),
          isSold: false,
        ),
        Items(
          itemId: 2008,
          itemName: "Psychology Textbook Bundle",
          image: "https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&h=300&fit=crop&auto=format",
          price: 95.00,
          category: "Class Items",
          description: "Intro to Psychology + Abnormal Psychology textbooks.",
          sellerId: 1003,
          launchTime: Timestamp.now(),
          isSold: true,
          buyerId: 1008,
        ),
        
        // Clothing
        Items(
          itemId: 2009,
          itemName: "North Face Jacket (Size M)",
          image: "https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400&h=300&fit=crop&auto=format",
          price: 120.00,
          category: "Clothing",
          description: "Waterproof, insulated winter jacket. Black, size medium.",
          sellerId: 1004,
          launchTime: Timestamp.now(),
          isSold: false,
        ),
        Items(
          itemId: 2010,
          itemName: "Nike Air Max 270 (Size 10)",
          image: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=300&fit=crop&auto=format",
          price: 95.00,
          category: "Clothing",
          description: "Worn 3 times, practically new. White and blue colorway.",
          sellerId: 1005,
          launchTime: Timestamp.now(),
          isSold: true,
          buyerId: 1002,
        ),
        Items(
          itemId: 2011,
          itemName: "Lululemon Yoga Mat",
          image: "https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=400&h=300&fit=crop&auto=format",
          price: 45.00,
          category: "Clothing",
          description: "5mm thickness, purple. Barely used, excellent condition.",
          sellerId: 1006,
          launchTime: Timestamp.now(),
          isSold: false,
        ),
        
        // Furniture
        Items(
          itemId: 2012,
          itemName: "IKEA Desk with Drawers",
          image: "https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=400&h=300&fit=crop&auto=format",
          price: 85.00,
          category: "Furniture",
          description: "White desk, 120cm x 60cm. Perfect for dorm or apartment.",
          sellerId: 1001,
          launchTime: Timestamp.now(),
          isSold: false,
        ),
        Items(
          itemId: 2013,
          itemName: "Gaming Chair - Ergonomic",
          image: "https://images.unsplash.com/photo-1580480055273-228ff5388ef8?w=400&h=300&fit=crop&auto=format",
          price: 150.00,
          category: "Furniture",
          description: "Black and red gaming chair with lumbar support.",
          sellerId: 1007,
          launchTime: Timestamp.now(),
          isSold: true,
          buyerId: 1004,
        ),
        Items(
          itemId: 2014,
          itemName: "Bookshelf - 5 Tier",
          image: "https://images.unsplash.com/photo-1594620302200-9a762244a156?w=400&h=300&fit=crop&auto=format",
          price: 60.00,
          category: "Furniture",
          description: "Wooden bookshelf, easy to assemble. Great for textbooks.",
          sellerId: 1008,
          launchTime: Timestamp.now(),
          isSold: false,
        ),
        
        // Daily Necessities
        Items(
          itemId: 2015,
          itemName: "Keurig Coffee Maker",
          image: "https://images.unsplash.com/photo-1517668808822-9ebb02f2a0e6?w=400&h=300&fit=crop&auto=format",
          price: 75.00,
          category: "Daily Necessities",
          description: "Single-serve coffee maker with 6 K-cups included.",
          sellerId: 1002,
          launchTime: Timestamp.now(),
          isSold: false,
        ),
        Items(
          itemId: 2016,
          itemName: "Mini Fridge (4.5 cu ft)",
          image: "https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?w=400&h=300&fit=crop&auto=format",
          price: 120.00,
          category: "Daily Necessities",
          description: "Perfect for dorm room. Includes small freezer compartment.",
          sellerId: 1005,
          launchTime: Timestamp.now(),
          isSold: true,
          buyerId: 1001,
        ),
        Items(
          itemId: 2017,
          itemName: "Vacuum Cleaner - Cordless",
          image: "https://images.unsplash.com/photo-1558317374-067fb5f30001?w=400&h=300&fit=crop&auto=format",
          price: 85.00,
          category: "Daily Necessities",
          description: "Dyson-style cordless vacuum. Great suction power.",
          sellerId: 1003,
          launchTime: Timestamp.now(),
          isSold: false,
        ),
        
        // Transportation
        Items(
          itemId: 2018,
          itemName: "Mountain Bike - Trek Marlin 5",
          image: "https://images.unsplash.com/photo-1576435728678-68d0fbf94e91?w=400&h=300&fit=crop&auto=format",
          price: 350.00,
          category: "Transportation",
          description: "29\" wheels, excellent for campus commuting and trails.",
          sellerId: 1006,
          launchTime: Timestamp.now(),
          isSold: false,
        ),
        Items(
          itemId: 2019,
          itemName: "Electric Scooter - Xiaomi",
          image: "https://images.unsplash.com/photo-1578352828697-58d06762108e?w=400&h=300&fit=crop&auto=format",
          price: 280.00,
          category: "Transportation",
          description: "25km range, foldable. Perfect for getting around campus.",
          sellerId: 1004,
          launchTime: Timestamp.now(),
          isSold: true,
          buyerId: 1006,
        ),
        Items(
          itemId: 2020,
          itemName: "Skateboard - Complete Setup",
          image: "https://images.unsplash.com/photo-1547447134-cd3f5c716030?w=400&h=300&fit=crop&auto=format",
          price: 95.00,
          category: "Transportation",
          description: "Element deck with Independent trucks. Good condition.",
          sellerId: 1007,
          launchTime: Timestamp.now(),
          isSold: false,
        ),
        Items(
          itemId: 2021,
          itemName: "Gaming Laptop - ASUS ROG",
          image: "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400&h=300&fit=crop&auto=format",
          price: 1299.99,
          category: "Electronics",
          description: "High-performance gaming laptop, RTX 3070, 16GB RAM. Perfect for gaming and coding.",
          sellerId: 1009,
          launchTime: Timestamp.now(),
          isSold: false,
        ),
        Items(
          itemId: 2022,
          itemName: "Mechanical Keyboard - Logitech",
          image: "https://images.unsplash.com/photo-1541140532154-b024d705b90a?w=400&h=300&fit=crop&auto=format",
          price: 89.99,
          category: "Electronics",
          description: "RGB mechanical keyboard with blue switches. Great for programming.",
          sellerId: 1009,
          launchTime: Timestamp.now(),
          isSold: true,
          buyerId: 1001,
        ),
        Items(
          itemId: 2023,
          itemName: "Computer Science Textbook Set",
          image: "https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&h=300&fit=crop&auto=format",
          price: 75.00,
          category: "Class Items",
          description: "Data Structures, Algorithms, and Operating Systems textbooks. Minimal wear.",
          sellerId: 1009,
          launchTime: Timestamp.now(),
          isSold: false,
        ),
      ];

      for (final item in demoItems) {
        _databaseService.addItem(item);
        print('Created item: ${item.itemName}');
      }
    } catch (e) {
      print('Error creating demo items: $e');
      rethrow;
    }
  }

  /// Create realistic demo transactions
  static Future<void> _createDemoTransactions() async {
    try {
      print('💳 Creating demo transactions...');
      
      final List<Map<String, dynamic>> transactions = [
        {
          'buyerId': 1007,
          'buyerName': 'Olivia Rodriguez',
          'sellerId': 1003,
          'items': [
            {
              'itemId': 2003,
              'itemName': 'Sony WH-1000XM5 Headphones',
              'quantity': 1,
              'unitPrice': 299.99,
              'totalPrice': 299.99,
            }
          ],
          'totalAmount': 299.99,
          'status': 'completed',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 5))),
          'updatedAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 3))),
        },
        {
          'buyerId': 1005,
          'buyerName': 'Jessica Martinez',
          'sellerId': 1001,
          'items': [
            {
              'itemId': 2005,
              'itemName': 'Calculus: Early Transcendentals (9th Ed)',
              'quantity': 1,
              'unitPrice': 85.00,
              'totalPrice': 85.00,
            }
          ],
          'totalAmount': 85.00,
          'status': 'completed',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 3))),
          'updatedAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 2))),
        },
        {
          'buyerId': 1008,
          'buyerName': 'Ryan Lee',
          'sellerId': 1003,
          'items': [
            {
              'itemId': 2008,
              'itemName': 'Psychology Textbook Bundle',
              'quantity': 1,
              'unitPrice': 95.00,
              'totalPrice': 95.00,
            }
          ],
          'totalAmount': 95.00,
          'status': 'confirmed',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 2))),
          'updatedAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 1))),
        },
        {
          'buyerId': 1002,
          'buyerName': 'Marcus Johnson',
          'sellerId': 1005,
          'items': [
            {
              'itemId': 2010,
              'itemName': 'Nike Air Max 270 (Size 10)',
              'quantity': 1,
              'unitPrice': 95.00,
              'totalPrice': 95.00,
            }
          ],
          'totalAmount': 95.00,
          'status': 'completed',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 24))),
          'updatedAt': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 12))),
        },
        {
          'buyerId': 1004,
          'buyerName': 'David Park',
          'sellerId': 1007,
          'items': [
            {
              'itemId': 2013,
              'itemName': 'Gaming Chair - Ergonomic',
              'quantity': 1,
              'unitPrice': 150.00,
              'totalPrice': 150.00,
            }
          ],
          'totalAmount': 150.00,
          'status': 'pending',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 6))),
          'updatedAt': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 6))),
        },
        {
          'buyerId': 1001,
          'buyerName': 'Emily Chen',
          'sellerId': 1005,
          'items': [
            {
              'itemId': 2016,
              'itemName': 'Mini Fridge (4.5 cu ft)',
              'quantity': 1,
              'unitPrice': 120.00,
              'totalPrice': 120.00,
            }
          ],
          'totalAmount': 120.00,
          'status': 'completed',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 48))),
          'updatedAt': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 24))),
        },
        {
          'buyerId': 1006,
          'buyerName': 'Alex Thompson',
          'sellerId': 1004,
          'items': [
            {
              'itemId': 2019,
              'itemName': 'Electric Scooter - Xiaomi',
              'quantity': 1,
              'unitPrice': 280.00,
              'totalPrice': 280.00,
            }
          ],
          'totalAmount': 280.00,
          'status': 'confirmed',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 8))),
          'updatedAt': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 4))),
        },
        {
          'buyerId': 1001,
          'buyerName': 'Emily Chen',
          'sellerId': 1009,
          'items': [
            {
              'itemId': 2022,
              'itemName': 'Mechanical Keyboard - Logitech',
              'quantity': 1,
              'unitPrice': 89.99,
              'totalPrice': 89.99,
            }
          ],
          'totalAmount': 89.99,
          'status': 'completed',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 1))),
          'updatedAt': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 12))),
        },
      ];

      for (final transaction in transactions) {
        await _firestore.collection('purchase_orders').add(transaction);
        print('Created transaction: ${transaction['buyerName']} → Seller ${transaction['sellerId']}');
      }
    } catch (e) {
      print('Error creating demo transactions: $e');
      rethrow;
    }
  }

  /// Create demo notifications
  static Future<void> _createDemoNotifications() async {
    try {
      print('Creating demo notifications...');
      
      final List<Map<String, dynamic>> notifications = [
        {
          'userId': 1003,
          'type': 'purchase_request',
          'title': 'New Purchase Request',
          'message': 'Olivia Rodriguez wants to purchase Sony WH-1000XM5 Headphones',
          'data': {
            'buyerId': 1007,
            'buyerName': 'Olivia Rodriguez',
            'itemId': 2003,
          },
          'isRead': true,
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 5))),
        },
        {
          'userId': 1001,
          'type': 'purchase_request',
          'title': 'New Purchase Request',
          'message': 'Jessica Martinez wants to purchase Calculus textbook for \$85.00',
          'data': {
            'buyerId': 1005,
            'buyerName': 'Jessica Martinez',
            'itemId': 2005,
          },
          'isRead': true,
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 3))),
        },
        {
          'userId': 1007,
          'type': 'rating',
          'title': 'New Rating Received',
          'message': 'David Park rated you 5 stars! "Great chair, fast delivery!"',
          'data': {
            'raterId': 1004,
            'raterName': 'David Park',
            'rating': 5.0,
          },
          'isRead': false,
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 12))),
        },
        {
          'userId': 1005,
          'type': 'transaction_update',
          'title': 'Transaction Completed',
          'message': 'Your sale of Nike Air Max 270 has been completed!',
          'data': {
            'buyerId': 1002,
            'itemId': 2010,
          },
          'isRead': false,
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 6))),
        },
        {
          'userId': 1004,
          'type': 'purchase_request',
          'title': 'New Purchase Request',
          'message': 'Alex Thompson wants to purchase Electric Scooter for \$280.00',
          'data': {
            'buyerId': 1006,
            'buyerName': 'Alex Thompson',
            'itemId': 2019,
          },
          'isRead': false,
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 4))),
        },
        {
          'userId': 1009,
          'type': 'rating',
          'title': 'New Rating Received',
          'message': 'Emily Chen rated you 5 stars! "Great keyboard, fast shipping!"',
          'data': {
            'raterId': 1001,
            'raterName': 'Emily Chen',
            'rating': 5.0,
          },
          'isRead': false,
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 2))),
        },
      ];

      for (final notification in notifications) {
        await _firestore.collection('notifications').add(notification);
        print('Created notification for user ${notification['userId']}');
      }
    } catch (e) {
      print('Error creating demo notifications: $e');
      rethrow;
    }
  }

  /// Create demo chat rooms and messages
  static Future<void> _createDemoChats() async {
    try {
      print('Creating demo chats...');
      
      // Create chat rooms
      final List<Map<String, dynamic>> chatRooms = [
        {
          'participants': ['1007', '1003'],
          'itemId': '2003',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 6))),
          'lastMessageTime': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 5))),
          'lastMessageId': null,
        },
        {
          'participants': ['1005', '1001'],
          'itemId': '2005',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 4))),
          'lastMessageTime': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 3))),
          'lastMessageId': null,
        },
        {
          'participants': ['1002', '1004'],
          'itemId': '2004',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 2))),
          'lastMessageTime': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 12))),
          'lastMessageId': null,
        },
        {
          'participants': ['1006', '1001'],
          'itemId': '2012',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 24))),
          'lastMessageTime': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 2))),
          'lastMessageId': null,
        },
      ];

      final List<String> chatRoomIds = [];
      for (final chatRoom in chatRooms) {
        final docRef = await _firestore.collection('chat_rooms').add(chatRoom);
        chatRoomIds.add(docRef.id);
        print('Created chat room: ${chatRoom['participants'].join(' ↔ ')}');
      }

      // Create messages for each chat room
      if (chatRoomIds.isNotEmpty) {
        // Chat 1: About headphones
        await _createMessage(chatRoomIds[0], 1007, 'Hi! Are these headphones still available?', DateTime.now().subtract(Duration(days: 6)));
        await _createMessage(chatRoomIds[0], 1003, 'Yes! They are in excellent condition, barely used.', DateTime.now().subtract(Duration(days: 6, hours: -1)));
        await _createMessage(chatRoomIds[0], 1007, 'Great! Can I pick them up tomorrow?', DateTime.now().subtract(Duration(days: 5, hours: 23)));
        await _createMessage(chatRoomIds[0], 1003, 'Sure! I am free after 3pm. Meet at the library?', DateTime.now().subtract(Duration(days: 5, hours: 22)));
        await _createMessage(chatRoomIds[0], 1007, 'Perfect! See you then!', DateTime.now().subtract(Duration(days: 5)));

        // Chat 2: About textbook
        await _createMessage(chatRoomIds[1], 1005, 'Is this the latest edition?', DateTime.now().subtract(Duration(days: 4)));
        await _createMessage(chatRoomIds[1], 1001, 'Yes, 9th edition. Perfect condition with minimal highlights.', DateTime.now().subtract(Duration(days: 4, hours: -2)));
        await _createMessage(chatRoomIds[1], 1005, 'Would you take \$80?', DateTime.now().subtract(Duration(days: 3, hours: 23)));
        await _createMessage(chatRoomIds[1], 1001, 'I can do \$82, it is like new!', DateTime.now().subtract(Duration(days: 3, hours: 22)));
        await _createMessage(chatRoomIds[1], 1005, 'Deal! When can I get it?', DateTime.now().subtract(Duration(days: 3)));

        // Chat 3: About iPhone
        await _createMessage(chatRoomIds[2], 1002, 'Does it come with the original box?', DateTime.now().subtract(Duration(days: 2)));
        await _createMessage(chatRoomIds[2], 1004, 'Yes! Box, charger, and AppleCare+ until next year.', DateTime.now().subtract(Duration(hours: 36)));
        await _createMessage(chatRoomIds[2], 1002, 'That\'s awesome! What\'s the battery health?', DateTime.now().subtract(Duration(hours: 24)));
        await _createMessage(chatRoomIds[2], 1004, '97%! I can send you screenshots if you want.', DateTime.now().subtract(Duration(hours: 12)));

        // Chat 4: About desk
        await _createMessage(chatRoomIds[3], 1006, 'Hi! Is the desk still available?', DateTime.now().subtract(Duration(hours: 24)));
        await _createMessage(chatRoomIds[3], 1001, 'Yes it is! When would you like to see it?', DateTime.now().subtract(Duration(hours: 20)));
        await _createMessage(chatRoomIds[3], 1006, 'How about this weekend?', DateTime.now().subtract(Duration(hours: 12)));
        await _createMessage(chatRoomIds[3], 1001, 'Saturday afternoon works for me!', DateTime.now().subtract(Duration(hours: 2)));
      }
    } catch (e) {
      print('Error creating demo chats: $e');
      rethrow;
    }
  }

  static Future<void> _createMessage(String chatRoomId, int senderId, String content, DateTime time) async {
    await _firestore.collection('messages').add({
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(time),
      'read': true,
    });
  }

  /// Update user arrays to match transaction data
  static Future<void> _updateUserArrays() async {
    try {
      print('Updating user arrays...');
      
      final Map<int, List<int>> userSoldItems = {
        1001: [2005],
        1003: [2003, 2008],
        1004: [2019],
        1005: [2010, 2016],
        1007: [2013],
        1009: [2022],
      };

      final Map<int, List<int>> userBoughtItems = {
        1001: [2016, 2022],
        1002: [2010],
        1004: [2013],
        1005: [2005],
        1006: [2019],
        1007: [2003],
        1008: [2008],
      };

      for (final entry in userSoldItems.entries) {
        final QuerySnapshot userSnapshot = await _firestore
            .collection('users')
            .where('userId', isEqualTo: entry.key)
            .get();
        
        if (userSnapshot.docs.isNotEmpty) {
          await userSnapshot.docs.first.reference.update({
            'itemSold': entry.value,
          });
          print('Updated user ${entry.key} itemSold array');
        }
      }

      for (final entry in userBoughtItems.entries) {
        final QuerySnapshot userSnapshot = await _firestore
            .collection('users')
            .where('userId', isEqualTo: entry.key)
            .get();
        
        if (userSnapshot.docs.isNotEmpty) {
          await userSnapshot.docs.first.reference.update({
            'itemBought': entry.value,
          });
          print('Updated user ${entry.key} itemBought array');
        }
      }
    } catch (e) {
      print('Error updating user arrays: $e');
      rethrow;
    }
  }
}

