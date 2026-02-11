import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'vht_case_detail_screen.dart';
import 'vht_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/screens/settings_screen.dart';
import '../../../common/presentation/screens/learning_resources_screen.dart';
import '../../../auth/current_user_session.dart';
import '../../../../core/utils/drawer_helpers.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';

/// VHT Active Cases Screen
///
/// Lists all active (non-completed) emergency cases created by this VHT.
/// Tapping a case opens the VhtCaseDetailScreen with real-time status.
class VhtActiveCasesScreen extends StatefulWidget {
  /// 'active' shows only active cases, 'all' shows all cases
  final String initialFilter;

  const VhtActiveCasesScreen({
    Key? key,
    this.initialFilter = 'active',
  }) : super(key: key);

  @override
  State<VhtActiveCasesScreen> createState() => _VhtActiveCasesScreenState();
}

class _VhtActiveCasesScreenState extends State<VhtActiveCasesScreen> {
  late String _filter;
  String _searchQuery = '';
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _categories = ['Birth', 'Trauma', 'Infection', 'Other'];

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Client-side filter by patient name, ID, or category
  bool _matchesSearch(Map<String, dynamic> data) {
    // Category filter
    if (_selectedCategory != null) {
      final emergencyType = (data['emergencyType'] as String? ?? '').toLowerCase();
      if (emergencyType != _selectedCategory!.toLowerCase()) return false;
    }

    // Text search filter
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    final patientId = (data['patientId'] as String? ?? '').toLowerCase();
    final firstName = (data['patientFirstName'] as String? ?? '').toLowerCase();
    final lastName = (data['patientLastName'] as String? ?? '').toLowerCase();
    final emergencyType = (data['emergencyType'] as String? ?? '').toLowerCase();
    return patientId.contains(q) || firstName.contains(q) || lastName.contains(q) || emergencyType.contains(q);
  }

  Stream<QuerySnapshot> _getCasesStream() {
    final uid = CurrentUserSession.uid;
    if (uid == null || uid.isEmpty) return const Stream.empty();

    Query query = FirebaseFirestore.instance
        .collection('emergencyCases')
        .where('vhtId', isEqualTo: uid);

    if (_filter == 'active') {
      query = query.where('status', whereIn: [
        'pending', 'advised', 'ambulanceRequested', 'dispatched', 'enRoute', 'arrived', 'inTransit',
      ]);
    } else if (_filter == 'completed') {
      query = query.where('status', whereIn: ['delivered', 'completed', 'cancelled']);
    }

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

  Color _getStatusColor(String? s) {
    switch (s?.toLowerCase()) {
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

  String _getStatusLabel(String? s) {
    switch (s?.toLowerCase()) {
      case 'pending': return 'Pending';
      case 'advised': return 'Advised';
      case 'ambulancerequested': return 'Amb. Requested';
      case 'dispatched': return 'Dispatched';
      case 'enroute': return 'En Route';
      case 'arrived': return 'Arrived';
      case 'intransit': return 'In Transit';
      case 'delivered': return 'Delivered';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      default: return s ?? 'Unknown';
    }
  }

  String _formatTimeAgo(Timestamp? ts) {
    if (ts == null) return '';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    final dt = ts.toDate();
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  int? _calculateAge(Map<String, dynamic> data) {
    // Try direct age first
    final directAge = data['patientAge'];
    if (directAge != null && directAge is int) return directAge;

    // Calculate from DOB
    final dobStr = data['patientDateOfBirth'] as String?;
    if (dobStr != null && dobStr.isNotEmpty) {
      try {
        final dob = DateTime.parse(dobStr);
        final now = DateTime.now();
        int age = now.year - dob.year;
        if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
          age--;
        }
        return age;
      } catch (_) {}
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'VHT',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        pageTitle: 'Active Cases',
        showBackButton: true,
        onBack: () => Navigator.pop(context),
        onSignOut: () async {
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
          }
        },
        onDashboard: () {
          Navigator.pushNamedAndRemoveUntil(context, '/vht-dashboard', (r) => false);
        },
        onSettings: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        },
        onLearningResources: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningResourcesScreen()));
        },
      ),
      endDrawer: buildStandardDrawer(context: context, dashboardRoute: '/vht-dashboard'),
      bottomNavigationBar: VhtNavigationBar(
        currentIndex: 0,
        onItemSelected: (index) {
          if (index == 0) {
            Navigator.pushNamedAndRemoveUntil(context, '/vht-dashboard', (r) => false);
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _filter == 'active' ? 'Active Cases' : _filter == 'completed' ? 'Case History' : 'All Cases',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by patient name, ID, or type...',
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
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.vhtAccent, width: 1.5)),
                ),
                onChanged: (value) => setState(() => _searchQuery = value.trim()),
              ),
            ),
            const SizedBox(height: 10),

            // Filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildChip('Active', 'active'),
                  const SizedBox(width: 8),
                  _buildChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildChip('Completed', 'completed'),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Category filter chips
            SizedBox(
              height: 36,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryChip('All Types', null),
                    const SizedBox(width: 6),
                    ..._categories.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _buildCategoryChip(cat, cat),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

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
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.red.withAlpha(150)),
                            const SizedBox(height: 12),
                            const Text(
                              'Error loading cases',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${snapshot.error}',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
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
                          Icon(Icons.inbox_outlined, size: 56, color: AppColors.textSecondary.withAlpha(80)),
                          const SizedBox(height: 12),
                          Text(
                            _filter == 'active' ? 'No active cases' : _filter == 'completed' ? 'No completed cases' : 'No cases found',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cases you report will appear here.',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _buildCaseCard(context, docs[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, String value) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.vhtAccent : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.vhtAccent : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? value) {
    final isSelected = _selectedCategory == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.vhtAccent.withAlpha(20) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.vhtAccent : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: isSelected ? AppColors.vhtAccent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCaseCard(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final caseId = doc.id;
    final emergencyType = data['emergencyType'] as String? ?? 'Unknown';
    final urgency = data['urgencyLevel'] as String? ?? 'medium';
    final status = data['status'] as String? ?? 'pending';
    final patientId = data['patientId'] as String? ?? '';
    final patientFirstName = data['patientFirstName'] as String? ?? '';
    final patientLastName = data['patientLastName'] as String? ?? '';
    final clinicName = data['assignedClinicName'] as String? ?? '';
    final createdAt = data['createdAt'] as Timestamp?;
    final patientName = '$patientFirstName $patientLastName'.trim();
    final age = _calculateAge(data);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VhtCaseDetailScreen(caseId: caseId)),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: status == 'pending' ? _getUrgencyColor(urgency).withAlpha(50) : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: emergency type + status
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
                    color: _getStatusColor(status).withAlpha(18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(status).withAlpha(40)),
                  ),
                  child: Text(
                    _getStatusLabel(status),
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: _getStatusColor(status)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Patient name + ID row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (patientName.isNotEmpty)
                        Text(
                          patientName,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (patientId.isNotEmpty)
                        Text(
                          'ID: $patientId',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (age != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.vhtAccent.withAlpha(15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$age yrs',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.vhtAccent),
                    ),
                  ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getUrgencyColor(urgency).withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    urgency.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: _getUrgencyColor(urgency)),
                  ),
                ),
              ],
            ),
            if (clinicName.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Clinic: $clinicName', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 4),
            Text(
              _formatTimeAgo(createdAt),
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary.withAlpha(150)),
            ),
          ],
        ),
      ),
    );
  }
}
