import 'package:flutter/material.dart';
import 'clinic_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/widgets/app_drawer.dart';
import '../../../auth/current_user_session.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';

// Clinic Staff Dashboard Screen
// Main dashboard for clinic staff

class ClinicDashboardScreen extends StatefulWidget {
  const ClinicDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ClinicDashboardScreen> createState() => _ClinicDashboardScreenState();
}

class _ClinicDashboardScreenState extends State<ClinicDashboardScreen> {
  int _currentIndex = 0; // 0 = Home, 1 = Patients, 2 = Incoming

  void _onNavItemSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    // TODO: wire up navigation when clinic tab screens are ready
    // if (index == 0) Navigator.pushNamed(context, '/clinic-dashboard');
    // if (index == 1) Navigator.pushNamed(context, '/clinic-patients');
    // if (index == 2) Navigator.pushNamed(context, '/clinic-incoming-requests');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Clinic',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        showBackButton: false,
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
          // Already on dashboard
        },
        onSettings: () {
          // TODO: Navigate to settings screen
        },
        onLearningResources: () {
          // TODO: Navigate to learning resources screen
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
      bottomNavigationBar: ClinicNavigationBar(
        currentIndex: _currentIndex,
        onItemSelected: _onNavItemSelected,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double horizontalPadding = constraints.maxWidth < 400
                ? 16.0
                : 20.0;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 560 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Clinic name card
                      if (CurrentUserSession.workplace != null &&
                          CurrentUserSession.workplace!.isNotEmpty)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16.0),
                          padding: const EdgeInsets.all(14.0),
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
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.clinicAccent.withAlpha(18),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.clinicAccent.withAlpha(30),
                                  ),
                                ),
                                child: Icon(
                                  Icons.local_hospital_outlined,
                                  color: AppColors.clinicAccent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Clinic',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      CurrentUserSession.workplace!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        'Welcome, ${CurrentUserSession.firstName ?? CurrentUserSession.fullName ?? 'User'}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Monitor incoming emergencies and manage active cases for your clinic.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Primary action button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.assignment_turned_in_outlined),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.0),
                            child: Text(
                              'View Incoming Emergencies',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.clinicAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 6,
                          ),
                          onPressed: () {
                            // Navigate to clinic active cases / incoming cases screen
                            Navigator.pushNamed(
                              context,
                              '/clinic-incoming-case',
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.people_outline),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.0),
                            child: Text(
                              'View Active Cases',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surface,
                            foregroundColor: AppColors.clinicAccent,
                            side: BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            // Navigate to clinic current patients screen (same list for now)
                            Navigator.pushNamed(
                              context,
                              '/clinic-incoming-case',
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'You will see a list of incoming emergencies and active cases linked to your clinic.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
