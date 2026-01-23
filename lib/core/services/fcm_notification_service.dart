// FCM Notification Service
// Handles sending push notifications via Firebase Cloud Messaging

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FCMNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize FCM and request permissions
  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Get FCM token
    String? token = await _messaging.getToken();
    if (token != null) {
      // Store token in Firestore for current user
      await _saveTokenToFirestore(token);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _saveTokenToFirestore(newToken);
    });
  }

  /// Save FCM token to Firestore
  Future<void> _saveTokenToFirestore(String token) async {
    // Get current user ID from session
    // This should be implemented based on your auth system
    // For now, we'll store it when sending notifications
  }

  /// Send notification to a specific FCM token
  /// Note: In production, this should be done via a backend server
  /// For now, we'll use Firebase Cloud Functions or direct HTTP API
  Future<bool> sendNotificationToClinician({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // In production, call your backend API or Cloud Function
      // For now, we'll create a notification document in Firestore
      // and let a Cloud Function handle the actual sending
      
      await _firestore.collection('notifications').add({
        'to': fcmToken,
        'title': title,
        'body': body,
        'data': data ?? {},
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      return true;
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }

  /// Send emergency case notification to clinician
  Future<bool> notifyClinicianOfEmergency({
    required String fcmToken,
    required String emergencyType,
    required String patientId,
    required String caseId,
    required String vhtName,
    String? urgencyLevel,
  }) async {
    final title = 'New Emergency Case';
    final body = '$emergencyType case reported by $vhtName';
    
    final notificationData = {
      'type': 'emergency_case',
      'caseId': caseId,
      'patientId': patientId,
      'emergencyType': emergencyType,
      'urgencyLevel': urgencyLevel ?? 'medium',
      'vhtName': vhtName,
    };

    return await sendNotificationToClinician(
      fcmToken: fcmToken,
      title: title,
      body: body,
      data: notificationData,
    );
  }
}
