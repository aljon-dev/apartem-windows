import 'package:bogsandmila/logo.dart';
import 'package:bogsandmila/services.dart';
import 'package:flutter/material.dart';

class ManageUserPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final uid;
  // ignore: prefer_typing_uninitialized_variables
  final type;
  const ManageUserPage({super.key, required this.uid, required this.type});

  @override
  // ignore: library_private_types_in_public_api
  _ManageUserPage createState() => _ManageUserPage();
}

class _ManageUserPage extends State<ManageUserPage> {
  late TextEditingController firstname = TextEditingController();
  late TextEditingController middlename = TextEditingController();
  late TextEditingController lastname = TextEditingController();
  late TextEditingController contactnumber = TextEditingController();
  late TextEditingController buildingnumber = TextEditingController();
  late TextEditingController unitnumber = TextEditingController();
  late TextEditingController username = TextEditingController();
  late TextEditingController password = TextEditingController();

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
                      'Manage User',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 32),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'Tenant Registration',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                      width: 700,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _formContainer("First Name:", firstname),
                              _formContainer("M.I:", middlename),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _formContainer("Last Name:", lastname),
                              _formContainer("Contact Number:", contactnumber),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _formContainer(
                                  "Building Number:", buildingnumber),
                              _formContainer("Unit Number:", unitnumber),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _formContainer("Username:", username),
                              _formContainer("Password:", password),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 22),
                                  width: 200,
                                  height: 40,
                                  padding: const EdgeInsets.all(0),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(228, 12, 12, 12),
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(
                                            0x661E1E1E), // Shadow color (#1E1E1E66)
                                        offset: Offset(0,
                                            2), // Horizontal and vertical offsets
                                        blurRadius:
                                            10.0, // Softness of the shadow
                                        spreadRadius:
                                            1.0, // Spread of the shadow
                                      ),
                                    ],
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      Services().CreateManageUser(
                                          firstname.text,
                                          middlename.text,
                                          lastname.text,
                                          contactnumber.text,
                                          buildingnumber.text,
                                          unitnumber.text,
                                          username.text,
                                          password.text);

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Create account successfully!'),
                                          backgroundColor: Colors
                                              .green, // Optional: Set a background color
                                          duration: Duration(
                                              seconds:
                                                  2), // Optional: Set duration for the snackbar
                                        ),
                                      );

                                      firstname.clear();
                                      middlename.clear();
                                      lastname.clear();
                                      contactnumber.clear();
                                      buildingnumber.clear();
                                      unitnumber.clear();
                                      username.clear();
                                      password.clear();
                                    },
                                    child: const Text(
                                      'Register Account',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
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

  _formContainer(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          padding: const EdgeInsets.only(left: 10),
          width: 300,
          height: 45,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 1, color: const Color(0xddDADADA))),
          child: TextField(
            style: const TextStyle(
              fontSize: 13.0,
            ),
            controller: controller,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        )
      ],
    );
  }
}
