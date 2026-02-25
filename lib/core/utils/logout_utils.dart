import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../features/auth/current_user_session.dart';
import '../services/fcm_notification_service.dart';

/// Utility class for handling user logout
class LogoutUtils {
  /// Performs logout:
  /// 1. Signs out from Firebase Auth
  /// 2. Stops notification listener to prevent stale popup delivery
  /// 3. Clears in-memory session
  /// Note: Device storage is NOT cleared so user can log back in with PIN.
  /// Language preference is stored per user (key: preferred_language_<userId));
  /// the next user to sign in on this device will get their own saved locale.
  static Future<void> logout() async {
    // Stop notification listener to prevent stale notifications after logout
    FCMNotificationService().stopNotificationListener();

    try {
      // Sign out from Firebase Auth
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      // Continue even if sign out fails
      debugPrint('Error signing out from Firebase: $e');
    }
    
    // Clear in-memory session
    CurrentUserSession.clear();
    
    // Device storage is kept so user can log back in with PIN
  }
}
