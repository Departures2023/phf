import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phf/models/users.dart';
import 'package:phf/models/items.dart';
import 'package:firebase_storage/firebase_storage.dart';

const String usersCollection = 'users';
const String itemsCollection = 'items';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _usersCollection;
  late final CollectionReference _itemsCollection;

  DatabaseService() {
    _usersCollection = _firestore.collection(usersCollection).withConverter<Users>(
      fromFirestore: (snapshot, _) => Users.fromJson(snapshot.data()!), 
      toFirestore: (user, _) => user.toJson()
    );
    
    _itemsCollection = _firestore.collection(itemsCollection).withConverter<Items>(
      fromFirestore: (snapshot, _) => Items.fromJson(snapshot.data()!), 
      toFirestore: (item, _) => item.toJson()
    );
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
          .orderBy('launchTime', descending: true)
          .limit(50) // Limit to 50 items for homepage
          .get();
      
      List<Items> items = snapshot.docs.map((doc) => Items.fromJson(doc.data() as Map<String, dynamic>)).toList();
      
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
  Future<List<Items>> getItemsBySellerId(String sellerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(itemsCollection)
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('launchTime', descending: true)
          .get();
      
      List<Items> items = snapshot.docs.map((doc) => Items.fromJson(doc.data() as Map<String, dynamic>)).toList();
      return items;
    } catch (e) {
      print('Error fetching items by seller: $e');
      return [];
    }
  }

  // Get sold items by seller ID
  Future<List<Items>> getSoldItemsBySellerId(String sellerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(itemsCollection)
          .where('sellerId', isEqualTo: sellerId)
          .where('isSold', isEqualTo: true)
          .orderBy('launchTime', descending: true)
          .get();
      
      List<Items> items = snapshot.docs.map((doc) => Items.fromJson(doc.data() as Map<String, dynamic>)).toList();
      return items;
    } catch (e) {
      print('Error fetching sold items: $e');
      return [];
    }
  }

  // Get bought items by buyer ID
  Future<List<Items>> getBoughtItemsByBuyerId(String buyerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(itemsCollection)
          .where('buyerId', isEqualTo: buyerId)
          .orderBy('launchTime', descending: true)
          .get();
      
      List<Items> items = snapshot.docs.map((doc) => Items.fromJson(doc.data() as Map<String, dynamic>)).toList();
      return items;
    } catch (e) {
      print('Error fetching bought items: $e');
      return [];
    }
  }
}