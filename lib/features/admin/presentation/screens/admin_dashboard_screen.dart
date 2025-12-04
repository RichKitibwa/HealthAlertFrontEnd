import 'package:flutter/material.dart';

// Admin Dashboard Screen
// Main dashboard for administrators and NGOs

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
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
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: false,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final padding = constraints.maxWidth < 400 ? 16.0 : 24.0;
            final crossAxisCount = isWide ? 2 : 1;
            final childAspectRatio = isWide ? 3.0 : 2.7;

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
                          icon: Icons.local_hospital_outlined,
                          title: 'Dispatched Ambulances',
                          subtitle: 'Track ambulance status and locations.',
                          onTap: () {
                            // TODO: Navigate to Dispatched Ambulances screen
                          },
                        ),
                        buildDashboardCard(
                          icon: Icons.assignment_outlined,
                          title: 'VHT Reports',
                          subtitle: 'Review reports submitted by VHTs.',
                          onTap: () {
                            // TODO: Navigate to VHT Reports screen
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
