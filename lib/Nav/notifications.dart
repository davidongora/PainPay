// notification_screen.dart

import 'package:flutter/material.dart';
import 'package:pain_pay/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:pain_pay/shared/app_bar.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => NotificationService().clearNotifications(),
          ),
        ],
      ),
      body: Consumer<NotificationService>(
        builder: (context, notificationService, child) {
          final notifications = notificationService.notifications;

          return notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 48),
                      SizedBox(height: 16),
                      Text('No notifications yet'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.notifications),
                        title: Text(notification.title),
                        subtitle: Text(notification.body),
                        trailing: Text(
                          '${notification.timestamp.hour}:${notification.timestamp.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
