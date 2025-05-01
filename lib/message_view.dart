import 'dart:math';
import 'package:bogsandmila/logo.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class MessageView extends StatefulWidget {
  final String id; // Explicitly define as String
  final String firstname;
  final String lastname;
  final String uid;
  final String type;

  const MessageView({
    Key? key,
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.uid,
    required this.type,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MessageView createState() => _MessageView();
}

class _MessageView extends State<MessageView> {
  final messagesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final sortid = [widget.uid, widget.id];
    sortid.sort();
    String chatroomID = sortid.join("_");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            LogoPage(uid: widget.uid, type: widget.type),
            const SizedBox(height: 50),
            Container(
              padding: EdgeInsets.all(20),
              alignment: Alignment.topLeft,
              child: Text(
                'Receiver: ${widget.firstname} ${widget.lastname}',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Container(
              height: 520,
              child: StreamBuilder(
                stream: (() {
                  // Conditional check to determine if orderBy should be applied
                  if (chatroomID != null && chatroomID.isNotEmpty) {
                    return FirebaseFirestore.instance
                        .collection('messages')
                        .orderBy("timestamp")
                        .snapshots();
                  } else {
                    return FirebaseFirestore.instance
                        .collection('messages')
                        .snapshots();
                  }
                })(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final timestamp =
                            snapshot.data!.docs[index]['timestamp'];
                        DateTime? messageDate;

                        // Check if the timestamp is of type Timestamp and convert it to DateTime
                        if (timestamp is Timestamp) {
                          messageDate = timestamp.toDate();
                        }
                        String formattedDate = '';
                        if (messageDate != null) {
                          formattedDate =
                              DateFormat('MMM d, y h:mm a').format(messageDate);
                        }

                        if (chatroomID == snapshot.data!.docs[index]['code']) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (messageDate != null)
                                DateChip(
                                  date: messageDate,
                                  label: formattedDate,
                                ),
                              snapshot.data!.docs[index]['sender'].toString() ==
                                      widget.uid.toString()
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        BubbleSpecialThree(
                                          text: snapshot.data!.docs[index]
                                              ['text'],
                                          color: Color(0xdd607DE1),
                                          tail: false,
                                          textStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(right: 10),
                                          child: FaIcon(
                                              FontAwesomeIcons.userCircle),
                                        )
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(left: 10),
                                          child: FaIcon(
                                              FontAwesomeIcons.userCircle),
                                        ),
                                        BubbleSpecialThree(
                                          text: snapshot.data!.docs[index]
                                              ['text'],
                                          color: Colors.grey,
                                          tail: false,
                                          isSender: false,
                                          textStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                      ],
                                    )
                            ],
                          );
                        } else {
                          return SizedBox
                              .shrink(); // Empty widget if chatroomID doesn't match
                        }
                      },
                    );
                  } else {
                    return Text('NO MESSAGES');
                  }
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: messagesController,
                        decoration: InputDecoration(
                            labelText: 'Enter Message',
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Color(0xdd607DE1),
                        borderRadius: BorderRadius.circular(50)),
                    child: TextButton(
                      onPressed: () async {
                        final sortid = [widget.uid, widget.id];
                        sortid.sort();
                        String chatroomID = sortid.join("_");

                        if (messagesController != null) {
                          final refcolmessages =
                              FirebaseFirestore.instance.collection('messages');

                          refcolmessages.add({
                            'sender': widget.uid,
                            'receiver': widget.id,
                            'text': messagesController.text,
                            'code': chatroomID,
                            'timestamp':
                                FieldValue.serverTimestamp(), // Add timestamp
                          });
                        }

                        messagesController.clear();
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DateChip extends StatelessWidget {
  final DateTime date; // You can use this if needed
  final String label; // Define the label parameter

  const DateChip({
    Key? key,
    required this.date, // Include date in constructor if needed
    required this.label, // Include label in constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(8.0), // Optional: rounded corners
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0), // Padding
        child: Text(
          label, // Display the label
          style: TextStyle(
              color: Colors.grey.shade600, fontSize: 12), // Text color
        ),
      ),
    );
  }
}
