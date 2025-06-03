import 'dart:io';

import 'package:bogsandmila/AdminOnly/BuildingUnitsAdmin.dart';
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
import 'package:emailjs/emailjs.dart' as emailjs;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

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

    final QuerySnapshot tenantSnapshot =
        await _firestore.collection('tenant').get();

    for (final doc in tenantSnapshot.docs) {
      final String uid = doc.id;
      final int rentalCost = doc['rentalfee'];
      final String payerName = doc['firstname'];
      final String? unitNumber = doc.data().toString().contains('unitnumber')
          ? doc['unitnumber']
          : null;
      final int dueDay = doc.data().toString().contains('due_day')
          ? doc['due_day']
          : 30; // fallback to 30

      // Check if sales record already exists for this month/year/user
      final QuerySnapshot existing = await _firestore
          .collection('sales_record')
          .where('uid', isEqualTo: uid)
          .where('due_month_number', isEqualTo: currentMonth)
          .where('due_year', isEqualTo: currentYear)
          .get();

      if (existing.docs.isEmpty) {
        final String formattedDateTime =
            DateFormat("yyyy-MM-dd – HH:mm").format(now);
        final String dueDateFormatted =
            "$dueDay/${currentMonth.toString().padLeft(2, '0')}/$currentYear";

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
    const months = [
      '',
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
      'December'
    ];
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StreamBuilder<QuerySnapshot>(
                            stream: _firestore
                                .collection('notifications')
                                .where('userId', isEqualTo: 'userAdmin')
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                const Center(
                                    child:
                                        Text('Failed to load notifications'));
                              }

                              final notifData = snapshot.data!.docs;
                              final unReadCount = notifData
                                  .where((doc) => doc['isRead'] == false)
                                  .length;
                              return Row(
                                children: [
                                  IconButton(
                                    icon: Icon(unReadCount != 0
                                        ? Icons.notification_important_outlined
                                        : Icons.notifications),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  notificationPage()));
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
                                  title:
                                      const Center(child: Text('Confirmation')),
                                  content: const Text(
                                      'Are You Sure Want to log out?'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginPage()),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                  StreamBuilder<DocumentSnapshot>(
                    stream: _firestore
                        .collection('Super-Admin')
                        .doc(widget.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text(
                                widget.type == 'Admin'
                                    ? 'Admin'
                                    : 'Super Admin',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 23),
                              ),
                            ],
                          ),
                        );
                      }

                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          !snapshot.data!.exists) {
                        return Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.type == 'Admin'
                                    ? 'Admin'
                                    : 'Super Admin',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 23),
                              ),
                            ],
                          ),
                        );
                      }

                      final userData =
                          snapshot.data!.data() as Map<String, dynamic>;

                      return UserProfileWidget(
                        userType: widget.type,
                        documentId: widget.uid,
                        currentEmail: userData['email'] ?? 'No email',
                        currentPassword: userData['password'] ?? '',
                        profileImageUrl: userData['profile'] ?? '',
                      );
                    },
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
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  buildingUnits(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image(
                                            image: AssetImage(
                                                'assets/updatedatabase.png'),
                                            fit: BoxFit.cover,
                                          ),
                                          Text(
                                            'Update Building',
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
                                  _cardContainer(6, "Manage Admin User",
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
                              // _cardContainer(
                              //     5, "Vacancy", "assets/vacancy.png"),
                              if (widget.type == 'Super Admin')
                                _cardContainer(
                                    1, "Announce", "assets/announce.png"),
                              if (widget.type == 'Super Admin')
                                _cardContainer(
                                    3, "Request", "assets/request.png"),
                              if (widget.type == 'Admin')
                                _cardContainer(
                                    8, "Archive", "assets/archive.png"),
                              if (widget.type == 'Admin')
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                BuildingUnitsAdminDesktop(
                                                  userId: widget.uid,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image(
                                          image: AssetImage(
                                              'assets/updatedatabase.png'),
                                          fit: BoxFit.cover,
                                        ),
                                        Text(
                                          'Building Units',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 17),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
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
            } else if (id == 4) {
              return buildingUnits(userid: '');
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

class UserProfileWidget extends StatefulWidget {
  final String currentEmail;
  final String currentPassword;
  final String profileImageUrl;
  final String documentId;
  final String userType; // "Admin" or "Super Admin"

  const UserProfileWidget({
    Key? key,
    required this.currentEmail,
    required this.currentPassword,
    required this.profileImageUrl,
    required this.documentId,
    required this.userType,
  }) : super(key: key);

  @override
  _UserProfileWidgetState createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.currentEmail;
    _passwordController.text = widget.currentPassword;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showUserSettingsDialog() {
    _emailController.text = widget.currentEmail;
    _passwordController.text = widget.currentPassword;
    _confirmPasswordController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.settings, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('User Settings'),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(type: FileType.image);
                          if (result != null &&
                              result.files.single.path != null) {
                            File file = File(result.files.single.path!);
                            String fileName = path.basename(file.path);

                            try {
                              setState(() {
                                _isLoading = true;
                              });

                              final ref = FirebaseStorage.instance
                                  .ref()
                                  .child('profile_images/$fileName');
                              await ref.putFile(file);
                              final downloadUrl = await ref.getDownloadURL();

                              await _firestore
                                  .collection('Super-Admin')
                                  .doc(widget.documentId)
                                  .update({
                                'profile': downloadUrl,
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Profile image updated!'),
                                    backgroundColor: Colors.green),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Failed to upload image: $e'),
                                    backgroundColor: Colors.red),
                              );
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                            border: Border.all(color: Colors.blue, width: 2),
                          ),
                          child: widget.profileImageUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    widget.profileImageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.person,
                                          size: 40, color: Colors.grey[600]);
                                    },
                                  ),
                                )
                              : Icon(Icons.person,
                                  size: 40, color: Colors.grey[600]),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Tap to change picture',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                      SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Please enter an email';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Please enter a password';
                          if (value.length < 6)
                            return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Please confirm your password';
                          if (value != _passwordController.text)
                            return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed:
                      _isLoading ? null : () => _updateUserSettings(setState),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateUserSettings(StateSetter setState) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final updatedEmail = _emailController.text.trim();

    try {
      // 1. Update Firestore credentials
      await _firestore.collection('Super-Admin').doc(widget.documentId).update({
        'email': updatedEmail,
        'password': _passwordController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Send notification email
      await _sendPasswordChangeEmail(updatedEmail);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Settings updated successfully!'),
            backgroundColor: Colors.green),
      );
      await emailjs.send(
        'service_ralmb2g', // Use your own service ID
        'template_rahmraj', // Use a dedicated template like 'template_passwordchange'
        {
          'email': _emailController.text.trim(),
          'name': 'Admin', // Or the admin's name if you have it
          'password': _passwordController.text.trim(),
        },
        const emailjs.Options(
          publicKey: 'VyqEOTlbKR9yzkJ2H',
          privateKey: '33HeQw8TVZFY62e2b6WjK',
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error updating settings: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendPasswordChangeEmail(String email) async {
    try {
      final url = Uri.parse(
          "https://<YOUR_CLOUD_FUNCTION_URL>/sendPasswordChangeEmail");
      final response = await HttpClient().postUrl(url)
        ..headers.set('Content-Type', 'application/json')
        ..write('{"email": "$email"}');

      final result = await response.close();
      if (result.statusCode == 200) {
        print('Password change email sent');
      } else {
        print('Failed to send email: ${result.statusCode}');
      }
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.userType ==
              'Super Admin') // Only show avatar for Super Admin
            GestureDetector(
              onTap: _showUserSettingsDialog,
              child: Container(
                width: 50,
                height: 50,
                margin: EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue[100],
                  border: Border.all(color: Colors.blue, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: widget.profileImageUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          widget.profileImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.person, size: 30, color: Colors.blue),
                        ),
                      )
                    : Icon(Icons.person, size: 30, color: Colors.blue),
              ),
            ),
          Text(
            widget.userType == 'Admin' ? 'Admin' : 'Super Admin',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 23),
          ),
        ],
      ),
    );
  }
}
