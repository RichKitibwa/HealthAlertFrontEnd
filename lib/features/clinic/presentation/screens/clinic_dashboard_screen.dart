import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'clinic_case_detail_screen.dart';
import 'clinic_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/widgets/app_drawer.dart';
import '../../../auth/current_user_session.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/user_location_update_service.dart';
import '../../../common/presentation/screens/notifications_screen.dart';
import '../../../common/presentation/screens/settings_screen.dart';
import '../../../common/presentation/screens/learning_resources_screen.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/services/recent_cases_service.dart';


class ClinicDashboardScreen extends StatefulWidget {
  const ClinicDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ClinicDashboardScreen> createState() => _ClinicDashboardScreenState();
}

class _ClinicDashboardScreenState extends State<ClinicDashboardScreen> {
  int _currentIndex = 0;
  String? _resolvedFacilityName;

  @override
  void initState() {
    super.initState();
    UserLocationUpdateService.startUpdating();
    _initializeFacilityContext();
  }

  @override
  void dispose() {
    UserLocationUpdateService.stopUpdating();
    super.dispose();
  }

  void _onNavItemSelected(int index) {
    if (index == _currentIndex) return;
  }

  bool get _isClinicStaffRole => (CurrentUserSession.role ?? '').toLowerCase().contains('clinic');
  String get _currentFacilityName => (_resolvedFacilityName ?? CurrentUserSession.workplace ?? '').trim();

  Future<void> _initializeFacilityContext() async {
    final role = (CurrentUserSession.role ?? '').toLowerCase();
    if (!role.contains('clinic')) return;

    final sessionFacility = (CurrentUserSession.workplace ?? '').trim();
    if (sessionFacility.isNotEmpty) {
      if (mounted) setState(() => _resolvedFacilityName = sessionFacility);
      return;
    }

    final uid = CurrentUserSession.uid;
    if (uid == null || uid.isEmpty) return;
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final workplace = (userDoc.data()?['workplace'] as String? ?? '').trim();
      if (workplace.isNotEmpty && mounted) {
        CurrentUserSession.workplace = workplace;
        setState(() => _resolvedFacilityName = workplace);
      }
    } catch (_) {
      // Keep UI functional; stream methods will return empty until facility is known.
    }
  }

  Stream<QuerySnapshot> _getPendingCasesStream() {
    final facilityName = _currentFacilityName;
    if (_isClinicStaffRole && facilityName.isEmpty) return const Stream.empty();
    Query query = FirebaseFirestore.instance.collection('emergencyCases');
    if (facilityName.isNotEmpty) {
      query = query.where('assignedClinicName', isEqualTo: facilityName);
    }
    query = query.where('status', isEqualTo: 'pending').orderBy('createdAt', descending: true);
    return query.snapshots();
  }

  Stream<QuerySnapshot> _getActiveCasesStream() {
    final facilityName = _currentFacilityName;
    if (_isClinicStaffRole && facilityName.isEmpty) return const Stream.empty();
    Query query = FirebaseFirestore.instance.collection('emergencyCases');
    if (facilityName.isNotEmpty) {
      query = query.where('assignedClinicName', isEqualTo: facilityName);
    }
    query = query.where('status', whereIn: [
      'pending',
      'advised',
      'ambulanceRequested',
      'dispatched',
      'enRoute',
      'arrived',
      'inTransit',
    ]);
    query = query.orderBy('createdAt', descending: true);
    return query.snapshots();
  }

  Color _getUrgencyColor(String? u) {
    switch (u?.toLowerCase()) {
      case 'critical': return Colors.red;
      case 'high': return Colors.deepOrange;
      case 'medium': return Colors.orange;
      case 'low': return Colors.green;
      default: return AppColors.textSecondary;
    }
  }

  String _formatTimeAgo(BuildContext context, Timestamp? ts) {
    if (ts == null) return '';
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.minAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hrAgo(diff.inHours);
    final dt = ts.toDate();
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatTimeAgoFromDate(BuildContext context, DateTime dt) {
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.minAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hrAgo(diff.inHours);
    return '${dt.day}/${dt.month}/${dt.year}';
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
            height: 72,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(child: CircularProgressIndicator()),
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
              Text(
                l10n.recentCases,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              if (entries.isEmpty)
                Text(
                  l10n.noRecentCases,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                )
              else
                Column(
                  children: entries.map((e) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ClinicCaseDetailScreen(caseId: e.caseId)),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border.withAlpha(160)),
                          color: AppColors.background.withAlpha(40),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.emergencyType.isNotEmpty ? e.emergencyType : l10n.unknown,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    e.caseId.isNotEmpty ? 'Case: ${e.caseId.length > 6 ? e.caseId.substring(0, 6) : e.caseId}' : l10n.unknown,
                                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _formatTimeAgoFromDate(context, e.viewedAt),
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary.withAlpha(170)),
                            ),
                          ],
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

  String _getUrgencyLabel(String? u, AppLocalizations l10n) {
    switch (u?.toLowerCase()) {
      case 'critical': return l10n.critical;
      case 'high': return l10n.high;
      case 'medium': return l10n.moderate;
      case 'low': return l10n.low;
      default: return l10n.unknown;
    }
  }

  String _getEmergencyTypeLabel(String? type, AppLocalizations l10n) {
    if (type == null || type.isEmpty) return l10n.unknown;
    switch (type.toLowerCase()) {
      case 'birth': return l10n.birth;
      case 'trauma': return l10n.trauma;
      case 'infection': return l10n.infection;
      case 'other': return l10n.other;
      default: return type;
    }
  }

  String _getWelcomeMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final firstName = CurrentUserSession.firstName ?? 'Doctor';
    return l10n.welcomeBackName(firstName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final role = (CurrentUserSession.role ?? '').toLowerCase();
    final isAllowed = role.contains('clinic') || role.contains('admin');
    if (!isAllowed) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Access denied: clinician-only screen.',
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Clinic',
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
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        },
        onLearningResources: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningResourcesScreen()));
        },
      ),
      endDrawer: AppDrawer(
        onDashboard: () {},
        onNotifications: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
        },
        onSettings: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        },
        onLearningResources: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningResourcesScreen()));
        },
        onLogout: () async {
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
          }
        },
      ),
      bottomNavigationBar: ClinicNavigationBar(
        currentIndex: _currentIndex,
        onItemSelected: _onNavItemSelected,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getWelcomeMessage(context),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Recent Cases Section (Return-to-Case)
              _buildRecentCasesSection(),
              const SizedBox(height: 20),

              // Stats cards row
              StreamBuilder<QuerySnapshot>(
                stream: _getActiveCasesStream(),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? [];
                  final pendingCount = docs.where((d) => (d.data() as Map)['status'] == 'pending').length;
                  final activeCount = docs.length;
                  final criticalCount = docs.where((d) {
                    final data = d.data() as Map;
                    return data['urgencyLevel'] == 'critical' && data['status'] == 'pending';
                  }).length;

                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          label: l10n.pendingReview,
                          count: pendingCount,
                          color: Colors.orange,
                          icon: Icons.hourglass_top_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          label: l10n.activeCases,
                          count: activeCount,
                          color: AppColors.clinicAccent,
                          icon: Icons.pending_actions_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          label: l10n.critical,
                          count: criticalCount,
                          color: Colors.red,
                          icon: Icons.warning_rounded,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.assignment_turned_in_outlined),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      l10n.viewAllIncomingCases,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.clinicAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/clinic-incoming-case');
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Pending cases needing review - show up to 3
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.needsYourReview,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/clinic-incoming-case'),
                    child: Text(l10n.viewAll, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.clinicAccent)),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              StreamBuilder<QuerySnapshot>(
                stream: _getPendingCasesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ));
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.green.withAlpha(150), size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.allCaughtUp,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.noCasesPendingReview,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final displayDocs = docs.take(3).toList();

                  return Column(
                    children: displayDocs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final caseId = doc.id;
                      final rawType = data['emergencyType'] as String?;
                      final emergencyType = _getEmergencyTypeLabel(rawType, l10n);
                      final urgencyRaw = data['urgencyLevel'] as String? ?? 'medium';
                      final urgency = _getUrgencyLabel(urgencyRaw, l10n);
                      final patientId = data['patientId'] as String? ?? '';
                      final patientGender = data['patientGender'] as String? ?? '';
                      final patientAge = data['patientAge'] as int?;
                      final vhtName = data['vhtName'] as String? ?? '';
                      final notes = data['notes'] as String? ?? '';
                      final createdAt = data['createdAt'] as Timestamp?;

                      String patientDesc = '';
                      if (patientGender.isNotEmpty) {
                        patientDesc += patientGender.toLowerCase() == 'male' ? l10n.male : (patientGender.toLowerCase() == 'female' ? l10n.female : patientGender);
                      }
                      if (patientAge != null) {
                        patientDesc += patientDesc.isNotEmpty ? ', ${l10n.yearsShort(patientAge)}' : l10n.yearsShort(patientAge);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ClinicCaseDetailScreen(caseId: caseId)),
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _getUrgencyColor(urgencyRaw).withAlpha(50)),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 8, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top row: type + urgency
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        emergencyType,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getUrgencyColor(urgencyRaw).withAlpha(20),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        urgency,
                                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: _getUrgencyColor(urgencyRaw)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Patient info
                                Row(
                                  children: [
                                    if (patientId.isNotEmpty) ...[
                                      Text('$patientId', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.clinicAccent)),
                                      const SizedBox(width: 8),
                                    ],
                                    if (patientDesc.isNotEmpty)
                                      Text(patientDesc, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    const Spacer(),
                                    Text(_formatTimeAgo(context, createdAt), style: TextStyle(fontSize: 11, color: AppColors.textSecondary.withAlpha(150))),
                                  ],
                                ),
                                // VHT name
                                if (vhtName.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(l10n.reportedBy(vhtName), style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                                // Notes preview
                                if (notes.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    notes,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary.withAlpha(180)),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                // Action hint
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(l10n.tapToReview, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.clinicAccent)),
                                    const SizedBox(width: 4),
                                    Icon(Icons.chevron_right, size: 16, color: AppColors.clinicAccent),
                                  ],
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
              const SizedBox(height: 20),

              // Arrived Patients section
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.arrivedPatients,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('emergencyCases')
                    .where('assignedClinicName', isEqualTo: CurrentUserSession.workplace ?? '')
                    .where('status', whereIn: ['delivered', 'inTreatment', 'admitted'])
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ));
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_hospital_outlined, color: AppColors.clinicAccent.withAlpha(150), size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.noPatientsArrivedYet,
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  l10n.patientsWillAppearHereOnceDelivered,
                                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ],
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
                      final emergencyType = _getEmergencyTypeLabel(data['emergencyType'] as String?, l10n);
                      final urgencyLabel = _getUrgencyLabel(data['urgencyLevel'] as String?, l10n);
                      final urgencyRaw = data['urgencyLevel'] as String? ?? 'medium';
                      final patientId = data['patientId'] as String? ?? '';
                      final patientFirstName = data['patientFirstName'] as String? ?? '';
                      final patientLastName = data['patientLastName'] as String? ?? '';
                      final patientName = '$patientFirstName $patientLastName'.trim();
                      final vhtName = data['vhtName'] as String? ?? '';
                      final notes = data['notes'] as String? ?? '';
                      final status = data['status'] as String? ?? 'delivered';
                      final imageUrl = data['imageUrl'] as String? ?? '';
                      final voiceNoteUrl = data['voiceNoteUrl'] as String? ?? '';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ClinicCaseDetailScreen(caseId: caseId)),
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _getUrgencyColor(urgencyRaw).withAlpha(50)),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 8, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        emergencyType,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getUrgencyColor(urgencyRaw).withAlpha(20),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        urgencyLabel,
                                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: _getUrgencyColor(urgencyRaw)),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: status == 'inTreatment' 
                                            ? Colors.blue.withAlpha(20) 
                                            : AppColors.success.withAlpha(20),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        status == 'inTreatment' ? l10n.inTreatmentStatus : l10n.deliveredStatus,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700, 
                                          fontSize: 11, 
                                          color: status == 'inTreatment' ? Colors.blue : AppColors.successDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Patient name and ID
                                Row(
                                  children: [
                                    if (patientName.isNotEmpty) ...[
                                      Text(patientName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                      const SizedBox(width: 8),
                                    ],
                                    if (patientId.isNotEmpty)
                                      Text('${l10n.idLabel}: $patientId', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.clinicAccent)),
                                  ],
                                ),
                                // VHT name
                                if (vhtName.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(l10n.reportedBy(vhtName), style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                                // Notes preview
                                if (notes.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    notes,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary.withAlpha(180)),
                                  ),
                                ],
                                // Media indicators
                                if (imageUrl.isNotEmpty || voiceNoteUrl.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      if (imageUrl.isNotEmpty) ...[
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: AppColors.border),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 20, color: AppColors.textSecondary),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      if (voiceNoteUrl.isNotEmpty)
                                        Row(
                                          children: [
                                            Icon(Icons.mic, size: 16, color: AppColors.clinicAccent),
                                            const SizedBox(width: 4),
                                            Text(l10n.voiceNote, style: TextStyle(fontSize: 11, color: AppColors.clinicAccent)),
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 8),
                                // Review Patient button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => ClinicCaseDetailScreen(caseId: caseId)),
                                      );
                                    },
                                    icon: const Icon(Icons.medical_services_outlined, size: 18),
                                    label: Text(l10n.reviewPatient, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.clinicAccent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }
}
