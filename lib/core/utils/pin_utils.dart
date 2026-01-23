import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Utility class for PIN hashing and verification
class PinUtils {
  /// Hash a PIN using SHA-256
  /// In production, consider using bcrypt or Argon2 for better security
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify a PIN against a hashed PIN
  static bool verifyPin(String pin, String hashedPin) {
    final hashedInput = hashPin(pin);
    return hashedInput == hashedPin;
  }

  /// Validate PIN format (4-6 digits)
  static bool isValidPinFormat(String pin) {
    final regex = RegExp(r'^\d{4,6}$');
    return regex.hasMatch(pin);
  }
}
