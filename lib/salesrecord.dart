import 'package:bogsandmila/logo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SalesRecordPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final uid;
  // ignore: prefer_typing_uninitialized_variables
  final type;
  const SalesRecordPage({super.key, required this.uid, required this.type});
  @override
  // ignore: library_private_types_in_public_api
  _SalesRecordPageState createState() => _SalesRecordPageState();
}

class _SalesRecordPageState extends State<SalesRecordPage> {
  final int _rowsPerPage = 10;
  int _currentPage = 0;
  String? selectedYear;
  List<String> years = [
    '2020',
    '2021',
    '2022',
    '2023',
    '2024',
    '2025',
    '2026',
    '2027',
    '2028',
    '2029',
    '2030'
  ];

  String? selectedMonth;
  List<String> month = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String? selectedBuilding;
  List<String> building = [
    '1',
    '2',
    '3',
    '4',
    '5',
  ];

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
                    LogoPage(uid: widget.uid, type: widget.type),
                    const SizedBox(height: 20),
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      width:
                                          200, // Ensure it takes available width
                                      child: DropdownButtonFormField<String>(
                                        value: selectedBuilding,
                                        hint: const Text('Select Building'),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedBuilding =
                                                newValue; // Update the selected year
                                            // fetchData();
                                          });
                                        },
                                        items: building
                                            .map<DropdownMenuItem<String>>(
                                                (String building) {
                                          return DropdownMenuItem<String>(
                                            value: building,
                                            child: Text('Building ${building}'),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 50,
                                      width:
                                          200, // Ensure it takes available width
                                      child: DropdownButtonFormField<String>(
                                        value: selectedYear,
                                        hint: const Text('Select Year'),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedYear =
                                                newValue; // Update the selected year
                                            // fetchData();
                                          });
                                        },
                                        items: years
                                            .map<DropdownMenuItem<String>>(
                                                (String year) {
                                          return DropdownMenuItem<String>(
                                            value: year,
                                            child: Text(year),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 50,
                                      width:
                                          200, // Ensure it takes available width
                                      child: DropdownButtonFormField<String>(
                                        value: selectedMonth,
                                        hint: const Text('Select Month'),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedMonth =
                                                newValue; // Update the selected year
                                            // fetchData();
                                          });
                                        },
                                        items: month
                                            .map<DropdownMenuItem<String>>(
                                                (String month) {
                                          return DropdownMenuItem<String>(
                                            value: month,
                                            child: Text(month),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            )
                          ],
                        )),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('sales_record')
                            .where('year', isEqualTo: selectedYear)
                            .where('month', isEqualTo: selectedMonth)
                            .where('building', isEqualTo: selectedBuilding)
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
                          final startIndex = _currentPage * _rowsPerPage;
                          final endIndex =
                              (startIndex + _rowsPerPage < data.length)
                                  ? startIndex + _rowsPerPage
                                  : data.length;

                          return Column(
                            children: [
                              DataTable(
                                columns: [
                                  DataColumn(
                                    label: Container(
                                      width:
                                          MediaQuery.of(context).size.width / 3,
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text(
                                        'Month',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Container(
                                      width:
                                          MediaQuery.of(context).size.width / 3,
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text(
                                        'Payer Name',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Container(
                                      width:
                                          MediaQuery.of(context).size.width / 3,
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text(
                                        'Rental Cost',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Container(
                                      width:
                                          MediaQuery.of(context).size.width / 3,
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text(
                                        'Status',
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
                                    final doc = data[startIndex + index];
                                    final month = doc['month'] ?? '';
                                    final payerName = doc['payer_name'] ?? '';
                                    final rentalCost = doc['rental_cost'] ?? '';
                                    final status = doc['status'] ?? '';

                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(month,
                                                style: const TextStyle(
                                                    color: Colors.black)),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(payerName,
                                                style: const TextStyle(
                                                    color: Colors.black)),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(rentalCost,
                                                style: const TextStyle(
                                                    color: Colors.black)),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(status,
                                                style: const TextStyle(
                                                    color: Colors.black)),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
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
                    )
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
