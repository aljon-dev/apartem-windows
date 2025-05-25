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
      name: data['name'] ?? 'Unknown',
      mainAcountUser: data['mainAcountUser'] ?? 'Unknown',
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 600 && screenWidth <= 1024;

    // Responsive grid configuration
    int crossAxisCount;
    double childAspectRatio;
    double maxCardWidth = 450; // Maximum card width for desktop

    if (isDesktop) {
      crossAxisCount = (screenWidth / maxCardWidth).floor().clamp(3, 6);
      childAspectRatio = 1.1; // Slightly wider than tall for desktop
    } else if (isTablet) {
      crossAxisCount = 3;
      childAspectRatio = 0.9;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 0.1;
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const Text('Back'),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.door_sliding),
                Icon(Icons.key),
                SizedBox(width: 8),
                Text(
                  'Borrow Keys',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<borrowerKey>>(
                stream: _getBorrowers(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error.toString()}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final borrowers = snapshot.data!;

                  if (borrowers.isEmpty) {
                    return const Center(
                      child: Text(
                        'No pending key requests',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: isDesktop ? 16 : 10,
                      mainAxisSpacing: isDesktop ? 16 : 10,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: borrowers.length,
                    itemBuilder: (context, index) {
                      final borrower = borrowers[index];
                      return Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(isDesktop ? 10 : 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min, // Important: Let content determine height
                            children: [
                              Text(
                                borrower.mainAcountUser == 'Sub_Tenant' ? 'Sub-Tenant' : borrower.mainAcountUser,
                                style: TextStyle(
                                  fontSize: isDesktop ? 20 : 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                borrower.name,
                                style: TextStyle(
                                  fontSize: isDesktop ? 20 : 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: isDesktop ? 20 : 12),
                              Text(
                                'Building: ${borrower.buildingnumber}',
                                style: TextStyle(
                                  fontSize: isDesktop ? 20 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Unit: ${borrower.unitnumber}',
                                style: TextStyle(
                                  fontSize: isDesktop ? 20 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'For: ${borrower.forWho}',
                                style: TextStyle(
                                  fontSize: isDesktop ? 20 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: isDesktop ? 20 : 8),
                              Text(
                                'Requested: ${DateFormat('MMM d, yyyy h:mm a').format(borrower.timestamp!.toDate().toLocal())}',
                                style: TextStyle(
                                  fontSize: isDesktop ? 20 : 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF333333),
                                ),
                              ),
                              SizedBox(height: isDesktop ? 20 : 8),
                              Text(
                                'Remarks:',
                                style: TextStyle(
                                  fontSize: isDesktop ? 15 : 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  borrower.remarks,
                                  style: TextStyle(
                                    fontSize: isDesktop ? 20 : 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: isDesktop ? 4 : 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(height: isDesktop ? 15 : 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _firestore.collection("borrow_keys").doc(borrower.id).update({'status': 'rejected'});
                                        _firestore.collection('notifications').add({
                                          'isRead': false,
                                          'title': 'Key Request',
                                          'message': 'Borrow Request rejected',
                                          'timestamp': FieldValue.serverTimestamp(),
                                          'userId': borrower.uid,
                                          'type': 'key_request',
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Borrow Key Rejected')));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: isDesktop ? 6 : 8),
                                      ),
                                      icon: Icon(Icons.close, size: isDesktop ? 16 : 18),
                                      label: Text(
                                        'Reject',
                                        style: TextStyle(fontSize: isDesktop ? 16 : 14),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _firestore.collection("borrow_keys").doc(borrower.id).update({'status': 'approved'});
                                        _firestore.collection('notifications').add({
                                          'isRead': false,
                                          'title': 'Key Request',
                                          'message': 'Borrow Request Accepted',
                                          'timestamp': FieldValue.serverTimestamp(),
                                          'userId': borrower.uid,
                                          'type': 'key_request',
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Borrow Key Approved')));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: isDesktop ? 6 : 8),
                                      ),
                                      icon: Icon(Icons.check, size: isDesktop ? 16 : 18),
                                      label: Text(
                                        'Accept',
                                        style: TextStyle(fontSize: isDesktop ? 16 : 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
