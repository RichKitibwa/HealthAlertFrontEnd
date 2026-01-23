import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage device-local storage for user registration tracking
class DeviceStorageService {
  static const String _registeredUserKey = 'registered_user_data';
  static const String _registeredPhoneKey = 'registered_phone';
  static const String _registeredNameKey = 'registered_name';

  /// Save user registration data to device
  static Future<void> saveRegisteredUser({
    required String phoneNumber,
    required String firstName,
    required String lastName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_registeredPhoneKey, phoneNumber);
    await prefs.setString(_registeredNameKey, '$firstName $lastName'.trim());
    await prefs.setBool(_registeredUserKey, true);
  }

  /// Check if user is registered on this device
  static Future<bool> isUserRegisteredOnDevice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_registeredUserKey) ?? false;
  }

  /// Get registered user's phone number
  static Future<String?> getRegisteredPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_registeredPhoneKey);
  }

  /// Get registered user's name
  static Future<String?> getRegisteredName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_registeredNameKey);
  }

  /// Clear registered user data (for logout or re-registration)
  static Future<void> clearRegisteredUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_registeredPhoneKey);
    await prefs.remove(_registeredNameKey);
    await prefs.remove(_registeredUserKey);
  }

  /// Get all registered user data
  static Future<Map<String, String?>> getRegisteredUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'phoneNumber': prefs.getString(_registeredPhoneKey),
      'name': prefs.getString(_registeredNameKey),
    };
  }
}
