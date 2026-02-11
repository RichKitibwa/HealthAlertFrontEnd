import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_case_timeline.dart';
import 'admin_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/screens/settings_screen.dart';
import '../../../auth/current_user_session.dart';
import '../../../../core/utils/drawer_helpers.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';

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

  String _getStatusLabel(String? status) {
    switch (status?.toLowerCase()) {
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
      default: return status ?? 'Unknown';
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
    return Scaffold(
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Admin',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        pageTitle: 'Active Cases',
        showBackButton: true,
        onBack: () => Navigator.pop(context),
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
        onItemSelected: (index) {
          if (index == 0) {
            Navigator.pushNamedAndRemoveUntil(context, '/admin-dashboard', (route) => false);
          }
        },
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
                    'Active Cases',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Monitor ongoing emergencies across VHTs, ambulances, and clinics.',
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
                  hintText: 'Search by patient, VHT, or type...',
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
                  _buildFilterChip('Active', 'active'),
                  const SizedBox(width: 8),
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed', 'completed'),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) => setState(() => _sortBy = value),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'Time', child: Text('Sort by time')),
                      PopupMenuItem(value: 'Severity', child: Text('Sort by severity')),
                      PopupMenuItem(value: 'Status', child: Text('Sort by status')),
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
                          Text(_sortBy, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 13, color: AppColors.adminAccent)),
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
                          Text('Error loading cases', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
                            _selectedFilter == 'active' ? 'No active cases' : 'No cases found',
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
                    itemBuilder: (context, index) => _buildCaseCard(context, docs[index]),
                  );
                },
              ),
            ),
          ],
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

  Widget _buildCaseCard(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final caseId = doc.id;
    final emergencyType = data['emergencyType'] as String? ?? 'Unknown';
    final urgency = data['urgencyLevel'] as String? ?? 'medium';
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
          border: Border.all(color: status == 'pending' ? _getUrgencyColor(urgency).withAlpha(50) : AppColors.border),
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
                    _getStatusLabel(status),
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
                        Text('ID: $patientId', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                if (patientAge != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text('$patientAge yrs', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.adminAccent)),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getUrgencyColor(urgency).withAlpha(22),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _getUrgencyColor(urgency).withAlpha(80)),
                  ),
                  child: Text(
                    urgency.toUpperCase(),
                    style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w800, fontSize: 10, color: _getUrgencyColor(urgency)),
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
                  Flexible(child: Text('Clinic: $clinicName', style: TextStyle(fontSize: 11, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                const Spacer(),
                Text(_formatTimeAgo(createdAt), style: TextStyle(fontSize: 10, color: AppColors.textSecondary.withAlpha(150))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
