import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/current_user_session.dart';

/// Utility class for handling user logout
class LogoutUtils {
  /// Performs logout:
  /// 1. Signs out from Firebase Auth
  /// 2. Clears in-memory session
  /// Note: Device storage is NOT cleared so user can log back in with PIN
  static Future<void> logout() async {
    try {
      // Sign out from Firebase Auth
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      // Continue even if sign out fails
      print('Error signing out from Firebase: $e');
    }
    
    // Clear in-memory session
    CurrentUserSession.clear();
    
    // Device storage is kept so user can log back in with PIN
  }
}
