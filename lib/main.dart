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
