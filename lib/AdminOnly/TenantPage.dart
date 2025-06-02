import 'package:bogsandmila/message.dart';
import 'package:bogsandmila/saleRecordingInfoPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TenantPage extends StatefulWidget {
  final String buildingnumber;
  const TenantPage({super.key, required this.buildingnumber});

  @override
  _TenantPageState createState() => _TenantPageState();
}

class _TenantPageState extends State<TenantPage> {
  String? _selectedUnitNumber;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Replace your _AssignTenantUserBuilding method with this:

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
    final unitsSnapshot = await _firestore.collection('UnitNumber').where('building#', isEqualTo: buildingNumber).where('isOccupied', isEqualTo: false).get();

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
                        stream: _firestore.collection('building').orderBy('building').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Error loading buildings');
                          }
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          final buildings = snapshot.data!.docs;
                          final sortedUnits = [...availableUnits] // copy the list
                            ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
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
                                    final unitSnap = await _firestore.collection('UnitNumber').where('building#', isEqualTo: int.parse(value)).where('isOccupied', isEqualTo: false).get();

                                    dialogSetState(() {
                                      availableUnits = unitSnap.docs.map((doc) => doc['unitNumber'].toString()).toList();
                                    });
                                  }
                                },
                                validator: (value) => value == null ? 'Please select a building' : null,
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
                                validator: (value) => value == null ? 'Please select a unit number' : null,
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
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
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

                      // Check if username already exists
                      final existingUser = await _firestore.collection('tenant').where('username', isEqualTo: username).get();
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
                              content: Text('Invalid contact number (must be 11 digits)'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                        return;
                      }

                      try {
// ✅ Add tenant and get the doc reference
                        final tenantDoc = await _firestore.collection('tenant').add({
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
                        });

// ✅ Mark unit as occupied
                        final unitQuery = await _firestore.collection('UnitNumber').where('unitNumber', isEqualTo: int.tryParse(selectedUnitNumber!)).where('building#', isEqualTo: int.tryParse(selectedBuilding!)).get();
                        if (unitQuery.docs.isNotEmpty) {
                          await unitQuery.docs.first.reference.update({'isOccupied': true});
                        }

// ✅ Now it's safe to use tenantDoc.id
                        final now = DateTime.now();
                        final currentMonth = DateFormat('MMMM').format(now);
                        final currentYear = now.year.toString();
                        final formattedDateTime = DateFormat('yyyy-MM-dd – HH:mm').format(now);
                        final dueDate = now.add(const Duration(days: 30));
                        final formattedDueDate = DateFormat('dd/MM/yyyy').format(dueDate);

// Add auto-generated sales record
                        await _firestore.collection('sales_record').add({
                          'datetime': formattedDateTime,
                          'due_date': formattedDueDate,
                          'due_day': dueDate.day,
                          'due_month_number': dueDate.month,
                          'due_year': dueDate.year,
                          'month': currentMonth,
                          'payer_name': '${firstNameController.text} ${lastNameController.text}',
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

  Future<void> _showEditTenantDialog(QueryDocumentSnapshot doc) async {
    final tenantData = doc.data() as Map<String, dynamic>;
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
          title: const Text('Edit Tenant'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    firstNameController.dispose();
    lastNameController.dispose();
    middleNameController.dispose();
    usernameController.dispose();
    contactController.dispose();
    rentalFeeController.dispose();
  }

  Future<void> _deleteTenant(QueryDocumentSnapshot tenant) async {
    final unitnumber = tenant['unitnumber']?.toString() ?? '';

    try {
      // Archive the tenant
      final tenantData = tenant.data() as Map<String, dynamic>;
      await _firestore.collection('Archive').doc(tenant.id).set({
        ...tenantData,
        'buildingnumber': "001",
        'unitnumber': "001",
      });

      // Delete the tenant
      await _firestore.collection('tenant').doc(tenant.id).delete();

      // Mark unit as unoccupied
      final unitQuery = await _firestore.collection('UnitNumber').where('unitNumber', isEqualTo: int.tryParse(unitnumber)).where('building#', isEqualTo: int.tryParse(widget.buildingnumber)).get();

      for (var unitDoc in unitQuery.docs) {
        await unitDoc.reference.update({'isOccupied': false});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tenant deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting tenant: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back'),
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.grey[900],
            child: const Center(
              child: Text(
                'Tenant Management',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Unit Filter
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore.collection('building').orderBy('building').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Error loading buildings');
                        }
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        final buildingDocs = snapshot.data!.docs;

                        return DropdownButtonFormField<String>(
                          value: _selectedUnitNumber,
                          decoration: InputDecoration(
                            labelText: 'Filter by Building',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.filter_alt),
                          ),
                          items: [
                            ...buildingDocs.map((doc) {
                              final number = doc['building'].toString();
                              return DropdownMenuItem(
                                value: number,
                                child: Text('Building $number'),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedUnitNumber = value;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

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
                  ],
                ),
              ),
            ),
          ),

          // Tenant List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: (_selectedUnitNumber == null || _selectedUnitNumber == 'All') ? _firestore.collection('tenant').snapshots() : _firestore.collection('tenant').where('buildingnumber', isEqualTo: _selectedUnitNumber).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var tenants = snapshot.data!.docs;

                // Apply unit filter if selected
                if (_selectedUnitNumber != null) {
                  tenants = tenants.where((doc) {
                    final bldg = doc['buildingnumber']?.toString() ?? '';
                    return bldg == _selectedUnitNumber;
                  }).toList();
                }

                if (tenants.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tenants found',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Determine the best card width based on available space
                    final cardWidth = constraints.maxWidth > 1000
                        ? constraints.maxWidth * 0.45
                        : constraints.maxWidth > 600
                            ? constraints.maxWidth * 0.7
                            : constraints.maxWidth;

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: cardWidth,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.5,
                      ),
                      itemCount: tenants.length,
                      itemBuilder: (context, index) {
                        final tenant = tenants[index];
                        final name = '${tenant['firstname']} ${tenant['lastname']}';
                        final unit = tenant['unitnumber'] ?? 'N/A';
                        final contact = tenant['contactnumber'] ?? 'N/A';
                        final rent = NumberFormat.currency(symbol: '₱').format(tenant['rentalfee'] ?? 0);
                        final tenantData = tenant.data() as Map<String, dynamic>;
                        final hasProfileImage = tenantData['profile'] != null && tenantData['profile'].toString().isNotEmpty;

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Profile section
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: hasProfileImage
                                          ? () {
                                              showDialog(
                                                context: context,
                                                builder: (_) => Dialog(
                                                  backgroundColor: Colors.transparent,
                                                  child: InteractiveViewer(
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(12),
                                                      child: Image.network(
                                                        tenantData['profile'],
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          : null,
                                      child: CircleAvatar(
                                        radius: 32,
                                        backgroundColor: Colors.blueGrey[200],
                                        backgroundImage: hasProfileImage ? NetworkImage(tenantData['profile']) : null,
                                        child: hasProfileImage
                                            ? null
                                            : Text(
                                                (tenantData['firstname']?.toString().isNotEmpty ?? false) ? tenantData['firstname'].toString()[0].toUpperCase() : '?',
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(width: 16),

                                // Information section
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildInfoRow(Icons.home, 'Unit $unit'),
                                      _buildInfoRow(Icons.phone, contact),
                                      _buildInfoRow(Icons.attach_money, 'Rent: $rent'),
                                    ],
                                  ),
                                ),

                                // Action buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.message, size: 28, color: Colors.blue),
                                      tooltip: 'Send Message',
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => messagePage(firstname: tenantData['firstname'], userid: '')));
                                      },
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        if (value == 'Payment') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => saleRecordingInfoPage(
                                                uid: tenant.id,
                                                firstname: tenant['firstname'],
                                                lastname: tenant['lastname'],
                                                buildnumber: widget.buildingnumber,
                                                unitnumber: tenant['unitnumber'],
                                              ),
                                            ),
                                          );
                                        } else if (value == 'View Sub-Account') {
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
                                                      Padding(
                                                        padding: const EdgeInsets.only(bottom: 8),
                                                        child: Text(
                                                          'Tenant: ${tenant['firstname']} ${tenant['lastname']} | Building #: ${tenant['buildingnumber']} | Unit #: ${tenant['unitnumber']}',
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 250,
                                                        child: StreamBuilder<QuerySnapshot>(
                                                          stream: _firestore.collection('Sub-Tenant').where('mainAccountId', isEqualTo: tenant.id).snapshots(),
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
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'Payment',
                                          child: Text('Payment'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'View Sub-Account',
                                          child: Text('View Sub-Account'),
                                        ),
                                      ],
                                      child: const Icon(Icons.more_vert),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
