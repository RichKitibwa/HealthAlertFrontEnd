import 'dart:ui';

import 'package:flutter/material.dart';
import 'ambulance_en_route_screen.dart';
import 'ambulance_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/widgets/app_drawer.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/current_user_session.dart';

class AmbulanceIncomingDispatchScreen extends StatelessWidget {
  // TODO: Replace placeholder emergencyType with value from VHT case selection (e.g., Birth/Trauma/Infection/Other).
  final String emergencyType;

  const AmbulanceIncomingDispatchScreen({
    Key? key,
    this.emergencyType = '🚑 Trauma',
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
      // Outer background
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
        currentIndex: 0, // 0 = Home, 1 = Map (adjust when wiring tabs)
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
                  // Header: title only (avatar handled by top nav bar)
                  const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Emergency Dispatch',
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Main frame area: sleek card + glass inner panel
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
                          // subtle highlight to fake depth
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
                                // Top mini-header inside the glass panel
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
                                        Icons.local_hospital_outlined,
                                        color: AppColors.ambulanceAccent,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Incoming Dispatch',
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Review details, then accept to proceed.',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // ETA chip
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.ambulanceAccent
                                            .withAlpha(18),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: AppColors.ambulanceAccent
                                              .withAlpha(30),
                                        ),
                                      ),
                                      child: Text(
                                        'ETA 12m',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                          color: AppColors.ambulanceAccent,
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

                                // Details tiles (3D-ish)
                                _InfoTile(
                                  icon: Icons.warning_amber_rounded,
                                  label: 'Emergency Type',
                                  value: emergencyType,
                                ),
                                const SizedBox(height: 10),
                                const _InfoTile(
                                  icon: Icons.place_outlined,
                                  label: 'Pickup',
                                  value: 'Village A',
                                ),
                                const SizedBox(height: 10),
                                const _InfoTile(
                                  icon: Icons.person_outline,
                                  label: 'Patient',
                                  value: 'Adult Male',
                                ),

                                const Spacer(),
                                const SizedBox(height: 14),

                                // Futuristic 3D button
                                Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 320,
                                    ),
                                    child: SizedBox(
                                      height: 56,
                                      width: double.infinity,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppColors.ambulanceAccent
                                                  .withAlpha(235),
                                              AppColors.ambulanceAccent,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.ambulanceAccent
                                                  .withAlpha(55),
                                              blurRadius: 20,
                                              offset: const Offset(0, 12),
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
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            onTap: () {
                                              // TODO: Implement accept dispatch action for ambulance worker and update backend case status.
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const AmbulanceEnRouteScreen(
                                                        // TODO: Pass along case details (e.g., caseId, pickup location) via constructor once wired to backend.
                                                      ),
                                                ),
                                              );
                                            },
                                            child: const Center(
                                              child: Text(
                                                'Accept Dispatch',
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
                                  ),
                                ),
                              ],
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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
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
          // shadow down-right
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
          // highlight up-left
          BoxShadow(
            color: Colors.white.withAlpha(180),
            blurRadius: 10,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
