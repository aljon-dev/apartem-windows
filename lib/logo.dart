import 'package:bogsandmila/dashboard.dart';
import 'package:flutter/material.dart';

class LogoPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables

  const LogoPage({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _LogoPage createState() => _LogoPage();
}

class _LogoPage extends State<LogoPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: GestureDetector(
          child: const Image(
            image: AssetImage('assets/logo.png'),
            fit: BoxFit.cover,
          ),
          onTap: () {},
        ));
  }
}
