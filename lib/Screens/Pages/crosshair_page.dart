import 'package:flutter/material.dart';

class CrosshairPage extends StatefulWidget {
  final String title;
  const CrosshairPage({Key? key, required this.title}) : super(key: key);

  @override
  State<CrosshairPage> createState() => _CrosshairPageState();
}

class _CrosshairPageState extends State<CrosshairPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text('Crosshair'),
      ),
    );
  }
}
