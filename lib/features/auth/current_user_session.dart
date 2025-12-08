import 'package:flutter/foundation.dart';

/// Simple in-memory session holder for the currently signed-in user.
///
/// This is populated after successful OTP verification / Firebase sign-in,
/// and can be read throughout the app (e.g., by nav bars, dashboards, etc.).
///
/// Example usage in OTP verification:
///
///   final data = userDoc.data();
///   CurrentUserSession.uid = uid;
///   CurrentUserSession.role = data?['role'];
///   CurrentUserSession.phoneNumber = data?['phoneNumber'];
///
/// Example usage in a screen:
///
///   appBar: TopNavigationBar(
///     role: CurrentUserSession.role ?? 'VHT',
///     profileImageUrl: CurrentUserSession.profileImageUrl,
///     onSignOut: () { ... },
///   ),
class CurrentUserSession {
  /// Firebase Auth UID of the current user.
  static String? uid;

  /// Role string from Firestore, e.g. "VHT", "Ambulance Driver",
  /// "Clinic Staff", "Admin".
  static String? role;

  /// First name of the user (if stored in Firestore).
  static String? firstName;

  /// Last name of the user (if stored in Firestore).
  static String? lastName;

  /// Phone number used for Firebase phone auth.
  static String? phoneNumber;

  /// Optional URL to a profile photo (e.g., in Firebase Storage).
  static String? profileImageUrl;

  /// Convenience getter: true if a user is currently "logged in" in memory.
  static bool get isLoggedIn => uid != null;

  /// Clears the in-memory session (e.g., on sign-out).
  static void clear() {
    if (kDebugMode) {
      debugPrint('CurrentUserSession: clearing session');
    }
    uid = null;
    role = null;
    firstName = null;
    lastName = null;
    phoneNumber = null;
    profileImageUrl = null;
  }
}
