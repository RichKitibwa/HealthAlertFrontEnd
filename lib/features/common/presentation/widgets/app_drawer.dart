// App Drawer Widget
// Reusable drawer menu for all user roles

import 'package:flutter/material.dart';
import '../../../auth/current_user_session.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback? onDashboard;
  final VoidCallback? onNotifications;
  final VoidCallback? onSettings;
  final VoidCallback? onReports;
  final VoidCallback? onAnalytics;
  final VoidCallback? onLearningResources;
  final VoidCallback onLogout;

  const AppDrawer({
    Key? key,
    this.onDashboard,
    this.onNotifications,
    this.onSettings,
    this.onReports,
    this.onAnalytics,
    this.onLearningResources,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final role = CurrentUserSession.role?.toLowerCase() ?? '';
    final bool isAdmin = role == 'admin';
    final bool isVHT = role == 'vht' || role == 'village health team';
    final bool isClinician = role == 'clinic' || role == 'clinician';
    final bool showLearningResources = isVHT || isClinician;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            if (onDashboard != null)
              ListTile(
                leading: const Icon(Icons.dashboard, color: Color(0xFF1A1A1A)),
                title: const Text('Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                  onDashboard!();
                },
              ),
            if (onNotifications != null)
              ListTile(
                leading: const Icon(Icons.notifications_outlined, color: Color(0xFF1A1A1A)),
                title: const Text('Notifications'),
                onTap: () {
                  Navigator.pop(context);
                  onNotifications!();
                },
              ),
            if (onSettings != null)
              ListTile(
                leading: const Icon(Icons.settings, color: Color(0xFF1A1A1A)),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  onSettings!();
                },
              ),
            if (showLearningResources && onLearningResources != null)
              ListTile(
                leading: const Icon(Icons.school, color: Color(0xFF1A1A1A)),
                title: const Text('Learning Resources'),
                onTap: () {
                  Navigator.pop(context);
                  onLearningResources!();
                },
              ),
            if (isAdmin && onReports != null)
              ListTile(
                leading: const Icon(Icons.assessment, color: Color(0xFF1A1A1A)),
                title: const Text('Reports'),
                onTap: () {
                  Navigator.pop(context);
                  onReports!();
                },
              ),
            if (isAdmin && onAnalytics != null)
              ListTile(
                leading: const Icon(Icons.analytics, color: Color(0xFF1A1A1A)),
                title: const Text('Analytics'),
                onTap: () {
                  Navigator.pop(context);
                  onAnalytics!();
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                onLogout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
