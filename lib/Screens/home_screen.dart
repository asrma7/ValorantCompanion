import 'package:flutter/material.dart';
import 'package:valorant_companion/components/appbar.dart';

import '../components/drawer.dart';
import '../components/home_screen_card.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(appbarTitle: widget.title),
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
            cardTitle: 'Store',
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
        ],
      ),
      drawer: const MyDrawer(),
    );
  }
}
