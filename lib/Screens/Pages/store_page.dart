import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:valorant_companion/Components/store_item.dart';
import 'package:valorant_companion/Components/timer.dart';
import 'package:valorant_companion/Library/src/models/content_tiers.dart';
import 'package:valorant_companion/Library/src/models/offers.dart';
import 'package:valorant_companion/Utils/database_helper.dart';
import 'package:valorant_companion/Utils/helpers.dart';
import '../../Library/src/models/weapons.dart';
import '/Library/valorant_client.dart';
import 'package:dio/dio.dart';

class StorePage extends StatefulWidget {
  final String title;
  const StorePage({Key? key, required this.title}) : super(key: key);

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final dbHelper = DatabaseHelper.instance;

  bool _clientHasError = false;

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
    ValorantClient client = ValorantClient(
      UserDetails(
        userName: user!['username'],
        password: user!['password'],
        region: stringToRegion(user!['region'])!,
      ),
      shouldPersistSession: false,
      callback: Callback(
        onError: (String error) {
          _clientHasError = true;
          if (error == "Authentication Failed.") {
            dbHelper.activeUserHasError();
            Navigator.pop(context);
            Navigator.popAndPushNamed(context, '/');
          } else {
            if (kDebugMode) {
              print(error);
            }
          }
        },
        onRequestError: (DioError error) {
          _clientHasError = true;
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
      client.assetInterface.getAssets<ContentTiers>(
          typeResolver: ContentTiers(), assetType: 'contenttiers'),
      client.playerInterface.getStorefront(),
      client.playerInterface.getStoreOffers(),
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
          if (snapshot.hasData && !_clientHasError) {
            Skins skinList = snapshot.data[0]!;
            ContentTiers contentTiersList = snapshot.data[1]!;
            var response = snapshot.data[2]!;
            Offers storeOffers = snapshot.data[3]!;
            List<String> items = response.skinsPanelLayout.singleItemOffers;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: TimerComponent(
                      time: response.skinsPanelLayout
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
          } else if (snapshot.hasError || _clientHasError) {
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
