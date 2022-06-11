import 'package:flutter/material.dart';

class StatsPage extends StatefulWidget {
  final String title;
  const StatsPage({Key? key, required this.title}) : super(key: key);

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text('Stats not implemented yet'),
      ),
    );
  }
}
