import 'package:flutter/material.dart';
import 'package:valorant_companion/Library/src/interfaces/asset.dart';
import 'package:valorant_companion/Library/src/interfaces/player.dart';
import 'package:valorant_companion/Library/src/models/inventory.dart';
import 'package:valorant_companion/Library/src/models/playercard.dart';
import 'package:valorant_companion/Library/src/models/playertitle.dart';
import 'package:valorant_companion/Library/src/models/spray.dart';
import 'package:valorant_companion/Screens/Views/inventory_identity_view.dart';

import '../../Library/src/models/weapons.dart';
import '../../Utils/database_helper.dart';
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

  Future? getPlayerInventory() async {
    if (user == null) {
      await _loadUserData();
    }
    Inventory? inventory = await playerInterface.getInventory();
    var futures = <Future>[
      assetInterface.getAssets<Weapons>(
          typeResolver: Weapons(), assetType: 'weapons'),
      assetInterface.getAssets<Spray>(
          typeResolver: Spray(), assetType: 'sprays'),
      assetInterface.getAssets<PlayerCards>(
          typeResolver: PlayerCards(), assetType: 'playercards'),
      assetInterface.getAssets<PlayerTitles>(
          typeResolver: PlayerTitles(), assetType: 'playertitles'),
    ];
    List resources = await Future.wait(futures);
    return {
      'weapons': resources[0],
      'sprays': resources[1],
      'playercards': resources[2],
      'playertitles': resources[3],
      'inventory': inventory,
    };
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
              try {
                Weapons weaponList = snapshot.data!['weapons']!;
                Spray sprayList = snapshot.data!['sprays']!;
                PlayerCards playerCards = snapshot.data!['playercards']!;
                PlayerTitles playerTitles = snapshot.data!['playertitles']!;
                Inventory inventory = snapshot.data!['inventory']!;
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
              } catch (e) {
                return const Center(
                  child: Text('Error'),
                );
              }
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
