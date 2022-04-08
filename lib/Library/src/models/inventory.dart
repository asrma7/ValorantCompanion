class Inventory {
  String? subject;
  int? version;
  List<Guns>? guns;
  List<Sprays>? sprays;
  Identity? identity;
  bool? incognito;

  Inventory(
      {this.subject,
      this.version,
      this.guns,
      this.sprays,
      this.identity,
      this.incognito});

  Inventory.fromJson(Map<String, dynamic> json) {
    subject = json['Subject'];
    version = json['Version'];
    if (json['Guns'] != null) {
      guns = <Guns>[];
      json['Guns'].forEach((v) {
        guns!.add(Guns.fromJson(v));
      });
    }
    if (json['Sprays'] != null) {
      sprays = <Sprays>[];
      json['Sprays'].forEach((v) {
        sprays!.add(Sprays.fromJson(v));
      });
    }
    identity =
        json['Identity'] != null ? Identity.fromJson(json['Identity']) : null;
    incognito = json['Incognito'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Subject'] = subject;
    data['Version'] = version;
    if (guns != null) {
      data['Guns'] = guns!.map((v) => v.toJson()).toList();
    }
    if (sprays != null) {
      data['Sprays'] = sprays!.map((v) => v.toJson()).toList();
    }
    if (identity != null) {
      data['Identity'] = identity!.toJson();
    }
    data['Incognito'] = incognito;
    return data;
  }
}

class Guns {
  String? iD;
  String? skinID;
  String? skinLevelID;
  String? chromaID;
  String? charmInstanceID;
  String? charmID;
  String? charmLevelID;

  Guns(
      {this.iD,
      this.skinID,
      this.skinLevelID,
      this.chromaID,
      this.charmInstanceID,
      this.charmID,
      this.charmLevelID});

  Guns.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    skinID = json['SkinID'];
    skinLevelID = json['SkinLevelID'];
    chromaID = json['ChromaID'];
    charmInstanceID = json['CharmInstanceID'];
    charmID = json['CharmID'];
    charmLevelID = json['CharmLevelID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ID'] = iD;
    data['SkinID'] = skinID;
    data['SkinLevelID'] = skinLevelID;
    data['ChromaID'] = chromaID;
    data['CharmInstanceID'] = charmInstanceID;
    data['CharmID'] = charmID;
    data['CharmLevelID'] = charmLevelID;
    return data;
  }
}

class Sprays {
  String? equipSlotID;
  String? sprayID;
  String? sprayLevelID;

  Sprays({this.equipSlotID, this.sprayID, this.sprayLevelID});

  Sprays.fromJson(Map<String, dynamic> json) {
    equipSlotID = json['EquipSlotID'];
    sprayID = json['SprayID'];
    sprayLevelID = json['SprayLevelID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['EquipSlotID'] = equipSlotID;
    data['SprayID'] = sprayID;
    data['SprayLevelID'] = sprayLevelID;
    return data;
  }
}

class Identity {
  String? playerCardID;
  String? playerTitleID;
  int? accountLevel;
  String? preferredLevelBorderID;
  bool? hideAccountLevel;

  Identity(
      {this.playerCardID,
      this.playerTitleID,
      this.accountLevel,
      this.preferredLevelBorderID,
      this.hideAccountLevel});

  Identity.fromJson(Map<String, dynamic> json) {
    playerCardID = json['PlayerCardID'];
    playerTitleID = json['PlayerTitleID'];
    accountLevel = json['AccountLevel'];
    preferredLevelBorderID = json['PreferredLevelBorderID'];
    hideAccountLevel = json['HideAccountLevel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PlayerCardID'] = playerCardID;
    data['PlayerTitleID'] = playerTitleID;
    data['AccountLevel'] = accountLevel;
    data['PreferredLevelBorderID'] = preferredLevelBorderID;
    data['HideAccountLevel'] = hideAccountLevel;
    return data;
  }
}
