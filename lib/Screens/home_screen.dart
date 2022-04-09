import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:valorant_companion/Utils/database_helper.dart';
import 'package:valorant_companion/components/appbar.dart';

import '../Model/push_notification.dart';
import '../components/drawer.dart';
import '../components/home_screen_card.dart';
import 'Pages/notification_page.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  int _totalNotifications = 0;
  late final FirebaseMessaging _messaging;

  @override
  void initState() {
    registerNotification();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationPage(
            openNotification: notification,
          ),
        ),
      );
    });
    super.initState();
  }

  void registerNotification() async {
    await Firebase.initializeApp();

    _messaging = FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    print(await _messaging.getToken());

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
        );
        await dbHelper.insertNotification(
          {
            'titleText': message.notification?.title,
            'bodyText': message.notification?.body,
            'imageUrl': message.notification?.android?.imageUrl ??
                message.notification?.apple?.imageUrl,
            'isRead': false,
          },
        );

        setState(() {
          _totalNotifications++;
        });

        showSimpleNotification(
          Text(notification.title!),
          leading: Image.asset('assets/images/logo_rounded.png'),
          subtitle: Text(notification.body!),
          background: Colors.cyan.shade700,
          duration: const Duration(seconds: 2),
        );
      });
    } else {
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        appbarTitle: widget.title,
        notificationCount: _totalNotifications,
        context: context,
      ),
      body: GridView(
        padding: const EdgeInsets.all(10.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        children: <Widget>[
          HomeScreenCard(
            cardTitle: 'Featured',
            cardSubtitle:
                'Get information about your daily offers and featured item from the market',
            cardImage: 'assets/images/featured.png',
            onTap: () {
              Navigator.pushNamed(context, '/featured');
            },
          ),
          HomeScreenCard(
            cardTitle: 'Daily Offers',
            cardSubtitle:
                'Get information about your daily offers and featured item from the market',
            cardImage: 'assets/images/store.png',
            onTap: () {
              Navigator.pushNamed(context, '/store');
            },
          ),
          HomeScreenCard(
            cardTitle: 'Night Market',
            cardSubtitle:
                'Get information about the items you can buy at the night market',
            cardImage: 'assets/images/nightmarket.png',
            onTap: () {
              Navigator.pushNamed(context, '/nightmarket');
            },
          ),
          HomeScreenCard(
            cardTitle: 'Inventory',
            cardSubtitle:
                'Get information about your inventory and your current stats',
            cardImage: 'assets/images/inventory.png',
            onTap: () {
              Navigator.pushNamed(context, '/inventory');
            },
          ),
          HomeScreenCard(
            cardTitle: 'Stats',
            cardSubtitle: 'Get information about your current stats',
            cardImage: 'assets/images/stats.png',
            onTap: () {
              Navigator.pushNamed(context, '/stats');
            },
          ),
          HomeScreenCard(
            cardTitle: 'Matches',
            cardSubtitle: 'Get information about your match history',
            cardImage: 'assets/images/matches.png',
            onTap: () {
              Navigator.pushNamed(context, '/matches');
            },
          ),
          HomeScreenCard(
            cardTitle: 'Leaderboard',
            cardSubtitle: 'Get information about the leaderboard',
            cardImage: 'assets/images/leaderboard.png',
            onTap: () {
              Navigator.pushNamed(context, '/leaderboard');
            },
          ),
          HomeScreenCard(
            cardTitle: 'Crosshair',
            cardSubtitle: 'Get your favourite crosshair presets',
            cardImage: 'assets/images/crosshair.png',
            onTap: () {
              Navigator.pushNamed(context, '/crosshair');
            },
          ),
        ],
      ),
      drawer: const MyDrawer(),
    );
  }
}

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    await dbHelper.insertNotification(
      {
        'titleText': message.notification?.title,
        'bodyText': message.notification?.body,
        'imageUrl': message.notification?.android?.imageUrl ??
            message.notification?.apple?.imageUrl,
        'isRead': false,
      },
    );
  }
}
