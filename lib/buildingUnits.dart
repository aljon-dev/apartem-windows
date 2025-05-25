import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bogsandmila/Snackbar.dart';

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

  Future<void> EditShowData(String BuildingId) async {
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
        return AlertDialog(
          title: Text('Edit Building Unit'),
          // Using Container with fixed height instead of Column with Expanded
          content: Container(
              width: double.maxFinite,
              height: 400, // Set an appropriate height
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: newUnitNumberController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Building Unit Number',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 5,
                        child: DropdownButtonFormField(
                          items: UnitType.map((String item) {
                            return DropdownMenuItem<String>(child: Text(item), value: item);
                          }).toList(),
                          onChanged: (String? newValue) {
                            newUnitTypeController.text = newValue!;
                          },
                          decoration: const InputDecoration(labelText: 'Select Unit Type', border: OutlineInputBorder()),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        height: 50,
                        child: TextButton.icon(
                            onPressed: () async {
                              if (newUnitNumberController.text.isEmpty || newUnitTypeController.text.isEmpty) {
                                _Snackbar('Please Fill All Fields', Colors.red, context);
                              } else {
                                final documentSnapshot = await _firestore.collection('UnitNumber').where('buildingId', isEqualTo: BuildingId).where('unitNumber', isEqualTo: int.parse(newUnitNumberController.text)).get();

                                if (documentSnapshot.docs.isNotEmpty) {
                                  _Snackbar('Unit Number Already Exists', Colors.red, context);
                                  return;
                                } else {
                                  _firestore.collection('UnitNumber').add({
                                    'buildingId': BuildingId,
                                    'unitNumber': int.parse(newUnitNumberController.text),
                                    'unitType': newUnitTypeController.text,
                                    'isOccupied': false,
                                  }).then((_) {
                                    _Snackbar('Unit Added', Colors.green, context);
                                    Navigator.pop(context);
                                  }).catchError((error) {
                                    _Snackbar('Failed to add the unit', Colors.red, context);
                                  });
                                }
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Unit'),
                            style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), foregroundColor: Colors.white, backgroundColor: Colors.blue)),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: StreamBuilder(
                      stream: _firestore.collection('UnitNumber').where('buildingId', isEqualTo: BuildingId).orderBy('unitNumber', descending: false).snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return const Center(child: Text('Error'));
                        }
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final BuildingSnapshot = snapshot.data!.docs;

                        // No items case
                        if (BuildingSnapshot.isEmpty) {
                          return Center(child: Text('No units found'));
                        }

                        return ListView.builder(
                          itemCount: BuildingSnapshot.length,
                          itemBuilder: (context, index) {
                            final buildingData = BuildingSnapshot[index];

                            // Proper initialization of controllers
                            // Create controllers with initial values from Firestore
                            TextEditingController unitNumberController = TextEditingController(text: buildingData['unitNumber'].toString());
                            TextEditingController unitTypeController = TextEditingController(text: buildingData['unitType']);
                            String unitKey = buildingData.id;

                            return Card(
                              child: ListTile(
                                  title: Text('Building Unit Number: ${buildingData['unitNumber'].toString()}'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        keyboardType: TextInputType.number,
                                        controller: unitNumberController,
                                        decoration: const InputDecoration(
                                          labelText: 'Building Unit Number',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField<String>(
                                        value: unitTypeController.text.isNotEmpty ? unitTypeController.text : null,
                                        items: UnitType.map((String item) {
                                          return DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(item),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          unitTypeController.text = newValue ?? unitTypeController.text;
                                        },
                                        decoration: const InputDecoration(
                                          labelText: 'Select Unit Type',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () async {
                                          List unitNumber = buildingData['unitNumber'];

                                          for (int i = 0; i < unitNumber.length; i++) {
                                            if (unitNumber[i] == int.parse(unitNumberController.text)) {
                                              _Snackbar('Unit Number Already Exists', Colors.red, context);
                                              return;
                                            }
                                          }
                                          _firestore.collection('UnitNumber').doc(buildingData.id).update({
                                            'unitNumber': int.parse(unitNumberController.text),
                                            'unitType': unitTypeController.text,
                                          }).then((_) {
                                            _Snackbar('Data Updated', Colors.green, context);
                                          }).catchError((error) {
                                            _Snackbar('Failed to update the data ', Colors.red, context);
                                          });
                                        },
                                      ),
                                      IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () async {
                                            _firestore.collection('UnitNumber').doc(unitKey).delete();
                                            _Snackbar('Successfully Deleted', Colors.red, context);
                                          }),
                                    ],
                                  )),
                            );
                          },
                        );
                      },
                    ),
                  )
                ],
              )),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
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
                  onPressed: () {
                    for (int i = 0; i < _BuildingUnits; i++) {
                      if (buildingUnitNumber[i].text.isEmpty || dropdownValues[i] == '') {
                        _Snackbar('Please Fill All Fields', Colors.red, context);
                        Navigator.pop(context);
                      } else {
                        _firestore.collection('UnitNumber').add({
                          'buildingId': key,
                          'unitNumber': int.parse(buildingUnitNumber[i].text),
                          'unitType': dropdownValues[i],
                          'isOccupied': false,
                          'building#': BuildingNumber,
                        });
                        _Snackbar('Unit Added', Colors.green, context);
                      }
                      Navigator.pop(context);
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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Building Units',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => AddBuilding(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Building Unit'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        )),
                  )
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('building').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final buildingSnapshot = snapshot.data!.docs;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: buildingSnapshot.length,
                      itemBuilder: (context, index) {
                        final buildingData = buildingSnapshot[index];
                        return Card(
                          child: ListTile(
                            title: Text('Building Number: ${buildingData['building']}'),
                            subtitle: Text('Available Units: ${buildingData['available']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    EditShowData(buildingData.id);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _firestore.collection('building').doc(buildingData.id).delete();
                                    _firestore.collection('UnitNumber').where('buildingId', isEqualTo: buildingData.id).get().then((snapshot) {
                                      for (var doc in snapshot.docs) {
                                        doc.reference.delete();
                                      }
                                    });
                                    _Snackbar('Successfully Deleted', Colors.red, context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                })
          ],
        ));
  }
}
