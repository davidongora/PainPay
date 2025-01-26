// update_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateService extends ChangeNotifier {
  bool _updateAvailable = false;
  bool get updateAvailable => _updateAvailable;

  Future<void> checkForUpdate(BuildContext context) async {
    if (!Platform.isAndroid) return; // Only Android supports in-app updates

    try {
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        _updateAvailable = true;
        notifyListeners();

        // Show update dialog
        if (context.mounted) {
          await _showUpdateDialog(context);
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  Future<void> performImmediateUpdate() async {
    try {
      await InAppUpdate.performImmediateUpdate();
    } catch (e) {
      debugPrint('Error performing immediate update: $e');
    }
  }

  Future<void> startFlexibleUpdate() async {
    try {
      await InAppUpdate.startFlexibleUpdate();
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e) {
      debugPrint('Error performing flexible update: $e');
    }
  }

  Future<void> _showUpdateDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Available'),
          content: const Text(
            'A new version of the app is available. Please update to access the latest features and improvements.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Update Now'),
              onPressed: () async {
                Navigator.of(context).pop();
                await performImmediateUpdate();
              },
            ),
            TextButton(
              child: const Text('Later'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
