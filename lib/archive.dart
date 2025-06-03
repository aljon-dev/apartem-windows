import 'package:bogsandmila/logo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({
    super.key,
  });

  @override
  _ArchivePageState createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  final int _rowsPerPage = 10;
  int _currentPage = 0;
  final TextEditingController _reasonController = TextEditingController();
  String? _selectedTenantId;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // Helper method to filter buildings with available units
  Future<List<DocumentSnapshot>> _getBuildingsWithAvailableUnits() async {
    final buildingsSnapshot =
        await FirebaseFirestore.instance.collection('building').get();

    List<DocumentSnapshot> availableBuildings = [];

    for (var building in buildingsSnapshot.docs) {
      final buildingNumber = building['building'].toString();
      final unitsQuery = await FirebaseFirestore.instance
          .collection('UnitNumber')
          .where('building#', isEqualTo: int.tryParse(buildingNumber))
          .where('isOccupied', isEqualTo: false)
          .limit(1)
          .get();

      if (unitsQuery.docs.isNotEmpty) {
        availableBuildings.add(building);
      }
    }

    return availableBuildings;
  }

  Future<void> _showEditAndUnarchiveDialog(
      String tenantId, Map<String, dynamic> tenantData) async {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController _firstNameController = TextEditingController();
    final TextEditingController _lastNameController = TextEditingController();
    final TextEditingController _middleNameController = TextEditingController();
    final TextEditingController _contactNumberController =
        TextEditingController();
    final TextEditingController _rentalFeeController = TextEditingController();
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();

    // Pre-fill the form with existing data
    _firstNameController.text = tenantData['firstname'] ?? '';
    _lastNameController.text = tenantData['lastname'] ?? '';
    _middleNameController.text = tenantData['middlename'] ?? '';
    _contactNumberController.text = tenantData['contactnumber'] ?? '';
    _rentalFeeController.text = (tenantData['rentalfee'] ?? 0).toString();
    _usernameController.text = tenantData['username'] ?? '';
    _emailController.text = tenantData['email'] ?? '';
    // Initialize dropdown values
    String? selectedBuilding;
    String? selectedUnit = tenantData['unitnumber']?.toString();
    String profile = tenantData['profile'].toString();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.edit,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Edit and Un-archive Tenant',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(maxHeight: 500),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Personal Information Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: InputDecoration(
                                labelText: 'First Name',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter first name';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: InputDecoration(
                                labelText: 'Last Name',
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter last name';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _middleNameController,
                        decoration: InputDecoration(
                          labelText: 'Middle Name (Optional)',
                          prefixIcon: const Icon(Icons.person_2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _contactNumberController,
                        decoration: InputDecoration(
                          labelText: 'Contact Number',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter contact number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Property Information Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Property Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: FutureBuilder<List<DocumentSnapshot>>(
                              future: _getBuildingsWithAvailableUnits(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                if (snapshot.hasError) {
                                  return const Text('Error loading buildings');
                                }

                                final availableBuildings = snapshot.data ?? [];

                                if (availableBuildings.isEmpty) {
                                  return const Text(
                                      'No buildings with available units');
                                }

                                return DropdownButtonFormField<String>(
                                  value: selectedBuilding,
                                  decoration: InputDecoration(
                                    labelText: 'Building Number',
                                    prefixIcon: const Icon(Icons.apartment),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 16,
                                    ),
                                  ),
                                  items: availableBuildings
                                      .map((DocumentSnapshot document) {
                                    Map<String, dynamic> data =
                                        document.data() as Map<String, dynamic>;
                                    String buildingNumber =
                                        data['building'].toString();
                                    return DropdownMenuItem<String>(
                                      value: buildingNumber,
                                      child: Text(buildingNumber),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedBuilding = newValue;
                                      selectedUnit = null;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a building';
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: selectedBuilding != null
                                  ? FirebaseFirestore.instance
                                      .collection('UnitNumber')
                                      .where('building#',
                                          isEqualTo:
                                              int.tryParse(selectedBuilding!))
                                      .where('isOccupied', isEqualTo: false)
                                      .snapshots()
                                  : const Stream.empty(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return const Text('Error loading units');
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }

                                if (selectedBuilding == null) {
                                  return DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Unit Number',
                                      prefixIcon:
                                          const Icon(Icons.door_front_door),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 16,
                                      ),
                                    ),
                                    items: const [],
                                    onChanged: null,
                                    hint: const Text('Select building first'),
                                  );
                                }

                                final units = snapshot.data?.docs ?? [];
                                final Set<String> uniqueUnitNumbers = {};
                                final List<DropdownMenuItem<String>>
                                    uniqueUnitItems = [];

                                for (DocumentSnapshot document in units) {
                                  Map<String, dynamic> data =
                                      document.data() as Map<String, dynamic>;
                                  String unitNumber =
                                      data['unitNumber'].toString();

                                  if (!uniqueUnitNumbers.contains(unitNumber)) {
                                    uniqueUnitNumbers.add(unitNumber);
                                    uniqueUnitItems.add(
                                      DropdownMenuItem<String>(
                                        value: unitNumber,
                                        child: Text(unitNumber),
                                      ),
                                    );
                                  }
                                }

                                uniqueUnitItems.sort((a, b) {
                                  final aNum = int.tryParse(a.value!);
                                  final bNum = int.tryParse(b.value!);
                                  if (aNum != null && bNum != null) {
                                    return aNum.compareTo(bNum);
                                  }
                                  return a.value!.compareTo(b.value!);
                                });

                                bool isValidUnitSelection = selectedUnit !=
                                        null &&
                                    uniqueUnitNumbers.contains(selectedUnit);

                                return DropdownButtonFormField<String>(
                                  value: isValidUnitSelection
                                      ? selectedUnit
                                      : null,
                                  decoration: InputDecoration(
                                    labelText: 'Unit Number',
                                    prefixIcon:
                                        const Icon(Icons.door_front_door),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 16,
                                    ),
                                  ),
                                  items: uniqueUnitItems,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedUnit = newValue;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a unit';
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _rentalFeeController,
                        decoration: InputDecoration(
                          labelText: 'Rental Fee',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter rental fee';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Account Information Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Account Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: const Icon(Icons.account_circle),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter username';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        Map<String, dynamic> updatedTenantData = {
                          'firstname': _firstNameController.text.trim(),
                          'lastname': _lastNameController.text.trim(),
                          'middlename': _middleNameController.text.trim(),
                          'contactnumber': _contactNumberController.text.trim(),
                          'buildingnumber': selectedBuilding ?? '0',
                          'password': _firstNameController.text +
                              _lastNameController.text +
                              selectedUnit.toString() +
                              selectedBuilding.toString(),
                          'unitnumber': selectedUnit ?? '0',
                          'rentalfee':
                              int.tryParse(_rentalFeeController.text) ?? 0,
                          'username': _usernameController.text.trim(),
                          'email': _emailController.text,
                          'profile': profile,
                        };

                        await FirebaseFirestore.instance
                            .collection('tenant')
                            .doc(tenantId)
                            .set(updatedTenantData);

                        await FirebaseFirestore.instance
                            .collection('Archive')
                            .doc(tenantId)
                            .delete();

                        final unitQuery = await FirebaseFirestore.instance
                            .collection('UnitNumber')
                            .where('unitNumber',
                                isEqualTo:
                                    int.tryParse(selectedUnit.toString()))
                            .where('building#',
                                isEqualTo:
                                    int.tryParse(selectedBuilding.toString()))
                            .get();

                        if (unitQuery.docs.isNotEmpty) {
                          await unitQuery.docs.first.reference
                              .update({'isOccupied': true});
                        }

                        if (mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.save, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Save and Un-archive',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _showDeleteConfirmation(
      String tenantId, String tenantName) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permanently Delete Tenant'),
          content: Text(
              'Are you sure you want to permanently delete $tenantName? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteTenant(tenantId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete Permanently'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTenant(String tenantId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Archive')
          .doc(tenantId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tenant permanently deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  String _getInitials(String firstName, String lastName) {
    if (firstName.isEmpty && lastName.isEmpty) return '?';
    if (firstName.isEmpty) return lastName[0].toUpperCase();
    if (lastName.isEmpty) return firstName[0].toUpperCase();
    return '${firstName[0].toUpperCase()}${lastName[0].toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    List<String> dropdownItems = ['Edit and Un-archive', 'Delete Permanently'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                // Header with back button
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(context),
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

                // Logo and title
                LogoPage(),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  color: const Color.fromARGB(240, 17, 17, 17),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image: AssetImage('assets/manageuser.png'),
                        width: 40,
                      ),
                      SizedBox(width: 20),
                      Text(
                        'Archived Tenants',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 23,
                        ),
                      ),
                    ],
                  ),
                ),

                // Main content
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Archive')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Something went wrong'));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final data = snapshot.data!.docs;
                      final startIndex = _currentPage * _rowsPerPage;
                      final endIndex = (startIndex + _rowsPerPage < data.length)
                          ? startIndex + _rowsPerPage
                          : data.length;

                      if (data.isEmpty) {
                        return const Center(
                          child: Text(
                            'No archived tenants found',
                            style: TextStyle(fontSize: 18),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Profile')),
                                  DataColumn(label: Text('Payer Name')),
                                  DataColumn(label: Text('email')),
                                  DataColumn(label: Text('Building')),
                                  DataColumn(label: Text('Unit')),
                                  DataColumn(label: Text('Contact')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: List.generate(
                                  endIndex - startIndex,
                                  (index) {
                                    final doc = data[startIndex + index];
                                    final profile = (doc.data() as Map<String,
                                            dynamic>)['profile'] ??
                                        '';
                                    final firstname = doc['firstname'] ?? '';
                                    final email = doc['email'] ?? '';
                                    final lastname = doc['lastname'] ?? '';
                                    final buildingnumber =
                                        doc['buildingnumber'] ?? '';
                                    final unitnumber = doc['unitnumber'] ?? '';
                                    final contactnumber =
                                        doc['contactnumber'] ?? '';
                                    final tenantId = doc.id;

                                    return DataRow(
                                      cells: [
                                        DataCell(_buildProfileWidget(
                                          profile,
                                          firstname,
                                          lastname,
                                        )),
                                        DataCell(Text('$firstname $lastname')),
                                        DataCell(Text('$email')),
                                        DataCell(Text(buildingnumber)),
                                        DataCell(Text(unitnumber)),
                                        DataCell(Text(contactnumber)),
                                        DataCell(
                                          DropdownButton<String>(
                                            value: null,
                                            hint: const Text('Actions'),
                                            icon: const FaIcon(FontAwesomeIcons
                                                .ellipsisVertical),
                                            onChanged: (String? newValue) {
                                              if (newValue ==
                                                  'Edit and Un-archive') {
                                                _showEditAndUnarchiveDialog(
                                                  tenantId,
                                                  doc.data()
                                                      as Map<String, dynamic>,
                                                );
                                              } else if (newValue ==
                                                  'Delete Permanently') {
                                                _showDeleteConfirmation(
                                                  tenantId,
                                                  '$firstname $lastname',
                                                );
                                              }
                                            },
                                            items: dropdownItems
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
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

                          // Pagination controls
                          if (data.length > _rowsPerPage)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
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
                                        backgroundColor: _currentPage == index
                                            ? const Color(0xdd1E1E1E)
                                            : Colors.white,
                                        foregroundColor: _currentPage == index
                                            ? Colors.white
                                            : const Color(0xdd1E1E1E),
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

  Widget _buildProfileWidget(
      String? profileUrl, String firstName, String lastName) {
    return GestureDetector(
      onTap: () {
        if (profileUrl != null && profileUrl.isNotEmpty) {
          _showImageDialog(profileUrl);
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[300],
        ),
        child: profileUrl != null && profileUrl.isNotEmpty
            ? ClipOval(
                child: Image.network(
                  profileUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        _getInitials(firstName, lastName),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              )
            : Center(
                child: Text(
                  _getInitials(firstName, lastName),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
      ),
    );
  }
}
