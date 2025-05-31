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
  const TenantPage({super.key, required this.buildingnumber, required this.userid});

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
    // Form controllers
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController middleNameController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController contactController = TextEditingController();
    final TextEditingController rentalFeeController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

    String? selectedUnitNumber;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    bool isShowPassword = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Move this inside but make it a state variable

            return AlertDialog(
              title: const Text('Assign Tenant User Building'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Unit Number Dropdown
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('UnitNumber').where('building#', isEqualTo: buildingNumber).where('isOccupied', isEqualTo: false).snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Something went wrong');
                          }
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Text('No available units');
                          }

                          final unitNumbers = snapshot.data!.docs.map((doc) => doc['unitNumber'].toString()).toList();

                          return DropdownButtonFormField<String>(
                            value: selectedUnitNumber,
                            hint: const Text('Select Unit Number'),
                            decoration: const InputDecoration(
                              labelText: 'Unit Number',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a unit number';
                              }
                              return null;
                            },
                            items: unitNumbers.map((String unitNumber) {
                              return DropdownMenuItem<String>(
                                value: unitNumber,
                                child: Text(unitNumber),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedUnitNumber = newValue;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // First Name Field
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

                      // Last Name Field
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

                      // Middle Name Field
                      TextFormField(
                        controller: middleNameController,
                        decoration: const InputDecoration(
                          labelText: 'Middle Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Email'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Put your email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Username Field
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

                      // Password Field - FIXED
                      TextFormField(
                        controller: passwordController,
                        obscureText: !isShowPassword, // Fixed logic
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isShowPassword = !isShowPassword;
                              });
                            },
                            icon: Icon(
                              isShowPassword ? Icons.visibility : Icons.visibility_off,
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

                      // Contact Field
                      TextFormField(
                        controller: contactController,
                        keyboardType: TextInputType.number,
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
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
                        // Add tenant to Firestore
                        await FirebaseFirestore.instance.collection('tenant').add({'firstname': firstNameController.text, 'lastname': lastNameController.text, 'middlename': middleNameController.text, 'email': emailController.text, 'unitnumber': selectedUnitNumber, 'username': usernameController.text, 'password': passwordController.text, 'contactnumber': contactController.text, 'buildingnumber': buildingNumber.toString(), 'rentalfee': int.parse(rentalFeeController.text), 'profile': ''});

                        // Update unit occupancy status
                        final unitQuery = await FirebaseFirestore.instance
                            .collection('UnitNumber')
                            .where('unitNumber', isEqualTo: int.tryParse(selectedUnitNumber.toString()))
                            .where('building#', isEqualTo: buildingNumber) // Fixed: use buildingNumber parameter directly
                            .get();

                        if (unitQuery.docs.isNotEmpty) {
                          await unitQuery.docs.first.reference.update({'isOccupied': true});
                        }

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tenant assigned successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        Navigator.of(context).pop();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error assigning tenant: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
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
                  child: const Text('Assign Tenant'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Dispose controllers after dialog is closed
      firstNameController.dispose();
      lastNameController.dispose();
      middleNameController.dispose();
      usernameController.dispose();
      passwordController.dispose();
      contactController.dispose();
      rentalFeeController.dispose(); // Added missing dispose
    });
  }

  Future<void> ResetPassword(BuildContext context, QueryDocumentSnapshot doc) async {
    // First show confirmation dialog
    bool confirmReset = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Password Reset'),
          content: const Text('Are you sure you want to reset this tenant\'s password? A new password will be emailed to them.'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
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
      await _firestore.collection('Tenant').doc(doc.id).update({'password': generatedPassword});

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
    final firstNameController = TextEditingController(text: tenantData['firstname']);
    final lastNameController = TextEditingController(text: tenantData['lastname']);
    final middleNameController = TextEditingController(text: tenantData['middlename'] ?? '');
    final usernameController = TextEditingController(text: tenantData['username']);
    final contactController = TextEditingController(text: tenantData['contactnumber']);
    final rentalFeeController = TextEditingController(text: tenantData['rentalfee']?.toString() ?? '0');

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
    List<String> dropdownItems = ['Payment', 'View Sub-Account', 'Reset Password', 'Edit', 'Delete', 'Message'];

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
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image(
                              image: AssetImage('assets/manageuser.png'),
                              width: 40,
                            ),
                            SizedBox(width: 20),
                            Text(
                              'Tenant',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 23),
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                              stream: FirebaseFirestore.instance.collection('building').snapshots(),
                                              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                if (snapshot.hasError) {
                                                  return Container(
                                                    height: 56,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: Colors.red[300]!),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: const Center(
                                                      child: Text(
                                                        'Error loading units',
                                                        style: TextStyle(color: Colors.red),
                                                      ),
                                                    ),
                                                  );
                                                }

                                                if (!snapshot.hasData) {
                                                  return Container(
                                                    height: 56,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: Colors.grey[300]!),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: const Center(
                                                      child: SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child: CircularProgressIndicator(strokeWidth: 2),
                                                      ),
                                                    ),
                                                  );
                                                }

                                                final data = snapshot.data!.docs;
                                                Set<String> uniqueUnits = {};
                                                for (var doc in data) {
                                                  Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
                                                  String BuildingNumber = docData['building']?.toString() ?? '';
                                                  if (BuildingNumber.isNotEmpty) {
                                                    uniqueUnits.add(BuildingNumber);
                                                  }
                                                }

                                                List<String> sortedUnits = uniqueUnits.toList()
                                                  ..sort((a, b) {
                                                    final numA = int.tryParse(a);
                                                    final numB = int.tryParse(b);
                                                    if (numA != null && numB != null) {
                                                      return numA.compareTo(numB);
                                                    }
                                                    return a.compareTo(b);
                                                  });

                                                return Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(color: Colors.grey[300]!),
                                                  ),
                                                  child: DropdownButtonFormField<String>(
                                                    value: selectedBuildingNumber,
                                                    hint: Row(
                                                      children: [
                                                        Icon(Icons.home, size: 20, color: Colors.grey[500]),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          'Choose Building number',
                                                          style: TextStyle(color: Colors.grey[600]),
                                                        ),
                                                      ],
                                                    ),
                                                    items: [
                                                      DropdownMenuItem<String>(
                                                        value: null,
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.clear_all, size: 20, color: Colors.grey[600]),
                                                            const SizedBox(width: 8),
                                                            Text(
                                                              'Buildings',
                                                              style: TextStyle(
                                                                color: Colors.grey[600],
                                                                fontWeight: FontWeight.w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      ...sortedUnits.map((String unitnumber) {
                                                        return DropdownMenuItem<String>(
                                                          value: unitnumber,
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.apartment, size: 20, color: Colors.blue[600]),
                                                              const SizedBox(width: 8),
                                                              Text(
                                                                'Building $unitnumber',
                                                                style: const TextStyle(fontWeight: FontWeight.w500),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ],
                                                    onChanged: (String? newValue) {
                                                      setState(() {
                                                        selectedBuildingNumber = newValue!;
                                                      });
                                                    },
                                                    decoration: const InputDecoration(
                                                      border: InputBorder.none,
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                    ),
                                                    dropdownColor: Colors.white,
                                                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
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
                                          margin: const EdgeInsets.only(right: 12),
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                _selectedUnitNumber = null;
                                              });
                                            },
                                            icon: const Icon(Icons.clear, size: 18),
                                            label: const Text('Clear'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey[100],
                                              foregroundColor: Colors.grey[700],
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                side: BorderSide(color: Colors.grey[300]!),
                                              ),
                                            ),
                                          ),
                                        ),
                                      StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance.collection('UnitNumber').where('building#', isEqualTo: int.parse(selectedBuildingNumber)).where('isOccupied', isEqualTo: false).snapshots(),
                                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                          if (snapshot.hasError) {
                                            return const Text('Something went wrong');
                                          }
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const Center(child: CircularProgressIndicator());
                                          }
                                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                            return const Text('No available units');
                                          }

                                          final unitNumbers = snapshot.data!.docs.map((doc) => doc['unitNumber'].toString()).toList();
                                          final hasAvailableUnits = unitNumbers.isNotEmpty;

                                          return ElevatedButton.icon(
                                            onPressed: hasAvailableUnits ? () => _AssignTenantUserBuilding(int.parse(selectedBuildingNumber)) : null,
                                            icon: const Icon(Icons.person_add, size: 20),
                                            label: const Text('Add Tenant'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: hasAvailableUnits ? Colors.blue[600] : Colors.grey[400],
                                              foregroundColor: hasAvailableUnits ? Colors.white : Colors.grey[600],
                                              elevation: hasAvailableUnits ? 2 : 0,
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
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
                              stream: selectedBuildingNumber == '0' ? FirebaseFirestore.instance.collection('tenant').snapshots() : FirebaseFirestore.instance.collection('tenant').where('buildingnumber', isEqualTo: selectedBuildingNumber).snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Center(child: Text('Something went wrong'));
                                }
                                if (!snapshot.hasData) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                final data = snapshot.data!.docs;
                                List<QueryDocumentSnapshot> filteredData = data;
                                if (selectedBuildingNumber != null && selectedBuildingNumber.isNotEmpty) {
                                  filteredData = data.where((doc) {
                                    final unitnumber = doc['buildingnumber']?.toString().trim().toLowerCase() ?? '';
                                    final selectedUnit = selectedBuildingNumber.trim().toLowerCase();
                                    return unitnumber == selectedUnit;
                                  }).toList();
                                }

                                final startIndex = _currentPage * _rowsPerPage;
                                final endIndex = (startIndex + _rowsPerPage < filteredData.length) ? startIndex + _rowsPerPage : filteredData.length;

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
                                              width: 200, // Increased width to prevent overflow
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
                                            final doc = filteredData[startIndex + index];
                                            final firstname = doc['firstname'] ?? '';
                                            final lastname = doc['lastname'] ?? '';
                                            final unitnumber = doc['unitnumber'] ?? '';
                                            final buildingnumber = doc['buildingnumber'] ?? '';
                                            final userunitnumber = doc['unitnumber'] ?? '';
                                            final contactnumber = doc['contactnumber'] ?? '';
                                            final username = doc['username'] ?? '';
                                            final password = doc['password'] ?? '';
                                            final email = doc['email'] ?? 'No Email Provided Yet';
                                            final profile = doc['profile'];
                                            final rentalFee = int.parse(doc['rentalfee'].toString()) ?? '0';

                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  SizedBox(
                                                    width: 80,
                                                    child: CircleAvatar(
                                                      backgroundColor: Colors.blue,
                                                      child: profile != ''
                                                          ? ClipOval(
                                                              child: Image.network(profile),
                                                            )
                                                          : Text(
                                                              '${firstname.isNotEmpty ? firstname[0] : ''}${lastname.isNotEmpty ? lastname[0] : ''}',
                                                              style: const TextStyle(color: Colors.white),
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 100,
                                                    child: Text(unitnumber, style: const TextStyle(color: Colors.black)),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 150,
                                                    child: Text('$firstname $lastname', style: const TextStyle(color: Colors.black)),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 120,
                                                    child: Text(contactnumber, style: const TextStyle(color: Colors.black)),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 200,
                                                    child: Text(email, style: const TextStyle(color: Colors.black)),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 120,
                                                    child: Text(username, style: const TextStyle(color: Colors.black)),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 100,
                                                    child: Text(rentalFee.toString(), style: const TextStyle(color: Colors.black)),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 150, // Increased width to accommodate the row of buttons
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        // Message Button
                                                        IconButton(
                                                          icon: const Icon(Icons.message, size: 18),
                                                          onPressed: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => messagePage(
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
                                                                  context: context,
                                                                  builder: (BuildContext context) {
                                                                    return AlertDialog(
                                                                      content: DropdownButton<String>(
                                                                        value: null,
                                                                        underline: Container(),
                                                                        hint: Text('Select an action'),
                                                                        icon: const Icon(Icons.more_vert),
                                                                        items: ['Payment', 'View Sub-Account', 'Reset Password', 'Edit', 'Delete'].map((String value) {
                                                                          return DropdownMenuItem<String>(
                                                                            value: value,
                                                                            child: Row(
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
                                                                        onChanged: (String? newValue) async {
                                                                          if (newValue == 'Payment') {
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
                                                                          } else if (newValue == 'View Sub-Account') {
                                                                            showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext context) {
                                                                                return AlertDialog(
                                                                                  title: const Text('Sub View Account'),
                                                                                  content: SizedBox(
                                                                                    height: 300,
                                                                                    width: 600,
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Expanded(
                                                                                          child: StreamBuilder<QuerySnapshot>(
                                                                                            stream: FirebaseFirestore.instance.collection('Sub-Tenant').where('mainAccountId', isEqualTo: doc.id).snapshots(),
                                                                                            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                                                              if (snapshot.hasError) {
                                                                                                return Text('Something went wrong');
                                                                                              }

                                                                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                                                                return CircularProgressIndicator();
                                                                                              }

                                                                                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                                                                                return Text('No data found');
                                                                                              }

                                                                                              return ListView(
                                                                                                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                                                                                                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                                                                                                  String name = data['name'] ?? 'No name';
                                                                                                  String password = data['password'] ?? 'No password';
                                                                                                  String contact = data['contact'] ?? 'No contact';
                                                                                                  String mainAccountId = data['mainAccountId'] ?? 'No contact';

                                                                                                  return ListTile(
                                                                                                    title: Text(name),
                                                                                                    subtitle: Column(
                                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                      children: [
                                                                                                        Text('Password: $password'),
                                                                                                        Text('Contact: $contact'),
                                                                                                        Text('mainAccountId: $mainAccountId'),
                                                                                                      ],
                                                                                                    ),
                                                                                                  );
                                                                                                }).toList(),
                                                                                              );
                                                                                            },
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  actions: [
                                                                                    TextButton(
                                                                                      onPressed: () {
                                                                                        Navigator.of(context).pop();
                                                                                      },
                                                                                      child: const Text('Close'),
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              },
                                                                            );
                                                                          } else if (newValue == 'Reset Password') {
                                                                            ResetPassword(context, doc);
                                                                          } else if (newValue == 'Edit') {
                                                                            _showEditTenantDialog(doc);
                                                                          } else if (newValue == 'Delete') {
                                                                            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                                                                            Map<String, dynamic> ArchiveData = {...data, 'buildingnumber': "001", 'unitnumber': "001"};
                                                                            await FirebaseFirestore.instance.collection('Archive').doc(doc.id).set(ArchiveData);
                                                                            await FirebaseFirestore.instance.collection('tenant').doc(doc.id).delete();

                                                                            final unitQuery = await FirebaseFirestore.instance.collection('UnitNumber').where('unitNumber', isEqualTo: int.tryParse(unitnumber)).where('building#', isEqualTo: int.tryParse(widget.buildingnumber)).get();

                                                                            for (var unitDoc in unitQuery.docs) {
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
                                                                            onPressed: () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            style: ElevatedButton.styleFrom(
                                                                              backgroundColor: Colors.red,
                                                                              foregroundColor: Colors.white,
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                            ),
                                                                            child: const Text('Close'))
                                                                      ],
                                                                    );
                                                                  });
                                                            },
                                                            icon: const Icon(Icons.more_vert))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        )),
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
