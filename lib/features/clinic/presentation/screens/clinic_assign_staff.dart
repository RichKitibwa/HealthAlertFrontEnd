import 'package:flutter/material.dart';
import 'clinic_ambulance_tracking.dart';
import 'clinic_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';
import '../../../common/presentation/widgets/app_drawer.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';

// Assign Staff screen
class ClinicAssignStaffScreen extends StatelessWidget {
  const ClinicAssignStaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Clinic',
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
          // TODO: Navigate to dashboard
        },
        onSettings: () {
          // TODO: Navigate to settings
        },
        onLearningResources: () {
          // TODO: Navigate to learning resources
        },
      ),
      endDrawer: AppDrawer(
        onDashboard: () {
          // TODO: Navigate to dashboard
        },
        onSettings: () {
          // TODO: Navigate to settings
        },
        onLearningResources: () {
          // TODO: Navigate to learning resources
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
      bottomNavigationBar: ClinicNavigationBar(
        currentIndex: 2, // 0 = Home, 1 = Patients, 2 = Incoming / Cases
        onItemSelected: (index) {
          // TODO: wire up navigation when clinic tab screens are ready
          // if (index == 0) Navigator.pushNamed(context, '/clinic-dashboard');
          // if (index == 1) Navigator.pushNamed(context, '/clinic-patients');
          // if (index == 2) Navigator.pushNamed(context, '/clinic-incoming-cases');
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assign Staff',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Confirm available personnel and required equipment for this case.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 16),
                        // Nurse: Available
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
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
                          child: const Center(
                            child: Text(
                              'Nurse: Available',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                height: 19 / 16,
                                color: AppColors.clinicAccent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Clinician: Available
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
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
                          child: const Center(
                            child: Text(
                              'Clinician: Available',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                height: 19 / 16,
                                color: AppColors.clinicAccent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Checklist card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Center(
                            child: Text(
                              'Checklist: Delivery Kit, Trauma Kit, PPE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                height: 18 / 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.06),
                        // Confirm Assignment button
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
                                        const ClinicAmbulanceTrackingScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.clinicAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 6,
                              ),
                              child: const Text(
                                'Confirm Staff',
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
