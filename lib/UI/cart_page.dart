import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/users.dart';
import '../sevices/database_service.dart';
import 'menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatefulWidget {
  final Users currentUser;
  
  const CartPage({super.key, required this.currentUser});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final DatabaseService _databaseService = DatabaseService();
  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh cart items when the page becomes visible
    _refreshUserAndLoadCart();
  }

  Future<void> _refreshUserAndLoadCart() async {
    try {
      // Get the current user ID from SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? currentUserId = prefs.getInt('currentUserId');
      
      if (currentUserId != null) {
        // Load cart items for the current user
        await _loadCartItemsForUser(currentUserId);
      }
    } catch (e) {
      print('Error refreshing user and loading cart: $e');
    }
  }

  Future<void> _loadCartItemsForUser(int userId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<CartItem> items = await _databaseService.getCartItems(userId);
      setState(() {
        _cartItems = items;
        _totalPrice = _calculateTotalPrice();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading cart items: $e');
    }
  }

  Future<void> _loadCartItems() async {
    // Get current user ID from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? currentUserId = prefs.getInt('currentUserId');
    
    if (currentUserId != null) {
      await _loadCartItemsForUser(currentUserId);
    }
  }

  double _calculateTotalPrice() {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  Future<void> _removeItem(CartItem item) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? currentUserId = prefs.getInt('currentUserId');
      
      if (currentUserId != null) {
        await _databaseService.removeFromCart(currentUserId, item.itemId);
        await _loadCartItems();
        
        // Refresh cart count in the parent menu
        if (context.mounted) {
          final menuState = menuKey.currentState;
          if (menuState != null) {
            menuState.refreshCartCount();
          }
        }
        
        _showSuccessSnackBar('Item removed from cart');
      }
    } catch (e) {
      _showErrorSnackBar('Error removing item: $e');
    }
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? currentUserId = prefs.getInt('currentUserId');
      
      if (currentUserId != null) {
        await _databaseService.updateCartItemQuantity(
          currentUserId, 
          item.itemId, 
          newQuantity
        );
        await _loadCartItems();
        
        // Refresh cart count in the parent menu
        if (context.mounted) {
          final menuState = menuKey.currentState;
          if (menuState != null) {
            menuState.refreshCartCount();
          }
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error updating quantity: $e');
    }
  }

  Future<void> _clearCart() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? currentUserId = prefs.getInt('currentUserId');
      
      if (currentUserId != null) {
        await _databaseService.clearCart(currentUserId);
        await _loadCartItems();
        
        // Refresh cart count in the parent menu
        if (context.mounted) {
          final menuState = menuKey.currentState;
          if (menuState != null) {
            menuState.refreshCartCount();
          }
        }
        
        _showSuccessSnackBar('Cart cleared');
      }
    } catch (e) {
      _showErrorSnackBar('Error clearing cart: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showCheckoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Checkout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Items: ${_cartItems.length}'),
            Text('Total Price: \$${_totalPrice.toStringAsFixed(2)}'),
            SizedBox(height: 16),
            Text('This will initiate the purchase process. You will be connected with sellers to complete the transactions.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processCheckout();
            },
            child: Text('Proceed'),
          ),
        ],
      ),
    );
  }

  Future<void> _processCheckout() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? currentUserId = prefs.getInt('currentUserId');
      
      if (currentUserId == null) {
        _showErrorSnackBar('User not found. Please login again.');
        return;
      }

      // Get current user data
      final Users? currentUser = await _databaseService.getUserById(currentUserId);
      if (currentUser == null) {
        _showErrorSnackBar('User data not found. Please login again.');
        return;
      }

      // Create purchase orders and notify sellers
      await _createPurchaseOrdersAndNotifySellers(currentUser);
      
      // Clear the cart after successful checkout
      await _clearCart();
      
      _showSuccessSnackBar('Purchase completed! Sellers have been notified.');
    } catch (e) {
      _showErrorSnackBar('Error processing checkout: $e');
    }
  }

  Future<void> _createPurchaseOrdersAndNotifySellers(Users buyer) async {
    try {
      // Group cart items by seller
      Map<int, List<CartItem>> itemsBySeller = {};
      for (var item in _cartItems) {
        if (!itemsBySeller.containsKey(item.sellerId)) {
          itemsBySeller[item.sellerId] = [];
        }
        itemsBySeller[item.sellerId]!.add(item);
      }

      // Create purchase orders and notifications for each seller
      for (var sellerId in itemsBySeller.keys) {
        final sellerItems = itemsBySeller[sellerId]!;
        
        // Create purchase order
        await _createPurchaseOrder(buyer, sellerId, sellerItems);
        
        // Create notification for seller
        await _createSellerNotification(buyer, sellerId, sellerItems);
      }
    } catch (e) {
      print('Error creating purchase orders and notifications: $e');
      rethrow;
    }
  }

  Future<void> _createPurchaseOrder(Users buyer, int sellerId, List<CartItem> items) async {
    try {
      final double totalAmount = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      
      await FirebaseFirestore.instance.collection('purchase_orders').add({
        'buyerId': buyer.userId,
        'buyerName': buyer.name,
        'sellerId': sellerId,
        'items': items.map((item) => {
          'itemId': item.itemId,
          'itemName': item.itemName,
          'quantity': item.quantity,
          'unitPrice': item.price,
          'totalPrice': item.totalPrice,
        }).toList(),
        'totalAmount': totalAmount,
        'status': 'pending', // pending, confirmed, completed, cancelled
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error creating purchase order: $e');
      rethrow;
    }
  }

  Future<void> _createSellerNotification(Users buyer, int sellerId, List<CartItem> items) async {
    try {
      final double totalAmount = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      final String itemNames = items.map((item) => item.itemName).join(', ');
      
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': sellerId,
        'type': 'purchase_request',
        'title': 'New Purchase Request',
        'message': '${buyer.name} wants to purchase: $itemNames (Total: \$${totalAmount.toStringAsFixed(2)})',
        'data': {
          'buyerId': buyer.userId,
          'buyerName': buyer.name,
          'items': items.map((item) => {
            'itemId': item.itemId,
            'itemName': item.itemName,
            'quantity': item.quantity,
            'unitPrice': item.price,
            'totalPrice': item.totalPrice,
          }).toList(),
          'totalAmount': totalAmount,
        },
        'isRead': false,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error creating seller notification: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(212, 237, 211, 190),
      appBar: AppBar(
        title: Text('Shopping Cart'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(
              onPressed: _clearCart,
              icon: Icon(Icons.clear_all),
              tooltip: 'Clear Cart',
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? _buildEmptyCart()
              : _buildCartContent(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add some items to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to home page (index 0)
              DefaultTabController.of(context).animateTo(0);
            },
            child: Text('Browse Items'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              CartItem item = _cartItems[index];
              return _buildCartItemCard(item);
            },
          ),
        ),
        
        // Checkout Section
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total (${_cartItems.length} items):',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${_totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showCheckoutDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Proceed to Checkout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            // Item Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: item.image.isNotEmpty
                    ? Image.network(
                        item.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image, size: 40, color: Colors.grey);
                        },
                      )
                    : Icon(Icons.image, size: 40, color: Colors.grey),
              ),
            ),
            
            SizedBox(width: 12),
            
            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'by ${item.sellerName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Quantity Controls
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: item.quantity > 1
                          ? () => _updateQuantity(item, item.quantity - 1)
                          : null,
                      icon: Icon(Icons.remove, size: 20),
                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _updateQuantity(item, item.quantity + 1),
                      icon: Icon(Icons.add, size: 20),
                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '\$${item.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            
            // Remove Button
            IconButton(
              onPressed: () => _removeItem(item),
              icon: Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Remove from cart',
            ),
          ],
        ),
      ),
    );
  }
}