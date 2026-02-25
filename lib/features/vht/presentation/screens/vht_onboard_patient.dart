import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'vht_dispatch_confirmation_screen.dart';
import 'vht_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';

/// VHT Onboard Patient Screen
///
/// Screen shown after the Add Media screen. Here, the VHT can:
///  - Review / add notes about the patient
///  - Call the clinic to discuss whether an ambulance is needed
///  - Continue to dispatch if the clinic recommends an ambulance
class VhtOnboardPatientScreen extends StatefulWidget {
  final String emergencyType;
  final File? capturedImage;
  final File? capturedVideo;
  final String? notes;
  final String? urgencyLevel;
  final String? caseId;

  const VhtOnboardPatientScreen({
    Key? key,
    required this.emergencyType,
    this.capturedImage,
    this.capturedVideo,
    this.notes,
    this.urgencyLevel,
    this.caseId,
  }) : super(key: key);

  @override
  State<VhtOnboardPatientScreen> createState() =>
      _VhtOnboardPatientScreenState();
}

class _VhtOnboardPatientScreenState extends State<VhtOnboardPatientScreen> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _callClinic() {
    // TODO: integrate real phone call (e.g. with url_launcher).
    final l10n = AppLocalizations.of(context)!;
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseAddNotesBeforeCallingClinic),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.callingClinicToDiscuss),
      ),
    );
  }

  void _continueToDispatch() {
    // For now, just go straight to the dispatch confirmation screen.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DispatchConfirmationScreen(emergencyType: widget.emergencyType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'VHT',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        pageTitle: l10n.onboardPatient,
        showBackButton: true,
        onBack: () {
          Navigator.pop(context);
        },
        onSignOut: () {
          CurrentUserSession.clear();
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
      ),
      // Figma background: #FBFCFD
      backgroundColor: const Color(0xFFFBFCFD),
      bottomNavigationBar: VhtNavigationBar(
        currentIndex:
            0, // this screen is part of the VHT Home/report emergency flow
        onItemSelected: (index) {
          // TODO: wire up navigation to other VHT tabs if desired
          // Example:
          // if (index == 0) Navigator.pushNamed(context, '/vht-dashboard');
          // if (index == 1) Navigator.pushNamed(context, '/vht-map');
          // if (index == 2) Navigator.pushNamed(context, '/vht-patients');
        },
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomInset),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - bottomInset - 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE3E8EF)),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Call Clinic button
                          Align(
                            alignment: Alignment.center,
                            child: ElevatedButton.icon(
                              onPressed: _callClinic,
                              icon: const Icon(
                                Icons.call_rounded,
                                color: Colors.white,
                              ),
                              label: Text(
                                l10n.callClinicToDiscussCase,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0077CC),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Continue to dispatch
                          Align(
                            alignment: Alignment.center,
                            child: OutlinedButton(
                              onPressed: _continueToDispatch,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF0077CC),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                              ),
                              child: Text(
                                l10n.continueToDispatchAmbulance,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Color(0xFF0077CC),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
