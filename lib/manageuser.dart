import 'package:bogsandmila/logo.dart';
import 'package:bogsandmila/services.dart';
import 'package:flutter/material.dart';

class ManageUserPage extends StatefulWidget {
  final String uid;
  final String type;

  const ManageUserPage({super.key, required this.uid, required this.type});

  @override
  _ManageUserPageState createState() => _ManageUserPageState();
}

class _ManageUserPageState extends State<ManageUserPage> {
  final _formKey = GlobalKey<FormState>();
  final firstname = TextEditingController();
  final middlename = TextEditingController();
  final lastname = TextEditingController();
  final contactnumber = TextEditingController();
  final buildingnumber = TextEditingController();
  final unitnumber = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    firstname.dispose();
    middlename.dispose();
    lastname.dispose();
    contactnumber.dispose();
    buildingnumber.dispose();
    unitnumber.dispose();
    username.dispose();
    password.dispose();
    super.dispose();
  }

  void _clearFields() {
    for (final controller in [
      firstname,
      middlename,
      lastname,
      contactnumber,
      buildingnumber,
      unitnumber,
      username,
      password,
    ]) {
      controller.clear();
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => isLoading = true);

    await Services().CreateManageUser(
      firstname.text,
      middlename.text,
      lastname.text,
      contactnumber.text,
      buildingnumber.text,
      unitnumber.text,
      username.text,
      password.text,
    );

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create account successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    _clearFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back button added here
                      Align(
                        alignment: Alignment.topLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.black),
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
                      LogoPage(uid: widget.uid, type: widget.type),
                      const SizedBox(height: 30),
                      const Text(
                        'Tenant Registration',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 24),
                      ),
                      const SizedBox(height: 30),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _rowInputs([
                              _formContainer("First Name:", firstname),
                              _formContainer("M.I:", middlename),
                            ]),
                            const SizedBox(height: 20),
                            _rowInputs([
                              _formContainer("Last Name:", lastname),
                              _formContainer("Contact Number:", contactnumber),
                            ]),
                            const SizedBox(height: 20),
                            _rowInputs([
                              _formContainer(
                                  "Building Number:", buildingnumber),
                              _formContainer("Unit Number:", unitnumber),
                            ]),
                            const SizedBox(height: 20),
                            _rowInputs([
                              _formContainer("Username:", username),
                              _formContainer("Password:", password,
                                  isPassword: true),
                            ]),
                            const SizedBox(height: 30),
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: 200,
                                height: 40,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(228, 12, 12, 12),
                                    shadowColor: const Color(0x661E1E1E),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  onPressed: isLoading ? null : _submitForm,
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Register Account',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: const Color.fromARGB(255, 30, 30, 30),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: const Center(
              child: Text(
                'Copyright © Bogs and Mila Apartment. All Rights Reserved.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formContainer(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        const SizedBox(height: 5),
        SizedBox(
          width: 300,
          height: 45,
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Required' : null,
            style: const TextStyle(fontSize: 13.0),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(left: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xddDADADA)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _rowInputs(List<Widget> inputs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: inputs,
    );
  }
}
