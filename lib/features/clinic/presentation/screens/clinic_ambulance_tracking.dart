import 'package:flutter/material.dart';
import 'clinic_patient_arrival.dart';
import 'clinic_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';

class ClinicAmbulanceTrackingScreen extends StatelessWidget {
  const ClinicAmbulanceTrackingScreen({super.key});

  static const Color _backgroundColor = Color(0xFFF7F9FC);
  static const Color _primaryBlue = Color(0xFF0077CC);
  static const Color _cardBorder = Color(0xFFE3E8EF);
  static const Color _statusGreen = Color(0xFF4BD964);

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
        onSignOut: () {
          CurrentUserSession.clear();
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
      ),
      backgroundColor: _backgroundColor,
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
            // Simple centered header; avatar and back button handled by TopNavigationBar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(color: Colors.white),
              child: const Center(
                child: Text(
                  'Ambulance Tracking',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    height: 24 / 20,
                    color: _primaryBlue,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Keep content nicely centered on larger screens
                      final maxWidth = constraints.maxWidth > 420
                          ? 420.0
                          : constraints.maxWidth;

                      return Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: maxWidth,
                            minWidth: maxWidth * 0.85,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Map / ETA placeholder card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _cardBorder),
                                ),
                                child: SizedBox(
                                  height: size.height * 0.35,
                                  child: const Center(
                                    child: Text(
                                      'Map / ETA Placeholder',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        height: 19 / 16,
                                        color: _primaryBlue,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: size.height * 0.06),
                              // Status pill: On Time
                              Align(
                                alignment: Alignment.center,
                                child: TextButton(
                                  onPressed: () {
                                    // TODO: Replace manual tap navigation with automatic
                                    // transition when ambulance status changes to "Arrived".
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ClinicPatientArrivalScreen(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: _statusGreen,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  child: const Text(
                                    'On Time',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      height: 17 / 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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

class _ClinicAmbulanceTrackingHeader extends StatelessWidget {
  const _ClinicAmbulanceTrackingHeader();

  static const Color _primaryBlue = Color(0xFF0077CC);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: _primaryBlue,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 4),
          // C square
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _primaryBlue,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: const Text(
              'C',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 17 / 14,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Ambulance Tracking',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                height: 24 / 20,
                color: _primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 48), // spacer to balance back button + C
        ],
      ),
    );
  }
}
