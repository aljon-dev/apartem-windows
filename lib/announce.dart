import 'package:bogsandmila/logo.dart';
import 'package:bogsandmila/services.dart';
import 'package:flutter/material.dart';

class AnnouncePage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final uid;
  // ignore: prefer_typing_uninitialized_variables
  final type;
  const AnnouncePage({super.key, required this.uid, required this.type});

  @override
  // ignore: library_private_types_in_public_api
  _AnnouncePage createState() => _AnnouncePage();
}

class _AnnouncePage extends State<AnnouncePage> {
  final TextEditingController announceController = TextEditingController();
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
                            image: AssetImage('assets/announce.png'),
                            fit: BoxFit.cover,
                            width: 50,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Announce',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 23),
                          ),
                        ],
                      )),
                  const SizedBox(height: 90),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: const Row(
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "Note: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text:
                                    "Fill in the text field of the announcement and press ",
                              ),
                              TextSpan(
                                text: "“send”",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text:
                                    ". All tenants will receive\nthis general announcement.", // Added line break here
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextField(
                      controller: announceController,
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
                              if (announceController.text.isEmpty) {
                              } else {
                                Services()
                                    .CreateAnnounce(announceController.text);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Announcement created successfully!'),
                                    backgroundColor: Colors
                                        .green, // Optional: Set a background color
                                    duration: Duration(
                                        seconds:
                                            2), // Optional: Set duration for the snackbar
                                  ),
                                );
                              }

                              // Clear the text field
                              announceController.clear();
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
