import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phf/models/users.dart';
import 'package:phf/models/items.dart';
import 'package:phf/models/cart_item.dart';
import 'package:firebase_storage/firebase_storage.dart';

const String usersCollection = 'users';
const String itemsCollection = 'items';
const String cartCollection = 'cart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _usersCollection;
  late final CollectionReference _itemsCollection;
  late final CollectionReference _cartCollection;

  DatabaseService() {
    _usersCollection = _firestore.collection(usersCollection).withConverter<Users>(
      fromFirestore: (snapshot, _) => Users.fromJson(snapshot.data()!), 
      toFirestore: (user, _) => user.toJson()
    );
    
    _itemsCollection = _firestore.collection(itemsCollection).withConverter<Items>(
      fromFirestore: (snapshot, _) => Items.fromJson(snapshot.data()!), 
      toFirestore: (item, _) => item.toJson()
    );
    
    _cartCollection = _firestore.collection(cartCollection);
  }

  Stream<QuerySnapshot> getUsers() {
    return _usersCollection.snapshots();
  }

  void addUser(Users user) async {
    // Use userId as document id to simplify lookups and updates
    await _firestore.collection(usersCollection).doc(user.userId.toString()).set(user.toJson());
  }

  Future<Users?> getUserById(int userId) async {
    final doc = await _firestore.collection(usersCollection).doc(userId.toString()).get();
    if (!doc.exists || doc.data() == null) return null;
    return Users.fromJson(doc.data()!);
  }

  Future<Users?> getUserByEmailAndPassword(String email, String password) async {
    final snapshot = await _firestore
        .collection(usersCollection)
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return Users.fromJson(snapshot.docs.first.data());
  }

  // Get user by email only (for checking if email exists)
  Future<Users?> getUserByEmail(String email) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return Users.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  Future<void> updateUser(Users user) async {
    await _firestore.collection(usersCollection).doc(user.userId.toString()).set(user.toJson(), SetOptions(merge: true));
  }

  // Get all items for homepage display
  Stream<QuerySnapshot> getItems() {
    return _itemsCollection.where('isSold', isEqualTo: false).orderBy('launchTime', descending: true).snapshots();
  }

  // Get items as a one-time query (for non-streaming use)
  Future<List<Items>> getHomePageItems() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(itemsCollection)
          .where('isSold', isEqualTo: false)
          .get();
      
      List<Items> items = snapshot.docs.map((doc) => Items.fromJson(doc.data() as Map<String, dynamic>)).toList();
      
      // Sort by launchTime in descending order (newest first)
      items.sort((a, b) => b.launchTime.compareTo(a.launchTime));
      
      // Limit to 50 items for homepage
      if (items.length > 50) {
        items = items.take(50).toList();
      }
      
      // Get download URLs for item images from Firebase Storage
      for (int i = 0; i < items.length; i++) {
        Items item = items[i];
        if (item.image.isNotEmpty && !item.image.startsWith('http')) {
          // If image is a Firebase Storage path (not a URL), get the download URL
          try {
            Reference ref = FirebaseStorage.instance.ref().child(item.image);
            String downloadUrl = await ref.getDownloadURL();
            // Update the item with the download URL
            items[i] = item.copyWith(image: downloadUrl);
          } catch (e) {
            print('Error getting download URL for item ${item.itemId}: $e');
            // Keep the original image path, UI will handle the error
          }
        }
      }
      
      return items;
    } catch (e) {
      print('Error fetching items: $e');
      return [];
    }
  }

  void addItem(Items item) async {
    await _firestore.collection(itemsCollection).doc(item.itemId.toString()).set(item.toJson());
  }

  // Get items by seller ID
  Future<List<Items>> getItemsBySellerId(int sellerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(itemsCollection)
          .where('sellerId', isEqualTo: sellerId)
          .get();
      
      List<Items> items = snapshot.docs.map((doc) => Items.fromJson(doc.data() as Map<String, dynamic>)).toList();
      
      // Sort by launchTime in descending order (newest first)
      items.sort((a, b) => b.launchTime.compareTo(a.launchTime));
      
      return items;
    } catch (e) {
      print('Error fetching items by seller: $e');
      return [];
    }
  }

  // Get sold items by seller ID
  Future<List<Items>> getSoldItemsBySellerId(int sellerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(itemsCollection)
          .where('sellerId', isEqualTo: sellerId)
          .where('isSold', isEqualTo: true)
          .get();
      
      List<Items> items = snapshot.docs.map((doc) => Items.fromJson(doc.data() as Map<String, dynamic>)).toList();
      
      // Sort by launchTime in descending order (newest first)
      items.sort((a, b) => b.launchTime.compareTo(a.launchTime));
      
      return items;
    } catch (e) {
      print('Error fetching sold items: $e');
      return [];
    }
  }

  // Get bought items by buyer ID
  Future<List<Items>> getBoughtItemsByBuyerId(int buyerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(itemsCollection)
          .where('buyerId', isEqualTo: buyerId)
          .get();
      
      List<Items> items = snapshot.docs.map((doc) => Items.fromJson(doc.data() as Map<String, dynamic>)).toList();
      
      // Sort by launchTime in descending order (newest first)
      items.sort((a, b) => b.launchTime.compareTo(a.launchTime));
      
      return items;
    } catch (e) {
      print('Error fetching bought items: $e');
      return [];
    }
  }

  // Cart Methods
  // Add item to user's cart
  Future<void> addToCart(int userId, Items item) async {
    try {
      // Get seller name
      Users? seller = await getUserById(item.sellerId);
      String sellerName = seller?.name ?? 'Unknown Seller';
      
      // Create cart item
      CartItem cartItem = CartItem(
        itemId: item.itemId,
        itemName: item.itemName,
        image: item.image,
        price: item.price,
        category: item.category,
        description: item.description,
        sellerId: item.sellerId,
        sellerName: sellerName,
        addedTime: Timestamp.now(),
        quantity: 1,
      );
      
      // Check if item already exists in cart
      QuerySnapshot existingItem = await _cartCollection
          .where('userId', isEqualTo: userId)
          .where('itemId', isEqualTo: item.itemId)
          .get();
      
      if (existingItem.docs.isNotEmpty) {
        // Update quantity if item already exists
        DocumentReference docRef = existingItem.docs.first.reference;
        await docRef.update({
          'quantity': FieldValue.increment(1),
        });
      } else {
        // Add new item to cart
        await _cartCollection.add({
          'userId': userId,
          ...cartItem.toJson(),
        });
      }
    } catch (e) {
      print('Error adding to cart: $e');
      throw e;
    }
  }

  // Get user's cart items
  Future<List<CartItem>> getCartItems(int userId) async {
    try {
      QuerySnapshot snapshot = await _cartCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      List<CartItem> cartItems = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return CartItem.fromJson(data);
      }).toList();
      
      // Sort by addedTime in descending order (newest first)
      cartItems.sort((a, b) => b.addedTime.compareTo(a.addedTime));
      
      return cartItems;
    } catch (e) {
      print('Error fetching cart items: $e');
      return [];
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(int userId, int itemId) async {
    try {
      QuerySnapshot snapshot = await _cartCollection
          .where('userId', isEqualTo: userId)
          .where('itemId', isEqualTo: itemId)
          .get();
      
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error removing from cart: $e');
      throw e;
    }
  }

  // Update cart item quantity
  Future<void> updateCartItemQuantity(int userId, int itemId, int quantity) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(userId, itemId);
        return;
      }
      
      QuerySnapshot snapshot = await _cartCollection
          .where('userId', isEqualTo: userId)
          .where('itemId', isEqualTo: itemId)
          .get();
      
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        await doc.reference.update({'quantity': quantity});
      }
    } catch (e) {
      print('Error updating cart quantity: $e');
      throw e;
    }
  }

  // Clear entire cart for user
  Future<void> clearCart(int userId) async {
    try {
      QuerySnapshot snapshot = await _cartCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error clearing cart: $e');
      throw e;
    }
  }

  // Get cart item count for user
  Future<int> getCartItemCount(int userId) async {
    try {
      QuerySnapshot snapshot = await _cartCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      int totalCount = 0;
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        totalCount += (data['quantity'] as int?) ?? 1;
      }
      return totalCount;
    } catch (e) {
      print('Error getting cart count: $e');
      return 0;
    }
  }

  Future<void> updateUserRating(int userId, String ratingField, double newRating) async {
    try {
      QuerySnapshot snapshot = await _usersCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({
          ratingField: newRating,
        });
      }
    } catch (e) {
      print('Error updating user rating: $e');
      rethrow;
    }
  }

  // Mark items as sold when transaction is completed
  Future<void> markItemsAsSold(List<dynamic> items, int buyerId) async {
    try {
      final WriteBatch batch = _firestore.batch();
      
      for (var itemData in items) {
        final int itemId = itemData['itemId'] as int;
        
        // Find the item document
        QuerySnapshot itemSnapshot = await _firestore
            .collection(itemsCollection)
            .where('itemId', isEqualTo: itemId)
            .get();
        
        if (itemSnapshot.docs.isNotEmpty) {
          final itemDoc = itemSnapshot.docs.first;
          final itemData = itemDoc.data() as Map<String, dynamic>;
          final int sellerId = itemData['sellerId'] as int;
          
          // Update the item
          batch.update(itemDoc.reference, {
            'isSold': true,
            'buyerId': buyerId,
          });
          
          // Update seller's itemSold array
          await _updateUserItemArray(sellerId, 'itemSold', itemId, batch);
          
          // Update buyer's itemBought array
          await _updateUserItemArray(buyerId, 'itemBought', itemId, batch);
        }
      }
      
      await batch.commit();
      print('Marked ${items.length} items as sold to buyer $buyerId');
    } catch (e) {
      print('Error marking items as sold: $e');
      rethrow;
    }
  }

  // Helper method to update user's item arrays
  Future<void> _updateUserItemArray(int userId, String arrayField, int itemId, WriteBatch batch) async {
    try {
      QuerySnapshot userSnapshot = await _firestore
          .collection(usersCollection)
          .where('userId', isEqualTo: userId)
          .get();
      
      if (userSnapshot.docs.isNotEmpty) {
        DocumentReference userRef = userSnapshot.docs.first.reference;
        batch.update(userRef, {
          arrayField: FieldValue.arrayUnion([itemId]),
        });
      }
    } catch (e) {
      print('Error updating user $arrayField array: $e');
      // Don't rethrow here as it's a helper method
    }
  }
}