import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/users.dart';
import '../sevices/database_service.dart';

class TransactionPage extends StatefulWidget {
  final Users currentUser;
  final int otherUserId;
  final String otherUserName;
  final List<dynamic> items;
  final double totalAmount;
  final String transactionType; // 'buyer' or 'seller'
  
  const TransactionPage({
    super.key,
    required this.currentUser,
    required this.otherUserId,
    required this.otherUserName,
    required this.items,
    required this.totalAmount,
    required this.transactionType,
  });

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final DatabaseService _databaseService = DatabaseService();
  String _transactionStatus = 'pending'; // pending, confirmed, completed, cancelled
  bool _hasRated = false;
  double _rating = 0.0;
  String _ratingComment = '';
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTransactionStatus();
  }

  Future<void> _loadTransactionStatus() async {
    try {
      // Find the purchase order for this transaction
      final QuerySnapshot orders = await FirebaseFirestore.instance
          .collection('purchase_orders')
          .where('buyerId', isEqualTo: widget.transactionType == 'buyer' ? widget.currentUser.userId : widget.otherUserId)
          .where('sellerId', isEqualTo: widget.transactionType == 'seller' ? widget.currentUser.userId : widget.otherUserId)
          .get();
      
      if (orders.docs.isNotEmpty) {
        final orderData = orders.docs.first.data() as Map<String, dynamic>;
        setState(() {
          _transactionStatus = orderData['status'] ?? 'pending';
        });
      }
    } catch (e) {
      print('Error loading transaction status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(212, 237, 211, 190),
      appBar: AppBar(
        title: Text(
          'Transaction Details',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTransactionHeader(),
            SizedBox(height: 20.h),
            _buildItemsList(),
            SizedBox(height: 20.h),
            _buildTransactionStatus(),
            SizedBox(height: 20.h),
            if (_transactionStatus == 'completed' && !_hasRated)
              _buildRatingSection(),
            if (_hasRated)
              _buildRatingDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.transactionType == 'buyer' ? Icons.shopping_cart : Icons.sell,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  widget.transactionType == 'buyer' ? 'Purchase Details' : 'Sale Details',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              '${widget.transactionType == 'buyer' ? 'Buying from' : 'Selling to'}: ${widget.otherUserName}',
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'Total Amount: \$${widget.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            ...widget.items.map((item) => _buildItemRow(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item['itemName'] ?? '',
              style: TextStyle(fontSize: 16.sp),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Qty: ${item['quantity'] ?? 0}',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '\$${(item['totalPrice'] ?? 0.0).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionStatus() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Status',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  _getStatusIcon(_transactionStatus),
                  color: _getStatusColor(_transactionStatus),
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  _getStatusText(_transactionStatus),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(_transactionStatus),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if (_canUpdateStatus())
              _buildStatusActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusActions() {
    return Column(
      children: [
        if (_transactionStatus == 'pending' && widget.transactionType == 'seller')
          ElevatedButton(
            onPressed: _confirmTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Confirm Transaction',
              style: TextStyle(fontSize: 16.sp),
            ),
          ),
        if (_transactionStatus == 'confirmed')
          ElevatedButton(
            onPressed: _completeTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Mark as Completed',
              style: TextStyle(fontSize: 16.sp),
            ),
          ),
        if (_transactionStatus == 'pending')
          TextButton(
            onPressed: _cancelTransaction,
            child: Text(
              'Cancel Transaction',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate ${widget.otherUserName}',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => _rating = (index + 1).toDouble()),
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 32.sp,
                  ),
                );
              }),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Comment (optional)',
                border: OutlineInputBorder(),
                hintText: 'Share your experience...',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _submitRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Submit Rating',
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingDisplay() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Rating',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                  size: 24.sp,
                );
              }),
            ),
            if (_ratingComment.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                _ratingComment,
                style: TextStyle(fontSize: 16.sp),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending Confirmation';
      case 'confirmed':
        return 'Confirmed';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  bool _canUpdateStatus() {
    return _transactionStatus == 'pending' || _transactionStatus == 'confirmed';
  }

  Future<void> _confirmTransaction() async {
    await _updateTransactionStatus('confirmed');
  }

  Future<void> _completeTransaction() async {
    await _updateTransactionStatus('completed');
  }

  Future<void> _cancelTransaction() async {
    await _updateTransactionStatus('cancelled');
  }

  Future<void> _updateTransactionStatus(String newStatus) async {
    try {
      // Find and update the purchase order
      final QuerySnapshot orders = await FirebaseFirestore.instance
          .collection('purchase_orders')
          .where('buyerId', isEqualTo: widget.transactionType == 'buyer' ? widget.currentUser.userId : widget.otherUserId)
          .where('sellerId', isEqualTo: widget.transactionType == 'seller' ? widget.currentUser.userId : widget.otherUserId)
          .get();
      
      if (orders.docs.isNotEmpty) {
        final orderData = orders.docs.first.data() as Map<String, dynamic>;
        final List<dynamic> items = orderData['items'] ?? [];
        final int buyerId = orderData['buyerId'] ?? 0;
        
        await orders.docs.first.reference.update({
          'status': newStatus,
          'updatedAt': Timestamp.now(),
        });
        
        // If transaction is completed, mark items as sold
        if (newStatus == 'completed') {
          await _databaseService.markItemsAsSold(items, buyerId);
        }
        
        setState(() {
          _transactionStatus = newStatus;
        });
        
        // Create notification for the other party
        await _createStatusNotification(newStatus);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction status updated to ${_getStatusText(newStatus)}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating transaction status: $e')),
      );
    }
  }

  Future<void> _createStatusNotification(String status) async {
    try {
      final String title = 'Transaction Update';
      String message = '';
      
      switch (status) {
        case 'confirmed':
          message = '${widget.currentUser.name} confirmed the transaction';
          break;
        case 'completed':
          message = '${widget.currentUser.name} marked the transaction as completed';
          break;
        case 'cancelled':
          message = '${widget.currentUser.name} cancelled the transaction';
          break;
      }
      
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': widget.otherUserId,
        'type': 'transaction_update',
        'title': title,
        'message': message,
        'data': {
          'transactionStatus': status,
          'otherUserId': widget.currentUser.userId,
          'otherUserName': widget.currentUser.name,
        },
        'isRead': false,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error creating status notification: $e');
    }
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a rating')),
      );
      return;
    }
    
    try {
      // Update user rating
      await _updateUserRating();
      
      // Create rating notification
      await _createRatingNotification();
      
      setState(() {
        _hasRated = true;
        _ratingComment = _commentController.text;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rating submitted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting rating: $e')),
      );
    }
  }

  Future<void> _updateUserRating() async {
    try {
      // Get current user data
      final Users? user = await _databaseService.getUserById(widget.otherUserId);
      if (user == null) return;
      
      // Calculate new rating
      final String ratingField = widget.transactionType == 'buyer' ? 'sellerCredit' : 'buyerCredit';
      final double currentRating = ratingField == 'sellerCredit' ? user.sellerCredit : user.buyerCredit;
      
      // Simple average calculation (in a real app, you'd want more sophisticated rating calculation)
      final double newRating = (currentRating + _rating) / 2;
      
      // Update user rating
      await _databaseService.updateUserRating(widget.otherUserId, ratingField, newRating);
    } catch (e) {
      print('Error updating user rating: $e');
      rethrow;
    }
  }

  Future<void> _createRatingNotification() async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': widget.otherUserId,
        'type': 'rating',
        'title': 'New Rating Received',
        'message': '${widget.currentUser.name} rated you ${_rating.toStringAsFixed(1)} stars',
        'data': {
          'rating': _rating,
          'comment': _ratingComment,
          'raterId': widget.currentUser.userId,
          'raterName': widget.currentUser.name,
        },
        'isRead': false,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error creating rating notification: $e');
    }
  }
}
