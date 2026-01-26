import 'package:flutter/material.dart';

/// Medical Healthcare Color Theme

class AppColors {
  // Primary Colors - Teal/Cyan (Medical Trust)
  static const Color primary = Color(
    0xFF0A8F8C,
  ); // Deep teal-blue - Primary brand color
  static const Color primaryLight = Color(
    0xFF5FBFB8,
  ); // Softened teal for hover/active states
  static const Color primaryDark = Color(
    0xFF006D6A,
  ); // Deeper teal for emphasis
  static const Color primaryContainer = Color(
    0xFFCDEDEA,
  ); // Soft mint for subtle backgrounds

  // Secondary Colors - Blue
  static const Color secondary = Color(
    0xFF2E6BA8,
  ); // Trustworthy blue - secondary brand color
  static const Color secondaryLight = Color(
    0xFFDCEEEF,
  ); // Mist blue - soft accents
  static const Color secondaryDark = Color(
    0xFF1F4E7A,
  ); // Deep blue for emphasis
  static const Color secondaryContainer = Color(
    0xFFDCEEEF,
  ); // Mist blue container

  // Accent Colors - Yellow/Amber
  static const Color accent = Color(0xFF0A8F8C);
  static const Color accentLight = Color(0xFFCDEDEA);
  static const Color accentDark = Color(0xFF006D6A);

  // Semantic Colors
  static const Color success = Color(0xFF6BBF9C);
  static const Color successLight = Color(0xFFEFF7F3);
  static const Color successDark = Color(0xFF2F8F6A);

  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFC62828);

  static const Color warning = Color(
    0xFFF4B400,
  ); // Softer amber (use sparingly)
  static const Color warningLight = Color(0xFFFFF2CC); // Very light amber
  static const Color warningDark = Color(0xFFB68400); // Deep amber

  static const Color info = Color(0xFF2E6BA8); // Match secondary blue
  static const Color infoLight = Color(0xFFDCEEEF); // Mist blue
  static const Color infoDark = Color(0xFF1F4E7A); // Deep blue

  // Medical Accent Colors
  static const Color healingGreen = Color(0xFF6BBF9C); // Calm sage green
  static const Color caringPink = Color(0xFFF2D7E6);
  static const Color tranquilGray = Color(0xFF6E7C7C); // Muted slate gray

  // Neutral Colors
  static const Color background = Color(0xFFFFFFFF); // True white background
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF7FBFA);

  // Text Colors
  static const Color textPrimary = Color(0xFF1C1C1E); // Near-black
  static const Color textSecondary = Color(0xFF6E7C7C); // Muted slate gray
  static const Color textTertiary = Color(0xFF9E9EA3); // Muted light gray
  static const Color textDisabled = Color(0xFFD0D5DD); // Very light gray

  // Border and Divider Colors
  static const Color border = Color(0xFFE3E8E8); // Light silver gray border
  static const Color divider = Color(
    0xFFE3E8E8,
  ); // Keep dividers subtle and consistent

  // Status Colors (for case/emergency status)
  static const Color statusPending = Color(0xFFFFB300); // Amber
  static const Color statusInProgress = Color(0xFF2196F3); // Blue
  static const Color statusCompleted = Color(0xFF4CAF50); // Green
  static const Color statusCancelled = Color(0xFF757575); // Gray

  // Urgency Level Colors
  static const Color urgencyCritical = Color(
    0xFFD32F2F,
  ); // Red - only for critical
  static const Color urgencyHigh = Color(0xFFFF9800); // Orange
  static const Color urgencyMedium = Color(0xFFFFB300); // Amber
  static const Color urgencyLow = Color(0xFF4CAF50); // Green

  // Role-specific Accent Colors (distinct, calming)
  static const Color vhtAccent = Color(0xFF0A8F8C); // Teal (VHT)
  static const Color clinicAccent = Color(0xFF2E6BA8); // Blue (Clinic)
  static const Color ambulanceAccent = Color(
    0xFF6BBF9C,
  ); // Sage green (Ambulance)
  static const Color adminAccent = Color(0xFF5C6B73); // Slate gray (Admin)

  // Network/Status Indicators
  static const Color online = success;
  static const Color offline = Color(0xFF8A9494);

  // Material Design 3 Color Scheme
  static ColorScheme get lightColorScheme => ColorScheme.light(
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: primaryContainer,
    onPrimaryContainer: textPrimary,
    secondary: secondary,
    onSecondary: Colors.white,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: secondaryDark,
    tertiary: accent,
    onTertiary: Colors.white,
    error: error,
    onError: Colors.white,
    errorContainer: errorLight.withOpacity(0.2),
    onErrorContainer: errorDark,
    surface: surface,
    background: background,
    onBackground: textPrimary,
    onSurface: textPrimary,
    surfaceVariant: surfaceVariant,
    onSurfaceVariant: textSecondary,
    outline: border,
    outlineVariant: divider,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: textPrimary,
    onInverseSurface: Colors.white,
    inversePrimary: primaryLight,
  );
}
