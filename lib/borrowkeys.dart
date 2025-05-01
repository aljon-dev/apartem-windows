import 'package:bogsandmila/logo.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BorrowKeysPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final uid;
  // ignore: prefer_typing_uninitialized_variables
  final type;
  const BorrowKeysPage({super.key, required this.uid, required this.type});
  @override
  // ignore: library_private_types_in_public_api
  _BorrowKeysPage createState() => _BorrowKeysPage();
}

class _BorrowKeysPage extends State<BorrowKeysPage> {
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
                            image: AssetImage('assets/borrowkeys.png'),
                            fit: BoxFit.cover,
                            width: 50,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Borrow Keys',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 23),
                          ),
                        ],
                      )),
                  const SizedBox(height: 50),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xddF6F6F4),
                          ),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Building Number: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: "1", // Added line break here
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Row(
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Unit Number: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: "2", // Added line break here
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Row(
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "For: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: "Relatives",
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Row(
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Remarks: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text:
                                              "\nMy mother will borrowing the key. Her name is Juanita Dela Cruz.", // Added line break here
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 2,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 110,
                                      padding: const EdgeInsets.all(0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xddF96262),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: TextButton(
                                          onPressed: () {},
                                          child: const Row(
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
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: TextButton(
                                          onPressed: () {},
                                          child: const Row(
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
                                ),
                              )
                            ],
                          ),
                        )),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                            child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xddF6F6F4),
                          ),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Building Number: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: "1", // Added line break here
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Row(
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Unit Number: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: "2", // Added line break here
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Row(
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "For: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: "Relatives",
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Row(
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Remarks: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text:
                                              "\nMy mother will borrowing the key. Her name is Juanita Dela Cruz.", // Added line break here
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 2,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 110,
                                      padding: const EdgeInsets.all(0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xddF96262),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: TextButton(
                                          onPressed: () {},
                                          child: const Row(
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
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: TextButton(
                                          onPressed: () {},
                                          child: const Row(
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
                                ),
                              )
                            ],
                          ),
                        )),
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
