import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../l10n/app_localizations.dart';
import 'admin_case_timeline.dart';
import 'admin_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/screens/settings_screen.dart';
import '../../../auth/current_user_session.dart';
import '../../../../core/utils/drawer_helpers.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_handling_pop_scope.dart';

class AdminCaseDashboardScreen extends StatefulWidget {
  const AdminCaseDashboardScreen({super.key});

  @override
  State<AdminCaseDashboardScreen> createState() => _AdminCaseDashboardScreenState();
}

class _AdminCaseDashboardScreenState extends State<AdminCaseDashboardScreen> {
  String _sortBy = 'Time';
  String _selectedFilter = 'active';
  String? _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _categories = ['Birth', 'Trauma', 'Infection', 'Other'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(Map<String, dynamic> data) {
    if (_selectedCategory != null) {
      final emergencyType = (data['emergencyType'] as String? ?? '').toLowerCase();
      if (emergencyType != _selectedCategory!.toLowerCase()) return false;
    }
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    final patientId = (data['patientId'] as String? ?? '').toLowerCase();
    final firstName = (data['patientFirstName'] as String? ?? '').toLowerCase();
    final lastName = (data['patientLastName'] as String? ?? '').toLowerCase();
    final emergencyType = (data['emergencyType'] as String? ?? '').toLowerCase();
    final vhtName = (data['vhtName'] as String? ?? '').toLowerCase();
    return patientId.contains(q) || firstName.contains(q) || lastName.contains(q) || emergencyType.contains(q) || vhtName.contains(q);
  }

  Stream<QuerySnapshot> _getCasesStream() {
    Query query = FirebaseFirestore.instance.collection('emergencyCases');

    if (_selectedFilter == 'active') {
      query = query.where('status', whereIn: [
        'pending', 'advised', 'ambulanceRequested', 'dispatched', 'enRoute', 'arrived', 'inTransit',
      ]);
    } else if (_selectedFilter == 'completed') {
      query = query.where('status', whereIn: ['delivered', 'completed', 'cancelled']);
    }

    // Note: orderBy removed to avoid composite index requirement; sorting done client-side in _sortDocs
    return query.snapshots();
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

  String _formatTimeAgo(Timestamp? ts, AppLocalizations l10n) {
    if (ts == null) return '';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.minAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hrAgo(diff.inHours);
    final dt = ts.toDate();
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _getCategoryLabel(String? cat, AppLocalizations l10n) {
    if (cat == null) return l10n.allTypes;
    switch (cat.toLowerCase()) {
      case 'birth': return l10n.birth;
      case 'trauma': return l10n.trauma;
      case 'infection': return l10n.infection;
      case 'other': return l10n.other;
      default: return cat;
    }
  }

  List<DocumentSnapshot> _sortDocs(List<DocumentSnapshot> docs) {
    switch (_sortBy) {
      case 'Severity':
        final order = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3};
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aLevel = order[aData['urgencyLevel']?.toString().toLowerCase()] ?? 4;
          final bLevel = order[bData['urgencyLevel']?.toString().toLowerCase()] ?? 4;
          return aLevel.compareTo(bLevel);
        });
        break;
      case 'Status':
        final order = {'pending': 0, 'ambulanceRequested': 1, 'dispatched': 2, 'enRoute': 3, 'arrived': 4, 'inTransit': 5, 'delivered': 6, 'completed': 7};
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aStatus = order[aData['status']?.toString()] ?? 8;
          final bStatus = order[bData['status']?.toString()] ?? 8;
          return aStatus.compareTo(bStatus);
        });
        break;
      default:
        // Default: sort by time (newest first)
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = aData['createdAt'] as Timestamp?;
          final bTime = bData['createdAt'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });
        break;
    }
    return docs;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BackHandlingPopScope(
      dashboardRoute: '/admin-dashboard',
      child: Scaffold(
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Admin',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        pageTitle: l10n.activeCasesTitle,
        showBackButton: true,
        onBack: () {
          if (Navigator.of(context).canPop()) {
            Navigator.pop(context);
          } else {
            Navigator.pushNamedAndRemoveUntil(context, '/admin-dashboard', (route) => false);
          }
        },
        onSignOut: () async {
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }
        },
        onDashboard: () {
          Navigator.pushNamedAndRemoveUntil(context, '/admin-dashboard', (route) => false);
        },
        onSettings: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        },
        onReports: () {},
        onAnalytics: () {},
      ),
      endDrawer: buildStandardDrawer(context: context, dashboardRoute: '/admin-dashboard'),
      backgroundColor: AppColors.background,
      bottomNavigationBar: AdminNavigationBar(
        currentIndex: 0,
        // Navigation is handled by AdminNavigationBar itself
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.activeCasesTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.viewAndManageOngoingCases,
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
                  hintText: l10n.searchByPatientVhtOrType,
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
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.adminAccent, width: 1.5)),
                ),
                onChanged: (value) => setState(() => _searchQuery = value.trim()),
              ),
            ),
            const SizedBox(height: 8),

            // Filter + Sort row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip(l10n.activeFilter, 'active'),
                  const SizedBox(width: 8),
                  _buildFilterChip(l10n.allFilter, 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip(l10n.completedFilter, 'completed'),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) => setState(() => _sortBy = value),
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'Time', child: Text(l10n.sortByTime)),
                      PopupMenuItem(value: 'Severity', child: Text(l10n.sortBySeverity)),
                      PopupMenuItem(value: 'Status', child: Text(l10n.sortByStatus)),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sort, size: 18, color: AppColors.adminAccent),
                          const SizedBox(width: 6),
                          Text(_sortBy == 'Time' ? l10n.sortByTime : _sortBy == 'Severity' ? l10n.sortBySeverity : l10n.sortByStatus, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 13, color: AppColors.adminAccent)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Category chips
            SizedBox(
              height: 34,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryChip(l10n.allTypes, null),
                    const SizedBox(width: 6),
                    ..._categories.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _buildCategoryChip(_getCategoryLabel(cat, l10n), cat),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Cases list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getCasesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red.withAlpha(150)),
                          const SizedBox(height: 12),
                          Text(l10n.errorLoadingCases, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text('${snapshot.error}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary), textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  }

                  final allDocs = snapshot.data?.docs ?? [];
                  List<DocumentSnapshot> docs = allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _matchesSearch(data);
                  }).toList().cast<DocumentSnapshot>();
                  docs = _sortDocs(docs);

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_outlined, size: 56, color: AppColors.textSecondary.withAlpha(80)),
                          const SizedBox(height: 12),
                          Text(
                            _selectedFilter == 'active' ? l10n.noActiveCases : l10n.noCasesFound,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _buildCaseCard(context, docs[index], l10n),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.adminAccent : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.adminAccent : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: isSelected ? Colors.white : AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? value) {
    final isSelected = _selectedCategory == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.adminAccent.withAlpha(20) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.adminAccent : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: isSelected ? AppColors.adminAccent : AppColors.textSecondary),
        ),
      ),
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

  Widget _buildCaseCard(BuildContext context, DocumentSnapshot doc, AppLocalizations l10n) {
    final data = doc.data() as Map<String, dynamic>;
    final caseId = doc.id;
    final emergencyType = _getCategoryLabel(data['emergencyType'] as String?, l10n);
    final urgency = _getUrgencyLabel(data['urgencyLevel'] as String?, l10n);
    final urgencyRaw = data['urgencyLevel'] as String? ?? 'medium';
    final status = data['status'] as String? ?? 'pending';
    final patientId = data['patientId'] as String? ?? '';
    final patientFirstName = data['patientFirstName'] as String? ?? '';
    final patientLastName = data['patientLastName'] as String? ?? '';
    final vhtName = data['vhtName'] as String? ?? '';
    final clinicName = data['assignedClinicName'] as String? ?? '';
    final createdAt = data['createdAt'] as Timestamp?;
    final patientName = '$patientFirstName $patientLastName'.trim();
    final patientAge = data['patientAge'] as int?;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminCaseTimelineScreen(caseId: caseId)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: status == 'pending' ? _getUrgencyColor(urgencyRaw).withAlpha(50) : AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 18, offset: const Offset(0, 12))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    emergencyType,
                    style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.adminAccent),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withAlpha(18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _getStatusColor(status).withAlpha(40)),
                  ),
                  child: Text(
                    _getStatusLabel(status, l10n),
                    style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 11, color: _getStatusColor(status)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (patientName.isNotEmpty)
                        Text(patientName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
                      if (patientId.isNotEmpty)
                        Text('${l10n.idLabel}: $patientId', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                if (patientAge != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(l10n.yearsShort(patientAge), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.adminAccent)),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getUrgencyColor(urgencyRaw).withAlpha(22),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _getUrgencyColor(urgencyRaw).withAlpha(80)),
                  ),
                  child: Text(
                    urgency,
                    style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w800, fontSize: 10, color: _getUrgencyColor(urgencyRaw)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (vhtName.isNotEmpty)
                  Text('VHT: $vhtName', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                if (vhtName.isNotEmpty && clinicName.isNotEmpty)
                  Text(' • ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                if (clinicName.isNotEmpty)
                  Flexible(child: Text('${l10n.clinicLabel}: $clinicName', style: TextStyle(fontSize: 11, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                const Spacer(),
                Text(_formatTimeAgo(createdAt, l10n), style: TextStyle(fontSize: 10, color: AppColors.textSecondary.withAlpha(150))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
