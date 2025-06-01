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

    return saleInfo(
      id: doc.id,
      datetime: info['datetime'],
      month: info['month'],
      payer_name: info['payer_name'],
      rental_cost: info['rental_cost'].toString(), // ✅ Fixed here
      status: info['status'],
      uid: info['uid'],
      year: info['year'],
      proofUrl: info['imageUrl'] ?? 'N/A',
    );
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
      final paid = int.tryParse(doc['amount_paid']?.toString() ?? '0') ?? 0;
      total += paid;
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
    final TextEditingController partialAmount = TextEditingController();
    String selectedMonth = DateFormat('MMMM').format(DateTime.now()); // Auto-filled
    String selectedYear = DateTime.now().year.toString(); // Auto-filled
    String? selectedPaymentMode = 'Cash';
    DateTime selectedDueDate = DateTime.now().add(const Duration(days: 30));

    // Check for duplicate billing
    final existing = await _firestore.collection('sales_record').where('uid', isEqualTo: widget.uid).where('month', isEqualTo: selectedMonth).where('year', isEqualTo: selectedYear).get();

    if (existing.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A bill already exists for this month.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Send Monthly Bill'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  // Month
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedMonth,
                    items: List.generate(12, (i) {
                      final m = DateFormat('MMMM').format(DateTime(0, i + 1));
                      return DropdownMenuItem(value: m, child: Text(m));
                    }),
                    onChanged: (val) => setState(() => selectedMonth = val!),
                  ),
                  const SizedBox(height: 10),

                  // Year
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedYear,
                    items: List.generate(8, (i) {
                      final y = (2023 + i).toString();
                      return DropdownMenuItem(value: y, child: Text(y));
                    }),
                    onChanged: (val) => setState(() => selectedYear = val!),
                  ),
                  const SizedBox(height: 10),

                  // Rental Fee
                  TextField(
                    controller: rentalFee,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Rental Fee',
                      border: OutlineInputBorder(),
                      prefixText: '₱ ',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: partialAmount,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Partial Payment (Optional)',
                      border: OutlineInputBorder(),
                      prefixText: '₱ ',
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Mode of Payment
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Payment Mode',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedPaymentMode,
                    items: ['Cash', 'GCash'].map((mode) => DropdownMenuItem(value: mode, child: Text(mode))).toList(),
                    onChanged: (val) => setState(() => selectedPaymentMode = val),
                  ),
                  const SizedBox(height: 10),

                  // Due Date
                  Row(
                    children: [
                      const Text('Due Date:'),
                      TextButton(
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDueDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() => selectedDueDate = picked);
                          }
                        },
                        child: Text(DateFormat('dd/MM/yyyy').format(selectedDueDate)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    'Partial payment logic is not yet implemented.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (rentalFee.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter rental fee')),
                    );
                    return;
                  }
                  final isPartial = partialAmount.text.isNotEmpty;

                  final record = {
                    'datetime': DateFormat('yyyy-MM-dd – HH:mm').format(DateTime.now()),
                    'month': selectedMonth,
                    'year': selectedYear,
                    'due_date': DateFormat('dd/MM/yyyy').format(selectedDueDate),
                    'due_day': selectedDueDate.day,
                    'due_month_number': selectedDueDate.month,
                    'due_year': selectedDueDate.year,
                    'rental_cost': rentalFee.text,
                    'amount_paid': isPartial ? partialAmount.text : rentalFee.text,
                    'balance': isPartial ? (int.parse(rentalFee.text) - int.parse(partialAmount.text)).toString() : '0',
                    'payment_mode': selectedPaymentMode,
                    'payment_type': isPartial ? 'partial' : 'full',
                    'status': isPartial ? 'partial' : 'pending',
                    'payer_name': '',
                    'uid': widget.uid,
                  };

                  await _firestore.collection('sales_record').add(record);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bill sent!')),
                  );
                },
                child: const Text('Send Bill'),
              ),
            ],
          );
        });
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
            Row(
              children: [
                Container(
                  width: 15,
                  height: 15,
                  color: Colors.green,
                ),
                const SizedBox(width: 6),
                const Text('Paid'),
                const SizedBox(width: 20),
                Container(
                  width: 15,
                  height: 15,
                  color: Colors.red,
                ),
                const SizedBox(width: 6),
                const Text('Unpaid'),
              ],
            ),
            const SizedBox(height: 10),
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
                              color: salelist.status.toLowerCase() == 'paid' ? Colors.green.shade100 : Colors.red.shade100,
                              child: InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      backgroundColor: Colors.purple.shade50,
                                      child: TransactionDetailsPage(
                                        id: salelist.id,
                                        month: salelist.month,
                                        year: salelist.year,
                                        datetime: salelist.datetime,
                                        payerName: salelist.payer_name,
                                        rentalCost: salelist.rental_cost,
                                        status: salelist.status,
                                        proofUrl: salelist.proofUrl,
                                      ),
                                    ),
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
