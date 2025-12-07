import 'package:flutter/material.dart';
import 'ambulance_case_closure.dart';
import 'ambulance_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';

class AmbulanceClinicEnRouteScreen extends StatelessWidget {
  const AmbulanceClinicEnRouteScreen({Key? key}) : super(key: key);

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
      // Outer background from Figma (#FBFCFD)
      backgroundColor: const Color(0xFFFBFCFD),
      bottomNavigationBar: AmbulanceNavigationBar(
        currentIndex: 1, // This screen represents a "map/route" view
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
                    'En Route to Clinic',
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
                  // Main frame: light background with inner white card
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
                            children: const [
                              SizedBox(height: 32),
                              Text(
                                'Map / ETA Placeholder',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  height: 19 / 16,
                                  color: Color(0xFF0077CC),
                                ),
                              ),
                              SizedBox(height: 32),
                              // TODO: Integrate real map + ETA from backend (e.g., clinic location, live ETA).
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Bottom primary button: "Arrived at Clinic"
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
                        // TODO: Mark case as "Arrived at clinic" in backend and notify clinic/VHT.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AmbulanceCaseClosureScreen(
                              // TODO: Pass full case summary data (pickup, arrival, clinic delivery times) via constructor once wired to backend.
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Arrived at clinic',
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
