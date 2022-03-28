import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:valorant_companion/Library/valorant_client.dart';

import '../Library/src/models/user.dart';
import '../Utils/database_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final dbHelper = DatabaseHelper.instance;
  String _errorMessage = "";
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Region region = Region.ap;

  bool _handlingForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Valorant Companion'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo_rounded.png', height: 80),
                const SizedBox(height: 16),
                const Text(
                  'Welcome to Valorant Companion',
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please login to continue',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: _errorMessage == "" ? 0 : 16),
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                AutofillGroup(
                  child: Column(
                    children: [
                      TextField(
                        controller: _usernameController,
                        autofillHints: const [AutofillHints.username],
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        autofillHints: const [AutofillHints.password],
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                //Dropdown select
                const SizedBox(height: 16),
                const Text(
                  'Select your region',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                DropdownButton<Region>(
                  value: Region.ap,
                  items: const [
                    DropdownMenuItem<Region>(
                      value: Region.na,
                      child: Text('NA'),
                    ),
                    DropdownMenuItem<Region>(
                      value: Region.eu,
                      child: Text('EU'),
                    ),
                    DropdownMenuItem<Region>(
                      value: Region.ap,
                      child: Text('AP'),
                    ),
                    DropdownMenuItem<Region>(
                      value: Region.ko,
                      child: Text('KR'),
                    ),
                  ],
                  onChanged: (value) {
                    region = value!;
                  },
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _handlingForm
                        ? const [
                            Text('Login'),
                            SizedBox(width: 8),
                            CupertinoActivityIndicator(
                              color: Colors.white,
                            )
                          ]
                        : const [
                            Text('Login'),
                          ],
                  ),
                  onPressed: _handlingForm
                      ? null
                      : () {
                          setState(() {
                            _handlingForm = true;
                          });
                          processLogin().then((value) {
                            setState(() {
                              _handlingForm = false;
                            });
                            if (value) {
                              Navigator.popAndPushNamed(context, '/home');
                            } else {
                              setState(() {});
                            }
                          });
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> processLogin() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    if (username == "") {
      setState(() {
        _errorMessage = "Please enter a username";
      });
      return false;
    }
    if (password == "") {
      setState(() {
        _errorMessage = "Please enter a password";
      });
      return false;
    }
    ValorantClient client = ValorantClient(
      UserDetails(
        userName: username,
        password: password,
        region: region,
      ),
      shouldPersistSession: false,
      callback: Callback(
        onError: (String error) {
          if (kDebugMode) {
            _errorMessage = "Error: $error";
          }
        },
        onRequestError: (DioError error) {
          if (kDebugMode) {
            _errorMessage = "Error: ${error.message}";
          }
        },
      ),
    );

    bool resp = await client.init(false);

    if (resp) {
      User? user = await client.playerInterface.getPlayer();
      dbHelper.insert({
        'username': username,
        'password': password,
        'region': region.humanized.toUpperCase(),
        'display_name': user?.displayName,
        'subject': user?.subject,
        'game_name': user?.gameName,
        'tagLine': user?.tagLine,
      });
      return true;
    } else {
      return false;
    }
  }
}
