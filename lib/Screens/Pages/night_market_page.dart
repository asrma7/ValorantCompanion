import 'package:flutter/material.dart';
import 'package:valorant_companion/Library/src/interfaces/asset.dart';
import 'package:valorant_companion/Library/src/interfaces/player.dart';
import 'package:valorant_companion/Library/src/models/storefront.dart';

import '../../Components/store_item.dart';
import '../../Components/timer.dart';
import '../../Library/src/models/content_tiers.dart';
import '../../Library/src/models/weapons.dart';
import '../../Library/valorant_client.dart';
import '../../Utils/database_helper.dart';

class NightMarketPage extends StatefulWidget {
  final String title;
  const NightMarketPage({Key? key, required this.title}) : super(key: key);

  @override
  State<NightMarketPage> createState() => _NightMarketPageState();
}

class _NightMarketPageState extends State<NightMarketPage> {
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
    var futures = <Future>[
      assetInterface.getAssets<Skins>(
          typeResolver: Skins(), assetType: 'weapons/skins'),
      assetInterface.getAssets<ContentTiers>(
          typeResolver: ContentTiers(), assetType: 'contenttiers'),
      playerInterface.getStorefront(),
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
            if (snapshot.data[2].bonusStore == null) {
              return const Center(
                child: Text('Night Market is not available'),
              );
            }
            Skins skinList = snapshot.data[0]!;
            ContentTiers contentTiersList = snapshot.data[1]!;
            Storefront response = snapshot.data[2]!;
            List<BonusStoreOffers> items =
                response.bonusStore!.bonusStoreOffers!;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: TimerComponent(
                      time: response
                          .bonusStore!.bonusStoreRemainingDurationInSeconds!,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      Skin skin = skinList.skinList.singleWhere((element) =>
                          element.levels!.first.uuid ==
                          items[index].offer!.offerID);
                      return StoreItem(
                        storeType: StoreType.nightmarket,
                        itemId: items[index].offer!.offerID!,
                        displayIcon:
                            skin.levels!.first.displayIcon ?? skin.displayIcon,
                        displayName: skin.displayName,
                        streamedVideo: skin.levels!.last.streamedVideo,
                        contentTier: contentTiersList
                            .getPlayerTitleFromId(skin.contentTierUuid!),
                        discountPercent: items[index].discountPercent,
                        discountedPrice:
                            items[index].discountCosts!.valorantPoints,
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
