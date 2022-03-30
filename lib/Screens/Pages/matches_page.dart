import 'package:flutter/material.dart';

class MatchesPage extends StatefulWidget {
  final String title;
  const MatchesPage({Key? key, required this.title}) : super(key: key);

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text('Matches'),
      ),
    );
  }
}
