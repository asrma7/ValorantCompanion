import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:valorant_companion/Library/src/url_manager.dart';

import '../Library/src/enums.dart';

class ItemDetailsScreen extends StatefulWidget {
  final String itemId, displayName, displayIcon, streamedVideo;
  final double? basePrice, discountedPrice, discountPercent;
  final ItemType itemType;
  const ItemDetailsScreen({
    Key? key,
    required this.itemId,
    required this.itemType,
    required this.displayName,
    required this.displayIcon,
    required this.streamedVideo,
    this.basePrice,
    this.discountedPrice,
    this.discountPercent,
  }) : super(key: key);

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.displayName),
      ),
      body: FutureBuilder(
        future: getItemPrice(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: Text('Price: ${snapshot.data}'),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Future<double> getItemPrice() async {
    if (widget.basePrice != null) {
      return widget.basePrice!;
    }
    var response = await Dio().get(
      '${UrlManager.getSingleOfferUrl}/${widget.itemId}',
    );
    return response.data['cost']['valorantPointCost'].toDouble();
  }
}
