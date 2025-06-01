import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class borrowerKey {
  final String id;
  final String forWho;
  final String remarks;
  final String uid;
  final String unitnumber;
  final String buildingnumber;
  final String name;
  final String fullname;
  final String profile;
  final String mainAcountUser;
  final Timestamp? timestamp;

  borrowerKey({
    required this.id,
    required this.forWho,
    required this.remarks,
    required this.uid,
    required this.unitnumber,
    required this.buildingnumber,
    required this.name,
    required this.fullname,
    required this.profile,
    required this.mainAcountUser,
    required this.timestamp,
  });

  factory borrowerKey.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return borrowerKey(
      id: doc.id,
      forWho: data['relationship'] ?? '',
      remarks: data['remarks'] ?? '',
      uid: data['uid'] ?? '',
      unitnumber: data['unitnumber'] ?? '',
      buildingnumber: data['buildingnumber'] ?? '',
      name: data['username'] ?? 'Unknown',
      mainAcountUser: data['mainAcountUser'] ?? 'Unknown',
      fullname: data['fullname'] ?? 'Unknown',
      profile: data['profile'] ?? '',
      timestamp: data['timestamp'],
    );
  }
}

class borrowKeypage extends StatefulWidget {
  const borrowKeypage({super.key});

  @override
  _borrowKeyPageState createState() => _borrowKeyPageState();
}

class _borrowKeyPageState extends State<borrowKeypage> {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<borrowerKey>> _getBorrowers() {
    return _firestore.collection('borrow_keys').where('status', isEqualTo: 'pending').snapshots().map((snapshot) => snapshot.docs.map(borrowerKey.fromFirestore).toList());
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleKeyRequest(borrowerKey borrower, String action) async {
    try {
      await _firestore.collection('borrow_keys').doc(borrower.id).update({'status': action});

      await _firestore.collection('notifications').add({
        'isRead': false,
        'title': 'Key Request',
        'message': 'Borrow Request ${action == 'approved' ? 'Accepted' : 'Rejected'}',
        'timestamp': FieldValue.serverTimestamp(),
        'userId': borrower.uid,
        'type': 'key_request',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Borrow Key ${action == 'approved' ? 'Approved' : 'Rejected'}',
            ),
            backgroundColor: action == 'approved' ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Row(
          children: [
            Icon(Icons.vpn_key_outlined, size: 24),
            SizedBox(width: 12),
            Text(
              'Key Borrow Requests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: StreamBuilder<List<borrowerKey>>(
          stream: _getBorrowers(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading requests',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final borrowers = snapshot.data!;

            if (borrowers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.key_off_outlined, size: 64, color: Colors.blue[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No pending key requests',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All key borrow requests have been processed',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                // For key requests, a single column layout works better
                // as each request has more detailed information
                return constraints.maxWidth > 1000 ? _buildTwoColumnLayout(borrowers) : _buildSingleColumnLayout(borrowers);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSingleColumnLayout(List<borrowerKey> borrowers) {
    return ListView.separated(
      itemCount: borrowers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildRequestCard(borrowers[index]);
      },
    );
  }

  Widget _buildTwoColumnLayout(List<borrowerKey> borrowers) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: borrowers.length,
      itemBuilder: (context, index) {
        return _buildRequestCard(borrowers[index]);
      },
    );
  }

  Widget _buildRequestCard(borrowerKey borrower) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTenantHeader(borrower),
                      const SizedBox(height: 20),
                      _buildLocationInfo(borrower),
                      const SizedBox(height: 16),
                      _buildRequestDetails(borrower),
                      const SizedBox(height: 16),
                      _buildRemarksSection(borrower),
                    ],
                  ),
                ),
              ),
            ),
            _buildActionButtons(borrower),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantHeader(borrowerKey borrower) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (borrower.profile.isNotEmpty) {
              _showImageDialog(borrower.profile);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: borrower.profile.isNotEmpty ? NetworkImage(borrower.profile) : null,
              backgroundColor: Colors.grey[100],
              child: borrower.profile.isEmpty ? Icon(Icons.person, size: 28, color: Colors.grey[600]) : null,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getAccountTypeColor(borrower.mainAcountUser),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  borrower.mainAcountUser == 'Sub_Tenant' ? 'Sub-Tenant' : borrower.mainAcountUser,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                borrower.fullname,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '@${borrower.name}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getAccountTypeColor(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'sub_tenant':
        return Colors.orange;
      case 'tenant':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLocationInfo(borrowerKey borrower) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, color: Colors.blue[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Building ${borrower.buildingnumber} • Unit ${borrower.unitnumber}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestDetails(borrowerKey borrower) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoSection(
                'REQUESTED FOR',
                borrower.forWho.isNotEmpty ? borrower.forWho : 'Not specified',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoSection(
                'REQUESTED AT',
                borrower.timestamp != null ? DateFormat('MMM d, yyyy\nh:mm a').format(borrower.timestamp!.toDate().toLocal()) : 'Unknown',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildRemarksSection(borrowerKey borrower) {
    if (borrower.remarks.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REMARKS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            borrower.remarks,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(borrowerKey borrower) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _handleKeyRequest(borrower, 'rejected'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text(
                'Reject',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _handleKeyRequest(borrower, 'approved'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text(
                'Approve',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
