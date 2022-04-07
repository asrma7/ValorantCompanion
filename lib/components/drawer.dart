import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Utils/database_helper.dart';

Map<String, dynamic> user = {
  'username': '',
  'password': '',
  'region': '',
};

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final dbHelper = DatabaseHelper.instance;
  @override
  void initState() {
    loadUserData();
    super.initState();
  }

  void loadUserData() async {
    await dbHelper.queryAllRows().then((value) {
      setState(() {
        user = value[0];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider _avatar;
    if (user['playerCard'] != null && user['playerCard'] != '') {
      _avatar = NetworkImage(user['playerCard']);
    } else {
      _avatar = const AssetImage('assets/images/default_avatar.png');
    }
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text('${user['display_name']}'),
            accountEmail: Text(
                '${user['game_name']}#${user['tagLine']} (${user['region']})'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: _avatar,
            ),
          ),
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
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Account'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
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
              dbHelper.deleteAll();
              const FlutterSecureStorage().deleteAll();
              Navigator.pop(context);
              Navigator.popAndPushNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
