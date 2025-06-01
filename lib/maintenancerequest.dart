import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class maintenanceRequest {
  final String id;
  final String message;
  final String status;
  final String tenant;
  final String uid;
  final String imageUrl;
  final String building;
  final String unit;
  final String fullname;
  final String profile;
  final DateTime timestamp;

  maintenanceRequest({
    required this.id,
    required this.message,
    required this.status,
    required this.tenant,
    required this.uid,
    required this.imageUrl,
    required this.building,
    required this.unit,
    required this.timestamp,
    required this.fullname,
    required this.profile,
  });

  factory maintenanceRequest.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> request = doc.data() as Map<String, dynamic>;

    return maintenanceRequest(
      id: doc.id,
      message: request['message'] ?? '',
      status: request['status'] ?? '',
      tenant: request['tenant'] ?? '',
      uid: request['uid'] ?? '',
      imageUrl: request['image'] ?? '',
      building: request['building'] ?? '',
      unit: request['unit'] ?? '',
      fullname: request['fullname'] ?? 'Unknown',
      profile: request['profile'] ?? '',
      timestamp: (request['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'message': message,
      'status': status,
      'tenant': tenant,
      'uid': uid,
      'image': imageUrl,
      'building': building,
      'unit': unit,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class maintenanceRequestPage extends StatefulWidget {
  const maintenanceRequestPage({super.key});

  @override
  _maintenanceRequestPageState createState() => _maintenanceRequestPageState();
}

class _maintenanceRequestPageState extends State<maintenanceRequestPage> {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<maintenanceRequest>> _getRequestMaintenance() {
    return _firestore.collection('maintenance_request').where('status', isEqualTo: 'pending').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => maintenanceRequest.fromFirestore(doc)).toList();
    });
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

  void _handleRequestAction(maintenanceRequest request, String action) async {
    try {
      await _firestore.collection('maintenance_request').doc(request.id).update({'status': action});

      await _firestore.collection('notifications').add({
        'isRead': false,
        'title': 'Maintenance Request',
        'message': 'Maintenance Request ${action == 'approved' ? 'Approved' : 'Rejected'}',
        'timestamp': FieldValue.serverTimestamp(),
        'userId': request.uid,
        'type': 'maintenance',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Maintenance Request ${action == 'approved' ? 'Approved' : 'Rejected'}',
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
            Icon(Icons.build_outlined, size: 24),
            SizedBox(width: 12),
            Text(
              'Maintenance Requests',
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
        child: StreamBuilder<List<maintenanceRequest>>(
          stream: _getRequestMaintenance(),
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
            print(snapshot.error);

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final maintenanceRequests = snapshot.data!;

            if (maintenanceRequests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task_alt, size: 64, color: Colors.green[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No pending requests',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All maintenance requests have been processed',
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
                int crossAxisCount = 1;
                if (constraints.maxWidth > 1200) {
                  crossAxisCount = 3;
                } else if (constraints.maxWidth > 800) {
                  crossAxisCount = 2;
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: maintenanceRequests.length,
                  itemBuilder: (context, index) {
                    final request = maintenanceRequests[index];
                    return _buildRequestCard(request);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildRequestCard(maintenanceRequest request) {
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
                      _buildTenantHeader(request),
                      const SizedBox(height: 20),
                      _buildInfoSection('Message', request.message),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoSection('Building', request.building),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoSection('Unit', request.unit),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoSection(
                        'Date & Time',
                        DateFormat('MMM dd, yyyy • HH:mm').format(request.timestamp),
                      ),
                      if (request.imageUrl.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildImageSection(request.imageUrl),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            _buildActionButtons(request),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantHeader(maintenanceRequest request) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (request.profile.isNotEmpty) {
              _showImageDialog(request.profile);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: request.profile.isNotEmpty ? NetworkImage(request.profile) : null,
              backgroundColor: Colors.grey[100],
              child: request.profile.isEmpty ? Icon(Icons.person, size: 28, color: Colors.grey[600]) : null,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.fullname,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '@${request.tenant}',
                style: TextStyle(
                  fontSize: 14,
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

  Widget _buildInfoSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ATTACHMENT',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showImageDialog(imageUrl),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 32,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(maintenanceRequest request) {
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
              onPressed: () => _handleRequestAction(request, 'approved'),
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
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _handleRequestAction(request, 'rejected'),
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
        ],
      ),
    );
  }
}
