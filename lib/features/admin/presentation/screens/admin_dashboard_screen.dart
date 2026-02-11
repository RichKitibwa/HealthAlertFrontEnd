import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_navigation_bar.dart';
import 'admin_case_analytics.dart';
import 'admin_manage_users_screen.dart';
import 'admin_case_timeline.dart';
import '../../../common/presentation/screens/notifications_screen.dart';
import '../../../common/presentation/screens/settings_screen.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/widgets/app_drawer.dart';
import '../../../auth/current_user_session.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';

// Admin Dashboard Screen
// Main dashboard for administrators and NGOs

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0; // 0 = Home, 1 = Notifications, 2 = Analytics, 3 = Users

  void _onNavItemSelected(int index) {
    if (index == _currentIndex) return;
    // Navigation is handled by AdminNavigationBar; dashboard is always "home" (index 0)
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildDashboardCard({
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
    }) {
      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.adminAccent.withAlpha(18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.adminAccent.withAlpha(30),
                  ),
                ),
                child: Icon(icon, color: AppColors.adminAccent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Admin',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        showBackButton: false,
        pageTitle: 'Dashboard',
        onSignOut: () async {
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          }
        },
        onDashboard: () {},
        onSettings: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        },
        onReports: () {},
        onAnalytics: () {},
      ),
      endDrawer: AppDrawer(
        onDashboard: () {},
        onNotifications: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
        },
        onSettings: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        },
        onReports: () {},
        onAnalytics: () {},
        onLogout: () async {
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          }
        },
      ),
      bottomNavigationBar: AdminNavigationBar(
        currentIndex: _currentIndex,
        onItemSelected: _onNavItemSelected,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${CurrentUserSession.firstName ?? 'User'}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose what you want to manage today.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Inter',
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        // Pending dispatch request section
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('emergencyCases')
                              .where('status', isEqualTo: 'ambulanceRequested')
                              .limit(1)
                              .snapshots(),
                          builder: (context, snapshot) {
                            final docs = snapshot.data?.docs ?? [];
                            if (docs.isEmpty) return const SizedBox.shrink();
                            
                            final data = docs.first.data() as Map<String, dynamic>;
                            final type = data['emergencyType'] as String? ?? 'Emergency';
                            final patientFirst = data['patientFirstName'] as String? ?? '';
                            final patientLast = data['patientLastName'] as String? ?? '';
                            final patientName = '$patientFirst $patientLast'.trim();
                            final urgency = data['urgencyLevel'] as String? ?? 'medium';
                            
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(
                                    builder: (_) => AdminCaseTimelineScreen(caseId: docs.first.id),
                                  )),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withAlpha(10),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.red.withAlpha(40)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withAlpha(20),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(Icons.local_shipping_rounded, color: Colors.red, size: 24),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Dispatch Needed', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.red)),
                                              const SizedBox(height: 2),
                                              Text('$type${patientName.isNotEmpty ? " - $patientName" : ""}', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text('Dispatch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
                        buildDashboardCard(
                          icon: Icons.assignment_rounded,
                          title: 'Active Cases',
                          subtitle: 'View and manage all ongoing cases.',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/admin-case-dashboard',
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        buildDashboardCard(
                          icon: Icons.insights_rounded,
                          title: 'Analytics',
                          subtitle:
                              'View ambulance dispatch and VHT report insights.',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AdminCaseAnalyticsScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        buildDashboardCard(
                          icon: Icons.people_alt_rounded,
                          title: 'Manage Users',
                          subtitle: 'Add or remove system users.',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AdminManageUsersScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
