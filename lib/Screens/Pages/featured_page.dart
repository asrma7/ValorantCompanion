import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:valorant_companion/Components/store_item.dart';
import 'package:valorant_companion/Library/src/models/buddies.dart';
import 'package:valorant_companion/Library/src/models/playercard.dart';
import 'package:valorant_companion/Library/src/models/playertitle.dart';
import 'package:valorant_companion/Library/src/models/spray.dart';
import '../../Library/src/models/weapons.dart';
import '/Components/timer.dart';
import '/Library/valorant_client.dart';
import '/Library/src/models/storefront.dart';
import 'package:dio/dio.dart';

import '/Utils/database_helper.dart';
import '/Utils/helpers.dart';

class FeaturedPage extends StatefulWidget {
  final String title;
  const FeaturedPage({Key? key, required this.title}) : super(key: key);

  @override
  State<FeaturedPage> createState() => _FeaturedPageState();
}

class _FeaturedPageState extends State<FeaturedPage> {
  final dbHelper = DatabaseHelper.instance;

  Map<String, dynamic>? user;

  Future<bool> _loadUserData() async {
    await dbHelper.queryActiveUser().then((value) {
      setState(() {
        user = value[0];
      });
    });
    return true;
  }

  Future? getStoreOffers() async {
    if (user == null) {
      await _loadUserData();
    }
    ValorantClient client = ValorantClient(
      UserDetails(
        userName: user!['username'],
        password: user!['password'],
        region: stringToRegion(user!['region'])!,
      ),
      shouldPersistSession: false,
      callback: Callback(
        onError: (String error) {
          if (kDebugMode) {
            print(error);
          }
        },
        onRequestError: (DioError error) {
          if (kDebugMode) {
            print(error.message);
          }
        },
      ),
    );
    await client.init();
    var futures = <Future>[
      client.assetInterface
          .getAssets<Skins>(typeResolver: Skins(), assetType: 'weapons/skins'),
      client.assetInterface
          .getAssets<Spray>(typeResolver: Spray(), assetType: 'sprays'),
      client.assetInterface.getAssets<PlayerCards>(
          typeResolver: PlayerCards(), assetType: 'playercards'),
      client.assetInterface.getAssets<PlayerTitles>(
          typeResolver: PlayerTitles(), assetType: 'playertitles'),
      client.assetInterface
          .getAssets<Buddies>(typeResolver: Buddies(), assetType: 'buddies'),
      client.playerInterface.getStorefront(),
    ];
    return await Future.wait(futures);
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
            Skins skinList = snapshot.data[0];
            Spray sprayList = snapshot.data[1];
            PlayerCards playerCardList = snapshot.data[2];
            PlayerTitles playerTitleList = snapshot.data[3];
            Buddies buddyList = snapshot.data[4];
            var response = snapshot.data[5];
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
