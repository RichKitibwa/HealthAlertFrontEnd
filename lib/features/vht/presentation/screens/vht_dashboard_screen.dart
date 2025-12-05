import 'package:flutter/material.dart';

// VHT Dashboard Screen
// Main dashboard for Village Health Team members with emergency reporting

class VHTDashboardScreen extends StatefulWidget {
  const VHTDashboardScreen({Key? key}) : super(key: key);

  @override
  State<VHTDashboardScreen> createState() => _VHTDashboardScreenState();
}

class _VHTDashboardScreenState extends State<VHTDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFCFD),
      appBar: AppBar(
        title: const Text('VHT Dashboard'),
        centerTitle: false,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () {
              // Navigate back to login screen and clear the stack
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
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
                          // Header bar with V icon and "VHT Dashboard"
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE3E8EF),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0077CC),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'V',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'VHT Dashboard',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                      color: Color(0xFF0077CC),
                                    ),
                                  ),
                                ),
                                // Spacer box to visually balance the left "V" icon
                                const SizedBox(width: 32),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

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

                // Fixed Bottom Nav Bar (Home / Cases / Profile)
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Color(0xFFE6E7EB), width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _BottomNavLabel(label: 'Home'),
                      _BottomNavLabel(label: 'Cases'),
                      _BottomNavLabel(label: 'Profile'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BottomNavLabel extends StatelessWidget {
  final String label;

  const _BottomNavLabel({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
    );
  }
}
