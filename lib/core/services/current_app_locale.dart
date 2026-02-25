import 'package:flutter/material.dart';

/// Holds the app's current locale for use in services that don't have BuildContext

class CurrentAppLocale {
  CurrentAppLocale._();

  static Locale? _current;

  /// Current locale, or English if not yet set.
  static Locale get current => _current ?? const Locale('en');

  /// Set by the app root (e.g. MaterialApp's Consumer) when locale is known.
  static set current(Locale? value) {
    _current = value;
  }
}
