import 'package:flutter/material.dart';
import 'ambulance_incoming_dispatch_screen.dart';
import 'ambulance_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';
import '../../../common/presentation/widgets/app_drawer.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen that shows all incoming emergency requests for the ambulance driver.
/// For now this uses dummy data; later it can be wired to backend / Firestore.
class AmbulanceAllIncomingRequestsScreen extends StatefulWidget {
  const AmbulanceAllIncomingRequestsScreen({super.key});

  @override
  State<AmbulanceAllIncomingRequestsScreen> createState() =>
      _AmbulanceAllIncomingRequestsScreenState();
}

class _AmbulanceAllIncomingRequestsScreenState
    extends State<AmbulanceAllIncomingRequestsScreen> {
  // Dummy data for now; later this can be replaced with real models from backend.
  final List<Map<String, String>> _dummyRequests = const [
    {
      'emergencyType': '🚑 Trauma',
      'pickup': 'Village A',
      'patient': 'Adult Male',
      'eta': '12 min',
    },
    {
      'emergencyType': '🤰 Birth',
      'pickup': 'Village B',
      'patient': 'Pregnant Female',
      'eta': '18 min',
    },
    {
      'emergencyType': '🦠 Infection',
      'pickup': 'Clinic C',
      'patient': 'Child, 6 years',
      'eta': '25 min',
    },
    {
      'emergencyType': '⚡ Other',
      'pickup': 'Village D',
      'patient': 'Elderly Female',
      'eta': '30 min',
    },
    {
      'emergencyType': '🚑 Trauma',
      'pickup': 'Highway Junction',
      'patient': 'Adult Female',
      'eta': '10 min',
    },
  ];

  int _currentIndex = 0; // 0 = Home, 1 = Map

  void _onNavItemSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    // TODO: wire up navigation when ambulance tab screens are ready
    // if (index == 0) Navigator.pushNamed(context, '/ambulance-dashboard');
    // if (index == 1) Navigator.pushNamed(context, '/ambulance-map');
  }

  void _openRequestDetail(Map<String, String> request) {
    // Later you can pass request data into the detail screen via constructor
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AmbulanceIncomingDispatchScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Ambulance',
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
      ),
      backgroundColor: AppColors.background,
      endDrawer: AppDrawer(
        onDashboard: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/ambulance-dashboard');
        },
        onSettings: () {
          Navigator.pop(context);
          // TODO: Navigate to settings screen
        },
        onLogout: () async {
          Navigator.pop(context);
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
      bottomNavigationBar: AmbulanceNavigationBar(
        currentIndex: _currentIndex,
        onItemSelected: _onNavItemSelected,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'All Incoming Requests',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      height: 24 / 20,
                      color: AppColors.ambulanceAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _dummyRequests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final request = _dummyRequests[index];
                        return _RequestCard(
                          emergencyType: request['emergencyType'] ?? '',
                          pickup: request['pickup'] ?? '',
                          patient: request['patient'] ?? '',
                          eta: request['eta'] ?? '',
                          onTap: () => _openRequestDetail(request),
                          theme: theme,
                        );
                      },
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

class _RequestCard extends StatelessWidget {
  final String emergencyType;
  final String pickup;
  final String patient;
  final String eta;
  final VoidCallback onTap;
  final ThemeData theme;

  const _RequestCard({
    required this.emergencyType,
    required this.pickup,
    required this.patient,
    required this.eta,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = AppColors.ambulanceAccent;
    final Color chipBg = AppColors.ambulanceAccent.withAlpha(20);
    final Color cardBorder = AppColors.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left column with emergency type, pickup and patient
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emergency type as the main title
                  Text(
                    'Emergency: $emergencyType',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 17 / 14,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pickup: $pickup',
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
                    'Patient: $patient',
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
            // ETA pill on the right, similar to status chip in admin cards
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'ETA: $eta',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  height: 15 / 12,
                  color: primaryGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
