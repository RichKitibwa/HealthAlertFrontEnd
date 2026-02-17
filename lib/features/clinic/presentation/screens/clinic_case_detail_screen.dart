import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'clinic_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/screens/settings_screen.dart';
import '../../../common/presentation/screens/learning_resources_screen.dart';
import '../../../auth/current_user_session.dart';
import '../../../../core/utils/drawer_helpers.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/fcm_notification_service.dart';
import '../../../../core/widgets/inline_voice_note_player.dart';

/// Clinic Case Detail Screen
///
/// Displays full details of an emergency case for the clinician to review.
/// Two workflow paths:
/// 1. Advice path: Clinician sends advice → VHT acts on it → Clinician closes case
/// 2. Ambulance path: Clinician requests ambulance → Admin dispatches → Ambulance delivers
class ClinicCaseDetailScreen extends StatefulWidget {
  final String caseId;

  const ClinicCaseDetailScreen({Key? key, required this.caseId}) : super(key: key);

  @override
  State<ClinicCaseDetailScreen> createState() => _ClinicCaseDetailScreenState();
}

class _ClinicCaseDetailScreenState extends State<ClinicCaseDetailScreen> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();
  bool _isUpdating = false;

  @override
  void dispose() {
    _notesController.dispose();
    _treatmentController.dispose();
    super.dispose();
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
      case 'intreatment': return Colors.blue;
      case 'admitted': return Colors.deepOrange;
      case 'discharged': return Colors.green.shade700;
      case 'received': return Colors.teal.shade600;
      case 'completed': return Colors.green.shade700;
      case 'cancelled': return Colors.red;
      default: return AppColors.textSecondary;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending': return 'Pending Review';
      case 'advised': return 'Advice Sent';
      case 'ambulancerequested': return 'Ambulance Requested';
      case 'dispatched': return 'Ambulance Dispatched';
      case 'enroute': return 'En Route';
      case 'arrived': return 'Arrived';
      case 'intransit': return 'In Transit';
      case 'delivered': return 'Delivered';
      case 'intreatment': return 'In Treatment';
      case 'admitted': return 'Admitted';
      case 'discharged': return 'Discharged';
      case 'received': return 'Patient Received';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      default: return status ?? 'Unknown';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Icons.hourglass_top_rounded;
      case 'advised': return Icons.message_rounded;
      case 'ambulancerequested': return Icons.local_shipping_outlined;
      case 'dispatched': return Icons.local_shipping_rounded;
      case 'enroute': return Icons.directions_car_rounded;
      case 'arrived': return Icons.location_on_rounded;
      case 'intransit': return Icons.transfer_within_a_station_rounded;
      case 'delivered': return Icons.check_circle_rounded;
      case 'intreatment': return Icons.medical_services_rounded;
      case 'admitted': return Icons.local_hotel_rounded;
      case 'discharged': return Icons.exit_to_app_rounded;
      case 'received': return Icons.how_to_reg_rounded;
      case 'completed': return Icons.verified_rounded;
      case 'cancelled': return Icons.cancel_rounded;
      default: return Icons.info_rounded;
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dt = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Request ambulance dispatch (sets status to ambulanceRequested for admin)
  Future<void> _requestAmbulanceDispatch(Map<String, dynamic> caseData) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.local_shipping_rounded, color: AppColors.clinicAccent, size: 22),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Request Ambulance Dispatch',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const Text(
          'This will forward the case to dispatch to assign an ambulance. Do you want to proceed?',
          style: TextStyle(fontSize: 14),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600), maxLines: 1),
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
                      backgroundColor: AppColors.clinicAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: const Text('Dispatch', style: TextStyle(fontWeight: FontWeight.w700), maxLines: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _isUpdating = true);

    try {
      final notes = _notesController.text.trim();
      await FirebaseFirestore.instance.collection('emergencyCases').doc(widget.caseId).update({
        'status': 'ambulanceRequested',
        'updatedBy': CurrentUserSession.uid,
        if (notes.isNotEmpty) 'clinicianNotes': notes,
        'clinicianDecision': 'dispatch_ambulance',
        'clinicianDecisionAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notify nearest admin: popup + in-app
      try {
        final notifService = FCMNotificationService();
        final emergencyType = caseData['emergencyType'] as String? ?? 'Unknown';
        final patientFirst = caseData['patientFirstName'] as String? ?? '';
        final patientLast = caseData['patientLastName'] as String? ?? '';
        final patientName = '$patientFirst $patientLast'.trim().isNotEmpty
            ? '$patientFirst $patientLast'.trim()
            : 'Unknown';
        final clinicianName = CurrentUserSession.fullName;
        // Use VHT coordinates from the case to find the nearest admin.
        final vhtLat = (caseData['vhtLatitude'] as num?)?.toDouble() ??
            (caseData['latitude'] as num?)?.toDouble();
        final vhtLng = (caseData['vhtLongitude'] as num?)?.toDouble() ??
            (caseData['longitude'] as num?)?.toDouble();
        await notifService.notifyAdminsOfAmbulanceRequest(
          caseId: widget.caseId,
          emergencyType: emergencyType,
          patientName: patientName,
          clinicianName: clinicianName,
          vhtLatitude: vhtLat,
          vhtLongitude: vhtLng,
        );
      } catch (e) {
        debugPrint('Failed to notify admins: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ambulance dispatch requested.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  /// Advise VHT (sets status to advised)
  Future<void> _adviseVHT(Map<String, dynamic> caseData) async {
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add advice for the VHT first.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final notes = _notesController.text.trim();
      await FirebaseFirestore.instance.collection('emergencyCases').doc(widget.caseId).update({
        'status': 'advised',
        'clinicianNotes': notes,
        'clinicianDecision': 'advise_vht',
        'clinicianDecisionAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notify VHT: popup + in-app
      try {
        final notifService = FCMNotificationService();
        final vhtId = caseData['vhtId'] as String? ?? '';
        final patientFirst = caseData['patientFirstName'] as String? ?? '';
        final patientLast = caseData['patientLastName'] as String? ?? '';
        final patientName = '$patientFirst $patientLast'.trim().isNotEmpty ? '$patientFirst $patientLast'.trim() : 'Unknown Patient';
        final clinicianName = CurrentUserSession.fullName;
        if (vhtId.isNotEmpty) {
          await notifService.notifyVhtOfClinicianAdvice(
            vhtId: vhtId,
            caseId: widget.caseId,
            patientName: patientName,
            clinicianName: clinicianName,
            advice: notes,
          );
        }
      } catch (e) {
        debugPrint('Failed to notify VHT of advice: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Advice sent to VHT successfully.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  /// Close / complete the case
  Future<void> _closeCase(Map<String, dynamic> caseData) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green, size: 22),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Close Case',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure the patient is OK and this case can be closed?',
          style: TextStyle(fontSize: 14),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600), maxLines: 1),
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
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: const Text('Close Case', style: TextStyle(fontWeight: FontWeight.w700), maxLines: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _isUpdating = true);

    try {
      await FirebaseFirestore.instance.collection('emergencyCases').doc(widget.caseId).update({
        'status': 'completed',
        'updatedBy': CurrentUserSession.uid,
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notify VHT: popup + in-app (case closed via advice path)
      try {
        final notifService = FCMNotificationService();
        final vhtId = caseData['vhtId'] as String? ?? '';
        final patientFirst = caseData['patientFirstName'] as String? ?? '';
        final patientLast = caseData['patientLastName'] as String? ?? '';
        final patientName = '$patientFirst $patientLast'.trim().isNotEmpty
            ? '$patientFirst $patientLast'.trim()
            : 'Unknown Patient';
        final clinicianName = CurrentUserSession.fullName;
        final emergencyType = caseData['emergencyType'] as String? ?? 'Emergency';
        if (vhtId.isNotEmpty) {
          await notifService.notifyOnCaseClosed(
            caseId: widget.caseId,
            emergencyType: emergencyType,
            patientName: patientName,
            vhtId: vhtId,
            clinicianName: clinicianName,
          );
        }
      } catch (e) {
        debugPrint('Failed to notify VHT of case closure: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Case closed successfully.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  /// Receive patient at clinic (sets status to inTreatment)
  Future<void> _receivePatient(Map<String, dynamic> data) async {
    setState(() => _isUpdating = true);
    try {
      await FirebaseFirestore.instance.collection('emergencyCases').doc(widget.caseId).update({
        'status': 'inTreatment',
        'updatedBy': CurrentUserSession.uid,
        'receivedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Note: Cloud Function handles notifications for inTreatment status

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient received. You can now add treatment notes.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  /// Admit patient (for more serious cases needing inpatient care)
  Future<void> _admitPatient(Map<String, dynamic> data) async {
    setState(() => _isUpdating = true);
    try {
      await FirebaseFirestore.instance.collection('emergencyCases').doc(widget.caseId).update({
        'status': 'admitted',
        'updatedBy': CurrentUserSession.uid,
        'admittedAt': FieldValue.serverTimestamp(),
        'admittedBy': CurrentUserSession.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient admitted. Add treatment notes when ready to discharge.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  /// Discharge patient and complete treatment
  Future<void> _dischargePatient(Map<String, dynamic> data) async {
    final treatmentNotes = _treatmentController.text.trim();
    if (treatmentNotes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter treatment notes before discharging'), backgroundColor: Colors.orange),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.exit_to_app_rounded, color: Colors.green, size: 22),
            const SizedBox(width: 10),
            const Text('Discharge Patient', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
        content: const Text(
          'This will mark the patient as discharged and close this case. Are you sure?',
          style: TextStyle(fontSize: 14),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
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
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Discharge', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _isUpdating = true);
    try {
      // Save treatment record to subcollection
      await FirebaseFirestore.instance
          .collection('emergencyCases')
          .doc(widget.caseId)
          .collection('treatments')
          .add({
        'treatmentNotes': treatmentNotes,
        'clinicianId': CurrentUserSession.uid,
        'clinicianName': CurrentUserSession.fullName,
        'treatedAt': FieldValue.serverTimestamp(),
      });

      // Update case status to completed with treatment notes
      await FirebaseFirestore.instance.collection('emergencyCases').doc(widget.caseId).update({
        'status': 'completed',
        'updatedBy': CurrentUserSession.uid,
        'treatmentNotes': treatmentNotes,
        'dischargedAt': FieldValue.serverTimestamp(),
        'dischargedBy': CurrentUserSession.uid,
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notify VHT (popup+inapp) and admin (popup+inapp) on discharge
      try {
        final notifService = FCMNotificationService();
        final vhtId = data['vhtId'] as String? ?? '';
        final patientFirst = data['patientFirstName'] as String? ?? '';
        final patientLast = data['patientLastName'] as String? ?? '';
        final patientName = '$patientFirst $patientLast'.trim().isNotEmpty
            ? '$patientFirst $patientLast'.trim()
            : 'Unknown Patient';
        final clinicName = data['assignedClinicName'] as String? ?? 'Clinic';
        final clinicianName = CurrentUserSession.fullName;
        final emergencyType = data['emergencyType'] as String? ?? 'Emergency';
        if (vhtId.isNotEmpty) {
          await notifService.notifyOnPatientDischarged(
            caseId: widget.caseId,
            emergencyType: emergencyType,
            patientName: patientName,
            vhtId: vhtId,
            clinicName: clinicName,
            clinicianName: clinicianName,
          );
        }
      } catch (e) {
        debugPrint('Failed to send discharge notifications: $e');
      }

      if (mounted) {
        _treatmentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient discharged. Case completed.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
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
        if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) age--;
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
          SnackBar(content: Text('Could not open dialer for $phone'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Clinic',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        pageTitle: 'Case Details',
        showBackButton: true,
        onBack: () => Navigator.pop(context),
        onSignOut: () async {
          await LogoutUtils.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }
        },
        onDashboard: () {
          Navigator.pushNamedAndRemoveUntil(context, '/clinic-dashboard', (route) => false);
        },
        onSettings: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        },
        onLearningResources: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningResourcesScreen()));
        },
      ),
      endDrawer: buildStandardDrawer(context: context, dashboardRoute: '/clinic-dashboard'),
      backgroundColor: AppColors.background,
      bottomNavigationBar: ClinicNavigationBar(
        currentIndex: 2,
        onItemSelected: (index) {
          if (index == 0) {
            Navigator.pushNamedAndRemoveUntil(context, '/clinic-dashboard', (route) => false);
          }
        },
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('emergencyCases').doc(widget.caseId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Case not found.'));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final emergencyType = data['emergencyType'] as String? ?? 'Unknown';
            final urgency = data['urgencyLevel'] as String? ?? 'medium';
            final status = data['status'] as String? ?? 'pending';
            final patientId = data['patientId'] as String? ?? '';
            final patientFirstName = data['patientFirstName'] as String? ?? '';
            final patientLastName = data['patientLastName'] as String? ?? '';
            final patientGender = data['patientGender'] as String? ?? '';
            final patientAge = _calculateAge(data);
            final notes = data['notes'] as String? ?? '';
            final vhtName = data['vhtName'] as String? ?? 'Unknown VHT';
            final vhtPhone = data['vhtPhoneNumber'] as String? ?? '';
            final ambulanceDriverId = data['assignedAmbulanceId'] as String? ?? '';
            final clinicianNotes = data['clinicianNotes'] as String? ?? '';
            final clinicianDecision = data['clinicianDecision'] as String? ?? '';
            final imageUrl = data['imageUrl'] as String? ?? '';
            final videoUrl = data['videoUrl'] as String? ?? '';
            final voiceNoteUrl = data['voiceNoteUrl'] as String? ?? '';
            final createdAt = data['createdAt'] as Timestamp?;
            final isPending = status == 'pending';
            final isAdvised = status == 'advised';
            final isAmbulanceRequested = status == 'ambulanceRequested';
            final canRequestAmbulance = isPending || isAdvised || isAmbulanceRequested;
            final isAmbulancePath = clinicianDecision == 'dispatch_ambulance';
            final statusColor = _getStatusColor(status);

            // Build patient display name
            String patientDisplayName = '';
            if (patientFirstName.isNotEmpty || patientLastName.isNotEmpty) {
              patientDisplayName = '$patientFirstName $patientLastName'.trim();
            }

            final bottomInset = MediaQuery.of(context).viewInsets.bottom;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status + Urgency Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _getUrgencyColor(urgency).withAlpha(15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _getUrgencyColor(urgency).withAlpha(40)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                emergencyType,
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: _getUrgencyColor(urgency)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Urgency: ${urgency.toUpperCase()}',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _getUrgencyColor(urgency)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor.withAlpha(60)),
                          ),
                          child: Text(
                            _getStatusLabel(status),
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: statusColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Patient Details Card
                  _DetailCard(title: 'Patient Information', children: [
                    if (patientDisplayName.isNotEmpty) _DetailRow('Name', patientDisplayName),
                    if (patientId.isNotEmpty) _DetailRow('Patient ID', patientId),
                    _DetailRow('Gender', patientGender.isNotEmpty ? patientGender[0].toUpperCase() + patientGender.substring(1) : 'Not specified'),
                    _DetailRow('Age', patientAge != null ? '$patientAge years' : 'Not specified'),
                  ]),
                  const SizedBox(height: 12),

                  // VHT Info + Contact
                  _DetailCard(title: 'Reporting VHT', children: [
                    _DetailRow('Name', vhtName),
                    if (vhtPhone.isNotEmpty)
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text('Phone', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: AppColors.textSecondary)),
                          ),
                          Expanded(
                            child: Text(vhtPhone, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
                          ),
                          IconButton(
                            icon: Icon(Icons.phone, color: Colors.green, size: 20),
                            onPressed: () => _callPhone(vhtPhone),
                            tooltip: 'Call VHT',
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                  ]),

                  // Ambulance driver contact (when assigned)
                  if (ambulanceDriverId.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(ambulanceDriverId).get(),
                      builder: (context, driverSnapshot) {
                        if (!driverSnapshot.hasData || !driverSnapshot.data!.exists) {
                          return const SizedBox.shrink();
                        }
                        final driverData = driverSnapshot.data!.data() as Map<String, dynamic>;
                        final driverName = '${driverData['firstName'] ?? ''} ${driverData['lastName'] ?? ''}'.trim();
                        final driverPhone = driverData['phoneNumber'] as String? ?? '';

                        if (driverName.isEmpty && driverPhone.isEmpty) return const SizedBox.shrink();

                        return _DetailCard(title: 'Ambulance Driver', children: [
                          _DetailRow('Name', driverName.isNotEmpty ? driverName : 'Unknown'),
                          if (driverPhone.isNotEmpty)
                            Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text('Phone', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: AppColors.textSecondary)),
                                ),
                                Expanded(
                                  child: Text(driverPhone, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
                                ),
                                IconButton(
                                  icon: Icon(Icons.phone, color: Colors.green, size: 20),
                                  onPressed: () => _callPhone(driverPhone),
                                  tooltip: 'Call Driver',
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                        ]);
                      },
                    ),
                  ],
                  const SizedBox(height: 12),

                  // VHT Notes
                  if (notes.isNotEmpty) ...[
                    _DetailCard(title: 'VHT Notes', children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(notes, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5)),
                      ),
                    ]),
                    const SizedBox(height: 12),
                  ],

                  // Media Attachments Section - always show
                  _DetailCard(title: 'Media from VHT', children: [
                    if (imageUrl.isEmpty && videoUrl.isEmpty && voiceNoteUrl.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('No media attached by VHT', style: TextStyle(fontSize: 13, color: Colors.grey[500], fontStyle: FontStyle.italic)),
                      ),
                      if (imageUrl.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _showFullScreenImage(context, imageUrl),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imageUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (ctx, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  height: 200,
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (ctx, err, stack) => Container(
                                height: 100,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withAlpha(20),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.broken_image, color: AppColors.textSecondary),
                                    const SizedBox(height: 4),
                                    Text('Could not load image', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Tap image to view full screen', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                      if (videoUrl.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            try {
                              final uri = Uri.parse(videoUrl);
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open video'), backgroundColor: Colors.red));
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(10),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.blue.withAlpha(30)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.videocam_rounded, color: Colors.blue, size: 24),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Video Attached', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.blue)),
                                      Text('Tap to play video', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.open_in_new, color: Colors.blue, size: 18),
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

                  // Fallback: check attachmentUrls list
                  ...() {
                    final attachmentUrls = (data['attachmentUrls'] as List<dynamic>?)?.cast<String>() ?? [];
                    if (attachmentUrls.isNotEmpty && imageUrl.isEmpty && videoUrl.isEmpty && voiceNoteUrl.isEmpty) {
                      return <Widget>[
                        _DetailCard(title: 'Attachments', children: [
                          ...attachmentUrls.map((url) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () async {
                                final uri = Uri.parse(url);
                                if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.attachment, color: AppColors.clinicAccent, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text('View attachment', style: TextStyle(fontSize: 13, color: AppColors.clinicAccent, decoration: TextDecoration.underline))),
                                ],
                              ),
                            ),
                          )),
                        ]),
                        const SizedBox(height: 12),
                      ];
                    }
                    return <Widget>[];
                  }(),

                  // Clinician notes (already provided — for non-pending cases)
                  if (clinicianNotes.isNotEmpty && !isPending) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.clinicAccent.withAlpha(8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.clinicAccent.withAlpha(30)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.medical_information_outlined, size: 18, color: AppColors.clinicAccent),
                              const SizedBox(width: 8),
                              Text(
                                isAmbulancePath ? 'Your Notes' : 'Your Advice to VHT',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.clinicAccent),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(clinicianNotes, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Progress Timeline
                  if (!isPending) ...[
                    _buildProgressTimeline(status, clinicianDecision),
                    const SizedBox(height: 16),
                  ],

                  // Time info
                  if (createdAt != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Reported: ${_formatTimestamp(createdAt)}',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary.withAlpha(150)),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // === ACTION SECTIONS ===

                  // Pending: show Take Action (notes input + two buttons)
                  if (isPending) ...[
                    const Divider(),
                    const SizedBox(height: 12),
                    Text('Take Action', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text('Add notes and decide whether to dispatch an ambulance or advise the VHT.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add your notes or advice for the VHT...',
                        hintStyle: TextStyle(color: AppColors.textSecondary.withAlpha(150)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.clinicAccent, width: 1.5)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isUpdating ? null : () => _requestAmbulanceDispatch(data),
                        icon: const Icon(Icons.local_shipping_rounded),
                        label: const Text('Request Ambulance Dispatch', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.clinicAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _isUpdating ? null : () => _adviseVHT(data),
                        icon: Icon(Icons.message_outlined, color: AppColors.clinicAccent),
                        label: Text('Send Advice to VHT', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.clinicAccent)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.clinicAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Show ambulance dispatch button for advised or ambulanceRequested cases
                  if (canRequestAmbulance && !isPending) ...[
                    const Divider(),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isUpdating ? null : () => _requestAmbulanceDispatch(data),
                        icon: const Icon(Icons.local_shipping_rounded),
                        label: const Text('Request Ambulance Dispatch', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.clinicAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Advised: show Close Case button
                  if (isAdvised) ...[
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'You advised the VHT. When the patient is OK, close the case.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isUpdating ? null : () => _closeCase(data),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Close Case (Patient OK)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Delivered: show Receive Patient button (ambulance path)
                  if (status == 'delivered') ...[
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Patient has been delivered to the clinic. Receive the patient to begin treatment.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isUpdating ? null : () => _receivePatient(data),
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('Receive Patient', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // In Treatment: show admit or treat & discharge options
                  if (status == 'inTreatment') ...[
                    const Divider(),
                    const SizedBox(height: 12),
                    Text('Patient In Treatment', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text('Admit the patient for inpatient care, or add treatment notes and discharge.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    // Admit Patient button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isUpdating ? null : () => _admitPatient(data),
                        icon: const Icon(Icons.local_hotel_rounded),
                        label: const Text('Admit Patient', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Treatment notes + Discharge
                    _DetailCard(title: 'Treatment Notes & Discharge', children: [
                      TextField(
                        controller: _treatmentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Enter diagnosis, treatment given, medications...',
                          hintStyle: TextStyle(color: AppColors.textSecondary.withAlpha(150)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.green, width: 1.5),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isUpdating ? null : () => _dischargePatient(data),
                          icon: const Icon(Icons.exit_to_app_rounded),
                          label: const Text('Treat & Discharge', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                  ],

                  // Admitted: show treatment notes + discharge
                  if (status == 'admitted') ...[
                    const Divider(),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withAlpha(10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.deepOrange.withAlpha(40)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_hotel_rounded, color: Colors.deepOrange, size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Patient Admitted', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.deepOrange)),
                                Text('Add treatment notes and discharge when ready.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DetailCard(title: 'Treatment Notes & Discharge', children: [
                      TextField(
                        controller: _treatmentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Enter diagnosis, treatment given, medications...',
                          hintStyle: TextStyle(color: AppColors.textSecondary.withAlpha(150)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.green, width: 1.5),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isUpdating ? null : () => _dischargePatient(data),
                          icon: const Icon(Icons.exit_to_app_rounded),
                          label: const Text('Discharge Patient', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
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

  Widget _buildProgressTimeline(String currentStatus, String clinicianDecision) {
    // Determine which workflow path to show
    final isAdvicePath = clinicianDecision == 'advise_vht' || currentStatus == 'advised';

    final List<String> statuses;
    if (isAdvicePath) {
      statuses = ['pending', 'advised', 'completed'];
    } else {
      statuses = ['pending', 'ambulanceRequested', 'dispatched', 'enRoute', 'arrived', 'inTransit', 'delivered', 'inTreatment', 'admitted', 'completed'];
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
            isAdvicePath ? 'Advice Progress' : 'Ambulance Progress',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
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
                        color: isCompleted ? (isCurrent ? _getStatusColor(s) : Colors.green) : AppColors.border,
                        border: isCurrent ? Border.all(color: _getStatusColor(s).withAlpha(80), width: 2) : null,
                      ),
                      child: isCompleted
                          ? Icon(isCurrent ? _getStatusIcon(s) : Icons.check, size: 12, color: Colors.white)
                          : null,
                    ),
                    if (index < statuses.length - 1)
                      Container(width: 2, height: 18, color: isCompleted && index < currentIndex ? Colors.green : AppColors.border),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      _getStatusLabel(s),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                        color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary.withAlpha(100),
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

class _DetailCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.clinicAccent)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
