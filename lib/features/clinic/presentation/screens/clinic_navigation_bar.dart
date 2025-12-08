import 'package:flutter/material.dart';

/// Global Clinic bottom navigation bar that you can import on any
/// clinic role page.
///
/// Tabs:
///   0 = Home
///   1 = Patients
///   2 = Incoming Requests
///
/// Usage:
/// ```dart
/// Scaffold(
///   body: ...,
///   bottomNavigationBar: ClinicNavigationBar(
///     currentIndex: _currentIndex,
///     onItemSelected: (index) {
///       setState(() => _currentIndex = index);
///       // TODO: wire up navigation per index
///     },
///   ),
/// );
/// ```
class ClinicNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const ClinicNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE6E7EB), width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onItemSelected,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0077CC),
        unselectedItemColor: const Color(0xFF667085),
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            activeIcon: Icon(Icons.people_alt),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox_outlined),
            activeIcon: Icon(Icons.inbox),
            label: 'Incoming',
          ),
        ],
      ),
    );
  }
}
