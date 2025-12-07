import 'package:flutter/material.dart';
import 'ambulance_incoming_dispatch_screen.dart';
import 'ambulance_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';

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
        onSignOut: () {
          CurrentUserSession.clear();
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
      ),
      backgroundColor: const Color(0xFFFBFCFD),
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
                      color: Color(0xFF0077CC),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Emergency Type: $emergencyType',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF0077CC),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pickup: $pickup',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF0077CC),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Patient: $patient',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF0077CC),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ETA: $eta',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF0077CC),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
