import 'package:bogsandmila/dashboard.dart';
import 'package:bogsandmila/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedValue = 'Super Admin'; // Default selection
  String invalidEmail = "";
  String invalidPassword = "";
  @override
  Widget build(BuildContext context) {
    List<String> dropdownItems = ['Super Admin', 'Admin'];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 350, vertical: 114),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 50),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: const Image(
                      image: AssetImage('assets/logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'LOGIN',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 23),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    alignment: Alignment.bottomLeft,
                    child: const Text(
                      'Login as:',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xddF4F4F4),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedValue,
                      hint: const Text('Select Username'),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedValue =
                              newValue!; // Correctly updating selectedValue
                        });
                      },
                      items: dropdownItems
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    alignment: Alignment.bottomLeft,
                    child: const Text(
                      'Username',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black12),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      invalidEmail,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    alignment: Alignment.bottomLeft,
                    child: const Text(
                      'Password',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black12),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      invalidPassword,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(228, 12, 12, 12),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x661E1E1E),
                          offset: Offset(0, 2),
                          blurRadius: 10.0,
                          spreadRadius: 1.0,
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () {
                        if (selectedValue == "Admin") {
                          FirebaseFirestore.instance
                              .collection('users')
                              .where('username',
                                  isEqualTo: emailController.text)
                              .where('password',
                                  isEqualTo: passwordController.text)
                              .get()
                              .then((QuerySnapshot querySnapshot) {
                            if (querySnapshot.docs.isNotEmpty) {
                              for (QueryDocumentSnapshot doc
                                  in querySnapshot.docs) {
                                String uid = doc.id;

                                Navigator.push(
                                  // ignore: use_build_context_synchronously
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DashboardPage(
                                        uid: uid, type: selectedValue),
                                  ),
                                );
                              }
                            } else {
                              setState(() {
                                invalidEmail = "Invalid Username";
                                invalidPassword = "Invalid Password";
                              });
                            }
                          });
                        } else {
                          Services()
                              .Signin(
                                  emailController.text, passwordController.text)
                              .then((userCredential) {
                            if (userCredential != null &&
                                userCredential.user != null) {
                              String uid = userCredential.user!
                                  .uid; // Safely access the UID if not null
                              Navigator.push(
                                // ignore: use_build_context_synchronously
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DashboardPage(
                                        uid: uid, type: selectedValue)),
                              );
                            } else {
                              setState(() {
                                invalidEmail = "Invalid Username";
                                invalidPassword = "Invalid Password";
                              });
                            }
                          }).catchError((error) {
                            setState(() {
                              invalidEmail = "Invalid Username";
                              invalidPassword = "Invalid Password";
                            });
                          });
                        }
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.white),
                      ),
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

  errorMessge(String lable) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(lable),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
