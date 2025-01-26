import 'package:flutter/material.dart';

class NotificationModel {
  final String title;
  final String body;
  final DateTime timestamp;

  NotificationModel({
    required this.title,
    required this.body,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class NotificationsProvider with ChangeNotifier {
  final List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  void addNotification(String title, String body) {
    _notifications.add(NotificationModel(title: title, body: body));
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
