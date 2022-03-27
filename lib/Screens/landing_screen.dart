import 'package:flutter/material.dart';

import '../Utils/database_helper.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final dbHelper = DatabaseHelper.instance;
    final userCount = await dbHelper.queryRowCount();

    if (userCount == 0) {
      Navigator.of(context).popAndPushNamed('/login');
    } else {
      Navigator.of(context).popAndPushNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/logo_rounded.png', height: 100),
      ),
    );
  }
}
