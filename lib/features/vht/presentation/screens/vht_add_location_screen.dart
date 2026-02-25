import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/location_utils.dart';
import '../../../../core/utils/location_error_localization.dart';
import 'vht_dispatch_confirmation_screen.dart';
import 'vht_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';

class CaptureLocationScreen extends StatefulWidget {
  final String emergencyType;

  const CaptureLocationScreen({Key? key, required this.emergencyType})
    : super(key: key);

  @override
  State<CaptureLocationScreen> createState() => _CaptureLocationScreenState();
}

class _CaptureLocationScreenState extends State<CaptureLocationScreen> {
  double? _latitude;
  double? _longitude;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _captureLocation();
  }

  Future<void> _captureLocation() async {
    setState(() {
      _isCapturing = true;
    });

    final result = await LocationUtils.getCurrentLocationWithDetails();

    if (!mounted) return;

    if (result.permissionDeniedForever) {
      final l10n = AppLocalizations.of(context)!;
      final shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.locationPermissionRequired),
          content: Text(l10n.locationNeedsAccessMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.openSettings),
            ),
          ],
        ),
      );
      if (shouldOpenSettings == true) {
        await openAppSettings();
      }
    }

    if (result.success && result.position != null) {
      setState(() {
        _latitude = result.position!.latitude;
        _longitude = result.position!.longitude;
        _isCapturing = false;
      });
    } else {
      setState(() {
        _isCapturing = false;
      });
      final l10n = AppLocalizations.of(context)!;
      final message = localizedLocationErrorMessage(result, l10n);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'VHT',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        pageTitle: l10n.setLocation,
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
        currentIndex: 0, // this screen is part of the VHT home/report flow
        onItemSelected: (index) {
          // TODO: wire up navigation if desired
          // Example:
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
                          children: [
                            const Icon(
                              Icons.my_location,
                              size: 48,
                              color: Color(0xFF0077CC),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.automaticallyCapturingLocation,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                height: 22 / 18,
                                color: Color(0xFF0077CC),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.locationCaptureHelp,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 18 / 14,
                                color: Color(0xFF667085),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_isCapturing)
                              const CircularProgressIndicator()
                            else if (_latitude != null && _longitude != null)
                              Text(
                                'Latitude: ${_latitude!.toStringAsFixed(6)}\n'
                                'Longitude: ${_longitude!.toStringAsFixed(6)}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Color(0xFF0077CC),
                                ),
                              )
                            else
                              ElevatedButton(
                                onPressed: _captureLocation,
                                child: Text(l10n.retryLocationCapture),
                              ),
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
                      onPressed: _latitude != null && _longitude != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DispatchConfirmationScreen(
                                    emergencyType: widget.emergencyType,
                                    latitude: _latitude!,
                                    longitude: _longitude!,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Text(
                        l10n.continueButton,
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
