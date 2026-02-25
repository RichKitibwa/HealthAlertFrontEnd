import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../l10n/app_localizations.dart';
import 'ambulance_en_route_screen.dart';
import 'ambulance_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../common/presentation/widgets/app_drawer.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/current_user_session.dart';

class AmbulanceIncomingDispatchScreen extends StatefulWidget {
  final String caseId;

  const AmbulanceIncomingDispatchScreen({
    Key? key,
    required this.caseId,
  }) : super(key: key);

  @override
  State<AmbulanceIncomingDispatchScreen> createState() => _AmbulanceIncomingDispatchScreenState();
}

class _AmbulanceIncomingDispatchScreenState extends State<AmbulanceIncomingDispatchScreen> {
  bool _isAccepting = false;

  Future<void> _callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.couldNotOpenDialer(phone)), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _acceptDispatch(Map<String, dynamic> caseData) async {
    setState(() => _isAccepting = true);

    try {
      final driverName = '${CurrentUserSession.firstName ?? ''} ${CurrentUserSession.lastName ?? ''}'.trim();

      await FirebaseFirestore.instance.collection('emergencyCases').doc(widget.caseId).update({
        'status': 'enRoute',
        'updatedBy': CurrentUserSession.uid,
        'assignedAmbulanceId': CurrentUserSession.uid,
        'assignedDriverName': driverName,
        'acceptedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Note: Cloud Function handles notifications for enRoute status (VHT and clinician)

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AmbulanceEnRouteScreen(caseId: widget.caseId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorAcceptingDispatch), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'Ambulance',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        pageTitle: l10n.dispatchRequest,
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
        currentIndex: 0,
        onItemSelected: (index) {},
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('emergencyCases').doc(widget.caseId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text(l10n.caseNotFound));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final emergencyType = data['emergencyType'] as String? ?? 'Unknown';
            final urgency = data['urgencyLevel'] as String? ?? 'medium';
            final patientFirstName = data['patientFirstName'] as String? ?? '';
            final patientLastName = data['patientLastName'] as String? ?? '';
            final patientAge = data['patientAge'] as int?;
            final patientGender = data['patientGender'] as String? ?? '';
            final vhtName = data['vhtName'] as String? ?? '';
            final vhtPhone = data['vhtPhoneNumber'] as String? ?? '';
            final clinicName = data['assignedClinicName'] as String? ?? '';
            final clinicianName = data['assignedClinicianName'] as String? ?? '';
            final clinicianPhone = data['clinicianPhoneNumber'] as String? ?? '';
            final notes = data['notes'] as String? ?? '';
            final patientName = '$patientFirstName $patientLastName'.trim();

            String patientDesc = '';
            if (patientGender.isNotEmpty) patientDesc = patientGender[0].toUpperCase() + patientGender.substring(1);
            if (patientAge != null) patientDesc += patientDesc.isNotEmpty ? ', $patientAge yrs' : '$patientAge yrs';

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.emergencyDispatch,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 20, color: AppColors.ambulanceAccent),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border),
                          color: AppColors.surface,
                          boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 24, offset: const Offset(0, 14))],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header
                            Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.ambulanceAccent.withAlpha(18),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.ambulanceAccent.withAlpha(30)),
                                  ),
                                  child: Icon(Icons.local_hospital_outlined, color: AppColors.ambulanceAccent),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l10n.incomingDispatch, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w800, fontSize: 14)),
                                      const SizedBox(height: 2),
                                      Text(l10n.reviewDetailsAcceptProceed, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 12, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: _getUrgencyColor(urgency).withAlpha(20),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(urgency.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w800, fontSize: 11, color: _getUrgencyColor(urgency))),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Divider(color: AppColors.border.withAlpha(120)),
                            const SizedBox(height: 14),

                            // Case details — simple rows (no nested cards)
                            _InlineInfoRow(icon: Icons.warning_amber_rounded, label: l10n.emergencyTypeLabel, value: emergencyType),
                            const SizedBox(height: 10),
                            if (patientName.isNotEmpty) ...[
                              _InlineInfoRow(icon: Icons.person_outline, label: l10n.patientLabel, value: '$patientName${patientDesc.isNotEmpty ? ' ($patientDesc)' : ''}'),
                              const SizedBox(height: 10),
                            ],
                            _InlineInfoRow(icon: Icons.place_outlined, label: l10n.destination, value: clinicName.isNotEmpty ? clinicName : l10n.toBeDetermined),
                            const SizedBox(height: 10),
                            if (vhtName.isNotEmpty) ...[
                              _InlineInfoRow(icon: Icons.health_and_safety_outlined, label: l10n.reportingVht, value: vhtName),
                            ],
                            if (notes.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              _InlineInfoRow(icon: Icons.notes_outlined, label: l10n.notesLabel, value: notes),
                            ],
                            const SizedBox(height: 16),

                            // Contact buttons
                            if (vhtPhone.isNotEmpty || clinicianPhone.isNotEmpty) ...[
                              Text(l10n.quickContact, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.ambulanceAccent)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (vhtPhone.isNotEmpty)
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _callPhone(vhtPhone),
                                        icon: Icon(Icons.phone, size: 16, color: Colors.green),
                                        label: Text(l10n.callVht, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          side: BorderSide(color: Colors.green.withAlpha(60)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      ),
                                    ),
                                  if (vhtPhone.isNotEmpty && clinicianPhone.isNotEmpty) const SizedBox(width: 10),
                                  if (clinicianPhone.isNotEmpty)
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _callPhone(clinicianPhone),
                                        icon: Icon(Icons.phone, size: 16, color: Colors.blue),
                                        label: Text(l10n.callClinic, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          side: BorderSide(color: Colors.blue.withAlpha(60)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Accept Dispatch button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isAccepting ? null : () => _acceptDispatch(data),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ambulanceAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 6,
                      ),
                      child: _isAccepting
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                          : Text(l10n.acceptDispatch, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Flat info row — no nested card decoration (avoids card-in-card pattern).
class _InlineInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InlineInfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: AppColors.ambulanceAccent.withAlpha(16),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.ambulanceAccent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary), maxLines: 3, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}
