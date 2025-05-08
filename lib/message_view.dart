import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      body: Column(
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
                  final fullName =
                      '${tenantData['firstname'] ?? ''} ${tenantData['lastname'] ?? ''}'
                          .toLowerCase();
                  return fullName.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredTenants.length,
                  itemBuilder: (context, index) {
                    final tenant = filteredTenants[index];
                    final tenantData = tenant.data() as Map<String, dynamic>;

                    return StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('messages')
                          .where('participants', arrayContains: tenant.id)
                          .orderBy('timestamp', descending: true)
                          .limit(1)
                          .snapshots(),
                      builder: (context, messageSnapshot) {
                        String lastMessage = '';
                        bool hasUnread = false;
                        DateTime? lastMessageTime;

                        if (messageSnapshot.hasData &&
                            messageSnapshot.data!.docs.isNotEmpty) {
                          final lastMessageData =
                              messageSnapshot.data!.docs.first.data()
                                  as Map<String, dynamic>;
                          lastMessage = lastMessageData['message'] ?? '';
                          hasUnread = !(lastMessageData['isRead'] ?? true) &&
                              (lastMessageData['receiverId'] == widget.userid ||
                                  lastMessageData['senderId'] == widget.userid);
                          lastMessageTime =
                              lastMessageData['timestamp']?.toDate();
                        }

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lastMessage.isEmpty
                                      ? 'No messages yet'
                                      : lastMessage,
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    adminId: widget.userid,
                                    tenantId: tenant.id,
                                    tenantName:
                                        '${tenantData['firstname'] ?? ''} ${tenantData['lastname'] ?? ''}',
                                    buildingnumber:
                                        tenantData['buildingnumber'],
                                    unitnumber: tenantData['unitnumber'],
                                  ),
                                ),
                              );
                            },
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

  const ChatScreen(
      {Key? key,
      required this.adminId,
      required this.tenantId,
      required this.tenantName,
      required this.buildingnumber,
      required this.unitnumber})
      : super(key: key);

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search messages...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : ListTile(
                title: Text(widget.tenantName),
                subtitle: Text(
                    'Bldg: ${widget.buildingnumber} unit:${widget.unitnumber}'),
              ),
        actions: [
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
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .where('participants', arrayContains: widget.tenantId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs.where((doc) {
                  final message = doc.data() as Map<String, dynamic>;
                  return _searchQuery.isEmpty ||
                      message['message']
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final isMe = message['senderId'] == adminId;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              message['message'],
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                    ),
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
      ),
    );
  }
}
