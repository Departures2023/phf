import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/users.dart';
import '../models/items.dart';
import '../sevices/database_service.dart';

class DatabaseSetup {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final DatabaseService _databaseService = DatabaseService();

  /// Initialize all required collections with sample data
  static Future<void> initializeDatabase() async {
    try {
      print('🚀 Starting database initialization...');
      
      // Create sample users first
      await _createSampleUsers();
      
      // Create sample items
      await _createSampleItems();
      
      // Create sample purchase orders
      await _createSamplePurchaseOrders();
      
      // Create sample notifications
      await _createSampleNotifications();
      
      // Create sample chat rooms
      await _createSampleChatRooms();
      
      // Create sample messages
      await _createSampleMessages();
      
      print('Database initialization completed successfully!');
      print('📋 Note: You may need to create Firestore indexes for optimal performance.');
      print('🔗 Check the console for index creation links if you encounter query errors.');
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  /// Create sample users
  static Future<void> _createSampleUsers() async {
    try {
      print('👥 Creating sample users...');
      
      final List<Users> sampleUsers = [
        Users(
          userId: 1,
          name: "Alice Johnson",
          email: "alice@example.com",
          password: "password123",
          avatar: "",
          buyerCredit: 4.5,
          sellerCredit: 4.2,
          itemSold: [2], // Only item 2 is actually sold
          itemBought: [3], // Only item 3 is actually bought
        ),
        Users(
          userId: 2,
          name: "Bob Smith",
          email: "bob@example.com",
          password: "password123",
          avatar: "",
          buyerCredit: 4.0,
          sellerCredit: 4.8,
          itemSold: [3, 4], // Items 3 and 4 are sold by Bob
          itemBought: [2], // Item 2 is bought by Bob
        ),
        Users(
          userId: 3,
          name: "Carol Davis",
          email: "carol@example.com",
          password: "password123",
          avatar: "",
          buyerCredit: 4.7,
          sellerCredit: 4.3,
          itemSold: [5], // Item 5 is sold by Carol
          itemBought: [3], // Item 3 is bought by Carol
        ),
      ];

      for (final user in sampleUsers) {
        _databaseService.addUser(user);
        print('Created user: ${user.name}');
      }
    } catch (e) {
      print('Error creating sample users: $e');
      rethrow;
    }
  }

  /// Create sample items
  static Future<void> _createSampleItems() async {
    try {
      print('📦 Creating sample items...');
      
      final List<Items> sampleItems = [
        Items(
          itemId: 1,
          itemName: "MacBook Pro 13-inch",
          image: "https://via.placeholder.com/300x200?text=MacBook+Pro",
          price: 1299.99,
          category: "Electronics",
          description: "Excellent condition MacBook Pro, barely used",
          sellerId: 1,
          launchTime: Timestamp.now(),
          isSold: false,
        ),
        Items(
          itemId: 2,
          itemName: "iPhone 13 Pro",
          image: "https://via.placeholder.com/300x200?text=iPhone+13+Pro",
          price: 899.99,
          category: "Electronics",
          description: "Unlocked iPhone 13 Pro, 128GB, Space Gray",
          sellerId: 1,
          buyerId: 2, // Bob Smith bought this
          launchTime: Timestamp.now(),
          isSold: true,
        ),
        Items(
          itemId: 3,
          itemName: "Nike Air Max 270",
          image: "https://via.placeholder.com/300x200?text=Nike+Air+Max",
          price: 120.00,
          category: "Clothing",
          description: "Size 10, worn only a few times",
          sellerId: 2,
          buyerId: 3, // Carol bought this
          launchTime: Timestamp.now(),
          isSold: true,
        ),
        Items(
          itemId: 4,
          itemName: "Calculus Textbook",
          image: "https://via.placeholder.com/300x200?text=Calculus+Book",
          price: 75.00,
          category: "Class Items",
          description: "Calculus: Early Transcendentals, 8th Edition",
          sellerId: 2,
          buyerId: 1, // Alice bought this
          launchTime: Timestamp.now(),
          isSold: true,
        ),
        Items(
          itemId: 5,
          itemName: "Gaming Chair",
          image: "https://via.placeholder.com/300x200?text=Gaming+Chair",
          price: 199.99,
          category: "Furniture",
          description: "Ergonomic gaming chair, black and red",
          sellerId: 3,
          buyerId: 2, // Bob bought this
          launchTime: Timestamp.now(),
          isSold: true,
        ),
      ];

      for (final item in sampleItems) {
        _databaseService.addItem(item);
        print('Created item: ${item.itemName}');
      }
    } catch (e) {
      print('Error creating sample items: $e');
      rethrow;
    }
  }

  /// Create sample purchase orders
  static Future<void> _createSamplePurchaseOrders() async {
    try {
      print('🛒 Creating sample purchase orders...');
      
      final List<Map<String, dynamic>> sampleOrders = [
        {
          'buyerId': 2,
          'buyerName': 'Bob Smith',
          'sellerId': 1,
          'items': [
            {
              'itemId': 1,
              'itemName': 'MacBook Pro 13-inch',
              'quantity': 1,
              'unitPrice': 1299.99,
              'totalPrice': 1299.99,
            }
          ],
          'totalAmount': 1299.99,
          'status': 'pending',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'buyerId': 3,
          'buyerName': 'Carol Davis',
          'sellerId': 2,
          'items': [
            {
              'itemId': 3,
              'itemName': 'Nike Air Max 270',
              'quantity': 1,
              'unitPrice': 120.00,
              'totalPrice': 120.00,
            }
          ],
          'totalAmount': 120.00,
          'status': 'confirmed',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'buyerId': 2,
          'buyerName': 'Bob Smith',
          'sellerId': 1,
          'items': [
            {
              'itemId': 2,
              'itemName': 'iPhone 13 Pro',
              'quantity': 1,
              'unitPrice': 899.99,
              'totalPrice': 899.99,
            }
          ],
          'totalAmount': 899.99,
          'status': 'completed',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
      ];

      for (final order in sampleOrders) {
        await _firestore.collection('purchase_orders').add(order);
        print('Created purchase order: ${order['buyerName']} → ${order['sellerId']}');
      }
    } catch (e) {
      print('Error creating sample purchase orders: $e');
      rethrow;
    }
  }

  /// Create sample notifications
  static Future<void> _createSampleNotifications() async {
    try {
      print('Creating sample notifications...');
      
      final List<Map<String, dynamic>> sampleNotifications = [
        {
          'userId': 1,
          'type': 'purchase_request',
          'title': 'New Purchase Request',
          'message': 'Bob Smith wants to purchase: MacBook Pro 13-inch (Total: \$1299.99)',
          'data': {
            'buyerId': 2,
            'buyerName': 'Bob Smith',
            'items': [
              {
                'itemId': 1,
                'itemName': 'MacBook Pro 13-inch',
                'quantity': 1,
                'unitPrice': 1299.99,
                'totalPrice': 1299.99,
              }
            ],
            'totalAmount': 1299.99,
          },
          'isRead': false,
          'createdAt': Timestamp.now(),
        },
        {
          'userId': 2,
          'type': 'transaction_update',
          'title': 'Transaction Update',
          'message': 'Carol Davis confirmed the transaction',
          'data': {
            'transactionStatus': 'confirmed',
            'otherUserId': 3,
            'otherUserName': 'Carol Davis',
          },
          'isRead': false,
          'createdAt': Timestamp.now(),
        },
        {
          'userId': 1,
          'type': 'rating',
          'title': 'New Rating Received',
          'message': 'Bob Smith rated you 5.0 stars',
          'data': {
            'rating': 5.0,
            'comment': 'Great seller, fast communication!',
            'raterId': 2,
            'raterName': 'Bob Smith',
          },
          'isRead': true,
          'createdAt': Timestamp.now(),
        },
      ];

      for (final notification in sampleNotifications) {
        await _firestore.collection('notifications').add(notification);
        print('Created notification: ${notification['title']}');
      }
    } catch (e) {
      print('Error creating sample notifications: $e');
      rethrow;
    }
  }

  /// Create sample chat rooms
  static Future<void> _createSampleChatRooms() async {
    try {
      print('💬 Creating sample chat rooms...');
      
      final List<Map<String, dynamic>> sampleChatRooms = [
        {
          'participants': ['1', '2'],
          'itemId': '1',
          'createdAt': Timestamp.now(),
          'lastMessageTime': Timestamp.now(),
          'lastMessageId': null,
        },
        {
          'participants': ['2', '3'],
          'itemId': '3',
          'createdAt': Timestamp.now(),
          'lastMessageTime': Timestamp.now(),
          'lastMessageId': null,
        },
      ];

      for (final chatRoom in sampleChatRooms) {
        await _firestore.collection('chat_rooms').add(chatRoom);
        print('Created chat room: ${chatRoom['participants'].join(' ↔ ')}');
      }
    } catch (e) {
      print('Error creating sample chat rooms: $e');
      rethrow;
    }
  }

  /// Create sample messages
  static Future<void> _createSampleMessages() async {
    try {
      print('💬 Creating sample messages...');
      
      // Get the chat room IDs we just created
      final QuerySnapshot chatRooms = await _firestore.collection('chat_rooms').get();
      
      if (chatRooms.docs.isNotEmpty) {
        final String chatRoomId = chatRooms.docs.first.id;
        
        final List<Map<String, dynamic>> sampleMessages = [
          {
            'chatRoomId': chatRoomId,
            'senderId': 2,
            'content': 'Hi! Is this item still available?',
            'timestamp': Timestamp.now(),
            'read': true,
          },
          {
            'chatRoomId': chatRoomId,
            'senderId': 1,
            'content': 'Yes, it\'s still available! Are you interested?',
            'timestamp': Timestamp.now(),
            'read': true,
          },
          {
            'chatRoomId': chatRoomId,
            'senderId': 2,
            'content': 'Great! What\'s the best price you can do?',
            'timestamp': Timestamp.now(),
            'read': false,
          },
        ];

        for (final message in sampleMessages) {
          await _firestore.collection('messages').add(message);
          print('Created message: ${message['content']}');
        }
      }
    } catch (e) {
      print('Error creating sample messages: $e');
      rethrow;
    }
  }

  /// Clear all collections (for testing/reset)
  static Future<void> clearAllCollections() async {
    try {
      print('🗑️ Clearing all collections...');
      
      // Clear purchase orders
      final QuerySnapshot purchaseOrders = await _firestore.collection('purchase_orders').get();
      for (QueryDocumentSnapshot doc in purchaseOrders.docs) {
        await doc.reference.delete();
      }
      
      // Clear notifications
      final QuerySnapshot notifications = await _firestore.collection('notifications').get();
      for (QueryDocumentSnapshot doc in notifications.docs) {
        await doc.reference.delete();
      }
      
      // Clear chat rooms
      final QuerySnapshot chatRooms = await _firestore.collection('chat_rooms').get();
      for (QueryDocumentSnapshot doc in chatRooms.docs) {
        await doc.reference.delete();
      }
      
      // Clear messages
      final QuerySnapshot messages = await _firestore.collection('messages').get();
      for (QueryDocumentSnapshot doc in messages.docs) {
        await doc.reference.delete();
      }
      
      // Clear users
      final QuerySnapshot users = await _firestore.collection('users').get();
      for (QueryDocumentSnapshot doc in users.docs) {
        await doc.reference.delete();
      }
      
      // Clear items
      final QuerySnapshot items = await _firestore.collection('items').get();
      for (QueryDocumentSnapshot doc in items.docs) {
        await doc.reference.delete();
      }
      
      print('All collections cleared successfully!');
    } catch (e) {
      print('Error clearing collections: $e');
      rethrow;
    }
  }

  /// Check if database is properly initialized
  static Future<bool> isDatabaseInitialized() async {
    try {
      // Check if we have users, items, and at least one notification
      final QuerySnapshot users = await _firestore.collection('users').limit(1).get();
      final QuerySnapshot items = await _firestore.collection('items').limit(1).get();
      final QuerySnapshot notifications = await _firestore.collection('notifications').limit(1).get();
      
      return users.docs.isNotEmpty && items.docs.isNotEmpty && notifications.docs.isNotEmpty;
    } catch (e) {
      print('Error checking database initialization: $e');
      return false;
    }
  }

  /// Print Firestore index creation instructions
  static void printIndexInstructions() {
    print('\n📋 FIRESTORE INDEX SETUP REQUIRED');
    print('=====================================');
    print('To fix query performance issues, create these indexes in Firebase Console:');
    print('');
    print('🔗 Go to: https://console.firebase.google.com/project/YOUR_PROJECT_ID/firestore/indexes');
    print('');
    print('📊 Required Indexes:');
    print('');
    print('1. NOTIFICATIONS Collection:');
    print('   - Collection: notifications');
    print('   - Fields: userId (Ascending), createdAt (Descending)');
    print('');
    print('2. MESSAGES Collection:');
    print('   - Collection: messages');
    print('   - Fields: chatRoomId (Ascending), read (Ascending), senderId (Ascending)');
    print('');
    print('3. PURCHASE_ORDERS Collection:');
    print('   - Collection: purchase_orders');
    print('   - Fields: buyerId (Ascending), createdAt (Descending)');
    print('   - Fields: sellerId (Ascending), createdAt (Descending)');
    print('');
    print('4. CHAT_ROOMS Collection:');
    print('   - Collection: chat_rooms');
    print('   - Fields: participants (Arrays), createdAt (Descending)');
    print('');
    print('⚡ After creating indexes, the app will work much faster!');
    print('=====================================\n');
  }

  /// Test queries to trigger index creation links
  static Future<void> testQueriesForIndexes() async {
    try {
      print('🧪 Testing queries to identify required indexes...');

      // Test notifications query
      try {
        await _firestore
            .collection('notifications')
            .where('userId', isEqualTo: 1)
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();
        print('Notifications query works');
      } catch (e) {
        print('Notifications query needs index: $e');
      }

      // Test messages query
      try {
        await _firestore
            .collection('messages')
            .where('chatRoomId', isEqualTo: 'test')
            .where('read', isEqualTo: false)
            .orderBy('senderId')
            .limit(1)
            .get();
        print('Messages query works');
      } catch (e) {
        print('Messages query needs index: $e');
      }

      // Test purchase orders query
      try {
        await _firestore
            .collection('purchase_orders')
            .where('buyerId', isEqualTo: 1)
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();
        print('Purchase orders query works');
      } catch (e) {
        print('Purchase orders query needs index: $e');
      }

    } catch (e) {
      print('Error testing queries: $e');
    }
  }

  /// Test profile functionality
  static Future<void> testProfileFunctionality() async {
    try {
      print('🧪 Testing profile functionality...');

      // First, let's check what's actually in the database
      print('📊 Current Database State:');
      
      // Check all users
      final QuerySnapshot allUsers = await _firestore.collection('users').get();
      print('   - Total Users: ${allUsers.docs.length}');
      for (var doc in allUsers.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('     * User ${data['userId']}: ${data['name']} - Sold: ${data['itemSold']?.length ?? 0}, Bought: ${data['itemBought']?.length ?? 0}');
      }
      
      // Check all items
      final QuerySnapshot allItems = await _firestore.collection('items').get();
      print('   - Total Items: ${allItems.docs.length}');
      for (var doc in allItems.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('     * Item ${data['itemId']}: ${data['itemName']} - Seller: ${data['sellerId']}, Sold: ${data['isSold']}, Buyer: ${data['buyerId'] ?? 'None'}');
      }

      print('\n🔍 Testing Individual Profiles:');

      // Test Alice's profile (userId: 1)
      final Users? alice = await _databaseService.getUserById(1);
      if (alice != null) {
        print('👤 Alice Johnson:');
        print('   - Item Sold Count: ${alice.itemSold.length}');
        print('   - Item Bought Count: ${alice.itemBought.length}');
        
        // Test sold items
        final List<Items> soldItems = await _databaseService.getSoldItemsBySellerId(1);
        print('   - Actual Sold Items: ${soldItems.length}');
        for (var item in soldItems) {
          print('     * ${item.itemName} (ID: ${item.itemId})');
        }
        
        // Test bought items
        final List<Items> boughtItems = await _databaseService.getBoughtItemsByBuyerId(1);
        print('   - Actual Bought Items: ${boughtItems.length}');
        for (var item in boughtItems) {
          print('     * ${item.itemName} (ID: ${item.itemId})');
        }
      }

      // Test Bob's profile (userId: 2)
      final Users? bob = await _databaseService.getUserById(2);
      if (bob != null) {
        print('👤 Bob Smith:');
        print('   - Item Sold Count: ${bob.itemSold.length}');
        print('   - Item Bought Count: ${bob.itemBought.length}');
        
        // Test sold items
        final List<Items> soldItems = await _databaseService.getSoldItemsBySellerId(2);
        print('   - Actual Sold Items: ${soldItems.length}');
        for (var item in soldItems) {
          print('     * ${item.itemName} (ID: ${item.itemId})');
        }
        
        // Test bought items
        final List<Items> boughtItems = await _databaseService.getBoughtItemsByBuyerId(2);
        print('   - Actual Bought Items: ${boughtItems.length}');
        for (var item in boughtItems) {
          print('     * ${item.itemName} (ID: ${item.itemId})');
        }
      }

      print('Profile functionality test completed!');
    } catch (e) {
      print('Error testing profile functionality: $e');
    }
  }

  /// Fix database inconsistencies by updating items to match user arrays
  static Future<void> fixDatabaseInconsistencies() async {
    try {
      print('🔧 Fixing database inconsistencies...');

      // Get all users
      final QuerySnapshot allUsers = await _firestore.collection('users').get();
      
      for (var userDoc in allUsers.docs) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final int userId = userData['userId'] as int;
        final List<dynamic> itemSold = userData['itemSold'] ?? [];
        final List<dynamic> itemBought = userData['itemBought'] ?? [];
        
        print('👤 Fixing user $userId (${userData['name']})...');
        
        // Update items that should be marked as sold by this user
        for (var itemId in itemSold) {
          final QuerySnapshot itemSnapshot = await _firestore
              .collection('items')
              .where('itemId', isEqualTo: itemId)
              .get();
          
          if (itemSnapshot.docs.isNotEmpty) {
            final itemDoc = itemSnapshot.docs.first;
            final itemData = itemDoc.data() as Map<String, dynamic>;
            
            // Only update if not already marked as sold by this user
            if (itemData['sellerId'] == userId && itemData['isSold'] != true) {
              await itemDoc.reference.update({
                'isSold': true,
                'buyerId': itemBought.contains(itemId) ? userId : null, // Set buyerId if user also bought it
              });
              print('   Marked item $itemId as sold by user $userId');
            }
          }
        }
        
        // Update items that should be marked as bought by this user
        for (var itemId in itemBought) {
          final QuerySnapshot itemSnapshot = await _firestore
              .collection('items')
              .where('itemId', isEqualTo: itemId)
              .get();
          
          if (itemSnapshot.docs.isNotEmpty) {
            final itemDoc = itemSnapshot.docs.first;
            final itemData = itemDoc.data() as Map<String, dynamic>;
            
            // Update buyerId if not already set
            if (itemData['buyerId'] != userId) {
              await itemDoc.reference.update({
                'buyerId': userId,
                'isSold': true, // If someone bought it, it should be marked as sold
              });
              print('   Marked item $itemId as bought by user $userId');
            }
          }
        }
      }
      
      print('Database inconsistencies fixed!');
    } catch (e) {
      print('Error fixing database inconsistencies: $e');
    }
  }

  /// Fix user arrays to match actual item states
  static Future<void> fixUserArrays() async {
    try {
      print('🔧 Fixing user arrays to match actual item states...');

      // Get all users
      final QuerySnapshot allUsers = await _firestore.collection('users').get();
      
      for (var userDoc in allUsers.docs) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final int userId = userData['userId'] as int;
        final String userName = userData['name'] as String;
        
        print('👤 Fixing user $userId ($userName)...');
        
        // Get actual sold items for this user
        final QuerySnapshot soldItems = await _firestore
            .collection('items')
            .where('sellerId', isEqualTo: userId)
            .where('isSold', isEqualTo: true)
            .get();
        
        // Get actual bought items for this user
        final QuerySnapshot boughtItems = await _firestore
            .collection('items')
            .where('buyerId', isEqualTo: userId)
            .get();
        
        // Extract item IDs
        final List<int> actualSoldIds = soldItems.docs
            .map((doc) => (doc.data() as Map<String, dynamic>)['itemId'] as int)
            .toList();
        
        final List<int> actualBoughtIds = boughtItems.docs
            .map((doc) => (doc.data() as Map<String, dynamic>)['itemId'] as int)
            .toList();
        
        // Update user document with correct arrays
        await userDoc.reference.update({
          'itemSold': actualSoldIds,
          'itemBought': actualBoughtIds,
        });
        
        print('   Updated itemSold: $actualSoldIds');
        print('   Updated itemBought: $actualBoughtIds');
      }
      
      print('User arrays fixed!');
    } catch (e) {
      print('Error fixing user arrays: $e');
    }
  }
}
