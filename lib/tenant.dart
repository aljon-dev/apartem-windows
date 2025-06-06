import 'package:bogsandmila/logo.dart';
import 'package:bogsandmila/message.dart';

import 'package:bogsandmila/saleRecordingInfoPage.dart';
import 'package:bogsandmila/tenantsalesrecord.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:emailjs/emailjs.dart' as emailjs;

class TenantPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables

  // ignore: prefer_typing_uninitialized_variables
  final userid;
  final buildingnumber;
  const TenantPage(
      {super.key, required this.buildingnumber, required this.userid});

  @override
  // ignore: library_private_types_in_public_api
  _TenantPageState createState() => _TenantPageState();
}

class _TenantPageState extends State<TenantPage> {
  String? _selectedUnitNumber;

  late String selectedBuildingNumber;

  @override
  void initState() {
    super.initState();
    selectedBuildingNumber = widget.buildingnumber.toString();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _rowsPerPage = 10;
  int _currentPage = 0;
  String? selectedValue;

  String vacantValue = 'Yes';
  String? paymentValue;
  Future<void> _AssignTenantUserBuilding(int buildingNumber) async {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final middleNameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final contactController = TextEditingController();
    final rentalFeeController = TextEditingController();
    final emailController = TextEditingController();

    String? selectedUnitNumber;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    bool isShowPassword = false;

    // Get available units first
    final unitsSnapshot = await _firestore
        .collection('UnitNumber')
        .where('building#', isEqualTo: buildingNumber)
        .where('isOccupied', isEqualTo: false)
        .get();

    if (unitsSnapshot.docs.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No available units'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    String? selectedBuilding;
    List<String> availableUnits = [];

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogSetState) {
            return AlertDialog(
              title: const Text('Assign Tenant'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('building')
                            .orderBy('building')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Error loading buildings');
                          }
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          final buildings = snapshot.data!.docs;
                          final sortedUnits = [
                            ...availableUnits
                          ] // copy the list
                            ..sort(
                                (a, b) => int.parse(a).compareTo(int.parse(b)));
                          return Column(
                            children: [
                              DropdownButtonFormField<String>(
                                value: selectedBuilding,
                                decoration: InputDecoration(
                                  labelText: 'Select Building',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.filter_alt),
                                ),
                                items: buildings.map((doc) {
                                  final number = doc['building'].toString();
                                  return DropdownMenuItem(
                                    value: number,
                                    child: Text('Building $number'),
                                  );
                                }).toList(),
                                onChanged: (value) async {
                                  dialogSetState(() {
                                    selectedBuilding = value;
                                    selectedUnitNumber = null;
                                    availableUnits = [];
                                  });

                                  if (value != null) {
                                    final unitSnap = await _firestore
                                        .collection('UnitNumber')
                                        .where('building#',
                                            isEqualTo: int.parse(value))
                                        .where('isOccupied', isEqualTo: false)
                                        .get();

                                    dialogSetState(() {
                                      availableUnits = unitSnap.docs
                                          .map((doc) =>
                                              doc['unitNumber'].toString())
                                          .toList();
                                    });
                                  }
                                },
                                validator: (value) => value == null
                                    ? 'Please select a building'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: selectedUnitNumber,
                                decoration: const InputDecoration(
                                  labelText: 'Select Unit',
                                  border: OutlineInputBorder(),
                                ),
                                items: sortedUnits.map((unit) {
                                  return DropdownMenuItem(
                                    value: unit,
                                    child: Text('Unit $unit'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  dialogSetState(() {
                                    selectedUnitNumber = value;
                                  });
                                },
                                validator: (value) => value == null
                                    ? 'Please select a unit number'
                                    : null,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter first name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter last name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: middleNameController,
                        decoration: const InputDecoration(
                          labelText: 'Middle Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: !isShowPassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              dialogSetState(() {
                                isShowPassword = !isShowPassword;
                              });
                            },
                            icon: Icon(
                              isShowPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email address';
                          }
                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: contactController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Contact Number',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter contact number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: rentalFeeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Rental Fee',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter rental fee';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final username = usernameController.text.trim();
                      final contact = contactController.text.trim();

                      final existingUser = await _firestore
                          .collection('tenant')
                          .where('username', isEqualTo: username)
                          .get();
                      if (existingUser.docs.isNotEmpty) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Username already exists'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                        return;
                      }

                      // Validate contact number: must be exactly 11 digits and numeric
                      final contactRegExp = RegExp(r'^\d{11}$');
                      if (!contactRegExp.hasMatch(contact)) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Invalid contact number (must be 11 digits)'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                        return;
                      }

                      try {
                        final tenantDoc =
                            await _firestore.collection('tenant').add({
                          'firstname': firstNameController.text,
                          'lastname': lastNameController.text,
                          'middlename': middleNameController.text,
                          'unitnumber': selectedUnitNumber,
                          'username': username,
                          'password': passwordController.text,
                          'contactnumber': contact,
                          'buildingnumber': selectedBuilding,
                          'rentalfee': int.parse(rentalFeeController.text),
                          'email': emailController.text,
                          'profile': '',
                        });

                        final unitQuery = await _firestore
                            .collection('UnitNumber')
                            .where('unitNumber',
                                isEqualTo: int.tryParse(selectedUnitNumber!))
                            .where('building#',
                                isEqualTo: int.tryParse(selectedBuilding!))
                            .get();
                        if (unitQuery.docs.isNotEmpty) {
                          await unitQuery.docs.first.reference
                              .update({'isOccupied': true});
                        }

                        final now = DateTime.now();
                        final currentMonth = DateFormat('MMMM').format(now);
                        final currentYear = now.year.toString();
                        final formattedDateTime =
                            DateFormat('yyyy-MM-dd – HH:mm').format(now);
                        final dueDate = now.add(const Duration(days: 30));
                        final formattedDueDate =
                            DateFormat('dd/MM/yyyy').format(dueDate);
                        final existingRecord = await _firestore
                            .collection('sales_record')
                            .where('uid', isEqualTo: tenantDoc.id)
                            .where('month', isEqualTo: currentMonth)
                            .where('year', isEqualTo: currentYear)
                            .get();

                        if (existingRecord.docs.isEmpty) {
                          await _firestore.collection('sales_record').add({
                            'datetime': formattedDateTime,
                            'due_date': formattedDueDate,
                            'due_day': dueDate.day,
                            'due_month_number': dueDate.month,
                            'due_year': dueDate.year,
                            'month': currentMonth,
                            'payer_name':
                                '${firstNameController.text} ${lastNameController.text}',
                            'rental_cost': int.parse(rentalFeeController.text),
                            'status': 'Unpaid',
                            'uid': tenantDoc.id,
                            'year': currentYear,
                          });
                        }
                        await _firestore.collection('sales_record').add({
                          'datetime': formattedDateTime,
                          'due_date': formattedDueDate,
                          'due_day': dueDate.day,
                          'due_month_number': dueDate.month,
                          'due_year': dueDate.year,
                          'month': currentMonth,
                          'payer_name':
                              '${firstNameController.text} ${lastNameController.text}',
                          'rental_cost': int.parse(rentalFeeController.text),
                          'status': 'Unpaid',
                          'uid': tenantDoc.id,
                          'year': currentYear,
                        });

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tenant assigned successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Assign Tenant'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> ResetPassword(
      BuildContext context, QueryDocumentSnapshot doc) async {
    // First show confirmation dialog
    bool confirmReset = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Password Reset'),
          content: const Text(
              'Are you sure you want to reset this tenant\'s password? A new password will be emailed to them.'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text('Reset Password'),
            ),
          ],
        );
      },
    );

    // If user didn't confirm, exit the function
    if (confirmReset != true) return;

    // Get tenant data
    final tenantData = doc.data() as Map<String, dynamic>;

    String firstname = tenantData['firstname'] ?? '';
    String lastname = tenantData['lastname'] ?? '';
    String email = tenantData['email'] ?? '';
    String building = tenantData['buildingnumber'] ?? '';
    String unitnumber = tenantData['unitnumber'] ?? '';

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resetting password...'),
        duration: Duration(seconds: 2),
      ),
    );

    // Generate password - consider using a more secure method
    String generatedPassword = '$firstname$lastname$building$unitnumber';

    try {
      // Send email with new password
      await emailjs.send(
        'service_ralmb2g',
        'template_rahmraj',
        {
          'email': email,
          'name': '$firstname $lastname',
          'password': generatedPassword,
        },
        const emailjs.Options(
          publicKey: 'VyqEOTlbKR9yzkJ2H',
          privateKey: '33HeQw8TVZFY62e2b6WjK',
        ),
      );

      // Update password in Firestore
      await _firestore
          .collection('tenant')
          .doc(doc.id)
          .update({'password': generatedPassword});

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to $email'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reset password: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showEditTenantDialog(QueryDocumentSnapshot doc) async {
    // Get current tenant data
    final tenantData = doc.data() as Map<String, dynamic>;

    // Form controllers initialized with current values
    final firstNameController =
        TextEditingController(text: tenantData['firstname']);
    final lastNameController =
        TextEditingController(text: tenantData['lastname']);
    final middleNameController =
        TextEditingController(text: tenantData['middlename'] ?? '');
    final usernameController =
        TextEditingController(text: tenantData['username']);
    final contactController =
        TextEditingController(text: tenantData['contactnumber']);
    final rentalFeeController =
        TextEditingController(text: tenantData['rentalfee']?.toString() ?? '0');

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Tenant Information'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // First Name
                  TextFormField(
                    controller: firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Last Name
                  TextFormField(
                    controller: lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Middle Name
                  TextFormField(
                    controller: middleNameController,
                    decoration: const InputDecoration(
                      labelText: 'Middle Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Username
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Contact Number
                  TextFormField(
                    controller: contactController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Contact Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter contact number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Rental Fee
                  TextFormField(
                    controller: rentalFeeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Rental Fee',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter rental fee';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await doc.reference.update({
                      'firstname': firstNameController.text,
                      'lastname': lastNameController.text,
                      'middlename': middleNameController.text,
                      'username': usernameController.text,
                      'contactnumber': contactController.text,
                      'rentalfee': int.parse(rentalFeeController.text),
                    });

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tenant updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error updating tenant: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );

    // Dispose controllers when dialog is closed
    firstNameController.dispose();
    lastNameController.dispose();
    middleNameController.dispose();
    usernameController.dispose();
    contactController.dispose();
    rentalFeeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> dropdownItems = [
      'Payment',
      'View Sub-Account',
      'Reset Password',
      'Edit',
      'Delete',
      'Message'
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        dataTableTheme: DataTableThemeData(
          headingRowColor: WidgetStateColor.resolveWith(
            (states) => const Color.fromARGB(224, 17, 17, 17),
          ),
          dataRowColor: WidgetStateColor.resolveWith(
            (states) => Colors.white,
          ),
          headingTextStyle: const TextStyle(color: Colors.white),
          dataTextStyle: const TextStyle(color: Colors.black),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: Stack(children: [
          SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LogoPage(),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        color: const Color.fromARGB(240, 17, 17, 17),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 20),
                            Text(
                              'Building # $selectedBuildingNumber',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 23),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Select Building Number',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            StreamBuilder<QuerySnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection('building')
                                                  .snapshots(),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<QuerySnapshot>
                                                      snapshot) {
                                                if (snapshot.hasError) {
                                                  return Container(
                                                    height: 56,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color:
                                                              Colors.red[300]!),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: const Center(
                                                      child: Text(
                                                        'Error loading units',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ),
                                                  );
                                                }

                                                if (!snapshot.hasData) {
                                                  return Container(
                                                    height: 56,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey[300]!),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: const Center(
                                                      child: SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                                strokeWidth: 2),
                                                      ),
                                                    ),
                                                  );
                                                }

                                                final data =
                                                    snapshot.data!.docs;
                                                Set<String> uniqueUnits = {};
                                                for (var doc in data) {
                                                  Map<String, dynamic> docData =
                                                      doc.data() as Map<String,
                                                          dynamic>;
                                                  String BuildingNumber =
                                                      docData['building']
                                                              ?.toString() ??
                                                          '';
                                                  if (BuildingNumber
                                                      .isNotEmpty) {
                                                    uniqueUnits
                                                        .add(BuildingNumber);
                                                  }
                                                }

                                                List<String> sortedUnits =
                                                    uniqueUnits.toList()
                                                      ..sort((a, b) {
                                                        final numA =
                                                            int.tryParse(a);
                                                        final numB =
                                                            int.tryParse(b);
                                                        if (numA != null &&
                                                            numB != null) {
                                                          return numA
                                                              .compareTo(numB);
                                                        }
                                                        return a.compareTo(b);
                                                      });

                                                return Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                        color:
                                                            Colors.grey[300]!),
                                                  ),
                                                  child:
                                                      DropdownButtonFormField<
                                                          String>(
                                                    value:
                                                        selectedBuildingNumber,
                                                    hint: Row(
                                                      children: [
                                                        Icon(Icons.home,
                                                            size: 20,
                                                            color: Colors
                                                                .grey[500]),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(
                                                          'Choose Building number',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[600]),
                                                        ),
                                                      ],
                                                    ),
                                                    items: [
                                                      DropdownMenuItem<String>(
                                                        value: null,
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                                Icons.clear_all,
                                                                size: 20,
                                                                color: Colors
                                                                    .grey[600]),
                                                            const SizedBox(
                                                                width: 8),
                                                            Text(
                                                              'Buildings',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey[600],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      ...sortedUnits.map(
                                                          (String unitnumber) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: unitnumber,
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .apartment,
                                                                  size: 20,
                                                                  color: Colors
                                                                          .blue[
                                                                      600]),
                                                              const SizedBox(
                                                                  width: 8),
                                                              Text(
                                                                'Building $unitnumber',
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ],
                                                    onChanged:
                                                        (String? newValue) {
                                                      setState(() {
                                                        selectedBuildingNumber =
                                                            newValue!;
                                                      });
                                                    },
                                                    decoration:
                                                        const InputDecoration(
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 12),
                                                    ),
                                                    dropdownColor: Colors.white,
                                                    icon: Icon(
                                                        Icons
                                                            .keyboard_arrow_down,
                                                        color:
                                                            Colors.grey[600]),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      if (_selectedUnitNumber != null)
                                        Container(
                                          margin:
                                              const EdgeInsets.only(right: 12),
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                _selectedUnitNumber = null;
                                              });
                                            },
                                            icon: const Icon(Icons.clear,
                                                size: 18),
                                            label: const Text('Clear'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey[100],
                                              foregroundColor: Colors.grey[700],
                                              elevation: 0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                side: BorderSide(
                                                    color: Colors.grey[300]!),
                                              ),
                                            ),
                                          ),
                                        ),
                                      StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('UnitNumber')
                                            .where('building#',
                                                isEqualTo: int.parse(
                                                    selectedBuildingNumber))
                                            .where('isOccupied',
                                                isEqualTo: false)
                                            .snapshots(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<QuerySnapshot>
                                                snapshot) {
                                          if (snapshot.hasError) {
                                            return const Text(
                                                'Something went wrong');
                                          }
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                          if (!snapshot.hasData ||
                                              snapshot.data!.docs.isEmpty) {
                                            return const Text(
                                                'No available units');
                                          }

                                          final unitNumbers = snapshot
                                              .data!.docs
                                              .map((doc) =>
                                                  doc['unitNumber'].toString())
                                              .toList();
                                          final hasAvailableUnits =
                                              unitNumbers.isNotEmpty;

                                          return ElevatedButton.icon(
                                            onPressed: hasAvailableUnits
                                                ? () => _AssignTenantUserBuilding(
                                                    int.parse(
                                                        selectedBuildingNumber))
                                                : null,
                                            icon: const Icon(Icons.person_add,
                                                size: 20),
                                            label: const Text('Add Tenant'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: hasAvailableUnits
                                                  ? Colors.blue[600]
                                                  : Colors.grey[400],
                                              foregroundColor: hasAvailableUnits
                                                  ? Colors.white
                                                  : Colors.grey[600],
                                              elevation:
                                                  hasAvailableUnits ? 2 : 0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        width: double.infinity,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: StreamBuilder<QuerySnapshot>(
                              stream: selectedBuildingNumber == '0'
                                  ? FirebaseFirestore.instance
                                      .collection('tenant')
                                      .snapshots()
                                  : FirebaseFirestore.instance
                                      .collection('tenant')
                                      .where('buildingnumber',
                                          isEqualTo: selectedBuildingNumber)
                                      .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Center(
                                      child: Text('Something went wrong'));
                                }
                                if (!snapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                final data = snapshot.data!.docs;
                                List<QueryDocumentSnapshot> filteredData = data;
                                if (selectedBuildingNumber != null &&
                                    selectedBuildingNumber.isNotEmpty) {
                                  filteredData = data.where((doc) {
                                    final unitnumber = doc['buildingnumber']
                                            ?.toString()
                                            .trim()
                                            .toLowerCase() ??
                                        '';
                                    final selectedUnit = selectedBuildingNumber
                                        .trim()
                                        .toLowerCase();
                                    return unitnumber == selectedUnit;
                                  }).toList();
                                }

                                final startIndex = _currentPage * _rowsPerPage;
                                final endIndex = (startIndex + _rowsPerPage <
                                        filteredData.length)
                                    ? startIndex + _rowsPerPage
                                    : filteredData.length;

                                return Column(
                                  children: [
                                    DataTable(
                                        columnSpacing: 40,
                                        horizontalMargin: 20,
                                        columns: const <DataColumn>[
                                          DataColumn(
                                            label: SizedBox(
                                              width: 80,
                                              child: Text(
                                                'Profile',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: 100,
                                              child: Text(
                                                'Unit Number',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: 150,
                                              child: Text(
                                                'Fullname',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: 120,
                                              child: Text(
                                                'Contact Number',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: 200,
                                              child: Text(
                                                'Email',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: 120,
                                              child: Text(
                                                'Username',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: 100,
                                              child: Text(
                                                'Rental Fee',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width:
                                                  200, // Increased width to prevent overflow
                                              child: Text(
                                                'Action',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        rows: List.generate(
                                          endIndex - startIndex,
                                          (index) {
                                            final doc = filteredData[
                                                startIndex + index];
                                            final firstname =
                                                doc['firstname'] ?? '';
                                            final lastname =
                                                doc['lastname'] ?? '';
                                            final unitnumber =
                                                doc['unitnumber'] ?? '';
                                            final buildingnumber =
                                                doc['buildingnumber'] ?? '';
                                            final userunitnumber =
                                                doc['unitnumber'] ?? '';
                                            final contactnumber =
                                                doc['contactnumber'] ?? '';
                                            final username =
                                                doc['username'] ?? '';
                                            final password =
                                                doc['password'] ?? '';
                                            final email = doc['email'] ??
                                                'No Email Provided Yet';
                                            final data = doc.data()
                                                as Map<String, dynamic>;
                                            final profile =
                                                data.containsKey('profile')
                                                    ? data['profile'] ?? ''
                                                    : '';
                                            final rentalFee = int.parse(
                                                    doc['rentalfee']
                                                        .toString()) ??
                                                '0';

                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (profile.isNotEmpty) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (_) =>
                                                              Dialog(
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            child:
                                                                InteractiveViewer(
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                child: Image
                                                                    .network(
                                                                        profile),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: SizedBox(
                                                      width: 80,
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                            Colors.blue,
                                                        child: profile != ''
                                                            ? ClipOval(
                                                                child: Image
                                                                    .network(
                                                                        profile),
                                                              )
                                                            : Text(
                                                                '${firstname.isNotEmpty ? firstname[0] : ''}${lastname.isNotEmpty ? lastname[0] : ''}',
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 100,
                                                    child: Text(unitnumber,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black)),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 150,
                                                    child: Text(
                                                        '$firstname $lastname',
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black)),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 120,
                                                    child: Text(contactnumber,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black)),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 200,
                                                    child: Text(email,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black)),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 120,
                                                    child: Text(username,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black)),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 100,
                                                    child: Text(
                                                        rentalFee.toString(),
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black)),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width:
                                                        150, // Increased width to accommodate the row of buttons
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        // Message Button
                                                        IconButton(
                                                          icon: const Icon(
                                                              Icons.message,
                                                              size: 18),
                                                          onPressed: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            messagePage(
                                                                              userid: widget.userid,
                                                                              firstname: firstname,
                                                                            )));
                                                          },
                                                          tooltip: 'Message',
                                                        ),
                                                        IconButton(
                                                            onPressed: () {
                                                              // Dropdown for other actions

                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      content:
                                                                          DropdownButton<
                                                                              String>(
                                                                        value:
                                                                            null,
                                                                        underline:
                                                                            Container(),
                                                                        hint: Text(
                                                                            'Select an action'),
                                                                        icon: const Icon(
                                                                            Icons.more_vert),
                                                                        items: [
                                                                          'Payment',
                                                                          'View Sub-Account',
                                                                          'Reset Password',
                                                                          'Edit',
                                                                          'Delete'
                                                                        ].map((String
                                                                            value) {
                                                                          return DropdownMenuItem<
                                                                              String>(
                                                                            value:
                                                                                value,
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                Icon(
                                                                                  value == 'Payment'
                                                                                      ? Icons.payment
                                                                                      : value == 'View Sub-Account'
                                                                                          ? Icons.account_tree
                                                                                          : value == 'Reset Password'
                                                                                              ? Icons.lock_reset
                                                                                              : value == 'Edit'
                                                                                                  ? Icons.edit
                                                                                                  : Icons.delete,
                                                                                  size: 18,
                                                                                ),
                                                                                const SizedBox(width: 8),
                                                                                Text(value),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        }).toList(),
                                                                        onChanged:
                                                                            (String?
                                                                                newValue) async {
                                                                          if (newValue ==
                                                                              'Payment') {
                                                                            Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                  builder: (context) => saleRecordingInfoPage(
                                                                                    uid: doc.id,
                                                                                    firstname: firstname,
                                                                                    lastname: lastname,
                                                                                    buildnumber: selectedBuildingNumber,
                                                                                    unitnumber: unitnumber,
                                                                                  ),
                                                                                ));
                                                                          } else if (newValue ==
                                                                              'View Sub-Account') {
                                                                            showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext context) {
                                                                                return AlertDialog(
                                                                                  title: const Text('Sub Accounts'),
                                                                                  content: SizedBox(
                                                                                    width: double.maxFinite,
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                      children: [
                                                                                        // 👇 Sub-heading below title
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.only(bottom: 8),
                                                                                          child: Text(
                                                                                            'Tenant: ${doc['firstname']} ${doc['lastname']} | Building #: ${doc['buildingnumber']} | Unit #: ${doc['unitnumber']}',
                                                                                            style: const TextStyle(
                                                                                              fontSize: 14,
                                                                                              fontWeight: FontWeight.w500,
                                                                                            ),
                                                                                          ),
                                                                                        ),

                                                                                        // 👇 Sub-account list
                                                                                        SizedBox(
                                                                                          height: 250,
                                                                                          child: StreamBuilder<QuerySnapshot>(
                                                                                            stream: _firestore.collection('Sub-Tenant').where('mainAccountId', isEqualTo: doc.id).snapshots(),
                                                                                            builder: (context, snapshot) {
                                                                                              if (snapshot.hasError) {
                                                                                                return const Text('Error loading sub-accounts');
                                                                                              }
                                                                                              if (!snapshot.hasData) {
                                                                                                return const Center(child: CircularProgressIndicator());
                                                                                              }
                                                                                              if (snapshot.data!.docs.isEmpty) {
                                                                                                return const Center(child: Text('No sub-accounts found'));
                                                                                              }

                                                                                              return ListView.builder(
                                                                                                itemCount: snapshot.data!.docs.length,
                                                                                                itemBuilder: (context, index) {
                                                                                                  final subAccount = snapshot.data!.docs[index];
                                                                                                  return ListTile(
                                                                                                    leading: GestureDetector(
                                                                                                      onTap: () {
                                                                                                        showDialog(
                                                                                                          context: context,
                                                                                                          builder: (_) => Dialog(
                                                                                                            backgroundColor: Colors.transparent,
                                                                                                            child: InteractiveViewer(
                                                                                                              child: ClipRRect(
                                                                                                                borderRadius: BorderRadius.circular(12),
                                                                                                                child: Image.network(
                                                                                                                  subAccount['profileImage'],
                                                                                                                  fit: BoxFit.contain,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        );
                                                                                                      },
                                                                                                      child: CircleAvatar(
                                                                                                        backgroundImage: NetworkImage(subAccount['profileImage']),
                                                                                                      ),
                                                                                                    ),
                                                                                                    title: Text(subAccount['fullname'] ?? 'No name'),
                                                                                                    subtitle: Column(
                                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                      children: [
                                                                                                        Text('Username: ${subAccount['username']}'),
                                                                                                        Text('Contact: ${subAccount['contact']}'),
                                                                                                        Text('Email: ${subAccount['email']}'),
                                                                                                        Text('Remarks: ${subAccount['remarks']}'),
                                                                                                        Text('Building #: ${subAccount['buildingnumber']}'),
                                                                                                        Text('Unit #: ${subAccount['unitnumber']}'),
                                                                                                      ],
                                                                                                    ),
                                                                                                  );
                                                                                                },
                                                                                              );
                                                                                            },
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  actions: [
                                                                                    TextButton(
                                                                                      onPressed: () => Navigator.of(context).pop(),
                                                                                      child: const Text('Close'),
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              },
                                                                            );
                                                                          } else if (newValue ==
                                                                              'Reset Password') {
                                                                            ResetPassword(context,
                                                                                doc);
                                                                          } else if (newValue ==
                                                                              'Edit') {
                                                                            _showEditTenantDialog(doc);
                                                                          } else if (newValue ==
                                                                              'Delete') {
                                                                            Map<String, dynamic>
                                                                                data =
                                                                                doc.data() as Map<String, dynamic>;
                                                                            Map<String, dynamic>
                                                                                ArchiveData =
                                                                                {
                                                                              ...data,
                                                                              'buildingnumber': "001",
                                                                              'unitnumber': "001"
                                                                            };
                                                                            await FirebaseFirestore.instance.collection('Archive').doc(doc.id).set(ArchiveData);
                                                                            await FirebaseFirestore.instance.collection('tenant').doc(doc.id).delete();

                                                                            final unitQuery =
                                                                                await FirebaseFirestore.instance.collection('UnitNumber').where('unitNumber', isEqualTo: int.tryParse(unitnumber)).where('building#', isEqualTo: int.tryParse(widget.buildingnumber)).get();

                                                                            for (var unitDoc
                                                                                in unitQuery.docs) {
                                                                              await FirebaseFirestore.instance.collection('UnitNumber').doc(unitDoc.id).update({
                                                                                'isOccupied': false,
                                                                              });
                                                                            }

                                                                            SuccessMessage('Successfully Deleted');
                                                                          }
                                                                        },
                                                                      ),
                                                                      actions: [
                                                                        ElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            style:
                                                                                ElevatedButton.styleFrom(
                                                                              backgroundColor: Colors.red,
                                                                              foregroundColor: Colors.white,
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                            ),
                                                                            child: const Text('Close'))
                                                                      ],
                                                                    );
                                                                  });
                                                            },
                                                            icon: const Icon(
                                                                Icons
                                                                    .more_vert))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                                backgroundColor: _currentPage ==
                                                        index
                                                    ? const Color(0xdd1E1E1E)
                                                    : Colors.white,
                                                foregroundColor: _currentPage ==
                                                        index
                                                    ? Colors.white
                                                    : const Color(0xdd1E1E1E),
                                              ),
                                              child:
                                                  Text((index + 1).toString()),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ]),
      ),
    );
  }

  SuccessMessage(String label) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(label),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ));
  }
}
