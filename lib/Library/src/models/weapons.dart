import 'dart:convert';

import 'package:valorant_companion/Library/src/models/serializable.dart';

class Weapons extends ISerializable<Weapons> {
  Weapons({
    this.weaponList = const [],
  });

  final List<Weapon> weaponList;

  factory Weapons.fromJson(String str) => Weapons.fromMap(json.decode(str));

  @override
  Map<String, dynamic> toJson() => toMap();

  factory Weapons.fromMap(Map<String, dynamic> json) => Weapons(
        weaponList: List<Weapon>.from(
            json['data'].map((x) => Weapon.fromJson(x)),
            growable: false),
      );

  Map<String, dynamic> toMap() =>
      {"Weapons": weaponList.map((x) => x.toJson()).toList()};

  @override
  Weapons fromJson(Map<String, dynamic> json) => Weapons.fromMap(json);

  Weapon? getWeaponFromId(String id) {
    for (var weapon in weaponList) {
      if (weapon.uuid == id) {
        return weapon;
      }
    }
    return null;
  }
}

class Weapon {
  String? uuid;
  String? displayName;
  String? category;
  String? defaultSkinUuid;
  String? displayIcon;
  WeaponStats? weaponStats;
  List<Skin>? skins;

  Weapon(
      {this.uuid,
      this.displayName,
      this.category,
      this.defaultSkinUuid,
      this.displayIcon,
      this.weaponStats,
      this.skins});

  Weapon.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    displayName = json['displayName'];
    category = json['category'];
    defaultSkinUuid = json['defaultSkinUuid'];
    displayIcon = json['displayIcon'];
    weaponStats = json['weaponStats'] != null
        ? WeaponStats.fromJson(json['weaponStats'])
        : null;
    if (json['skins'] != null) {
      skins = <Skin>[];
      json['skins'].forEach((v) {
        skins!.add(Skin.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['displayName'] = displayName;
    data['category'] = category;
    data['defaultSkinUuid'] = defaultSkinUuid;
    data['displayIcon'] = displayIcon;
    if (weaponStats != null) {
      data['weaponStats'] = weaponStats!.toJson();
    }
    if (skins != null) {
      data['skins'] = skins!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  Skin? getSkinFromId(String id) {
    if (skins != null) {
      for (var skin in skins!) {
        if (skin.uuid == id) {
          return skin;
        }
      }
    }
    return null;
  }
}

class WeaponStats {
  double? fireRate;
  int? magazineSize;
  double? runSpeedMultiplier;
  double? equipTimeSeconds;
  double? reloadTimeSeconds;
  double? firstBulletAccuracy;
  int? shotgunPelletCount;
  String? wallPenetration;
  String? feature;
  String? fireMode;
  String? altFireType;
  AdsStats? adsStats;
  AltShotgunStats? altShotgunStats;
  AirBurstStats? airBurstStats;
  List<DamageRanges>? damageRanges;

  WeaponStats(
      {this.fireRate,
      this.magazineSize,
      this.runSpeedMultiplier,
      this.equipTimeSeconds,
      this.reloadTimeSeconds,
      this.firstBulletAccuracy,
      this.shotgunPelletCount,
      this.wallPenetration,
      this.feature,
      this.fireMode,
      this.altFireType,
      this.adsStats,
      this.altShotgunStats,
      this.airBurstStats,
      this.damageRanges});

  WeaponStats.fromJson(Map<String, dynamic> json) {
    fireRate = json['fireRate'].toDouble();
    magazineSize = json['magazineSize'];
    runSpeedMultiplier = json['runSpeedMultiplier'];
    equipTimeSeconds = json['equipTimeSeconds'].toDouble();
    reloadTimeSeconds = json['reloadTimeSeconds'].toDouble();
    firstBulletAccuracy = json['firstBulletAccuracy'].toDouble();
    shotgunPelletCount = json['shotgunPelletCount'];
    wallPenetration = json['wallPenetration'];
    feature = json['feature'];
    fireMode = json['fireMode'];
    altFireType = json['altFireType'];
    adsStats =
        json['adsStats'] != null ? AdsStats.fromJson(json['adsStats']) : null;
    altShotgunStats = json['altShotgunStats'] != null
        ? AltShotgunStats.fromJson(json['altShotgunStats'])
        : null;
    airBurstStats = json['airBurstStats'] != null
        ? AirBurstStats.fromJson(json['airBurstStats'])
        : null;
    if (json['damageRanges'] != null) {
      damageRanges = <DamageRanges>[];
      json['damageRanges'].forEach((v) {
        damageRanges!.add(DamageRanges.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fireRate'] = fireRate;
    data['magazineSize'] = magazineSize;
    data['runSpeedMultiplier'] = runSpeedMultiplier;
    data['equipTimeSeconds'] = equipTimeSeconds;
    data['reloadTimeSeconds'] = reloadTimeSeconds;
    data['firstBulletAccuracy'] = firstBulletAccuracy;
    data['shotgunPelletCount'] = shotgunPelletCount;
    data['wallPenetration'] = wallPenetration;
    data['feature'] = feature;
    data['fireMode'] = fireMode;
    data['altFireType'] = altFireType;
    if (adsStats != null) {
      data['adsStats'] = adsStats!.toJson();
    }
    if (altShotgunStats != null) {
      data['altShotgunStats'] = altShotgunStats!.toJson();
    }
    if (airBurstStats != null) {
      data['airBurstStats'] = airBurstStats!.toJson();
    }
    if (damageRanges != null) {
      data['damageRanges'] = damageRanges!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AdsStats {
  double? zoomMultiplier;
  double? fireRate;
  double? runSpeedMultiplier;
  int? burstCount;
  double? firstBulletAccuracy;

  AdsStats(
      {this.zoomMultiplier,
      this.fireRate,
      this.runSpeedMultiplier,
      this.burstCount,
      this.firstBulletAccuracy});

  AdsStats.fromJson(Map<String, dynamic> json) {
    zoomMultiplier = json['zoomMultiplier'].toDouble();
    fireRate = json['fireRate'].toDouble();
    runSpeedMultiplier = json['runSpeedMultiplier'].toDouble();
    burstCount = json['burstCount'];
    firstBulletAccuracy = json['firstBulletAccuracy'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['zoomMultiplier'] = zoomMultiplier;
    data['fireRate'] = fireRate;
    data['runSpeedMultiplier'] = runSpeedMultiplier;
    data['burstCount'] = burstCount;
    data['firstBulletAccuracy'] = firstBulletAccuracy;
    return data;
  }
}

class AltShotgunStats {
  int? shotgunPelletCount;
  double? burstRate;

  AltShotgunStats({this.shotgunPelletCount, this.burstRate});

  AltShotgunStats.fromJson(Map<String, dynamic> json) {
    shotgunPelletCount = json['shotgunPelletCount'];
    burstRate = json['burstRate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['shotgunPelletCount'] = shotgunPelletCount;
    data['burstRate'] = burstRate;
    return data;
  }
}

class AirBurstStats {
  int? shotgunPelletCount;
  double? burstDistance;

  AirBurstStats({this.shotgunPelletCount, this.burstDistance});

  AirBurstStats.fromJson(Map<String, dynamic> json) {
    shotgunPelletCount = json['shotgunPelletCount'];
    burstDistance = json['burstDistance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['shotgunPelletCount'] = shotgunPelletCount;
    data['burstDistance'] = burstDistance;
    return data;
  }
}

class DamageRanges {
  int? rangeStartMeters;
  int? rangeEndMeters;
  double? headDamage;
  double? bodyDamage;
  double? legDamage;

  DamageRanges(
      {this.rangeStartMeters,
      this.rangeEndMeters,
      this.headDamage,
      this.bodyDamage,
      this.legDamage});

  DamageRanges.fromJson(Map<String, dynamic> json) {
    rangeStartMeters = json['rangeStartMeters'];
    rangeEndMeters = json['rangeEndMeters'];
    headDamage = json['headDamage'].toDouble();
    bodyDamage = json['bodyDamage'].toDouble();
    legDamage = json['legDamage'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rangeStartMeters'] = rangeStartMeters;
    data['rangeEndMeters'] = rangeEndMeters;
    data['headDamage'] = headDamage;
    data['bodyDamage'] = bodyDamage;
    data['legDamage'] = legDamage;
    return data;
  }
}

class Skins extends ISerializable<Skins> {
  Skins({
    this.skinList = const [],
  });

  final List<Skin> skinList;

  factory Skins.fromJson(String str) => Skins.fromMap(json.decode(str));

  @override
  Map<String, dynamic> toJson() => toMap();

  factory Skins.fromMap(Map<String, dynamic> json) => Skins(
        skinList: List<Skin>.from(json['data'].map((x) => Skin.fromJson(x)),
            growable: false),
      );

  Map<String, dynamic> toMap() =>
      {"Skins": skinList.map((x) => x.toJson()).toList()};

  @override
  Skins fromJson(Map<String, dynamic> json) => Skins.fromMap(json);

  Skin? getSkinFromId(String id) {
    for (var skin in skinList) {
      if (skin.uuid == id) {
        return skin;
      }
    }
    return null;
  }
}

class Skin {
  String? uuid;
  String? displayName;
  String? themeUuid;
  String? contentTierUuid;
  String? displayIcon;
  List<Chromas>? chromas;
  List<Levels>? levels;

  Skin(
      {this.uuid,
      this.displayName,
      this.themeUuid,
      this.contentTierUuid,
      this.displayIcon,
      this.chromas,
      this.levels});

  Skin.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    displayName = json['displayName'];
    themeUuid = json['themeUuid'];
    contentTierUuid = json['contentTierUuid'];
    displayIcon = json['displayIcon'];
    if (json['chromas'] != null) {
      chromas = <Chromas>[];
      json['chromas'].forEach((v) {
        chromas!.add(Chromas.fromJson(v));
      });
    }
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
    data['themeUuid'] = themeUuid;
    data['contentTierUuid'] = contentTierUuid;
    data['displayIcon'] = displayIcon;
    if (chromas != null) {
      data['chromas'] = chromas!.map((v) => v.toJson()).toList();
    }
    if (levels != null) {
      data['levels'] = levels!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  Chromas? getChromaFromId(String uuid) {
    if (chromas != null) {
      for (final chroma in chromas!) {
        if (chroma.uuid == uuid) {
          return chroma;
        }
      }
    }
    return null;
  }
}

class Chromas {
  String? uuid;
  String? displayName;
  String? displayIcon;
  String? fullRender;
  String? swatch;
  String? streamedVideo;

  Chromas(
      {this.uuid,
      this.displayName,
      this.displayIcon,
      this.fullRender,
      this.swatch,
      this.streamedVideo});

  Chromas.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    displayName = json['displayName'];
    displayIcon = json['displayIcon'];
    fullRender = json['fullRender'];
    swatch = json['swatch'];
    streamedVideo = json['streamedVideo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['displayName'] = displayName;
    data['displayIcon'] = displayIcon;
    data['fullRender'] = fullRender;
    data['swatch'] = swatch;
    data['streamedVideo'] = streamedVideo;
    return data;
  }
}

class Levels {
  String? uuid;
  String? displayName;
  String? levelItem;
  String? displayIcon;
  String? streamedVideo;

  Levels(
      {this.uuid,
      this.displayName,
      this.levelItem,
      this.displayIcon,
      this.streamedVideo});

  Levels.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    displayName = json['displayName'];
    levelItem = json['levelItem'];
    displayIcon = json['displayIcon'];
    streamedVideo = json['streamedVideo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['displayName'] = displayName;
    data['levelItem'] = levelItem;
    data['displayIcon'] = displayIcon;
    data['streamedVideo'] = streamedVideo;
    return data;
  }
}
