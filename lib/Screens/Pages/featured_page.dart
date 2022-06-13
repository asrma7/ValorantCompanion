import 'package:flutter/material.dart';
import 'package:valorant_companion/Components/store_item.dart';
import 'package:valorant_companion/Library/src/interfaces/asset.dart';
import 'package:valorant_companion/Library/src/interfaces/player.dart';
import 'package:valorant_companion/Library/src/models/buddies.dart';
import 'package:valorant_companion/Library/src/models/playercard.dart';
import 'package:valorant_companion/Library/src/models/playertitle.dart';
import 'package:valorant_companion/Library/src/models/spray.dart';
import '../../Library/src/models/weapons.dart';
import '/Components/timer.dart';
import '/Library/valorant_client.dart';
import '/Library/src/models/storefront.dart';

import '/Utils/database_helper.dart';

class FeaturedPage extends StatefulWidget {
  final String title;
  const FeaturedPage({Key? key, required this.title}) : super(key: key);

  @override
  State<FeaturedPage> createState() => _FeaturedPageState();
}

class _FeaturedPageState extends State<FeaturedPage> {
  final dbHelper = DatabaseHelper.instance;
  AssetInterface assetInterface = AssetInterface();
  PlayerInterface playerInterface = PlayerInterface();

  Map<String, dynamic>? user;

  Future<bool> _loadUserData() async {
    await dbHelper.queryActiveUser().then((value) {
      setState(() {
        user = value;
      });
    });
    return true;
  }

  Future? getStoreOffers() async {
    if (user == null) {
      await _loadUserData();
    }
    Storefront? storeFront = await playerInterface.getStorefront();
    var futures = <Future>[
      assetInterface.getAssets<Skins>(
          typeResolver: Skins(), assetType: 'weapons/skins'),
      assetInterface.getAssets<Spray>(
          typeResolver: Spray(), assetType: 'sprays'),
      assetInterface.getAssets<PlayerCards>(
          typeResolver: PlayerCards(), assetType: 'playercards'),
      assetInterface.getAssets<PlayerTitles>(
          typeResolver: PlayerTitles(), assetType: 'playertitles'),
      assetInterface.getAssets<Buddies>(
          typeResolver: Buddies(), assetType: 'buddies'),
    ];
    List resources = await Future.wait(futures);
    return {
      'skins': resources[0],
      'sprays': resources[1],
      'playercards': resources[2],
      'playertitles': resources[3],
      'buddies': resources[4],
      'storefront': storeFront,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: getStoreOffers(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            Skins skinList = snapshot.data['skins'];
            Spray sprayList = snapshot.data['sprays'];
            PlayerCards playerCardList = snapshot.data['playercards'];
            PlayerTitles playerTitleList = snapshot.data['playertitles'];
            Buddies buddyList = snapshot.data['buddies'];
            var response = snapshot.data['storefront'];
            List<ItemElement> items = response.featuredBundle.bundle.items;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: TimerComponent(
                      time: response
                          .featuredBundle.bundleRemainingDurationInSeconds,
                    ),
                  ),
                ),
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      ItemElement item = items[index];
                      String? itemId = item.item?.itemId;
                      String? itemTypeId = item.item?.itemTypeId;
                      String? displayIcon,
                          displayName,
                          streamedVideo,
                          titleText;
                      ItemType itemType =
                          ItemTypeConstants.getItemTypeFromId(itemTypeId!);
                      switch (itemType) {
                        case ItemType.weapon:
                          displayName = skinList.skinList
                              .singleWhere((element) =>
                                  element.levels!.first.uuid == itemId)
                              .displayName!;
                          displayIcon = skinList.skinList
                              .singleWhere((element) =>
                                  element.levels!.first.uuid == itemId)
                              .levels!
                              .first
                              .displayIcon;
                          streamedVideo = skinList.skinList
                              .singleWhere((element) =>
                                  element.levels!.first.uuid == itemId)
                              .levels!
                              .last
                              .streamedVideo;
                          break;
                        case ItemType.buddy:
                          displayName = buddyList.buddyList
                              .singleWhere((element) =>
                                  element.levels!.first.uuid == itemId)
                              .displayName!;
                          displayIcon = buddyList.buddyList
                              .singleWhere((element) =>
                                  element.levels!.first.uuid == itemId)
                              .displayIcon;
                          break;
                        case ItemType.playercard:
                          displayName = playerCardList.playerCardList
                              .singleWhere((element) => element.uuid == itemId)
                              .displayName!;
                          displayIcon = playerCardList.playerCardList
                              .singleWhere((element) => element.uuid == itemId)
                              .displayIcon;
                          break;
                        case ItemType.spray:
                          displayName = sprayList.sprayList
                              .singleWhere((element) => element.uuid == itemId)
                              .displayName!;
                          displayIcon = sprayList.sprayList
                              .singleWhere((element) => element.uuid == itemId)
                              .displayIcon;
                          break;
                        case ItemType.title:
                          displayName = playerTitleList.playerTitleList
                              .singleWhere((element) => element.uuid == itemId)
                              .displayName!;
                          titleText = playerTitleList.playerTitleList
                              .singleWhere((element) => element.uuid == itemId)
                              .titleText;
                          break;
                        case ItemType.unknown:
                          return Container();
                      }
                      return StoreItem(
                        storeType: StoreType.featured,
                        itemId: itemId!,
                        itemType: itemType,
                        basePrice: item.basePrice,
                        discountedPrice: item.discountedPrice,
                        discountPercent: item.discountPercent,
                        displayIcon: displayIcon,
                        displayName: displayName,
                        streamedVideo: streamedVideo,
                        titleText: titleText,
                      );
                    },
                    childCount: items.length,
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Container();
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
