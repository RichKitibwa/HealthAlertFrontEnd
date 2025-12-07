import 'package:flutter/material.dart';
import 'ambulance_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';
import 'ambulance_all_incoming_requests.dart';

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
        showBackButton: true,
        onBack: () {
          Navigator.pop(context);
        },
        onSignOut: () {
          CurrentUserSession.clear();
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
      ),
      // Outer background
      backgroundColor: const Color(0xFFFBFCFD),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Case Closure',
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
                            children: [
                              const Text(
                                'Case summary:',
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
                                'Pickup: $pickupTime',
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
                                'Arrival at scene: $arrivalTime',
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
                                'Delivered to clinic: $clinicDeliveryTime',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  height: 19 / 16,
                                  color: Color(0xFF0077CC),
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
                        backgroundColor: const Color(0xFF4BD964),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
