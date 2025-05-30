import 'package:bogsandmila/TransactionDetailsPage.dart';
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
                          'due_date': formattedDueDate,
                          'imageUrl': '',
                          'month': selectedMonth,
                          'payer_name': '',
                          'rental_cost': rentalFee.text,
                          'status': 'pending',
                          'uid': widget.uid,
                          'year': selectedYear,
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
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("${salelist.month} ${salelist.year}"),
                                        content: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Center(
                                                child: Icon(
                                                  salelist.status.toLowerCase() == 'paid'
                                                      ? Icons.check_circle
                                                      : salelist.status.toLowerCase() == 'under review'
                                                          ? Icons.hourglass_top
                                                          : Icons.cancel,
                                                  size: 60,
                                                  color: salelist.status.toLowerCase() == 'paid'
                                                      ? Colors.green
                                                      : salelist.status.toLowerCase() == 'under review'
                                                          ? Colors.orange
                                                          : Colors.red,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Text("Date: ${salelist.datetime}"),
                                              Text("Payer Name: ${salelist.payer_name.isEmpty ? "N/A" : salelist.payer_name}"),
                                              Text("Amount: ₱ ${salelist.rental_cost}"),
                                              Text("Status: ${salelist.status}"),
                                              const SizedBox(height: 10),
                                              const Divider(),
                                              const SizedBox(height: 10),
                                              salelist.proofUrl.isNotEmpty && salelist.proofUrl != "N/A"
                                                  ? Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Text("Proof of Payment:", style: TextStyle(fontWeight: FontWeight.bold)),
                                                        const SizedBox(height: 8),
                                                        ClipRRect(
                                                          borderRadius: BorderRadius.circular(10),
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (_) => FullScreenImageViewer(imageUrl: salelist.proofUrl),
                                                                ),
                                                              );
                                                            },
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(10),
                                                              child: Image.network(
                                                                salelist.proofUrl,
                                                                height: 200,
                                                                fit: BoxFit.cover,
                                                                errorBuilder: (context, error, stackTrace) => const Text("Image failed to load"),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : const Text("No proof of payment uploaded."),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          if (salelist.status != 'paid')
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                ElevatedButton.icon(
                                                  onPressed: () async {
                                                    await _firestore.collection('sales_record').doc(salelist.id).update({
                                                      'status': 'unpaid',
                                                    });
                                                    Navigator.of(context).pop();
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text("Status updated to Unpaid")),
                                                    );
                                                  },
                                                  icon: const Icon(Icons.cancel),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    foregroundColor: Colors.white,
                                                  ),
                                                  label: const Text("Unpaid"),
                                                ),
                                                ElevatedButton.icon(
                                                  onPressed: () async {
                                                    // UPDATE STATUS TO PAID
                                                    await _firestore.collection('sales_record').doc(salelist.id).update({
                                                      'status': 'paid',
                                                    });
                                                    Navigator.of(context).pop();
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text("Status updated to Paid")),
                                                    );
                                                  },
                                                  icon: const Icon(Icons.check),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.green,
                                                    foregroundColor: Colors.white,
                                                  ),
                                                  label: const Text("Paid"),
                                                ),
                                              ],
                                            ),
                                          if (salelist.status == 'paid')
                                            Container(
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.red,
                                                      foregroundColor: Colors.white,
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                                      )),
                                                  child: const Text('Close')),
                                            ), // Empty container for paid status
                                        ],
                                      );
                                    },
                                  );
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
