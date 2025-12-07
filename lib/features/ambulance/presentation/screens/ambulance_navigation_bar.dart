import 'package:flutter/material.dart';

/// Global Ambulance bottom navigation bar that you can import on any
/// ambulance role page.
///
/// Usage:
///
/// Scaffold(
///   body: ...,
///   bottomNavigationBar: AmbulanceNavigationBar(
///     currentIndex: 0, // 0 = Home, 1 = Map
///     onItemSelected: (index) {
///       // handle navigation based on index
///     },
///   ),
/// );
class AmbulanceNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const AmbulanceNavigationBar({
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
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
      ),
    );
  }
}
