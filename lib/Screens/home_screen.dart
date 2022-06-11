import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:valorant_companion/Model/push_notification.dart';
import 'package:valorant_companion/Utils/database_helper.dart';
import 'package:valorant_companion/components/appbar.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../Utils/ad_helper.dart';
import '../components/drawer.dart';
import '../components/home_screen_card.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

const int maxFailedLoadAttempts = 3;
int currentAdLoadAttempt = 0;

AppOpenAd? _appOpenAd;

DatabaseHelper dbHelper = DatabaseHelper.instance;

registerNotification(context) async {
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      Navigator.pushNamed(context, '/notifications',
          arguments: PushNotification(
            title: message.notification!.title!,
            body: message.notification!.body!,
            imageUrl: message.notification?.android?.imageUrl ??
                message.notification?.apple?.imageUrl,
          ));
    }
  });
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  if ((await messaging.getNotificationSettings()).authorizationStatus ==
      AuthorizationStatus.denied) {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      Fluttertoast.showToast(msg: "Notification permission denied");
    }
  }

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    if (message.notification != null) {
      Navigator.pushNamed(context, '/notifications',
          arguments: PushNotification(
            title: message.notification!.title!,
            body: message.notification!.body!,
            imageUrl: message.notification?.android?.imageUrl ??
                message.notification?.apple?.imageUrl,
          ));
    }
  });
  FirebaseMessaging.onMessage.listen((message) {
    if (message.notification != null) {
      String? imageUrl = message.notification!.android?.imageUrl ??
          message.notification!.apple?.imageUrl;
      dbHelper.insertNotification({
        'titleText': message.notification!.title,
        'bodyText': message.notification!.body,
        'imageUrl': imageUrl,
      });
      FlutterRingtonePlayer.playNotification();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(message.notification!.title!),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              imageUrl != null
                  ? Image.network(
                      imageUrl,
                      height: 150,
                    )
                  : Container(),
              Text(message.notification!.body!),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  });
}

Future<void> _loadAppOpenAd(context) async {
  await MobileAds.instance.initialize();
  await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: <String>[]));
  await AppOpenAd.load(
    adUnitId: AdHelper.appOpenAdUnitId,
    request: const AdRequest(),
    adLoadCallback: AppOpenAdLoadCallback(
      onAdLoaded: (ad) {
        if (kDebugMode) {
          print('AppOpenAd loaded');
        }
        _showAppOpenAd(context);
        _appOpenAd = ad;
      },
      onAdFailedToLoad: (error) {
        if (kDebugMode) {
          print('AppOpenAd failed to load: $error');
          print(error.message);
        }
      },
    ),
    orientation: AppOpenAd.orientationPortrait,
  );
}

_showAppOpenAd(context) {
  if (_appOpenAd == null) {
    if (kDebugMode) {
      print('AppOpenAd not loaded yet');
    }
    if (currentAdLoadAttempt < maxFailedLoadAttempts) {
      currentAdLoadAttempt++;
      _loadAppOpenAd(context);
    }
    return;
  }
  _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
    onAdShowedFullScreenContent: (ad) {
      if (kDebugMode) {
        print('AppOpenAd showed full screen');
      }
    },
    onAdFailedToShowFullScreenContent: (ad, error) {
      ad.dispose();
      if (kDebugMode) {
        print('AppOpenAd failed to show full screen: $error');
      }
      _appOpenAd = null;
      _loadAppOpenAd(context);
    },
  );
  _appOpenAd!.show();
}

// _showAppOpenAd() {
//   if (_appOpenAd == null) {
//     print('AppOpenAd not loaded yet');
//     _loadAppOpenAd();
//     return;
//   }
//   _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
//     onAdShowedFullScreenContent: (ad) {
//       print('AppOpenAd showed full screen');
//     },
//     onAdFailedToShowFullScreenContent: (ad, error) {
//       ad.dispose();
//       print('AppOpenAd failed to show full screen: $error');
//       _appOpenAd = null;
//       _loadAppOpenAd();
//     },
//     onAdDismissedFullScreenContent: (ad){
//       ad.dispose();
//       print('AppOpenAd dismissed full screen');
//       _appOpenAd = null;
//       _loadAppOpenAd();
//     },
//   );
//   _appOpenAd!.show();
// }

class _HomeScreenState extends State<HomeScreen> {
  DatabaseHelper dbHelper = DatabaseHelper.instance;

  int? _totalNotifications = 0;

  @override
  void initState() {
    _loadAppOpenAd(context);
    registerNotification(context);
    _getNotificationCount();
    super.initState();
  }

  _getNotificationCount() async {
    dbHelper.getNotificationCount().then((value) => setState(() {
          _totalNotifications = value;
        }));
  }

  void createOpenAd() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        appbarTitle: widget.title,
        notificationCount: _totalNotifications!,
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
