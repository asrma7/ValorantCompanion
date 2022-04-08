import 'dart:convert';

import 'package:valorant_companion/Library/valorant_client.dart';

class PlayerTitles extends ISerializable<PlayerTitles> {
  PlayerTitles({
    this.playerTitleList = const [],
  });

  final List<PlayerTitle> playerTitleList;

  factory PlayerTitles.fromJson(String str) =>
      PlayerTitles.fromMap(json.decode(str));

  @override
  Map<String, dynamic> toJson() => toMap();

  factory PlayerTitles.fromMap(Map<String, dynamic> json) => PlayerTitles(
        playerTitleList: List<PlayerTitle>.from(
            json['data'].map((x) => PlayerTitle.fromJson(x)),
            growable: false),
      );

  Map<String, dynamic> toMap() =>
      {"Titles": playerTitleList.map((x) => x.toJson()).toList()};

  @override
  PlayerTitles fromJson(Map<String, dynamic> json) =>
      PlayerTitles.fromMap(json);

  PlayerTitle? getPlayerTitleFromId(String id) {
    for (PlayerTitle item in playerTitleList) {
      if (item.uuid == id) {
        return item;
      }
    }
    return null;
  }
}

class PlayerTitle {
  String? uuid;
  String? displayName;
  String? titleText;
  bool? isHiddenIfNotOwned;

  PlayerTitle(
      {this.uuid, this.displayName, this.titleText, this.isHiddenIfNotOwned});

  PlayerTitle.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    displayName = json['displayName'];
    titleText = json['titleText'];
    isHiddenIfNotOwned = json['isHiddenIfNotOwned'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['displayName'] = displayName;
    data['titleText'] = titleText;
    data['isHiddenIfNotOwned'] = isHiddenIfNotOwned;
    return data;
  }
}
