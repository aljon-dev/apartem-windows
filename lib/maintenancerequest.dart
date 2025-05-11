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
  final DateTime timestamp; // Use DateTime for better handling

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
  });

  // Factory constructor to create an instance from Firestore
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
      timestamp: (request['timestamp'] as Timestamp)
          .toDate(), // Convert Firestore Timestamp to DateTime
    );
  }

  // Convert instance to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'message': message,
      'status': status,
      'tenant': tenant,
      'uid': uid,
      'image': imageUrl,
      'building': building,
      'unit': unit,
      'timestamp': Timestamp.fromDate(
          timestamp), // Convert DateTime to Firestore Timestamp
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
    return _firestore
        .collection('maintenance_request')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => maintenanceRequest.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.hardware_outlined),
                  Text(
                    'Maintenance Request',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                  child: StreamBuilder<List<maintenanceRequest>>(
                      stream: _getRequestMaintenance(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.hasError}'));
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final maintenanceRequest = snapshot.data!;

                        return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2),
                            itemCount: maintenanceRequest.length,
                            itemBuilder: (context, index) {
                              final request = maintenanceRequest[index];
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Tenant',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      Text(request.tenant,
                                          style: const TextStyle(
                                            fontSize: 20,
                                          )),
                                      const SizedBox(height: 20),
                                      const Text('Message',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      Text(request.message,
                                          style: const TextStyle(
                                            fontSize: 20,
                                          )),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      const Text('Building Number',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      Text(request.building,
                                          style: const TextStyle(
                                            fontSize: 20,
                                          )),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      const Text('Unit Number',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      Text(request.unit,
                                          style: const TextStyle(
                                            fontSize: 20,
                                          )),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Date Time',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            DateFormat('yyyy-MM-dd HH:mm:ss')
                                                .format(request.timestamp),
                                            style:
                                                const TextStyle(fontSize: 20),
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                      ),
                                      Center(
                                        child: request.imageUrl.isNotEmpty
                                            ? Image.network(
                                                request.imageUrl,
                                                height: 150,
                                                width: 200,
                                              )
                                            : const SizedBox(),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              _firestore
                                                  .collection(
                                                      'maintenance_request')
                                                  .doc(request.id)
                                                  .update({
                                                'status': 'approved',
                                              });

                                              _firestore
                                                  .collection('notifications')
                                                  .add({
                                                'isRead': false,
                                                'title': 'Maintenance Request',
                                                'message':
                                                    'Maintenance Request Approved',
                                                'timestamp': FieldValue
                                                    .serverTimestamp(),
                                                'userId': request.uid,
                                                'type': 'maintenance',
                                              });

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Maintenance Request  Rejected')));
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5))),
                                            icon: const Icon(Icons.close),
                                            label: const Text('Rejected'),
                                          ),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              _firestore
                                                  .collection(
                                                      'maintenance_request')
                                                  .doc(request.id)
                                                  .update({
                                                'status': 'rejected',
                                              });

                                              _firestore
                                                  .collection('notifications')
                                                  .add({
                                                'isRead': false,
                                                'title': 'Maintenance Request',
                                                'message':
                                                    'Maintenance Request Rejected',
                                                'timestamp': FieldValue
                                                    .serverTimestamp(),
                                                'userId': request.uid,
                                                'type': 'maintenance',
                                              });

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Maintenance Request Approved')));
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5))),
                                            icon: const Icon(Icons.check),
                                            label: const Text('Accepted'),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      }))
            ],
          ),
        ));
  }
}
