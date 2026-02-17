import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ambulance_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/widgets/app_drawer.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/current_user_session.dart';
import '../../../common/presentation/screens/map_screen.dart';
import '../../../../core/services/fcm_notification_service.dart';

class AmbulanceEnRouteScreen extends StatefulWidget {
  final String caseId;

  const AmbulanceEnRouteScreen({Key? key, required this.caseId})
      : super(key: key);

  @override
  State<AmbulanceEnRouteScreen> createState() => _AmbulanceEnRouteScreenState();
}

class _AmbulanceEnRouteScreenState extends State<AmbulanceEnRouteScreen> {
  bool _isUpdatingStatus = false;

  /// All statuses in order for the progress timeline.
  static const List<String> _statusOrder = [
    'dispatched',
    'enRoute',
    'arrived',
    'inTransit',
    'delivered',
    'inTreatment',
    'admitted',
    'completed',
  ];

  static const Map<String, String> _statusLabels = {
    'pending': 'Pending',
    'dispatched': 'Dispatched',
    'enRoute': 'En Route',
    'arrived': 'Arrived at VHT',
    'inTransit': 'Patient In Transit',
    'delivered': 'Delivered to Clinic',
    'inTreatment': 'In Treatment',
    'admitted': 'Admitted',
    'discharged': 'Discharged',
    'completed': 'Completed',
  };

  static const Map<String, IconData> _statusIcons = {
    'dispatched': Icons.local_shipping_outlined,
    'enRoute': Icons.navigation_outlined,
    'arrived': Icons.flag_outlined,
    'inTransit': Icons.transfer_within_a_station,
    'delivered': Icons.local_hospital_outlined,
    'inTreatment': Icons.medical_services_rounded,
    'admitted': Icons.local_hotel_rounded,
    'discharged': Icons.exit_to_app_rounded,
    'completed': Icons.check_circle_outline,
  };

  int _statusIndex(String status) {
    final idx = _statusOrder.indexOf(status);
    return idx == -1 ? 0 : idx;
  }

  Future<void> _updateCaseStatus(String newStatus, {String? vhtId, String? patientName}) async {
    if (_isUpdatingStatus) return;
    setState(() => _isUpdatingStatus = true);

    try {
      // Fetch current case data before update (needed for notifications)
      final caseDoc = await FirebaseFirestore.instance
          .collection('emergencyCases')
          .doc(widget.caseId)
          .get();
      final caseData = caseDoc.data() ?? {};

      await FirebaseFirestore.instance
          .collection('emergencyCases')
          .doc(widget.caseId)
          .update({
        'status': newStatus,
        'updatedBy': CurrentUserSession.uid,
        'statusUpdatedAt': FieldValue.serverTimestamp(),
        'statusHistory': FieldValue.arrayUnion([
          {
            'status': newStatus,
            'updatedBy': CurrentUserSession.uid,
            'updatedAt': Timestamp.now(),
          }
        ]),
      });

      // Notify parties when patient is delivered to clinic
      if (newStatus == 'delivered') {
        try {
          final notifService = FCMNotificationService();
          final fetchedVhtId = caseData['vhtId'] as String? ?? '';
          final clinicianId = caseData['assignedClinicId'] as String? ?? '';
          final patientFirst = caseData['patientFirstName'] as String? ?? '';
          final patientLast = caseData['patientLastName'] as String? ?? '';
          final patName = '$patientFirst $patientLast'.trim().isNotEmpty
              ? '$patientFirst $patientLast'.trim()
              : patientName ?? 'Unknown Patient';
          final emergencyType = caseData['emergencyType'] as String? ?? 'Emergency';
          final clinicName = caseData['assignedClinicName'] as String? ?? 'Clinic';
          final driverName =
              '${CurrentUserSession.firstName ?? ''} ${CurrentUserSession.lastName ?? ''}'.trim();
          if (fetchedVhtId.isNotEmpty) {
            await notifService.notifyOnPatientDelivered(
              caseId: widget.caseId,
              emergencyType: emergencyType,
              patientName: patName,
              vhtId: fetchedVhtId,
              clinicianId: clinicianId,
              clinicName: clinicName,
              driverName: driverName.isNotEmpty ? driverName : 'the driver',
            );
          }
        } catch (e) {
          debugPrint('Failed to send delivery notifications: $e');
        }
      }
      // No notifications for arrived, inTransit — just status updates

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Status updated to ${_statusLabels[newStatus] ?? newStatus}'),
            backgroundColor: AppColors.ambulanceAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingStatus = false);
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch dialer for $phoneNumber'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _fetchUserData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Ambulance',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        pageTitle: 'En Route',
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
      ),
      backgroundColor: AppColors.background,
      endDrawer: AppDrawer(
        onDashboard: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/ambulance-dashboard');
        },
        onSettings: () {
          Navigator.pop(context);
        },
        onLogout: () async {
          Navigator.pop(context);
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        },
      ),
      bottomNavigationBar: AmbulanceNavigationBar(
        currentIndex: 1,
        onItemSelected: (index) {},
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('emergencyCases')
              .doc(widget.caseId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.ambulanceAccent,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(
                        'Error loading case data',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off,
                          size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      Text(
                        'Case not found',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final caseData = snapshot.data!.data()!;
            final currentStatus = caseData['status'] as String? ?? 'enRoute';
            final emergencyType =
                caseData['emergencyType'] as String? ?? 'Unknown';
            final patientId = caseData['patientId'] as String? ?? '';
            final patientFirst = caseData['patientFirstName'] as String? ?? '';
            final patientLast = caseData['patientLastName'] as String? ?? '';
            final patientNameConstructed = '$patientFirst $patientLast'.trim();
            final patientName = patientNameConstructed.isNotEmpty
                ? patientNameConstructed
                : (patientId.isNotEmpty ? 'Patient #$patientId' : 'Unknown patient');
            final vhtId = caseData['vhtId'] as String?;
            final vhtName = caseData['vhtName'] as String?;
            final clinicId = caseData['assignedClinicId'] as String?;
            final clinicName = caseData['assignedClinicName'] as String?;
            final clinicianId = caseData['assignedClinicianId'] as String?;
            final currentStatusIndex = _statusIndex(currentStatus);

            // Coordinates for map navigation
            final vhtLat = (caseData['vhtLatitude'] as num?)?.toDouble()
                ?? (caseData['latitude'] as num?)?.toDouble();
            final vhtLng = (caseData['vhtLongitude'] as num?)?.toDouble()
                ?? (caseData['longitude'] as num?)?.toDouble();
            final clinicLat = (caseData['clinicLatitude'] as num?)?.toDouble();
            final clinicLng = (caseData['clinicLongitude'] as num?)?.toDouble();

            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _statusLabels[currentStatus] ?? 'En Route',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              height: 24 / 20,
                              color: AppColors.ambulanceAccent,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildCaseInfoCard(
                      emergencyType: emergencyType,
                      patientName: patientName,
                      patientId: patientId,
                      currentStatus: currentStatus,
                    ),
                    const SizedBox(height: 20),

                    // Progress Timeline
                    _buildProgressTimeline(currentStatusIndex),
                    const SizedBox(height: 20),

                    // Contact Buttons
                    _buildContactButtons(vhtId: vhtId, clinicianId: clinicianId, clinicId: clinicId, vhtName: vhtName, clinicName: clinicName, currentStatus: currentStatus, vhtLat: vhtLat, vhtLng: vhtLng, clinicLat: clinicLat, clinicLng: clinicLng),
                    const SizedBox(height: 20),

                    // Status Action Buttons (contextual)
                    _buildStatusActions(currentStatus, vhtId: vhtId, patientName: patientName),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCaseInfoCard({
    required String emergencyType,
    required String patientName,
    required String patientId,
    required String currentStatus,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface.withAlpha(230),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.white.withAlpha(120),
            blurRadius: 18,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withAlpha(120)),
              color: Colors.white.withAlpha(180),
            ),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header row with nav icon + status badge
                Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppColors.ambulanceAccent.withAlpha(18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.ambulanceAccent.withAlpha(30),
                        ),
                      ),
                      child: Icon(
                        _statusIcons[currentStatus] ??
                            Icons.navigation_outlined,
                        color: AppColors.ambulanceAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patientName,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            patientId.isNotEmpty
                                ? 'ID: $patientId'
                                : 'Case: ${widget.caseId.length > 8 ? widget.caseId.substring(0, 8) : widget.caseId}...',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(currentStatus),
                  ],
                ),
                const SizedBox(height: 14),
                Container(height: 1, color: AppColors.border.withAlpha(120)),
                const SizedBox(height: 14),

                // Emergency type only (detailed patient info removed for simplified en route view)
                _CaseInfoTile(
                  icon: Icons.warning_amber_rounded,
                  label: 'Emergency',
                  value: emergencyType,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final Color bgColor;
    final Color textColor;
    switch (status) {
      case 'enRoute':
        bgColor = AppColors.ambulanceAccent.withAlpha(18);
        textColor = AppColors.ambulanceAccent;
        break;
      case 'arrived':
        bgColor = AppColors.statusInProgress.withAlpha(18);
        textColor = AppColors.statusInProgress;
        break;
      case 'inTransit':
        bgColor = AppColors.warning.withAlpha(30);
        textColor = AppColors.warningDark;
        break;
      case 'inTreatment':
        bgColor = Colors.blue.withAlpha(18);
        textColor = Colors.blue;
        break;
      case 'admitted':
        bgColor = Colors.deepOrange.withAlpha(18);
        textColor = Colors.deepOrange;
        break;
      case 'delivered':
      case 'completed':
        bgColor = AppColors.success.withAlpha(18);
        textColor = AppColors.successDark;
        break;
      default:
        bgColor = AppColors.ambulanceAccent.withAlpha(18);
        textColor = AppColors.ambulanceAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: textColor.withAlpha(30)),
      ),
      child: Text(
        (_statusLabels[status] ?? status).toUpperCase(),
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 0.6,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildProgressTimeline(int currentStatusIndex) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Case Progress',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_statusOrder.length, (index) {
            final status = _statusOrder[index];
            final isCompleted = index <= currentStatusIndex;
            final isCurrent = index == currentStatusIndex;
            final isLast = index == _statusOrder.length - 1;

            return _TimelineStep(
              label: _statusLabels[status] ?? status,
              icon: _statusIcons[status] ?? Icons.circle,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContactButtons({
    String? vhtId,
    String? clinicianId,
    String? clinicId,
    String? vhtName,
    String? clinicName,
    String? currentStatus,
    double? vhtLat,
    double? vhtLng,
    double? clinicLat,
    double? clinicLng,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Contact',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          // Navigate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Route to VHT when dispatched/enRoute, to clinic when arrived/inTransit
                final goingToVht = currentStatus == 'dispatched' || currentStatus == 'enRoute';
                final destLat = goingToVht ? vhtLat : clinicLat;
                final destLng = goingToVht ? vhtLng : clinicLng;
                final destLabel = goingToVht ? (vhtName ?? 'VHT Location') : (clinicName ?? 'Clinic');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MapScreen(
                      title: goingToVht ? 'Navigate to VHT' : 'Navigate to Clinic',
                      destinationLabel: destLabel,
                      destinationType: goingToVht ? 'vht' : 'clinic',
                      destinationLat: destLat,
                      destinationLng: destLng,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.navigation_rounded, size: 18),
              label: const Text('Open Navigation Map', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Call VHT button
              Expanded(
                child: _ContactButton(
                  label: 'Call VHT',
                  icon: Icons.phone,
                  color: AppColors.vhtAccent,
                  onTap: vhtId != null
                      ? () async {
                          final userData = await _fetchUserData(vhtId);
                          final phone = userData?['phoneNumber'] as String?;
                          if (phone != null && phone.isNotEmpty) {
                            await _makePhoneCall(phone);
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'VHT phone number not available'),
                                  backgroundColor: AppColors.warning,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          }
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Call Clinician button
              Expanded(
                child: _ContactButton(
                  label: 'Call Clinic',
                  icon: Icons.phone,
                  color: AppColors.clinicAccent,
                  onTap: (clinicianId != null || clinicId != null)
                      ? () async {
                          final targetId = clinicianId ?? clinicId;
                          final userData = await _fetchUserData(targetId!);
                          final phone = userData?['phoneNumber'] as String?;
                          if (phone != null && phone.isNotEmpty) {
                            await _makePhoneCall(phone);
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'Clinician phone number not available'),
                                  backgroundColor: AppColors.warning,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          }
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusActions(String currentStatus, {String? vhtId, String? patientName}) {
    // Determine which action buttons to show based on current status
    final List<_StatusAction> actions = [];

    switch (currentStatus) {
      case 'dispatched':
      case 'enRoute':
        actions.add(_StatusAction(
          label: 'Arrived at VHT',
          icon: Icons.flag_outlined,
          targetStatus: 'arrived',
          color: AppColors.statusInProgress,
        ));
        break;
      case 'arrived':
        actions.add(_StatusAction(
          label: 'Patient Picked Up',
          icon: Icons.transfer_within_a_station,
          targetStatus: 'inTransit',
          color: AppColors.ambulanceAccent,
        ));
        break;
      case 'inTransit':
        actions.add(_StatusAction(
          label: 'Delivered to Clinic',
          icon: Icons.local_hospital_outlined,
          targetStatus: 'delivered',
          color: AppColors.successDark,
        ));
        break;
      case 'inTreatment':
      case 'admitted':
      case 'delivered':
      case 'completed':
        // No more status actions needed
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.success.withAlpha(60)),
                color: AppColors.successLight,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.check_circle, color: AppColors.successDark, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    currentStatus == 'completed' ? 'Case Completed' 
                        : currentStatus == 'inTreatment' ? 'Patient In Treatment'
                        : currentStatus == 'admitted' ? 'Patient Admitted'
                        : 'Patient Delivered Successfully',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.successDark),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your delivery is complete. The clinic will handle the patient from here.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/ambulance-dashboard', (r) => false);
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text('Back to Dashboard', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Column(
      children: actions.map((action) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    action.color.withAlpha(235),
                    action.color,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: action.color.withAlpha(55),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.white.withAlpha(90),
                    blurRadius: 10,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _isUpdatingStatus
                      ? null
                      : () => _updateCaseStatus(action.targetStatus, vhtId: vhtId, patientName: patientName),
                  child: Center(
                    child: _isUpdatingStatus
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(action.icon,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                action.label,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  height: 20 / 16,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Private helper widgets ─────────────────────────────────────────────────

class _CaseInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CaseInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withAlpha(140)),
        color: Colors.white.withAlpha(210),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withAlpha(180),
            blurRadius: 10,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: AppColors.ambulanceAccent.withAlpha(16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.ambulanceAccent.withAlpha(28),
              ),
            ),
            child: Icon(icon, color: AppColors.ambulanceAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;

  const _TimelineStep({
    required this.label,
    required this.icon,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final Color circleColor;
    final Color lineColor;
    final Color textColor;
    final FontWeight fontWeight;

    if (isCurrent) {
      circleColor = AppColors.ambulanceAccent;
      lineColor = AppColors.border;
      textColor = AppColors.ambulanceAccent;
      fontWeight = FontWeight.w800;
    } else if (isCompleted) {
      circleColor = AppColors.successDark;
      lineColor = AppColors.successDark;
      textColor = AppColors.textPrimary;
      fontWeight = FontWeight.w600;
    } else {
      circleColor = AppColors.border;
      lineColor = AppColors.border;
      textColor = AppColors.textTertiary;
      fontWeight = FontWeight.w500;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline column (circle + line)
        SizedBox(
          width: 32,
          child: Column(
            children: [
              Container(
                width: isCurrent ? 28 : 22,
                height: isCurrent ? 28 : 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted || isCurrent
                      ? circleColor
                      : Colors.transparent,
                  border: Border.all(color: circleColor, width: 2),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: circleColor.withAlpha(60),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: isCompleted || isCurrent
                    ? Icon(
                        isCompleted && !isCurrent ? Icons.check : icon,
                        color: Colors.white,
                        size: isCurrent ? 16 : 13,
                      )
                    : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 28,
                  color: lineColor.withAlpha(isCompleted ? 255 : 80),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Label
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: isCurrent ? 3 : 0, bottom: 8),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: fontWeight,
                fontSize: isCurrent ? 14 : 13,
                color: textColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ContactButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    final effectiveColor = isDisabled ? AppColors.textDisabled : color;

    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: effectiveColor.withAlpha(isDisabled ? 30 : 14),
          border: Border.all(color: effectiveColor.withAlpha(isDisabled ? 40 : 50)),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: effectiveColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: effectiveColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusAction {
  final String label;
  final IconData icon;
  final String targetStatus;
  final Color color;

  const _StatusAction({
    required this.label,
    required this.icon,
    required this.targetStatus,
    required this.color,
  });
}
