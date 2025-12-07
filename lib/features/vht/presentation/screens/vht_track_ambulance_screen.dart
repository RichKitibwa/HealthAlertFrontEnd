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
        child: Stack(
          children: [
            Positioned(
              left: 26,
              top: 16,
              child: SizedBox(
                width: 360,
                height: 640,
                child: Stack(
                  children: [
                    // Full frame background (#F7F9FC)
                    Positioned.fill(
                      child: Container(color: const Color(0xFFF7F9FC)),
                    ),

                    // "Track Ambulance" title
                    const Positioned(
                      left: 0,
                      right: 0,
                      top: 14,
                      child: Center(
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
                    ),

                    // Main white card for map
                    Positioned(
                      left: 20, // 5.56%
                      right: 20, // 5.56%
                      top: 80, // 12.5%
                      height: 360,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE3E8EF)),
                        ),
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

                    // "Case Closed" button
                    Positioned(
                      left: 60, // 16.67%
                      right: 60,
                      top: 560, // 71.88% ish
                      height: 64,
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
                          Navigator.pop(context); // back to confirmation screen
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
          ],
        ),
      ),
    );
  }
}
