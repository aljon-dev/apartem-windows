import 'package:bogsandmila/logo.dart';
import 'package:bogsandmila/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminAccountPage extends StatefulWidget {
  final uid;
  final type;
  const AdminAccountPage({super.key, required this.uid, required this.type});

  @override
  _AdminAccountPage createState() => _AdminAccountPage();
}

class _AdminAccountPage extends State<AdminAccountPage> {
  late TextEditingController username = TextEditingController();
  late TextEditingController password = TextEditingController();
  final int _rowsPerPage = 10;
  int _currentPage = 0;
  String? selectedValue;

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
                  // Back button
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        label: const Text(
                          'Back',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  LogoPage(uid: widget.uid, type: widget.type),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    color: const Color.fromARGB(240, 17, 17, 17),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage('assets/manageuser.png'),
                          width: 40,
                        ),
                        SizedBox(width: 20),
                        Text(
                          'Admin Accounts',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 23),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Registration Form
                  Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'Admin Registration',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 700,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _formContainer("Username:", username),
                            _formContainer("Password:", password),
                          ],
                        ),
                        const SizedBox(height: 20),
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
                                    if (username.text.isEmpty || password.text.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please fill all fields!'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    Services().AdminAccount(username.text, password.text);
                                    username.clear();
                                    password.clear();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Account created successfully!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
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
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Admin Accounts Table
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(child: Text('Something went wrong'));
                        }
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final data = snapshot.data!.docs;
                        final startIndex = _currentPage * _rowsPerPage;
                        final endIndex = (startIndex + _rowsPerPage < data.length) ? startIndex + _rowsPerPage : data.length;

                        return Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Username', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Password', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                  rows: List.generate(
                                    endIndex - startIndex,
                                    (index) {
                                      final doc = data[startIndex + index];
                                      final username = doc['username'] ?? '';
                                      final password = doc['password'] ?? '';

                                      return DataRow(
                                        cells: [
                                          DataCell(Text(username)),
                                          DataCell(Text(password)),
                                          DataCell(
                                            DropdownButton<String>(
                                              value: selectedValue,
                                              icon: const Icon(Icons.more_vert),
                                              underline: Container(),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  selectedValue = newValue;
                                                  if (newValue == 'Edit') {
                                                    _showEditDialog(doc);
                                                  } else if (newValue == 'Delete') {
                                                    _showDeleteDialog(doc);
                                                  }
                                                });
                                              },
                                              items: <String>['Edit', 'Delete'].map<DropdownMenuItem<String>>((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            // Pagination
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  (data.length / _rowsPerPage).ceil(),
                                  (index) => Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _currentPage = index;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _currentPage == index ? const Color(0xdd1E1E1E) : Colors.white,
                                        foregroundColor: _currentPage == index ? Colors.white : const Color(0xdd1E1E1E),
                                      ),
                                      child: Text((index + 1).toString()),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
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

  void _showEditDialog(QueryDocumentSnapshot doc) {
    final usernameController = TextEditingController(text: doc['username']);
    final passwordController = TextEditingController(text: doc['password']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Admin Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                await doc.reference.update({
                  'username': usernameController.text,
                  'password': passwordController.text,
                });

                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xdd1E1E1E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).then((_) {
      usernameController.dispose();
      passwordController.dispose();
    });
  }

  void _showDeleteDialog(QueryDocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this admin account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await doc.reference.delete();
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account deleted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _formContainer(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.only(left: 10),
          width: 300,
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 1, color: const Color(0xddDADADA)),
          ),
          child: TextField(
            style: const TextStyle(fontSize: 13.0),
            controller: controller,
            decoration: const InputDecoration(border: InputBorder.none),
            obscureText: label == 'Password:',
          ),
        )
      ],
    );
  }
}
