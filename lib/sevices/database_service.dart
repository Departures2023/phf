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
    _usersCollection.add(user);
  }

  // Get all items for homepage display
  Stream<QuerySnapshot> getItems() {
    return _itemsCollection.where('isSold', isEqualTo: false).orderBy('launchTime', descending: true).snapshots();
  }

  // Get items as a one-time query (for non-streaming use)
  Future<List<Items>> getHomePageItems() async {
    try {
      QuerySnapshot snapshot = await _itemsCollection
          .where('isSold', isEqualTo: false)
          .orderBy('launchTime', descending: true)
          .limit(50) // Limit to 50 items for homepage
          .get();
      
      List<Items> items = snapshot.docs.map((doc) => doc.data() as Items).toList();
      
      // Get download URLs for item images from Firebase Storage
      for (Items item in items) {
        if (item.image.isNotEmpty && !item.image.startsWith('http')) {
          // If image is a Firebase Storage path (not a URL), get the download URL
          try {
            Reference ref = FirebaseStorage.instance.ref().child(item.image);
            String downloadUrl = await ref.getDownloadURL();
            // Update the item with the download URL
            item = item.copyWith(image: downloadUrl);
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
    _itemsCollection.add(item);
  }
}