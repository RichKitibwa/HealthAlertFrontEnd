import 'package:flutter/material.dart';
import 'admin_case_timeline.dart';
import 'admin_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';
import '../../../common/presentation/widgets/app_drawer.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';

class AdminCaseDashboardScreen extends StatelessWidget {
  const AdminCaseDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Admin',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        showBackButton: true,
        onBack: () {
          Navigator.pop(context);
        },
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
          // TODO: Navigate to dashboard screen
        },
        onSettings: () {
          // TODO: Navigate to settings screen
        },
        onReports: () {
          // TODO: Navigate to reports screen
        },
        onAnalytics: () {
          // TODO: Navigate to analytics screen
        },
      ),
      endDrawer: AppDrawer(
        onDashboard: () {
          // TODO: Navigate to dashboard screen
        },
        onSettings: () {
          // TODO: Navigate to settings screen
        },
        onReports: () {
          // TODO: Navigate to reports screen
        },
        onAnalytics: () {
          // TODO: Navigate to analytics screen
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
      backgroundColor: AppColors.background,
      bottomNavigationBar: AdminNavigationBar(
        currentIndex: 0, // 0 = Home, 1 = Reports/Analytics
        onItemSelected: (index) {
          // TODO: wire up navigation when admin tabs are ready
          // if (index == 0) Navigator.pushNamed(context, '/admin-dashboard');
          // if (index == 1) Navigator.pushNamed(context, '/admin-analytics');
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Cases',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Monitor ongoing emergencies across VHTs, ambulances, and clinics.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Sort dropdown row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      // TODO: Implement actual sorting based on selected criterion
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sort by $value (coming soon)')),
                      );
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'Severity',
                        child: Text('Sort by severity'),
                      ),
                      PopupMenuItem(
                        value: 'Time arrived',
                        child: Text('Sort by time arrived'),
                      ),
                      PopupMenuItem(
                        value: 'Clinic',
                        child: Text('Sort by clinic'),
                      ),
                      PopupMenuItem(
                        value: 'Distance',
                        child: Text('Sort by distance'),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.sort,
                            size: 18,
                            color: AppColors.adminAccent,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Sort',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: AppColors.adminAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Sample active cases (clickable)
                        GestureDetector(
                          onTap: () {
                            // TODO: Replace with navigation using selected case ID
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AdminCaseTimelineScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Case #001 - Adult Female, Trauma',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          height: 17 / 14,
                                          color: AppColors.adminAccent,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'VHT Zone 3 • ETA 12 min',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          height: 15 / 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFFF6A3D,
                                    ).withAlpha(22),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFFF6A3D,
                                      ).withAlpha(80),
                                    ),
                                  ),
                                  child: const Text(
                                    'Critical',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      height: 15 / 12,
                                      color: Color(0xFFCC3C17),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // TODO: Replace with navigation using selected case ID
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AdminCaseTimelineScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Case #002 - Child, Respiratory',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          height: 17 / 14,
                                          color: AppColors.adminAccent,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'VHT Zone 1 • ETA 8 min',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          height: 15 / 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF4BD964,
                                    ).withAlpha(22),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF4BD964,
                                      ).withAlpha(80),
                                    ),
                                  ),
                                  child: const Text(
                                    'Normal',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      height: 15 / 12,
                                      color: Color(0xFF2EAE4F),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Map / Active Cases placeholder card
                        Container(
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
                          child: SizedBox(
                            height: size.height * 0.35,
                            child: const Center(
                              child: Text(
                                'Map / Active Cases Placeholder',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  height: 19 / 16,
                                  color: AppColors.adminAccent,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Status legend row: Normal / Critical
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Normal
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4BD964).withAlpha(22),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: const Color(0xFF4BD964).withAlpha(80),
                                ),
                              ),
                              child: const Text(
                                'Normal',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  height: 17 / 14,
                                  color: Color(0xFF2EAE4F),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Critical
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6A3D).withAlpha(22),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: const Color(0xFFFF6A3D).withAlpha(80),
                                ),
                              ),
                              child: const Text(
                                'Critical',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  height: 17 / 14,
                                  color: Color(0xFFCC3C17),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
