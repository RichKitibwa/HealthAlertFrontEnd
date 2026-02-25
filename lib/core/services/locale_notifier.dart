import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the app's locale and persists it per logged-in user.
///
/// Language is stored per account: key format `preferred_language_<userId>`.
/// When a different user signs in on the same device, [loadAndApplyLocaleForUser]
/// loads that user's saved preference only; the previous user's preference
/// remains stored and is restored if they sign in again.
/// Fallback (no user): `preferred_language`.
class LocaleNotifier extends ChangeNotifier {
  LocaleNotifier({String? initialLocaleCode}) {
    if (initialLocaleCode != null && initialLocaleCode.isNotEmpty) {
      _locale = Locale(initialLocaleCode);
    }
  }

  static const String _globalKey = 'preferred_language';

  Locale? _locale;
  Locale? get locale => _locale;

  // ── Helpers ──────────────────────────────────────────────────────────────

  static String _keyForUser(String? userId) {
    if (userId == null || userId.isEmpty) return _globalKey;
    return '${_globalKey}_$userId';
  }

  // ── Static loaders ────────────────────────────────────────────────────────

  /// Load the saved locale code for a specific user (or the global key if
  /// [userId] is null/empty).  Falls back to `null` when nothing is saved.
  static Future<String?> loadLocaleCodeForUser(String? userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keyForUser(userId);
      return prefs.getString(key);
    } catch (_) {
      return null;
    }
  }

  /// Legacy loader used at cold-start before the user identity is known.
  /// Reads the global (non-user-specific) key only.
  static Future<String?> loadSavedLocaleCode() async {
    return loadLocaleCodeForUser(null);
  }

  // ── Instance mutators ─────────────────────────────────────────────────────

  /// Set the locale for the given [userId] and persist it.
  /// Pass `null` / empty [userId] to save against the global fallback key.
  Future<void> setLocaleForUser(String? userId, String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyForUser(userId), languageCode);
      _locale = Locale(languageCode);
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  /// Convenience wrapper that saves against the global key.
  /// Kept for backward-compatibility with any call sites not yet updated.
  Future<void> setLocale(String languageCode) async {
    return setLocaleForUser(null, languageCode);
  }

  /// Switch to the saved locale for [userId].  If no preference is saved,
  /// keeps the current locale unchanged (or defaults to English).
  Future<void> loadAndApplyLocaleForUser(String? userId) async {
    final code = await loadLocaleCodeForUser(userId);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
      notifyListeners();
    }
  }
}
