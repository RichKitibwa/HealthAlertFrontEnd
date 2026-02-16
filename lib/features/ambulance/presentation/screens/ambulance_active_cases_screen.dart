import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ambulance_en_route_screen.dart';
import 'ambulance_navigation_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/current_user_session.dart';

/// Ambulance Active Cases Screen
///
/// Lists active cases assigned to this ambulance driver.
/// Filters client-side for status in [dispatched, enRoute, arrived, inTransit]
/// to avoid composite index requirement.
class AmbulanceActiveCasesScreen extends StatefulWidget {
  const AmbulanceActiveCasesScreen({Key? key}) : super(key: key);

  @override
  State<AmbulanceActiveCasesScreen> createState() =>
      _AmbulanceActiveCasesScreenState();
}

class _AmbulanceActiveCasesScreenState
    extends State<AmbulanceActiveCasesScreen> {
  static const List<String> _activeStatuses = [
    'dispatched',
    'enRoute',
    'arrived',
    'inTransit',
  ];

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Query by assignedAmbulanceId only; filter status client-side.
  Stream<QuerySnapshot> _getCasesStream() {
    final uid = CurrentUserSession.uid;
    if (uid == null || uid.isEmpty) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('emergencyCases')
        .where('assignedAmbulanceId', isEqualTo: uid)
        .snapshots();
  }

  bool _matchesSearch(Map<String, dynamic> data) {
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    final firstName = (data['patientFirstName'] as String? ?? '').toLowerCase();
    final lastName = (data['patientLastName'] as String? ?? '').toLowerCase();
    final emergencyType = (data['emergencyType'] as String? ?? '')
        .toLowerCase();
    return firstName.contains(q) ||
        lastName.contains(q) ||
        emergencyType.contains(q);
  }

  IconData _getEmergencyIcon(String? type) {
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

  Color _getEmergencyIconColor(String? type) {
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

  Color _getUrgencyColor(String? u) {
    switch (u?.toLowerCase()) {
      case 'critical':
        return AppColors.urgencyCritical;
      case 'high':
        return AppColors.urgencyHigh;
      case 'medium':
        return AppColors.urgencyMedium;
      case 'low':
        return AppColors.urgencyLow;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusColor(String? s) {
    switch (s?.toLowerCase()) {
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

  String _getStatusLabel(String? s) {
    switch (s?.toLowerCase()) {
      case 'dispatched':
        return 'Dispatched';
      case 'enroute':
        return 'En Route';
      case 'arrived':
        return 'Arrived';
      case 'intransit':
        return 'In Transit';
      default:
        return s ?? 'Unknown';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Active Cases',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: AmbulanceNavigationBar(
        currentIndex: 0,
        onItemSelected: (index) {
          // TODO: Wire up navigation if needed
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by patient name or emergency type...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary.withAlpha(150),
                  ),
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.ambulanceAccent,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (value) =>
                    setState(() => _searchQuery = value.trim()),
              ),
            ),

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
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.error.withAlpha(150),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Error loading cases',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
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
                      ),
                    );
                  }

                  final allDocs = snapshot.data?.docs ?? [];
                  final filteredDocs = allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['status'] as String? ?? '';
                    if (!_activeStatuses.contains(status)) return false;
                    return _matchesSearch(data);
                  }).toList();

                  // Client-side sort by createdAt descending
                  filteredDocs.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aTs = aData['createdAt'] as Timestamp?;
                    final bTs = bData['createdAt'] as Timestamp?;
                    if (aTs == null && bTs == null) return 0;
                    if (aTs == null) return 1;
                    if (bTs == null) return -1;
                    return bTs.compareTo(aTs);
                  });

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 56,
                            color: AppColors.textSecondary.withAlpha(80),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No active cases',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cases you accept will appear here.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredDocs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _buildCaseCard(context, filteredDocs[index]);
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

  Widget _buildCaseCard(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final caseId = doc.id;
    final emergencyType = data['emergencyType'] as String? ?? 'Unknown';
    final urgency = data['urgencyLevel'] as String? ?? 'medium';
    final status = data['status'] as String? ?? 'pending';
    final patientFirstName = data['patientFirstName'] as String? ?? '';
    final patientLastName = data['patientLastName'] as String? ?? '';
    final vhtName = data['vhtName'] as String? ?? '';
    final clinicName = data['assignedClinicName'] as String? ?? '';
    final createdAt = data['createdAt'] as Timestamp?;
    final patientName = '$patientFirstName $patientLastName'.trim();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AmbulanceEnRouteScreen(caseId: caseId),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _getUrgencyColor(urgency).withAlpha(50)),
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
            // Top row: emergency type with emoji + status pill
            Row(
              children: [
                Icon(
                  _getEmergencyIcon(emergencyType),
                  size: 22,
                  color: _getEmergencyIconColor(emergencyType),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    emergencyType,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withAlpha(18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(status).withAlpha(40),
                    ),
                  ),
                  child: Text(
                    _getStatusLabel(status),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Urgency badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getUrgencyColor(urgency).withAlpha(20),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                urgency.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  color: _getUrgencyColor(urgency),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Patient name
            if (patientName.isNotEmpty)
              Text(
                patientName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            if (patientName.isNotEmpty) const SizedBox(height: 4),

            // VHT name
            if (vhtName.isNotEmpty)
              Text(
                'VHT: $vhtName',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            if (vhtName.isNotEmpty) const SizedBox(height: 2),

            // Clinic name
            if (clinicName.isNotEmpty)
              Text(
                'Clinic: $clinicName',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),

            // Time ago
            Text(
              _formatTimeAgo(createdAt),
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary.withAlpha(150),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
