import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:valorant_companion/Utils/helpers.dart';
import '../Library/valorant_client.dart';
import '../Utils/database_helper.dart';

class UpdateUserPassword extends StatefulWidget {
  const UpdateUserPassword({Key? key, required this.user}) : super(key: key);

  final Map<String, dynamic> user;

  @override
  State<UpdateUserPassword> createState() => _UpdateUserPasswordState();
}

class _UpdateUserPasswordState extends State<UpdateUserPassword> {
  final dbHelper = DatabaseHelper.instance;
  String _errorMessage = "";
  final TextEditingController _passwordController = TextEditingController();

  bool _handlingForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Password'),
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
                  'Your Account Password Has Changed',
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
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                            text: widget.user['username']),
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
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(context, '/home');
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
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _handlingForm
                      ? null
                      : () {
                          dbHelper.delete(widget.user['id']).then((value) {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          });
                        },
                  child: const Text('RemoveAccount'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> processLogin() async {
    String username = widget.user['username'];
    String password = _passwordController.text;
    Region? region = stringToRegion(widget.user['region']);
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
    ValorantClient client = ValorantClient.instance;
    bool resp = await client.authenticate(username, password, region!);

    if (resp) {
      dbHelper.update({
        'id': widget.user['id'],
        'password': password,
        'isActive': 1,
        'hasError': 0,
      });
      return true;
    } else {
      return false;
    }
  }
}
