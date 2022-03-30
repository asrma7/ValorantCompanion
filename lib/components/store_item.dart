import 'package:flutter/material.dart';
import 'package:valorant_companion/Library/valorant_client.dart';
import 'package:valorant_companion/Screens/Pages/item_details_page.dart';

import '../Library/src/models/content_tiers.dart';

class StoreItem extends StatefulWidget {
  final String itemId;
  final String? displayName, displayIcon, streamedVideo, titleText;
  final ContentTier? contentTier;
  final ItemType itemType;
  final double? basePrice, discountedPrice, discountPercent;
  const StoreItem({
    Key? key,
    required this.itemId,
    this.itemType = ItemType.weapon,
    this.displayIcon,
    this.displayName,
    this.streamedVideo,
    this.contentTier,
    this.basePrice,
    this.discountedPrice,
    this.discountPercent,
    this.titleText,
  }) : super(key: key);

  @override
  State<StoreItem> createState() => _StoreItemState();
}

class _StoreItemState extends State<StoreItem> {
  late String type;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 200.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: widget.contentTier != null
                ? HexColor.fromHex(widget.contentTier!.highlightColor!,
                    endOpacity: true)
                : Colors.white,
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
            widget.contentTier != null
                ? Image.network(
                    widget.contentTier!.displayIcon!,
                    height: 50.0,
                  )
                : Container(),
            Expanded(
              child: Image.network(
                widget.displayIcon!,
              ),
            ),
            Text(
              widget.displayName!,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailsPage(
              itemId: widget.itemId,
              itemType: widget.itemType,
              displayName: widget.displayName!,
              displayIcon: widget.displayIcon,
              titleText: widget.titleText,
              streamedVideo: widget.streamedVideo ?? '',
              basePrice: widget.basePrice,
              discountedPrice: widget.discountedPrice,
              discountPercent: widget.discountPercent,
            ),
          ),
        );
      },
    );
  }
}
