// Create Emergency Case Screen
// VHT creates new emergency case

import 'package:flutter/material.dart';
import 'vht_add_media_screen.dart';

class CreateEmergencyScreen extends StatefulWidget {
  const CreateEmergencyScreen({Key? key}) : super(key: key);

  @override
  State<CreateEmergencyScreen> createState() => _CreateEmergencyScreenState();
}

class _CreateEmergencyScreenState extends State<CreateEmergencyScreen> {
  String? _selectedType;

  void _selectType(String type) {
    setState(() {
      _selectedType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF0077CC),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      // Figma background: #FBFCFD
      backgroundColor: const Color(0xFFFBFCFD),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 26,
              top: 16,
              child: SizedBox(
                width: 360,
                height: 640,
                child: Stack(
                  children: [
                    // Full frame background (#F7F9FC)
                    Positioned.fill(
                      child: Container(color: const Color(0xFFF7F9FC)),
                    ),

                    // Top white bar (Vector: top 0%, bottom ~90.62%)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: 60,
                      child: Container(color: Colors.white),
                    ),

                    // Back button
                    Positioned(
                      left: 0,
                      top: 12,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: const Color(0xFF0077CC),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    // Blue square with "V"
                    // TODO: Clickable profile to switch between roles
                    Positioned(
                      left: 10, // ~2.78% of 360
                      top: 12, // ~1.88% of 640
                      width: 36,
                      height: 36,
                      child: Container(
                        color: const Color(0xFF0077CC),
                        child: const Center(
                          child: Text(
                            'V',
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
                    ),

                    // "Report Emergency" title
                    const Positioned(
                      left: 0,
                      right: 0,
                      top: 14,
                      child: Center(
                        child: Text(
                          'Report Emergency',
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
                    ),

                    // Main white card (Vector: left/right 5.56%, top 12.5%, bottom 31.25%)
                    Positioned(
                      left: 20,
                      right: 20,
                      top: 80,
                      height: 360,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE3E8EF)),
                        ),
                      ),
                    ),

                    // 🤰 Birth (blue bar)
                    Positioned(
                      left: 40, // 11.11%
                      right: 40,
                      top: 100, // 15.62%
                      height: 64,
                      child: GestureDetector(
                        onTap: () => _selectType('Birth'),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _selectedType == 'Birth'
                                ? const Color(0xFF0077CC)
                                : const Color(0xFF0077CC).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '🤰 Birth',
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

                    // 🚑 Trauma (orange-red bar)
                    Positioned(
                      left: 40,
                      right: 40,
                      top: 180, // 28.12%
                      height: 64,
                      child: GestureDetector(
                        onTap: () => _selectType('Trauma'),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _selectedType == 'Trauma'
                                ? const Color(0xFFFF6A3D)
                                : const Color(0xFFFF6A3D).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '🚑 Trauma',
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

                    // 🦠 Infection (orange bar)
                    Positioned(
                      left: 40,
                      right: 40,
                      top: 260, // 40.62%
                      height: 64,
                      child: GestureDetector(
                        onTap: () => _selectType('Infection'),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _selectedType == 'Infection'
                                ? const Color(0xFFFF8A00)
                                : const Color(0xFFFF8A00).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '🦠 Infection',
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

                    // ⚡ Other (gray bar)
                    Positioned(
                      left: 40,
                      right: 40,
                      top: 340, // 53.12%
                      height: 64,
                      child: GestureDetector(
                        onTap: () => _selectType('Other'),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _selectedType == 'Other'
                                ? const Color(0xFF667085)
                                : const Color(0xFF667085).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '⚡ Other',
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

                    // 🚨 Dispatch Now button
                    Positioned(
                      left: 60, // 16.67%
                      right: 60,
                      bottom: 16, // anchor to bottom of the 640 frame
                      height: 64,
                      child: GestureDetector(
                        onTap: () {
                          if (_selectedType == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select an emergency type first.',
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddMediaScreen(
                                  emergencyType: _selectedType!,
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0077CC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              '🚨 Dispatch Now',
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _EmergencyTypeCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Center(
        child: SizedBox(
          width: 320,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  // Default #E6E7EB, highlight with green when selected
                  color: selected
                      ? const Color(0xFF0F766E)
                      : const Color(0xFFE6E7EB),
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
