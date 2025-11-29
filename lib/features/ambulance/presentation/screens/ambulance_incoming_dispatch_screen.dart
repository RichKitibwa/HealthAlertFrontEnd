import 'package:flutter/material.dart';
import 'ambulance_en_route_screen.dart';

class AmbulanceIncomingDispatchScreen extends StatelessWidget {
  // TODO: Replace placeholder emergencyType with value from VHT case selection (e.g., Birth/Trauma/Infection/Other).
  final String emergencyType;

  const AmbulanceIncomingDispatchScreen({
    Key? key,
    this.emergencyType = '🚑 Trauma',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF0077CC),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Outer background
      backgroundColor: const Color(0xFFFBFCFD),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header row: blue "A" box + title
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
                          'Emergency Dispatch',
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
                  // Main frame area (Figma: #F7F9FC with inner white card)
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
                              // Emergency Type: from VHT selection (placeholder + TODO)
                              Text(
                                'Emergency Type: $emergencyType',
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
                              const Text(
                                'Pickup: Village A',
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
                              const Text(
                                'Patient: Adult Male',
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
                              const Text(
                                'ETA: 12 min',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  height: 19 / 16,
                                  color: Color(0xFF0077CC),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Accept / Reject buttons row
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 56,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF4BD964,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          // TODO: Implement accept dispatch action for ambulance worker and update backend case status.
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const AmbulanceEnRouteScreen(
                                                    // TODO: Pass along case details (e.g., caseId, pickup location) via constructor once wired to backend.
                                                  ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Accept',
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
                                          backgroundColor: const Color(
                                            0xFF667085,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          // TODO: Send rejection status back to VHT/backend so the case can be reassigned or escalated.
                                          showDialog(
                                            context: context,
                                            builder: (dialogContext) {
                                              return AlertDialog(
                                                title: const Text(
                                                  'Case rejected',
                                                ),
                                                content: const Text(
                                                  'The VHT will be notified that this ambulance request was rejected.',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          dialogContext,
                                                        ).pop(),
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: const Text(
                                          'Reject',
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
