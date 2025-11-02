import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/users.dart';
import '../sevices/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'transaction_page.dart';

class NotificationsPage extends StatefulWidget {
  final Users currentUser;
  
  const NotificationsPage({super.key, required this.currentUser});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Users _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.currentUser;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshUserData();
  }

  Future<void> _refreshUserData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? currentUserId = prefs.getInt('currentUserId');
      
      if (currentUserId != null && currentUserId != _currentUser.userId) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(212, 237, 211, 190),
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: _markAllAsRead,
            icon: Icon(Icons.done_all),
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: _currentUser.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading notifications',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      // Retry by rebuilding the widget
                      setState(() {});
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }
          
          // Sort notifications by createdAt in descending order (newest first)
          final notifications = snapshot.data!.docs;
          notifications.sort((a, b) {
            final Map<String, dynamic> aData = a.data() as Map<String, dynamic>;
            final Map<String, dynamic> bData = b.data() as Map<String, dynamic>;
            final Timestamp aTime = aData['createdAt'] ?? Timestamp.now();
            final Timestamp bTime = bData['createdAt'] ?? Timestamp.now();
            return bTime.compareTo(aTime);
          });
          
          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64.sp,
            color: Colors.grey[600],
          ),
          SizedBox(height: 16.h),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You\'ll receive notifications when someone wants to buy your items',
            style: TextStyle(
              fontSize: 20.sp,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(QueryDocumentSnapshot notificationDoc) {
    final data = notificationDoc.data() as Map<String, dynamic>;
    final bool isRead = data['isRead'] ?? false;
    final String title = data['title'] ?? '';
    final String message = data['message'] ?? '';
    final String type = data['type'] ?? '';
    final Timestamp createdAt = data['createdAt'] ?? Timestamp.now();
    
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: isRead ? 2 : 4,
      color: isRead ? Colors.white : Colors.blue[50],
      child: InkWell(
        onTap: () => _handleNotificationTap(notificationDoc),
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification icon
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: _getNotificationColor(type),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  _getNotificationIcon(type),
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              
              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _formatTime(createdAt),
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'purchase_request':
        return Colors.green;
      case 'transaction_update':
        return Colors.blue;
      case 'rating':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'purchase_request':
        return Icons.shopping_cart;
      case 'transaction_update':
        return Icons.receipt;
      case 'rating':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationTap(QueryDocumentSnapshot notificationDoc) async {
    final data = notificationDoc.data() as Map<String, dynamic>;
    final String type = data['type'] ?? '';
    
    // Mark as read
    await notificationDoc.reference.update({'isRead': true});
    
    if (type == 'purchase_request') {
      // Navigate to transaction page
      final Map<String, dynamic> notificationData = data['data'] ?? {};
      final int buyerId = notificationData['buyerId'] ?? 0;
      final String buyerName = notificationData['buyerName'] ?? '';
      final List<dynamic> items = notificationData['items'] ?? [];
      final double totalAmount = (notificationData['totalAmount'] ?? 0.0).toDouble();
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionPage(
              currentUser: _currentUser,
              otherUserId: buyerId,
              otherUserName: buyerName,
              items: items,
              totalAmount: totalAmount,
              transactionType: 'seller',
            ),
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final QuerySnapshot notifications = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: _currentUser.userId)
          .where('isRead', isEqualTo: false)
          .get();
      
      final WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      await batch.commit();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('All notifications marked as read')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking notifications as read: $e')),
        );
      }
    }
  }
}
