import 'package:flutter/material.dart';
import 'package:valorant_companion/Utils/database_helper.dart';

class NotificationList extends StatefulWidget {
  final List<Map<String, dynamic>> notifications;
  const NotificationList({Key? key, required this.notifications})
      : super(key: key);

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  late List<Map<String, dynamic>> notifications;
  DatabaseHelper dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    notifications = widget.notifications;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: Key(notifications[index]['id'].toString()),
          child: ListTile(
            title: Text(notifications[index]['titleText']),
            subtitle: Text(notifications[index]['bodyText']),
            leading: notifications[index]['imageUrl'] != null
                ? Image.network(
                    notifications[index]['imageUrl'],
                    width: 50,
                  )
                : Image.asset(
                    'assets/images/valorant_logo.png',
                    width: 50,
                  ),
            onTap: showNotification(
                notifications[index]['titleText'],
                notifications[index]['bodyText'],
                notifications[index]['imageUrl']),
          ),
          onDismissed: (direction) async {
            await dbHelper.deleteNotification(notifications[index]['id']);
            setState(() {
              notifications.removeAt(index);
            });
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const Divider();
      },
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
