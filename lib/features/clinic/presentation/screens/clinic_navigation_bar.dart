import 'package:flutter/material.dart';
import '../../../common/presentation/widgets/notification_bell_with_badge.dart';
import '../../../common/presentation/screens/notifications_screen.dart';
import '../../../common/presentation/screens/learning_resources_screen.dart';
import 'clinic_incoming_case_screen.dart';

class ClinicNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onItemSelected;

  const ClinicNavigationBar({
    super.key,
    required this.currentIndex,
    this.onItemSelected,
  });

  void _handleTabTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    onItemSelected?.call(index);

    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/clinic-dashboard', (r) => false);
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ClinicIncomingCaseScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningResourcesScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE6E7EB), width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _handleTabTap(context, index),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0077CC),
        unselectedItemColor: const Color(0xFF667085),
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.inbox_outlined),
            activeIcon: Icon(Icons.inbox),
            label: 'Incoming',
          ),
          BottomNavigationBarItem(
            icon: NotificationBellWithBadge(isSelected: currentIndex == 2),
            activeIcon: NotificationBellWithBadge(isSelected: true),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Learn',
          ),
        ],
      ),
    );
  }
}
