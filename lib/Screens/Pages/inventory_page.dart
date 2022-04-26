import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:valorant_companion/Library/src/models/inventory.dart';
import 'package:valorant_companion/Library/src/models/playercard.dart';
import 'package:valorant_companion/Library/src/models/playertitle.dart';
import 'package:valorant_companion/Library/src/models/spray.dart';
import 'package:valorant_companion/Screens/Views/inventory_identity_view.dart';

import '../../Library/src/models/weapons.dart';
import '../../Library/valorant_client.dart';
import '../../Utils/database_helper.dart';
import '../../Utils/helpers.dart';
import '../Views/inventory_sprays_view.dart';
import '../Views/inventory_weapons_view.dart';

class InventoryPage extends StatefulWidget {
  final String title;
  const InventoryPage({Key? key, required this.title}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final dbHelper = DatabaseHelper.instance;

  Map<String, dynamic>? user;

  Future<bool> _loadUserData() async {
    await dbHelper.queryActiveUser().then((value) {
      setState(() {
        user = value;
      });
    });
    return true;
  }

  Future? getPlayerInventory() async {
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
          .getAssets<Weapons>(typeResolver: Weapons(), assetType: 'weapons'),
      client.assetInterface
          .getAssets<Spray>(typeResolver: Spray(), assetType: 'sprays'),
      client.assetInterface.getAssets<PlayerCards>(
          typeResolver: PlayerCards(), assetType: 'playercards'),
      client.assetInterface.getAssets<PlayerTitles>(
          typeResolver: PlayerTitles(), assetType: 'playertitles'),
      client.playerInterface.getInventory(),
    ];
    return await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
      ),
      body: FutureBuilder(
          future: getPlayerInventory(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              Weapons weaponList = snapshot.data![0]!;
              Spray sprayList = snapshot.data![1]!;
              PlayerCards playerCards = snapshot.data![2]!;
              PlayerTitles playerTitles = snapshot.data![3]!;
              Inventory inventory = snapshot.data![4]!;
              return DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    Container(
                      color: Colors.red,
                      child: const TabBar(
                        tabs: [
                          Tab(
                            text: "Weapons",
                          ),
                          Tab(
                            text: "Sprays",
                          ),
                          Tab(
                            text: "Identity",
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          InventoryWeaponsView(
                            guns: inventory.guns!,
                            weaponList: weaponList,
                          ),
                          InventorySpraysView(
                            sprays: inventory.sprays!,
                            sprayList: sprayList,
                          ),
                          InventoryIdentityView(
                            playerCard: playerCards.getPlayerCardFromId(
                                inventory.identity!.playerCardID!)!,
                            playerTitle: playerTitles.getPlayerTitleFromId(
                                inventory.identity!.playerTitleID!)!,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
