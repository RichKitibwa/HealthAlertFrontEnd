import 'package:flutter/material.dart';
import 'ambulance_navigation_bar.dart';
import 'ambulance_all_incoming_requests.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';

// Ambulance Driver Dashboard Screen
// Main landing screen for ambulance drivers

class AmbulanceDashboardScreen extends StatefulWidget {
  const AmbulanceDashboardScreen({super.key});

  @override
  State<AmbulanceDashboardScreen> createState() =>
      _AmbulanceDashboardScreenState();
}

class _AmbulanceDashboardScreenState extends State<AmbulanceDashboardScreen> {
  static const Color _primaryBlue = Color(0xFF0077CC);

  int _currentIndex = 0; // 0 = Home, 1 = Map

  void _onNavItemSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    // TODO: wire up navigation as needed
    // Example:
    // if (index == 0) Navigator.pushNamed(context, '/ambulance-dashboard');
    // if (index == 1) Navigator.pushNamed(context, '/ambulance-map');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width >= 600;

    return Scaffold(
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Ambulance',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        showBackButton: false,
        onSignOut: () {
          CurrentUserSession.clear();
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
      ),
      bottomNavigationBar: AmbulanceNavigationBar(
        currentIndex: _currentIndex,
        onItemSelected: _onNavItemSelected,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double horizontalPadding = constraints.maxWidth < 400
                ? 16.0
                : 24.0;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 520 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'View incoming emergency requests from VHTs and clinics.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      // Primary action button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.emergency_share_outlined),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.0),
                            child: Text(
                              'Show Incoming Requests',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AmbulanceAllIncomingRequestsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'You will see a list of open cases assigned to your ambulance, '
                        'including requests created by VHTs and clinics.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
