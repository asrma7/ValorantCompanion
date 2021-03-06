import 'dart:convert';

import 'serializable.dart';

class Storefront extends ISerializable<Storefront> {
  Storefront({
    this.featuredTheme,
    this.featuredBundle,
    this.skinsPanelLayout,
    this.bonusStore,
  });

  final FeaturedTheme? featuredTheme;
  final FeaturedBundle? featuredBundle;
  final SkinsPanelLayout? skinsPanelLayout;
  final BonusStore? bonusStore;

  factory Storefront.fromJson(String str) =>
      Storefront.fromMap(json.decode(str));

  @override
  Map<String, dynamic> toJson() => toMap();

  factory Storefront.fromMap(Map<String, dynamic> json) => Storefront(
        featuredTheme: json["FeaturedTheme"] == null
            ? null
            : FeaturedTheme.fromMap(json["FeaturedTheme"]),
        featuredBundle: json["FeaturedBundle"] == null
            ? null
            : FeaturedBundle.fromMap(json["FeaturedBundle"]),
        skinsPanelLayout: json["SkinsPanelLayout"] == null
            ? null
            : SkinsPanelLayout.fromMap(json["SkinsPanelLayout"]),
        bonusStore: json['BonusStore'] != null
            ? BonusStore.fromMap(json['BonusStore'])
            : null,
      );

  Map<String, dynamic> toMap() => {
        "FeaturedTheme": featuredTheme?.toMap(),
        "FeaturedBundle": featuredBundle?.toMap(),
        "SkinsPanelLayout": skinsPanelLayout?.toMap(),
        "BonusStore": bonusStore?.toMap(),
      };

  @override
  Storefront fromJson(Map<String, dynamic> json) => Storefront.fromMap(json);
}

class FeaturedBundle {
  FeaturedBundle({
    this.bundle,
    this.bundleRemainingDurationInSeconds = 0,
  });

  final FeaturedTheme? bundle;
  final int bundleRemainingDurationInSeconds;

  factory FeaturedBundle.fromJson(String str) =>
      FeaturedBundle.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory FeaturedBundle.fromMap(Map<String, dynamic> json) => FeaturedBundle(
        bundle: json["Bundle"] == null
            ? null
            : FeaturedTheme.fromMap(json["Bundle"]),
        bundleRemainingDurationInSeconds:
            json["BundleRemainingDurationInSeconds"] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        "Bundle": bundle?.toMap(),
        "BundleRemainingDurationInSeconds": bundleRemainingDurationInSeconds,
      };
}

class FeaturedTheme {
  FeaturedTheme({
    this.id,
    this.dataAssetId,
    this.currencyId,
    this.items = const [],
  });

  final String? id;
  final String? dataAssetId;
  final String? currencyId;
  final List<ItemElement> items;

  factory FeaturedTheme.fromJson(String str) =>
      FeaturedTheme.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory FeaturedTheme.fromMap(Map<String, dynamic> json) => FeaturedTheme(
        id: json["ID"],
        dataAssetId: json["DataAssetID"],
        currencyId: json["CurrencyID"],
        items: json["Items"] == null
            ? []
            : List<ItemElement>.from(
                json["Items"].map((x) => ItemElement.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "ID": id,
        "DataAssetID": dataAssetId,
        "CurrencyID": currencyId,
        "Items": List<dynamic>.from(items.map((x) => x.toMap())),
      };
}

class ItemElement {
  ItemElement({
    this.item,
    this.basePrice = 0.0,
    this.currencyId,
    this.discountPercent = 0.0,
    this.discountedPrice = 0.0,
    this.isPromoItem = false,
  });

  final Item? item;
  final double basePrice;
  final String? currencyId;
  final double discountPercent;
  final double discountedPrice;
  final bool isPromoItem;

  factory ItemElement.fromJson(String str) =>
      ItemElement.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ItemElement.fromMap(Map<String, dynamic> json) => ItemElement(
        item: json["Item"] == null ? null : Item.fromMap(json["Item"]),
        basePrice: json["BasePrice"] != null
            ? json["BasePrice"] is double
                ? json["BasePrice"]
                : (json["BasePrice"] as int).toDouble()
            : 0.0,
        currencyId: json["CurrencyID"],
        discountPercent: json["DiscountPercent"] != null
            ? json["DiscountPercent"] is double
                ? json["DiscountPercent"]
                : (json["DiscountPercent"] as int).toDouble()
            : 0.0,
        isPromoItem: json["IsPromoItem"] ?? false,
      );

  Map<String, dynamic> toMap() => {
        "Item": item?.toMap(),
        "BasePrice": basePrice,
        "CurrencyID": currencyId,
        "DiscountPercent": discountPercent,
        "IsPromoItem": isPromoItem,
      };
}

class Item {
  Item({
    this.itemTypeId,
    this.itemId,
    this.amount = 0.0,
  });

  final String? itemTypeId;
  final String? itemId;
  final double amount;

  factory Item.fromJson(String str) => Item.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Item.fromMap(Map<String, dynamic> json) => Item(
        itemTypeId: json["ItemTypeID"],
        itemId: json["ItemID"],
        amount: json["Amount"] != null
            ? json["Amount"] is double
                ? json["Amount"]
                : (json["Amount"] as int).toDouble()
            : 0.0,
      );

  Map<String, dynamic> toMap() => {
        "ItemTypeID": itemTypeId,
        "ItemID": itemId,
        "Amount": amount,
      };
}

class SkinsPanelLayout {
  SkinsPanelLayout({
    this.singleItemOffers = const [],
    this.singleItemOffersRemainingDurationInSeconds = 0,
  });

  final List<String> singleItemOffers;
  final int singleItemOffersRemainingDurationInSeconds;

  factory SkinsPanelLayout.fromJson(String str) =>
      SkinsPanelLayout.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SkinsPanelLayout.fromMap(Map<String, dynamic> json) =>
      SkinsPanelLayout(
        singleItemOffers:
            List<String>.from(json["SingleItemOffers"].map((x) => x)),
        singleItemOffersRemainingDurationInSeconds:
            json["SingleItemOffersRemainingDurationInSeconds"],
      );

  Map<String, dynamic> toMap() => {
        "SingleItemOffers": List<dynamic>.from(singleItemOffers.map((x) => x)),
        "SingleItemOffersRemainingDurationInSeconds":
            singleItemOffersRemainingDurationInSeconds,
      };
}

class BonusStore {
  List<BonusStoreOffers>? bonusStoreOffers;
  int? bonusStoreRemainingDurationInSeconds;

  BonusStore(
      {this.bonusStoreOffers, this.bonusStoreRemainingDurationInSeconds});

  factory BonusStore.fromMap(Map<String, dynamic> json) => BonusStore(
        bonusStoreOffers: List<BonusStoreOffers>.from(
            json['BonusStoreOffers'].map((x) => BonusStoreOffers.fromMap(x)),
            growable: false),
        bonusStoreRemainingDurationInSeconds:
            json["BonusStoreRemainingDurationInSeconds"] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        "BonusStoreOffers": bonusStoreOffers!.map((e) => e.toMap()).toList(),
        "BonusStoreRemainingDurationInSeconds":
            bonusStoreRemainingDurationInSeconds,
      };

  factory BonusStore.fromJson(String str) =>
      BonusStore.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());
}

class BonusStoreOffers {
  String? bonusOfferID;
  Offer? offer;
  double? discountPercent;
  Cost? discountCosts;
  bool? isSeen;

  BonusStoreOffers(
      {this.bonusOfferID,
      this.offer,
      this.discountPercent,
      this.discountCosts,
      this.isSeen});

  factory BonusStoreOffers.fromMap(Map<String, dynamic> json) =>
      BonusStoreOffers(
        bonusOfferID: json["BonusOfferID"],
        offer: json["Offer"] == null ? null : Offer.fromMap(json["Offer"]),
        discountPercent: json["DiscountPercent"].toDouble(),
        discountCosts: json["DiscountCosts"] == null
            ? null
            : Cost.fromMap(json["DiscountCosts"]),
        isSeen: json["IsSeen"] ?? false,
      );

  Map<String, dynamic> toMap() {
    return {
      "BonusOfferID": bonusOfferID,
      "Offer": offer?.toMap(),
      "DiscountPercent": discountPercent,
      "DiscountCosts": discountCosts?.toMap(),
      "IsSeen": isSeen,
    };
  }
}

class Offer {
  String? offerID;
  bool? isDirectPurchase;
  String? startDate;
  Cost? cost;
  List<Rewards>? rewards;

  Offer(
      {this.offerID,
      this.isDirectPurchase,
      this.startDate,
      this.cost,
      this.rewards});

  factory Offer.fromMap(Map<String, dynamic> json) => Offer(
        offerID: json["OfferID"],
        isDirectPurchase: json["IsDirectPurchase"],
        startDate: json["StartDate"],
        cost: json["Cost"] == null ? null : Cost.fromMap(json["Cost"]),
        rewards: List<Rewards>.from(
            json["Rewards"].map((x) => Rewards.fromMap(x)),
            growable: false),
      );

  Map<String, dynamic> toMap() {
    return {
      "OfferID": offerID,
      "IsDirectPurchase": isDirectPurchase,
      "StartDate": startDate,
      "Cost": cost?.toMap(),
      "Rewards": List<dynamic>.from(rewards!.map((x) => x.toMap())),
    };
  }
}

class Cost {
  double? valorantPoints;

  Cost({this.valorantPoints});

  factory Cost.fromMap(Map<String, dynamic> json) => Cost(
        valorantPoints: json["85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741"].toDouble(),
      );

  Map<String, dynamic> toMap() {
    return {
      "85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741": valorantPoints,
    };
  }
}

class Rewards {
  String? itemTypeID;
  String? itemID;
  int? quantity;

  Rewards({this.itemTypeID, this.itemID, this.quantity});

  factory Rewards.fromMap(Map<String, dynamic> json) => Rewards(
        itemTypeID: json["ItemTypeID"],
        itemID: json["ItemID"],
        quantity: json["Quantity"],
      );

  Map<String, dynamic> toMap() {
    return {
      "ItemTypeID": itemTypeID,
      "ItemID": itemID,
      "Quantity": quantity,
    };
  }
}
