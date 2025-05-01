import 'package:bogsandmila/logo.dart';
import 'package:bogsandmila/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MaintenceRequestPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final uid;
  // ignore: prefer_typing_uninitialized_variables
  final type;
  const MaintenceRequestPage(
      {super.key, required this.uid, required this.type});

  @override
  // ignore: library_private_types_in_public_api
  _MaintenceRequestPage createState() => _MaintenceRequestPage();
}

class _MaintenceRequestPage extends State<MaintenceRequestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LogoPage(uid: widget.uid, type: widget.type),
                  const SizedBox(height: 50),
                  Container(
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage('assets/maintenancerequest.png'),
                            fit: BoxFit.cover,
                            width: 50,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Maintenance Request',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 23),
                          ),
                        ],
                      )),
                  const SizedBox(height: 50),
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('maintenance_request')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No data available'));
                        }

                        final List<DocumentSnapshot> data = snapshot.data!.docs;

                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20.0,
                            mainAxisSpacing: 20.0,
                          ),
                          padding: const EdgeInsets.all(10),
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            var doc = data[index];
                            var docID = doc.id; // Accessing the document ID

                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xddF6F6F4),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Tenant:",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    doc['tenant'] ?? 'Unknown',
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text(
                                    "Message:",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    doc['message'] ?? 'No message',
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text(
                                    "Image:",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Expanded(
                                    child: Image.network(
                                      doc['image'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 110,
                                        padding: const EdgeInsets.all(0),
                                        decoration: BoxDecoration(
                                          color: const Color(0xddF96262),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: TextButton(
                                            onPressed: () {
                                              Services()
                                                  .MaintenanceRequestAction(
                                                      docID, 'declined');
                                            },
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                FaIcon(
                                                  FontAwesomeIcons
                                                      // ignore: deprecated_member_use
                                                      .solidTimesCircle,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  'Decline',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ],
                                            )),
                                      ),
                                      Container(
                                        width: 110,
                                        padding: const EdgeInsets.all(0),
                                        decoration: BoxDecoration(
                                          color: const Color(0xdd00B723),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: TextButton(
                                            onPressed: () {
                                              Services()
                                                  .MaintenanceRequestAction(
                                                      docID, 'approved');
                                            },
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                FaIcon(
                                                  FontAwesomeIcons
                                                      // ignore: deprecated_member_use
                                                      .solidCheckCircle,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  'Accept',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ],
                                            )),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  )),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: const Color.fromARGB(255, 30, 30, 30),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const Center(
                child: Text(
                  'Copyright © Bogs and Mila Apartment. All Rights Reserved.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
