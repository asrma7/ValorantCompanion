import 'package:flutter/material.dart';

class NightMarketPage extends StatefulWidget {
  final String title;
  const NightMarketPage({Key? key, required this.title}) : super(key: key);

  @override
  State<NightMarketPage> createState() => _NightMarketPageState();
}

class _NightMarketPageState extends State<NightMarketPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text('NightMarket Offers'),
      ),
    );
  }
}
