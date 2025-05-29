import 'package:bogsandmila/archive.dart';
import 'package:bogsandmila/tenant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class buildingUnits extends StatefulWidget {
  const buildingUnits({super.key});

  @override
  State<buildingUnits> createState() => _buildingUnits();
}

class _buildingUnits extends State<buildingUnits> {
  final _firestore = FirebaseFirestore.instance;

  void _Snackbar(String message, Color color, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> AddBuilding() async {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController buildingname = TextEditingController();
    TextEditingController buildingunit = TextEditingController();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Building Unit'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: buildingname,
                          decoration: const InputDecoration(labelText: 'Building Number', border: OutlineInputBorder()),
                          validator: (value) => value == null || value.isEmpty ? 'PLEASE ENTER BUILDING NUMBER' : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          controller: buildingunit,
                          decoration: const InputDecoration(labelText: 'How many Units in this Building', border: OutlineInputBorder()),
                          validator: (value) => value == null || value.isEmpty ? 'Please Enter Your Number of Units' : null,
                        ),
                      ],
                    ))
              ],
            ),
            actions: [
              TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), foregroundColor: Colors.white, backgroundColor: Colors.red),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel')),
              TextButton.icon(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final Building = await _firestore.collection('building').where('building', isEqualTo: int.parse(buildingname.text)).get();
                      if (Building.docs.isEmpty) {
                        final building = await _firestore.collection('building').add({
                          'building': int.parse(buildingname.text),
                          'available': int.parse(buildingunit.text),
                        });
                        String buildingId = building.id;
                        await getBuildingUnits(int.parse(buildingunit.text), buildingId, int.parse(buildingname.text));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Building Already Exists', style: TextStyle(color: Colors.white)),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.red,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), foregroundColor: Colors.white, backgroundColor: Colors.blue),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Building Unit'))
            ],
          );
        });
  }

  Future<void> EditShowData(String BuildingId, String BuildingNumber) async {
    final List<String> UnitType = [
      'Studio Type',
      'Bedroom Type',
      'Bungalow Type',
    ];

    final newUnitNumberController = TextEditingController();
    final newUnitTypeController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit Building $BuildingNumber',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Add New Unit Section
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text(
                          'Add New Unit',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: newUnitNumberController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Unit Number',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          hint: const Text('Select Unit Type'),
                          items: UnitType.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            newUnitTypeController.text = newValue!;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Add Unit'),
                            style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            onPressed: () async {
                              if (newUnitNumberController.text.isEmpty || newUnitTypeController.text.isEmpty) {
                                _Snackbar('Please fill all fields', Colors.red, context);
                                return;
                              }

                              final existingUnits = await _firestore.collection('UnitNumber').where('buildingId', isEqualTo: BuildingId).where('unitNumber', isEqualTo: int.parse(newUnitNumberController.text)).get();

                              if (existingUnits.docs.isNotEmpty) {
                                _Snackbar('Unit number already exists', Colors.red, context);
                                return;
                              }

                              try {
                                await _firestore.collection('UnitNumber').add({
                                  'buildingId': BuildingId,
                                  'unitNumber': int.parse(newUnitNumberController.text),
                                  'unitType': newUnitTypeController.text,
                                  'isOccupied': false,
                                });
                                _Snackbar('Unit added successfully', Colors.green, context);
                                newUnitNumberController.clear();
                                newUnitTypeController.text = '';
                              } catch (e) {
                                _Snackbar('Failed to add unit', Colors.red, context);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Existing Units Section
                const Text(
                  'Existing Units',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('UnitNumber').where('buildingId', isEqualTo: BuildingId).orderBy('unitNumber', descending: false).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No units found'));
                      }

                      final units = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: units.length,
                        itemBuilder: (context, index) {
                          final unit = units[index];
                          final unitNumber = unit['unitNumber'].toString();
                          final unitType = unit['unitType'].toString();
                          final unitId = unit.id;

                          final unitNumberController = TextEditingController(text: unitNumber);
                          final unitTypeController = TextEditingController(text: unitType);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Unit #$unitNumber',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: unitNumberController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Unit Number',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: unitTypeController.text,
                                    items: UnitType.map((String item) {
                                      return DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(item),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      unitTypeController.text = newValue!;
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Unit Type',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.save, size: 20),
                                        onPressed: () async {
                                          try {
                                            await _firestore.collection('UnitNumber').doc(unitId).update({
                                              'unitNumber': int.parse(unitNumberController.text),
                                              'unitType': unitTypeController.text,
                                            });
                                            _Snackbar('Unit updated', Colors.green, context);
                                          } catch (e) {
                                            _Snackbar('Failed to update unit', Colors.red, context);
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                        onPressed: () async {
                                          try {
                                            await _firestore.collection('UnitNumber').doc(unitId).delete();
                                            _Snackbar('Unit deleted', Colors.green, context);
                                          } catch (e) {
                                            _Snackbar('Failed to delete unit', Colors.red, context);
                                          }
                                        },
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
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> getBuildingUnits(int _BuildingUnits, String key, int BuildingNumber) async {
    final List<String> UnitType = [
      'Studio Type',
      'Bedroom Type',
      'Bungalow Type',
    ];

    List<TextEditingController> buildingUnitNumber = List.generate(_BuildingUnits, (index) => TextEditingController());
    List<String?> dropdownValues = List.generate(_BuildingUnits, (index) => null);

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Building Units'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_BuildingUnits, (index) {
                  return Column(children: [
                    TextFormField(
                      controller: buildingUnitNumber[index],
                      decoration: InputDecoration(
                        labelText: 'Building Unit Number ${index + 1}',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: dropdownValues[index],
                      items: UnitType.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValues[index] = newValue;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select Unit Type',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(
                      color: Colors.black,
                      height: 20,
                      thickness: 2,
                      indent: 10,
                      endIndent: 10,
                    )
                  ]);
                }),
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                label: Text('Cancel'),
                icon: Icon(Icons.cancel),
                style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), foregroundColor: Colors.white, backgroundColor: Colors.red),
              ),
              TextButton.icon(
                  onPressed: () async {
                    // First, validate all fields
                    bool hasEmptyFields = false;
                    for (int i = 0; i < _BuildingUnits; i++) {
                      if (buildingUnitNumber[i].text.isEmpty || dropdownValues[i] == null || dropdownValues[i] == '') {
                        hasEmptyFields = true;
                        break;
                      }
                    }

                    if (hasEmptyFields) {
                      _Snackbar('Please Fill All Fields', Colors.red, context);
                      return; // Exit without closing dialog
                    }

                    // If validation passes, save all units
                    try {
                      for (int i = 0; i < _BuildingUnits; i++) {
                        await _firestore.collection('UnitNumber').add({
                          'buildingId': key,
                          'unitNumber': int.parse(buildingUnitNumber[i].text),
                          'unitType': dropdownValues[i],
                          'isOccupied': false,
                          'building#': BuildingNumber,
                        });
                      }

                      // Show success message only once after all units are saved
                      _Snackbar('All Units Added Successfully', Colors.green, context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    } catch (e) {
                      // Handle any errors during saving
                      _Snackbar('Error saving units: $e', Colors.red, context);
                    }
                  },
                  icon: const Icon(Icons.save),
                  style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), foregroundColor: Colors.white, backgroundColor: Colors.blue),
                  label: const Text('Save Units'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.black),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                label: const Text('Back'))
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Building',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => AddBuilding(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Building'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ArchivePage()));
                      },
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Archive'),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Legend
            Row(
              children: const [
                Icon(Icons.circle, color: Colors.green, size: 12),
                SizedBox(width: 4),
                Text('Has Vacancy'),
                SizedBox(width: 12),
                Icon(Icons.circle, color: Colors.red, size: 12),
                SizedBox(width: 4),
                Text('Fully Occupied'),
              ],
            ),
            const SizedBox(height: 10),
            // GridView of Building Cards
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('building').orderBy('building').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Center(child: Text('Error loading buildings'));
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final buildings = snapshot.data!.docs;

                  return GridView.builder(
                    itemCount: buildings.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) {
                      final building = buildings[index];

                      return StreamBuilder<QuerySnapshot>(
                        stream: _firestore.collection('UnitNumber').where('building#', isEqualTo: building['building']).snapshots(),
                        builder: (context, unitSnapshot) {
                          if (!unitSnapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final units = unitSnapshot.data!.docs;
                          final totalUnits = units.length;
                          final occupied = units.where((u) => u['isOccupied'] == true).length;
                          final isVacant = occupied < totalUnits;

                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.apartment, color: isVacant ? Colors.green : Colors.red, size: 40),
                                  Text(
                                    'Building No. ${building['building']}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    '$occupied/$totalUnits',
                                    style: TextStyle(
                                      color: isVacant ? Colors.green : Colors.red,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => TenantPage(buildingnumber: building['building'].toString())));
                                        },
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                        child: const Text('View'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => EditShowData(building.id, building['building'].toString()),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                        child: const Text('Update'),
                                      ),
                                    ],
                                  )
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
      ),
    );
  }
}
