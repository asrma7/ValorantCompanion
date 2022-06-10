import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:valorant_companion/Screens/Pages/crosshair_page.dart';
import 'package:valorant_companion/Screens/Pages/inventory_page.dart';
import 'package:valorant_companion/Screens/landing_screen.dart';
import 'package:valorant_companion/Screens/Pages/leaderboard_page.dart';
import 'package:valorant_companion/Screens/login_screen.dart';
import 'package:valorant_companion/Screens/Pages/matches_page.dart';
import 'package:valorant_companion/Screens/Pages/night_market_page.dart';
import 'package:valorant_companion/Screens/Pages/stats_page.dart';
import 'package:valorant_companion/Screens/Pages/store_page.dart';
import 'package:valorant_companion/Screens/Pages/featured_page.dart';
import 'package:valorant_companion/Utils/database_helper.dart';
import 'package:window_manager/window_manager.dart';

import 'Screens/Pages/notification_page.dart';
import 'Screens/home_screen.dart';

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) {
    await windowManager.ensureInitialized();
    await windowManager.hide();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setSize(const Size(350, 650));
      await windowManager.setAlignment(Alignment.centerRight);
      await windowManager.setResizable(false);
      await windowManager.show();
      await windowManager.setSkipTaskbar(false);
    });
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        title: 'Valorant Companion',
        theme: ThemeData(
          primarySwatch: Colors.red,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: {
          '/': (context) => const LandingScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(title: "Valorant Companion"),
          '/featured': (context) =>
              const FeaturedPage(title: "Featured Bundle"),
          '/store': (context) => const StorePage(title: "Daily Offers"),
          '/inventory': (context) => const InventoryPage(title: "Inventory"),
          '/nightmarket': (context) =>
              const NightMarketPage(title: "NightMarket Offers"),
          '/stats': (context) => const StatsPage(title: "Stats"),
          '/matches': (context) => const MatchesPage(title: "Matches"),
          '/leaderboard': (context) =>
              const LeaderboardPage(title: "Leaderboard"),
          '/crosshair': (context) =>
              const CrosshairPage(title: "Crosshair Presets"),
          '/notifications': (context) => const NotificationPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  if (message.notification != null) {
    String? imageUrl = message.notification!.android?.imageUrl ??
        message.notification!.apple?.imageUrl;
    dbHelper.insertNotification({
      'titleText': message.notification!.title,
      'bodyText': message.notification!.body,
      'imageUrl': imageUrl,
    });
  }
}
