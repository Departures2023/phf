import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/users.dart';
import '../models/items.dart';
import '../sevices/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../utils/sample_data.dart';
import 'login_page.dart';
import '../utils/database_setup.dart';
import '../utils/demo_data_generator.dart';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh user data when the page becomes visible
    _refreshUserData();
  }

  @override
  void didUpdateWidget(ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh when widget is updated (e.g., when navigating back from transaction page)
    _refreshUserData();
  }


  Future<void> _refreshUserData() async {
    try {
      // Get the current user ID from SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? currentUserId = prefs.getInt('currentUserId');
      
      if (currentUserId != null && currentUserId != _currentUser.userId) {
        // Only update if the user ID has changed
        print('🔄 User changed from ${_currentUser.userId} to $currentUserId, refreshing profile...');
        final Users? newUser = await DatabaseService().getUserById(currentUserId);
        if (newUser != null && mounted) {
          setState(() {
            _currentUser = newUser;
          });
          print('✅ Profile updated for user: ${newUser.name}');
        }
      } else if (currentUserId == null) {
        // User logged out, but we're still showing profile - this shouldn't happen
        print('⚠️ No current user ID found, but profile page is still showing');
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check for user changes on every build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserData();
    });
    
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
                              fontSize: 26.sp,
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
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text('Seller rating', style: TextStyle(fontSize: 15.sp, color: Colors.grey[800])),
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
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text('Buyer rating', style: TextStyle(fontSize: 15.sp, color: Colors.grey[800])),
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
                              color: Colors.grey[800],
                              fontSize: 18.sp,
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
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text('Items sold', style: TextStyle(fontSize: 15.sp, color: Colors.grey[800])),
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
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text('Items bought', style: TextStyle(fontSize: 15.sp, color: Colors.grey[800])),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            // Refresh Button
            IconButton(
              onPressed: _refreshUserData,
              icon: Icon(Icons.refresh, size: 24.sp),
              tooltip: 'Refresh Profile',
            ),
            // Settings Icon
            PopupMenuButton<String>(
              icon: Icon(Icons.settings, size: 24.sp),
              onSelected: (value) async {
                if (value == 'sample_data') {
                  await _addSampleData();
                } else if (value == 'init_database') {
                  await _initializeDatabase();
                } else if (value == 'generate_demo_data') {
                  await _generateDemoData();
                } else if (value == 'clear_database') {
                  await _clearDatabase();
                } else if (value == 'test_indexes') {
                  await _testIndexes();
                } else if (value == 'test_profile') {
                  await _testProfileData();
                } else if (value == 'fix_database') {
                  await _fixDatabaseIssues();
                } else if (value == 'fix_user_arrays') {
                  await _fixUserArrays();
                } else if (value == 'logout') {
                  await _handleLogout();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'sample_data',
                  child: Row(
                    children: [
                      Icon(Icons.add_box, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text('Add Sample Data'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'init_database',
                  child: Row(
                    children: [
                      Icon(Icons.storage, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text('Initialize Database'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'generate_demo_data',
                  child: Row(
                    children: [
                      Icon(Icons.video_library, size: 20.sp, color: Colors.deepPurple),
                      SizedBox(width: 8.w),
                      Text('🎬 Generate Demo Data', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'test_indexes',
                  child: Row(
                    children: [
                      Icon(Icons.speed, size: 20.sp, color: Colors.blue),
                      SizedBox(width: 8.w),
                      Text('Test Indexes'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'test_profile',
                  child: Row(
                    children: [
                      Icon(Icons.person_search, size: 20.sp, color: Colors.green),
                      SizedBox(width: 8.w),
                      Text('Test Profile Data'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'fix_database',
                  child: Row(
                    children: [
                      Icon(Icons.build, size: 20.sp, color: Colors.orange),
                      SizedBox(width: 8.w),
                      Text('Fix Database Issues'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'fix_user_arrays',
                  child: Row(
                    children: [
                      Icon(Icons.sync, size: 20.sp, color: Colors.purple),
                      SizedBox(width: 8.w),
                      Text('Fix User Arrays'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear_database',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, size: 20.sp, color: Colors.red),
                      SizedBox(width: 8.w),
                      Text('Clear Database', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20.sp, color: Colors.black87),
                      SizedBox(width: 8.w),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
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

  Future<void> _addSampleData() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20.w),
              Text('Adding sample data...'),
            ],
          ),
        ),
      );
      
      await SampleData.addAllSampleData();
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sample data added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding sample data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _initializeDatabase() async {
    try {
      // Show confirmation dialog
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Initialize Database',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'This will create all required collections and sample data for the app to work properly.\n\nThis includes:\n• Sample users\n• Sample items\n• Sample purchase orders\n• Sample notifications\n• Sample chat rooms\n\nDo you want to continue?',
            style: TextStyle(fontSize: 16.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text('Initialize'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20.w),
              Text('Initializing database...'),
            ],
          ),
        ),
      );

      await DatabaseSetup.initializeDatabase();

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Database initialized successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog if it's open
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error initializing database: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearDatabase() async {
    try {
      // Show confirmation dialog
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Clear Database',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          content: Text(
            '⚠️ WARNING: This will delete ALL data from:\n• Purchase orders\n• Notifications\n• Chat rooms\n• Messages\n\nThis action cannot be undone!\n\nAre you sure you want to continue?',
            style: TextStyle(fontSize: 16.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Clear All'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20.w),
              Text('Clearing database...'),
            ],
          ),
        ),
      );

      await DatabaseSetup.clearAllCollections();

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Database cleared successfully!'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      // Close loading dialog if it's open
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing database: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _testIndexes() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20.w),
              Text('Testing queries...'),
            ],
          ),
        ),
      );

      // Test queries and print instructions
      await DatabaseSetup.testQueriesForIndexes();
      DatabaseSetup.printIndexInstructions();

      // Close loading dialog
      Navigator.of(context).pop();

      // Show instructions dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Firestore Index Setup',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'To fix query performance issues, create these indexes in Firebase Console:',
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 16.h),
                Text(
                  '🔗 Go to: Firebase Console → Firestore → Indexes',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12.h),
                Text(
                  '📊 Required Indexes:',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text(
                  '1. NOTIFICATIONS:\n   userId (Ascending), createdAt (Descending)',
                  style: TextStyle(fontSize: 14.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  '2. MESSAGES:\n   chatRoomId (Ascending), read (Ascending), senderId (Ascending)',
                  style: TextStyle(fontSize: 14.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  '3. PURCHASE_ORDERS:\n   buyerId (Ascending), createdAt (Descending)\n   sellerId (Ascending), createdAt (Descending)',
                  style: TextStyle(fontSize: 14.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  '4. CHAT_ROOMS:\n   participants (Arrays), createdAt (Descending)',
                  style: TextStyle(fontSize: 14.sp),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    '⚡ After creating indexes, the app will work much faster!',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog if it's open
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error testing indexes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showDisclaimerIfFirstTime() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool hasSeenDisclaimer = prefs.getBool('hasSeenDisclaimer') ?? false;
      
      if (!hasSeenDisclaimer) {
        await prefs.setBool('hasSeenDisclaimer', true);
        
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text(
                'Important Notice',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.orange,
                    size: 48.sp,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'This app does NOT handle any transactions or payments.',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '• All transactions are between users directly\n'
                    '• No payment processing is included\n'
                    '• Users are responsible for their own transactions\n'
                    '• Please arrange payment methods separately\n'
                    '• Use this app only for item discovery and communication',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Text(
                      'Please ensure you understand this before using the app.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'I Understand',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      print('Error showing disclaimer: $e');
    }
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
                              // Show disclaimer for first-time login
                              await _showDisclaimerIfFirstTime();
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
        unselectedLabelColor: Colors.grey[800],
        labelStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 18.sp),
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
      key: ValueKey('${_currentUser.userId}_$type'), // Force rebuild when user changes
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
      final int userId = _currentUser.userId;
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
              fontSize: 20.sp,
              color: Colors.grey[800],
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
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.category,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20.sp,
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
                              fontSize: 14.sp,
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

  Future<void> _testProfileData() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16.w),
              Text('Testing profile data...'),
            ],
          ),
        ),
      );

      await DatabaseSetup.testProfileFunctionality();
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show results dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Profile Test Results'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Profile data testing completed! Check the console for detailed results.',
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Text(
                    '✅ This will help verify that profile counts match actual item lists!',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.green[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog if it's open
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error testing profile data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fixDatabaseIssues() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16.w),
              Text('Fixing database issues...'),
            ],
          ),
        ),
      );

      await DatabaseSetup.fixDatabaseInconsistencies();
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show results dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Database Fix Results'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Database inconsistencies have been fixed! Check the console for detailed results.',
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Text(
                    '🔧 Items have been updated to match user arrays. Try testing profile data again!',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog if it's open
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fixing database issues: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fixUserArrays() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16.w),
              Text('Fixing user arrays...'),
            ],
          ),
        ),
      );

      await DatabaseSetup.fixUserArrays();
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show results dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('User Arrays Fixed'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'User arrays have been updated to match actual item states! Check the console for detailed results.',
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.purple[200]!),
                  ),
                  child: Text(
                    '🔄 User itemSold and itemBought arrays now match the actual items in the database!',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.purple[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog if it's open
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fixing user arrays: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _generateDemoData() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20.h),
              Text('Generating comprehensive demo data...'),
              SizedBox(height: 12.h),
              Text(
                'This will create users, items, transactions, chats, and notifications',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      await DemoDataGenerator.generateAllDemoData();
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28.sp),
              SizedBox(width: 12.w),
              Text('Demo Data Ready!'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🎉 Your app is now loaded with comprehensive demo data!',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),
                _buildDemoDataSummary('👥 Users', '8 realistic student profiles'),
                _buildDemoDataSummary('📦 Items', '20 items across all categories'),
                _buildDemoDataSummary('💳 Transactions', '7 transactions (various statuses)'),
                _buildDemoDataSummary('💬 Chats', '4 chat conversations'),
                _buildDemoDataSummary('🔔 Notifications', '5 notification examples'),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.purple[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎬 Demo Video Tips:',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[800],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '• Login as any user (emily.chen@university.edu, demo123)\n'
                        '• Show home page with diverse items\n'
                        '• Demonstrate chat functionality\n'
                        '• Show transactions and notifications\n'
                        '• Highlight the rating system',
                        style: TextStyle(fontSize: 12.sp, color: Colors.purple[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Got it!'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog if it's open
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating demo data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDemoDataSummary(String icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: 16.sp)),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Clear user session
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('currentUserId');
        await prefs.remove('hasSeenDisclaimer');

        // Navigate to login page and remove all previous routes
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logging out: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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