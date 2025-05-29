import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class messagePage extends StatefulWidget {
  final String userid;

  const messagePage({Key? key, required this.userid}) : super(key: key);

  @override
  _messagePageState createState() => _messagePageState();
}

class _messagePageState extends State<messagePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedTenantId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Row(
        children: [
          // Left side - Chat list
          Container(
            width: 350, // Fixed width for the chat list
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search tenants...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('tenant').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Filter tenants based on search query
                      final filteredTenants = snapshot.data!.docs.where((tenant) {
                        final tenantData = tenant.data() as Map<String, dynamic>;
                        final fullName = '${tenantData['firstname'] ?? ''} ${tenantData['lastname'] ?? ''}'.toLowerCase();
                        return fullName.contains(_searchQuery);
                      }).toList();

                      return ListView.builder(
                        itemCount: filteredTenants.length,
                        itemBuilder: (context, index) {
                          final tenant = filteredTenants[index];
                          final tenantData = tenant.data() as Map<String, dynamic>;

                          return StreamBuilder<QuerySnapshot>(
                            stream: _firestore.collection('messages').where('participants', arrayContains: tenant.id).orderBy('timestamp', descending: true).limit(1).snapshots(),
                            builder: (context, messageSnapshot) {
                              String lastMessage = '';
                              bool hasUnread = false;
                              DateTime? lastMessageTime;

                              if (messageSnapshot.hasData && messageSnapshot.data!.docs.isNotEmpty) {
                                final lastMessageData = messageSnapshot.data!.docs.first.data() as Map<String, dynamic>;
                                lastMessage = lastMessageData['message'] ?? '';
                                hasUnread = !(lastMessageData['isRead'] ?? true) && (lastMessageData['receiverId'] == widget.userid || lastMessageData['senderId'] == widget.userid);
                                lastMessageTime = lastMessageData['timestamp']?.toDate();
                              }

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedTenantId = tenant.id;
                                  });
                                },
                                child: Container(
                                  color: _selectedTenantId == tenant.id ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue.shade100,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                    title: Text(
                                      '${tenantData['firstname'] ?? ''} ${tenantData['lastname'] ?? ''}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lastMessage.isEmpty ? 'No messages yet' : lastMessage,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (lastMessageTime != null)
                                          Text(
                                            _formatTimestamp(lastMessageTime),
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                      ],
                                    ),
                                    trailing: hasUnread
                                        ? Container(
                                            width: 12,
                                            height: 12,
                                            decoration: const BoxDecoration(
                                              color: Colors.blue,
                                              shape: BoxShape.circle,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Right side - Chat content
          Expanded(
            child: _selectedTenantId == null
                ? const Center(
                    child: Text('Select a conversation to start chatting'),
                  )
                : _buildChatContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatContent() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('tenant').doc(_selectedTenantId).snapshots(),
      builder: (context, tenantSnapshot) {
        if (!tenantSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tenantData = tenantSnapshot.data!.data() as Map<String, dynamic>;
        final tenantName = '${tenantData['firstname'] ?? ''} ${tenantData['lastname'] ?? ''}';
        final buildingNumber = tenantData['buildingnumber'];
        final unitNumber = tenantData['unitnumber'];

        return ChatScreen(
          adminId: widget.userid,
          tenantId: _selectedTenantId!,
          tenantName: tenantName,
          buildingnumber: buildingNumber,
          unitnumber: unitNumber,
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    if (now.difference(timestamp).inDays == 0) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
    return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class ChatScreen extends StatefulWidget {
  final String adminId;
  final String tenantId;
  final String tenantName;
  final String buildingnumber;
  final String unitnumber;

  const ChatScreen({
    Key? key,
    required this.adminId,
    required this.tenantId,
    required this.tenantName,
    required this.buildingnumber,
    required this.unitnumber,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _searchController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _scrollController = ScrollController();

  String adminId = "userAdmin";
  String _searchQuery = '';
  bool _isSearching = false;

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      await _firestore.collection('messages').add({
        'senderId': adminId,
        'receiverId': widget.tenantId,
        'message': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'senderRole': 'admin',
        'participants': [adminId, widget.tenantId],
      });

      // Create notification for tenant
      await _firestore.collection('notifications').add({
        'userId': widget.tenantId,
        'title': 'New Message from Admin',
        'message': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'message',
      });

      _messageController.clear();
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final messageTime = timestamp.toDate();
    final localTime = messageTime.toLocal();

    // Check if message is from today
    if (DateFormat('yyyy-MM-dd').format(now) == DateFormat('yyyy-MM-dd').format(localTime)) {
      return DateFormat('h:mm a').format(localTime); // Show only time for today
    }
    // Check if message is from yesterday
    else if (now.difference(localTime).inDays == 1) {
      return 'Yesterday ${DateFormat('h:mm a').format(localTime)}';
    }
    // Check if message is from this week
    else if (now.difference(localTime).inDays < 7) {
      return DateFormat('EEEE h:mm a').format(localTime); // Show day name and time
    }
    // Show full date for older messages
    else {
      return DateFormat('MMM d, yyyy h:mm a').format(localTime);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chat header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Icon(
                  Icons.person,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tenantName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Bldg: ${widget.buildingnumber} Unit: ${widget.unitnumber}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchQuery = '';
                      _searchController.clear();
                    }
                  });
                },
              ),
            ],
          ),
        ),

        // Search bar (when active)
        if (_isSearching)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search messages...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

        // Messages
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('messages').where('participants', arrayContains: widget.tenantId).orderBy('timestamp', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final messages = snapshot.data!.docs.where((doc) {
                final message = doc.data() as Map<String, dynamic>;
                return _searchQuery.isEmpty || message['message'].toString().toLowerCase().contains(_searchQuery);
              }).toList();

              return ListView.builder(
                reverse: true,
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index].data() as Map<String, dynamic>;
                  final isMe = message['senderId'] == adminId;
                  final timestamp = message['timestamp'] as Timestamp?;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[200],
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                              bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            message['message'],
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Message input
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.blue,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
