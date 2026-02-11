import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/current_user_session.dart';

/// Notification bell icon with unread count badge for navigation bars.
class NotificationBellWithBadge extends StatelessWidget {
  final bool isSelected;

  const NotificationBellWithBadge({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: CurrentUserSession.uid ?? '')
          .where('read', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return Badge(
          isLabelVisible: count > 0,
          label: Text(
            '$count',
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
          child: Icon(
            isSelected ? Icons.notifications : Icons.notifications_outlined,
          ),
        );
      },
    );
  }
}
