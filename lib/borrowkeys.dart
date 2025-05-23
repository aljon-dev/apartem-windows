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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.door_sliding),
                Icon(Icons.key),
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: borrowers.length,
                    itemBuilder: (context, index) {
                      final borrower = borrowers[index];
                      return Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                borrower.mainAcountUser == 'Sub_Tenant' ? 'Sub-Tenant' : borrower.mainAcountUser,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                borrower.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Building: ${borrower.buildingnumber}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Unit: ${borrower.unitnumber}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'For: ${borrower.forWho}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Requested: ${DateFormat('MMM d, yyyy h:mm a').format(borrower.timestamp!.toDate().toLocal())}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Remarks:',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                borrower.remarks,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 16),
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
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      icon: const Icon(Icons.close, size: 18),
                                      label: const Text('Reject', style: TextStyle(fontSize: 14)),
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
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      icon: const Icon(Icons.check, size: 18),
                                      label: const Text('Accept', style: TextStyle(fontSize: 14)),
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
