import 'package:bogsandmila/logo.dart';
import 'package:bogsandmila/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VacancyPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final uid;
  // ignore: prefer_typing_uninitialized_variables
  final type;
  const VacancyPage({super.key, required this.uid, required this.type});
  @override
  // ignore: library_private_types_in_public_api
  _VacancyPage createState() => _VacancyPage();
}

class _VacancyPage extends State<VacancyPage> {
  @override
  Widget build(BuildContext context) {
    // Create a reference to the Firestore document
    DocumentReference documentRef = FirebaseFirestore.instance
        .collection('available_units')
        .doc('c6EnJE8SuwsbVnwnluZf');

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
                  const SizedBox(height: 100),
                  StreamBuilder<DocumentSnapshot>(
                    stream: documentRef.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Center(
                            child: Text('Document does not exist'));
                      }

                      // Get the data from the snapshot
                      Map<String, dynamic> data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      String qty = data['qty']?.toString() ?? "0";

                      return Stack(
                        alignment:
                            Alignment.center, // Ensures both are centered
                        children: [
                          const Image(
                            image: AssetImage('assets/house2.png'),
                            fit: BoxFit.cover,
                            width: 300,
                          ),
                          Column(
                            children: [
                              const SizedBox(height: 30),
                              Text(
                                qty,
                                style: const TextStyle(
                                  fontSize: 100,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Available Units',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: 150,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(width: 1)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xdd4D82D2),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xdd4D82D2),
                                offset: Offset(0, 2),
                                blurRadius: 3.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                          child: TextButton(
                              onPressed: () {
                                Services().ActionVacancy('minus');
                              },
                              child: const FaIcon(
                                FontAwesomeIcons.minus,
                                color: Colors.white,
                                size: 18,
                              )),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xdd4D82D2),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xdd4D82D2),
                                offset: Offset(0, 2),
                                blurRadius: 3.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                          child: TextButton(
                              onPressed: () {
                                Services().ActionVacancy('plus');
                              },
                              child: const FaIcon(
                                FontAwesomeIcons.plus,
                                color: Colors.white,
                                size: 18,
                              )),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Adjust the quantity of available unit here.',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  )
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
