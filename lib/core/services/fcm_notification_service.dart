// FCM Notification Service
// in-app notification creation, and real-time popup triggering via Firestore listener.

import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/auth/current_user_session.dart';
import '../../l10n/app_localizations.dart';
import 'current_app_locale.dart';
import '../utils/location_utils.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('FCM background message received: ${message.notification?.title ?? message.data['title']}');

  if (message.notification == null) {
    final title = message.data['title'] ?? 'Emergency Alert';
    final body = message.data['body'] ?? message.data['message'] ?? '';
    if (title.isNotEmpty || body.isNotEmpty) {
      try {
        await FCMNotificationService.showLocalPopup(
          title: title,
          body: body,
          payload: message.data['caseId'],
          role: message.data['recipientRole'],
        );
      } catch (e) {
        debugPrint('Background handler notification error: $e');
      }
    }
  }
}

class FCMNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static bool _localNotificationsInitialized = false;
  static bool _channelsRegistered = false;

  static final Set<String> _shownNotificationIds = {};

  // Prevent registering multiple onMessage / onMessageOpenedApp listeners.
  static bool _foregroundListenerSetup = false;

  // Firestore real-time listener for new notifications.
  StreamSubscription<QuerySnapshot>? _notificationListener;

  static const Map<String, AndroidNotificationChannel> _roleChannels = {
    'ambulance': AndroidNotificationChannel(
      'ambulance_emergency_v4',
      'Ambulance Alerts',
      description: 'New dispatch and mission alerts (siren sound)',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('ambulance_alert'),
      enableLights: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    ),
    'clinician': AndroidNotificationChannel(
      'clinician_emergency_v3',
      'Clinician Alerts',
      description: 'New emergency cases and follow-ups (loud alert)',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('clinician_alert'),
      enableLights: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    ),
    'admin': AndroidNotificationChannel(
      'admin_emergency_v3',
      'Admin Alerts',
      description: 'Dispatch requests and case updates (loud alert)',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('admin_alert'),
      enableLights: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    ),
    'vht': AndroidNotificationChannel(
      'vht_emergency_v3',
      'VHT Alerts',
      description: 'Ambulance on the way, clinician advice (loud alert)',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('vht_alert'),
      enableLights: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    ),
  };

  /// Fallback channel when role is unknown (e.g. background FCM). Uses loud alert.
  static const AndroidNotificationChannel _emergencyChannel =
      AndroidNotificationChannel(
    'emergency_alerts_v3',
    'Emergency Alerts',
    description: 'Notifications for emergency cases and status updates',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    sound: RawResourceAndroidNotificationSound('vht_alert'),
    enableLights: true,
    audioAttributesUsage: AudioAttributesUsage.alarm,
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

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.createNotificationChannel(_emergencyChannel);
      for (final channel in _roleChannels.values) {
        await androidPlugin.createNotificationChannel(channel);
      }
      _channelsRegistered = true;
    }

    _localNotificationsInitialized = true;
  }

  /// Maps app role string to channel key for custom sound.
  static String _channelKeyForRole(String? role) {
    if (role == null || role.isEmpty) return '';
    final r = role.toLowerCase();
    if (r.contains('ambulance')) return 'ambulance';
    if (r.contains('clinic') || r.contains('clinician')) return 'clinician';
    if (r.contains('admin')) return 'admin';
    if (r.contains('vht')) return 'vht';
    return '';
  }

  /// Show a local popup notification on the device.
  /// role-specific channel and sound (ambulance siren, clinician/admin/VHT alert).
  /// [tapToViewSuffix] is shown in the user's current app language (e.g. "Tap to view case").
  static Future<void> showLocalPopup({
    required String title,
    required String body,
    String? payload,
    String? role,
    String? tapToViewSuffix,
  }) async {
    await _initializeLocalNotifications();

    String displayBody = body.trim();
    if (tapToViewSuffix != null && tapToViewSuffix.isNotEmpty) {
      displayBody = displayBody.isEmpty
          ? tapToViewSuffix
          : '$displayBody\n$tapToViewSuffix';
    }

    final String channelKey = _channelKeyForRole(role);
    final bool isAmbulance = channelKey == 'ambulance';
    final AndroidNotificationChannel? roleChannel =
        channelKey.isNotEmpty ? _roleChannels[channelKey] : null;
    final AndroidNotificationChannel activeChannel =
        roleChannel ?? _emergencyChannel;
    final String channelId = activeChannel.id;
    final String channelName = activeChannel.name;
    final String channelDescription = activeChannel.description ?? '';

    // Vibration pattern: 3 long pulses for ambulance, 2 pulses for others
    final Int64List vibrationPattern = isAmbulance
        ? Int64List.fromList([0, 600, 200, 600, 200, 600])
        : Int64List.fromList([0, 400, 200, 400]);

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
      icon: '@mipmap/ic_launcher',
      // Ambulance: fullscreen takeover + persistent until tapped
      fullScreenIntent: isAmbulance,
      ongoing: isAmbulance,
      autoCancel: true,
      visibility: NotificationVisibility.public,
      category: isAmbulance
          ? AndroidNotificationCategory.alarm
          : AndroidNotificationCategory.reminder,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Use a unique ID based on current time to avoid overwriting
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 & 0x7FFFFFFF,
      title,
      displayBody,
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
    if (_foregroundListenerSetup) return;
    _foregroundListenerSetup = true;
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final String? uid = CurrentUserSession.uid;
      if (uid == null || uid.isEmpty) return;

      final l10n = lookupAppLocalizations(CurrentAppLocale.current);
      final String title = message.notification?.title
          ?? message.data['title']
          ?? l10n.notificationFallbackTitle;
      final String body = message.notification?.body
          ?? message.data['body']
          ?? message.data['message']
          ?? '';
      final String? caseId = message.data['caseId'];

      // Deduplicate with Firestore listener: if we already showed for this doc, skip.
      final String? notifDocId = message.data['notifDocId'];
      if (notifDocId != null && notifDocId.isNotEmpty) {
        if (_shownNotificationIds.contains(notifDocId)) return;
        _shownNotificationIds.add(notifDocId);
      }

      // Show local popup for foreground FCM messages (role-based sound).
      // In background/terminated, Android shows the notification automatically.
      final tapToView = lookupAppLocalizations(CurrentAppLocale.current).tapToViewCase;
      showLocalPopup(
        title: title,
        body: body,
        payload: caseId,
        role: CurrentUserSession.role,
        tapToViewSuffix: tapToView,
      );
    });
  }

  static bool _openedListenerSetup = false;

  void _setupMessageOpenedListener() {
    if (_openedListenerSetup) return;
    _openedListenerSetup = true;
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification tapped: ${message.data}');
    });
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
  /// Shows a local popup when a new notification doc is added (so users see
  /// popups even if FCM is delayed or not sent). Deduplication with FCM via
  /// _shownNotificationIds so we do not show twice when both Firestore and FCM fire.
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

        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final docId = change.doc.id;
            if (_shownNotificationIds.contains(docId)) continue;
            _shownNotificationIds.add(docId);
            final data = change.doc.data() as Map<String, dynamic>? ?? {};
            final title = data['title'] as String? ?? 'Notification';
            final body = data['message'] as String? ?? data['body'] as String? ?? '';
            final caseId = data['caseId'] as String?;
            final role = data['recipientRole'] as String? ?? CurrentUserSession.role;
            final tapToView = lookupAppLocalizations(CurrentAppLocale.current).tapToViewCase;
            showLocalPopup(
              title: title,
              body: body,
              payload: caseId,
              role: role,
              tapToViewSuffix: tapToView,
            );
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


  /// Get localized strings for a user's preferred locale.
  Future<AppLocalizations> _l10nForUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final code = doc.data()?['preferredLocale'] as String? ?? 'en';
      return lookupAppLocalizations(Locale(code));
    } catch (_) {
      return lookupAppLocalizations(const Locale('en'));
    }
  }

  static String _urgencyLabel(String? u, AppLocalizations l10n) {
    switch (u?.toLowerCase()) {
      case 'critical': return l10n.critical;
      case 'high': return l10n.high;
      case 'medium': return l10n.moderate;
      case 'low': return l10n.low;
      default: return u ?? l10n.unknown;
    }
  }

  static String _emergencyTypeLabel(String? t, AppLocalizations l10n) {
    switch (t?.toLowerCase()) {
      case 'birth': return l10n.birth;
      case 'trauma': return l10n.trauma;
      case 'infection': return l10n.infection;
      case 'other': return l10n.other;
      default: return t ?? l10n.unknown;
    }
  }

  /// Create an in-app notification document in Firestore.
  Future<void> sendInAppNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? caseId,
    String? recipientRole,
  }) async {
    // Guard: never send to empty userId – would pollute shared queries
    if (userId.isEmpty) {
      debugPrint('sendInAppNotification skipped: userId is empty (type=$type)');
      return;
    }
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'read': false,
        if (caseId != null) 'caseId': caseId,
        if (recipientRole != null) 'recipientRole': recipientRole,
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
    final clinicianL10n = await _l10nForUser(clinicianId);
    final vhtL10n = await _l10nForUser(vhtId);
    final typeLabelC = _emergencyTypeLabel(emergencyType, clinicianL10n);
    final urgencyLabelC = _urgencyLabel(urgencyLevel, clinicianL10n);
    final typeLabelV = _emergencyTypeLabel(emergencyType, vhtL10n);

    if (clinicianId.isNotEmpty) {
      await sendInAppNotification(
        userId: clinicianId,
        title: clinicianL10n.notificationNewEmergencyCase,
        message: clinicianL10n.notificationNewEmergencyCaseMessage(typeLabelC, vhtName, patientName, urgencyLabelC),
        type: 'new_case',
        caseId: caseId,
        recipientRole: 'Clinician',
      );
    }

    if (vhtId.isNotEmpty) {
      await sendInAppNotification(
        userId: vhtId,
        title: vhtL10n.notificationCaseSubmittedSuccessfully,
        message: vhtL10n.notificationCaseSubmittedMessage(typeLabelV, patientName, clinicName),
        type: 'case_submitted',
        caseId: caseId,
        recipientRole: 'VHT',
      );
    }
  }

  Future<void> notifyClinicianOfVhtFollowUp({
    required String clinicianId,
    required String caseId,
    required String patientName,
    required String vhtName,
    required String followUpMessage,
  }) async {
    final l10n = await _l10nForUser(clinicianId);
    final shortMsg = followUpMessage.length > 80 ? '${followUpMessage.substring(0, 80)}...' : followUpMessage;
    if (clinicianId.isNotEmpty) {
      await sendInAppNotification(
        userId: clinicianId,
        title: l10n.notificationVhtFollowUpUpdate,
        message: l10n.notificationVhtFollowUpMessage(vhtName, patientName, shortMsg),
        type: 'vht_follow_up',
        caseId: caseId,
        recipientRole: 'Clinician',
      );
    }
  }

  Future<void> notifyCliniciansOfVhtFollowUp({
    required String facilityName,
    required String caseId,
    required String patientName,
    required String vhtName,
    required String followUpMessage,
    String? excludeUserId,
  }) async {
    final shortMsg = followUpMessage.length > 80 ? '${followUpMessage.substring(0, 80)}...' : followUpMessage;

    try {
      if (facilityName.trim().isEmpty) return;

      final cliniciansQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Clinic Staff')
          .where('workplace', isEqualTo: facilityName)
          .get();

      if (cliniciansQuery.docs.isEmpty) return;

      // Notify each clinician with their own locale preferences.
      await Future.wait(cliniciansQuery.docs.map((doc) async {
        final clinicianId = doc.id;
        if (clinicianId.isEmpty) return;
        if (excludeUserId != null && excludeUserId.isNotEmpty && clinicianId == excludeUserId) return;

        final l10n = await _l10nForUser(clinicianId);
        await sendInAppNotification(
          userId: clinicianId,
          title: l10n.notificationVhtFollowUpUpdate,
          message: l10n.notificationVhtFollowUpMessage(vhtName, patientName, shortMsg),
          type: 'vht_follow_up',
          caseId: caseId,
          recipientRole: 'Clinician',
        );
      }));
    } catch (e) {
      debugPrint('notifyCliniciansOfVhtFollowUp failed: $e');
    }
  }

  /// Clinician advises VHT → VHT gets popup + in-app.
  Future<void> notifyVhtOfClinicianAdvice({
    required String vhtId,
    required String caseId,
    required String patientName,
    required String clinicianName,
    required String advice,
  }) async {
    final l10n = await _l10nForUser(vhtId);
    final shortAdvice = advice.length > 80 ? '${advice.substring(0, 80)}...' : advice;
    if (vhtId.isNotEmpty) {
      await sendInAppNotification(
        userId: vhtId,
        title: l10n.notificationClinicianAdviceReceived,
        message: l10n.notificationClinicianAdviceMessage(clinicianName, patientName, shortAdvice),
        type: 'clinician_advice',
        caseId: caseId,
        recipientRole: 'VHT',
      );
    }
  }

  /// Clinician requests ambulance → nearest admin gets popup + in-app.
  /// ALL ambulance drivers also get a standby notification.
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

      // Identify the nearest admin when coordinates are available.
      List<String> targetAdminIds;

      if (adminsQuery.docs.isNotEmpty) {
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

        final adminFutures = targetAdminIds.map((adminId) async {
          final l10n = await _l10nForUser(adminId);
          final typeLabel = _emergencyTypeLabel(emergencyType, l10n);
          return sendInAppNotification(
            userId: adminId,
            title: l10n.notificationAmbulanceDispatchRequired,
            message: '${l10n.clinicianLabel} $clinicianName — $typeLabel. ${l10n.patientLabel}: $patientName.',
            type: 'dispatch_request',
            caseId: caseId,
            recipientRole: 'Admin',
          );
        });

        await Future.wait(adminFutures);
      }

      // Notify ALL ambulance drivers so they can be ready for dispatch
      try {
        final driversQuery = await _firestore
            .collection('users')
            .where('role', isEqualTo: 'Ambulance Driver')
            .get();

        final driverFutures = driversQuery.docs.map((driverDoc) async {
          final driverId = driverDoc.id;
          if (driverId.isEmpty) return;
          final l10n = await _l10nForUser(driverId);
          final typeLabel = _emergencyTypeLabel(emergencyType, l10n);
          await sendInAppNotification(
            userId: driverId,
            title: l10n.notificationAmbulanceRequestStandby,
            message: l10n.notificationAmbulanceRequestStandbyMessage(clinicianName, typeLabel, patientName),
            type: 'ambulance_request_standby',
            caseId: caseId,
            recipientRole: 'Ambulance Driver',
          );
        });

        await Future.wait(driverFutures);
      } catch (e) {
        debugPrint('Failed to notify drivers of ambulance request: $e');
      }
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
    final vhtL10n = await _l10nForUser(vhtId);
    final clinicianL10n = await _l10nForUser(clinicianId);
    final driverL10n = await _l10nForUser(driverId);
    final typeC = _emergencyTypeLabel(emergencyType, clinicianL10n);
    final typeD = _emergencyTypeLabel(emergencyType, driverL10n);

    if (vhtId.isNotEmpty) {
      await sendInAppNotification(
        userId: vhtId,
        title: vhtL10n.notificationAmbulanceOnTheWay,
        message: vhtL10n.notificationAmbulanceOnTheWayMessage(driverName, patientName),
        type: 'ambulance_dispatched',
        caseId: caseId,
        recipientRole: 'VHT',
      );
    }

    if (clinicianId.isNotEmpty) {
      await sendInAppNotification(
        userId: clinicianId,
        title: clinicianL10n.notificationAmbulanceDispatched,
        message: clinicianL10n.notificationAmbulanceDispatchedMessage(driverName, typeC, patientName),
        type: 'ambulance_dispatched',
        caseId: caseId,
        recipientRole: 'Clinician',
      );
    }

    if (driverId.isNotEmpty) {
      await sendInAppNotification(
        userId: driverId,
        title: driverL10n.notificationNewDispatchAssignment,
        message: driverL10n.notificationNewDispatchMessage(typeD, vhtName, clinicName, patientName),
        type: 'dispatch_assigned',
        caseId: caseId,
        recipientRole: 'Ambulance Driver',
      );
    }
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
    final vhtL10n = await _l10nForUser(vhtId);
    final clinicianL10n = await _l10nForUser(clinicianId);
    final typeV = _emergencyTypeLabel(emergencyType, vhtL10n);
    final typeC = _emergencyTypeLabel(emergencyType, clinicianL10n);

    if (vhtId.isNotEmpty) {
      await sendInAppNotification(
        userId: vhtId,
        title: vhtL10n.notificationPatientDelivered,
        message: vhtL10n.notificationPatientDeliveredMessage(patientName, typeV, clinicName, driverName),
        type: 'patient_delivered',
        caseId: caseId,
        recipientRole: 'VHT',
      );
    }

    try {
      final adminsQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Admin')
          .get();
      for (final adminDoc in adminsQuery.docs) {
        final l10n = await _l10nForUser(adminDoc.id);
        final typeLabel = _emergencyTypeLabel(emergencyType, l10n);
        await sendInAppNotification(
          userId: adminDoc.id,
          title: l10n.notificationPatientDelivered,
          message: l10n.notificationPatientDeliveredMessage(patientName, typeLabel, clinicName, driverName),
          type: 'patient_delivered',
          caseId: caseId,
          recipientRole: 'Admin',
        );
      }
    } catch (e) {
      debugPrint('Failed to fetch admins for delivery notification: $e');
    }

    // Notify clinician that patient is arriving (NOT the driver — driver already knows)
    if (clinicianId.isNotEmpty) {
      await sendInAppNotification(
        userId: clinicianId,
        title: clinicianL10n.notificationPatientArriving,
        message: clinicianL10n.notificationPatientArrivingMessage(patientName, typeC, driverName),
        type: 'patient_arriving',
        caseId: caseId,
        recipientRole: 'Clinician',
      );
    }
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
    final vhtL10n = await _l10nForUser(vhtId);
    final typeV = _emergencyTypeLabel(emergencyType, vhtL10n);

    if (vhtId.isNotEmpty) {
      await sendInAppNotification(
        userId: vhtId,
        title: vhtL10n.notificationPatientDischarged,
        message: vhtL10n.notificationPatientDischargedMessage(patientName, typeV, clinicName),
        type: 'patient_discharged',
        caseId: caseId,
        recipientRole: 'VHT',
      );
    }

    try {
      final adminsQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Admin')
          .get();
      for (final adminDoc in adminsQuery.docs) {
        final l10n = await _l10nForUser(adminDoc.id);
        final typeLabel = _emergencyTypeLabel(emergencyType, l10n);
        await sendInAppNotification(
          userId: adminDoc.id,
          title: l10n.notificationCaseCompleted,
          message: l10n.notificationCaseCompletedMessage(patientName, typeLabel, clinicName, clinicianName),
          type: 'case_completed',
          caseId: caseId,
          recipientRole: 'Admin',
        );
      }
    } catch (e) {
      debugPrint('Failed to fetch admins for discharge notification: $e');
    }
  }

  /// Clinician closes advice-path case → notify VHT (popup+inapp).
  Future<void> notifyOnCaseClosed({
    required String caseId,
    required String emergencyType,
    required String patientName,
    required String vhtId,
    required String clinicianName,
  }) async {
    final l10n = await _l10nForUser(vhtId);
    final typeLabel = _emergencyTypeLabel(emergencyType, l10n);
    if (vhtId.isNotEmpty) {
      await sendInAppNotification(
        userId: vhtId,
        title: l10n.notificationCaseClosed,
        message: l10n.notificationCaseClosedMessage(clinicianName, patientName, typeLabel),
        type: 'case_closed',
        caseId: caseId,
        recipientRole: 'VHT',
      );
    }
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
    final l10n = await _l10nForUser(clinicianId);
    final typeLabel = _emergencyTypeLabel(emergencyType, l10n);
    final urgencyLabel = _urgencyLabel(urgencyLevel, l10n);
    final message = l10n.notificationNewEmergencyCaseMessage(typeLabel, vhtName, patientName, urgencyLabel);
    await sendInAppNotification(
      userId: clinicianId,
      title: l10n.notificationNewEmergencyCase,
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
    final l10n = await _l10nForUser(userId);
    final typeLabel = _emergencyTypeLabel(emergencyType, l10n);
    final message = l10n.notificationAmbulanceDispatchedMessage('…', typeLabel, patientName);
    await sendInAppNotification(
      userId: userId,
      title: l10n.notificationAmbulanceDispatched,
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
    final l10n = await _l10nForUser(vhtId);
    await sendInAppNotification(
      userId: vhtId,
      title: l10n.currentStatus,
      message: l10n.statusUpdatedTo(status),
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
    final l10n = await _l10nForUser(driverId);
    final typeLabel = _emergencyTypeLabel(emergencyType, l10n);
    final message = l10n.notificationNewDispatchMessage(typeLabel, '…', clinicName, patientName);
    await sendInAppNotification(
      userId: driverId,
      title: l10n.notificationNewDispatchAssignment,
      message: message,
      type: 'dispatch',
      caseId: caseId,
    );
  }
}
