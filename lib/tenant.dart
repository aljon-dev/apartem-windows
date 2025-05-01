import 'package:bogsandmila/logo.dart';
import 'package:bogsandmila/tenantsalesrecord.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class TenantPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final uid;
  // ignore: prefer_typing_uninitialized_variables
  final type;
  // ignore: prefer_typing_uninitialized_variables
  final buildingnumber;
  const TenantPage(
      {super.key,
      required this.uid,
      required this.type,
      required this.buildingnumber});

  @override
  // ignore: library_private_types_in_public_api
  _TenantPageState createState() => _TenantPageState();
}

class _TenantPageState extends State<TenantPage> {
  final int _rowsPerPage = 10;
  int _currentPage = 0;
  String? selectedValue;
  String? selectedValue2;
  String vacantValue = 'Yes';
  String? paymentValue;
  @override
  Widget build(BuildContext context) {
    List<String> dropdownItems = [
      'Payment',
      'Vacancy',
      'View Sub-Account',
      'Reset Password',
      'Archive'
    ];
    List<String> dropdownItems2 = ['Reset Password', 'Delete Account'];
    List<String> dropdownVacant = [
      'Yes',
      'No',
    ];
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
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      color: const Color.fromARGB(240, 17, 17, 17),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage('assets/manageuser.png'),
                            width: 40,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Tenant',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 23),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: widget.buildingnumber == '0'
                            ? FirebaseFirestore.instance
                                .collection('tenant')
                                .where('archive', isEqualTo: '0')
                                .snapshots()
                            : FirebaseFirestore.instance
                                .collection('tenant')
                                .where('buildingnumber',
                                    isEqualTo: widget.buildingnumber.toString())
                                .where('archive', isEqualTo: '0')
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
                                          MediaQuery.of(context).size.width / 8,
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text(
                                        'Building Number',
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
                                          MediaQuery.of(context).size.width / 8,
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text(
                                        'Unit Number',
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
                                          MediaQuery.of(context).size.width / 8,
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text(
                                        'Contact Number',
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
                                          MediaQuery.of(context).size.width / 8,
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text(
                                        'Username',
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
                                          MediaQuery.of(context).size.width / 8,
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text(
                                        'Password',
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
                                          MediaQuery.of(context).size.width / 8,
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text(
                                        'Action',
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
                                    final firstname = doc['firstname'] ?? '';
                                    final lastname = doc['lastname'] ?? '';
                                    final buildingnumber =
                                        doc['buildingnumber'] ?? '';
                                    final unitnumber = doc['unitnumber'] ?? '';
                                    final contactnumber =
                                        doc['contactnumber'] ?? '';
                                    final username = doc['username'] ?? '';
                                    final password = doc['password'] ?? '';
                                    final vacant = doc['vacant'] ?? '';

                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(buildingnumber,
                                                style: const TextStyle(
                                                    color: Colors.black)),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(unitnumber,
                                                style: const TextStyle(
                                                    color: Colors.black)),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(contactnumber,
                                                style: const TextStyle(
                                                    color: Colors.black)),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: GestureDetector(
                                              child: Text(username,
                                                  style: const TextStyle(
                                                      color: Colors.black)),
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            TenantSalesRecordPage(
                                                                uid: widget.uid,
                                                                type:
                                                                    widget.type,
                                                                tenant_id:
                                                                    doc.id)));
                                              },
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(password,
                                                style: const TextStyle(
                                                    color: Colors.black)),
                                          ),
                                        ),
                                        DataCell(
                                          DropdownButtonFormField<String>(
                                            value: selectedValue,

                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                            icon: const FaIcon(FontAwesomeIcons
                                                .ellipsisVertical), // Remove the default dropdown icon
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                selectedValue = null;

                                                if (newValue == 'Payment') {
                                                  String? PaymentValue;

                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return StatefulBuilder(
                                                        builder: (BuildContext
                                                                context,
                                                            StateSetter
                                                                setState) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                'Payment'),
                                                            content: SizedBox(
                                                              height: 100,
                                                              child: Column(
                                                                children: [
                                                                  RadioListTile<
                                                                      String>(
                                                                    title: const Text(
                                                                        'Paid'),
                                                                    value:
                                                                        'Paid',
                                                                    groupValue:
                                                                        PaymentValue,
                                                                    onChanged:
                                                                        (String?
                                                                            newValue) {
                                                                      setState(
                                                                          () {
                                                                        PaymentValue =
                                                                            newValue;
                                                                      });
                                                                    },
                                                                  ),
                                                                  RadioListTile<
                                                                      String>(
                                                                    title: const Text(
                                                                        'Unpaid'),
                                                                    value:
                                                                        'Unpaid',
                                                                    groupValue:
                                                                        PaymentValue,
                                                                    onChanged:
                                                                        (String?
                                                                            newValue) {
                                                                      setState(
                                                                          () {
                                                                        PaymentValue =
                                                                            newValue;
                                                                      });
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(); // Close the dialog
                                                                },
                                                                child:
                                                                    const Text(
                                                                        'Close'),
                                                              ),
                                                              TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  String
                                                                      getCurrentMonth() {
                                                                    return DateFormat
                                                                            .MMMM()
                                                                        .format(
                                                                            DateTime.now());
                                                                  }

                                                                  String
                                                                      getCurrentYear() {
                                                                    return DateFormat
                                                                            .y()
                                                                        .format(
                                                                            DateTime.now());
                                                                  }

                                                                  String
                                                                      getCurrentDateTime() {
                                                                    return DateFormat(
                                                                            'yyyy-MM-dd – HH:mm')
                                                                        .format(
                                                                            DateTime.now());
                                                                  }

                                                                  String
                                                                      rental_cost =
                                                                      "";
                                                                  if (widget
                                                                          .buildingnumber ==
                                                                      1) {
                                                                    rental_cost =
                                                                        "5000";
                                                                  } else if (widget
                                                                          .buildingnumber ==
                                                                      2) {
                                                                    rental_cost =
                                                                        "5000";
                                                                  } else if (widget
                                                                          .buildingnumber ==
                                                                      3) {
                                                                    rental_cost =
                                                                        "6000";
                                                                  } else if (widget
                                                                          .buildingnumber ==
                                                                      4) {
                                                                    rental_cost =
                                                                        "3500";
                                                                  } else if (widget
                                                                          .buildingnumber ==
                                                                      5) {
                                                                    rental_cost =
                                                                        "3500";
                                                                  }

                                                                  final firestore =
                                                                      FirebaseFirestore
                                                                          .instance;

                                                                  String
                                                                      currentMonth =
                                                                      getCurrentMonth();
                                                                  String
                                                                      currentYear =
                                                                      getCurrentYear();
                                                                  String uid =
                                                                      doc.id;

                                                                  try {
                                                                    QuerySnapshot querySnapshot = await firestore
                                                                        .collection(
                                                                            'sales_record')
                                                                        .where(
                                                                            'month',
                                                                            isEqualTo:
                                                                                currentMonth)
                                                                        .where(
                                                                            'year',
                                                                            isEqualTo:
                                                                                currentYear)
                                                                        .where(
                                                                            'uid',
                                                                            isEqualTo:
                                                                                uid)
                                                                        .get();

                                                                    if (querySnapshot
                                                                        .docs
                                                                        .isNotEmpty) {
                                                                      DocumentReference
                                                                          documentRef =
                                                                          querySnapshot
                                                                              .docs
                                                                              .first
                                                                              .reference;
                                                                      await documentRef
                                                                          .update({
                                                                        'payer_name':
                                                                            '$firstname $lastname',
                                                                        'rental_cost':
                                                                            rental_cost,
                                                                        'building': widget
                                                                            .buildingnumber
                                                                            .toString(),
                                                                        'datetime':
                                                                            getCurrentDateTime(),
                                                                        'status':
                                                                            PaymentValue, // Use PaymentValue directly
                                                                      });
                                                                    } else {
                                                                      await firestore
                                                                          .collection(
                                                                              'sales_record')
                                                                          .add({
                                                                        'month':
                                                                            currentMonth,
                                                                        'year':
                                                                            currentYear,
                                                                        'uid':
                                                                            uid,
                                                                        'payer_name':
                                                                            '$firstname $lastname',
                                                                        'rental_cost':
                                                                            rental_cost,
                                                                        'building': widget
                                                                            .buildingnumber
                                                                            .toString(),
                                                                        'datetime':
                                                                            getCurrentDateTime(),
                                                                        'status':
                                                                            PaymentValue, // Use PaymentValue directly
                                                                      });
                                                                    }

                                                                    SuccessMessage(
                                                                        'Successfully Set Vacant');
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  } catch (e) {
                                                                    print(
                                                                        "Error: $e");
                                                                  }
                                                                },
                                                                child:
                                                                    const Text(
                                                                        'Save'),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                } else if (newValue ==
                                                    'Vacancy') {
                                                  String vacantValue = 'Yes';

                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return StatefulBuilder(
                                                        builder: (BuildContext
                                                                context,
                                                            StateSetter
                                                                setState) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                'Vacancy'),
                                                            content: SizedBox(
                                                              height: 100,
                                                              child: Column(
                                                                children: [
                                                                  RadioListTile<
                                                                      String>(
                                                                    title: const Text(
                                                                        'Yes'),
                                                                    value:
                                                                        'Yes',
                                                                    groupValue:
                                                                        vacantValue,
                                                                    onChanged:
                                                                        (String?
                                                                            newValue) {
                                                                      setState(
                                                                          () {
                                                                        vacantValue =
                                                                            newValue!;
                                                                      });
                                                                    },
                                                                  ),
                                                                  RadioListTile<
                                                                      String>(
                                                                    title:
                                                                        const Text(
                                                                            'No'),
                                                                    value: 'No',
                                                                    groupValue:
                                                                        vacantValue,
                                                                    onChanged:
                                                                        (String?
                                                                            newValue) {
                                                                      setState(
                                                                          () {
                                                                        vacantValue =
                                                                            newValue!;
                                                                      });
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(); // Close the dialog
                                                                },
                                                                child:
                                                                    const Text(
                                                                        'Close'),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'tenant')
                                                                      .doc(doc
                                                                          .id)
                                                                      .update({
                                                                    'vacant':
                                                                        vacantValue
                                                                  });

                                                                  if (vacantValue ==
                                                                      'Yes') {
                                                                    if (vacantValue ==
                                                                        vacant) {
                                                                    } else {
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'building')
                                                                          .where(
                                                                              'building',
                                                                              isEqualTo:
                                                                                  buildingnumber)
                                                                          .get()
                                                                          .then(
                                                                              (querySnapshot) {
                                                                        for (var doc
                                                                            in querySnapshot.docs) {
                                                                          // Check if 'available' is stored as a String and convert it to an int
                                                                          int currentAvailable =
                                                                              int.tryParse(doc['available'].toString()) ?? 0;
                                                                          int updatedAvailable =
                                                                              currentAvailable - 1;

                                                                          // Update the document with the new 'available' value
                                                                          doc.reference
                                                                              .update({
                                                                            'available':
                                                                                updatedAvailable.toString(),
                                                                          });
                                                                        }
                                                                      });
                                                                    }
                                                                  } else {
                                                                    if (vacantValue ==
                                                                        vacant) {
                                                                    } else {
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'building')
                                                                          .where(
                                                                              'building',
                                                                              isEqualTo:
                                                                                  buildingnumber)
                                                                          .get()
                                                                          .then(
                                                                              (querySnapshot) {
                                                                        for (var doc
                                                                            in querySnapshot.docs) {
                                                                          // Check if 'available' is stored as a String and convert it to an int
                                                                          int currentAvailable =
                                                                              int.tryParse(doc['available'].toString()) ?? 0;
                                                                          int updatedAvailable =
                                                                              currentAvailable + 1;

                                                                          // Update the document with the new 'available' value
                                                                          doc.reference
                                                                              .update({
                                                                            'available':
                                                                                updatedAvailable.toString(),
                                                                          });
                                                                        }
                                                                      });
                                                                    }
                                                                  }

                                                                  SuccessMessage(
                                                                      'Successfully Set Vacant');
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child:
                                                                    const Text(
                                                                        'Save'),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                } else if (newValue ==
                                                    'View Sub-Account') {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            'Sub View Account'),
                                                        content: SizedBox(
                                                          height: 300,
                                                          width:
                                                              600, // Allow space for the ListView
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                // Wrap ListView with Flexible
                                                                child: StreamBuilder<
                                                                    QuerySnapshot>(
                                                                  stream: FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'Sub-Tenant')
                                                                      .where(
                                                                          'mainAccountId',
                                                                          isEqualTo:
                                                                              doc.id)
                                                                      .snapshots(),
                                                                  builder: (context,
                                                                      AsyncSnapshot<
                                                                              QuerySnapshot>
                                                                          snapshot) {
                                                                    if (snapshot
                                                                        .hasError) {
                                                                      return Text(
                                                                          'Something went wrong');
                                                                    }

                                                                    if (snapshot
                                                                            .connectionState ==
                                                                        ConnectionState
                                                                            .waiting) {
                                                                      return CircularProgressIndicator();
                                                                    }

                                                                    if (!snapshot
                                                                            .hasData ||
                                                                        snapshot
                                                                            .data!
                                                                            .docs
                                                                            .isEmpty) {
                                                                      return Text(
                                                                          'No data found');
                                                                    }

                                                                    // Data successfully retrieved
                                                                    return ListView(
                                                                      children: snapshot
                                                                          .data!
                                                                          .docs
                                                                          .map((DocumentSnapshot
                                                                              document) {
                                                                        Map<String,
                                                                                dynamic>
                                                                            data =
                                                                            document.data()
                                                                                as Map<String, dynamic>;

                                                                        String
                                                                            name =
                                                                            data['name'] ??
                                                                                'No name';
                                                                        String
                                                                            password =
                                                                            data['password'] ??
                                                                                'No password';
                                                                        String
                                                                            contact =
                                                                            data['contact'] ??
                                                                                'No contact';
                                                                        String
                                                                            mainAccountId =
                                                                            data['mainAccountId'] ??
                                                                                'No contact';

                                                                        return ListTile(
                                                                          title:
                                                                              Text(name),
                                                                          subtitle:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text('Password: $password'),
                                                                              Text('Contact: $contact'),
                                                                              Text('mainAccountId: $mainAccountId'),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      }).toList(),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(); // Close the dialog
                                                            },
                                                            child: const Text(
                                                                'Close'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              // Save logic based on vacantValue
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(); // Close the dialog
                                                            },
                                                            child: const Text(
                                                                'Save'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                } else if (newValue ==
                                                    'Reset Password') {
                                                  FirebaseFirestore.instance
                                                      .collection('tenant')
                                                      .doc(doc.id)
                                                      .update({
                                                    'password': '123456789',
                                                  });

                                                  SuccessMessage(
                                                      'Successfully Reset Password');
                                                } else if (newValue ==
                                                    'Archive') {
                                                  FirebaseFirestore.instance
                                                      .collection('tenant')
                                                      .doc(doc.id)
                                                      .update({
                                                    'archive': '1',
                                                  });

                                                  SuccessMessage(
                                                      'Successfully Archive Account');
                                                }
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
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      color: const Color.fromARGB(240, 17, 17, 17),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage('assets/manageuser.png'),
                            width: 40,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Admin',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 23),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
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
                                        'Username',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Container(
                                      width: MediaQuery.of(context).size.width /
                                          3.40,
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text(
                                        'Password',
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
                                          MediaQuery.of(context).size.width / 4,
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text(
                                        'Action',
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
                                    final username = doc['username'] ?? '';
                                    final password = doc['password'] ?? '';

                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(username,
                                                style: const TextStyle(
                                                    color: Colors.black)),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(password,
                                                style: const TextStyle(
                                                    color: Colors.black)),
                                          ),
                                        ),
                                        DataCell(
                                          DropdownButtonFormField<String>(
                                            value: selectedValue2,

                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                            icon: const FaIcon(FontAwesomeIcons
                                                .ellipsisVertical), // Remove the default dropdown icon
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                selectedValue2 = null;

                                                if (newValue ==
                                                    'Reset Password') {
                                                  FirebaseFirestore.instance
                                                      .collection('users')
                                                      .doc(doc.id)
                                                      .update({
                                                    'password': '123456789',
                                                  });

                                                  SuccessMessage(
                                                      'Successfully Reset Password');
                                                } else if (newValue ==
                                                    'Delete Account') {
                                                  FirebaseFirestore.instance
                                                      .collection('users')
                                                      .doc(doc.id)
                                                      .delete();
                                                  SuccessMessage(
                                                      'Successfully Delete Account');
                                                }
                                              });
                                            },
                                            items: dropdownItems2
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
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
                    ),
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

  // ignore: non_constant_identifier_names
  SuccessMessage(String label) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(label),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ));
  }
}
