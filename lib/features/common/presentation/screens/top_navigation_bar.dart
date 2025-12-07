import 'package:flutter/material.dart';

/// Global top navigation bar used across all role-based dashboards (VHT,
/// Ambulance, Clinic, Admin).

class TopNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  /// Role identifier, e.g. "vht", "ambulance", "clinic", "admin".
  final String role;

  /// Optional profile image URL for the logged-in user (per role).
  /// If null, a CircleAvatar with the role initial will be shown instead.
  final String? profileImageUrl;

  /// Called when the sign-out button is pressed.
  final VoidCallback onSignOut;

  /// Whether to show a back button on the left.
  /// Useful for non-dashboard screens (detail pages, forms, etc.).
  final bool showBackButton;

  /// Optional callback when the back button is pressed.
  /// If null and [showBackButton] is true, Navigator.pop will be used.
  final VoidCallback? onBack;

  const TopNavigationBar({
    super.key,
    required this.role,
    required this.onSignOut,
    this.profileImageUrl,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = _backgroundColorForRole(role);
    final String roleLabel = _roleDisplayName(role);

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: onBack ?? () => Navigator.pop(context),
            )
          : null,
      titleSpacing: showBackButton ? 0 : 16,
      title: Row(
        children: [
          _buildAvatar(roleLabel),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$roleLabel Dashboard',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          color: Colors.white,
          tooltip: 'Sign out',
          onPressed: onSignOut,
        ),
      ],
    );
  }

  /// Builds the profile avatar; uses [profileImageUrl] if provided, otherwise
  /// falls back to the first letter of the role.
  Widget _buildAvatar(String roleLabel) {
    final String initial = roleLabel.isNotEmpty
        ? roleLabel.characters.first.toUpperCase()
        : '?';

    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(profileImageUrl!),
      );
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.white,
      child: Text(
        initial,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }
}

/// Maps a loose role string to a display label.

/// This lets you pass "vht", "VHT", "vHt", etc. and always get "VHT".
String _roleDisplayName(String role) {
  final normalized = role.trim().toLowerCase();
  switch (normalized) {
    case 'vht':
    case 'village health team':
      return 'VHT';
    case 'ambulance':
    case 'driver':
      return 'Ambulance';
    case 'clinic':
    case 'clinician':
      return 'Clinic';
    case 'admin':
    case 'administrator':
      return 'Admin';
    default:
      // Fallback to capitalizing the raw role string.
      if (role.isEmpty) return 'User';
      return role[0].toUpperCase() + role.substring(1);
  }
}

/// Returns a background color based on the role.

Color _backgroundColorForRole(String role) {
  final normalized = role.trim().toLowerCase();
  switch (normalized) {
    case 'vht':
    case 'village health team':
      // Teal / green for VHT
      return const Color(0xFF0F766E);
    case 'ambulance':
    case 'driver':
      // Red for ambulance / emergency
      return const Color(0xFFB91C1C);
    case 'clinic':
    case 'clinician':
      // Blue for clinic
      return const Color(0xFF1D4ED8);
    case 'admin':
    case 'administrator':
      // Purple for admin / oversight
      return const Color(0xFF7C3AED);
    default:
      // Neutral teal-ish default
      return const Color(0xFF0F766E);
  }
}
