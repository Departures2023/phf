import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home_page.dart';
import 'cart_page.dart';
import 'sell_page.dart';
import 'profile_page.dart';
import 'chat_page.dart';
import '../models/users.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Menu extends StatefulWidget {
  final Users currentUser;
  
  const Menu({super.key, required this.currentUser});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final List<BottomNavigationBarItem> bottomItems = [
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.shopping_cart), label: 'Cart'),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.chat_bubble_2), label: 'Chat'),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.camera_fill), label: 'Sell'),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.person), label: 'Profile'),
  ];

  late final List pageItems;

  int currentIndex = 0;
  var currentPage;

  @override
  void initState() {
    super.initState();
    // Initialize page items with the current user
    pageItems = [
      HomePage(currentUser: widget.currentUser),
      CartPage(),
      ChatPage(currentUser: widget.currentUser),
      SellPage(currentUser: widget.currentUser),
      ProfilePage(currentUser: widget.currentUser),
    ];
    currentPage = pageItems[currentIndex];
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(750, 1334));
    return Scaffold(
      backgroundColor: Color.fromARGB(212, 237, 211, 190),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey[600],
        items: bottomItems,
        onTap: (index) {
          setState(() {
            currentIndex = index;
            currentPage = pageItems[index];
          });
        }
      ),
      body: currentPage
    );
  }
}