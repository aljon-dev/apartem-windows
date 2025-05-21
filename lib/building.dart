import 'package:bogsandmila/logo.dart';
import 'package:bogsandmila/tenant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BuildingPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final uid;
  // ignore: prefer_typing_uninitialized_variables
  final type;
  const BuildingPage({super.key, required this.uid, required this.type});

  @override
  // ignore: library_private_types_in_public_api
  _BuildingPage createState() => _BuildingPage();
}

class _BuildingPage extends State<BuildingPage> {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
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
                        )),
                    LogoPage(uid: widget.uid, type: widget.type),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: StreamBuilder<QuerySnapshot>(
                                stream: _firestore.collection('building').snapshots(),
                                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasError) {
                                    return const Center(child: Text('Error'));
                                  }
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  final data = snapshot.data;
                                  if (data == null || data.docs.isEmpty) {
                                    return const Center(child: Text('No data found'));
                                  }

                                  return LayoutBuilder(
                                    builder: (context, constraints) {
                                      // Use the available width to make the table responsive
                                      final availableWidth = constraints.maxWidth;

                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: DataTable(
                                            // Adjust column spacing based on available width
                                            columnSpacing: availableWidth * 0.02, // 2% of available width
                                            headingRowHeight: 56.0,
                                            dataRowHeight: 52.0,
                                            // Ensure table takes available width
                                            horizontalMargin: 16.0,
                                            columns: [
                                              DataColumn(
                                                label: Container(
                                                  width: availableWidth * 0.4, // 40% of available width
                                                  child: const Text(
                                                    'Building',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Container(
                                                  width: availableWidth * 0.3, // 30% of available width
                                                  child: const Text(
                                                    'Availability',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Container(
                                                  width: availableWidth * 0.2, // 20% of available width
                                                  child: const Text(
                                                    'Action',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                            rows: data.docs.map((doc) {
                                              final buildingName = doc['building'] ?? 'N/A';
                                              final availability = doc['available'] ?? 'N/A';
                                              final buildingId = doc.id;
                                              return DataRow(
                                                cells: [
                                                  DataCell(
                                                    Container(
                                                      width: availableWidth * 0.4, // 40% of available width
                                                      child: Text(
                                                        'Building Number ${buildingName.toString()}',
                                                        style: const TextStyle(color: Colors.black),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                      width: availableWidth * 0.1, // 30% of available width
                                                      child: Container(
                                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: availability == 0 ? Colors.red[100] : Colors.green[100],
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          availability == 0 ? 'Not Available' : 'Available',
                                                          style: TextStyle(
                                                            color: availability == 0 ? Colors.red[900] : Colors.green[900],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                      width: availableWidth * .1, // 20% of available width
                                                      child: IconButton(
                                                        icon: const Icon(Icons.info, color: Colors.blue),
                                                        tooltip: 'View Details',
                                                        onPressed: () {
                                                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                            return TenantPage(
                                                              uid: widget.uid,
                                                              type: widget.type,
                                                              buildingnumber: buildingName.toString(),
                                                            );
                                                          }));
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
}
