// Create Emergency Case Screen
// VHT creates new emergency case

// class CreateEmergencyScreen extends StatefulWidget {
//   // TODO: Create stateful widget
// }

// class _CreateEmergencyScreenState extends State<CreateEmergencyScreen> {

// }

// Create Emergency Case Screen
// VHT creates new emergency case

import 'package:flutter/material.dart';

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
      // Figma background: #FBFCFD
      backgroundColor: const Color(0xFFFBFCFD),
      body: SafeArea(
        child: Center(
          // Figma frame: width 360
          child: SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                // "Select Emergency Type" label
                const Text(
                  'Select Emergency Type',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 16),

                // Cards
                _EmergencyTypeCard(
                  title: 'Birth',
                  subtitle: 'Complications during labor',
                  selected: _selectedType == 'Birth',
                  onTap: () => _selectType('Birth'),
                ),
                _EmergencyTypeCard(
                  title: 'Trauma',
                  subtitle: 'Severe bleeding, fractures',
                  selected: _selectedType == 'Trauma',
                  onTap: () => _selectType('Trauma'),
                ),
                _EmergencyTypeCard(
                  title: 'Infection',
                  subtitle: 'Fever, sepsis risk',
                  selected: _selectedType == 'Infection',
                  onTap: () => _selectType('Infection'),
                ),
                _EmergencyTypeCard(
                  title: 'Other',
                  subtitle: 'Select and add notes',
                  selected: _selectedType == 'Other',
                  onTap: () => _selectType('Other'),
                ),

                const Spacer(),

                // "Next: Location" button at bottom but centered horizontally
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 320,
                      child: ElevatedButton(
                        onPressed: _selectedType == null
                            ? null
                            : () {
                                // TODO: Navigate to Location screen, optionally pass _selectedType
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
                          'Next: Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
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
