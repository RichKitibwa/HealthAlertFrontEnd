import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'vht_navigation_bar.dart';
import 'vht_active_cases_screen.dart';
import 'vht_case_detail_screen.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/screens/notifications_screen.dart';
import '../../../common/presentation/screens/settings_screen.dart';
import '../../../common/presentation/screens/learning_resources_screen.dart';
import '../../../common/presentation/widgets/app_drawer.dart';
import '../../../auth/current_user_session.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/services/recent_cases_service.dart';

// VHT Dashboard Screen
// Main dashboard for Village Health Team members with emergency reporting

class VHTDashboardScreen extends StatefulWidget {
  const VHTDashboardScreen({Key? key}) : super(key: key);

  @override
  State<VHTDashboardScreen> createState() => _VHTDashboardScreenState();
}

class _VHTDashboardScreenState extends State<VHTDashboardScreen> {
  int _currentIndex = 0;

  void _onNavItemSelected(int index) {
    if (index == _currentIndex) return;
    // Navigation is handled by VhtNavigationBar; dashboard is always "home" (index 0)
  }

  Color _getUrgencyColor(String? u) {
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

  Color _getStatusColor(String? s) {
    switch (s?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'advised':
        return Colors.blue;
      case 'ambulancerequested':
        return Colors.deepPurple;
      case 'dispatched':
        return AppColors.clinicAccent;
      case 'enroute':
        return Colors.blue;
      case 'arrived':
        return Colors.green;
      case 'intransit':
        return Colors.indigo;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel(BuildContext context, String? s) {
    final l10n = AppLocalizations.of(context)!;
    switch (s?.toLowerCase()) {
      case 'pending':
        return l10n.pendingReview;
      case 'advised':
        return l10n.clinicianAdvised;
      case 'ambulancerequested':
        return l10n.ambulanceRequested;
      case 'dispatched':
        return l10n.ambulanceDispatched;
      case 'enroute':
        return l10n.ambulanceEnRoute;
      case 'arrived':
        return l10n.ambulanceArrived;
      case 'intransit':
        return l10n.patientInTransit;
      default:
        return s ?? '';
    }
  }

  String _formatTimeAgo(BuildContext context, Timestamp? ts) {
    if (ts == null) return '';
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    final dt = ts.toDate();
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatTimeAgoFromDate(BuildContext context, DateTime ts) {
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${ts.day}/${ts.month}/${ts.year}';
  }

  Widget _buildRecentCasesSection() {
    final l10n = AppLocalizations.of(context)!;
    final uid = CurrentUserSession.uid;
    if (uid == null || uid.isEmpty) return const SizedBox.shrink();

    return FutureBuilder<List<RecentCaseEntry>>(
      future: RecentCasesService.getRecentCasesForUser(uid),
      builder: (context, snapshot) {
        final entries = snapshot.data ?? const <RecentCaseEntry>[];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Loading recent cases...'),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.recentCases,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (entries.isEmpty)
                Text(
                  l10n.noRecentCases,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                )
              else
                Column(
                  children: entries.map((e) {
                    final patientLabel = e.patientName.isNotEmpty
                        ? e.patientName
                        : (e.patientId.isNotEmpty
                              ? e.patientId
                              : (e.caseId.isNotEmpty
                                    ? 'Case: ${e.caseId.length > 6 ? e.caseId.substring(0, 6) : e.caseId}'
                                    : l10n.unknown));
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  VhtCaseDetailScreen(caseId: e.caseId),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.border.withAlpha(160),
                            ),
                            color: AppColors.background.withAlpha(40),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.emergencyType.isNotEmpty
                                          ? e.emergencyType
                                          : l10n.unknown,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      patientLabel,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _formatTimeAgoFromDate(context, e.viewedAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary.withAlpha(170),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Stream<QuerySnapshot> _getActiveCasesStream() {
    final uid = CurrentUserSession.uid;
    if (uid == null || uid.isEmpty) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('emergencyCases')
        .where('vhtId', isEqualTo: uid)
        .where(
          'status',
          whereIn: [
            'pending',
            'advised',
            'ambulanceRequested',
            'dispatched',
            'enRoute',
            'arrived',
            'inTransit',
          ],
        )
        .orderBy('createdAt', descending: true)
        .limit(2)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'VHT',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        pageTitle: l10n.dashboard,
        onSignOut: () async {
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        },
        onDashboard: () {},
        onSettings: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
        onLearningResources: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LearningResourcesScreen()),
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
        onLearningResources: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LearningResourcesScreen()),
          );
        },
        onLogout: () async {
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Welcome message
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.welcomeName(CurrentUserSession.firstName ?? l10n.user),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            // Scrollable main content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Report Emergency primary action
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/create-emergency');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.emergency,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                l10n.reportEmergency,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Active Cases Section
                      _buildActiveCasesSection(),
                      const SizedBox(height: 20),
                      // Recent Cases Section (Return-to-Case)
                      _buildRecentCasesSection(),
                      const SizedBox(height: 20),

                      // Quick Actions header
                      Text(
                        l10n.quickActions,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // View Case History (completed/closed only)
                      _buildActionCard(
                        icon: Icons.description_outlined,
                        iconColor: AppColors.clinicAccent,
                        title: l10n.viewCaseHistory,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const VhtActiveCasesScreen(
                                initialFilter: 'completed',
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Nav Bar
            VhtNavigationBar(
              currentIndex: _currentIndex,
              onItemSelected: _onNavItemSelected,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  /// Active cases section showing up to 2 cases + "View All" button
  Widget _buildActiveCasesSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.activeCases,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const VhtActiveCasesScreen(initialFilter: 'active'),
                  ),
                );
              },
              child: Text(
                l10n.viewAll,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.vhtAccent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        StreamBuilder<QuerySnapshot>(
          stream: _getActiveCasesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.withAlpha(40)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.withAlpha(150),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Could not load active cases.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green.withAlpha(150),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No active cases right now.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final caseId = doc.id;
                final emergencyType =
                    data['emergencyType'] as String? ?? 'Unknown';
                final urgency = data['urgencyLevel'] as String? ?? 'medium';
                final status = data['status'] as String? ?? 'pending';
                final patientId = data['patientId'] as String? ?? '';
                final patientFirstName =
                    data['patientFirstName'] as String? ?? '';
                final patientLastName =
                    data['patientLastName'] as String? ?? '';
                final patientName = '$patientFirstName $patientLastName'.trim();
                final createdAt = data['createdAt'] as Timestamp?;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VhtCaseDetailScreen(caseId: caseId),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: status == 'pending'
                              ? _getUrgencyColor(urgency).withAlpha(50)
                              : AppColors.border,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(6),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Left: type + patient
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      emergencyType,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getUrgencyColor(
                                          urgency,
                                        ).withAlpha(20),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        urgency.toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 9,
                                          color: _getUrgencyColor(urgency),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  patientName.isNotEmpty
                                      ? patientName
                                      : (patientId.isNotEmpty
                                            ? 'ID: $patientId'
                                            : 'No Patient ID'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (createdAt != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatTimeAgo(context, createdAt),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary.withAlpha(
                                        150,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Right: status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withAlpha(18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getStatusColor(status).withAlpha(40),
                              ),
                            ),
                            child: Text(
                              _getStatusLabel(context, status),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: _getStatusColor(status),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
