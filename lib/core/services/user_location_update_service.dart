// Updates the current user's location and lastActive in Firestore.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/location_utils.dart';
import '../../features/auth/current_user_session.dart';

class UserLocationUpdateService {
  static Timer? _timer;
  static const Duration _interval = Duration(seconds: 30);

  static void startUpdating() {
    stopUpdating();
    void update() => _updateLocationAndLastActive();
    update(); // run once immediately
    _timer = Timer.periodic(_interval, (_) => update());
  }

  static void stopUpdating() {
    _timer?.cancel();
    _timer = null;
  }

  static Future<void> _updateLocationAndLastActive() async {
    final uid = CurrentUserSession.uid;
    if (uid == null || uid.isEmpty) return;

    try {
      final result = await LocationUtils.getCurrentLocationWithDetails();
      final updates = <String, dynamic>{
        'lastActive': FieldValue.serverTimestamp(),
      };
      if (result.success && result.position != null) {
        updates['latitude'] = result.position!.latitude;
        updates['longitude'] = result.position!.longitude;
        updates['lastLocationUpdatedAt'] = FieldValue.serverTimestamp();
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).update(updates);
    } catch (e) {
      debugPrint('UserLocationUpdateService: $e');
    }
  }

  static Future<void> updateLastActiveOnce() async {
    final uid = CurrentUserSession.uid;
    if (uid == null || uid.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('UserLocationUpdateService updateLastActive: $e');
    }
  }
}
