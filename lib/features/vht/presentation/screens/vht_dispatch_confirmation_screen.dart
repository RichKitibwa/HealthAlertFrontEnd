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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header row with V circle and title
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
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
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Dispatch Confirmation',
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
                      ),
                      const SizedBox(width: 48), // visual balance spacer
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Main white card that scales with height
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Clinic assigned: $clinicName',
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
                              'Estimated arrival: $etaText',
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
                            const Divider(
                              thickness: 1,
                              color: Color(0xFFE3E8EF),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Automatically assigning nearest ambulance…',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                height: 19 / 16,
                                color: Color(0xFF0077CC),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'The system will choose the closest available ambulance and update this screen in real time.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 18 / 14,
                                color: Color(0xFF667085),
                              ),
                            ),
                            const SizedBox(height: 16),
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
                            const SizedBox(height: 16),
                            // TODO: Integrate backend logic to:
                            // 1) Find the nearest available ambulance
                            // 2) Assign it to this case
                            // 3) Stream live updates (status/ETA) to this screen
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
            );
          },
        ),
      ),
    );
  }
}
