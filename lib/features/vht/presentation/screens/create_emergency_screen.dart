// Create Emergency Case Screen
// VHT creates new emergency case

import 'package:flutter/material.dart';
import 'vht_add_media_screen.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import 'vht_navigation_bar.dart';
import '../../../auth/current_user_session.dart';

class CreateEmergencyScreen extends StatefulWidget {
  const CreateEmergencyScreen({Key? key}) : super(key: key);

  @override
  State<CreateEmergencyScreen> createState() => _CreateEmergencyScreenState();
}

class _CreateEmergencyScreenState extends State<CreateEmergencyScreen> {
  int _currentIndex = 0; // 0 = Home, 1 = Map, 2 = Patients

  void _onNavItemSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    // TODO: wire up navigation if needed
    // Example:
    // if (index == 0) Navigator.pushNamed(context, '/vht-dashboard');
    // if (index == 1) Navigator.pushNamed(context, '/vht-map');
    // if (index == 2) Navigator.pushNamed(context, '/vht-patients');
  }

  void _goToAddMedia(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMediaScreen(emergencyType: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'VHT',
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
      // Figma background: #FBFCFD
      backgroundColor: const Color(0xFFFBFCFD),
      bottomNavigationBar: VhtNavigationBar(
        currentIndex: _currentIndex,
        onItemSelected: _onNavItemSelected,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              const Text(
                'Report Emergency',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  height: 32 / 24,
                  color: Color(0xFF0077CC),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Select the type of emergency',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF667085),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Emergency type cards
              _EmergencyTypeCard(
                icon: '🤰',
                title: 'Birth',
                color: const Color(0xFF0077CC),
                onTap: () => _goToAddMedia('Birth'),
              ),
              const SizedBox(height: 16),
              _EmergencyTypeCard(
                icon: '🚑',
                title: 'Trauma',
                color: const Color(0xFFFF6A3D),
                onTap: () => _goToAddMedia('Trauma'),
              ),
              const SizedBox(height: 16),
              _EmergencyTypeCard(
                icon: '🦠',
                title: 'Infection',
                color: const Color(0xFFFF8A00),
                onTap: () => _goToAddMedia('Infection'),
              ),
              const SizedBox(height: 16),
              _EmergencyTypeCard(
                icon: '⚡',
                title: 'Other',
                color: const Color(0xFF667085),
                onTap: () => _goToAddMedia('Other'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmergencyTypeCard extends StatelessWidget {
  final String icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _EmergencyTypeCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
