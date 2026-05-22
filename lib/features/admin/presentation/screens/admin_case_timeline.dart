import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'admin_case_analytics.dart';
import 'admin_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/screens/settings_screen.dart';
import '../../../auth/current_user_session.dart';
import '../../../../core/utils/drawer_helpers.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/location_utils.dart';
import '../../../../core/widgets/back_handling_pop_scope.dart';
import '../../../../l10n/app_localizations.dart';

class AdminCaseTimelineScreen extends StatefulWidget {
  final String caseId;

  const AdminCaseTimelineScreen({super.key, required this.caseId});

  @override
  State<AdminCaseTimelineScreen> createState() =>
      _AdminCaseTimelineScreenState();
}

class _AdminCaseTimelineScreenState extends State<AdminCaseTimelineScreen> {
  bool _isDispatching = false;

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

  String _getStatusLabel(String? status, AppLocalizations l10n) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return l10n.pendingReview;
      case 'advised':
        return l10n.adviceSent;
      case 'ambulancerequested':
        return l10n.ambulanceRequested;
      case 'dispatched':
        return l10n.ambulanceDispatched;
      case 'enroute':
        return l10n.enRoute;
      case 'arrived':
        return l10n.arrived;
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
        return status ?? l10n.unknown;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'advised':
        return Icons.message_rounded;
      case 'ambulancerequested':
        return Icons.local_shipping_outlined;
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

  String _formatTimestamp(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} - ${dt.day}/${dt.month}/${dt.year}';
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.couldNotOpenDialer(phone)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _dispatchAmbulance(Map<String, dynamic> caseData) async {
    final l10n = AppLocalizations.of(context)!;
    // Show ambulance selection dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dialogL10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.local_shipping_rounded,
                color: AppColors.adminAccent,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  dialogL10n.dispatchAmbulance,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
          content: Text(
            dialogL10n.assigningNearestAmbulance,
            style: const TextStyle(fontSize: 14),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          dialogL10n.cancel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.adminAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          dialogL10n.dispatch,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirm != true) return;
    setState(() => _isDispatching = true);

    try {
      final caseDoc = await FirebaseFirestore.instance
          .collection('emergencyCases')
          .doc(widget.caseId)
          .get();
      final caseData = caseDoc.data() as Map<String, dynamic>?;
      double? pickupLat =
          (caseData?['latitude'] as num?)?.toDouble() ??
          (caseData?['vhtLatitude'] as num?)?.toDouble();
      double? pickupLon =
          (caseData?['longitude'] as num?)?.toDouble() ??
          (caseData?['vhtLongitude'] as num?)?.toDouble();

      // Fetch all ambulance drivers and pick nearest by distance
      final driversQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Ambulance Driver')
          .get();

      String? assignedDriverId;
      String? assignedDriverName;
      if (driversQuery.docs.isNotEmpty) {
        final driversWithDistance = <Map<String, dynamic>>[];
        for (final doc in driversQuery.docs) {
          final d = doc.data();
          final lat = (d['latitude'] as num?)?.toDouble();
          final lon = (d['longitude'] as num?)?.toDouble();
          double distance = double.maxFinite;
          if (pickupLat != null &&
              pickupLon != null &&
              lat != null &&
              lon != null) {
            distance = LocationUtils.calculateDistance(
              pickupLat,
              pickupLon,
              lat,
              lon,
            );
          }
          driversWithDistance.add({
            'id': doc.id,
            'firstName': d['firstName'] ?? '',
            'lastName': d['lastName'] ?? '',
            'distance': distance,
          });
        }
        driversWithDistance.sort(
          (a, b) =>
              (a['distance'] as double).compareTo(b['distance'] as double),
        );
        final nearest = driversWithDistance.first;
        assignedDriverId = nearest['id'] as String;
        assignedDriverName = '${nearest['firstName']} ${nearest['lastName']}'
            .trim();
      }

      await FirebaseFirestore.instance
          .collection('emergencyCases')
          .doc(widget.caseId)
          .update({
            'status': 'dispatched',
            'updatedBy': CurrentUserSession.uid,
            'dispatchedAt': FieldValue.serverTimestamp(),
            if (assignedDriverId != null)
              'assignedAmbulanceId': assignedDriverId,
            if (assignedDriverName != null)
              'assignedDriverName': assignedDriverName,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.ambulanceDispatchedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorGeneric(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDispatching = false);
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
          pageTitle: AppLocalizations.of(context)!.caseTimeline,
          showBackButton: true,
          onBack: () {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/admin-dashboard',
                (route) => false,
              );
            }
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
              '/admin-dashboard',
              (route) => false,
            );
          },
          onSettings: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
          onReports: () {},
          onAnalytics: () {},
        ),
        backgroundColor: AppColors.background,
        endDrawer: buildStandardDrawer(
          context: context,
          dashboardRoute: '/admin-dashboard',
        ),
        bottomNavigationBar: AdminNavigationBar(currentIndex: 0),
        body: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('emergencyCases')
                .doc(widget.caseId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                final l10n = AppLocalizations.of(context)!;
                return Center(child: Text(l10n.caseNotFound));
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final emergencyType =
                  data['emergencyType'] as String? ?? 'Unknown';
              final urgency = data['urgencyLevel'] as String? ?? 'medium';
              final status = data['status'] as String? ?? 'pending';
              final patientFirstName =
                  data['patientFirstName'] as String? ?? '';
              final patientLastName = data['patientLastName'] as String? ?? '';
              final patientId = data['patientId'] as String? ?? '';
              final patientAge = data['patientAge'] as int?;
              final vhtName = data['vhtName'] as String? ?? '';
              final vhtPhone = data['vhtPhoneNumber'] as String? ?? '';
              final clinicName = data['assignedClinicName'] as String? ?? '';
              final clinicianName =
                  data['assignedClinicianName'] as String? ?? '';
              final clinicianPhone =
                  data['clinicianPhoneNumber'] as String? ?? '';
              final createdAt = data['createdAt'] as Timestamp?;
              final updatedAt = data['updatedAt'] as Timestamp?;
              final dispatchedAt = data['dispatchedAt'] as Timestamp?;
              final statusColor = _getStatusColor(status);
              final patientName = '$patientFirstName $patientLastName'.trim();
              final isAmbulanceRequested = status == 'ambulanceRequested';

              // Build timeline
              final clinicianDecision =
                  data['clinicianDecision'] as String? ?? '';
              final isAdvicePath =
                  clinicianDecision == 'advise_vht' || status == 'advised';
              final List<String> statuses;
              if (isAdvicePath) {
                statuses = ['pending', 'advised', 'completed'];
              } else if (clinicianDecision == 'dispatch_ambulance' ||
                  [
                    'ambulanceRequested',
                    'dispatched',
                    'enRoute',
                    'arrived',
                    'inTransit',
                    'delivered',
                    'inTreatment',
                    'admitted',
                  ].contains(status)) {
                statuses = [
                  'pending',
                  'ambulanceRequested',
                  'dispatched',
                  'enRoute',
                  'arrived',
                  'inTransit',
                  'delivered',
                  'inTreatment',
                  'admitted',
                  'completed',
                ];
              } else {
                statuses = ['pending', 'completed'];
              }
              final currentIndex = statuses.indexOf(status);

              final l10n = AppLocalizations.of(context)!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.caseTimeline,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.reviewEventsForCase,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status + Urgency Banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: statusColor.withAlpha(40)),
                      ),
                      child: Row(
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
                                  emergencyType,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: statusColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getStatusLabel(status, l10n),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getUrgencyColor(urgency).withAlpha(20),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              urgency.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: _getUrgencyColor(urgency),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Patient + Case Info
                    _buildInfoCard(l10n.caseDetails, [
                      if (patientName.isNotEmpty)
                        _buildInfoRow(l10n.patientLabel, patientName),
                      if (patientId.isNotEmpty)
                        _buildInfoRow(l10n.patientIdLabel, patientId),
                      if (patientAge != null)
                        _buildInfoRow(l10n.age, l10n.ageYears(patientAge)),
                      if (vhtName.isNotEmpty) _buildInfoRow(l10n.vht, vhtName),
                      if (clinicName.isNotEmpty)
                        _buildInfoRow(l10n.clinicLabel, clinicName),
                      if (clinicianName.isNotEmpty)
                        _buildInfoRow(l10n.clinicianLabel, clinicianName),
                    ]),
                    const SizedBox(height: 12),

                    // Contact section
                    _buildInfoCard(l10n.contactSection, [
                      if (vhtPhone.isNotEmpty)
                        _buildContactRow(l10n.vht, vhtName, vhtPhone),
                      if (clinicianPhone.isNotEmpty)
                        _buildContactRow(
                          l10n.clinicianLabel,
                          clinicianName,
                          clinicianPhone,
                        ),
                    ]),
                    const SizedBox(height: 16),

                    // Timeline
                    Container(
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
                            l10n.progressTimeline,
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
                            final s = statuses[index];

                            // Get timestamp for this status
                            String? timeStr;
                            if (s == 'pending' && createdAt != null)
                              timeStr = _formatTimestamp(createdAt);
                            if (s == 'dispatched' && dispatchedAt != null)
                              timeStr = _formatTimestamp(dispatchedAt);
                            if (isCurrent &&
                                updatedAt != null &&
                                s != 'pending')
                              timeStr = _formatTimestamp(updatedAt);

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isCompleted
                                            ? (isCurrent
                                                  ? _getStatusColor(s)
                                                  : Colors.green)
                                            : AppColors.border,
                                        border: isCurrent
                                            ? Border.all(
                                                color: _getStatusColor(
                                                  s,
                                                ).withAlpha(80),
                                                width: 2,
                                              )
                                            : null,
                                      ),
                                      child: isCompleted
                                          ? Icon(
                                              isCurrent
                                                  ? _getStatusIcon(s)
                                                  : Icons.check,
                                              size: 12,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    if (index < statuses.length - 1)
                                      Container(
                                        width: 2,
                                        height: 22,
                                        color:
                                            isCompleted && index < currentIndex
                                            ? Colors.green
                                            : AppColors.border,
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getStatusLabel(s, l10n),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isCurrent
                                                ? FontWeight.w700
                                                : FontWeight.w400,
                                            color: isCompleted
                                                ? AppColors.textPrimary
                                                : AppColors.textSecondary
                                                      .withAlpha(100),
                                          ),
                                        ),
                                        if (timeStr != null)
                                          Text(
                                            timeStr,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dispatch button (when ambulance is requested)
                    if (isAmbulanceRequested) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isDispatching
                              ? null
                              : () => _dispatchAmbulance(data),
                          icon: _isDispatching
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.local_shipping_rounded),
                          label: Text(
                            _isDispatching
                                ? l10n.dispatching
                                : l10n.dispatchAmbulance,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.adminAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
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
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.adminAccent,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(String role, String name, String phone) {
    final l10n = AppLocalizations.of(context)!;
    String callLabel;
    if (role == l10n.vht) {
      callLabel = l10n.callVht;
    } else if (role == l10n.clinicianLabel) {
      callLabel = l10n.callClinician;
    } else {
      callLabel = '${l10n.callsLabel} $role';
    }
    return InkWell(
      onTap: () => _callPhone(phone),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.phone, color: Colors.green, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    callLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (name.isNotEmpty)
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
