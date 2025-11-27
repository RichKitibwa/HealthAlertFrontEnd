import 'package:flutter/material.dart';
// VHT Dashboard Screen
// Main dashboard for Village Health Team members

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
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 360,

            child: Column(
              children: [
                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                  ),
                ),

                const SizedBox(height: 8),

                // TopBar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE6E9EF)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Village Health \u2014 Quick Report',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,

                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE6E9EF)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Report Emergency',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap to start \u2014 voice note or one-tap dispatch',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/vht-create-emergency',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F766E), // #0F766E
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Report Emergency',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // "Recent Cases" label
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Recent Cases',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // RecentCases card ("No open cases")
                // TODO: Connect open cases route
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE6E9EF)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'No open cases',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),

                const Spacer(),

                // Bottom Nav Bar (Home / Cases / Profile)
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
            ),
          ),
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
