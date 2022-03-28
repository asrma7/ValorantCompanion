import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:valorant_companion/Library/valorant_client.dart';
import 'package:valorant_companion/Screens/item_details_page.dart';
import '../Library/src/url_manager.dart';

class StoreItem extends StatefulWidget {
  final String itemId;
  final ItemType itemType;
  final double? basePrice, discountedPrice, discountPercent;
  const StoreItem({
    Key? key,
    required this.itemId,
    this.itemType = ItemType.weapon,
    this.basePrice,
    this.discountedPrice,
    this.discountPercent,
  }) : super(key: key);

  @override
  State<StoreItem> createState() => _StoreItemState();
}

class _StoreItemState extends State<StoreItem> {
  late String type;
  Future<dynamic> getItemDetails() async {
    switch (widget.itemType) {
      case ItemType.buddy:
        type = '/buddies/levels/';
        break;
      case ItemType.playercard:
        type = '/playercards/';
        break;
      case ItemType.spray:
        type = '/sprays/';
        break;
      case ItemType.weapon:
        type = '/weapons/skinlevels/';
        break;
      default:
        type = '';
    }
    var response =
        Dio().get('${UrlManager.getContentBaseUrl}$type${widget.itemId}');
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getItemDetails(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            var response = snapshot.data.data['data'];
            return GestureDetector(
              child: Container(
                height: 200.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.grey,
                          blurRadius: 2.0,
                          offset: Offset(0, 1),
                          spreadRadius: 1),
                    ]),
                margin: const EdgeInsets.all(5.0),
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        response['displayIcon'],
                      ),
                    ),
                    Text(
                      response['displayName'],
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetailsScreen(
                      itemId: widget.itemId,
                      itemType: widget.itemType,
                      displayName: response['displayName'],
                      displayIcon: response['displayIcon'],
                      streamedVideo: response['streamedVideo'] ?? '',
                      basePrice: widget.basePrice,
                      discountedPrice: widget.discountedPrice,
                      discountPercent: widget.discountPercent,
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Container();
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
