import 'package:flutter/material.dart';
import 'vht_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/widgets/app_drawer.dart';
import '../../../auth/current_user_session.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';
// VHT Dashboard Screen
// Main dashboard for Village Health Team members with emergency reporting

class VHTDashboardScreen extends StatefulWidget {
  const VHTDashboardScreen({Key? key}) : super(key: key);

  @override
  State<VHTDashboardScreen> createState() => _VHTDashboardScreenState();
}

class _VHTDashboardScreenState extends State<VHTDashboardScreen> {
  int _currentIndex = 0; // 0 = Home, 1 = Map, 2 = Patients

  void _onNavItemSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Handle navigation between tabs/routes as needed
    // For now, this keeps you on the dashboard and just updates the selected tab.
    // Later you can add:
    // if (index == 1) Navigator.pushNamed(context, '/vht-map');
    // if (index == 2) Navigator.pushNamed(context, '/vht-patients');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'VHT',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        onSignOut: () async {
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        },
        onDashboard: () {
          // Already on dashboard, do nothing or refresh
        },
        onSettings: () {
          // TODO: Navigate to settings screen
        },
        onLearningResources: () {
          // TODO: Navigate to learning resources screen (offline-first)
        },
      ),
      endDrawer: AppDrawer(
        onDashboard: () {
          // Already on dashboard
        },
        onSettings: () {
          // TODO: Navigate to settings screen
        },
        onLearningResources: () {
          // TODO: Navigate to learning resources screen
        },
        onLogout: () async {
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        },
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Welcome message below navbar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Welcome, ${CurrentUserSession.firstName ?? 'User'}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                ),
                // Scrollable main content
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Status card: Network / Battery
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(10),
                                  blurRadius: 16,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.wifi,
                                      size: 18,
                                      color: AppColors.vhtAccent,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Network: Online',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.battery_full,
                                      size: 18,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Battery: Good',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Report Emergency primary action
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/create-emergency',
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.vhtAccent,
                                side: BorderSide(
                                  color: AppColors.vhtAccent,
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppColors.vhtAccent,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Report Emergency',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Quick Actions header
                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 📄 View Case History
                          Card(
                            elevation: 0,
                            color: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: AppColors.border.withValues(alpha: 0.8),
                              ),
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.description_outlined,
                                color: AppColors.clinicAccent,
                              ),
                              title: Text(
                                'View Case History',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                // TODO: Navigate to case history
                              },
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 📝 Send Follow-up Update
                          Card(
                            elevation: 0,
                            color: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: AppColors.border.withValues(alpha: 0.8),
                              ),
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.edit_note_outlined,
                                color: AppColors.vhtAccent,
                              ),
                              title: Text(
                                'Send Follow-up Update',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                // TODO: Navigate to follow-up update
                              },
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ⚙️ Settings
                          Card(
                            elevation: 0,
                            color: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: AppColors.border.withValues(alpha: 0.8),
                              ),
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.settings_outlined,
                                color: AppColors.adminAccent,
                              ),
                              title: Text(
                                'Settings',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                // TODO: Navigate to settings
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),

                // Fixed Bottom Nav Bar (Home / Map / Patients)
                VhtNavigationBar(
                  currentIndex: _currentIndex,
                  onItemSelected: _onNavItemSelected,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
