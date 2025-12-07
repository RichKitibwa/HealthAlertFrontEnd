import 'package:flutter/material.dart';
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
        onSignOut: () {
          CurrentUserSession.clear();
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
      ),
      // Outer background: light grey/blue
      backgroundColor: const Color(0xFFFBFCFD),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Arrived at Scene',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      height: 24 / 20,
                      color: Color(0xFF0077CC),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Main frame area: light background with inner white card
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE3E8EF)),
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
                                'Patient info from VHT',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  height: 19 / 16,
                                  color: Color(0xFF0077CC),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Emergency: $emergencyType',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  height: 19 / 16,
                                  color: Color(0xFF0077CC),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                patientInfo,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  height: 18 / 14,
                                  color: Color(0xFF667085),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // TODO: Optionally, add vital signs or quick checklist here once backend data is available.
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Secondary actions: notify clinic and VHT
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0077CC)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // TODO: Notify destination clinic (e.g., via backend update or FHIR message).
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Clinic notified about arrival.'),
                          ),
                        );
                      },
                      child: const Text(
                        'Notify Clinic',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 20 / 16,
                          color: Color(0xFF0077CC),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0077CC)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // TODO: Notify originating VHT that ambulance has arrived at scene.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('VHT notified about arrival.'),
                          ),
                        );
                      },
                      child: const Text(
                        'Notify VHT',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 20 / 16,
                          color: Color(0xFF0077CC),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Bottom primary button: "Patient onboard"
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0077CC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // TODO: Mark patient as onboard in backend and move case to "transporting to clinic" stage.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AmbulanceClinicEnRouteScreen(
                                  // TODO: Pass along case details (e.g., caseId, clinic info, ETA) via constructor once wired to backend.
                                ),
                          ),
                        );
                      },
                      child: const Text(
                        'Patient onboard',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                          height: 24 / 20,
                          color: Colors.white,
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
