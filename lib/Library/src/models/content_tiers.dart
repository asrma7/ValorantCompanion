import 'dart:convert';
import 'package:valorant_companion/Library/valorant_client.dart';

class ContentTiers extends ISerializable<ContentTiers> {
  ContentTiers({
    this.contentTierList = const [],
  });

  final List<ContentTier> contentTierList;

  factory ContentTiers.fromJson(String str) =>
      ContentTiers.fromMap(json.decode(str));

  @override
  Map<String, dynamic> toJson() => toMap();

  factory ContentTiers.fromMap(Map<String, dynamic> json) => ContentTiers(
        contentTierList: List<ContentTier>.from(
            json['data'].map((x) => ContentTier.fromJson(x)),
            growable: false),
      );

  Map<String, dynamic> toMap() =>
      {"ContentTiers": contentTierList.map((x) => x.toJson()).toList()};

  @override
  ContentTiers fromJson(Map<String, dynamic> json) =>
      ContentTiers.fromMap(json);

  ContentTier? getPlayerTitleFromId(String id) {
    for (ContentTier item in contentTierList) {
      if (item.uuid == id) {
        return item;
      }
    }
    return null;
  }
}

class ContentTier {
  String? uuid;
  String? devName;
  int? rank;
  int? juiceValue;
  int? juiceCost;
  String? highlightColor;
  String? displayIcon;
  String? assetPath;

  ContentTier(
      {this.uuid,
      this.devName,
      this.rank,
      this.juiceValue,
      this.juiceCost,
      this.highlightColor,
      this.displayIcon,
      this.assetPath});

  ContentTier.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    devName = json['devName'];
    rank = json['rank'];
    juiceValue = json['juiceValue'];
    juiceCost = json['juiceCost'];
    highlightColor = json['highlightColor'];
    displayIcon = json['displayIcon'];
    assetPath = json['assetPath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['devName'] = devName;
    data['rank'] = rank;
    data['juiceValue'] = juiceValue;
    data['juiceCost'] = juiceCost;
    data['highlightColor'] = highlightColor;
    data['displayIcon'] = displayIcon;
    data['assetPath'] = assetPath;
    return data;
  }
}
