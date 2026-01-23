import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

/// Medical fonts configuration for the Health Alert app
/// Uses professional, readable fonts suitable for healthcare applications
/// Uses system fonts (Roboto on Android, San Francisco on iOS) for reliability
class AppFonts {
  // Get platform-appropriate font family
  static String get _fontFamily {
    // Roboto is the default on Android and is excellent for medical apps
    // San Francisco is the default on iOS
    // Both are professional and highly readable
    if (defaultTargetPlatform == TargetPlatform.iOS || 
        defaultTargetPlatform == TargetPlatform.macOS) {
      return '.SF Pro Text';
    }
    // Default to Roboto for Android and other platforms
    return 'Roboto';
  }
  
  // Primary font - Clean, professional, highly readable
  static TextStyle get primary => TextStyle(fontFamily: _fontFamily);
  
  // Bold variant
  static TextStyle get primaryBold => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.bold,
  );
  
  // Semi-bold variant
  static TextStyle get primarySemiBold => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
  );
  
  // Light variant
  static TextStyle get primaryLight => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w300,
  );
  
  // Secondary font - Same as primary but can be customized
  static TextStyle get secondary => TextStyle(fontFamily: _fontFamily);
  
  // Bold variant
  static TextStyle get secondaryBold => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.bold,
  );
  
  // Display font - For headings and important text
  static TextStyle get display => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
  );
  
  // Bold variant
  static TextStyle get displayBold => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.bold,
  );
  
  // Medical/Technical font - Excellent for data and technical content
  static TextStyle get technical => TextStyle(fontFamily: _fontFamily);
  
  // Bold variant
  static TextStyle get technicalBold => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.bold,
  );
  
  // Monospace font for codes, IDs, etc.
  static TextStyle get monospace {
    if (defaultTargetPlatform == TargetPlatform.iOS || 
        defaultTargetPlatform == TargetPlatform.macOS) {
      return const TextStyle(fontFamily: 'Menlo');
    }
    return const TextStyle(fontFamily: 'monospace');
  }
  
  // Headings style
  static TextStyle heading({double? fontSize, Color? color}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize ?? 24,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }
  
  // Body text style
  static TextStyle body({double? fontSize, Color? color}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize ?? 16,
      color: color,
    );
  }
  
  // Button text style
  static TextStyle button({double? fontSize, Color? color}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize ?? 18,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }
  
  // Label style
  static TextStyle label({double? fontSize, Color? color}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize ?? 14,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }
}

/// Theme data with medical fonts
class AppFontTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: TextTheme(
        displayLarge: AppFonts.heading(fontSize: 32),
        displayMedium: AppFonts.heading(fontSize: 28),
        displaySmall: AppFonts.heading(fontSize: 24),
        headlineLarge: AppFonts.heading(fontSize: 22),
        headlineMedium: AppFonts.heading(fontSize: 20),
        headlineSmall: AppFonts.heading(fontSize: 18),
        titleLarge: AppFonts.primaryBold.copyWith(fontSize: 20),
        titleMedium: AppFonts.primarySemiBold.copyWith(fontSize: 18),
        titleSmall: AppFonts.primarySemiBold.copyWith(fontSize: 16),
        bodyLarge: AppFonts.body(fontSize: 18),
        bodyMedium: AppFonts.body(fontSize: 16),
        bodySmall: AppFonts.body(fontSize: 14),
        labelLarge: AppFonts.label(fontSize: 16),
        labelMedium: AppFonts.label(fontSize: 14),
        labelSmall: AppFonts.label(fontSize: 12),
      ),
    );
  }
}
