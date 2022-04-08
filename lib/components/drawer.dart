import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:valorant_companion/Screens/login_screen.dart';
import '../Library/valorant_client.dart';
import '../Utils/database_helper.dart';
import '../Utils/helpers.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  bool showUserDetails = false;
  bool _isLoading = false;
  final dbHelper = DatabaseHelper.instance;

  Future<Map<String, dynamic>?> loadUserData() async {
    var value = await dbHelper.queryAllRows();
    try {
      var user = value.singleWhere((element) => element['isActive'] == 1);
      return {'users': value, 'user': user};
    } catch (e) {
      Navigator.pop(context);
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      Navigator.pushNamed(context, '/');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    ImageProvider _avatar;
    return Drawer(
      child: FutureBuilder(
          future: loadUserData(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && snapshot.data['users'] != null) {
              var users = snapshot.data['users'];
              var user = snapshot.data['user'];
              if (user['playerCard'] != null && user['playerCard'] != '') {
                _avatar = NetworkImage(user['playerCard']);
              } else {
                _avatar = const AssetImage('assets/images/valorant_logo.png');
              }
              return Column(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: Text('${user['display_name']}'),
                    accountEmail: Text(
                        '${user['game_name']}#${user['tagLine']} (${user['region']})'),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: _avatar,
                    ),
                    onDetailsPressed: () {
                      setState(() {
                        showUserDetails = !showUserDetails;
                      });
                    },
                  ),
                  Expanded(
                    child: showUserDetails
                        ? _buildUserDetail(users)
                        : _buildDrawerList(),
                  )
                ],
              );
            }
            return Container();
          }),
    );
  }

  Widget _buildUserDetail(users) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var otherAccountUser = users[index];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                leading: otherAccountUser['playerCard'] != null &&
                        otherAccountUser['playerCard'] != ''
                    ? Image.network(otherAccountUser['playerCard'])
                    : Image.asset('assets/images/valorant_logo.png'),
                title: Text(
                    '${otherAccountUser['game_name']}#${otherAccountUser['tagLine']} (${otherAccountUser['region']})'),
                onTap: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  const FlutterSecureStorage().deleteAll();
                  ValorantClient client = ValorantClient(
                    UserDetails(
                      userName: users[index]['username'],
                      password: users[index]['password'],
                      region: stringToRegion(users[index]['region'])!,
                    ),
                    shouldPersistSession: false,
                    callback: Callback(
                      onError: (String error) {
                        SnackBar(
                          content: Text(
                            error,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.red,
                        );
                      },
                      onRequestError: (DioError error) {
                        SnackBar(
                          content: Text(
                            error.message,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.red,
                        );
                      },
                    ),
                  );
                  bool resp = await client.init();
                  if (resp) {
                    await dbHelper.rawUpdate('UPDATE users SET isActive = 0');
                    await dbHelper.update({
                      'id': users[index]['id'],
                      'isActive': 1,
                    });
                  }
                  setState(() {
                    _isLoading = false;
                  });
                },
              );
            },
          ),
        ),
        GestureDetector(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add),
                Text("Add Account"),
              ],
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(
                  isBack: true,
                ),
              ),
            );
          },
        )
      ],
    );
  }

  Widget _buildDrawerList() {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Home'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.collections),
          title: const Text('Featured Bundle'),
          onTap: () {
            Navigator.popAndPushNamed(context, '/featured');
          },
        ),
        ListTile(
          leading: const Icon(Icons.card_giftcard),
          title: const Text('Daily Offers'),
          onTap: () {
            Navigator.popAndPushNamed(context, '/store');
          },
        ),
        ListTile(
          leading: const Icon(Icons.shop_2),
          title: const Text('Night Market'),
          onTap: () {
            Navigator.popAndPushNamed(context, '/nightmarket');
          },
        ),
        // ListTile(
        //   leading: const Icon(Icons.person),
        //   title: const Text('Account'),
        //   onTap: () {
        //     Navigator.pop(context);
        //   },
        // ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () {
            final dbHelper = DatabaseHelper.instance;
            dbHelper.logout();
            const FlutterSecureStorage().deleteAll();
            Navigator.pop(context);
            Navigator.popAndPushNamed(context, '/');
          },
        ),
      ],
    );
  }
}
