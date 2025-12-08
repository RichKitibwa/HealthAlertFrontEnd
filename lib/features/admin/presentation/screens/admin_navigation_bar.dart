import 'package:flutter/material.dart';

/// Global Admin bottom navigation bar that you can import on any
/// admin role page.
///
/// Tabs:
///   0 = Home
///   1 = Reports
///
/// Usage:
/// ```dart
/// class AdminDashboardScreen extends StatefulWidget {
///   const AdminDashboardScreen({super.key});
///
///   @override
///   State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
/// }
///
/// class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
///   int _currentIndex = 0;
///
///   void _onItemSelected(int index) {
///     setState(() => _currentIndex = index);
///     // TODO: wire up navigation for each tab:
///     // if (index == 0) Navigator.pushNamed(context, '/admin-dashboard');
///     // if (index == 1) Navigator.pushNamed(context, '/admin-reports');
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: Container(), // your admin content
///       bottomNavigationBar: AdminNavigationBar(
///         currentIndex: _currentIndex,
///         onItemSelected: _onItemSelected,
///       ),
///     );
///   }
/// }
/// ```
class AdminNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const AdminNavigationBar({
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
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
