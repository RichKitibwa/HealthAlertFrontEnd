import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_case_timeline.dart';
import '../../../../core/theme/app_colors.dart';

class AdminAllCasesListScreen extends StatefulWidget {
  final String? filterStatus;

  const AdminAllCasesListScreen({super.key, this.filterStatus});

  @override
  State<AdminAllCasesListScreen> createState() => _AdminAllCasesListScreenState();
}

class _AdminAllCasesListScreenState extends State<AdminAllCasesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getTitle() {
    switch (widget.filterStatus) {
      case 'active':
        return 'Active Cases';
      case 'completed':
        return 'Completed Cases';
      default:
        return 'All Cases';
    }
  }

  Stream<QuerySnapshot> _getCasesStream() {
    Query query = FirebaseFirestore.instance.collection('emergencyCases');

    if (widget.filterStatus == 'active') {
      query = query.where('status', whereIn: [
        'pending', 'advised', 'ambulanceRequested', 'dispatched', 'enRoute', 'arrived', 'inTransit',
      ]);
    } else if (widget.filterStatus == 'completed') {
      query = query.where('status', whereIn: ['delivered', 'completed', 'cancelled']);
    }

    return query.snapshots();
  }

  bool _matchesSearch(Map<String, dynamic> data) {
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    final patientId = (data['patientId'] as String? ?? '').toLowerCase();
    final firstName = (data['patientFirstName'] as String? ?? '').toLowerCase();
    final lastName = (data['patientLastName'] as String? ?? '').toLowerCase();
    final emergencyType = (data['emergencyType'] as String? ?? '').toLowerCase();
    return patientId.contains(q) || firstName.contains(q) || lastName.contains(q) || emergencyType.contains(q);
  }

  List<DocumentSnapshot> _sortByCreatedAt(List<DocumentSnapshot> docs) {
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
    return docs;
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

  Color _getUrgencyColor(String? urgency) {
    switch (urgency?.toLowerCase()) {
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

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
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
      case 'delivered':
        return Colors.teal;
      case 'completed':
        return Colors.green.shade700;
      case 'cancelled':
        return Colors.grey;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'advised':
        return 'Advised';
      case 'ambulancerequested':
        return 'Amb. Requested';
      case 'dispatched':
        return 'Dispatched';
      case 'enroute':
        return 'En Route';
      case 'arrived':
        return 'Arrived';
      case 'intransit':
        return 'In Transit';
      case 'delivered':
        return 'Delivered';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status ?? 'Unknown';
    }
  }

  String _formatTimeAgo(Timestamp? ts) {
    if (ts == null) return '';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final dt = ts.toDate();
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_getTitle(), style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by patient name, ID, or type...',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary.withAlpha(150)),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
                ),
                onChanged: (value) => setState(() => _searchQuery = value.trim()),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getCasesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: AppColors.error.withAlpha(150)),
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
                  }).toList();
                  docs = _sortByCreatedAt(docs);

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_outlined, size: 56, color: AppColors.textSecondary.withAlpha(120)),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isNotEmpty ? 'No matching cases' : 'No cases found',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _searchQuery.isNotEmpty ? 'Try a different search term' : 'Cases will appear here when reported',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: docs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
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

  Widget _buildCaseCard(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final caseId = doc.id;
    final emergencyType = data['emergencyType'] as String? ?? 'Unknown';
    final urgency = data['urgencyLevel'] as String? ?? 'medium';
    final status = data['status'] as String? ?? 'pending';
    final patientFirstName = data['patientFirstName'] as String? ?? '';
    final patientLastName = data['patientLastName'] as String? ?? '';
    final createdAt = data['createdAt'] as Timestamp?;
    final patientName = '$patientFirstName $patientLastName'.trim();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminCaseTimelineScreen(caseId: caseId)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getUrgencyColor(urgency).withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(_getEmergencyIcon(emergencyType), size: 24, color: _getEmergencyIconColor(emergencyType)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          patientName.isNotEmpty ? patientName : 'Unknown Patient',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getUrgencyColor(urgency).withAlpha(22),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _getUrgencyColor(urgency).withAlpha(80)),
                        ),
                        child: Text(
                          urgency.toUpperCase(),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _getUrgencyColor(urgency)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withAlpha(18),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _getStatusColor(status).withAlpha(40)),
                        ),
                        child: Text(
                          _getStatusLabel(status),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _getStatusColor(status)),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTimeAgo(createdAt),
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emergencyType,
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 24),
          ],
        ),
      ),
    );
  }
}
