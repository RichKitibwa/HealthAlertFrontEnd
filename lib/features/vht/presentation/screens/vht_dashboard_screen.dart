import 'package:flutter/material.dart';
import 'vht_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';
// VHT Dashboard Screen
// Main dashboard for Village Health Team members with emergency reporting

class VHTDashboardScreen extends StatefulWidget {
  const VHTDashboardScreen({Key? key}) : super(key: key);

  @override
  State<VHTDashboardScreen> createState() => _VHTDashboardScreenState();
}

class _VHTDashboardScreenState extends State<VHTDashboardScreen> {
  int _currentIndex = 0; // 0 = Home, 1 = Map, 2 = Patients

  void _onNavItemSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Handle navigation between tabs/routes as needed
    // For now, this keeps you on the dashboard and just updates the selected tab.
    // Later you can add:
    // if (index == 1) Navigator.pushNamed(context, '/vht-map');
    // if (index == 2) Navigator.pushNamed(context, '/vht-patients');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFCFD),
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'VHT',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        onSignOut: () {
          CurrentUserSession.clear();
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Scrollable main content
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Status card: Network / Battery
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE3E8EF),
                              ),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '📡 Network: Online',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF475467),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '🔋 Battery: Good',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF475467),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Report Emergency primary action
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/create-emergency',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0077CC),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                '🚨 Report Emergency',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Quick Actions header
                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF344054),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 📄 View Case History
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE3E8EF),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '📄 View Case History',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF344054),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 📝 Send Follow-up Update
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE3E8EF),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '📝 Send Follow-up Update',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF344054),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ⚙️ Settings
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE3E8EF),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '⚙️ Settings',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF344054),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),

                // Fixed Bottom Nav Bar (Home / Map / Patients)
                VhtNavigationBar(
                  currentIndex: _currentIndex,
                  onItemSelected: _onNavItemSelected,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
