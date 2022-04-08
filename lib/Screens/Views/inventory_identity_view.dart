import 'package:flutter/material.dart';
import 'package:valorant_companion/Library/src/models/playertitle.dart';
import '../../Library/src/models/playercard.dart';

class InventoryIdentityView extends StatelessWidget {
  final PlayerCard playerCard;
  final PlayerTitle playerTitle;
  const InventoryIdentityView(
      {Key? key, required this.playerCard, required this.playerTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(playerCard.largeArt!),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        alignment: Alignment.center,
        width: double.maxFinite,
        height: 25.0,
        color: Colors.black38,
        child: Text(
          playerTitle.titleText!,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
