import 'package:flutter/material.dart';
import 'admin_case_analytics.dart';
import 'admin_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';
import '../../../common/presentation/widgets/app_drawer.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';

class AdminCaseTimelineScreen extends StatelessWidget {
  const AdminCaseTimelineScreen({super.key});

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
        onDashboard: () {},
        onSettings: () {},
        onReports: () {},
        onAnalytics: () {},
      ),
      backgroundColor: AppColors.background,
      endDrawer: AppDrawer(
        onDashboard: () {
          // TODO: Navigate to dashboard
        },
        onSettings: () {
          // TODO: Navigate to settings
        },
        onReports: () {
          // TODO: Navigate to reports
        },
        onAnalytics: () {
          // TODO: Navigate to analytics
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
                    'Case Timeline',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Review the sequence of events for this emergency case.',
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Timeline card
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 24,
                          ),
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              // TODO: Replace hardcoded time with fetched VHT reporting time
                              Text(
                                'VHT Report: 10:12',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  height: 19 / 16,
                                  color: AppColors.adminAccent,
                                ),
                              ),
                              SizedBox(height: 12),
                              // TODO: Replace hardcoded time with fetched ambulance accepting time
                              Text(
                                'Ambulance Accept: 10:14',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  height: 19 / 16,
                                  color: AppColors.adminAccent,
                                ),
                              ),
                              SizedBox(height: 12),
                              // TODO: Replace hardcoded time with fetched arrival-at-scene time
                              Text(
                                'Arrival at Scene: 10:25',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  height: 19 / 16,
                                  color: AppColors.adminAccent,
                                ),
                              ),
                              SizedBox(height: 12),
                              // TODO: Replace hardcoded time with fetched clinic intake time
                              Text(
                                'Clinic Intake: 10:40',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  height: 19 / 16,
                                  color: AppColors.adminAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // View Analytics button
                        SizedBox(
                          width: double.infinity,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 360),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AdminCaseAnalyticsScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.adminAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 6,
                              ),
                              child: const Text(
                                'View Analytics',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  height: 20 / 16,
                                ),
                              ),
                            ),
                          ),
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
