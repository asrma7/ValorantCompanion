import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:valorant_companion/Library/src/models/inventory.dart';
import 'package:valorant_companion/Library/valorant_client.dart';

import '../Library/src/models/user.dart';
import '../Utils/database_helper.dart';

class LoginScreen extends StatefulWidget {
  final bool isBack;
  const LoginScreen({Key? key, this.isBack = false}) : super(key: key);

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
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          leading: widget.isBack
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.popAndPushNamed(context, '/home'),
                )
              : null,
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
                    value: region,
                    items: const [
                      DropdownMenuItem<Region>(
                        value: Region.na,
                        child: Text('North America'),
                      ),
                      DropdownMenuItem<Region>(
                        value: Region.eu,
                        child: Text('Europe'),
                      ),
                      DropdownMenuItem<Region>(
                        value: Region.ap,
                        child: Text('Asia Pacific'),
                      ),
                      DropdownMenuItem<Region>(
                        value: Region.kr,
                        child: Text('Korea (South)'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        region = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 16),
                  ElevatedButton(
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
                                Navigator.pushReplacementNamed(
                                    context, '/home');
                              } else {
                                setState(() {});
                              }
                            });
                          },
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      onWillPop: () async {
        if (widget.isBack) {
          Navigator.of(context).pushReplacementNamed('/home');
          return false;
        }
        return true;
      },
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
    const FlutterSecureStorage().deleteAll();
    ValorantClient client = ValorantClient(
      UserDetails(
        userName: username,
        password: password,
        region: region,
      ),
      shouldPersistSession: false,
      callback: Callback(
        onError: (String error) {
          setState(() {
            _errorMessage = "Error: $error";
          });
        },
        onRequestError: (DioError error) {
          setState(() {
            _errorMessage = "Error: ${error.message}";
          });
        },
      ),
    );
    bool resp = await client.init();

    if (resp) {
      User? user = await client.playerInterface.getPlayer();
      Inventory? inventory = await client.playerInterface.getInventory();
      dbHelper.insert({
        'username': username,
        'password': password,
        'region': region.humanized.toUpperCase(),
        'display_name': user?.displayName,
        'subject': user?.subject,
        'game_name': user?.gameName,
        'tagLine': user?.tagLine,
        'playerCard':
            'https://media.valorant-api.com/playercards/${inventory!.identity!.playerCardID!}/smallart.png',
        'isActive': 1,
      });
      return true;
    } else {
      return false;
    }
  }
}
