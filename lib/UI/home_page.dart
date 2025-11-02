import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phf/sevices/service_methods.dart';
import 'package:phf/sevices/database_service.dart';
import 'package:phf/models/items.dart';
import 'package:phf/models/navigation_category.dart';
import 'package:phf/models/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';
import 'menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final Users currentUser;
  
  const HomePage({super.key, required this.currentUser});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String homePageContent = 'loading...';
  final DatabaseService _databaseService = DatabaseService();
  late Users _currentUser;
  String? _selectedCategory; // Track selected category for filtering

  @override
  void initState() {
    _currentUser = widget.currentUser;
    getHomePageContent().then((val){
      setState(() {
        homePageContent = val.toString();
      });
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh user data when the page becomes visible
    _refreshUserData();
  }

  Future<void> _refreshUserData() async {
    try {
      // Get the current user ID from SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? currentUserId = prefs.getInt('currentUserId');
      
      if (currentUserId != null && currentUserId != _currentUser.userId) {
        // User has changed, fetch the new user data
        final Users? newUser = await DatabaseService().getUserById(currentUserId);
        if (newUser != null && mounted) {
          setState(() {
            _currentUser = newUser;
          });
        }
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }

  // Filter items by selected category
  List<Items> _filterItemsByCategory(List<Items> allItems) {
    if (_selectedCategory == null || _selectedCategory == 'All') {
      return allItems;
    }
    return allItems.where((item) => item.category == _selectedCategory).toList();
  }

  // Handle category selection
  void _onCategorySelected(String categoryName) {
    setState(() {
      _selectedCategory = categoryName;
    });
    print('🔍 Filtering items by category: $categoryName');
  }

  Future<void> _addToCart(Items item) async {
    try {
      await _databaseService.addToCart(_currentUser.userId, item);
      Navigator.of(context).pop(); // Close the dialog
      
      // Refresh cart count in the parent menu
      if (context.mounted) {
        // Find the parent Menu widget and refresh cart count
        final menuState = menuKey.currentState;
        if (menuState != null) {
          menuState.refreshCartCount();
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.itemName} added to cart!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () {
              // Navigate to cart page (index 1)
              DefaultTabController.of(context).animateTo(1);
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to cart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image, size: 40, color: Colors.grey[600]),
                                      SizedBox(height: 4),
                                      Text(
                                        item.itemName,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
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
                              onPressed: () => _addToCart(item),
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

  Future<Users?> _getSellerInfo(int sellerId) async {
    try {
      return await DatabaseService().getUserById(sellerId);
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
      if (seller.userId == _currentUser.userId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You cannot message yourself')),
        );
        return;
      }

      // Create or find chat room
      String chatRoomId = await _createOrFindChatRoom(item, seller);
      
      // Debug logging
      print('💬 Creating Chat Room:');
      print('  - Current User ID: ${_currentUser.userId}');
      print('  - Current User Name: ${_currentUser.name}');
      print('  - Seller ID: ${seller.userId}');
      print('  - Seller Name: ${seller.name}');
      print('  - Chat Room ID: $chatRoomId');
      
      // Navigate to chat
      Navigator.of(context).pop(); // Close item details dialog
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatDetailPage(
            chatRoom: ChatRoom(
              id: chatRoomId,
              participants: [_currentUser.userId.toString(), seller.userId.toString()],
              item: item,
              otherUser: seller,
              lastMessage: null,
              unreadCount: 0,
            ),
            currentUser: _currentUser,
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
      // Check if chat room already exists for this item and participants
      QuerySnapshot existingRooms = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .where('participants', arrayContains: _currentUser.userId.toString())
          .get();

      // Filter to find rooms with both participants and the same item
      for (var doc in existingRooms.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<String> participants = List<String>.from(data['participants']);
        String itemId = data['itemId'] ?? '';
        
        if (participants.contains(seller.userId.toString()) && itemId == item.itemId.toString()) {
          return doc.id;
        }
      }

      // Create new chat room
      DocumentReference chatRoomRef = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .add({
        'participants': [_currentUser.userId.toString(), seller.userId.toString()],
        'itemId': item.itemId.toString(),
        'createdAt': Timestamp.now(),
        'lastMessageTime': Timestamp.now(),
        'lastMessageId': null,
      });

      print('Created chat room ${chatRoomRef.id} between user ${_currentUser.userId} (${_currentUser.name}) and seller ${seller.userId} (${seller.name}) for item ${item.itemId}');
      
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
        title: Text('Grin Market'),
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
                // Add "Show All" option at the beginning
                List<NavigationCategory> categoriesWithAll = [
                  NavigationCategory(
                    id: 'all',
                    name: 'All',
                    image: '',
                    route: null,
                  ),
                  ...categorySnapshot.data!,
                ];
                return TopNavBar(
                  key: ValueKey('topNav'),
                  topNavBarList: categoriesWithAll,
                  onCategorySelected: _onCategorySelected,
                  selectedCategory: _selectedCategory,
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
                  List<Items> allItems = itemsSnapshot.data!;
                  List<Items> items = _filterItemsByCategory(allItems);
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
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Container(
                                                color: Colors.grey[200],
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                        : null,
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.image, size: 60, color: Colors.grey[600]),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      item.itemName,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[600],
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              );
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
  final Function(String) onCategorySelected;
  final String? selectedCategory;
  
  const TopNavBar({
    required Key key, 
    required this.topNavBarList,
    required this.onCategorySelected,
    this.selectedCategory,
  }) : super(key: key);

  Widget _gridViewBuilder(BuildContext context, NavigationCategory category) {
    return InkWell(
      onTap: () {
        print('Navigation clicked: ${category.name}');
        onCategorySelected(category.name);
      },
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: selectedCategory == category.name 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: selectedCategory == category.name
              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Display category icon with fallback
            Container(
              width: ScreenUtil().setWidth(50),
              height: ScreenUtil().setHeight(50),
              child: category.image.isNotEmpty
                  ? Image.network(
                      category.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _getCategoryIcon(category.name);
                      },
                    )
                  : _getCategoryIcon(category.name),
            ),
            SizedBox(height: 1.5),
            Text(
              category.name, // Category name like "Electronics", "Clothing", etc.
              style: TextStyle(
                fontSize: 11,
                color: selectedCategory == category.name
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black,
                fontWeight: selectedCategory == category.name
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCategoryIcon(String categoryName) {
    IconData iconData;
    Color iconColor = Colors.grey[600]!;
    
    switch (categoryName.toLowerCase()) {
      case 'all':
        iconData = Icons.grid_view;
        iconColor = Colors.green;
        break;
      case 'class items':
        iconData = Icons.school;
        iconColor = Colors.blue;
        break;
      case 'clothing':
        iconData = Icons.checkroom;
        iconColor = Colors.purple;
        break;
      case 'daily necessities':
        iconData = Icons.home;
        iconColor = Colors.orange;
        break;
      case 'electronics':
        iconData = Icons.devices;
        iconColor = Colors.green;
        break;
      case 'food':
        iconData = Icons.restaurant;
        iconColor = Colors.red;
        break;
      case 'furniture':
        iconData = Icons.chair;
        iconColor = Colors.brown;
        break;
      case 'house':
        iconData = Icons.home_work;
        iconColor = Colors.teal;
        break;
      case 'transportation':
        iconData = Icons.directions_car;
        iconColor = Colors.indigo;
        break;
      default:
        iconData = Icons.category;
        iconColor = Colors.grey;
    }
    
    return Icon(
      iconData,
      size: 40,
      color: iconColor,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(300), // Increased height to prevent overflow
      padding: EdgeInsets.all(12),
      child: GridView.count(
        crossAxisCount: 4,
        childAspectRatio: 1.1, // Better spacing for decorations
        padding: EdgeInsets.all(8),
        children: topNavBarList.map((category) {
          return _gridViewBuilder(context, category);
        }).toList(),
      ),
    );
  }
}