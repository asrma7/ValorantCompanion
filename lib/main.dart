import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import 'package:window_manager/window_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'Screens/home_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Handling a background message ${message.messageId}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) {
    // Must add this line.
    await windowManager.ensureInitialized();

    // Use it only after calling `hiddenWindowAtLaunch`
    await windowManager.hide();
    windowManager.waitUntilReadyToShow().then((_) async {
      // Hide window title bar
      await windowManager.setSize(const Size(350, 650));
      await windowManager.setAlignment(Alignment.centerRight);
      await windowManager.setResizable(false);
      await windowManager.show();
      await windowManager.setSkipTaskbar(false);
    });
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(const MyApp());
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    var initialzationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initialzationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (kDebugMode) {
        print(message.data);
      }
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.blue,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: "@mipmap/ic_launcher",
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title!),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body!)],
                  ),
                ),
              );
            });
      }
    });

    getToken();
  }

  String? token;

  getToken() async {
    token = await FirebaseMessaging.instance.getToken();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valorant Companion',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/': (context) => const LandingScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(title: "Valorant Companion"),
        '/featured': (context) => const FeaturedPage(title: "Featured Bundle"),
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
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
