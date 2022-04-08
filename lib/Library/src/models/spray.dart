import 'dart:convert';

import 'package:valorant_companion/Library/valorant_client.dart';

class Spray extends ISerializable<Spray> {
  Spray({
    this.sprayList = const [],
  });

  final List<SprayItem> sprayList;

  factory Spray.fromJson(String str) => Spray.fromMap(json.decode(str));

  @override
  Map<String, dynamic> toJson() => toMap();

  factory Spray.fromMap(Map<String, dynamic> json) => Spray(
        sprayList: List<SprayItem>.from(
            json['data'].map((x) => SprayItem.fromJson(x)),
            growable: false),
      );

  Map<String, dynamic> toMap() =>
      {"Spray": sprayList.map((x) => x.toJson()).toList()};

  @override
  Spray fromJson(Map<String, dynamic> json) => Spray.fromMap(json);

  SprayItem? getSprayFromId(String id) {
    for (SprayItem item in sprayList) {
      if (item.uuid == id) {
        return item;
      }
    }
    return null;
  }
}

class SprayItem {
  String? uuid;
  String? displayName;
  String? displayIcon;
  String? fullIcon;
  String? fullTransparentIcon;
  String? animationPng;
  String? animationGif;

  SprayItem(
      {this.uuid,
      this.displayName,
      this.displayIcon,
      this.fullIcon,
      this.fullTransparentIcon,
      this.animationPng,
      this.animationGif});

  SprayItem.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    displayName = json['displayName'];
    displayIcon = json['displayIcon'];
    fullIcon = json['fullIcon'];
    fullTransparentIcon = json['fullTransparentIcon'];
    animationPng = json['animationPng'];
    animationGif = json['animationGif'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['displayName'] = displayName;
    data['displayIcon'] = displayIcon;
    data['fullIcon'] = fullIcon;
    data['fullTransparentIcon'] = fullTransparentIcon;
    data['animationPng'] = animationPng;
    data['animationGif'] = animationGif;
    return data;
  }
}
