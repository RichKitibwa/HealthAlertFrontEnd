import 'package:flutter/material.dart';
import 'ambulance_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';
import 'ambulance_all_incoming_requests.dart';
import '../../../common/presentation/widgets/app_drawer.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';

class AmbulanceCaseClosureScreen extends StatelessWidget {
  // TODO: Fetch these values dynamically from backend case data (pickup, arrival, clinic delivery times).
  final String pickupTime;
  final String arrivalTime;
  final String clinicDeliveryTime;

  const AmbulanceCaseClosureScreen({
    Key? key,
    this.pickupTime = '10:12',
    this.arrivalTime = '10:25',
    this.clinicDeliveryTime = '10:40',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Ambulance',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        pageTitle: 'Case Closure',
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
        currentIndex: 0, // Treat case closure as part of the main flow
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
                    'Case Closure',
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
                  // Main frame: light background with inner white card
                  Expanded(
                    child: Container(
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 24,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Case summary:',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  height: 19 / 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Pickup: $pickupTime',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  height: 19 / 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Arrival at scene: $arrivalTime',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  height: 19 / 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Delivered to clinic: $clinicDeliveryTime',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  height: 19 / 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // TODO: Optionally, show total response time or additional notes here from backend.
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Bottom button: "Ready for next case"
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ambulanceAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 6,
                      ),
                      onPressed: () {
                        // TODO: Mark case as closed in backend and reset ambulance to available state.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Case closed. Ambulance is ready for the next case.',
                            ),
                          ),
                        );

                        // Navigate back to the list of all incoming requests
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AmbulanceAllIncomingRequestsScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Ready for next case',
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
