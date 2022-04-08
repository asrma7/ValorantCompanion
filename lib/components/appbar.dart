import 'package:flutter/material.dart';

class MyAppBar extends AppBar {
  final String appbarTitle;
  MyAppBar({Key? key, required this.appbarTitle})
      : super(
          key: key,
          backgroundColor: Colors.red,
          title: Text(appbarTitle),
          automaticallyImplyLeading: true,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => () {},
            ),
          ],
        );
}
