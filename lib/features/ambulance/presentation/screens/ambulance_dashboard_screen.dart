import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ambulance_navigation_bar.dart';
import 'ambulance_all_incoming_requests.dart';
import 'ambulance_active_cases_screen.dart';
import 'ambulance_incoming_dispatch_screen.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/screens/notifications_screen.dart';
import '../../../common/presentation/screens/settings_screen.dart';
import '../../../common/presentation/widgets/app_drawer.dart';
import '../../../auth/current_user_session.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/user_location_update_service.dart';
import '../../../../l10n/app_localizations.dart';

class AmbulanceDashboardScreen extends StatefulWidget {
  const AmbulanceDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AmbulanceDashboardScreen> createState() =>
      _AmbulanceDashboardScreenState();
}

class _AmbulanceDashboardScreenState extends State<AmbulanceDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    UserLocationUpdateService.startUpdating();
  }

  @override
  void dispose() {
    UserLocationUpdateService.stopUpdating();
    super.dispose();
  }

  void _onNavItemSelected(int index) {
    if (index == _currentIndex) return;
  }

  /// Same query as "View all requests" — we then pick the single most recent for the dashboard card.
  Stream<QuerySnapshot> _latestRequestStream() {
    final uid = CurrentUserSession.uid;
    if (uid == null || uid.isEmpty) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('emergencyCases')
        .where('status', isEqualTo: 'dispatched')
        .where('assignedAmbulanceId', isEqualTo: uid)
        .snapshots();
  }

  Color _urgencyColor(String? u) {
    switch (u?.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.deepOrange;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _emergencyIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'birth':
        return Icons.pregnant_woman_rounded;
      case 'trauma':
        return Icons.local_hospital_rounded;
      case 'infection':
        return Icons.coronavirus_rounded;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  Color _emergencyIconColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'birth':
        return Colors.pink;
      case 'trauma':
        return Colors.red;
      case 'infection':
        return Colors.orange;
      default:
        return Colors.amber;
    }
  }

  String _timeAgo(Timestamp? ts, AppLocalizations l10n) {
    if (ts == null) return '';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.minAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hrAgo(diff.inHours);
    return '${ts.toDate().day}/${ts.toDate().month}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Ambulance',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        showBackButton: false,
        pageTitle: l10n.dashboard,
        onSignOut: () async {
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
          }
        },
        onDashboard: () {},
        onSettings: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
      endDrawer: AppDrawer(
        onDashboard: () {},
        onNotifications: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          );
        },
        onSettings: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
        onLogout: () async {
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
          }
        },
      ),
      bottomNavigationBar: AmbulanceNavigationBar(
        currentIndex: _currentIndex,
        onItemSelected: _onNavItemSelected,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome message
                    Text(
                      l10n.welcomeName(
                        CurrentUserSession.firstName ?? l10n.user,
                      ),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Latest Dispatch Request ──────────────────────────────
                    Text(
                      l10n.latestDispatchRequest,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<QuerySnapshot>(
                      stream: _latestRequestStream(),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const _DispatchShimmer();
                        }

                        final allDocs = snap.data?.docs ?? [];
                        // Pick single most recent by dispatchedAt or createdAt (same logic as View all requests)
                        final doc = allDocs.isEmpty
                            ? null
                            : (() {
                                final sorted = List.of(allDocs)
                                  ..sort((a, b) {
                                    final aData =
                                        a.data() as Map<String, dynamic>;
                                    final bData =
                                        b.data() as Map<String, dynamic>;
                                    final aT =
                                        aData['dispatchedAt'] as Timestamp? ??
                                        aData['createdAt'] as Timestamp?;
                                    final bT =
                                        bData['dispatchedAt'] as Timestamp? ??
                                        bData['createdAt'] as Timestamp?;
                                    if (aT == null && bT == null) return 0;
                                    if (aT == null) return 1;
                                    if (bT == null) return -1;
                                    return bT.compareTo(aT);
                                  });
                                return sorted.first;
                              })();

                        if (doc == null) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: Colors.green.shade400,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    l10n.noNewDispatchRequests,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final data = doc.data() as Map<String, dynamic>;
                        final caseId = doc.id;
                        final emergencyType =
                            data['emergencyType'] as String? ?? 'Unknown';
                        final urgency =
                            data['urgencyLevel'] as String? ?? 'medium';
                        final patientFirst =
                            data['patientFirstName'] as String? ?? '';
                        final patientLast =
                            data['patientLastName'] as String? ?? '';
                        final patientAge = data['patientAge'] as int?;
                        final patientGender =
                            data['patientGender'] as String? ?? '';
                        final vhtName = data['vhtName'] as String? ?? '';
                        final clinicName =
                            data['assignedClinicName'] as String? ?? '';
                        final dispatchedAt = data['dispatchedAt'] as Timestamp?;
                        final patientName = '$patientFirst $patientLast'.trim();

                        String patientDesc = '';
                        if (patientGender.isNotEmpty) {
                          patientDesc =
                              patientGender[0].toUpperCase() +
                              patientGender.substring(1);
                        }
                        if (patientAge != null) {
                          patientDesc += patientDesc.isNotEmpty
                              ? ', $patientAge yrs'
                              : '$patientAge yrs';
                        }
                        if (patientDesc.isEmpty) patientDesc = 'Unknown';

                        return InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AmbulanceIncomingDispatchScreen(
                                caseId: caseId,
                              ),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _urgencyColor(urgency).withAlpha(50),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(6),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _emergencyIcon(emergencyType),
                                      size: 20,
                                      color: _emergencyIconColor(emergencyType),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        emergencyType,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: AppColors.ambulanceAccent,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _urgencyColor(
                                          urgency,
                                        ).withAlpha(20),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        urgency.toUpperCase(),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                          color: _urgencyColor(urgency),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                if (patientName.isNotEmpty)
                                  Text(
                                    '${l10n.patientLabel}: $patientName',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                Text(
                                  patientDesc,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (vhtName.isNotEmpty)
                                      Text(
                                        'VHT: $vhtName',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    if (clinicName.isNotEmpty) ...[
                                      Text(
                                        ' • ',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          '${l10n.destination}: $clinicName',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                    const Spacer(),
                                    if (dispatchedAt != null)
                                      Text(
                                        _timeAgo(dispatchedAt, l10n),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary
                                              .withAlpha(150),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── View all incoming requests ───────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AmbulanceAllIncomingRequestsScreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.list_alt_rounded,
                          size: 20,
                          color: AppColors.ambulanceAccent,
                        ),
                        label: Text(
                          l10n.viewAllRequests,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ambulanceAccent,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          side: BorderSide(color: AppColors.ambulanceAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Active Cases ─────────────────────────────────────────
                    Text(
                      l10n.activeCases,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AmbulanceActiveCasesScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.assignment_rounded, size: 20),
                        label: Text(
                          l10n.viewActiveCases,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: AppColors.border),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AmbulanceActiveCasesScreen(
                                showCompleted: true,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.history_rounded, size: 20),
                        label: Text(
                          l10n.completedCases,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ambulanceAccent,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.ambulanceAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(
                            color: AppColors.ambulanceAccent.withAlpha(150),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DispatchShimmer extends StatelessWidget {
  const _DispatchShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
