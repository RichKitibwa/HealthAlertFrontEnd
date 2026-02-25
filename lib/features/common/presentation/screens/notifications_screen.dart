import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/current_user_session.dart';
import '../../../../core/widgets/back_handling_pop_scope.dart';

import '../../../vht/presentation/screens/vht_navigation_bar.dart';
import '../../../vht/presentation/screens/vht_case_detail_screen.dart';
import '../../../ambulance/presentation/screens/ambulance_navigation_bar.dart';
import '../../../ambulance/presentation/screens/ambulance_incoming_dispatch_screen.dart';
import '../../../ambulance/presentation/screens/ambulance_en_route_screen.dart';
import '../../../clinic/presentation/screens/clinic_navigation_bar.dart';
import '../../../clinic/presentation/screens/clinic_case_detail_screen.dart';
import '../../../admin/presentation/screens/admin_navigation_bar.dart';
import '../../../admin/presentation/screens/admin_case_timeline.dart';

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
          SnackBar(content: Text('${AppLocalizations.of(context)!.failedToMarkAsRead}: $e')),
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
          SnackBar(content: Text(AppLocalizations.of(context)!.allNotificationsMarkedAsRead)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.failedToMarkAllAsRead}: $e')),
        );
      }
    }
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'new_case':
        return Icons.medical_services_rounded;
      case 'case_submitted':
        return Icons.check_circle_rounded;
      case 'vht_follow_up':
        return Icons.update_rounded;
      case 'clinician_advice':
        return Icons.tips_and_updates_rounded;
      case 'dispatch_request':
        return Icons.local_shipping_outlined;
      case 'ambulance_request_standby':
        return Icons.notification_important_rounded;
      case 'ambulance_dispatched':
      case 'dispatch_assigned':
        return Icons.local_shipping_rounded;
      case 'patient_delivered':
      case 'patient_arriving':
        return Icons.local_hospital_rounded;
      case 'patient_discharged':
      case 'case_completed':
        return Icons.verified_rounded;
      case 'case_closed':
        return Icons.check_circle_outline_rounded;
      case 'dispatch':
        return Icons.local_shipping_rounded;
      case 'case_update':
        return Icons.refresh_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColorForType(String? type) {
    switch (type) {
      case 'new_case':
      case 'dispatch_request':
      case 'ambulance_request_standby':
        return Colors.red;
      case 'clinician_advice':
      case 'vht_follow_up':
        return Colors.blue;
      case 'ambulance_dispatched':
      case 'dispatch_assigned':
        return AppColors.ambulanceAccent;
      case 'patient_delivered':
      case 'patient_arriving':
        return Colors.teal;
      case 'patient_discharged':
      case 'case_completed':
      case 'case_closed':
      case 'case_submitted':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  /// Navigate to the relevant screen based on notification type and user role.
  void _handleNotificationTap(BuildContext context, String docId, Map<String, dynamic> data) {
    // Mark as read first
    _markAsRead(docId);

    final caseId = data['caseId'] as String?;
    final type = data['type'] as String?;
    final role = CurrentUserSession.role ?? '';

    if (caseId == null || caseId.isEmpty) return;

    // Route based on role
    if (role == 'VHT') {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => VhtCaseDetailScreen(caseId: caseId),
      ));
    } else if (role == 'Ambulance Driver' || role == 'Ambulance') {
      // For dispatch assignment / standby → show incoming dispatch screen
      // For already en route cases → show en route screen
      if (type == 'dispatch_assigned' || type == 'ambulance_request_standby') {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => AmbulanceIncomingDispatchScreen(caseId: caseId),
        ));
      } else {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => AmbulanceEnRouteScreen(caseId: caseId),
        ));
      }
    } else if (role == 'Clinic' || role == 'Clinic Staff' || role == 'Clinician') {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => ClinicCaseDetailScreen(caseId: caseId),
      ));
    } else if (role == 'Admin') {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => AdminCaseTimelineScreen(caseId: caseId),
      ));
    }
  }

  String _formatTimeAgo(BuildContext context, dynamic createdAt) {
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
    if (diff.inSeconds < 60) return AppLocalizations.of(context)!.justNow;
    if (diff.inMinutes < 60) return AppLocalizations.of(context)!.minAgo(diff.inMinutes);
    if (diff.inHours < 24) return AppLocalizations.of(context)!.hrAgo(diff.inHours);
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Widget _buildBody(BuildContext context, String uid) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              l10n.errorGeneric(snapshot.error.toString()),
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
                  l10n.noNotificationsYet,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.notificationsWillAppearHere,
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
            final title = data['title'] as String? ?? l10n.notificationFallbackTitle;
            final message = data['message'] as String? ?? '';
            final type = data['type'] as String?;
            final read = data['read'] as bool? ?? false;
            final createdAt = data['createdAt'];
            final caseId = data['caseId'] as String?;
            final hasAction = caseId != null && caseId.isNotEmpty;
            final iconColor = _getColorForType(type);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: read ? AppColors.surface : iconColor.withAlpha(8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: read ? AppColors.border : iconColor.withAlpha(40),
                ),
              ),
              child: InkWell(
                onTap: () => _handleNotificationTap(context, doc.id, data),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: iconColor.withAlpha(18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_getIconForType(type), color: iconColor, size: 22),
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
                                      fontWeight: read ? FontWeight.w500 : FontWeight.w700,
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (!read)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: iconColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            if (message.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                message,
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                  _formatTimeAgo(context, createdAt),
                                  style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                                ),
                                if (hasAction) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.tapToViewCase,
                                    style: TextStyle(fontSize: 11, color: iconColor, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (hasAction) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 18),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = CurrentUserSession.uid;
    if (uid == null || uid.isEmpty) {
      return BackHandlingPopScope(
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.notifications),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  final role = CurrentUserSession.role?.toLowerCase() ?? '';
                  String route = '/login';
                  if (role == 'admin') route = '/admin-dashboard';
                  else if (role == 'vht') route = '/vht-dashboard';
                  else if (role.contains('clinic')) route = '/clinic-dashboard';
                  else if (role.contains('ambulance')) route = '/ambulance-dashboard';
                  Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
                }
              },
            ),
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
          ),
          body: Center(child: Text(AppLocalizations.of(context)!.pleaseSignInToViewNotifications)),
        ),
      );
    }

    Widget? bottomNav;

    switch (CurrentUserSession.role) {
      case 'VHT':
        bottomNav = VhtNavigationBar(
          currentIndex: 1,
          onItemSelected: (index) {},
        );
        break;
      case 'Ambulance':
      case 'Ambulance Driver':
        bottomNav = AmbulanceNavigationBar(
          currentIndex: 1,
          onItemSelected: (index) {},
        );
        break;
      case 'Clinic':
      case 'Clinic Staff':
        bottomNav = ClinicNavigationBar(
          currentIndex: 2,
          onItemSelected: (index) {},
        );
        break;
      case 'Admin':
        bottomNav = AdminNavigationBar(
          currentIndex: 1, // Admin nav: 0=Home, 1=Notifications, 2=Analytics, 3=Users
          onItemSelected: (index) {},
        );
        break;
      default:
        bottomNav = null;
    }

    return BackHandlingPopScope(
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notifications),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              final role = CurrentUserSession.role?.toLowerCase() ?? '';
              String route = '/login';
              if (role == 'admin') route = '/admin-dashboard';
              else if (role == 'vht') route = '/vht-dashboard';
              else if (role.contains('clinic')) route = '/clinic-dashboard';
              else if (role.contains('ambulance')) route = '/ambulance-dashboard';
              Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
            }
          },
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: Text(
              AppLocalizations.of(context)!.markAllRead,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomNav,
      body: _buildBody(context, uid),
    ),
    );
  }
}
