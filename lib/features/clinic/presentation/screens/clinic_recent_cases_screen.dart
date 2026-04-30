import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/recent_cases_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../auth/current_user_session.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/drawer_helpers.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/screens/settings_screen.dart';
import '../../../common/presentation/screens/learning_resources_screen.dart';
import 'clinic_case_detail_screen.dart';
import 'clinic_navigation_bar.dart';

class ClinicRecentCasesScreen extends StatefulWidget {
  const ClinicRecentCasesScreen({super.key});

  @override
  State<ClinicRecentCasesScreen> createState() => _ClinicRecentCasesScreenState();
}

class _ClinicRecentCasesScreenState extends State<ClinicRecentCasesScreen> {
  static const _terminalStatuses = {'completed', 'cancelled', 'discharged'};

  late Future<List<RecentCaseEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = _loadActiveEntries();
  }

  void _reload() => setState(() => _entriesFuture = _loadActiveEntries());

  Future<List<RecentCaseEntry>> _loadActiveEntries() async {
    final uid = CurrentUserSession.uid;
    if (uid == null || uid.isEmpty) return const [];

    final entries = await RecentCasesService.getRecentCasesForUser(uid);
    if (entries.isEmpty) return const [];

    // Fetch statuses from Firestore in parallel.
    final snapshots = await Future.wait(
      entries.map(
        (e) => FirebaseFirestore.instance
            .collection('emergencyCases')
            .doc(e.caseId)
            .get(),
      ),
    );

    final completedIds = <String>{};
    final active = <RecentCaseEntry>[];

    for (var i = 0; i < entries.length; i++) {
      final snap = snapshots[i];
      if (!snap.exists) {
        // Document gone — treat as completed.
        completedIds.add(entries[i].caseId);
        continue;
      }
      final data = snap.data();
      final status = (data?['status'] as String? ?? '').toLowerCase();
      if (_terminalStatuses.contains(status)) {
        completedIds.add(entries[i].caseId);
      } else {
        active.add(entries[i]);
      }
    }

    // Silently clean up local storage.
    if (completedIds.isNotEmpty) {
      await RecentCasesService.removeCompletedCases(
        userId: uid,
        completedCaseIds: completedIds,
      );
    }

    return active;
  }

  Color _getUrgencyColor(String? urgency) {
    switch (urgency?.toLowerCase()) {
      case 'critical': return Colors.red;
      case 'high': return Colors.deepOrange;
      case 'medium': return Colors.orange;
      case 'low': return Colors.green;
      default: return AppColors.textSecondary;
    }
  }

  String _timeAgo(BuildContext context, DateTime dt) {
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.minAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hrAgo(diff.inHours);
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _subtitle(RecentCaseEntry e) {
    if (e.patientName.isNotEmpty) {
      return e.patientId.isNotEmpty
          ? '${e.patientName} · ${e.patientId}'
          : e.patientName;
    }
    if (e.patientId.isNotEmpty) return 'Patient ID: ${e.patientId}';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Clinic',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        pageTitle: l10n.recentCases,
        showBackButton: true,
        onBack: () => Navigator.pop(context),
        onSignOut: () async {
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
          }
        },
        onDashboard: () =>
            Navigator.pushNamedAndRemoveUntil(context, '/clinic-dashboard', (r) => false),
        onSettings: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
        onLearningResources: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningResourcesScreen())),
      ),
      endDrawer: buildStandardDrawer(context: context, dashboardRoute: '/clinic-dashboard'),
      bottomNavigationBar: ClinicNavigationBar(
        currentIndex: 0,
        onItemSelected: (i) {
          if (i == 0) {
            Navigator.pushNamedAndRemoveUntil(context, '/clinic-dashboard', (r) => false);
          }
        },
      ),
      body: SafeArea(
        child: FutureBuilder<List<RecentCaseEntry>>(
          future: _entriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off_rounded, size: 56,
                          color: AppColors.textSecondary.withAlpha(100)),
                      const SizedBox(height: 16),
                      Text(
                        l10n.errorLoadingCases,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please check your connection and try again.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: _reload,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Retry'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.clinicAccent),
                          foregroundColor: AppColors.clinicAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final entries = snapshot.data ?? const [];

            if (entries.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_rounded, size: 64,
                          color: AppColors.textSecondary.withAlpha(80)),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noRecentCases,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Active cases you open will appear here for quick access.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    '${entries.length} active case${entries.length == 1 ? '' : 's'}',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final e = entries[index];
                      return _RecentCaseCard(
                        entry: e,
                        subtitle: _subtitle(e),
                        timeAgo: _timeAgo(context, e.viewedAt),
                        urgencyColor: _getUrgencyColor(null),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ClinicCaseDetailScreen(caseId: e.caseId),
                            ),
                          );
                          // Refresh after returning — case status may have changed.
                          _reload();
                        },
                        onDismiss: () async {
                          final uid = CurrentUserSession.uid;
                          if (uid != null) {
                            await RecentCasesService.removeCaseFromRecent(
                              userId: uid,
                              caseId: e.caseId,
                            );
                          }
                          _reload();
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RecentCaseCard extends StatelessWidget {
  final RecentCaseEntry entry;
  final String subtitle;
  final String timeAgo;
  final Color urgencyColor;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _RecentCaseCard({
    required this.entry,
    required this.subtitle,
    required this.timeAgo,
    required this.urgencyColor,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(entry.caseId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(200),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      onDismissed: (_) => onDismiss(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.clinicAccent.withAlpha(18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.medical_services_outlined,
                    color: AppColors.clinicAccent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.emergencyType.isNotEmpty ? entry.emergencyType : 'Emergency',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: AppColors.clinicAccent),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      'Last viewed $timeAgo',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary.withAlpha(160)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
