import 'package:flutter/material.dart';

import '../Screens/Pages/notification_page.dart';

class MyAppBar extends AppBar {
  final String appbarTitle;
  final int notificationCount;
  final BuildContext context;
  MyAppBar({
    Key? key,
    required this.appbarTitle,
    this.notificationCount = 0,
    required this.context,
  }) : super(
          key: key,
          backgroundColor: Colors.red,
          title: Text(appbarTitle),
          automaticallyImplyLeading: true,
          actions: <Widget>[
            IconButton(
              icon: notificationCount > 0
                  ? Stack(
                      children: [
                        const Icon(Icons.notifications),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            height: 15,
                            width: 15,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                notificationCount.toString(),
                                style: const TextStyle(
                                  fontSize: 8.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationPage(),
                  ),
                );
              },
            ),
          ],
        );
}
