import 'package:bogsandmila/borrowkeys.dart';
import 'package:bogsandmila/logo.dart';
import 'package:bogsandmila/maintenancerequest.dart';
import 'package:flutter/material.dart';

class RequestPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final uid;
  // ignore: prefer_typing_uninitialized_variables
  final type;
  const RequestPage({super.key, required this.uid, required this.type});

  @override
  // ignore: library_private_types_in_public_api
  _RequestPage createState() => _RequestPage();
}

class _RequestPage extends State<RequestPage> {
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
                    child: const Text(
                      'Requests',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 23),
                    ),
                  ),
                  const SizedBox(height: 90),
                  SizedBox(
                      width: 700,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xddF6F6F4),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image(
                                        image: AssetImage(
                                            'assets/maintenancerequest.png'),
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Maintenance Request',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Number of Request: 2',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MaintenceRequestPage(
                                                  uid: widget.uid,
                                                  type: widget.type)));
                                },
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              GestureDetector(
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xddF6F6F4),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image(
                                        image:
                                            AssetImage('assets/borrowkeys.png'),
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Borrow Keys',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Number of Request: 2',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => BorrowKeysPage(
                                              uid: widget.uid,
                                              type: widget.type)));
                                },
                              ),
                            ],
                          ),
                        ],
                      )),
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
