import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:valorant_companion/Components/store_item.dart';
import '../Components/timer.dart';
import '../Library/valorant_client.dart';
import '../Library/src/models/storefront.dart';
import 'package:dio/dio.dart';

import '../Utils/database_helper.dart';
import '../Utils/helpers.dart';

class FeaturedScreen extends StatefulWidget {
  final String title;
  const FeaturedScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<FeaturedScreen> createState() => _FeaturedScreenState();
}

class _FeaturedScreenState extends State<FeaturedScreen> {
  final dbHelper = DatabaseHelper.instance;

  late Map<String, dynamic> user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    await dbHelper.queryAllRows().then((value) {
      setState(() {
        user = value[0];
      });
    });
  }

  Future? getStoreOffers() async {
    ValorantClient client = ValorantClient(
      UserDetails(
        userName: user['username'],
        password: user['password'],
        region: stringToRegion(user['region'])!,
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
    Future<Storefront?> resp = client.playerInterface.getStorefront();
    return resp;
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
            var response = snapshot.data;
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
                      return StoreItem(
                        itemId: itemId!,
                        itemType:
                            ItemTypeConstants.getItemTypeFromId(itemTypeId!),
                        basePrice: item.basePrice,
                        discountedPrice: item.discountedPrice,
                        discountPercent: item.discountPercent,
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
