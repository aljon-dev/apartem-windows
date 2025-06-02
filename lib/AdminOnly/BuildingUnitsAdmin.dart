import 'package:bogsandmila/AdminOnly/TenantPage.dart';
import 'package:bogsandmila/TransactionDetailsPage.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BuildingUnitsAdminDesktop extends StatefulWidget {
  String userId;
  BuildingUnitsAdminDesktop({super.key, required this.userId});

  @override
  State<BuildingUnitsAdminDesktop> createState() => _BuildingUnitsDesktopState();
}

class _BuildingUnitsDesktopState extends State<BuildingUnitsAdminDesktop> {
  final _firestore = FirebaseFirestore.instance;
  final _scrollController = ScrollController();
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        width: 400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _addBuilding() async {
    final formKey = GlobalKey<FormState>();
    final buildingNameController = TextEditingController();
    final buildingUnitController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Building'),
          content: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: buildingNameController,
                    decoration: const InputDecoration(
                      labelText: 'Building Number',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter building number' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: buildingUnitController,
                    decoration: const InputDecoration(
                      labelText: 'Number of Units',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter number of units' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final buildingNumber = int.parse(buildingNameController.text);
                    final existingBuilding = await _firestore.collection('building').where('building', isEqualTo: buildingNumber).get();

                    if (existingBuilding.docs.isNotEmpty) {
                      _showSnackbar('Building already exists', Colors.red);
                      return;
                    }

                    final buildingRef = await _firestore.collection('building').add({
                      'building': buildingNumber,
                      'available': int.parse(buildingUnitController.text),
                    });

                    await _showUnitCreationDialog(
                      int.parse(buildingUnitController.text),
                      buildingRef.id,
                      buildingNumber,
                    );

                    _showSnackbar('Building added successfully', Colors.green);
                    Navigator.pop(context);
                  } catch (e) {
                    _showSnackbar('Error: ${e.toString()}', Colors.red);
                  }
                }
              },
              child: const Text('Add Building'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUnitCreationDialog(int unitCount, String buildingId, int buildingNumber) async {
    final unitControllers = List.generate(unitCount, (index) => TextEditingController());
    final unitTypeControllers = List.generate(unitCount, (index) => TextEditingController());
    final unitTypes = ['Studio Type', 'Bedroom Type', 'Bungalow Type'];

    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(40),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Unit Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Scrollbar(
                    controller: _scrollController,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: List.generate(unitCount, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Unit ${index + 1}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: unitControllers[index],
                                      decoration: const InputDecoration(
                                        labelText: 'Unit Number',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                      hint: const Text('Select Unit Type'),
                                      items: unitTypes.map((type) {
                                        return DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        unitTypeControllers[index].text = value!;
                                      },
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () async {
                        try {
                          for (int i = 0; i < unitCount; i++) {
                            if (unitControllers[i].text.isEmpty || unitTypeControllers[i].text.isEmpty) {
                              _showSnackbar('Please fill all fields', Colors.red);
                              return;
                            }

                            await _firestore.collection('UnitNumber').add({
                              'buildingId': buildingId,
                              'unitNumber': int.parse(unitControllers[i].text),
                              'unitType': unitTypeControllers[i].text,
                              'isOccupied': false,
                              'building#': buildingNumber,
                            });
                          }
                          _showSnackbar('Units added successfully', Colors.green);
                          Navigator.pop(context);
                        } catch (e) {
                          _showSnackbar('Error adding units: $e', Colors.red);
                        }
                      },
                      child: const Text('Save All Units'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBuildingCard(DocumentSnapshot building) {
    final buildingNumber = building['building'];
    final availableUnits = building['available'];

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('UnitNumber').where('building#', isEqualTo: buildingNumber).snapshots(),
      builder: (context, unitSnapshot) {
        if (!unitSnapshot.hasData) return const SizedBox();

        final totalUnits = unitSnapshot.data!.docs.length;
        final occupiedUnits = unitSnapshot.data!.docs.where((unit) => unit['isOccupied'] == true).length;
        final available = totalUnits - occupiedUnits;
        final fullyOccupied = available == 0;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // Navigate to building detail view
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.apartment,
                    size: 40,
                    color: fullyOccupied ? Colors.red : Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Building $buildingNumber',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$occupiedUnits/$totalUnits occupied',
                    style: TextStyle(
                      color: fullyOccupied ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TenantPage(
                                      buildingnumber: buildingNumber.toString(),
                                    )));
                      },
                      child: const Text('View Tenants'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: IconButton(
          icon: Row(
            children: [
              Icon(Icons.arrow_back),
              Text('Back'),
            ],
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Building Management',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Icon(Icons.circle, size: 12, color: Colors.green),
                SizedBox(width: 8),
                Text('Vacant units available'),
                SizedBox(width: 24),
                Icon(Icons.circle, size: 12, color: Colors.red),
                SizedBox(width: 8),
                Text('Fully occupied'),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('building').orderBy('building').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final buildings = snapshot.data!.docs.where((building) {
                    if (_searchQuery.isEmpty) return true;
                    return building['building'].toString().contains(_searchQuery);
                  }).toList();

                  if (buildings.isEmpty) {
                    return const Center(child: Text('No buildings found'));
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: buildings.length,
                    itemBuilder: (context, index) {
                      return _buildBuildingCard(buildings[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
