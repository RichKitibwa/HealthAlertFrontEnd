import 'package:flutter/material.dart';
import 'clinic_case_summary.dart';
import 'clinic_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';

class ClinicIncomingCaseScreen extends StatelessWidget {
  const ClinicIncomingCaseScreen({super.key});

  static const Color _backgroundColor = Color(0xFFF7F9FC);
  static const Color _primaryBlue = Color(0xFF0077CC);
  static const Color _cardBorder = Color(0xFFE3E8EF);

  // Dummy data for now; later this can be replaced with real backend data.
  final List<Map<String, String>> _dummyCases = const [
    {
      'patient': 'Adult Female',
      'emergency': '🚑 Trauma',
      'notes': 'Severe bleeding, suspected fracture',
      'eta': '12 min',
    },
    {
      'patient': 'Child, 4 years',
      'emergency': '🦠 Infection',
      'notes': 'High fever, difficulty breathing',
      'eta': '18 min',
    },
    {
      'patient': 'Pregnant Female',
      'emergency': '🤰 Birth',
      'notes': 'Contractions every 3 minutes',
      'eta': '10 min',
    },
    {
      'patient': 'Elderly Male',
      'emergency': '⚡ Other',
      'notes': 'Chest pain, dizziness',
      'eta': '20 min',
    },
    {
      'patient': 'Adult Male',
      'emergency': '🚑 Trauma',
      'notes': 'Road traffic accident, unconscious',
      'eta': '8 min',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Clinic',
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
      backgroundColor: _backgroundColor,
      bottomNavigationBar: ClinicNavigationBar(
        currentIndex: 2, // 0 = Home, 1 = Patients, 2 = Incoming Requests
        onItemSelected: (index) {
          // TODO: wire up navigation once clinic tab screens are ready.
          // Example:
          // if (index == 0) Navigator.pushNamed(context, '/clinic-dashboard');
          // if (index == 1) Navigator.pushNamed(context, '/clinic-patients');
          // if (index == 2) Navigator.pushNamed(context, '/clinic-incoming-cases');
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            _ClinicIncomingHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth > 420
                        ? 420.0
                        : constraints.maxWidth;

                    return Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: maxWidth,
                          minWidth: maxWidth * 0.8,
                        ),
                        child: ListView.separated(
                          itemCount: _dummyCases.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final caseData = _dummyCases[index];
                            final patient = caseData['patient'] ?? '';
                            final emergency = caseData['emergency'] ?? '';
                            final notes = caseData['notes'] ?? '';
                            final eta = caseData['eta'] ?? '';

                            return InkWell(
                              onTap: () {
                                // Later you can pass case details to the summary screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ClinicCaseSummaryScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _cardBorder),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Left side: patient, emergency, VHT notes
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Patient: $patient',
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              height: 17 / 14,
                                              color: _primaryBlue,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Emergency: $emergency',
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              height: 15 / 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'VHT notes: $notes',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              height: 15 / 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Right side: ETA pill, similar to status chip on admin dashboard
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _primaryBlue,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        'ETA: $eta',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          height: 15 / 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClinicIncomingHeader extends StatelessWidget {
  const _ClinicIncomingHeader();

  static const Color _primaryBlue = Color(0xFF0077CC);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: const Center(
        child: Text(
          'Incoming Cases',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 24 / 20,
            color: _primaryBlue,
          ),
        ),
      ),
    );
  }
}
