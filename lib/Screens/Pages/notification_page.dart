import 'package:flutter/material.dart';
import 'package:valorant_companion/Model/push_notification.dart';

import '../../Utils/database_helper.dart';

class NotificationPage extends StatefulWidget {
  final PushNotification? openNotification;
  const NotificationPage({Key? key, this.openNotification}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  @override
  void initState() {
    if (widget.openNotification != null) {
      showNotification(
          widget.openNotification!.title!, widget.openNotification!.body!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              await dbHelper.deleteAllNotifications();
              setState(() {});
            },
            child: const Text('clear'),
          ),
        ],
      ),
      body: FutureBuilder(
        future: dbHelper.getNotifications(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            List<Map<String, dynamic>> notifications = snapshot.data;
            return ListView.separated(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(notifications[index]['id'].toString()),
                  child: ListTile(
                    title: Text(snapshot.data![index]['titleText']),
                    subtitle: Text(snapshot.data![index]['bodyText']),
                  ),
                  onDismissed: (direction) async {
                    await dbHelper
                        .deleteNotification(snapshot.data![index]['id']);
                    setState(() {});
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
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

  showNotification(String title, String body) {
    AlertDialog dialog = AlertDialog(
      title: Text(title),
      content: Text(body),
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
