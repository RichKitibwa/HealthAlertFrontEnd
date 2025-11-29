import 'package:flutter/material.dart';
import 'ambulance_clinic_en_route.dart';

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
      // Transparent app bar to match ambulance flow
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF0077CC),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Outer background: light grey/blue
      backgroundColor: const Color(0xFFFBFCFD),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header row: blue "A" box + "Arrived at Scene"
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
