import 'package:bogsandmila/dashboard.dart';
import 'package:bogsandmila/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedValue = 'Super Admin';
  String invalidEmail = "";
  String invalidPassword = "";

  @override
  Widget build(BuildContext context) {
    final List<String> dropdownItems = ['Super Admin', 'Admin'];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                width: 600,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const Image(
                        image: AssetImage('assets/logo.png'),
                        height: 80,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'LOGIN',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      const SizedBox(height: 30),

                      // Role Dropdown
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text('Login as:',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedValue,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xffF4F4F4),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none),
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedValue = newValue!;
                          });
                        },
                        items: dropdownItems
                            .map((value) => DropdownMenuItem(
                                value: value, child: Text(value)))
                            .toList(),
                      ),
                      const SizedBox(height: 20),

                      // Email or Username
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          selectedValue == 'Super Admin' ? 'Email' : 'Username',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: selectedValue == 'Super Admin'
                              ? 'Email'
                              : 'Username',
                          filled: true,
                          fillColor: const Color(0xffF4F4F4),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                      if (invalidEmail.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(invalidEmail,
                                style: const TextStyle(color: Colors.red)),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Password
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text('Password',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          fillColor: const Color(0xffF4F4F4),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                      if (invalidPassword.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(invalidPassword,
                                style: const TextStyle(color: Colors.red)),
                          ),
                        ),

                      const SizedBox(height: 30),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: _handleLogin,
                          child: const Text('Login',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Footer
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

  void _handleLogin() {
    setState(() {
      invalidEmail = "";
      invalidPassword = "";
    });

    if (selectedValue == "Admin") {
      FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: emailController.text)
          .where('password', isEqualTo: passwordController.text)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final uid = querySnapshot.docs.first.id;
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => DashboardPage(uid: uid, type: selectedValue)),
          );
        } else {
          setState(() {
            invalidEmail = "Invalid Username";
            invalidPassword = "Invalid Password";
          });
        }
      });
    } else {
      Services()
          .Signin(emailController.text, passwordController.text)
          .then((userCredential) {
        if (userCredential != null && userCredential.user != null) {
          final uid = userCredential.user!.uid;
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => DashboardPage(uid: uid, type: selectedValue)),
          );
        } else {
          setState(() {
            invalidEmail = "Invalid Username";
            invalidPassword = "Invalid Password";
          });
        }
      }).catchError((_) {
        setState(() {
          invalidEmail = "Invalid Username";
          invalidPassword = "Invalid Password";
        });
      });
    }
  }
}
