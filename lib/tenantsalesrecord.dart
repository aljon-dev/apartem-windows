import 'package:bogsandmila/logo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TenantSalesRecordPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final uid;
  // ignore: prefer_typing_uninitialized_variables
  final type;
  // ignore: prefer_typing_uninitialized_variables, non_constant_identifier_names
  final tenant_id;
  const TenantSalesRecordPage(
      {super.key,
      required this.uid,
      required this.type,
      // ignore: non_constant_identifier_names
      required this.tenant_id});
  @override
  // ignore: library_private_types_in_public_api
  _TenantSalesRecordPageState createState() => _TenantSalesRecordPageState();
}

class _TenantSalesRecordPageState extends State<TenantSalesRecordPage> {
  final int _rowsPerPage = 10;
  int _currentPage = 0;

  String selectedValue = 'paid';
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
  ]; // Add more years as needed

  // ignore: non_constant_identifier_names
  String tenant_name = "";
  String buildingnumber = "";
  String unitnumber = "";
  // ignore: non_constant_identifier_names
  double rental_cost = 0.0;
  @override
  void initState() {
    super.initState();
    // Fetch data based on the provided UID when the widget initializes
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('tenant')
          .doc(widget.tenant_id)
          .get();

      if (documentSnapshot.exists) {
        var userData = documentSnapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          setState(() {
            tenant_name = (userData['firstname'] ?? '') +
                " " +
                (userData['lastname'] ?? '');
            buildingnumber = userData['buildingnumber'] ?? '';
            unitnumber = userData['unitnumber'] ?? '';
            unitnumber = userData['unitnumber'] ?? '';
          });
        } else {}
      } else {}

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('sales_record')
          .where('uid', isEqualTo: widget.tenant_id)
          .where('year', isEqualTo: selectedYear)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Initialize rental_cost to 0
        double totalRentalCost = 0.0;

        // Iterate through all documents
        for (var doc in querySnapshot.docs) {
          var userData = doc.data() as Map<String, dynamic>?;

          if (userData != null) {
            // Check if 'rental_cost' is present and parse it
            double rentalCost = (userData['rental_cost'] ?? 0.0) is double
                ? userData['rental_cost'] as double
                : double.tryParse(userData['rental_cost'].toString()) ?? 0.0;

            // Add to totalRentalCost
            totalRentalCost += rentalCost;
          } else {}
        }

        // Update state with total rental cost
        setState(() {
          rental_cost = totalRentalCost;
        });
      } else {}
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    List<String> dropdownItems = ['paid', 'unpaid'];
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                tenantInfo('Tenant Name: $tenant_name'),
                                const SizedBox(height: 10),
                                tenantInfo('Building Number: $unitnumber'),
                                const SizedBox(height: 10),
                                tenantInfo('Unit Number: $buildingnumber'),
                                const SizedBox(height: 10),
                              ],
                            ),
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
                                        value: selectedYear,
                                        hint: const Text('Select Year'),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedYear =
                                                newValue; // Update the selected year
                                            fetchData();
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
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Text(
                                      'Annual Collection Total: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15),
                                    ),
                                    Text(
                                      NumberFormat('#,##0.00')
                                          .format(rental_cost),
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                              ],
                            )
                          ],
                        )),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('sales_record')
                            .where('uid', isEqualTo: widget.tenant_id)
                            .where('year', isEqualTo: selectedYear)
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
                                  DataColumn(label: tableColumn('Month')),
                                  DataColumn(label: tableColumn('Payer Name')),
                                  DataColumn(label: tableColumn('Rental Cost')),
                                  DataColumn(label: tableColumn('Status')),
                                  DataColumn(label: tableColumn('Action')),
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
                                        DataCell(tableRow(month)),
                                        DataCell(tableRow(payerName)),
                                        DataCell(tableRow(rentalCost)),
                                        DataCell(tableRow(status)),
                                        DataCell(
                                          DropdownButtonFormField<String>(
                                            value: selectedValue,
                                            hint: const Text('Select Status'),
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                selectedValue = newValue!;
                                                FirebaseFirestore.instance
                                                    .collection('sales_record')
                                                    .doc(doc.id)
                                                    .update({
                                                  'status': selectedValue,
                                                });
                                              });
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
                                        )
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

  tableColumn(String label) {
    return Container(
      width: MediaQuery.of(context).size.width / 6,
      padding: const EdgeInsets.all(8.0),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  tableRow(String label) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(label, style: const TextStyle(color: Colors.black)),
    );
  }

  tenantInfo(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
    );
  }
}
