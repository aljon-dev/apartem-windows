import 'package:bogsandmila/logo.dart';
import 'package:bogsandmila/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessagePageOld extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final uid;
  // ignore: prefer_typing_uninitialized_variables
  final type;
  const MessagePageOld({super.key, required this.uid, required this.type});
  @override
  // ignore: library_private_types_in_public_api
  _MessagePageOld createState() => _MessagePageOld();
}

class _MessagePageOld extends State<MessagePageOld> {
  final TextEditingController messageController = TextEditingController();

  String? selectedValue =
      ''; // Set the initial value as an empty string for 'Select Tenant'
  List<Map<String, String>> tenantsList = [
    {
      'uid': '',
      'name': 'Select Tenant'
    }, // Default option with a unique empty value
  ];

  @override
  void initState() {
    super.initState();
    _fetchTenantsFromFirestore();
  }

  // Function to fetch tenants from Firestore
  Future<void> _fetchTenantsFromFirestore() async {
    final tenants = await FirebaseFirestore.instance.collection('tenant').get();

    List<Map<String, String>> fetchedTenants = [
      {
        'uid': '',
        'name': 'Select Tenant'
      }, // Default option with a unique empty value
    ];

    for (var tenant in tenants.docs) {
      String tenantUid = tenant.id;
      String tenantName = tenant.data()['name'] ?? '';
      fetchedTenants.add({'uid': tenantUid, 'name': tenantName});
    }

    setState(() {
      tenantsList = fetchedTenants;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
                            image: AssetImage('assets/message.png'),
                            fit: BoxFit.cover,
                            width: 50,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Message',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 23),
                          ),
                        ],
                      )),
                  const SizedBox(height: 90),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Select Tenant:',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 23,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xddF4F4F4),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: selectedValue,
                              hint: const Text('Select Tenant'),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedValue = newValue!;
                                });

                                // Use selectedValue as uid here
                              },
                              items: tenantsList
                                  .map<DropdownMenuItem<String>>((tenant) {
                                return DropdownMenuItem<String>(
                                  value:
                                      tenant['uid'], // Unique UID as the value
                                  child: Text(tenant[
                                      'name']!), // Display name as the dropdown label
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextField(
                      controller: messageController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: "Enter an announcement here",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 110,
                          padding: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(228, 12, 12, 12),
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(
                                    0x661E1E1E), // Shadow color (#1E1E1E66)
                                offset: Offset(
                                    0, 2), // Horizontal and vertical offsets
                                blurRadius: 10.0, // Softness of the shadow
                                spreadRadius: 1.0, // Spread of the shadow
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () {
                              if (messageController.text.isEmpty) {
                              } else {
                                Services().CreateMessage(user!.uid,
                                    selectedValue!, messageController.text);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Message created successfully!'),
                                    backgroundColor: Colors
                                        .green, // Optional: Set a background color
                                    duration: Duration(
                                        seconds:
                                            2), // Optional: Set duration for the snackbar
                                  ),
                                );
                              }

                              // Clear the text field
                              messageController.clear();
                            },
                            child: const Text(
                              'Send',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
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
