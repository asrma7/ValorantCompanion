import 'dart:convert';

import 'package:valorant_companion/Library/valorant_client.dart';

class PlayerCards extends ISerializable<PlayerCards> {
  PlayerCards({
    this.playerCardList = const [],
  });

  final List<PlayerCard> playerCardList;

  factory PlayerCards.fromJson(String str) =>
      PlayerCards.fromMap(json.decode(str));

  @override
  Map<String, dynamic> toJson() => toMap();

  factory PlayerCards.fromMap(Map<String, dynamic> json) => PlayerCards(
        playerCardList: List<PlayerCard>.from(
            json['data'].map((x) => PlayerCard.fromJson(x)),
            growable: false),
      );

  Map<String, dynamic> toMap() =>
      {"PlayerCards": playerCardList.map((x) => x.toJson()).toList()};

  @override
  PlayerCards fromJson(Map<String, dynamic> json) => PlayerCards.fromMap(json);

  PlayerCard? getPlayerCardFromId(String id) {
    for (PlayerCard item in playerCardList) {
      if (item.uuid == id) {
        return item;
      }
    }
    return null;
  }
}

class PlayerCard {
  String? uuid;
  String? displayName;
  bool? isHiddenIfNotOwned;
  String? themeUuid;
  String? displayIcon;
  String? smallArt;
  String? wideArt;
  String? largeArt;

  PlayerCard(
      {this.uuid,
      this.displayName,
      this.isHiddenIfNotOwned,
      this.themeUuid,
      this.displayIcon,
      this.smallArt,
      this.wideArt,
      this.largeArt});

  PlayerCard.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    displayName = json['displayName'];
    isHiddenIfNotOwned = json['isHiddenIfNotOwned'];
    themeUuid = json['themeUuid'];
    displayIcon = json['displayIcon'];
    smallArt = json['smallArt'];
    wideArt = json['wideArt'];
    largeArt = json['largeArt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['displayName'] = displayName;
    data['isHiddenIfNotOwned'] = isHiddenIfNotOwned;
    data['themeUuid'] = themeUuid;
    data['displayIcon'] = displayIcon;
    data['smallArt'] = smallArt;
    data['wideArt'] = wideArt;
    data['largeArt'] = largeArt;
    return data;
  }
}
