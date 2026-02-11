import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/current_user_session.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Future<void> _markAsRead(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(docId)
          .update({'read': true});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark as read: $e')),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    final uid = CurrentUserSession.uid;
    if (uid == null || uid.isEmpty) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: uid)
          .where('read', isEqualTo: false)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications marked as read')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark all as read: $e')),
        );
      }
    }
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'case_update':
        return Icons.medical_services;
      case 'dispatch':
        return Icons.local_shipping;
      case 'message':
        return Icons.message;
      case 'alert':
        return Icons.warning_amber;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimeAgo(dynamic createdAt) {
    if (createdAt == null) return '';
    DateTime dt;
    if (createdAt is Timestamp) {
      dt = createdAt.toDate();
    } else if (createdAt is DateTime) {
      dt = createdAt;
    } else {
      return '';
    }
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final uid = CurrentUserSession.uid;
    if (uid == null || uid.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Notifications'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
        ),
        body: const Center(
          child: Text('Please sign in to view notifications'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: Text(
              'Mark All Read',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final sortedDocs = List<QueryDocumentSnapshot>.from(docs)
            ..sort((a, b) {
              final aData = a.data() as Map<String, dynamic>?;
              final bData = b.data() as Map<String, dynamic>?;
              final aTs = aData?['createdAt'];
              final bTs = bData?['createdAt'];
              if (aTs == null && bTs == null) return 0;
              if (aTs == null) return 1;
              if (bTs == null) return -1;
              late DateTime aDt;
              late DateTime bDt;
              if (aTs is Timestamp) {
                aDt = aTs.toDate();
              } else if (aTs is DateTime) {
                aDt = aTs;
              } else {
                aDt = DateTime.now();
              }
              if (bTs is Timestamp) {
                bDt = bTs.toDate();
              } else if (bTs is DateTime) {
                bDt = bTs;
              } else {
                bDt = DateTime.now();
              }
              return bDt.compareTo(aDt);
            });

          if (sortedDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Notifications will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              final doc = sortedDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final title = data['title'] as String? ?? 'Notification';
              final message = data['message'] as String? ?? '';
              final type = data['type'] as String?;
              final read = data['read'] as bool? ?? false;
              final createdAt = data['createdAt'];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.border),
                ),
                child: InkWell(
                  onTap: () => _markAsRead(doc.id),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getIconForType(type),
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        fontWeight: read
                                            ? FontWeight.w500
                                            : FontWeight.w700,
                                        fontSize: 16,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (!read)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              if (message.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  message,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Text(
                                _formatTimeAgo(createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
