import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../common/presentation/widgets/app_drawer.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';
import 'ambulance_clinic_en_route.dart';
import 'ambulance_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';

class AmbulanceArrivalScreen extends StatelessWidget {
  // TODO: Fetch emergency type and patient info from backend (VHT-submitted case details).
  final String emergencyType;
  final String patientInfo;

  const AmbulanceArrivalScreen({
    Key? key,
    this.emergencyType = '🚑 Trauma',
    this.patientInfo =
        'Details provided by VHT (e.g., Adult male, breathing, bleeding at leg)',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Ambulance',
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
      ),
      backgroundColor: AppColors.background,
      endDrawer: AppDrawer(
        onDashboard: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/ambulance-dashboard');
        },
        onSettings: () {
          Navigator.pop(context);
          // TODO: Navigate to settings screen
        },
        onLogout: () async {
          Navigator.pop(context);
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
      bottomNavigationBar: AmbulanceNavigationBar(
        currentIndex: 0, // Treat this as part of the main ambulance flow
        onItemSelected: (index) {
          // TODO: wire up navigation when ambulance tab screens are ready
          // if (index == 0) Navigator.pushNamed(context, '/ambulance-dashboard');
          // if (index == 1) Navigator.pushNamed(context, '/ambulance-map');
        },
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Arrived at Scene',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      height: 24 / 20,
                      color: AppColors.ambulanceAccent,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Main frame area: sleek card + glass panel
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.surface,
                            AppColors.surface.withAlpha(230),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 24,
                            offset: const Offset(0, 14),
                          ),
                          BoxShadow(
                            color: Colors.white.withAlpha(120),
                            blurRadius: 18,
                            offset: const Offset(0, -10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.border.withAlpha(120),
                              ),
                              color: Colors.white.withAlpha(180),
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.ambulanceAccent
                                            .withAlpha(18),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.ambulanceAccent
                                              .withAlpha(30),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.flag_outlined,
                                        color: AppColors.ambulanceAccent,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'On Scene',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  height: 1,
                                  color: AppColors.border.withAlpha(120),
                                ),
                                const SizedBox(height: 14),
                                _ArrivalInfoTile(
                                  icon: Icons.warning_amber_rounded,
                                  label: 'Emergency',
                                  value: emergencyType,
                                ),
                                const SizedBox(height: 10),
                                _ArrivalInfoTile(
                                  icon: Icons.person_outline,
                                  label: 'Patient info',
                                  value: patientInfo,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _SecondaryActionButton(
                          label: 'Notify Clinic',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Clinic notified about arrival.'),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _SecondaryActionButton(
                          label: 'Notify VHT',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('VHT notified about arrival.'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.ambulanceAccent.withAlpha(235),
                            AppColors.ambulanceAccent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ambulanceAccent.withAlpha(55),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.white.withAlpha(90),
                            blurRadius: 10,
                            offset: const Offset(0, -6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AmbulanceClinicEnRouteScreen(),
                              ),
                            );
                          },
                          child: const Center(
                            child: Text(
                              'Patient onboard',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                height: 20 / 16,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
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

class _ArrivalInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ArrivalInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withAlpha(140)),
        color: Colors.white.withAlpha(210),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withAlpha(180),
            blurRadius: 10,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: AppColors.ambulanceAccent.withAlpha(16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.ambulanceAccent.withAlpha(28),
              ),
            ),
            child: Icon(icon, color: AppColors.ambulanceAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SecondaryActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withAlpha(220),
          border: Border.all(color: AppColors.border.withAlpha(140)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withAlpha(160),
              blurRadius: 10,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
