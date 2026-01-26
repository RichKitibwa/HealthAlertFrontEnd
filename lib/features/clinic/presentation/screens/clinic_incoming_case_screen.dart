import 'package:flutter/material.dart';
import 'clinic_case_summary.dart';
import 'clinic_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';
import '../../../common/presentation/widgets/app_drawer.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';

class ClinicIncomingCaseScreen extends StatelessWidget {
  const ClinicIncomingCaseScreen({super.key});

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
        onSignOut: () async {
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        },
        onDashboard: () {
          // TODO: Navigate to dashboard screen
        },
        onSettings: () {
          // TODO: Navigate to settings screen
        },
        onLearningResources: () {
          // TODO: Navigate to learning resources screen
        },
      ),
      endDrawer: AppDrawer(
        onDashboard: () {
          // TODO: Navigate to dashboard screen
        },
        onSettings: () {
          // TODO: Navigate to settings screen
        },
        onLearningResources: () {
          // TODO: Navigate to learning resources screen
        },
        onLogout: () async {
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        },
      ),
      backgroundColor: AppColors.background,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Incoming Cases',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Review emergencies submitted by VHTs.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
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
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.border),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(8),
                                      blurRadius: 18,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
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
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              height: 17 / 14,
                                              color: AppColors.clinicAccent,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Emergency: $emergency',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              height: 15 / 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'VHT notes: $notes',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              height: 15 / 12,
                                              color: AppColors.textSecondary,
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
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.clinicAccent.withAlpha(
                                          18,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: AppColors.clinicAccent
                                              .withAlpha(30),
                                        ),
                                      ),
                                      child: Text(
                                        'ETA: $eta',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                          height: 15 / 12,
                                          color: AppColors.clinicAccent,
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
