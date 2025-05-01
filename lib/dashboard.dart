import 'package:bogsandmila/adminaccount.dart';
import 'package:bogsandmila/announce.dart';
import 'package:bogsandmila/archive.dart';
import 'package:bogsandmila/building.dart';
import 'package:bogsandmila/login.dart';
import 'package:bogsandmila/logo.dart';
import 'package:bogsandmila/manageuser.dart';
import 'package:bogsandmila/message.dart';
import 'package:bogsandmila/request.dart';
import 'package:bogsandmila/salesrecord.dart';
import 'package:bogsandmila/tenant.dart';
import 'package:bogsandmila/vacancy.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
                  GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.bottomLeft,
                      child: FaIcon(FontAwesomeIcons.signOut),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                  ),
                  LogoPage(uid: widget.uid, type: widget.type),
                  const SizedBox(height: 30),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      widget.type == 'Admin' ? 'Admin' : 'Super Admin',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 23),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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
                                    onTap: _launchURL,
                                    child: Container(
                                      width: 200,
                                      height: 200,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xddF6F6F4),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image(
                                            image: AssetImage(
                                                'assets/updatedatabase.png'),
                                            fit: BoxFit.cover,
                                          ),
                                          Text(
                                            'Update Database',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 17),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  _cardContainer(
                                      2, "Message", "assets/message.png"),
                                  _cardContainer(6, "Manage User",
                                      "assets/manageuser.png"),
                                ],
                              ),
                          if (widget.type == 'Admin')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _cardContainer(
                                    1, "Announce", "assets/announce.png"),
                                _cardContainer(
                                    2, "Message", "assets/message.png"),
                                _cardContainer(
                                    3, "Request", "assets/request.png"),
                              ],
                            ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              if (widget.type == 'Admin')
                                _cardContainer(4, "Sales Record",
                                    "assets/salesrecord.png"),
                              // _cardContainer(
                              //     5, "Vacancy", "assets/vacancy.png"),
                              if (widget.type == 'Admin')
                                _cardContainer(
                                    6, "Manage User", "assets/manageuser.png"),
                              _cardContainer(
                                  7, "Building", "assets/house2.png"),
                              _cardContainer(
                                  8, "Archive", "assets/archive.png"),
                            ],
                          ),
                        ],
                      )),
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
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            if (id == 1) {
              return AnnouncePage(uid: widget.uid, type: widget.type);
            } else if (id == 2) {
              return MessagePage(uid: widget.uid, type: widget.type);
            } else if (id == 3) {
              return RequestPage(uid: widget.uid, type: widget.type);
            } else if (id == 4) {
              return SalesRecordPage(uid: widget.uid, type: widget.type);
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
              return ArchivePage(uid: widget.uid, type: widget.type);
            } else if (id == 9) {
              return AdminAccountPage(uid: widget.uid, type: widget.type);
            } else if (id == 10) {
              return ManageUserPage(uid: widget.uid, type: widget.type);
            } else {
              return AnnouncePage(uid: widget.uid, type: widget.type);
            }
          }));
        });
  }
}
