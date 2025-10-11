import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phf/sevices/service_methods.dart';
import 'package:phf/sevices/database_service.dart';
import 'package:phf/models/items.dart';
import 'package:phf/models/navigation_category.dart';
import 'package:phf/models/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';

class HomePage extends StatefulWidget {
  final Users currentUser;
  
  const HomePage({super.key, required this.currentUser});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String homePageContent = 'loading...';

  @override
  void initState() {
    getHomePageContent().then((val){
      setState(() {
        homePageContent = val.toString();
      });
    });
    super.initState();
  }

  void _showItemDetails(BuildContext context, Items item) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Image
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: item.image.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.image_not_supported, size: 50);
                              },
                            ),
                          )
                        : Icon(Icons.image, size: 50),
                  ),
                  SizedBox(height: 16),
                  
                  // Item Details
                  Text(
                    item.itemName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  Text(
                    'Category: ${item.category}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  // Description
                  if (item.description.isNotEmpty) ...[
                    Text(
                      'Description:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  
                  // Seller Information
                  FutureBuilder<Users?>(
                    future: _getSellerInfo(item.sellerId),
                    builder: (context, sellerSnapshot) {
                      if (sellerSnapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Loading seller info...'),
                            ],
                          ),
                        );
                      }
                      
                      if (sellerSnapshot.hasData && sellerSnapshot.data != null) {
                        final seller = sellerSnapshot.data!;
                        return Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Seller Information',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.white,
                                      backgroundImage: seller.avatar.isNotEmpty
                                          ? NetworkImage(seller.avatar)
                                          : null,
                                      child: seller.avatar.isEmpty
                                          ? Icon(Icons.person, size: 20, color: Theme.of(context).colorScheme.primary)
                                          : null,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          seller.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.sell, color: Colors.orange, size: 16),
                                            SizedBox(width: 4),
                                            Text(
                                              'Seller: ${seller.sellerCredit.toStringAsFixed(1)}',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            SizedBox(width: 12),
                                            Icon(Icons.shopping_cart, color: Colors.blue, size: 16),
                                            SizedBox(width: 4),
                                            Text(
                                              'Buyer: ${seller.buyerCredit.toStringAsFixed(1)}',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Seller information not available',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  
                  // Action Buttons
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _messageSeller(context, item),
                              icon: Icon(Icons.message, size: 16),
                              label: Text('Message'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                // TODO: Add to cart functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Added to cart!')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text('Add to Cart'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Users?> _getSellerInfo(String sellerId) async {
    try {
      final int userId = int.parse(sellerId);
      return await DatabaseService().getUserById(userId);
    } catch (e) {
      print('Error fetching seller info: $e');
      return null;
    }
  }

  Future<void> _messageSeller(BuildContext context, Items item) async {
    try {
      // Get seller info
      Users? seller = await _getSellerInfo(item.sellerId);
      if (seller == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to find seller information')),
        );
        return;
      }

      // Check if current user is the seller
      if (seller.userId == widget.currentUser.userId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You cannot message yourself')),
        );
        return;
      }

      // Create or find chat room
      String chatRoomId = await _createOrFindChatRoom(item, seller);
      
      // Navigate to chat
      Navigator.of(context).pop(); // Close item details dialog
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatDetailPage(
            chatRoom: ChatRoom(
              id: chatRoomId,
              participants: [widget.currentUser.userId.toString(), seller.userId.toString()],
              item: item,
              otherUser: seller,
              lastMessage: null,
              unreadCount: 0,
            ),
            currentUser: widget.currentUser,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting chat: $e')),
      );
    }
  }

  Future<String> _createOrFindChatRoom(Items item, Users seller) async {
    try {
      // Check if chat room already exists
      QuerySnapshot existingRooms = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .where('participants', arrayContains: widget.currentUser.userId.toString())
          .where('itemId', isEqualTo: item.itemId.toString())
          .get();

      if (existingRooms.docs.isNotEmpty) {
        return existingRooms.docs.first.id;
      }

      // Create new chat room
      DocumentReference chatRoomRef = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .add({
        'participants': [widget.currentUser.userId.toString(), seller.userId.toString()],
        'itemId': item.itemId.toString(),
        'createdAt': Timestamp.now(),
        'lastMessageTime': Timestamp.now(),
      });

      return chatRoomRef.id;
    } catch (e) {
      print('Error creating/finding chat room: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('PHF'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          // Top Navigation Bar with Categories
          FutureBuilder<List<NavigationCategory>>(
            future: getNavigationCategories(),
            builder: (context, categorySnapshot) {
              if (categorySnapshot.hasData) {
                return TopNavBar(
                  key: ValueKey('topNav'),
                  topNavBarList: categorySnapshot.data!,
                );
              } else {
                return Container(
                  height: ScreenUtil().setHeight(250),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
          // Items Grid - Reduced gap by removing padding
          Expanded(
            child: FutureBuilder<List<Items>>(
              future: getHomePageContent(),
              builder: (context, itemsSnapshot) {
                if (itemsSnapshot.hasData) {
                  List<Items> items = itemsSnapshot.data!;
                  return GridView.builder(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 16), // Reduced top padding
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return GestureDetector(
                        onTap: () => _showItemDetails(context, item),
                        child: Card(
                          elevation: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                  child: item.image.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                                          child: Image.network(
                                            item.image,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Icon(Icons.image_not_supported, size: 50);
                                            },
                                          ),
                                        )
                                      : Icon(Icons.image, size: 50),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.itemName,
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '\$${item.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TopNavBar extends StatelessWidget {
  final List<NavigationCategory> topNavBarList;
  const TopNavBar({required Key key, required this.topNavBarList}) : super(key: key);

  Widget _gridViewBuilder(BuildContext context, NavigationCategory category) {
    return InkWell(
      onTap: () {
        print('Navigation clicked: ${category.name}');
        // You can add navigation logic here
        // Navigator.pushNamed(context, category.route ?? '/category/${category.id}');
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Display category icon from Google Cloud Storage URL
          Image.network(
            category.image, // This should be the Google Cloud Storage URL for the category icon
            width: ScreenUtil().setWidth(60), //95
            height: ScreenUtil().setHeight(60),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.category, size: 23); //40
            },
          ),
          SizedBox(height: 2.3),
          Text(
            category.name, // Category name like "Electronics", "Clothing", etc.
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(280), // Increased height to prevent blocking
      padding: EdgeInsets.all(12),
      child: GridView.count(
        crossAxisCount: 4,
        childAspectRatio: 1.2, // Better spacing
        padding: EdgeInsets.all(8),
        children: topNavBarList.map((category) {
          return _gridViewBuilder(context, category);
        }).toList(),
      ),
    );
  }
}