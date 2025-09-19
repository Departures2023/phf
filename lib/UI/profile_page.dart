import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/users.dart';
import '../models/items.dart';

class ProfilePage extends StatefulWidget {
  final Users currentUser;
  
  const ProfilePage({super.key, required this.currentUser});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0; // Default to "Currently Selling" (index 0)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: _selectedIndex);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(212, 237, 211, 190),
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          // Profile Header
          _buildProfileHeader(),
          
          // Tab Bar
          _buildTabBar(),
          
          // Content Area
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildItemList('selling'), // Currently Selling
                _buildItemList('sold'), // Item Sold
                _buildItemList('bought'), // Item Bought
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      margin: EdgeInsets.all(16.w),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 35.r,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: CircleAvatar(
                radius: 32.r,
                backgroundColor: Colors.white,
                backgroundImage: widget.currentUser.avatar.isNotEmpty
                    ? NetworkImage(widget.currentUser.avatar)
                    : null,
                child: widget.currentUser.avatar.isEmpty
                    ? Icon(Icons.person, size: 40.sp, color: Theme.of(context).colorScheme.primary)
                    : null,
              ),
            ),
            
            SizedBox(width: 15.w),
            
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Ratings Row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.currentUser.name,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Seller Rating
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sell, color: Colors.orange, size: 14.sp),
                            SizedBox(width: 2.w),
                            Text(
                              '${widget.currentUser.sellerCredit.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 8.w),
                        // Buyer Rating
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shopping_cart, color: Colors.blue, size: 14.sp),
                            SizedBox(width: 2.w),
                            Text(
                              '${widget.currentUser.buyerCredit.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    // ID and Item Counts Row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'ID: ${widget.currentUser.userId}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                        // Items Sold Count
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 14.sp),
                            SizedBox(width: 2.w),
                            Text(
                              '${widget.currentUser.itemSold.length}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 8.w),
                        // Items Bought Count
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.book_outlined, color: Colors.purple, size: 14.sp),
                            SizedBox(width: 2.w),
                            Text(
                              '${widget.currentUser.itemBought.length}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            // Settings Icon
            IconButton(
              onPressed: () {
                // Navigate to settings
              },
              icon: Icon(Icons.settings, size: 24.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      elevation: 2,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Theme.of(context).colorScheme.primary,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 14.sp),
        tabs: [
          Tab(text: 'Currently Selling'),
          Tab(text: 'Item Sold'),
          Tab(text: 'Item Bought'),
        ],
      ),
    );
  }

  Widget _buildItemList(String type) {
    // This would typically fetch data from your database
    // For now, we'll show mock data or empty state
    List<Items> items = _getItemsByType(type);
    
    if (items.isEmpty) {
      return _buildEmptyState(type);
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(items[index]);
      },
    );
  }

  List<Items> _getItemsByType(String type) {
    // Mock data - replace with actual database queries
    switch (type) {
      case 'sold':
        return []; // Items sold by user
      case 'bought':
        return []; // Items bought by user
      case 'selling':
        return []; // Items currently being sold by user
      default:
        return [];
    }
  }

  Widget _buildEmptyState(String type) {
    String message;
    IconData icon;
    
    switch (type) {
      case 'sold':
        message = 'No items sold yet';
        icon = Icons.sell;
        break;
      case 'bought':
        message = 'No items bought yet';
        icon = Icons.shopping_cart;
        break;
      case 'selling':
        message = 'No items currently on sale';
        icon = Icons.store;
        break;
      default:
        message = 'No items found';
        icon = Icons.inventory;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Items item) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            // Item Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                child: item.image.isNotEmpty
                    ? Image.network(
                        item.image,
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image_not_supported, color: Colors.white, size: 30.sp);
                        },
                      )
                    : Icon(Icons.image, color: Colors.white, size: 30.sp),
              ),
            ),
            
            SizedBox(width: 12.w),
            
            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.category,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      if (item.isSold)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Sold',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileBlock extends StatelessWidget {
  const ProfileBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// class TopNavBar extends StatelessWidget {
//   final List<NavigationCategory> topNavBarList;
//   const TopNavBar({required Key key, required this.topNavBarList}) : super(key: key);

//   Widget _gridViewBuilder(BuildContext context, NavigationCategory category) {
//     return InkWell(
//       onTap: () {
//         print('Navigation clicked: ${category.name}');
//         // You can add navigation logic here
//         // Navigator.pushNamed(context, category.route ?? '/category/${category.id}');
//       },
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           // Display category icon from Google Cloud Storage URL
//           Image.network(
//             category.image, // This should be the Google Cloud Storage URL for the category icon
//             width: ScreenUtil().setWidth(95),
//             height: ScreenUtil().setHeight(95),
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) {
//               return Icon(Icons.category, size: 40);
//             },
//           ),
//           SizedBox(height: 4),
//           Text(
//             category.name, // Category name like "Electronics", "Clothing", etc.
//             style: TextStyle(fontSize: 12),
//             textAlign: TextAlign.center,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: ScreenUtil().setHeight(320),
//       padding: EdgeInsets.all(3.0),
//       child: GridView.count(
//         crossAxisCount: 4,
//         padding: EdgeInsets.all(5.0),
//         children: topNavBarList.map((category) {
//           return _gridViewBuilder(context, category);
//         }).toList(),
//       ),
//     );
//   }
// }