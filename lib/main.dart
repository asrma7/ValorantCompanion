import 'package:flutter/material.dart';
import 'package:valorant_companion/Screens/landing_screen.dart';
import 'package:valorant_companion/Screens/login_screen.dart';
import 'package:valorant_companion/Screens/store_page.dart';
import 'package:valorant_companion/Screens/featured_page.dart';

import 'Screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/': (context) => const LandingScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(title: "Valorant Companion"),
        '/featured': (context) =>
            const FeaturedScreen(title: "Featured Bundle"),
        '/store': (context) => const StoreScreen(title: "Daily Offers"),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
