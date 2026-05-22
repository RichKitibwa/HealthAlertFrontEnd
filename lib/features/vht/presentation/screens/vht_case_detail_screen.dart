import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'vht_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/screens/settings_screen.dart';
import '../../../common/presentation/screens/learning_resources_screen.dart';
import '../../../auth/current_user_session.dart';
import '../../../../core/utils/drawer_helpers.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/inline_voice_note_player.dart';
import '../../../../core/services/fcm_notification_service.dart';
import '../../../../core/services/recent_cases_service.dart';
import '../../../../l10n/app_localizations.dart';

/// VHT Case Detail Screen
///
/// Shows full case details with real-time status updates.
/// Supports two workflow paths:
/// 1. Advice path: pending → advised → completed
/// 2. Ambulance path: pending → ambulanceRequested → dispatched → enRoute → arrived → inTransit → delivered → completed
class VhtCaseDetailScreen extends StatefulWidget {
  final String caseId;

  const VhtCaseDetailScreen({Key? key, required this.caseId}) : super(key: key);

  @override
  State<VhtCaseDetailScreen> createState() => _VhtCaseDetailScreenState();
}

class _VhtCaseDetailScreenState extends State<VhtCaseDetailScreen> {
  bool _isSendingFollowUp = false;
  bool _hasMarkedRecentCase = false;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
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

  String _getStatusLabel(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toLowerCase()) {
      case 'pending':
        return l10n.pendingReview;
      case 'advised':
        return l10n.clinicianAdvised;
      case 'ambulancerequested':
        return l10n.ambulanceRequested;
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

  String _getStatusMessage(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toLowerCase()) {
      case 'pending':
        return l10n.statusMsgPending;
      case 'advised':
        return l10n.statusMsgAdvised;
      case 'ambulancerequested':
        return l10n.statusMsgAmbRequested;
      case 'dispatched':
        return l10n.statusMsgDispatched;
      case 'enroute':
        return l10n.statusMsgEnRoute;
      case 'arrived':
        return l10n.statusMsgArrived;
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
        return l10n.statusMsgCompleted;
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

  String _formatTimestamp(BuildContext context, Timestamp? timestamp) {
    if (timestamp == null) return '';
    final l10n = AppLocalizations.of(context)!;
    final dt = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.minAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hrAgo(diff.inHours);
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  int? _calculateAge(Map<String, dynamic> data) {
    final directAge = data['patientAge'];
    if (directAge != null && directAge is int) return directAge;
    final dobStr = data['patientDateOfBirth'] as String?;
    if (dobStr != null && dobStr.isNotEmpty) {
      try {
        final dob = DateTime.parse(dobStr);
        final now = DateTime.now();
        int age = now.year - dob.year;
        if (now.month < dob.month ||
            (now.month == dob.month && now.day < dob.day))
          age--;
        return age;
      } catch (_) {}
    }
    return null;
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.couldNotOpenDialer(phone),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _callAdmin() async {
    try {
      final adminQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Admin')
          .limit(1)
          .get();

      if (adminQuery.docs.isNotEmpty) {
        final adminData = adminQuery.docs.first.data();
        final phone = adminData['phoneNumber'] as String? ?? '';
        if (phone.isNotEmpty) {
          await _callPhone(phone);
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.noAdminContactFound),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.errorFindingAdmin}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFullScreenImage(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(url, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendFollowUpUpdate(
    String caseId,
    String currentStatus, {
    String? clinicName,
    String? patientName,
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(ctx)!.sendFollowUpUpdate,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(ctx)!.provideUpdateOnCondition,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'e.g. Patient condition worsening, needs urgent attention...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary.withAlpha(120),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(AppLocalizations.of(ctx)!.cancel, maxLines: 1),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty)
                Navigator.pop(ctx, controller.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vhtAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(AppLocalizations.of(ctx)!.sendUpdate, maxLines: 1),
            ),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;
    setState(() => _isSendingFollowUp = true);

    try {
      final vhtName =
          '${CurrentUserSession.firstName ?? ''} ${CurrentUserSession.lastName ?? ''}'
              .trim();

      await FirebaseFirestore.instance
          .collection('emergencyCases')
          .doc(caseId)
          .collection('followUps')
          .add({
            'message': result,
            'sentBy': CurrentUserSession.uid,
            'sentByName': vhtName,
            'sentByRole': 'VHT',
            'timestamp': FieldValue.serverTimestamp(),
          });

      await FirebaseFirestore.instance
          .collection('emergencyCases')
          .doc(caseId)
          .update({
            'lastFollowUp': result,
            'lastFollowUpBy': vhtName,
            'lastFollowUpAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (clinicName != null && clinicName.isNotEmpty) {
        await FCMNotificationService().notifyCliniciansOfVhtFollowUp(
          facilityName: clinicName,
          caseId: caseId,
          patientName: patientName?.isNotEmpty == true
              ? patientName!
              : 'patient',
          vhtName: vhtName,
          followUpMessage: result,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.followUpUpdateSentSuccessfully,
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.failedToSendFollowUp}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingFollowUp = false);
    }
  }

  Future<void> _sendAmbulanceDelayUpdate(
    String caseId, {
    required String clinicName,
    required String patientName,
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(ctx)!.sendFollowUpUpdate,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ambulance response seems delayed. Request a quick update from the clinic.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'e.g. Ambulance dispatched but no arrival yet. Patient condition worsening...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary.withAlpha(120),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(AppLocalizations.of(ctx)!.cancel, maxLines: 1),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty)
                Navigator.pop(ctx, controller.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vhtAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(AppLocalizations.of(ctx)!.sendUpdate, maxLines: 1),
            ),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;
    setState(() => _isSendingFollowUp = true);

    try {
      final vhtName =
          '${CurrentUserSession.firstName ?? ''} ${CurrentUserSession.lastName ?? ''}'
              .trim();
      final message = 'Ambulance delayed: $result';

      await FirebaseFirestore.instance
          .collection('emergencyCases')
          .doc(caseId)
          .collection('followUps')
          .add({
            'message': message,
            'sentBy': CurrentUserSession.uid,
            'sentByName': vhtName,
            'sentByRole': 'VHT',
            'timestamp': FieldValue.serverTimestamp(),
          });

      await FirebaseFirestore.instance
          .collection('emergencyCases')
          .doc(caseId)
          .update({
            'lastFollowUp': message,
            'lastFollowUpBy': vhtName,
            'lastFollowUpAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (clinicName.trim().isNotEmpty) {
        await FCMNotificationService().notifyCliniciansOfVhtFollowUp(
          facilityName: clinicName,
          caseId: caseId,
          patientName: patientName.isNotEmpty ? patientName : 'patient',
          vhtName: vhtName,
          followUpMessage: message,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.followUpUpdateSentSuccessfully,
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.failedToSendFollowUp}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingFollowUp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'VHT',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        pageTitle: AppLocalizations.of(context)!.caseDetails,
        showBackButton: true,
        onBack: () => Navigator.pop(context),
        onSignOut: () async {
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
          }
        },
        onDashboard: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/vht-dashboard',
            (r) => false,
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
              (r) => false,
            );
          }
        },
      ),
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
              return Center(
                child: Text(AppLocalizations.of(context)!.caseNotFound),
              );
            }

            final l10n = AppLocalizations.of(context)!;
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final emergencyType =
                data['emergencyType'] as String? ?? l10n.unknown;
            final urgency = data['urgencyLevel'] as String? ?? 'medium';
            final status = data['status'] as String? ?? 'pending';
            final effectiveStatus = status;
            final patientId = data['patientId'] as String? ?? '';
            final patientFirstName = data['patientFirstName'] as String? ?? '';
            final patientLastName = data['patientLastName'] as String? ?? '';
            final patientGender = data['patientGender'] as String? ?? '';
            final patientAge = data['patientAge'] as int?;
            final notes = data['notes'] as String? ?? '';
            final clinicName =
                data['assignedClinicName'] as String? ?? l10n.unknownClinic;
            final clinicianName =
                data['assignedClinicianName'] as String? ?? '';
            final clinicianNotes = data['clinicianNotes'] as String? ?? '';
            final clinicianAdvice = data['clinicianAdvice'] as String? ?? '';
            final clinicianDecision =
                data['clinicianDecision'] as String? ?? '';
            final createdAt = data['createdAt'] as Timestamp?;
            final updatedAt = data['updatedAt'] as Timestamp?;
            final lastFollowUpAt = data['lastFollowUpAt'] as Timestamp?;
            final statusColor = _getStatusColor(effectiveStatus);
            final isAdvicePath =
                clinicianDecision == 'advise_vht' ||
                effectiveStatus == 'advised';
            final isCaseOpen = status != 'completed' && status != 'cancelled';
            final now = DateTime.now();
            const ambulanceStaleThreshold = Duration(minutes: 15);
            const followUpThrottleThreshold = Duration(minutes: 10);
            final shouldShowAmbulanceDelayCommunication =
                isCaseOpen &&
                ['dispatched', 'enRoute', 'inTransit'].contains(status) &&
                updatedAt != null &&
                now.difference(updatedAt.toDate()) > ambulanceStaleThreshold &&
                (lastFollowUpAt == null ||
                    now.difference(lastFollowUpAt.toDate()) >
                        followUpThrottleThreshold);
            final clinicianAdviceText = clinicianAdvice.isNotEmpty
                ? clinicianAdvice
                : clinicianNotes;

            // Additional fields for contacts and media
            final clinicianPhone =
                data['clinicianPhoneNumber'] as String? ?? '';
            final ambulanceDriverId =
                data['assignedAmbulanceId'] as String? ?? '';
            final imageUrl = data['imageUrl'] as String? ?? '';
            final videoUrl = data['videoUrl'] as String? ?? '';
            final voiceNoteUrl = data['voiceNoteUrl'] as String? ?? '';
            final calculatedAge = _calculateAge(data);

            // Build patient display name
            String patientDisplayName = '';
            if (patientFirstName.isNotEmpty || patientLastName.isNotEmpty) {
              patientDisplayName = '$patientFirstName $patientLastName'.trim();
            }

            // Record this case as "recent" for fast return from dashboards.
            if (!_hasMarkedRecentCase) {
              _hasMarkedRecentCase = true;
              final uid = CurrentUserSession.uid;
              if (uid != null && uid.isNotEmpty) {
                final emergencyTypeForRecent = emergencyType;
                Future.microtask(() async {
                  try {
                    await RecentCasesService.markCaseAsRecent(
                      userId: uid,
                      caseId: widget.caseId,
                      emergencyType: emergencyTypeForRecent,
                      patientId: patientId,
                      patientName: patientDisplayName,
                    );
                  } catch (_) {}
                });
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Emergency type + urgency header
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
                          emergencyType,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.vhtAccent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getUrgencyColor(urgency).withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          urgency.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: _getUrgencyColor(urgency),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (createdAt != null)
                        Text(
                          _formatTimestamp(context, createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 2. Status card
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
                          _getStatusIcon(effectiveStatus),
                          color: statusColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getStatusLabel(context, effectiveStatus),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getStatusMessage(context, effectiveStatus),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Clinician Advice / Notes (privacy: content hidden for VHT)
                  //
                  // VHT can still see the case status progression, but clinician notes
                  // are intentionally not displayed here.
                  if (clinicianAdviceText.isNotEmpty && isAdvicePath) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.blue.withAlpha(40)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.medical_information_rounded,
                                size: 20,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.clinicianAdvice,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            clinicianAdviceText,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 4. Clinician Notes (privacy: content hidden for VHT)
                  if (clinicianNotes.isNotEmpty &&
                      !isAdvicePath &&
                      clinicianDecision.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.clinicAccent.withAlpha(8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.clinicAccent.withAlpha(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.medical_information_outlined,
                                size: 18,
                                color: AppColors.clinicAccent,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.clinicianNotes,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.clinicAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.awaitingStatusUpdate,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // 5. Patient details (with calculated age)
                  _buildInfoCard(l10n.patientInformation, [
                    if (patientDisplayName.isNotEmpty)
                      _buildInfoRow(l10n.name, patientDisplayName),
                    if (patientId.isNotEmpty)
                      _buildInfoRow(l10n.patientIdLabel, patientId),
                    if (patientGender.isNotEmpty)
                      _buildInfoRow(
                        l10n.gender,
                        patientGender[0].toUpperCase() +
                            patientGender.substring(1),
                      ),
                    if (calculatedAge != null)
                      _buildInfoRow(l10n.age, l10n.ageYears(calculatedAge)),
                  ]),
                  const SizedBox(height: 12),

                  // 6. Assigned clinic
                  _buildInfoCard(l10n.assignedFacility, [
                    _buildInfoRow(l10n.clinicLabel, clinicName),
                    // Clinician identity is not displayed to VHT (privacy).
                  ]),
                  const SizedBox(height: 12),

                  // 7. Contact section (call clinician, call ambulance driver when dispatched)
                  if (isCaseOpen) ...[
                    _buildInfoCard(l10n.contactSection, [
                      if (clinicianPhone.isNotEmpty)
                        InkWell(
                          onTap: () => _callPhone(clinicianPhone),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.callClinician,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (clinicianName.isNotEmpty)
                                        Text(
                                          clinicianName,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (ambulanceDriverId.isNotEmpty &&
                          ['dispatched', 'enRoute'].contains(status))
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(ambulanceDriverId)
                              .get(),
                          builder: (context, driverSnap) {
                            if (!driverSnap.hasData || !driverSnap.data!.exists)
                              return const SizedBox.shrink();
                            final driverData =
                                driverSnap.data!.data() as Map<String, dynamic>;
                            final driverPhone =
                                driverData['phoneNumber'] as String? ?? '';
                            final driverName =
                                '${driverData['firstName'] ?? ''} ${driverData['lastName'] ?? ''}'
                                    .trim();
                            if (driverPhone.isEmpty)
                              return const SizedBox.shrink();
                            return InkWell(
                              onTap: () => _callPhone(driverPhone),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.callAmbulanceDriver,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          if (driverName.isNotEmpty)
                                            Text(
                                              driverName,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      size: 18,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      if (shouldShowAmbulanceDelayCommunication)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isSendingFollowUp
                                  ? null
                                  : () => _sendAmbulanceDelayUpdate(
                                      widget.caseId,
                                      clinicName: clinicName,
                                      patientName: patientDisplayName.isNotEmpty
                                          ? patientDisplayName
                                          : 'patient',
                                    ),
                              icon: Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.vhtAccent,
                              ),
                              label: Text(
                                'Ambulance delayed - message clinic',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.vhtAccent,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: AppColors.vhtAccent.withAlpha(160),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (clinicianPhone.isEmpty &&
                          !(ambulanceDriverId.isNotEmpty &&
                              ['dispatched', 'enRoute'].contains(status)) &&
                          !shouldShowAmbulanceDelayCommunication)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            l10n.noContactsAvailableYet,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                    ]),
                    const SizedBox(height: 12),
                  ],

                  // 8. VHT Notes
                  if (notes.isNotEmpty) ...[
                    _buildInfoCard(l10n.vhtNotes, [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          notes,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                  ],

                  // 9. Media Attachments section (images, videos, voice notes)
                  if (imageUrl.isNotEmpty ||
                      videoUrl.isNotEmpty ||
                      voiceNoteUrl.isNotEmpty) ...[
                    _buildInfoCard(l10n.attachments, [
                      if (imageUrl.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _showFullScreenImage(context, imageUrl),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imageUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (ctx, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  height: 180,
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (ctx, err, stack) => Container(
                                height: 80,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withAlpha(20),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.couldNotLoadImage,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.tapImageToViewFullScreen,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (videoUrl.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final uri = Uri.parse(videoUrl);
                            if (await canLaunchUrl(uri))
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(10),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.blue.withAlpha(30),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.videocam_rounded,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.videoAttached,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      Text(
                                        l10n.tapToPlayVideo,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.open_in_new,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (voiceNoteUrl.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        InlineVoiceNotePlayer(voiceNoteUrl: voiceNoteUrl),
                      ],
                    ]),
                    const SizedBox(height: 12),
                  ],

                  // 10. Last follow-up
                  if ((data['lastFollowUp'] as String? ?? '').isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.blue.withAlpha(30)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.update_rounded,
                                size: 18,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.latestFollowUp,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                              const Spacer(),
                              if (data['lastFollowUpAt'] != null)
                                Text(
                                  _formatTimestamp(
                                    context,
                                    data['lastFollowUpAt'] as Timestamp?,
                                  ),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data['lastFollowUp'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // 11. Contact Admin section (when dispatch requested)
                  if ([
                    'ambulanceRequested',
                    'dispatched',
                    'enRoute',
                  ].contains(status)) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withAlpha(8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.deepPurple.withAlpha(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.admin_panel_settings,
                                size: 18,
                                color: Colors.deepPurple,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.needHelpWithDispatch,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.contactAdminForDispatch,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _callAdmin(),
                                  icon: Icon(
                                    Icons.phone,
                                    size: 16,
                                    color: Colors.deepPurple,
                                  ),
                                  label: Text(
                                    l10n.callAdmin,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.deepPurple.withAlpha(60),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _sendFollowUpUpdate(
                                    widget.caseId,
                                    status,
                                    clinicName:
                                        data['assignedClinicName'] as String?,
                                    patientName:
                                        '${data['patientFirstName'] ?? ''} ${data['patientLastName'] ?? ''}'
                                            .trim(),
                                  ),
                                  icon: Icon(
                                    Icons.message,
                                    size: 16,
                                    color: Colors.deepPurple,
                                  ),
                                  label: Text(
                                    l10n.message,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.deepPurple.withAlpha(60),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // 12. Last updated
                  if (updatedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${l10n.lastUpdated}: ${_formatTimestamp(context, updatedAt)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary.withAlpha(150),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 13. Send Follow-up button (only for open cases)
                  if (isCaseOpen) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isSendingFollowUp
                            ? null
                            : () => _sendFollowUpUpdate(
                                widget.caseId,
                                status,
                                clinicName:
                                    data['assignedClinicName'] as String?,
                                patientName:
                                    '${data['patientFirstName'] ?? ''} ${data['patientLastName'] ?? ''}'
                                        .trim(),
                              ),
                        icon: _isSendingFollowUp
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.edit_note_rounded),
                        label: Text(
                          _isSendingFollowUp
                              ? l10n.sending
                              : l10n.sendFollowUpUpdate,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.vhtAccent,
                          side: BorderSide(
                            color: AppColors.vhtAccent,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 14. Progress Timeline
                  _buildStatusTimeline(
                    context,
                    effectiveStatus,
                    clinicianDecision,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
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
              color: AppColors.vhtAccent,
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

  Widget _buildStatusTimeline(
    BuildContext context,
    String currentStatus,
    String clinicianDecision,
  ) {
    final l10n = AppLocalizations.of(context)!;
    // Determine which workflow path
    final isAdvicePath =
        clinicianDecision == 'advise_vht' || currentStatus == 'advised';

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
          'discharged',
        ].contains(currentStatus)) {
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
        'discharged',
        'completed',
      ];
    } else {
      // Default: show simple pending flow until clinician decides
      statuses = ['pending', 'completed'];
    }

    final currentIndex = statuses.indexOf(currentStatus);

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
            isAdvicePath ? l10n.adviceProgress : l10n.caseProgress,
            style: const TextStyle(
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
                            ? (isCurrent ? _getStatusColor(s) : Colors.green)
                            : AppColors.border,
                        border: isCurrent
                            ? Border.all(
                                color: _getStatusColor(s).withAlpha(80),
                                width: 2,
                              )
                            : null,
                      ),
                      child: isCompleted
                          ? Icon(
                              isCurrent ? _getStatusIcon(s) : Icons.check,
                              size: 12,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    if (index < statuses.length - 1)
                      Container(
                        width: 2,
                        height: 18,
                        color: isCompleted && index < currentIndex
                            ? Colors.green
                            : AppColors.border,
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      _getStatusLabel(context, s),
                      style: TextStyle(
                        fontSize: 12,
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
            );
          }),
        ],
      ),
    );
  }
}
