import 'package:flutter/material.dart';

class LeaderboardPage extends StatefulWidget {
  final String title;
  const LeaderboardPage({Key? key, required this.title}) : super(key: key);

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text('Leaderboard not implemented yet'),
      ),
    );
  }
}
