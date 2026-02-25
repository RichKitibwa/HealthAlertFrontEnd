import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../l10n/app_localizations.dart';
import 'clinic_case_detail_screen.dart';
import 'clinic_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/screens/settings_screen.dart';
import '../../../common/presentation/screens/learning_resources_screen.dart';
import '../../../auth/current_user_session.dart';
import '../../../../core/utils/drawer_helpers.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';

/// Clinic Incoming Cases Screen
///
/// Displays real emergency cases from Firestore that are assigned to the
/// current clinician. Replaces the previous dummy data implementation.
///
/// Query: emergencyCases where assignedClinicId == current user ID
/// Orders by createdAt descending (newest first)
class ClinicIncomingCaseScreen extends StatefulWidget {
  const ClinicIncomingCaseScreen({super.key});

  @override
  State<ClinicIncomingCaseScreen> createState() =>
      _ClinicIncomingCaseScreenState();
}

class _ClinicIncomingCaseScreenState extends State<ClinicIncomingCaseScreen> {
  String _selectedFilter = 'active'; // 'active', 'all', 'completed'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Client-side filter by patient name or ID
  bool _matchesSearch(Map<String, dynamic> data) {
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    final patientId = (data['patientId'] as String? ?? '').toLowerCase();
    final firstName = (data['patientFirstName'] as String? ?? '').toLowerCase();
    final lastName = (data['patientLastName'] as String? ?? '').toLowerCase();
    return patientId.contains(q) || firstName.contains(q) || lastName.contains(q);
  }

  Stream<QuerySnapshot> _getCasesStream() {
    final currentUserId = CurrentUserSession.uid;
    if (currentUserId == null || currentUserId.isEmpty) {
      return const Stream.empty();
    }

    Query query = FirebaseFirestore.instance
        .collection('emergencyCases')
        .where('assignedClinicId', isEqualTo: currentUserId);

    // Apply filter
    if (_selectedFilter == 'active') {
      query = query.where('status', whereIn: [
        'pending',
        'advised',
        'ambulanceRequested',
        'dispatched',
        'enRoute',
        'arrived',
        'inTransit',
      ]);
    } else if (_selectedFilter == 'completed') {
      query = query.where('status', whereIn: ['delivered', 'completed']);
    }

    query = query.orderBy('createdAt', descending: true);

    return query.snapshots();
  }

  Color _getUrgencyColor(String? urgency) {
    switch (urgency?.toLowerCase()) {
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

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'advised': return Colors.blue;
      case 'ambulancerequested': return Colors.deepPurple;
      case 'dispatched': return AppColors.clinicAccent;
      case 'enroute': return Colors.blue;
      case 'arrived': return Colors.green;
      case 'intransit': return Colors.indigo;
      case 'delivered': return Colors.teal;
      case 'completed': return Colors.green.shade700;
      case 'cancelled': return Colors.red;
      default: return AppColors.textSecondary;
    }
  }

  String _getStatusLabel(String? status, AppLocalizations l10n) {
    switch (status?.toLowerCase()) {
      case 'pending': return l10n.pendingReview;
      case 'advised': return l10n.adviceSent;
      case 'ambulancerequested': return l10n.ambulanceRequested;
      case 'dispatched': return l10n.dispatched;
      case 'enroute': return l10n.enRoute;
      case 'arrived': return l10n.arrived;
      case 'intransit': return l10n.patientInTransit;
      case 'delivered': return l10n.patientDelivered;
      case 'completed': return l10n.caseCompleted;
      case 'cancelled': return l10n.caseCancelled;
      default: return status ?? l10n.unknown;
    }
  }

  IconData _getEmergencyIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'birth': return Icons.pregnant_woman_rounded;
      case 'trauma': return Icons.local_hospital_rounded;
      case 'infection': return Icons.coronavirus_rounded;
      default: return Icons.warning_amber_rounded;
    }
  }

  Color _getEmergencyIconColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'birth': return Colors.pink;
      case 'trauma': return Colors.red;
      case 'infection': return Colors.orange;
      default: return Colors.amber;
    }
  }

  String _formatTimeAgo(Timestamp? timestamp, AppLocalizations l10n) {
    if (timestamp == null) return '';
    final dt = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.minAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hrAgo(diff.inHours);
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Clinic',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        pageTitle: l10n.incomingCases,
        showBackButton: true,
        onBack: () {
          Navigator.pop(context);
        },
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
        onDashboard: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/clinic-dashboard',
            (route) => false,
          );
        },
        onSettings: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        },
        onLearningResources: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningResourcesScreen()));
        },
      ),
      endDrawer: buildStandardDrawer(context: context, dashboardRoute: '/clinic-dashboard'),
      backgroundColor: AppColors.background,
      bottomNavigationBar: ClinicNavigationBar(
        currentIndex: 1,
        onItemSelected: (index) {
          // Navigation is handled by ClinicNavigationBar
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.incomingCases,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.reviewEmergenciesSubmittedByVhts,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchByPatientNameOrId,
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary.withAlpha(150)),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.clinicAccent, width: 1.5)),
                ),
                onChanged: (value) => setState(() => _searchQuery = value.trim()),
              ),
            ),
            const SizedBox(height: 10),

            // Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _FilterChip(
                    label: l10n.activeFilter,
                    isSelected: _selectedFilter == 'active',
                    onTap: () => setState(() => _selectedFilter = 'active'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: l10n.allFilter,
                    isSelected: _selectedFilter == 'all',
                    onTap: () => setState(() => _selectedFilter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: l10n.completedFilter,
                    isSelected: _selectedFilter == 'completed',
                    onTap: () => setState(() => _selectedFilter = 'completed'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Case List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getCasesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red.withAlpha(150),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.errorLoadingCases,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${snapshot.error}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final allDocs = snapshot.data?.docs ?? [];
                  final docs = allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _matchesSearch(data);
                  }).toList();

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: AppColors.textSecondary.withAlpha(80),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFilter == 'active'
                                ? l10n.noActiveCases
                                : _selectedFilter == 'completed'
                                    ? l10n.noCompletedCases
                                    : l10n.noCasesFound,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.emergencyCasesAssignedToYourClinic,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final caseId = docs[index].id;
                        final emergencyType = data['emergencyType'] as String? ?? 'Unknown';
                        final urgency = data['urgencyLevel'] as String? ?? 'medium';
                        final status = data['status'] as String? ?? 'pending';
                        final notes = data['notes'] as String? ?? '';
                        final patientGender = data['patientGender'] as String? ?? '';
                        final patientAge = data['patientAge'] as int?;
                        final patientId = data['patientId'] as String? ?? '';
                        final patientFirstName = data['patientFirstName'] as String? ?? '';
                        final patientLastName = data['patientLastName'] as String? ?? '';
                        final vhtName = data['vhtName'] as String? ?? 'Unknown VHT';
                        final createdAt = data['createdAt'] as Timestamp?;

                        // Build patient description
                        final patientName = '$patientFirstName $patientLastName'.trim();
                        String patientDesc = '';
                        if (patientName.isNotEmpty) {
                          patientDesc = patientName;
                        }
                        if (patientGender.isNotEmpty) {
                          patientDesc += patientDesc.isNotEmpty ? ', ' : '';
                          patientDesc += patientGender[0].toUpperCase() + patientGender.substring(1);
                        }
                        if (patientAge != null) {
                          patientDesc += patientDesc.isNotEmpty ? ', $patientAge yrs' : '$patientAge yrs';
                        }
                        if (patientDesc.isEmpty) {
                          patientDesc = '${l10n.patientLabel} $patientId';
                        }

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClinicCaseDetailScreen(
                                  caseId: caseId,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: status == 'pending'
                                    ? _getUrgencyColor(urgency).withAlpha(60)
                                    : AppColors.border,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(8),
                                  blurRadius: 18,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top row: Emergency type + Status badge
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getEmergencyIcon(emergencyType),
                                            size: 20,
                                            color: _getEmergencyIconColor(emergencyType),
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              emergencyType,
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                color: AppColors.textPrimary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(status).withAlpha(18),
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(
                                          color: _getStatusColor(status).withAlpha(40),
                                        ),
                                      ),
                                      child: Text(
                                        _getStatusLabel(status, l10n),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                          color: _getStatusColor(status),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Patient info
                                Text(
                                  'Patient: $patientDesc',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: AppColors.clinicAccent,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // VHT + Urgency row
                                Row(
                                  children: [
                                    Text(
                                      'VHT: $vhtName',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getUrgencyColor(urgency).withAlpha(20),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        urgency.toUpperCase(),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                          color: _getUrgencyColor(urgency),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Notes (if any)
                                if (notes.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'Notes: $notes',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],

                                // Time
                                const SizedBox(height: 6),
                                Text(
                                  _formatTimeAgo(createdAt, l10n),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    color: AppColors.textSecondary.withAlpha(150),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.clinicAccent : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.clinicAccent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
