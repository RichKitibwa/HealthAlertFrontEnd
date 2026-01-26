import 'dart:ui';

import 'package:flutter/material.dart';
import 'ambulance_arrival_screen.dart';
import 'ambulance_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/widgets/app_drawer.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/current_user_session.dart';

class AmbulanceEnRouteScreen extends StatelessWidget {
  const AmbulanceEnRouteScreen({Key? key}) : super(key: key);

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
        currentIndex: 1, // This screen represents the "Map" view
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
                  // Header: title only (avatar & back handled by top nav bar)
                  const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'En Route',
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
                                        Icons.navigation_outlined,
                                        color: AppColors.ambulanceAccent,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Navigation',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Follow the route to the pickup location.',
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
                                        'EN ROUTE',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w900,
                                          fontSize: 11,
                                          letterSpacing: 0.6,
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

                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppColors.border.withAlpha(140),
                                      ),
                                      color: Colors.white.withAlpha(210),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(10),
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
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.map_outlined,
                                          size: 44,
                                          color: AppColors.ambulanceAccent,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Map / Navigation Placeholder',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                      ],
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
                  const SizedBox(height: 24),
                  // Bottom buttons row: En Route + Delay (sleek 3D)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
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
                                  color: AppColors.ambulanceAccent.withAlpha(
                                    55,
                                  ),
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
                                  // TODO: Update backend status to "En Route" / confirm current status.
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AmbulanceArrivalScreen(
                                            // TODO: Pass along case details (e.g., caseId, emergencyType, patientInfo) via constructor once wired to backend.
                                          ),
                                    ),
                                  );
                                },
                                child: const Center(
                                  child: Text(
                                    'En Route',
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
                      const SizedBox(width: 14),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFFF7A4D), Color(0xFFFF5A2A)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF5A2A).withAlpha(55),
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
                                  // TODO: Let driver report a delay and notify clinic/VHT with reason and updated ETA.
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) {
                                      return AlertDialog(
                                        title: const Text('Report delay'),
                                        content: const Text(
                                          'This will notify the clinic and VHT that the ambulance is delayed.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                              dialogContext,
                                            ).pop(),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // TODO: Implement delay report backend call.
                                              Navigator.of(dialogContext).pop();
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Center(
                                  child: Text(
                                    'Delay',
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
                    ],
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
