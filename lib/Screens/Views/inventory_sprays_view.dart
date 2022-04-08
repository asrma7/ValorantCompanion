import 'package:flutter/material.dart';

import '../../Library/src/models/inventory.dart';
import '../../Library/src/models/spray.dart';

class InventorySpraysView extends StatelessWidget {
  final List<Sprays> sprays;
  final Spray sprayList;
  const InventorySpraysView(
      {Key? key, required this.sprays, required this.sprayList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: ((context, index) {
        SprayItem spray = sprayList.getSprayFromId(sprays[index].sprayID!)!;
        return Container(
          margin: const EdgeInsets.all(10),
          child: Material(
            shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(10),
              ),
            ),
            color: Colors.grey[300],
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Image.network(
                    spray.animationGif ??
                        spray.animationPng ??
                        spray.fullTransparentIcon ??
                        spray.fullIcon ??
                        spray.displayIcon!,
                    height: 100,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    spray.displayName!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      shadows: [
                        Shadow(
                          color: Colors.white,
                          blurRadius: 1,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      itemCount: sprays.length,
    );
  }
}
