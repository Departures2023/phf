import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home_page.dart';
import 'cart_page.dart';
import 'sell_page.dart';
import 'profile_page.dart';
import 'chat_page.dart';
import 'notifications_page.dart';
import '../models/users.dart';
import '../sevices/database_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Menu extends StatefulWidget {
  final Users currentUser;
  
  const Menu({super.key, required this.currentUser});

  @override
  State<Menu> createState() => _MenuState();
}

// Global key to access menu state
final GlobalKey<_MenuState> menuKey = GlobalKey<_MenuState>();

class _MenuState extends State<Menu> {
  final DatabaseService _databaseService = DatabaseService();
  int _cartItemCount = 0;

  late final List pageItems;

  int currentIndex = 0;
  var currentPage;

  List<BottomNavigationBarItem> get bottomItems => [
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
    BottomNavigationBarItem(
      icon: Stack(
        children: [
          Icon(CupertinoIcons.shopping_cart),
          if (_cartItemCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '$_cartItemCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      label: 'Cart',
    ),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.bell), label: 'Notifications'),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.chat_bubble_2), label: 'Chat'),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.camera_fill), label: 'Sell'),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.person), label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize page items with the current user
    pageItems = [
      HomePage(currentUser: widget.currentUser),
      CartPage(currentUser: widget.currentUser),
      NotificationsPage(currentUser: widget.currentUser),
      ChatPage(currentUser: widget.currentUser),
      SellPage(currentUser: widget.currentUser),
      ProfilePage(currentUser: widget.currentUser),
    ];
    currentPage = pageItems[currentIndex];
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    try {
      int count = await _databaseService.getCartItemCount(widget.currentUser.userId);
      setState(() {
        _cartItemCount = count;
      });
    } catch (e) {
      print('Error loading cart count: $e');
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      currentIndex = index;
      currentPage = pageItems[index];
    });
    
    // Refresh cart count when cart tab is selected
    if (index == 1) {
      _loadCartCount();
    }
  }

  // Method to refresh cart count from other pages
  void refreshCartCount() {
    _loadCartCount();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(750, 1334));
    return Scaffold(
      key: menuKey,
      backgroundColor: Color.fromARGB(212, 237, 211, 190),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey[600],
        items: bottomItems,
        onTap: _onTabTapped
      ),
      body: currentPage
    );
  }
}