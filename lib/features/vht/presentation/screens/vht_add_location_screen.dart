import 'package:flutter/material.dart';
import 'vht_dispatch_confirmation_screen.dart';
import 'vht_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';

class CaptureLocationScreen extends StatelessWidget {
  final String emergencyType;

  const CaptureLocationScreen({Key? key, required this.emergencyType})
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
      // Figma background: #FBFCFD
      backgroundColor: const Color(0xFFFBFCFD),
      bottomNavigationBar: VhtNavigationBar(
        currentIndex: 0, // this screen is part of the VHT home/report flow
        onItemSelected: (index) {
          // TODO: wire up navigation if desired
          // Example:
          // if (index == 0) Navigator.pushNamed(context, '/vht-dashboard');
          // if (index == 1) Navigator.pushNamed(context, '/vht-map');
          // if (index == 2) Navigator.pushNamed(context, '/vht-patients');
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
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE3E8EF)),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.my_location,
                              size: 48,
                              color: Color(0xFF0077CC),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Automatically capturing location…',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                height: 22 / 18,
                                color: Color(0xFF0077CC),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'This will help responders find you faster.\nNo need to move the map or pin your position.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 18 / 14,
                                color: Color(0xFF667085),
                              ),
                            ),
                            SizedBox(height: 16),
                            // TODO: Implement GPS-based automatic location capture
                            // (e.g., GPS/triangulation handled on backend)
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                        // TODO: Wire this to real captured coordinates once backend integration is ready.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DispatchConfirmationScreen(
                              emergencyType: emergencyType,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Continue',
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
