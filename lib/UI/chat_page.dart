import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/users.dart';
import '../models/items.dart';
import '../sevices/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final Users currentUser;
  
  const ChatPage({super.key, required this.currentUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(212, 237, 211, 190),
      appBar: AppBar(
        title: Text('Messages'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          // Chat List
          Expanded(
            child: _buildChatList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return FutureBuilder<List<ChatRoom>>(
      future: _getUserChatRooms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading chats: ${snapshot.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        
        List<ChatRoom> chatRooms = snapshot.data ?? [];
        
        if (chatRooms.isEmpty) {
          return _buildEmptyState();
        }
        
        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            return _buildChatRoomCard(chatRooms[index]);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64.sp,
            color: Colors.grey[700],
          ),
          SizedBox(height: 16.h),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start a conversation by clicking on an item',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomCard(ChatRoom chatRoom) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: CircleAvatar(
          radius: 30.r,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: CircleAvatar(
            radius: 28.r,
            backgroundColor: Colors.white,
            backgroundImage: chatRoom.otherUser.avatar.isNotEmpty
                ? NetworkImage(chatRoom.otherUser.avatar)
                : null,
            child: chatRoom.otherUser.avatar.isEmpty
                ? Icon(Icons.person, size: 30.sp, color: Theme.of(context).colorScheme.primary)
                : null,
          ),
        ),
        title: Text(
          chatRoom.otherUser.name,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (chatRoom.lastMessage != null) ...[
              SizedBox(height: 4.h),
              Text(
                chatRoom.lastMessage!.content,
            style: TextStyle(
              fontSize: 20.sp,
              color: Colors.grey[800],
            ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 6.h),
            ],
            Text(
              'Item: ${chatRoom.item.itemName}',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (chatRoom.lastMessage != null)
              Text(
                _formatTime(chatRoom.lastMessage!.timestamp),
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.grey[800],
                ),
              ),
            SizedBox(height: 6.h),
            if (chatRoom.unreadCount > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${chatRoom.unreadCount}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _openChat(chatRoom),
      ),
    );
  }

  Future<List<ChatRoom>> _getUserChatRooms() async {
    try {
      // Get all chat rooms where current user is a participant
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .where('participants', arrayContains: widget.currentUser.userId.toString())
          .get();
      
      List<ChatRoom> chatRooms = [];
      
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // Get the other participant
        List<String> participants = List<String>.from(data['participants']);
        String otherUserId = participants.firstWhere((id) => id != widget.currentUser.userId.toString());
        
        print('Chat room ${doc.id}: participants = $participants, current user = ${widget.currentUser.userId}, other user = $otherUserId');
        
        // Get other user info
        Users? otherUser = await DatabaseService().getUserById(int.parse(otherUserId));
        if (otherUser == null) {
          print('Could not find user with ID $otherUserId');
          continue;
        }
        
        // Get item info
        String itemId = data['itemId'];
        Items? item = await _getItemById(int.parse(itemId));
        if (item == null) continue;
        
        // Get last message
        Message? lastMessage;
        if (data['lastMessageId'] != null) {
          lastMessage = await _getMessageById(data['lastMessageId']);
        }
        
        // Count unread messages
        int unreadCount = await _getUnreadCount(doc.id, widget.currentUser.userId.toString());
        
        chatRooms.add(ChatRoom(
          id: doc.id,
          participants: participants,
          item: item,
          otherUser: otherUser,
          lastMessage: lastMessage,
          unreadCount: unreadCount,
        ));
      }
      
      // Sort by lastMessageTime in descending order (newest first)
      chatRooms.sort((a, b) {
        if (a.lastMessage == null && b.lastMessage == null) return 0;
        if (a.lastMessage == null) return 1;
        if (b.lastMessage == null) return -1;
        return b.lastMessage!.timestamp.compareTo(a.lastMessage!.timestamp);
      });
      
      return chatRooms;
    } catch (e) {
      print('Error fetching chat rooms: $e');
      return [];
    }
  }

  Future<Items?> _getItemById(int itemId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('items')
          .doc(itemId.toString())
          .get();
      
      if (doc.exists && doc.data() != null) {
        return Items.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching item: $e');
      return null;
    }
  }

  Future<Message?> _getMessageById(String messageId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('messages')
          .doc(messageId)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return Message.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching message: $e');
      return null;
    }
  }

  Future<int> _getUnreadCount(String chatRoomId, String userId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('messages')
          .where('chatRoomId', isEqualTo: chatRoomId)
          .where('senderId', isNotEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      print('Error counting unread messages: $e');
      return 0;
    }
  }

  String _formatTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _openChat(ChatRoom chatRoom) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailPage(
          chatRoom: chatRoom,
          currentUser: widget.currentUser,
        ),
      ),
    );
  }
}

class ChatDetailPage extends StatefulWidget {
  final ChatRoom chatRoom;
  final Users currentUser;
  
  const ChatDetailPage({
    super.key,
    required this.chatRoom,
    required this.currentUser,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(212, 237, 211, 190),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.chatRoom.otherUser.name,
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.chatRoom.item.itemName,
              style: TextStyle(fontSize: 18.sp, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _buildMessagesList(),
          ),
          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .where('chatRoomId', isEqualTo: widget.chatRoom.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading messages'));
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        List<Message> messages = snapshot.data!.docs
            .map((doc) => Message.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
        
        // Sort messages by timestamp in descending order (newest first)
        messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        if (messages.isEmpty) {
          return Center(
            child: Text(
              'No messages yet. Start the conversation!',
              style: TextStyle(color: Colors.grey[800]),
            ),
          );
        }
        
        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: EdgeInsets.all(16.w),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return _buildMessageBubble(messages[index]);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(Message message) {
    bool isMe = message.senderId == widget.currentUser.userId.toString();
    
    // Debug logging
    print('Message Debug:');
    print('  - Message senderId: ${message.senderId}');
    print('  - Current user ID: ${widget.currentUser.userId}');
    print('  - Current user name: ${widget.currentUser.name}');
    print('  - Is me: $isMe');
    print('  - Message content: ${message.content}');
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        constraints: BoxConstraints(maxWidth: 0.75 * MediaQuery.of(context).size.width),
        decoration: BoxDecoration(
          color: isMe 
              ? Theme.of(context).colorScheme.primary
              : Colors.white,
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontSize: 22.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              _formatMessageTime(message.timestamp),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey[800],
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[800],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              ),
              style: TextStyle(fontSize: 16.sp),
              maxLines: null,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 12.w),
          FloatingActionButton(
            onPressed: _sendMessage,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(Icons.send, color: Colors.white, size: 24.sp),
            mini: false,
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    String content = _messageController.text.trim();
    if (content.isEmpty) return;
    
    _messageController.clear();
    
    try {
      // Create message
      Message message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatRoomId: widget.chatRoom.id,
        senderId: widget.currentUser.userId.toString(),
        content: content,
        timestamp: Timestamp.now(),
        read: false,
      );
      
      // Debug logging
      print('📤 Sending Message:');
      print('  - Sender ID: ${message.senderId}');
      print('  - Sender Name: ${widget.currentUser.name}');
      print('  - Content: ${message.content}');
      print('  - Chat Room ID: ${message.chatRoomId}');
      
      // Save message
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(message.id)
          .set(message.toJson());
      
      // Update chat room with last message
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(widget.chatRoom.id)
          .update({
        'lastMessageId': message.id,
        'lastMessageTime': message.timestamp,
      });
      
      print('Message sent by user ${widget.currentUser.userId} (${widget.currentUser.name}) to chat room ${widget.chatRoom.id}');
      
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  String _formatMessageTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Data Models
class ChatRoom {
  final String id;
  final List<String> participants;
  final Items item;
  final Users otherUser;
  final Message? lastMessage;
  final int unreadCount;

  ChatRoom({
    required this.id,
    required this.participants,
    required this.item,
    required this.otherUser,
    this.lastMessage,
    required this.unreadCount,
  });
}

class Message {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String content;
  final Timestamp timestamp;
  final bool read;

  Message({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.read,
  });

  Message.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        chatRoomId = json['chatRoomId'] as String,
        senderId = json['senderId'] as String,
        content = json['content'] as String,
        timestamp = json['timestamp'] as Timestamp,
        read = json['read'] as bool? ?? false;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp,
      'read': read,
    };
  }
}
