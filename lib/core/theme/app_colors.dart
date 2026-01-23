import 'package:flutter/material.dart';

/// Medical Healthcare Color Theme
/// Based on medical/healthcare design principles and Material Design 3
/// Colors are chosen to evoke trust, calmness, and professionalism
/// Red is reserved only for errors and danger alerts

class AppColors {
  // Primary Colors - Teal/Cyan (Medical Trust)
  // Based on Apollo Hospitals design: teal/dark cyan for trust and professionalism
  static const Color primary = Color(0xFF008B8B); // Dark Cyan/Teal - Primary brand color
  static const Color primaryLight = Color(0xFF40C4C4); // Lighter teal for hover states
  static const Color primaryDark = Color(0xFF006666); // Darker teal for emphasis
  static const Color primaryContainer = Color(0xFFB2EBEB); // Very light teal for backgrounds
  
  // Secondary Colors - Blue (Calm and Professional)
  static const Color secondary = Color(0xFF4C8FD1); // Serene Blue
  static const Color secondaryLight = Color(0xFF7DB3E3); // Light blue
  static const Color secondaryDark = Color(0xFF2E6BA8); // Dark blue
  static const Color secondaryContainer = Color(0xFFE3F2FD); // Very light blue for backgrounds
  
  // Accent Colors - Yellow/Amber (Action and Energy)
  static const Color accent = Color(0xFFFFB300); // Amber/Yellow for CTAs
  static const Color accentLight = Color(0xFFFFD54F); // Light amber
  static const Color accentDark = Color(0xFFFF8F00); // Dark amber
  
  // Semantic Colors
  static const Color success = Color(0xFF4CAF50); // Material Green
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  
  static const Color error = Color(0xFFD32F2F); // Material Red - ONLY for errors/danger
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFC62828);
  
  static const Color warning = Color(0xFFFF9800); // Material Orange
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);
  
  static const Color info = Color(0xFF2196F3); // Material Blue
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);
  
  // Medical Accent Colors (from healthcare design research)
  static const Color healingGreen = Color(0xFF8CC63F);
  static const Color caringPink = Color(0xFFFF7CAC);
  static const Color tranquilGray = Color(0xFFA7A9AC);
  
  // Neutral Colors
  static const Color background = Color(0xFFFBFCFD); // Very light gray/blue background
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Light gray surface
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A); // Almost black
  static const Color textSecondary = Color(0xFF475467); // Medium gray
  static const Color textTertiary = Color(0xFF98A2B3); // Light gray
  static const Color textDisabled = Color(0xFFD0D5DD); // Very light gray
  
  // Border and Divider Colors
  static const Color border = Color(0xFFE3E8EF); // Light gray border
  static const Color divider = Color(0xFFE5E7EB); // Divider color
  
  // Status Colors (for case/emergency status)
  static const Color statusPending = Color(0xFFFFB300); // Amber
  static const Color statusInProgress = Color(0xFF2196F3); // Blue
  static const Color statusCompleted = Color(0xFF4CAF50); // Green
  static const Color statusCancelled = Color(0xFF757575); // Gray
  
  // Urgency Level Colors
  static const Color urgencyCritical = Color(0xFFD32F2F); // Red - only for critical
  static const Color urgencyHigh = Color(0xFFFF9800); // Orange
  static const Color urgencyMedium = Color(0xFFFFB300); // Amber
  static const Color urgencyLow = Color(0xFF4CAF50); // Green
  
  // Role-specific Accent Colors (optional, for visual distinction)
  static const Color vhtAccent = Color(0xFF008B8B); // Teal
  static const Color ambulanceAccent = Color(0xFF4C8FD1); // Blue
  static const Color clinicAccent = Color(0xFF4C8FD1); // Blue
  static const Color adminAccent = Color(0xFF6C757D); // Gray
  
  // Network/Status Indicators
  static const Color online = Color(0xFF4CAF50); // Green
  static const Color offline = Color(0xFF757575); // Gray
  
  // Material Design 3 Color Scheme
  static ColorScheme get lightColorScheme => ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryContainer,
        onPrimaryContainer: primaryDark,
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
