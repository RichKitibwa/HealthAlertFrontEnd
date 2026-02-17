import 'package:flutter/material.dart';
import '../../features/common/presentation/screens/settings_screen.dart';
import '../../features/common/presentation/screens/notifications_screen.dart';
import '../../features/common/presentation/screens/learning_resources_screen.dart';
import '../../features/common/presentation/widgets/app_drawer.dart';
import '../../features/auth/current_user_session.dart';
import '../../features/admin/presentation/screens/admin_case_analytics.dart';
import '../../features/admin/utils/admin_reports_export.dart';
import 'logout_utils.dart';

/// Builds a standard AppDrawer with properly wired callbacks for Settings,
/// Notifications, Learning Resources, and Logout. U

AppDrawer buildStandardDrawer({
  required BuildContext context,
  required String dashboardRoute,
  VoidCallback? onReports,
  VoidCallback? onAnalytics,
}) {
  final role = (CurrentUserSession.role ?? '').toLowerCase();
  final isAdmin = role == 'admin';

  // Default handlers for admin Reports and Analytics
  VoidCallback? reportsHandler = onReports;
  VoidCallback? analyticsHandler = onAnalytics;

  if (isAdmin) {
    // If admin and no custom handler provided, use default navigation
    if (analyticsHandler == null) {
      analyticsHandler = () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminCaseAnalyticsScreen()),
        );
      };
    }
    // Reports: same as Export Reports (PDF export)
    if (reportsHandler == null) {
      reportsHandler = () {
        exportReportsPdf(context);
      };
    }
  }

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
    onReports: reportsHandler,
    onAnalytics: analyticsHandler,
    onLogout: () async {
      await LogoutUtils.logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
