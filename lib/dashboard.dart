import 'package:bogsandmila/adminaccount.dart';
import 'package:bogsandmila/announce.dart';
import 'package:bogsandmila/archive.dart';
import 'package:bogsandmila/building.dart';
import 'package:bogsandmila/buildingUnits.dart';
import 'package:bogsandmila/login.dart';
import 'package:bogsandmila/logo.dart';
import 'package:bogsandmila/manageuser.dart';
import 'package:bogsandmila/message.dart';
import 'package:bogsandmila/notifications.dart';
import 'package:bogsandmila/request.dart';
import 'package:bogsandmila/salesrecord.dart';
import 'package:bogsandmila/tenant.dart';
import 'package:bogsandmila/vacancy.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final uid;
  // ignore: prefer_typing_uninitialized_variables
  final type;
  const DashboardPage({super.key, required this.uid, required this.type});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardPage createState() => _DashboardPage();
}

class _DashboardPage extends State<DashboardPage> {
  final _firestore = FirebaseFirestore.instance;

  void _launchURL() async {
    const url = 'https://chatgpt.com/c/66f678fd-2130-8012-937b-aac2917509e6';
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> AutomaticSendPayment() async {
    final DateTime now = DateTime.now();
    final int currentMonth = now.month;
    final int currentYear = now.year;

    final QuerySnapshot tenantSnapshot = await _firestore.collection('tenant').get();

    for (final doc in tenantSnapshot.docs) {
      final String uid = doc.id;
      final int rentalCost = doc['rentalfee'];
      final String payerName = doc['firstname'];
      final String? unitNumber = doc.data().toString().contains('unitnumber') ? doc['unitnumber'] : null;
      final int dueDay = doc.data().toString().contains('due_day') ? doc['due_day'] : 30; // fallback to 30

      // Check if sales record already exists for this month/year/user
      final QuerySnapshot existing = await _firestore.collection('sales_record').where('uid', isEqualTo: uid).where('due_month_number', isEqualTo: currentMonth).where('due_year', isEqualTo: currentYear).get();

      if (existing.docs.isEmpty) {
        final String formattedDateTime = DateFormat("yyyy-MM-dd – HH:mm").format(now);
        final String dueDateFormatted = "$dueDay/${currentMonth.toString().padLeft(2, '0')}/$currentYear";

        await _firestore.collection('sales_record').add({
          'Amount': '', // blank until payment
          'GcashNumber': '',
          'ReferenceNumber': '',
          'buildingnumber': null,
          'datetime': formattedDateTime,
          'due_date': dueDateFormatted,
          'due_day': dueDay,
          'due_month_number': currentMonth,
          'due_year': currentYear,
          'imageUrl': '',
          'month': _getMonthName(currentMonth),
          'payer_name': payerName,
          'rental_cost': rentalCost,
          'status': 'Unpaid',
          'uid': uid,
          'unitnumber': unitNumber,
          'year': currentYear.toString(),
        });
      }
    }
  }

  String _getMonthName(int monthNumber) {
    const months = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[monthNumber];
  }

  @override
  void initState() {
    super.initState();

    AutomaticSendPayment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StreamBuilder<QuerySnapshot>(
                            stream: _firestore.collection('notifications').where('userId', isEqualTo: 'userAdmin').snapshots(),
                            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                const Center(child: Text('Failed to load notifications'));
                              }

                              final notifData = snapshot.data!.docs;
                              final unReadCount = notifData.where((doc) => doc['isRead'] == false).length;
                              return Row(
                                children: [
                                  IconButton(
                                    icon: Icon(unReadCount != 0 ? Icons.notification_important_outlined : Icons.notifications),
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => notificationPage()));
                                    },
                                  ),
                                  Text('Notifications'),
                                ],
                              );
                            }),

                        // Log out (Top Right)
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Center(child: Text('Confirmation')),
                                  content: const Text('Are You Sure Want to log out?'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const LoginPage()),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text('Confirm'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text('Cancel'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Row(
                            children: [
                              Text('Log Out'),
                              SizedBox(width: 5),
                              Icon(Icons.logout),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  LogoPage(),
                  const SizedBox(height: 30),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      widget.type == 'Admin' ? 'Admin' : 'Super Admin',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 23),
                    ),
                  ),
                  SizedBox(height: widget.type == 'Super Admin' ? 90 : 10),
                  SizedBox(
                      width: widget.type == 'Admin' ? 900 : 900,
                      child: Column(
                        children: [
                          if (widget.type == 'Super Admin')
                            if (widget.type == 'Super Admin')
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  // GestureDetector(
                                  //   onTap: _launchURL,
                                  //   child: Container(
                                  //     width: 200,
                                  //     height: 200,
                                  //     alignment: Alignment.center,
                                  //     decoration: BoxDecoration(
                                  //       color: const Color(0xddF6F6F4),
                                  //       borderRadius: BorderRadius.circular(5),
                                  //     ),
                                  //     child: const Column(
                                  //       mainAxisAlignment:
                                  //           MainAxisAlignment.center,
                                  //       children: [
                                  //         Image(
                                  //           image: AssetImage(
                                  //               'assets/systemmaintenance.png'),
                                  //           fit: BoxFit.cover,
                                  //         ),
                                  //         Text(
                                  //           'Maintenance System',
                                  //           style: TextStyle(
                                  //               fontWeight: FontWeight.w700,
                                  //               fontSize: 17),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => buildingUnits(
                                                    userid: widget.uid,
                                                  )));
                                    },
                                    child: Container(
                                      width: 200,
                                      height: 200,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xddF6F6F4),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image(
                                            image: AssetImage('assets/updatedatabase.png'),
                                            fit: BoxFit.cover,
                                          ),
                                          Text(
                                            'Update Building',
                                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  _cardContainer(2, "Message", "assets/message.png"),
                                  _cardContainer(6, "Manage Admin User", "assets/manageuser.png"),
                                ],
                              ),
                          if (widget.type == 'Admin')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _cardContainer(1, "Announce", "assets/announce.png"),
                                _cardContainer(2, "Message", "assets/message.png"),
                                _cardContainer(3, "Request", "assets/request.png"),
                              ],
                            ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // _cardContainer(
                              //     5, "Vacancy", "assets/vacancy.png"),
                              if (widget.type == 'Super Admin') _cardContainer(1, "Announce", "assets/announce.png"),
                              if (widget.type == 'Super Admin') _cardContainer(3, "Request", "assets/request.png"),

                              _cardContainer(8, "Archive", "assets/archive.png"),
                            ],
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _cardContainer(int id, String label, String pathImage) {
    return GestureDetector(
        child: Container(
          width: 200,
          height: 200,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xddF6F6F4),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage(pathImage),
                fit: BoxFit.cover,
              ),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            if (id == 1) {
              return announcementPage();
            } else if (id == 2) {
              return messagePage(
                userid: widget.uid,
                firstname: '',
              );
            } else if (id == 3) {
              return RequestPage(uid: widget.uid, type: widget.type);
            } else if (id == 5) {
              return VacancyPage(uid: widget.uid, type: widget.type);
            } else if (id == 6) {
              if (widget.type == "Admin") {
                return ManageUserPage(uid: widget.uid, type: widget.type);
              } else {
                return AdminAccountPage(uid: widget.uid, type: widget.type);
              }
            } else if (id == 7) {
              return BuildingPage(uid: widget.uid, type: widget.type);
            } else if (id == 8) {
              return ArchivePage();
            } else if (id == 9) {
              return AdminAccountPage(uid: widget.uid, type: widget.type);
            } else if (id == 10) {
              return ManageUserPage(uid: widget.uid, type: widget.type);
            } else {
              return announcementPage();
            }
          }));
        });
  }
}
