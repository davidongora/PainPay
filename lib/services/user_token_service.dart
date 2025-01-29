import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class UserTokenService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save user's FCM token
  Future<void> saveUserToken(String userId, String token) async {
    try {
      await _firestore.collection('user_tokens').doc(userId).set({
        'token': token,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving user token: $e');
    }
  }

  // Get user's FCM token
  Future<String?> getUserToken(String userId) async {
    try {
      final doc = await _firestore.collection('user_tokens').doc(userId).get();
      return doc.data()?['token'] as String?;
    } catch (e) {
      print('Error fetching user token: $e');
      return null;
    }
  }

  // Update token when it refreshes
  Future<void> setupTokenRefreshListener(String userId) async {
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) async {
      try {
        await saveUserToken(userId, token);
      } catch (e) {
        print('Error updating token: $e');
      }
    });
  }
}
