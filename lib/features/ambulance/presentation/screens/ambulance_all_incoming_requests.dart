import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../l10n/app_localizations.dart';
import 'ambulance_incoming_dispatch_screen.dart';
import 'ambulance_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';
import '../../../common/presentation/widgets/app_drawer.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen that shows all incoming emergency requests for the ambulance driver.
/// Uses real Firestore data - queries cases with status 'dispatched' assigned to this driver.
class AmbulanceAllIncomingRequestsScreen extends StatefulWidget {
  const AmbulanceAllIncomingRequestsScreen({super.key});

  @override
  State<AmbulanceAllIncomingRequestsScreen> createState() =>
      _AmbulanceAllIncomingRequestsScreenState();
}

class _AmbulanceAllIncomingRequestsScreenState
    extends State<AmbulanceAllIncomingRequestsScreen> {
  int _currentIndex = 0;

  void _onNavItemSelected(int index) {
    setState(() => _currentIndex = index);
  }

  Stream<QuerySnapshot> _getDispatchedCasesStream() {
    final uid = CurrentUserSession.uid;
    if (uid == null || uid.isEmpty) return const Stream.empty();

    // Only show cases dispatched to this driver (privacy: driver sees only their dispatches)
    return FirebaseFirestore.instance
        .collection('emergencyCases')
        .where('status', isEqualTo: 'dispatched')
        .where('assignedAmbulanceId', isEqualTo: uid)
        .snapshots();
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

  String _formatTimeAgo(Timestamp? ts, AppLocalizations l10n) {
    if (ts == null) return '';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.minAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hrAgo(diff.inHours);
    final dt = ts.toDate();
    return '${dt.day}/${dt.month}/${dt.year}';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Ambulance',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        showBackButton: true,
        onBack: () => Navigator.pop(context),
        onSignOut: () async {
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }
        },
      ),
      backgroundColor: AppColors.background,
      endDrawer: AppDrawer(
        onDashboard: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/ambulance-dashboard');
        },
        onSettings: () => Navigator.pop(context),
        onLogout: () async {
          Navigator.pop(context);
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }
        },
      ),
      bottomNavigationBar: AmbulanceNavigationBar(
        currentIndex: _currentIndex,
        onItemSelected: _onNavItemSelected,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                l10n.incomingDispatchRequests,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: AppColors.ambulanceAccent,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.acceptDispatchToStart,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getDispatchedCasesStream(),
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
                          Text(l10n.errorLoadingRequests, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text('${snapshot.error}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  
                  // Filter to only active statuses
                  final activeDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['status'] as String? ?? '';
                    return ['dispatched', 'enRoute', 'arrived', 'inTransit'].contains(status);
                  }).toList();
                  
                  activeDocs.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aTime = aData['createdAt'] as Timestamp?;
                    final bTime = bData['createdAt'] as Timestamp?;
                    if (aTime == null && bTime == null) return 0;
                    if (aTime == null) return 1;
                    if (bTime == null) return -1;
                    return bTime.compareTo(aTime);
                  });

                  if (activeDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_outlined, size: 56, color: AppColors.textSecondary.withAlpha(80)),
                          const SizedBox(height: 12),
                          Text(l10n.noIncomingRequests, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text(l10n.dispatchedCasesAppearHere, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: activeDocs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final data = activeDocs[index].data() as Map<String, dynamic>;
                      final caseId = activeDocs[index].id;
                      final emergencyType = data['emergencyType'] as String? ?? 'Unknown';
                      final urgency = data['urgencyLevel'] as String? ?? 'medium';
                      final patientFirstName = data['patientFirstName'] as String? ?? '';
                      final patientLastName = data['patientLastName'] as String? ?? '';
                      final patientAge = data['patientAge'] as int?;
                      final patientGender = data['patientGender'] as String? ?? '';
                      final vhtName = data['vhtName'] as String? ?? '';
                      final createdAt = data['createdAt'] as Timestamp?;
                      final clinicName = data['assignedClinicName'] as String? ?? '';
                      final patientName = '$patientFirstName $patientLastName'.trim();

                      String patientDesc = '';
                      if (patientGender.isNotEmpty) patientDesc = patientGender[0].toUpperCase() + patientGender.substring(1);
                      if (patientAge != null) patientDesc += patientDesc.isNotEmpty ? ', $patientAge yrs' : '$patientAge yrs';
                      if (patientDesc.isEmpty) patientDesc = 'Unknown';

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AmbulanceIncomingDispatchScreen(
                                caseId: caseId,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _getUrgencyColor(urgency).withAlpha(50)),
                            boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 12, offset: const Offset(0, 6))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(_getEmergencyIcon(emergencyType), size: 20, color: _getEmergencyIconColor(emergencyType)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      emergencyType,
                                      style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ambulanceAccent),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getUrgencyColor(urgency).withAlpha(20),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      urgency.toUpperCase(),
                                      style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 10, color: _getUrgencyColor(urgency)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              if (patientName.isNotEmpty)
                                Text('${l10n.patientLabel}: $patientName', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
                              Text('$patientDesc', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (vhtName.isNotEmpty)
                                    Text('VHT: $vhtName', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  if (clinicName.isNotEmpty) ...[
                                    Text(' • ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    Flexible(child: Text('${l10n.destination}: $clinicName', style: TextStyle(fontSize: 11, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                                  ],
                                  const Spacer(),
                                  Text(_formatTimeAgo(createdAt, l10n), style: TextStyle(fontSize: 10, color: AppColors.textSecondary.withAlpha(150))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
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
}
