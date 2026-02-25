import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../common/presentation/widgets/notification_bell_with_badge.dart';
import '../../../common/presentation/screens/notifications_screen.dart';
import '../../../common/presentation/screens/learning_resources_screen.dart';
import '../../../common/presentation/screens/map_screen.dart';

class VhtNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onItemSelected;

  const VhtNavigationBar({
    super.key,
    required this.currentIndex,
    this.onItemSelected,
  });

  void _handleTabTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    onItemSelected?.call(index);

    switch (index) {
      case 0:
        // Home - clear all routes and go to dashboard
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          '/vht-dashboard',
          (route) => false,
        );
        break;
      case 1:
        // Push (like hamburger menu) so back button pops to dashboard
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LearningResourcesScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MapScreen(title: AppLocalizations.of(context)!.areaMap)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.homeLabel,
          ),
          BottomNavigationBarItem(
            icon: NotificationBellWithBadge(isSelected: currentIndex == 1),
            activeIcon: NotificationBellWithBadge(isSelected: true),
            label: l10n.notifications,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book_outlined),
            activeIcon: const Icon(Icons.menu_book),
            label: l10n.learnLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined),
            activeIcon: const Icon(Icons.map),
            label: l10n.mapLabel,
          ),
        ],
      ),
    );
  }
}
