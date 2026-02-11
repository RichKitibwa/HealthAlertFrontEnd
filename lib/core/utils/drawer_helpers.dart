import 'package:flutter/material.dart';
import '../../features/common/presentation/screens/settings_screen.dart';
import '../../features/common/presentation/screens/notifications_screen.dart';
import '../../features/common/presentation/screens/learning_resources_screen.dart';
import '../../features/common/presentation/widgets/app_drawer.dart';
import '../../features/auth/current_user_session.dart';
import 'logout_utils.dart';

/// Builds a standard AppDrawer with properly wired callbacks for Settings,
/// Notifications, Learning Resources, and Logout. Use this from any screen
/// that has the hamburger menu / endDrawer.
///
/// [context] - the BuildContext of the screen
/// [dashboardRoute] - the named route for the current user's dashboard
///   (e.g. '/vht-dashboard', '/clinic-dashboard', etc.)
/// [onReports] - optional admin-only reports callback
/// [onAnalytics] - optional admin-only analytics callback
AppDrawer buildStandardDrawer({
  required BuildContext context,
  required String dashboardRoute,
  VoidCallback? onReports,
  VoidCallback? onAnalytics,
}) {
  return AppDrawer(
    onDashboard: () {
      Navigator.pushNamedAndRemoveUntil(context, dashboardRoute, (r) => false);
    },
    onNotifications: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      );
    },
    onSettings: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    },
    onLearningResources: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LearningResourcesScreen()),
      );
    },
    onReports: onReports,
    onAnalytics: onAnalytics,
    onLogout: () async {
      await LogoutUtils.logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
      }
    },
  );
}

/// Returns the dashboard route for the current user based on their role.
String getDashboardRouteForCurrentUser() {
  final role = (CurrentUserSession.role ?? '').toLowerCase();
  switch (role) {
    case 'vht':
    case 'village health team':
      return '/vht-dashboard';
    case 'clinic':
    case 'clinician':
      return '/clinic-dashboard';
    case 'ambulance':
    case 'ambulance driver':
    case 'driver':
      return '/ambulance-dashboard';
    case 'admin':
    case 'administrator':
      return '/admin-dashboard';
    default:
      return '/login';
  }
}
