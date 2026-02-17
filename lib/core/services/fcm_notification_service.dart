// FCM Notification Service
// in-app notification creation, and real-time popup triggering via Firestore listener.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/auth/current_user_session.dart';
import '../utils/location_utils.dart';

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

  static final Set<String> _shownNotificationIds = {};

  // Firestore real-time listener for new notifications.
  StreamSubscription<QuerySnapshot>? _notificationListener;

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

  /// Show a local popup notification on the device.
  static Future<void> showLocalPopup({
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

    // Use a unique ID based on current time to avoid overwriting
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 & 0x7FFFFFFF,
      title,
      body,
      details,
      payload: payload,
    );
  }


  /// Initialize FCM: request permissions, get token, save to Firestore, setup listeners.
  Future<void> initialize() async {
    try {
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

      final String title = message.notification?.title ?? 'Notification';
      final String body =
          message.notification?.body ?? message.data['message'] ?? '';
      final String type = message.data['type'] ?? 'message';
      final String? caseId = message.data['caseId'];

      // Show local popup for foreground FCM messages
      showLocalPopup(title: title, body: body, payload: caseId);

      // Create in-app notification document (only if not already created by the trigger)
      // use a dedup key in the data to avoid creating duplicates
      final String? dedupeKey = message.data['dedupeKey'];
      if (dedupeKey == null) {
        _createNotificationDocument(
          userId: uid,
          title: title,
          message: body,
          type: type,
          caseId: caseId,
        );
      }
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
      debugPrint('Failed to create notification doc: $e');
    }
  }

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

  /// Start listening for new notification documents for this user.
  void startNotificationListener(String userId) {
    _notificationListener?.cancel();
    _shownNotificationIds.clear();
    bool isFirstSnapshot = true;

    _notificationListener = _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .listen(
      (snapshot) {
        if (isFirstSnapshot) {
          for (final doc in snapshot.docs) {
            _shownNotificationIds.add(doc.id);
          }
          isFirstSnapshot = false;
          return;
        }

        // Show popup only for newly added notifications
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final docId = change.doc.id;
            if (!_shownNotificationIds.contains(docId)) {
              _shownNotificationIds.add(docId);
              final data = change.doc.data() as Map<String, dynamic>;
              final title = data['title'] as String? ?? 'Notification';
              final body = data['message'] as String? ?? '';
              final caseId = data['caseId'] as String?;
              showLocalPopup(title: title, body: body, payload: caseId);
            }
          }
        }
      },
      onError: (e) {
        debugPrint('Notification listener error (non-fatal): $e');
      },
    );
  }

  /// Stop the notification listener (call on logout).
  void stopNotificationListener() {
    _notificationListener?.cancel();
    _notificationListener = null;
    _shownNotificationIds.clear();
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


  /// VHT creates a case → notify clinician (popup via listener + in-app)
  /// and VHT themselves (in-app only).
  Future<void> notifyOnCaseCreated({
    required String clinicianId,
    required String vhtId,
    required String caseId,
    required String emergencyType,
    required String patientName,
    required String urgencyLevel,
    required String clinicName,
    required String vhtName,
  }) async {
    final futures = <Future>[];

    // Clinician: popup + in-app
    futures.add(sendInAppNotification(
      userId: clinicianId,
      title: '🚨 New Emergency Case',
      message: 'New $emergencyType case from VHT $vhtName. Patient: $patientName. Urgency: ${urgencyLevel.toUpperCase()}. Please review immediately.',
      type: 'new_case',
      caseId: caseId,
    ));

    // VHT: in-app only (no popu)
    futures.add(sendInAppNotification(
      userId: vhtId,
      title: 'Case Submitted Successfully',
      message: 'Your $emergencyType case for $patientName has been sent to $clinicName for review.',
      type: 'case_submitted',
      caseId: caseId,
    ));

    await Future.wait(futures);
  }

  Future<void> notifyClinicianOfVhtFollowUp({
    required String clinicianId,
    required String caseId,
    required String patientName,
    required String vhtName,
    required String followUpMessage,
  }) async {
    final shortMsg = followUpMessage.length > 80 ? '${followUpMessage.substring(0, 80)}...' : followUpMessage;
    await sendInAppNotification(
      userId: clinicianId,
      title: '📩 VHT Follow-up Update',
      message: '$vhtName updated on $patientName: "$shortMsg"',
      type: 'vht_follow_up',
      caseId: caseId,
    );
  }

  /// Clinician advises VHT → VHT gets popup + in-app.
  Future<void> notifyVhtOfClinicianAdvice({
    required String vhtId,
    required String caseId,
    required String patientName,
    required String clinicianName,
    required String advice,
  }) async {
    final shortAdvice = advice.length > 80 ? '${advice.substring(0, 80)}...' : advice;
    await sendInAppNotification(
      userId: vhtId,
      title: 'Clinician Advice Received',
      message: 'Dr. $clinicianName responded about $patientName: "$shortAdvice"',
      type: 'clinician_advice',
      caseId: caseId,
    );
  }

  /// Clinician requests ambulance → nearest admin gets popup + in-app.
  /// [vhtLatitude] / [vhtLongitude] are the VHT's GPS coordinates used to
  /// find the nearest admin. If omitted, all admins are notified.
  Future<void> notifyAdminsOfAmbulanceRequest({
    required String caseId,
    required String emergencyType,
    required String patientName,
    required String clinicianName,
    double? vhtLatitude,
    double? vhtLongitude,
  }) async {
    try {
      final adminsQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Admin')
          .get();

      if (adminsQuery.docs.isEmpty) return;

      // Identify the nearest admin when coordinates are available.
      List<String> targetAdminIds;

      if (vhtLatitude != null && vhtLongitude != null) {
        // Build admin list with distances and sort nearest first.
        final withDistances = adminsQuery.docs.map((doc) {
          final data = doc.data();
          final adminLat = (data['latitude'] as num?)?.toDouble();
          final adminLng = (data['longitude'] as num?)?.toDouble();
          final distance = (adminLat != null && adminLng != null)
              ? LocationUtils.calculateDistance(
                  vhtLatitude, vhtLongitude, adminLat, adminLng)
              : double.maxFinite;
          return {'id': doc.id, 'distance': distance};
        }).toList();

        withDistances.sort(
            (a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

        // Notify only the nearest admin.
        targetAdminIds = [withDistances.first['id'] as String];
      } else {
        // No location info — notify all admins as fallback.
        targetAdminIds = adminsQuery.docs.map((d) => d.id).toList();
      }

      final futures = targetAdminIds.map((adminId) {
        return sendInAppNotification(
          userId: adminId,
          title: '🚑 Ambulance Dispatch Required',
          message:
              'Dr. $clinicianName requests an ambulance for $emergencyType case. Patient: $patientName. Please dispatch immediately.',
          type: 'dispatch_request',
          caseId: caseId,
        );
      });

      await Future.wait(futures);
    } catch (e) {
      debugPrint('Failed to notify admins of ambulance request: $e');
    }
  }


  /// Ambulance dispatched → notify VHT (popup+inapp), clinic (popup+inapp), driver (popup+inapp).
  Future<void> notifyOnAmbulanceDispatched({
    required String caseId,
    required String emergencyType,
    required String patientName,
    required String vhtId,
    required String clinicianId,
    required String driverId,
    required String driverName,
    required String clinicName,
    required String vhtName,
  }) async {
    final futures = <Future>[];

    // VHT: popup + in-app
    futures.add(sendInAppNotification(
      userId: vhtId,
      title: '🚑 Ambulance On The Way',
      message: 'Great news! An ambulance driven by $driverName has been dispatched to you for your $emergencyType case. Stay with $patientName.',
      type: 'ambulance_dispatched',
      caseId: caseId,
    ));

    // Clinician: popup + in-app
    futures.add(sendInAppNotification(
      userId: clinicianId,
      title: '🚑 Ambulance Dispatched',
      message: 'Ambulance driver $driverName has been dispatched for the $emergencyType case (Patient: $patientName). Prepare to receive patient.',
      type: 'ambulance_dispatched',
      caseId: caseId,
    ));

    // Driver: popup + in-app
    futures.add(sendInAppNotification(
      userId: driverId,
      title: '🚑 New Dispatch Assignment',
      message: 'You have been assigned to a $emergencyType case. Collect patient from VHT $vhtName and deliver to $clinicName. Patient: $patientName.',
      type: 'dispatch_assigned',
      caseId: caseId,
    ));

    await Future.wait(futures);
  }

  /// Patient delivered to clinic → notify VHT (popup+inapp), admin (popup+inapp), clinic (inapp only).
  Future<void> notifyOnPatientDelivered({
    required String caseId,
    required String emergencyType,
    required String patientName,
    required String vhtId,
    required String clinicianId,
    required String clinicName,
    required String driverName,
  }) async {
    final futures = <Future>[];

    // VHT: popup + in-app (personalized)
    futures.add(sendInAppNotification(
      userId: vhtId,
      title: 'Patient Delivered',
      message: 'Your patient $patientName ($emergencyType) has been safely delivered to $clinicName by $driverName. They will now receive treatment.',
      type: 'patient_delivered',
      caseId: caseId,
    ));

    // Notify all admins: popup + in-app (personalized)
    try {
      final adminsQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Admin')
          .get();

      for (final adminDoc in adminsQuery.docs) {
        futures.add(sendInAppNotification(
          userId: adminDoc.id,
          title: 'Patient Delivered',
          message: '$patientName ($emergencyType) has been delivered to $clinicName by driver $driverName. Awaiting clinical handover.',
          type: 'patient_delivered',
          caseId: caseId,
        ));
      }
    } catch (e) {
      debugPrint('Failed to fetch admins for delivery notification: $e');
    }

    // Clinician: in-app only (they'll see the delivered status on screen)
    futures.add(sendInAppNotification(
      userId: clinicianId,
      title: 'Patient Arriving',
      message: 'Patient $patientName ($emergencyType) has been delivered by $driverName. Please receive the patient.',
      type: 'patient_delivered',
      caseId: caseId,
    ));

    await Future.wait(futures);
  }

  /// Patient discharged → notify VHT (popup+inapp), admin (popup+inapp).
  Future<void> notifyOnPatientDischarged({
    required String caseId,
    required String emergencyType,
    required String patientName,
    required String vhtId,
    required String clinicName,
    required String clinicianName,
  }) async {
    final futures = <Future>[];

    // VHT: popup + in-app
    futures.add(sendInAppNotification(
      userId: vhtId,
      title: 'Patient Discharged',
      message: 'Your patient $patientName ($emergencyType) has been treated and discharged from $clinicName. Case is now complete.',
      type: 'patient_discharged',
      caseId: caseId,
    ));

    // All admins: popup + in-app
    try {
      final adminsQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Admin')
          .get();

      for (final adminDoc in adminsQuery.docs) {
        futures.add(sendInAppNotification(
          userId: adminDoc.id,
          title: '🏥 Case Completed',
          message: '$patientName ($emergencyType) has been discharged from $clinicName by Dr. $clinicianName. Case closed.',
          type: 'case_completed',
          caseId: caseId,
        ));
      }
    } catch (e) {
      debugPrint('Failed to fetch admins for discharge notification: $e');
    }

    await Future.wait(futures);
  }

  /// Clinician closes advice-path case → notify VHT (popup+inapp).
  Future<void> notifyOnCaseClosed({
    required String caseId,
    required String emergencyType,
    required String patientName,
    required String vhtId,
    required String clinicianName,
  }) async {
    await sendInAppNotification(
      userId: vhtId,
      title: 'Case Closed',
      message: 'Dr. $clinicianName has confirmed $patientName ($emergencyType) is OK and closed the case.',
      type: 'case_closed',
      caseId: caseId,
    );
  }


  /// Notify clinician of a new emergency case (legacy - use [notifyOnCaseCreated] instead).
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

  /// Notify user that ambulance has been dispatched 
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

  /// Notify VHT of a status update on their reported case 
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

  /// Notify driver of a new dispatch assignment 
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
