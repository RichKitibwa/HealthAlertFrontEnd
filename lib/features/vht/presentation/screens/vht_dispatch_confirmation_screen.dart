import 'package:flutter/material.dart';
import 'vht_track_ambulance_screen.dart';

class DispatchConfirmationScreen extends StatelessWidget {
  final String emergencyType;

  const DispatchConfirmationScreen({Key? key, required this.emergencyType})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Placeholder values for now
    const String clinicName = 'Central Health'; // TODO: fill dynamically
    const String ambulanceId = '042'; // TODO: retrieve from DB
    const String etaText = '12 min'; // TODO: compute ETA

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF0077CC),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      // Matches other screens
      backgroundColor: const Color(0xFFFBFCFD),
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

                    // Top white bar
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: 60,
                      child: Container(color: Colors.white),
                    ),

                    // Blue circle with "V"
                    Positioned(
                      left: 10,
                      top: 12,
                      width: 36,
                      height: 36,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF0077CC),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'V',
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
                    ),

                    // "Dispatch Confirmation" title
                    const Positioned(
                      left: 0,
                      right: 0,
                      top: 14,
                      child: Center(
                        child: Text(
                          'Dispatch Confirmation',
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

                    // Main white card with details
                    Positioned(
                      left: 20, // 5.56%
                      right: 20, // 5.56%
                      top: 100, // 15.62%
                      height: 360,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE3E8EF)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Clinic Assigned: $clinicName',
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
                              'Ambulance Assigned: $ambulanceId',
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
                              'ETA: $etaText',
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
                            Text(
                              'Emergency type: $emergencyType',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 17 / 14,
                                color: Color(0xFF667085),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // "Track Ambulance" button
                    Positioned(
                      left: 60, // 16.67%
                      right: 60,
                      top: 560, // 75% of 640 + a bit
                      height: 64,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0077CC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrackAmbulanceScreen(
                                emergencyType: emergencyType,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Track Ambulance',
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
