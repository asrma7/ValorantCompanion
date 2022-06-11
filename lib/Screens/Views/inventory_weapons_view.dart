import 'package:flutter/material.dart';
import 'package:valorant_companion/Library/src/models/weapons.dart';

import '../../Library/src/models/inventory.dart';

class InventoryWeaponsView extends StatelessWidget {
  final List<Guns> guns;
  final Weapons weaponList;
  const InventoryWeaponsView(
      {Key? key, required this.guns, required this.weaponList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: ((context, index) {
        Weapon weapon = weaponList.getWeaponFromId(guns[index].iD!)!;
        Skin skin = weapon.getSkinFromId(guns[index].skinID!)!;
        Chromas chroma = skin.getChromaFromId(guns[index].chromaID!)!;
        String skinImage = "";
        if (skin.displayName!.contains("Standard")) {
          skinImage = weapon.displayIcon!;
        } else {
          skinImage =
              chroma.displayIcon ?? skin.displayIcon ?? weapon.displayIcon!;
        }
        return Container(
          margin: const EdgeInsets.all(10),
          child: Material(
            shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(10),
              ),
            ),
            color: Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Image.network(
                    skinImage,
                    height: 100,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      itemCount: guns.length,
    );
  }
}
