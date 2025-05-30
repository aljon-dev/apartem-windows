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
        backgroundColor: Colors.blue.shade50,
      ),
      body: Row(
        children: [
          // Left Column - Chat list
          Container(
            width: 320,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
              color: Colors.grey.shade50,
            ),
            child: Column(
              children: [
                // Search Header
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chats',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search tenants...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                // Chat List
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

                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _selectedTenantId == tenant.id ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      _selectedTenantId = tenant.id;
                                    });
                                  },
                                  leading: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.blue.shade100,
                                    child: tenantData['profile'] != null && tenantData['profile'].toString().isNotEmpty
                                        ? ClipOval(
                                            child: Image.network(
                                              tenantData['profile'],
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Text(
                                                '${tenantData['firstname']?[0] ?? ''}${tenantData['lastname']?[0] ?? ''}'.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue.shade900,
                                                ),
                                              ),
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                                                );
                                              },
                                            ),
                                          )
                                        : Text(
                                            '${tenantData['firstname']?[0] ?? ''}${tenantData['lastname']?[0] ?? ''}'.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade900,
                                            ),
                                          ),
                                  ),
                                  title: Text(
                                    '${tenantData['firstname'] ?? ''} ${tenantData['lastname'] ?? ''}',
                                    style: TextStyle(
                                      fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lastMessage.isEmpty ? 'No messages yet' : lastMessage,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      if (lastMessageTime != null)
                                        Text(
                                          _formatTimestamp(lastMessageTime),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: hasUnread
                                      ? Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                      : null,
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

          // Middle Column - Chat content
          Expanded(
            flex: 2,
            child: _selectedTenantId == null
                ? Container(
                    color: Colors.grey.shade50,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Select a conversation to start chatting',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _buildChatContent(),
          ),

          // Right Column - User Profile
          if (_selectedTenantId != null)
            Container(
              width: 300,
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.grey.shade300)),
                color: Colors.grey.shade50,
              ),
              child: _buildUserProfile(),
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

  Widget _buildUserProfile() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('tenant').doc(_selectedTenantId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tenantData = snapshot.data!.data() as Map<String, dynamic>;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Header
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Profile Picture
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue.shade100,
                child: tenantData['profile'] != null && tenantData['profile'].toString().isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          tenantData['profile'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Text(
                            '${tenantData['firstname']?[0] ?? ''}${tenantData['lastname']?[0] ?? ''}'.toUpperCase(),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                            );
                          },
                        ),
                      )
                    : Text(
                        '${tenantData['firstname']?[0] ?? ''}${tenantData['lastname']?[0] ?? ''}'.toUpperCase(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Full Name
              Text(
                '${tenantData['firstname'] ?? ''} ${tenantData['lastname'] ?? ''}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Contact Information Card
              _buildInfoCard('Contact Information', [
                _buildInfoRow(Icons.person, 'Fullname', tenantData['firstname'] + ' ' + tenantData['lastname'] ?? 'N/A'),
                _buildInfoRow(Icons.phone_outlined, 'Phone', tenantData['contactnumber'] ?? 'N/A'),
                _buildInfoRow(Icons.verified_user, 'Username', tenantData['username'] ?? 'N/A'),
                _buildInfoRow(Icons.money, 'Rental Fee', tenantData['rentalfee'].toString() ?? 'N/A'),
              ]),

              const SizedBox(height: 16),

              // Property Information Card
              _buildInfoCard('Property Information', [
                _buildInfoRow(Icons.business_outlined, 'Building', tenantData['buildingnumber']?.toString() ?? 'N/A'),
                _buildInfoRow(Icons.door_front_door_outlined, 'Unit', tenantData['unitnumber']?.toString() ?? 'N/A'),
              ]),

              const SizedBox(height: 16),

              _buildInfoCardWithStreamBuilder('Number of Sub Accounts', [
                _buildStreamBuilderInfoRow(
                  Icons.people_outlined,
                  'Sub Accounts',
                  _firestore.collection('Sub-Tenant').where('mainAccountId', isEqualTo: _selectedTenantId).snapshots(),
                ),
              ]),

              const SizedBox(height: 16),

              _buildRentalInfoCard(),

              const SizedBox(height: 16),

              /*
              _buildInfoCard('Lease Information', [
                _buildInfoRow(Icons.calendar_today_outlined, 'Move-in Date', tenantData['moveindate'] != null ? DateFormat('MMM dd, yyyy').format((tenantData['moveindate'] as Timestamp).toDate()) : 'N/A'),
                _buildInfoRow(Icons.attach_money_outlined, 'Monthly Rent', tenantData['monthlyrent'] != null ? '₱${tenantData['monthlyrent']}' : 'N/A'),
                _buildInfoRow(Icons.receipt_outlined, 'Deposit', tenantData['deposit'] != null ? '₱${tenantData['deposit']}' : 'N/A'),
              ]),
              */

              const SizedBox(height: 24),

              // Quick Actions
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCardWithStreamBuilder(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Color _getRentalStatusColor(String status, DateTime? dueDate) {
    if (status.toLowerCase() == 'paid') {
      return Colors.green;
    } else if (status.toLowerCase() == 'unpaid') {
      if (dueDate != null) {
        final now = DateTime.now();
        final daysDifference = now.difference(dueDate).inDays;

        if (daysDifference > 0) {
          return Colors.red; // Overdue
        } else if (daysDifference == 0) {
          return Colors.orange; // Due today
        } else {
          return Colors.blue; // Not yet due
        }
      }
      return Colors.red; // Default for unpaid
    }
    return Colors.grey; // Unknown status
  }

// Method to get status text with due info
  String _getStatusText(String status, DateTime? dueDate) {
    if (status.toLowerCase() == 'unpaid' && dueDate != null) {
      final now = DateTime.now();
      final daysDifference = now.difference(dueDate).inDays;

      if (daysDifference > 0) {
        return '$status (${daysDifference} days overdue)';
      } else if (daysDifference == 0) {
        return '$status (Due today)';
      } else {
        return '$status (Due in ${daysDifference.abs()} days)';
      }
    }
    return status;
  }

// Replace your existing rental info card section with this:
  Widget _buildRentalInfoCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('rentalRecord').where('tenantId', isEqualTo: _selectedTenantId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildInfoCard('Rental Information', [
            _buildInfoRow(Icons.error, 'Error', 'Unable to load rental data'),
          ]);
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildInfoCard('Rental Information', [
            _buildInfoRow(Icons.calendar_month, 'Monthly Fee', 'No rental record found'),
          ]);
        }

        // Get the rental record
        final rentalDoc = snapshot.data!.docs.first;
        final rentalData = rentalDoc.data() as Map<String, dynamic>;

        final status = rentalData['status']?.toString() ?? 'Unknown';
        final rentalFee = rentalData['rentalfee']?.toString() ?? 'N/A';
        final timestamp = rentalData['timestamp'] as Timestamp?;
        final dueDate = timestamp?.toDate();

        final statusColor = _getRentalStatusColor(status, dueDate);
        final statusText = _getStatusText(status, dueDate);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rental Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildColoredInfoRow(
                Icons.calendar_month,
                'Monthly Fee',
                '₱$rentalFee',
                statusColor,
              ),
              _buildColoredInfoRow(
                Icons.info,
                'Status',
                statusText,
                statusColor,
              ),
              if (dueDate != null)
                _buildInfoRow(
                  Icons.calendar_today,
                  'Due Date',
                  DateFormat('MMM dd, yyyy').format(dueDate),
                ),
            ],
          ),
        );
      },
    );
  }

// Add this new method for colored info rows
  Widget _buildColoredInfoRow(IconData icon, String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamBuilderInfoRow(IconData icon, String label, Stream<QuerySnapshot> stream) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                StreamBuilder<QuerySnapshot>(
                  stream: stream,
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text(
                        'Error loading data',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }

                    final count = snapshot.data?.docs.length ?? 0;
                    final displayText = '$count/3';

                    // Determine color based on count
                    Color textColor;
                    Color backgroundColor;

                    if (count == 0) {
                      textColor = Colors.grey.shade700;
                      backgroundColor = Colors.grey.shade100;
                    } else if (count <= 1) {
                      textColor = Colors.green.shade800;
                      backgroundColor = Colors.green.shade100;
                    } else if (count == 2) {
                      textColor = Colors.orange.shade800;
                      backgroundColor = Colors.orange.shade100;
                    } else if (count >= 3) {
                      textColor = Colors.red.shade800;
                      backgroundColor = Colors.red.shade100;
                    } else {
                      textColor = Colors.grey.shade700;
                      backgroundColor = Colors.grey.shade100;
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: textColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        displayText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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

    if (DateFormat('yyyy-MM-dd').format(now) == DateFormat('yyyy-MM-dd').format(localTime)) {
      return DateFormat('h:mm a').format(localTime);
    } else if (now.difference(localTime).inDays == 1) {
      return 'Yesterday ${DateFormat('h:mm a').format(localTime)}';
    } else if (now.difference(localTime).inDays < 7) {
      return DateFormat('EEEE h:mm a').format(localTime);
    } else {
      return DateFormat('MMM d, yyyy h:mm a').format(localTime);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Chat header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              color: Colors.white,
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
                Expanded(
                  child: Column(
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
                ),
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
            child: Container(
              color: Colors.grey.shade50,
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
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index].data() as Map<String, dynamic>;
                      final isMe = message['senderId'] == adminId;
                      final timestamp = message['timestamp'] as Timestamp?;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                                color: isMe ? Colors.blue : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                                  bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
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
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
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
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
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
