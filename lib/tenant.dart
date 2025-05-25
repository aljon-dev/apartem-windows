import 'package:bogsandmila/logo.dart';
import 'package:bogsandmila/saleRecordingInfoPage.dart';
import 'package:bogsandmila/tenantsalesrecord.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class TenantPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final uid;
  // ignore: prefer_typing_uninitialized_variables
  final type;
  // ignore: prefer_typing_uninitialized_variables
  final buildingnumber;
  const TenantPage({super.key, required this.uid, required this.type, required this.buildingnumber});

  @override
  // ignore: library_private_types_in_public_api
  _TenantPageState createState() => _TenantPageState();
}

class _TenantPageState extends State<TenantPage> {
  String? _selectedUnitNumber;

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
                        await FirebaseFirestore.instance.collection('tenant').add({
                          'firstname': firstNameController.text,
                          'lastname': lastNameController.text,
                          'middlename': middleNameController.text,
                          'unitnumber': selectedUnitNumber,
                          'username': usernameController.text,
                          'password': passwordController.text,
                          'contactnumber': contactController.text,
                          'buildingnumber': buildingNumber.toString(),
                          'rentalfee': int.parse(rentalFeeController.text),
                        });

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
    List<String> dropdownItems = ['Payment', 'View Sub-Account', 'Reset Password', 'Edit', 'Delete'];

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
          dataTextStyle: const TextStyle(color: Colors.white),
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
                          SizedBox(
                            width: 20,
                          ),
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
                          // Filter and Action Section
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section Title

                                // Filter and Button Row
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Unit Number Selection
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Select Unit Number',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          StreamBuilder<QuerySnapshot>(
                                            stream: widget.buildingnumber == '0' ? FirebaseFirestore.instance.collection('tenant').snapshots() : FirebaseFirestore.instance.collection('tenant').where('buildingnumber', isEqualTo: widget.buildingnumber.toString()).snapshots(),
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

                                              // Get unique unit numbers and sort them
                                              Set<String> uniqueUnits = {};
                                              for (var doc in data) {
                                                Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
                                                String unitnumber = docData['unitnumber']?.toString() ?? '';
                                                if (unitnumber.isNotEmpty) {
                                                  uniqueUnits.add(unitnumber);
                                                }
                                              }

                                              List<String> sortedUnits = uniqueUnits.toList()
                                                ..sort((a, b) {
                                                  // Try to sort numerically if possible
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
                                                  value: _selectedUnitNumber,
                                                  hint: Row(
                                                    children: [
                                                      Icon(Icons.home, size: 20, color: Colors.grey[500]),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Choose unit number',
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
                                                            'All Units',
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
                                                              'Unit $unitnumber',
                                                              style: const TextStyle(fontWeight: FontWeight.w500),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ],
                                                  onChanged: (String? newValue) {
                                                    setState(() {
                                                      _selectedUnitNumber = newValue;
                                                    });
                                                  },
                                                  decoration: const InputDecoration(
                                                    border: InputBorder.none,
                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

                                    // Clear Filter Button
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
                                      stream: FirebaseFirestore.instance.collection('UnitNumber').where('building#', isEqualTo: int.parse(widget.buildingnumber)).where('isOccupied', isEqualTo: false).snapshots(),
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
                                          onPressed: hasAvailableUnits ? () => _AssignTenantUserBuilding(int.parse(widget.buildingnumber)) : null,
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
                                    // Add Tenant Button
                                  ],
                                ),

                                // Selected Unit Info
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: widget.buildingnumber == '0' ? FirebaseFirestore.instance.collection('tenant').snapshots() : FirebaseFirestore.instance.collection('tenant').where('buildingnumber', isEqualTo: widget.buildingnumber.toString()).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(child: Text('Something went wrong'));
                          }
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final data = snapshot.data!.docs;
                          List<QueryDocumentSnapshot> filteredData = data;
                          if (_selectedUnitNumber != null && _selectedUnitNumber!.isNotEmpty) {
                            filteredData = data.where((doc) {
                              final unitnumber = doc['unitnumber']?.toString().trim().toLowerCase() ?? '';
                              final selectedUnit = _selectedUnitNumber!.trim().toLowerCase();
                              return unitnumber == selectedUnit;
                            }).toList();
                          }

                          final startIndex = _currentPage * _rowsPerPage;
                          final endIndex = (startIndex + _rowsPerPage < filteredData.length) ? startIndex + _rowsPerPage : filteredData.length;

                          return Column(
                            children: [
                              DataTable(
                                columns: [
                                  DataColumn(
                                    label: Container(
                                      width: MediaQuery.of(context).size.width / 8,
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text(
                                        'Building Number',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Container(
                                      width: MediaQuery.of(context).size.width / 8,
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text(
                                        'Unit Number',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Container(
                                      width: MediaQuery.of(context).size.width / 8,
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text(
                                        'Contact Number',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Container(
                                      width: MediaQuery.of(context).size.width / 8,
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text(
                                        'Username',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Container(
                                      width: MediaQuery.of(context).size.width / 8,
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text(
                                        'Rental Fee',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Container(
                                      width: MediaQuery.of(context).size.width / 8,
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text(
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
                                    final rentalFee = int.parse(doc['rentalfee'].toString()) ?? '0';

                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(buildingnumber, style: const TextStyle(color: Colors.black)),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(unitnumber, style: const TextStyle(color: Colors.black)),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(contactnumber, style: const TextStyle(color: Colors.black)),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: GestureDetector(
                                              child: Text(username, style: const TextStyle(color: Colors.black)),
                                              onTap: () {},
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(rentalFee.toString(), style: const TextStyle(color: Colors.black)),
                                          ),
                                        ),
                                        DataCell(
                                          DropdownButtonFormField<String>(
                                            value: selectedValue,

                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                            icon: const FaIcon(FontAwesomeIcons.ellipsisVertical), // Remove the default dropdown icon
                                            onChanged: (String? newValue) {
                                              setState(() async {
                                                selectedValue = null;

                                                if (newValue == 'Payment') {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => saleRecordingInfoPage(
                                                          uid: doc.id,
                                                          firstname: firstname,
                                                          lastname: lastname,
                                                          buildnumber: widget.buildingnumber,
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
                                                          width: 600, // Allow space for the ListView
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                // Wrap ListView with Flexible
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

                                                                    // Data successfully retrieved
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
                                                              Navigator.of(context).pop(); // Close the dialog
                                                            },
                                                            child: const Text('Close'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              // Save logic based on vacantValue
                                                              Navigator.of(context).pop(); // Close the dialog
                                                            },
                                                            child: const Text('Save'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                } else if (newValue == 'Reset Password') {
                                                  FirebaseFirestore.instance.collection('tenant').doc(doc.id).update({
                                                    'password': '123456789',
                                                  });

                                                  SuccessMessage('Successfully Reset Password');
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
                                              });
                                            },
                                            items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
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
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Admin',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 23),
                          ),
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
      ),
    );
  }

  // ignore: non_constant_identifier_names
  SuccessMessage(String label) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(label),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ));
  }
}
