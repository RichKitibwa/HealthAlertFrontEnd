import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../l10n/app_localizations.dart';
import 'admin_navigation_bar.dart';
import 'admin_all_cases_list_screen.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/screens/settings_screen.dart';
import '../../../auth/current_user_session.dart';
import '../../../../core/utils/drawer_helpers.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_handling_pop_scope.dart';
import '../../../../core/constants/health_facility_constants.dart';
import '../../utils/admin_reports_export.dart';

class AdminCaseAnalyticsScreen extends StatefulWidget {
  final String? caseId;

  const AdminCaseAnalyticsScreen({super.key, this.caseId});

  @override
  State<AdminCaseAnalyticsScreen> createState() => _AdminCaseAnalyticsScreenState();
}

class _AdminCaseAnalyticsScreenState extends State<AdminCaseAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Returns the camp a facility belongs to, or 'Unassigned'.
  String _campForFacility(String facilityName) {
    if (HealthFacilityConstants.imvepiFacilities.contains(facilityName)) {
      return HealthFacilityConstants.imvepiCamp;
    }
    if (HealthFacilityConstants.rhinoFacilities.contains(facilityName)) {
      return HealthFacilityConstants.rhinoCamp;
    }
    return 'Unassigned';
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'birth':
        return Colors.pink;
      case 'trauma':
        return Colors.orange;
      case 'infection':
        return Colors.purple;
      default:
        return AppColors.adminAccent;
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    return BackHandlingPopScope(
      dashboardRoute: '/admin-dashboard',
      child: Scaffold(
        appBar: TopNavigationBar(
          role: CurrentUserSession.role ?? 'Admin',
          profileImageUrl: CurrentUserSession.profileImageUrl,
          pageTitle: 'Analytics',
          showBackButton: true,
          onBack: () {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/admin-dashboard', (route) => false);
            }
          },
          onSignOut: () async {
            await LogoutUtils.logout();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            }
          },
          onDashboard: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/admin-dashboard', (route) => false);
          },
          onSettings: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()));
          },
          onReports: () {},
          onAnalytics: () {},
        ),
        backgroundColor: AppColors.background,
        endDrawer: buildStandardDrawer(
            context: context, dashboardRoute: '/admin-dashboard'),
        bottomNavigationBar: AdminNavigationBar(currentIndex: 2),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Case Analytics',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Real-time emergency response overview.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.adminAccent,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.adminAccent,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Settlements'),
                        Tab(text: 'Facilities'),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _OverviewTab(
                      campForFacility: _campForFacility,
                      getTypeColor: _getTypeColor,
                    ),
                    _SettlementsTab(
                      campForFacility: _campForFacility,
                      getUrgencyColor: _getUrgencyColor,
                    ),
                    _FacilitiesTab(campForFacility: _campForFacility),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 — OVERVIEW
// ─────────────────────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final String Function(String) campForFacility;
  final Color Function(String) getTypeColor;

  const _OverviewTab({
    required this.campForFacility,
    required this.getTypeColor,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('emergencyCases').snapshots(),
      builder: (context, snapshot) {
        final l10n = AppLocalizations.of(context)!;
        String typeLabel(String t) {
          switch (t.toLowerCase()) {
            case 'birth': return l10n.birth;
            case 'trauma': return l10n.trauma;
            case 'infection': return l10n.infection;
            case 'other': return l10n.other;
            default: return t;
          }
        }
        String urgencyLabel(String u) {
          switch (u.toLowerCase()) {
            case 'critical': return l10n.critical;
            case 'high': return l10n.high;
            case 'medium': return l10n.moderate;
            case 'low': return l10n.low;
            default: return u;
          }
        }
        int totalCases = 0;
        int activeCases = 0;
        int completedCases = 0;
        int criticalCases = 0;
        final Map<String, int> typeCount = {};
        final Map<String, int> urgencyCount = {};
        int unassignedCases = 0;

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          totalCases = docs.length;
          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = (data['status'] as String? ?? '').toLowerCase();
            final urgency =
                (data['urgencyLevel'] as String? ?? 'medium').toLowerCase();
            final type = data['emergencyType'] as String? ?? 'Other';
            final assignedClinic =
                data['assignedClinicId'] as String? ?? '';

            if (['completed', 'cancelled', 'delivered'].contains(status)) {
              completedCases++;
            } else {
              activeCases++;
            }
            if (urgency == 'critical') criticalCases++;
            if (assignedClinic.isEmpty) unassignedCases++;

            typeCount[type] = (typeCount[type] ?? 0) + 1;
            urgencyCount[urgency] = (urgencyCount[urgency] ?? 0) + 1;
          }
        }

        final resolutionRate = totalCases > 0
            ? (completedCases / totalCases * 100).toStringAsFixed(0)
            : '0';

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Stat grid ─────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const AdminAllCasesListScreen())),
                          child: _StatCard(
                              label: l10n.totalCases,
                              value: '$totalCases',
                              color: AppColors.adminAccent),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AdminAllCasesListScreen(
                                      filterStatus: 'active'))),
                          child: _StatCard(
                              label: l10n.activeFilter,
                              value: '$activeCases',
                              color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AdminAllCasesListScreen(
                                      filterStatus: 'completed'))),
                          child: _StatCard(
                              label: l10n.completedFilter,
                              value: '$completedCases',
                              color: Colors.green),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                            label: l10n.critical,
                            value: '$criticalCases',
                            color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: l10n.resolutionRate,
                          value: '$resolutionRate%',
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: l10n.unassigned,
                          value: '$unassignedCases',
                          color: unassignedCases > 0
                              ? Colors.deepOrange
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Cases by type ─────────────────────────────────────
                  _SectionCard(
                    title: l10n.casesByType,
                    icon: Icons.category_outlined,
                    child: typeCount.isEmpty
                        ? _EmptyHint(l10n.noCasesFound)
                        : Column(
                            children: typeCount.entries.map((entry) {
                              final pct = totalCases > 0
                                  ? entry.value / totalCases
                                  : 0.0;
                              return _BarRow(
                                label: typeLabel(entry.key),
                                count: entry.value,
                                total: totalCases,
                                fraction: pct,
                                color: getTypeColor(entry.key),
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // ── Urgency distribution ──────────────────────────────
                  _SectionCard(
                    title: l10n.urgencyDistribution,
                    icon: Icons.priority_high_rounded,
                    child: urgencyCount.isEmpty
                        ? _EmptyHint('No urgency data yet.')
                        : Column(
                            children: [
                              for (final level in [
                                'critical',
                                'high',
                                'medium',
                                'low'
                              ])
                                if (urgencyCount.containsKey(level))
                                  _BarRow(
                                    label: urgencyLabel(level),
                                    count: urgencyCount[level]!,
                                    total: totalCases,
                                    fraction: totalCases > 0
                                        ? urgencyCount[level]! / totalCases
                                        : 0,
                                    color: _urgencyColor(level),
                                  ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 20),

                  // ── Export ────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => exportReportsPdf(context),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: Text(l10n.exportReports),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.adminAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 6,
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _urgencyColor(String level) {
    switch (level) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.deepOrange;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String _capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2 — SETTLEMENTS
// ─────────────────────────────────────────────────────────────────────────────
class _SettlementsTab extends StatelessWidget {
  final String Function(String) campForFacility;
  final Color Function(String) getUrgencyColor;

  const _SettlementsTab({
    required this.campForFacility,
    required this.getUrgencyColor,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('emergencyCases').snapshots(),
      builder: (context, snapshot) {
        // Per-camp counters
        final Map<String, int> campTotal = {
          HealthFacilityConstants.imvepiCamp: 0,
          HealthFacilityConstants.rhinoCamp: 0,
        };
        final Map<String, int> campActive = {
          HealthFacilityConstants.imvepiCamp: 0,
          HealthFacilityConstants.rhinoCamp: 0,
        };
        final Map<String, int> campCompleted = {
          HealthFacilityConstants.imvepiCamp: 0,
          HealthFacilityConstants.rhinoCamp: 0,
        };
        final Map<String, int> campCritical = {
          HealthFacilityConstants.imvepiCamp: 0,
          HealthFacilityConstants.rhinoCamp: 0,
        };
        // Per-camp emergency type breakdown
        final Map<String, Map<String, int>> campTypeBreakdown = {
          HealthFacilityConstants.imvepiCamp: {},
          HealthFacilityConstants.rhinoCamp: {},
        };

        int totalAssigned = 0;

        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final facilityName =
                data['assignedClinicName'] as String? ?? '';
            final camp = campForFacility(facilityName);
            if (!campTotal.containsKey(camp)) continue;

            final status =
                (data['status'] as String? ?? '').toLowerCase();
            final urgency =
                (data['urgencyLevel'] as String? ?? '').toLowerCase();
            final type = data['emergencyType'] as String? ?? 'Other';

            campTotal[camp] = (campTotal[camp] ?? 0) + 1;
            totalAssigned++;

            if (['completed', 'cancelled', 'delivered'].contains(status)) {
              campCompleted[camp] = (campCompleted[camp] ?? 0) + 1;
            } else {
              campActive[camp] = (campActive[camp] ?? 0) + 1;
            }
            if (urgency == 'critical') {
              campCritical[camp] = (campCritical[camp] ?? 0) + 1;
            }
            campTypeBreakdown[camp]![type] =
                (campTypeBreakdown[camp]![type] ?? 0) + 1;
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final camp in HealthFacilityConstants.camps) ...[
                    _CampSummaryCard(
                      campName: camp,
                      total: campTotal[camp] ?? 0,
                      active: campActive[camp] ?? 0,
                      completed: campCompleted[camp] ?? 0,
                      critical: campCritical[camp] ?? 0,
                      totalAllCamps: totalAssigned,
                      typeBreakdown: campTypeBreakdown[camp] ?? {},
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (totalAssigned == 0)
                    _EmptyHint(
                        'No cases assigned to facilities yet.\nCases will appear here once VHTs submit emergencies.'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CampSummaryCard extends StatelessWidget {
  final String campName;
  final int total;
  final int active;
  final int completed;
  final int critical;
  final int totalAllCamps;
  final Map<String, int> typeBreakdown;

  const _CampSummaryCard({
    required this.campName,
    required this.total,
    required this.active,
    required this.completed,
    required this.critical,
    required this.totalAllCamps,
    required this.typeBreakdown,
  });

  Color get _campColor => campName == HealthFacilityConstants.imvepiCamp
      ? Colors.teal
      : Colors.indigo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final campPct = totalAllCamps > 0
        ? (total / totalAllCamps * 100).toStringAsFixed(0)
        : '0';
    final resolutionRate =
        total > 0 ? (completed / total * 100).toStringAsFixed(0) : '0';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 18,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _campColor.withAlpha(14),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                  bottom: BorderSide(color: _campColor.withAlpha(30))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _campColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.location_city_rounded,
                      color: _campColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    campName,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: _campColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _campColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$total cases · $campPct% of total',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: _campColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick stats row
                Row(
                  children: [
                    _MiniStat(
                        label: l10n.activeFilter, value: '$active', color: Colors.orange),
                    const SizedBox(width: 8),
                    _MiniStat(
                        label: l10n.doneLabel,
                        value: '$completed',
                        color: Colors.green),
                    const SizedBox(width: 8),
                    _MiniStat(
                        label: l10n.critical,
                        value: '$critical',
                        color: Colors.red),
                    const SizedBox(width: 8),
                    _MiniStat(
                        label: l10n.resolutionLabel,
                        value: '$resolutionRate%',
                        color: Colors.teal),
                  ],
                ),

                // Load bar
                if (totalAllCamps > 0) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Share of all cases',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: totalAllCamps > 0 ? total / totalAllCamps : 0,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(_campColor),
                      minHeight: 8,
                    ),
                  ),
                ],

                // Emergency type breakdown
                if (typeBreakdown.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'By emergency type',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: typeBreakdown.entries.map((e) {
                      return _TypeChip(type: e.key, count: e.value);
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3 — FACILITIES
// ─────────────────────────────────────────────────────────────────────────────
class _FacilitiesTab extends StatelessWidget {
  final String Function(String) campForFacility;

  const _FacilitiesTab({required this.campForFacility});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_FacilityStats>>(
      future: _loadFacilityStats(),
      builder: (context, snapshot) {
        final l10n = AppLocalizations.of(context)!;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('${l10n.errorLoadingFacilityData}: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary)),
          );
        }

        final facilities = snapshot.data ?? [];
        if (facilities.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_hospital_outlined,
                    size: 56, color: AppColors.textSecondary.withAlpha(80)),
                const SizedBox(height: 12),
                Text(l10n.noFacilityDataYet,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(
                    'Facility stats will appear once clinicians register\nand cases are submitted.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        final maxCases =
            facilities.map((f) => f.totalCases).fold(0, (a, b) => a > b ? a : b);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Staff coverage summary
                  _SectionCard(
                    title: l10n.staffCoverage,
                    icon: Icons.people_outline,
                    child: Column(
                      children: [
                        for (final stats in facilities)
                          _StaffCoverageRow(stats: stats),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cases per facility ranking
                  _SectionCard(
                    title: l10n.caseLoadByFacility,
                    icon: Icons.bar_chart_rounded,
                    subtitle: l10n.rankedByTotalCasesAssigned,
                    child: facilities.isEmpty
                        ? _EmptyHint('No data yet.')
                        : Column(
                            children: facilities.map((stats) {
                              final fraction = maxCases > 0
                                  ? stats.totalCases / maxCases
                                  : 0.0;
                              final camp = campForFacility(stats.facilityName);
                              final campColor =
                                  camp == HealthFacilityConstants.imvepiCamp
                                      ? Colors.teal
                                      : Colors.indigo;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            stats.facilityName,
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: campColor.withAlpha(15),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            camp.replaceAll(' Camp', ''),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: campColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${stats.totalCases}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: AppColors.adminAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: fraction,
                                              backgroundColor: AppColors.border,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      AppColors.adminAccent),
                                              minHeight: 7,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Active: ${stats.activeCases}  ·  Done: ${stats.completedCases}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Unresolved critical cases per facility
                  _SectionCard(
                    title: l10n.criticalUnresolvedCases,
                    icon: Icons.warning_amber_rounded,
                    child: Column(
                      children: [
                        for (final stats in facilities
                            .where((s) => s.criticalActive > 0)
                            .toList()
                          ..sort((a, b) =>
                              b.criticalActive.compareTo(a.criticalActive)))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.circle,
                                    color: Colors.red, size: 8),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    stats.facilityName,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withAlpha(15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${stats.criticalActive} critical',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (facilities.every((s) => s.criticalActive == 0))
                          _EmptyHint('No unresolved critical cases.'),
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
  }

  /// Loads facility stats from both emergencyCases and users in parallel.
  Future<List<_FacilityStats>> _loadFacilityStats() async {
    final firestore = FirebaseFirestore.instance;

    // Load cases and users in parallel
    final results = await Future.wait([
      firestore.collection('emergencyCases').get(),
      firestore
          .collection('users')
          .where('role', isEqualTo: 'Clinic Staff')
          .get(),
    ]);

    final casesDocs = results[0].docs;
    final usersDocs = results[1].docs;

    // Build staff count per facility
    final Map<String, int> staffCount = {};
    final Map<String, Set<String>> staffSpecialties = {};
    for (final doc in usersDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final workplace = data['workplace'] as String? ?? '';
      if (workplace.isEmpty) continue;
      staffCount[workplace] = (staffCount[workplace] ?? 0) + 1;
      final specialty = data['specialty'] as String? ?? '';
      staffSpecialties.putIfAbsent(workplace, () => {}).add(specialty);
    }

    // Build case stats per facility
    final Map<String, _FacilityStats> statsMap = {};

    // Seed all known facilities so we show even those with 0 cases
    for (final f in HealthFacilityConstants.allFacilities) {
      statsMap[f] = _FacilityStats(
        facilityName: f,
        staffCount: staffCount[f] ?? 0,
        specialties: staffSpecialties[f] ?? {},
      );
    }

    for (final doc in casesDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final facility = data['assignedClinicName'] as String? ?? '';
      if (facility.isEmpty) continue;

      final status = (data['status'] as String? ?? '').toLowerCase();
      final urgency = (data['urgencyLevel'] as String? ?? '').toLowerCase();
      final isCompleted =
          ['completed', 'cancelled', 'delivered'].contains(status);

      final existing = statsMap[facility] ??
          _FacilityStats(
            facilityName: facility,
            staffCount: staffCount[facility] ?? 0,
            specialties: staffSpecialties[facility] ?? {},
          );

      statsMap[facility] = existing.copyWith(
        totalCases: existing.totalCases + 1,
        activeCases:
            existing.activeCases + (isCompleted ? 0 : 1),
        completedCases:
            existing.completedCases + (isCompleted ? 1 : 0),
        criticalActive: existing.criticalActive +
            (urgency == 'critical' && !isCompleted ? 1 : 0),
      );
    }

    final list = statsMap.values.toList()
      ..sort((a, b) => b.totalCases.compareTo(a.totalCases));

    return list;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data class for facility stats
// ─────────────────────────────────────────────────────────────────────────────
class _FacilityStats {
  final String facilityName;
  final int totalCases;
  final int activeCases;
  final int completedCases;
  final int criticalActive;
  final int staffCount;
  final Set<String> specialties;

  const _FacilityStats({
    required this.facilityName,
    this.totalCases = 0,
    this.activeCases = 0,
    this.completedCases = 0,
    this.criticalActive = 0,
    required this.staffCount,
    required this.specialties,
  });

  _FacilityStats copyWith({
    int? totalCases,
    int? activeCases,
    int? completedCases,
    int? criticalActive,
  }) {
    return _FacilityStats(
      facilityName: facilityName,
      totalCases: totalCases ?? this.totalCases,
      activeCases: activeCases ?? this.activeCases,
      completedCases: completedCases ?? this.completedCases,
      criticalActive: criticalActive ?? this.criticalActive,
      staffCount: staffCount,
      specialties: specialties,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared / reusable widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 18,
              offset: const Offset(0, 12))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.adminAccent),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.adminAccent,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!,
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final double fraction;
  final Color color;

  const _BarRow({
    required this.label,
    required this.count,
    required this.total,
    required this.fraction,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textPrimary)),
              Text('$count ($pct%)',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 18,
              offset: const Offset(0, 12))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(25)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String type;
  final int count;

  const _TypeChip({required this.type, required this.count});

  Color _color() {
    switch (type.toLowerCase()) {
      case 'birth':
        return Colors.pink;
      case 'trauma':
        return Colors.orange;
      case 'infection':
        return Colors.purple;
      default:
        return AppColors.adminAccent;
    }
  }

  String _typeLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (type.toLowerCase()) {
      case 'birth': return l10n.birth;
      case 'trauma': return l10n.trauma;
      case 'infection': return l10n.infection;
      case 'other': return l10n.other;
      default: return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withAlpha(30)),
      ),
      child: Text(
        '${_typeLabel(context)} · $count',
        style: TextStyle(
            fontWeight: FontWeight.w600, fontSize: 11, color: c),
      ),
    );
  }
}

class _StaffCoverageRow extends StatelessWidget {
  final _FacilityStats stats;

  const _StaffCoverageRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            stats.staffCount > 0
                ? Icons.check_circle_outline
                : Icons.warning_amber_outlined,
            size: 16,
            color: stats.staffCount > 0 ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.facilityName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                if (stats.specialties.isNotEmpty)
                  Text(
                    stats.specialties
                        .where((s) => s.isNotEmpty)
                        .join(', '),
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: stats.staffCount > 0
                  ? Colors.green.withAlpha(15)
                  : Colors.orange.withAlpha(15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              stats.staffCount == 0
                  ? 'No staff'
                  : '${stats.staffCount} staff',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color:
                    stats.staffCount > 0 ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style:
            TextStyle(fontSize: 13, color: AppColors.textSecondary),
        textAlign: TextAlign.center,
      ),
    );
  }
}
