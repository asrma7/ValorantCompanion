import 'dart:convert';

import 'package:valorant_companion/Library/valorant_client.dart';

class Buddies extends ISerializable<Buddies> {
  Buddies({
    this.buddyList = const [],
  });

  final List<Buddy> buddyList;

  factory Buddies.fromJson(String str) => Buddies.fromMap(json.decode(str));

  @override
  Map<String, dynamic> toJson() => toMap();

  factory Buddies.fromMap(Map<String, dynamic> json) => Buddies(
        buddyList: List<Buddy>.from(json['data'].map((x) => Buddy.fromJson(x)),
            growable: false),
      );

  Map<String, dynamic> toMap() =>
      {"Buddies": buddyList.map((x) => x.toJson()).toList()};

  @override
  Buddies fromJson(Map<String, dynamic> json) => Buddies.fromMap(json);

  Buddy? getBuddyFromId(String id) {
    for (Buddy item in buddyList) {
      if (item.uuid == id) {
        return item;
      }
    }
    return null;
  }
}

class Buddy {
  String? uuid;
  String? displayName;
  bool? isHiddenIfNotOwned;
  String? themeUuid;
  String? displayIcon;
  List<Levels>? levels;

  Buddy(
      {this.uuid,
      this.displayName,
      this.isHiddenIfNotOwned,
      this.themeUuid,
      this.displayIcon,
      this.levels});

  Buddy.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    displayName = json['displayName'];
    isHiddenIfNotOwned = json['isHiddenIfNotOwned'];
    themeUuid = json['themeUuid'];
    displayIcon = json['displayIcon'];
    if (json['levels'] != null) {
      levels = <Levels>[];
      json['levels'].forEach((v) {
        levels!.add(Levels.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['displayName'] = displayName;
    data['isHiddenIfNotOwned'] = isHiddenIfNotOwned;
    data['themeUuid'] = themeUuid;
    data['displayIcon'] = displayIcon;
    if (levels != null) {
      data['levels'] = levels!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Levels {
  String? uuid;
  int? charmLevel;
  String? displayName;
  String? displayIcon;

  Levels({this.uuid, this.charmLevel, this.displayName, this.displayIcon});

  Levels.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    charmLevel = json['charmLevel'];
    displayName = json['displayName'];
    displayIcon = json['displayIcon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['charmLevel'] = charmLevel;
    data['displayName'] = displayName;
    data['displayIcon'] = displayIcon;
    return data;
  }
}
