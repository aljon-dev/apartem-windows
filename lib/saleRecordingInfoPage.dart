import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class saleInfo {
  final String id;
  final String datetime;
  final String month;
  final String payer_name;
  final String rental_cost;
  final String status;
  final String uid;
  final String year;
  final String proofUrl;

  saleInfo({
    required this.id,
    required this.datetime,
    required this.month,
    required this.proofUrl,
    required this.payer_name,
    required this.rental_cost,
    required this.status,
    required this.uid,
    required this.year,
  });

  factory saleInfo.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> info = doc.data() as Map<String, dynamic>;

    return saleInfo(id: doc.id, datetime: info['datetime'], month: info['month'], payer_name: info['payer_name'], rental_cost: info['rental_cost'], status: info['status'], uid: info['uid'], year: info['year'], proofUrl: info['imageUrl'] ?? 'N/A');
  }

  Map<String, dynamic> toFireStore() {
    return {
      'datetime': datetime,
      'payer_name': payer_name,
      'rental_cost': rental_cost,
      'status': status,
      'uid': uid,
      'year': year,
      'imageUrl': proofUrl,
    };
  }
}

class saleRecordingInfoPage extends StatefulWidget {
  final String uid;
  final String firstname;
  final String lastname;
  final String buildnumber;
  final String unitnumber;
  const saleRecordingInfoPage({
    super.key,
    required this.uid,
    required this.firstname,
    required this.lastname,
    required this.buildnumber,
    required this.unitnumber,
  });

  @override
  _saleRecordingInfoPageState createState() => _saleRecordingInfoPageState();
}

class _saleRecordingInfoPageState extends State<saleRecordingInfoPage> {
  final _firestore = FirebaseFirestore.instance;

  int annualComputation = 0;

  Stream<List<saleInfo>> getsaleInfos() {
    return _firestore.collection('sales_record').where('uid', isEqualTo: widget.uid).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => saleInfo.fromFirestore(doc)).toList();
    });
  }

  Future<void> getAnnualComputation() async {
    final snapshot = await _firestore.collection('sales_record').where('uid', isEqualTo: widget.uid).get();

    int total = 0;
    for (var doc in snapshot.docs) {
      total += int.parse(doc['rental_cost']);
    }

    setState(() {
      annualComputation = total;
    });
  }

  @override
  void initState() {
    super.initState();
    getAnnualComputation();
  }

  Future<void> ViewProof(String imageUrl) async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Proof of Image',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                imageUrl.isEmpty
                    ? const Text(
                        'No Image Proof Found',
                        style: TextStyle(color: Colors.grey),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                  label: Text('Close'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> sendMonthlyBills() async {
    final TextEditingController rentalFee = TextEditingController();
    List Dates = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    List Year = [
      '2023',
      '2024',
      '2025',
      '2026',
      '2027',
      '2028',
      '2029',
      '2030',
    ];

    String? selectedMonth;
    String? selectedYear;
    DateTime selectedDueDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Send Monthly Bill'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Month Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Month',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedMonth,
                      items: Dates.map<DropdownMenuItem<String>>((month) {
                        return DropdownMenuItem<String>(
                          value: month,
                          child: Text(month),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedMonth = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 15),

                    // Year Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedYear,
                      items: Year.map<DropdownMenuItem<String>>((year) {
                        return DropdownMenuItem<String>(
                          value: year,
                          child: Text(year),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedYear = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 15),

                    // Rental Fee TextField
                    TextField(
                      controller: rentalFee,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Rental Fee',
                        border: OutlineInputBorder(),
                        prefixText: '₱ ',
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Due Date Picker
                    Row(
                      children: [
                        const Text('Due Date: '),
                        TextButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDueDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null && picked != selectedDueDate) {
                              setState(() {
                                selectedDueDate = picked;
                              });
                            }
                          },
                          child: Text('${selectedDueDate.day}/${selectedDueDate.month}/${selectedDueDate.year}'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedMonth != null && selectedYear != null && rentalFee.text.isNotEmpty) {
                      try {
                        // Store both formatted datetime and individual date components
                        String formattedDateTime = DateFormat('yyyy-MM-dd - HH:mm').format(selectedDueDate);
                        String formattedDueDate = DateFormat('dd/MM/yyyy').format(selectedDueDate);

                        await _firestore.collection('sales_record').add({
                          'datetime': formattedDateTime,
                          'due_date': formattedDueDate, // Add formatted due date
                          'month': selectedMonth,
                          'payer_name': '',
                          'rental_cost': rentalFee.text,
                          'status': 'pending',
                          'uid': widget.uid,
                          'year': selectedYear,
                          'imageUrl': '',
                        });

                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Monthly bill sent successfully!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error sending bill: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                    }
                  },
                  child: const Text('Send Bill'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Recording Info'),
        leading: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
        actions: [IconButton(onPressed: () => sendMonthlyBills(), icon: Icon(Icons.send))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tenant name : ${widget.firstname}, ${widget.lastname}'),
            const SizedBox(height: 10),
            Text('Building Number: ${widget.buildnumber}'),
            const SizedBox(height: 10),
            Text('Unit Number: ${widget.unitnumber}'),
            const SizedBox(height: 10),
            Expanded(
                child: StreamBuilder<List<saleInfo>>(
                    stream: getsaleInfos(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final sales = snapshot.data!;

                      return ListView.builder(
                          itemCount: sales.length,
                          itemBuilder: (context, index) {
                            final salelist = sales[index];

                            return Card(
                              child: InkWell(
                                onTap: () {
                                  ViewProof(salelist.proofUrl);
                                },
                                child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Container(
                                        child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Month: ${salelist.month}'),
                                        const SizedBox(height: 10),
                                        Text('Payer Name: ${salelist.payer_name}'),
                                        const SizedBox(height: 10),
                                        Text('Rental Cost: ${salelist.rental_cost}'),
                                        const SizedBox(height: 10),
                                        Text('Status: ${salelist.status}'),
                                        const SizedBox(height: 10),
                                      ],
                                    ))),
                              ),
                            );
                          });
                    })),
            Text(
              'Annual Computation : $annualComputation',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
