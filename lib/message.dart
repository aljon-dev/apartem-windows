import 'package:bogsandmila/logo.dart';
import 'package:bogsandmila/message_view.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MessagePage extends StatefulWidget {
  final uid;
  final type;

  const MessagePage({super.key, required this.uid, required this.type});

  @override
  _MessagePage createState() => _MessagePage();
}

class _MessagePage extends State<MessagePage> {
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
                children: [
                  LogoPage(uid: widget.uid, type: widget.type),
                  const SizedBox(height: 50),
                  Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Image(
                          image: AssetImage('assets/message.png'),
                          fit: BoxFit.cover,
                          width: 50,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Message',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 23,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 90),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('tenant')
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
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Center(
                                    child: Text('No data available'));
                              }

                              final List<DocumentSnapshot> data =
                                  snapshot.data!.docs;

                              return ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  var doc = data[index].data()
                                      as Map<String, dynamic>;

                                  return GestureDetector(
                                    child: Container(
                                      margin: EdgeInsets.symmetric(vertical: 5),
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 244, 244, 244),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            child: Text(
                                              '${doc['firstname']} ${doc['lastname']}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          FaIcon(
                                            FontAwesomeIcons.sms,
                                            color: Color(0xdd607DE1),
                                          )
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MessageView(
                                                  id: data[index].id,
                                                  firstname: doc['firstname'],
                                                  lastname: doc['lastname'],
                                                  uid: widget.uid,
                                                  type: widget.type)));
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
