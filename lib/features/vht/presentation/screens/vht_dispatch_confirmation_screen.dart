import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'vht_track_ambulance_screen.dart';
import 'vht_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';
import '../../../../data/repositories/emergency_case_repository.dart';
import '../../../../data/models/emergency_case_model.dart';
import '../../../../core/enums/case_type.dart';
import '../../../../core/enums/urgency_level.dart';

class DispatchConfirmationScreen extends StatefulWidget {
  final String emergencyType;
  final double? latitude;
  final double? longitude;
  final File? capturedImage;
  final File? capturedVideo;
  final String? notes;
  final String? urgencyLevel;

  const DispatchConfirmationScreen({
    Key? key,
    required this.emergencyType,
    this.latitude,
    this.longitude,
    this.capturedImage,
    this.capturedVideo,
    this.notes,
    this.urgencyLevel,
  }) : super(key: key);

  @override
  State<DispatchConfirmationScreen> createState() => _DispatchConfirmationScreenState();
}

class _DispatchConfirmationScreenState extends State<DispatchConfirmationScreen> {
  final EmergencyCaseRepository _caseRepository = EmergencyCaseRepository();
  bool _isSubmitting = false;

  Future<void> _submitEmergencyCase() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create emergency case model
      final caseModel = EmergencyCaseModel(
        caseType: CaseTypeExtension.fromString(widget.emergencyType),
        urgencyLevel: widget.urgencyLevel != null
            ? UrgencyLevelExtension.fromString(widget.urgencyLevel!)
            : UrgencyLevel.medium,
        latitude: widget.latitude,
        longitude: widget.longitude,
        notes: widget.notes,
        description: widget.notes,
      );

      // Create case in repository (handles offline/online)
      final createdCase = await _caseRepository.createCase(caseModel);

      // Upload attachments if available
      if (widget.capturedImage != null) {
        await _caseRepository.uploadAttachment(
          createdCase.id ?? createdCase.offlineId ?? '',
          widget.capturedImage!,
          'image',
        );
      }

      if (widget.capturedVideo != null) {
        await _caseRepository.uploadAttachment(
          createdCase.id ?? createdCase.offlineId ?? '',
          widget.capturedVideo!,
          'video',
        );
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(createdCase.isOffline
                ? l10n.caseSavedOfflineSyncWhenOnline
                : l10n.emergencyCaseCreatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TrackAmbulanceScreen(
              emergencyType: widget.emergencyType,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorCreatingEmergencyCaseWithError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Placeholder values for now
    const String clinicName = 'Central Health'; // TODO: fill dynamically
    const String etaText = '12 min'; // TODO: compute ETA

    return Scaffold(
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'VHT',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        pageTitle: l10n.dispatchConfirmation,
        showBackButton: true,
        onBack: () {
          Navigator.pop(context);
        },
        onSignOut: () {
          CurrentUserSession.clear();
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
      ),
      // Matches other screens
      backgroundColor: const Color(0xFFFBFCFD),
      bottomNavigationBar: VhtNavigationBar(
        currentIndex: 0, // part of VHT home/report flow
        onItemSelected: (index) {
          // TODO: wire up navigation if desired
          // if (index == 0) Navigator.pushNamed(context, '/vht-dashboard');
          // if (index == 1) Navigator.pushNamed(context, '/vht-map');
          // if (index == 2) Navigator.pushNamed(context, '/vht-patients');
        },
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.dispatchConfirmation,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      height: 24 / 20,
                      color: Color(0xFF0077CC),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Main white card that scales with height
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE3E8EF)),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.clinicAssignedWithName(clinicName),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                height: 19 / 16,
                                color: Color(0xFF0077CC),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.estimatedArrivalValue(etaText),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                height: 19 / 16,
                                color: Color(0xFF0077CC),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Divider(
                              thickness: 1,
                              color: Color(0xFFE3E8EF),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.assigningNearestAmbulance,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                height: 19 / 16,
                                color: Color(0xFF0077CC),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.systemWillChooseClosestAmbulance,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 18 / 14,
                                color: Color(0xFF667085),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${l10n.emergencyTypeLabel}: ${widget.emergencyType}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 17 / 14,
                                color: Color(0xFF667085),
                              ),
                            ),
                            if (widget.latitude != null && widget.longitude != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  l10n.locationCoordinates(widget.latitude!.toStringAsFixed(6), widget.longitude!.toStringAsFixed(6)),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Color(0xFF667085),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            // TODO: Integrate backend logic to:
                            // 1) Find the nearest available ambulance
                            // 2) Assign it to this case
                            // 3) Stream live updates (status/ETA) to this screen
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0077CC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _submitEmergencyCase,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              l10n.confirmAndDispatch,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                          height: 24 / 20,
                          color: Colors.white,
                        ),
                      ),
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
