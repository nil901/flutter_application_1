import 'package:flutter/material.dart';
import 'package:flutter_application_1/color/colors.dart';
import 'package:flutter_application_1/utils/comman_app_bar.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  final List<Map<String, String>> notifications = const [
    {
      "title": "New Lead Assigned",
      "message": "You have been assigned a new lead.",
      "time": "10 mins ago",
    },
    {
      "title": "Call Reminder",
      "message": "Reminder: Call back client at 3:00 PM.",
      "time": "1 hour ago",
    },
    {
      "title": "System Update",
      "message": "Dashboard maintenance scheduled for tomorrow.",
      "time": "Yesterday",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kwhite,
      appBar:  CustomAppBar(title:  "Notifications"),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return ListTile(
            leading: const Icon(Icons.notifications, color: Colors.orange),
            title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item['message']!),
            trailing: Text(item['time']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          );
        },
      ),
    );
  }
}
