import 'package:flutter/material.dart';
import 'ambulance_arrival_screen.dart';

class AmbulanceEnRouteScreen extends StatelessWidget {
  const AmbulanceEnRouteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Transparent app bar to match other flows
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF0077CC),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Outer background from Figma (#FBFCFD)
      backgroundColor: const Color(0xFFFBFCFD),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header row: blue "A" box + "En Route" title
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        color: const Color(0xFF0077CC),
                        child: const Center(
                          child: Text(
                            'A',
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
                          'En Route',
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
                      const SizedBox(width: 48), // visual balance
                    ],
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
                            children: const [
                              SizedBox(height: 32),
                              Text(
                                'Map / Navigation Placeholder',
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
                              // TODO: Integrate real map/navigation for ambulance driver (e.g., Google Maps, OSRM, etc.).
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Bottom buttons row: En Route (green) and Delay (orange)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4BD964),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              // TODO: Update backend status to "En Route" / confirm current status.
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AmbulanceArrivalScreen(
                                        // TODO: Pass along case details (e.g., caseId, emergencyType, patientInfo) via constructor once wired to backend.
                                      ),
                                ),
                              );
                            },
                            child: const Text(
                              'En Route',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                                height: 22 / 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6A3D),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              // TODO: Let driver report a delay and notify clinic/VHT with reason and updated ETA.
                              showDialog(
                                context: context,
                                builder: (dialogContext) {
                                  return AlertDialog(
                                    title: const Text('Report delay'),
                                    content: const Text(
                                      'This will notify the clinic and VHT that the ambulance is delayed.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(dialogContext).pop(),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // TODO: Implement delay report backend call.
                                          Navigator.of(dialogContext).pop();
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Text(
                              'Delay',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                                height: 22 / 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
