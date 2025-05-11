import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
        rental_cost: info['rental_cost'],
        status: info['status'],
        uid: info['uid'],
        year: info['year'],
        proofUrl: info['imageUrl'] ?? 'N/A');
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
    Key? key,
    required this.uid,
    required this.firstname,
    required this.lastname,
    required this.buildnumber,
    required this.unitnumber,
  }) : super(key: key);

  @override
  _saleRecordingInfoPageState createState() => _saleRecordingInfoPageState();
}

class _saleRecordingInfoPageState extends State<saleRecordingInfoPage> {
  final _firestore = FirebaseFirestore.instance;

  int annualComputation = 0;

  Stream<List<saleInfo>> getsaleInfos() {
    return _firestore
        .collection('sales_record')
        .where('uid', isEqualTo: widget.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => saleInfo.fromFirestore(doc)).toList();
    });
  }

  Future<void> getAnnualComputation() async {
    final snapshot = await _firestore
        .collection('sales_record')
        .where('uid', isEqualTo: widget.uid)
        .get();

    int total = 0;
    for (var doc in snapshot.docs) {
      total += int.parse(doc['rental_cost']);
    }

    setState(() {
      annualComputation = total;
    });
  }

  void initState() {
    super.initState();
    getAnnualComputation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sale Recording Info'),
        leading: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
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
                        return CircularProgressIndicator();
                      }

                      final sales = snapshot.data!;

                      return ListView.builder(
                          itemCount: sales.length,
                          itemBuilder: (context, index) {
                            final salelist = sales[index];

                            return Card(
                              child: InkWell(
                                onTap: () {},
                                child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Container(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Month: ${salelist.month}'),
                                        SizedBox(height: 10),
                                        Text(
                                            'Payer Name: ${salelist.payer_name}'),
                                        SizedBox(height: 10),
                                        Text(
                                            'Rental Cost: ${salelist.rental_cost}'),
                                        SizedBox(height: 10),
                                        Text('Status: ${salelist.status}'),
                                        SizedBox(height: 10),
                                      ],
                                    ))),
                              ),
                            );
                          });
                    })),
            Text(
              'Annual Computation : ${annualComputation}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
