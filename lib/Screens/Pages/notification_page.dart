import 'package:flutter/material.dart';
import 'package:valorant_companion/Model/push_notification.dart';

import '../../Components/notification_lists.dart';
import '../../Utils/database_helper.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  @override
  Widget build(BuildContext context) {
    final PushNotification? notification =
        ModalRoute.of(context)?.settings.arguments as PushNotification?;
    if (notification != null) {
      String? imageUrl = notification.imageUrl;
      showNotification(notification.title, notification.body, imageUrl);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            onPressed: () async {
              await dbHelper.deleteAllNotifications();
              setState(() {});
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: FutureBuilder(
        future: dbHelper.getNotifications(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            List<Map<String, dynamic>> notifications = snapshot.data;
            return NotificationList(
              notifications: notifications,
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  showNotification(String title, String body, String? imageUrl) {
    AlertDialog dialog = AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          imageUrl != null
              ? Image.network(
                  imageUrl,
                  height: 150,
                )
              : Container(),
          Text(body),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
    dialog.build(context);
  }
}
