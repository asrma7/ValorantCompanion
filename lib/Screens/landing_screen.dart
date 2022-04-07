import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Library/valorant_client.dart';
import '../Utils/database_helper.dart';
import '../Utils/helpers.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  DatabaseHelper? dbHelper;
  Future<List<Map<String, dynamic>>> _loadUserData() async {
    dbHelper = DatabaseHelper.instance;
    List<int?> rowCount = await dbHelper!.queryRowCount();
    if (rowCount[0] == 0) {
      Navigator.of(context).popAndPushNamed('/login');
    } else if (rowCount[1] != 0) {
      Navigator.of(context).popAndPushNamed('/home');
    } else {
      return await dbHelper!.queryAllRows();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : FutureBuilder(
              future: _loadUserData(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  List<Map<String, dynamic>> users = snapshot.data;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Choose Account",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .75,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: users.length,
                          itemBuilder: (context, index) => Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10.0,
                                  spreadRadius: 5.0,
                                  offset: Offset(0.0, 0.0),
                                ),
                              ],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            child: ListTile(
                              leading: users[index]['playerCard'] != null &&
                                      users[index]['playerCard'] != ''
                                  ? Image.network(users[index]['playerCard'])
                                  : Image.asset(
                                      'assets/images/valorant_logo.png'),
                              title: Text(
                                  '${users[index]['game_name']}#${users[index]['tagLine']} (${users[index]['region']})'),
                              onTap: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                const FlutterSecureStorage().deleteAll();
                                ValorantClient client = ValorantClient(
                                  UserDetails(
                                    userName: users[index]['username'],
                                    password: users[index]['password'],
                                    region:
                                        stringToRegion(users[index]['region'])!,
                                  ),
                                  shouldPersistSession: false,
                                  callback: Callback(
                                    onError: (String error) {
                                      if (kDebugMode) {
                                        SnackBar(
                                          content: Text(
                                            error,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: Colors.red,
                                        );
                                      }
                                    },
                                    onRequestError: (DioError error) {
                                      if (kDebugMode) {
                                        SnackBar(
                                          content: Text(
                                            error.message,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: Colors.red,
                                        );
                                      }
                                    },
                                  ),
                                );
                                bool resp = await client.init();
                                setState(() {
                                  _isLoading = false;
                                });
                                if (resp) {
                                  await dbHelper!.rawUpdate(
                                      'UPDATE users SET isActive = 0');
                                  await dbHelper!.update({
                                    'id': users[index]['id'],
                                    'isActive': 1,
                                  });
                                  Navigator.of(_scaffoldKey.currentContext!)
                                      .popAndPushNamed('/home');
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await dbHelper!.deleteAll();
                          Navigator.of(context).popAndPushNamed('/login');
                        },
                        child: const Text('Logout of all Accounts'),
                      ),
                    ],
                  );
                }
                return Center(
                  child: Image.asset('assets/images/logo_rounded.png',
                      height: 100),
                );
              },
            ),
    );
  }
}
