import 'package:flutter/material.dart';
import 'package:valorant_companion/Components/store_item.dart';
import 'package:valorant_companion/Components/timer.dart';
import 'package:valorant_companion/Library/src/interfaces/asset.dart';
import 'package:valorant_companion/Library/src/interfaces/player.dart';
import 'package:valorant_companion/Library/src/models/content_tiers.dart';
import 'package:valorant_companion/Library/src/models/offers.dart';
import 'package:valorant_companion/Library/src/models/storefront.dart';
import 'package:valorant_companion/Utils/database_helper.dart';
import '../../Library/src/models/weapons.dart';
import '/Library/valorant_client.dart';

class StorePage extends StatefulWidget {
  final String title;
  const StorePage({Key? key, required this.title}) : super(key: key);

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
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
      assetInterface.getAssets<ContentTiers>(
          typeResolver: ContentTiers(), assetType: 'contenttiers'),
      playerInterface.getStoreOffers(),
    ];
    List resources = await Future.wait(futures);
    return {
      'skins': resources[0],
      'contentTiers': resources[1],
      'offers': resources[2],
      'storeFront': storeFront,
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
            Skins skinList = snapshot.data['skins']!;
            ContentTiers contentTiersList = snapshot.data['contentTiers']!;
            Offers storeOffers = snapshot.data['offers']!;
            Storefront? storeFront = snapshot.data['storeFront']!;
            List<String> items = storeFront!.skinsPanelLayout!.singleItemOffers;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: TimerComponent(
                      time: storeFront.skinsPanelLayout!
                          .singleItemOffersRemainingDurationInSeconds,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      Skin skin = skinList.skinList.singleWhere((element) =>
                          element.levels!.first.uuid == items[index]);
                      int price = storeOffers.offerList
                          .singleWhere((element) => element.id == items[index])
                          .cost!
                          .amount;
                      return StoreItem(
                        storeType: StoreType.dailyoffer,
                        itemId: items[index],
                        displayIcon:
                            skin.levels!.first.displayIcon ?? skin.displayIcon,
                        basePrice: price.toDouble(),
                        displayName: skin.displayName,
                        streamedVideo: skin.levels!.last.streamedVideo,
                        contentTier: contentTiersList
                            .getPlayerTitleFromId(skin.contentTierUuid!),
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
