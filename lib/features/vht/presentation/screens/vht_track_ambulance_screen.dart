import 'package:flutter/material.dart';
import 'vht_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';

class TrackAmbulanceScreen extends StatelessWidget {
  final String emergencyType;

  const TrackAmbulanceScreen({Key? key, required this.emergencyType})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'VHT',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        pageTitle: 'Track Ambulance',
        showBackButton: true,
        onBack: () {
          Navigator.pop(context);
        },
        onSignOut: () {
          CurrentUserSession.clear();
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
      ),
      // Matches other screens
      backgroundColor: const Color(0xFFFBFCFD),
      bottomNavigationBar: VhtNavigationBar(
        currentIndex: 0, // part of VHT home/report flow
        onItemSelected: (index) {
          // TODO: wire up navigation if desired
          // if (index == 0) Navigator.pushNamed(context, '/vht-dashboard');
          // if (index == 1) Navigator.pushNamed(context, '/vht-map');
          // if (index == 2) Navigator.pushNamed(context, '/vht-patients');
        },
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              color: const Color(0xFFF7F9FC),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 480, // keep things tidy on larger screens
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 4),
                      const Center(
                        child: Text(
                          'Track Ambulance',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            height: 24 / 20,
                            color: Color(0xFF0077CC),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Map card
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE3E8EF)),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: const Center(
                            child: Text(
                              'Map Placeholder',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                height: 19 / 16,
                                color: Color(0xFF0077CC),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Notify clinic that patient is onboard
                      SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: integrate real clinic notification (or call)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Clinic notified that patient is onboard.',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.notifications_active_rounded,
                            color: Color(0xFF0077CC),
                          ),
                          label: const Text(
                            'Notify clinic patient is onboard',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Color(0xFF0077CC),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF0077CC)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Case Closed button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0077CC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            // TODO: you can later navigate back to dashboard or cases list
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Case closed.')),
                            );
                            Navigator.pop(
                              context,
                            ); // back to confirmation screen
                          },
                          child: const Text(
                            'Case Closed',
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
