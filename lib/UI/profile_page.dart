import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/users.dart';
import '../models/items.dart';
import '../sevices/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  final Users currentUser;
  
  const ProfilePage({super.key, required this.currentUser});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0; // Default to "Currently Selling" (index 0)
  late Users _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.currentUser;
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
            GestureDetector(
              onTap: _showAvatarOptions,
              child: CircleAvatar(
                radius: 46.r,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: CircleAvatar(
                  radius: 42.r,
                  backgroundColor: Colors.white,
                  backgroundImage: _currentUser.avatar.isNotEmpty
                      ? NetworkImage(_currentUser.avatar)
                      : null,
                  child: _currentUser.avatar.isEmpty
                      ? Icon(Icons.person, size: 52.sp, color: Theme.of(context).colorScheme.primary)
                      : null,
                ),
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
                            _currentUser.name,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Seller Rating
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sell, color: Colors.orange, size: 25.sp),
                            SizedBox(width: 2.w),
                            Text(
                              '${_currentUser.sellerCredit.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text('Seller rating', style: TextStyle(fontSize: 11.sp, color: Colors.grey[700])),
                          ],
                        ),
                        SizedBox(width: 8.w),
                        // Buyer Rating
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shopping_cart, color: Colors.blue, size: 25.sp),
                            SizedBox(width: 2.w),
                            Text(
                              '${_currentUser.buyerCredit.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text('Buyer rating', style: TextStyle(fontSize: 11.sp, color: Colors.grey[700])),
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
                            'ID: ${_currentUser.userId}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                        // Items Sold Count
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 25.sp),
                            SizedBox(width: 2.w),
                            Text(
                              '${_currentUser.itemSold.length}',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text('Items sold', style: TextStyle(fontSize: 11.sp, color: Colors.grey[700])),
                          ],
                        ),
                        SizedBox(width: 8.w),
                        // Items Bought Count
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.book_outlined, color: Colors.purple, size: 25.sp),
                            SizedBox(width: 2.w),
                            Text(
                              '${_currentUser.itemBought.length}',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text('Items bought', style: TextStyle(fontSize: 11.sp, color: Colors.grey[700])),
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

  Future<void> _showAvatarOptions() async {
    // Check if user is logged in (not the default sample user)
    final bool isLoggedIn = _currentUser.userId != 1;
    
    if (!isLoggedIn) {
      // Show login/register dialog
      _showAuthDialog();
      return;
    }
    
    // Show options for logged in user
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Avatar Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.upload),
                title: Text('Upload New Avatar'),
                onTap: () {
                  Navigator.of(context).pop();
                  _uploadAvatar();
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () {
                  Navigator.of(context).pop();
                  _logout();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    
    if (file == null) return;
    
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20.w),
              Text('Uploading avatar...'),
            ],
          ),
        ),
      );
      
      // Upload to Firebase Storage
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child('avatars')
          .child('${_currentUser.userId}.jpg');
      
      await ref.putFile(File(file.path));
      final String avatarUrl = await ref.getDownloadURL();
      
      // Update user in Firestore
      final Users updatedUser = _currentUser.copyWith(avatar: avatarUrl);
      await DatabaseService().updateUser(updatedUser);
      
      // Update local state
      setState(() {
        _currentUser = updatedUser;
      });
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Avatar updated successfully!')),
      );
      
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading avatar: $e')),
      );
    }
  }

  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUserId');
    
    // Reset to default user
    setState(() {
      _currentUser = Users(
        userId: 1,
        name: "Sample User",
        password: "password",
        email: "user@example.com",
        avatar: "",
        buyerCredit: 4.2,
        sellerCredit: 3.8,
        itemSold: [1, 2, 3, 4, 5],
        itemBought: [6, 7, 8],
      );
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully')),
    );
  }

  Future<void> _showAuthDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    bool isRegister = true;
    bool uploadAvatar = false;
    File? pickedAvatarFile;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setLocalState) {
          return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Login / Register', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      ChoiceChip(
                        label: Text('Register'),
                        selected: isRegister,
                        onSelected: (_) => setLocalState(() => isRegister = true),
                      ),
                      SizedBox(width: 8.w),
                      ChoiceChip(
                        label: Text('Login'),
                        selected: !isRegister,
                        onSelected: (_) => setLocalState(() => isRegister = false),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  if (isRegister)
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  if (isRegister) ...[
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Switch(
                          value: uploadAvatar,
                          onChanged: (v) => setLocalState(() => uploadAvatar = v),
                        ),
                        Text('Upload avatar now'),
                      ],
                    ),
                    if (uploadAvatar)
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 85);
                              if (file != null) {
                                setLocalState(() => pickedAvatarFile = File(file.path));
                              }
                            },
                            child: Text('Choose Image'),
                          ),
                          SizedBox(width: 10.w),
                          if (pickedAvatarFile != null)
                            Text('Selected', style: TextStyle(color: Colors.green)),
                        ],
                      ),
                  ],
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel'),
                      ),
                      SizedBox(width: 8.w),
                      ElevatedButton(
                        onPressed: () async {
                          final String email = emailController.text.trim();
                          final String password = passwordController.text.trim();
                          if (email.isEmpty || password.isEmpty || (isRegister && nameController.text.trim().isEmpty)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please fill all fields')),
                            );
                            return;
                          }
                          try {
                            Users signedIn;
                            if (isRegister) {
                              String avatarUrl = '';
                              if (uploadAvatar && pickedAvatarFile != null) {
                                final int newId = DateTime.now().millisecondsSinceEpoch;
                                final Reference ref = FirebaseStorage.instance.ref().child('avatars').child('$newId.jpg');
                                await ref.putFile(pickedAvatarFile!);
                                avatarUrl = await ref.getDownloadURL();
                                final Users newUser = Users(
                                  userId: newId,
                                  name: nameController.text.trim(),
                                  password: password,
                                  email: email,
                                  avatar: avatarUrl,
                                  buyerCredit: 0.0,
                                  sellerCredit: 0.0,
                                  itemSold: [],
                                  itemBought: [],
                                );
                                DatabaseService().addUser(newUser);
                                signedIn = newUser;
                              } else {
                                final int newId = DateTime.now().millisecondsSinceEpoch;
                                final Users newUser = Users(
                                  userId: newId,
                                  name: nameController.text.trim(),
                                  password: password,
                                  email: email,
                                  avatar: '',
                                  buyerCredit: 0.0,
                                  sellerCredit: 0.0,
                                  itemSold: [],
                                  itemBought: [],
                                );
                                DatabaseService().addUser(newUser);
                                signedIn = newUser;
                              }
                            } else {
                              final Users? fetched = await DatabaseService().getUserByEmailAndPassword(email, password);
                              if (fetched == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Invalid credentials')),
                                );
                                return;
                              }
                              signedIn = fetched;
                            }

                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.setInt('currentUserId', signedIn.userId);
                            if (mounted) {
                              setState(() { _currentUser = signedIn; });
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Welcome, ${signedIn.name}')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        });
      },
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
    return FutureBuilder<List<Items>>(
      future: _getItemsByType(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading items: ${snapshot.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        
        List<Items> items = snapshot.data ?? [];
        
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
      },
    );
  }

  Future<List<Items>> _getItemsByType(String type) async {
    try {
      final String userId = _currentUser.userId.toString();
      switch (type) {
        case 'sold':
          return await DatabaseService().getSoldItemsBySellerId(userId);
        case 'bought':
          return await DatabaseService().getBoughtItemsByBuyerId(userId);
        case 'selling':
          final allItems = await DatabaseService().getItemsBySellerId(userId);
          // Filter out sold items to show only currently selling
          return allItems.where((item) => !item.isSold).toList();
        default:
          return [];
      }
    } catch (e) {
      print('Error fetching items: $e');
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