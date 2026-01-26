import 'package:flutter/material.dart';
import 'admin_navigation_bar.dart';
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
  int _currentIndex = 0; // 0 = Home, 1 = Reports/Analytics

  void _onItemSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
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
        onSignOut: () async {
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          }
        },
        onDashboard: () {},
        onSettings: () {},
        onReports: () {},
        onAnalytics: () {},
      ),
      endDrawer: AppDrawer(
        onDashboard: () {},
        onSettings: () {},
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
        onItemSelected: _onItemSelected,
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
                        buildDashboardCard(
                          icon: Icons.assignment_turned_in_outlined,
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
                          icon: Icons.bar_chart_outlined,
                          title: 'Analytics',
                          subtitle:
                              'View ambulance dispatch and VHT report insights.',
                          onTap: () {},
                        ),
                        const SizedBox(height: 16),
                        buildDashboardCard(
                          icon: Icons.group_outlined,
                          title: 'Manage Users',
                          subtitle: 'Add or remove system users.',
                          onTap: () {},
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
