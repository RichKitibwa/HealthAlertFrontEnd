import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'vht_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/screens/settings_screen.dart';
import '../../../common/presentation/screens/learning_resources_screen.dart';
import '../../../auth/current_user_session.dart';
import '../../../../core/utils/drawer_helpers.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// VHT Case Submitted Screen
///
/// Shown after a VHT successfully creates an emergency case and notifies a clinic.
/// Displays:
/// - Confirmation that the case was submitted
/// - Assigned clinic and clinician info
/// - Real-time case status updates via Firestore stream
/// - Option to return to dashboard or view case details
///
/// Per business rules (Rural Dispatch Flow), the VHT does NOT dispatch ambulances.
/// The clinician reviews the case and decides whether to dispatch an ambulance.
class VhtCaseSubmittedScreen extends StatefulWidget {
  final String caseId;
  final String emergencyType;
  final String clinicName;
  final String clinicianName;
  final String? patientId;
  final String? urgencyLevel;
  final bool isOffline;

  const VhtCaseSubmittedScreen({
    Key? key,
    required this.caseId,
    required this.emergencyType,
    required this.clinicName,
    required this.clinicianName,
    this.patientId,
    this.urgencyLevel,
    this.isOffline = false,
  }) : super(key: key);

  @override
  State<VhtCaseSubmittedScreen> createState() => _VhtCaseSubmittedScreenState();
}

class _VhtCaseSubmittedScreenState extends State<VhtCaseSubmittedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkAnimController;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _checkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _checkAnimation = CurvedAnimation(
      parent: _checkAnimController,
      curve: Curves.elasticOut,
    );
    _checkAnimController.forward();
  }

  @override
  void dispose() {
    _checkAnimController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
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
      case 'intreatment':
        return Colors.blue;
      case 'admitted':
        return Colors.deepOrange;
      case 'discharged':
        return Colors.green.shade700;
      case 'completed':
        return Colors.green.shade700;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toLowerCase()) {
      case 'pending':
        return l10n.pendingReview;
      case 'dispatched':
        return l10n.ambulanceDispatched;
      case 'enroute':
        return l10n.ambulanceEnRoute;
      case 'arrived':
        return l10n.ambulanceArrived;
      case 'intransit':
        return l10n.patientInTransit;
      case 'delivered':
        return l10n.patientDelivered;
      case 'intreatment':
        return l10n.inTreatment;
      case 'admitted':
        return l10n.admitted;
      case 'discharged':
        return l10n.discharged;
      case 'completed':
        return l10n.caseCompleted;
      case 'cancelled':
        return l10n.caseCancelled;
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'dispatched':
        return Icons.local_shipping_rounded;
      case 'enroute':
        return Icons.directions_car_rounded;
      case 'arrived':
        return Icons.location_on_rounded;
      case 'intransit':
        return Icons.transfer_within_a_station_rounded;
      case 'delivered':
        return Icons.check_circle_rounded;
      case 'intreatment':
        return Icons.medical_services_rounded;
      case 'admitted':
        return Icons.local_hotel_rounded;
      case 'discharged':
        return Icons.exit_to_app_rounded;
      case 'completed':
        return Icons.verified_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _getStatusMessage(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toLowerCase()) {
      case 'pending':
        return l10n.statusMsgPendingSubmitted;
      case 'dispatched':
        return l10n.statusMsgDispatchedStay;
      case 'enroute':
        return l10n.statusMsgEnRoutePrepare;
      case 'arrived':
        return l10n.statusMsgArrivedHandOver;
      case 'intransit':
        return l10n.statusMsgInTransit;
      case 'delivered':
        return l10n.statusMsgDelivered;
      case 'intreatment':
        return l10n.statusMsgInTreatment;
      case 'admitted':
        return l10n.statusMsgAdmitted;
      case 'discharged':
        return l10n.statusMsgDischarged;
      case 'completed':
        return l10n.statusMsgCompletedTreated;
      case 'cancelled':
        return l10n.statusMsgCancelled;
      default:
        return l10n.awaitingStatusUpdate;
    }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'VHT',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        pageTitle: l10n.caseTracking,
        showBackButton: false,
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
            '/vht-dashboard',
            (route) => false,
          );
        },
        onSettings: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
        onLearningResources: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LearningResourcesScreen()),
          );
        },
      ),
      endDrawer: buildStandardDrawer(
        context: context,
        dashboardRoute: '/vht-dashboard',
      ),
      bottomNavigationBar: VhtNavigationBar(
        currentIndex: 0,
        onItemSelected: (index) {
          if (index == 0) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/vht-dashboard',
              (route) => false,
            );
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success Animation
              ScaleTransition(
                scale: _checkAnimation,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 56,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                l10n.caseSubmitted,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.clinicNotifiedOfEmergency,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Case Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Emergency Type + Urgency
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.vhtAccent.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.emergencyType,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.vhtAccent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (widget.urgencyLevel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getUrgencyColor(
                                widget.urgencyLevel,
                              ).withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.urgencyLevel!.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: _getUrgencyColor(widget.urgencyLevel),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Patient ID
                    if (widget.patientId != null) ...[
                      _InfoRow(
                        icon: Icons.badge_outlined,
                        label: l10n.patientIdLabel,
                        value: widget.patientId!,
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Assigned Clinic
                    _InfoRow(
                      icon: Icons.local_hospital_outlined,
                      label: l10n.assignedFacility,
                      value: widget.clinicName,
                    ),
                    const SizedBox(height: 10),

                    // Assigned Clinician
                    _InfoRow(
                      icon: Icons.person_outlined,
                      label: l10n.clinicianLabel,
                      value: widget.clinicianName.isNotEmpty
                          ? widget.clinicianName
                          : l10n.assignedClinician,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Offline banner
              if (widget.isOffline) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withAlpha(60)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.savedOffline,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.caseSavedOfflineMessage,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF667085),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Real-time Status Card (only show if online)
              if (!widget.isOffline)
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('emergencyCases')
                      .doc(widget.caseId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    String status = 'pending';
                    Timestamp? updatedAt;

                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      if (data != null) {
                        status = data['status'] as String? ?? 'pending';
                        updatedAt = data['updatedAt'] as Timestamp?;
                      }
                    }

                    final statusColor = _getStatusColor(status);

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: statusColor.withAlpha(40)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Header
                          Row(
                            children: [
                              Icon(
                                _getStatusIcon(status),
                                color: statusColor,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.currentStatus,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _getStatusLabel(context, status),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withAlpha(20),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Status message
                          Text(
                            _getStatusMessage(context, status),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),

                          // Privacy: clinician notes are not shown to VHTs.

                          // Last updated
                          if (updatedAt != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              '${l10n.lastUpdated}: ${_formatTimestamp(updatedAt)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary.withAlpha(150),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              if (!widget.isOffline) ...[
                const SizedBox(height: 16),

                // Status Timeline
                _buildStatusTimeline(context),
              ],
              const SizedBox(height: 24),

              // Action Buttons
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vhtAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/vht-dashboard',
                      (route) => false,
                    );
                  },
                  child: Text(
                    l10n.returnToDashboard,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Report another emergency
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.vhtAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/create-emergency',
                      (route) => route.settings.name == '/vht-dashboard',
                    );
                  },
                  child: Text(
                    l10n.reportAnotherEmergency,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.vhtAccent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dt = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildStatusTimeline(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('emergencyCases')
          .doc(widget.caseId)
          .snapshots(),
      builder: (context, snapshot) {
        String currentStatus = 'pending';
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            currentStatus = data['status'] as String? ?? 'pending';
          }
        }

        final statuses = [
          'pending',
          'dispatched',
          'enRoute',
          'arrived',
          'inTransit',
          'delivered',
          'inTreatment',
          'admitted',
          'discharged',
          'completed',
        ];
        final currentIndex = statuses.indexOf(currentStatus);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Case Progress',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(statuses.length, (index) {
                final isCompleted = index <= currentIndex;
                final isCurrent = index == currentIndex;
                final status = statuses[index];

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < statuses.length - 1 ? 0 : 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline indicator
                      Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted
                                  ? (isCurrent
                                        ? _getStatusColor(status)
                                        : Colors.green)
                                  : AppColors.border,
                              border: isCurrent
                                  ? Border.all(
                                      color: _getStatusColor(
                                        status,
                                      ).withAlpha(80),
                                      width: 3,
                                    )
                                  : null,
                            ),
                            child: isCompleted
                                ? Icon(
                                    isCurrent
                                        ? _getStatusIcon(status)
                                        : Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          if (index < statuses.length - 1)
                            Container(
                              width: 2,
                              height: 20,
                              color: isCompleted && index < currentIndex
                                  ? Colors.green
                                  : AppColors.border,
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Status label
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            _getStatusLabel(context, status),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isCurrent
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isCompleted
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary.withAlpha(100),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
