// FCM Notification Service
// Handles push notification registration, foreground/background message handling,

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/auth/current_user_session.dart';

/// Top-level background message handler. Must be registered in main() before runApp().
/// Runs in a separate isolate when app is in background or terminated.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('FCM background message: ${message.notification?.title}');
}

class FCMNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static bool _localNotificationsInitialized = false;

  /// Android notification channel for emergency alerts
  static const AndroidNotificationChannel _emergencyChannel =
      AndroidNotificationChannel(
    'emergency_alerts',
    'Emergency Alerts',
    description: 'Notifications for emergency cases and status updates',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  /// Register the background message handler. Call from main() before runApp().
  static void registerBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Initialize local notifications plugin and create Android channel.
  static Future<void> _initializeLocalNotifications() async {
    if (_localNotificationsInitialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Local notification tapped: ${response.payload}');
      },
    );

    // Create the Android notification channel
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_emergencyChannel);
    }

    _localNotificationsInitialized = true;
  }

  /// Show a local notification (for foreground push messages)
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _initializeLocalNotifications();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'emergency_alerts',
      'Emergency Alerts',
      channelDescription: 'Notifications for emergency cases and status updates',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Initialize FCM: request permissions, get token, save to Firestore, setup listeners.
  Future<void> initialize() async {
    try {
      // Initialize local notifications first
      await _initializeLocalNotifications();

      final NotificationSettings settings =
          await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        final String? token = await _messaging.getToken();
        if (token != null) {
          await _saveTokenToFirestore(token);
        }

        _messaging.onTokenRefresh.listen((String newToken) {
          _saveTokenToFirestore(newToken);
        });

        _setupForegroundListener();
        _setupMessageOpenedListener();
      }
    } catch (e) {
      debugPrint('FCM initialization error (non-fatal): $e');
    }
  }

  void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final String? uid = CurrentUserSession.uid;
      if (uid == null || uid.isEmpty) return;

      final String title =
          message.notification?.title ?? 'Notification';
      final String body =
          message.notification?.body ?? message.data['message'] ?? '';
      final String type = message.data['type'] ?? 'message';
      final String? caseId = message.data['caseId'];

      // Show a local notification so it appears even in foreground
      _showLocalNotification(
        title: title,
        body: body,
        payload: caseId,
      );

      // Also create in-app notification document
      _createNotificationDocument(
        userId: uid,
        title: title,
        message: body,
        type: type,
        caseId: caseId,
      );
    });
  }

  void _setupMessageOpenedListener() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification opened: ${message.data}');
    });
  }

  Future<void> _createNotificationDocument({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? caseId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'read': false,
        if (caseId != null) 'caseId': caseId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to create foreground notification doc: $e');
    }
  }

  /// Save FCM token to the current user's Firestore document.
  Future<void> _saveTokenToFirestore(String token) async {
    final String? uid = CurrentUserSession.uid;
    if (uid == null || uid.isEmpty) return;

    try {
      await _firestore.collection('users').doc(uid).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      try {
        await _firestore.collection('users').doc(uid).set({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Failed to save FCM token: $e');
      }
    }
  }

  /// Create an in-app notification document in Firestore.
  Future<void> sendInAppNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? caseId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'read': false,
        if (caseId != null) 'caseId': caseId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to send in-app notification: $e');
    }
  }

  /// Notify clinician of a new emergency case.
  Future<void> notifyClinicianOfEmergency({
    required String clinicianId,
    required String emergencyType,
    required String patientName,
    required String caseId,
    required String vhtName,
    String? urgencyLevel,
  }) async {
    final String urgency = urgencyLevel ?? 'Unknown';
    final String message =
        'Emergency: $emergencyType case reported by VHT $vhtName. Patient: $patientName. Urgency: $urgency. Please review and take action.';
    await sendInAppNotification(
      userId: clinicianId,
      title: 'New Emergency Case',
      message: message,
      type: 'emergency',
      caseId: caseId,
    );
  }

  /// Notify user that ambulance has been dispatched.
  Future<void> notifyOfDispatch({
    required String userId,
    required String caseId,
    required String emergencyType,
    required String patientName,
  }) async {
    final String message =
        'Ambulance has been dispatched for $emergencyType emergency. Patient: $patientName. Driver is en route.';
    await sendInAppNotification(
      userId: userId,
      title: 'Ambulance Dispatched',
      message: message,
      type: 'dispatch',
      caseId: caseId,
    );
  }

  /// Notify VHT of a status update on their reported case.
  Future<void> notifyVhtOfStatusUpdate({
    required String vhtId,
    required String caseId,
    required String status,
    required String patientName,
  }) async {
    final String message =
        'Your reported case for $patientName has been updated. Status: $status.';
    await sendInAppNotification(
      userId: vhtId,
      title: 'Case Status Update',
      message: message,
      type: 'case_update',
      caseId: caseId,
    );
  }

  /// Notify driver of a new dispatch assignment.
  Future<void> notifyDriverOfDispatch({
    required String driverId,
    required String caseId,
    required String emergencyType,
    required String patientName,
    required String clinicName,
  }) async {
    final String message =
        'New dispatch assignment: $emergencyType emergency. Patient: $patientName. Destination: $clinicName. Accept to start your ride.';
    await sendInAppNotification(
      userId: driverId,
      title: 'New Dispatch Assignment',
      message: message,
      type: 'dispatch',
      caseId: caseId,
    );
  }
}
