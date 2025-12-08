import 'package:flutter/material.dart';
import 'admin_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';

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

    // TODO: wire up navigation when admin tab screens are ready
    // if (index == 0) Navigator.pushNamed(context, '/admin-dashboard');
    // if (index == 1) Navigator.pushNamed(context, '/admin-analytics');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 600;
    const primaryBlue = Color(0xFF0077CC);

    Widget buildDashboardCard({
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
    }) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 32, color: primaryBlue),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Admin',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        showBackButton: false,
        onSignOut: () {
          CurrentUserSession.clear();
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
      ),
      bottomNavigationBar: AdminNavigationBar(
        currentIndex: _currentIndex,
        onItemSelected: _onItemSelected,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final padding = constraints.maxWidth < 400 ? 16.0 : 24.0;
            final crossAxisCount = isWide ? 2 : 1;
            // On narrow screens, give each card more vertical space to avoid overflow.
            final childAspectRatio = isWide ? 3.0 : 2.1;

            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Admin',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose what you want to manage today.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: childAspectRatio,
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
                        buildDashboardCard(
                          icon: Icons.bar_chart_outlined,
                          title: 'Analytics',
                          subtitle:
                              'View ambulance dispatch and VHT report insights.',
                          onTap: () {
                            // TODO: Navigate to Admin Analytics screen
                            // Navigator.pushNamed(context, '/admin-analytics');
                          },
                        ),
                        buildDashboardCard(
                          icon: Icons.group_outlined,
                          title: 'Manage Users',
                          subtitle: 'Add or remove system users.',
                          onTap: () {
                            // TODO: Navigate to Manage Users screen
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
