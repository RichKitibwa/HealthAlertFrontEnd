import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:geolocator/geolocator.dart';
import 'vht_onboard_patient.dart';
import 'vht_navigation_bar.dart';
import '../../../common/presentation/screens/top_navigation_bar.dart';
import '../../../auth/current_user_session.dart';
import '../../../../core/widgets/camera_widget.dart';
import '../../../../core/widgets/full_screen_media_viewer.dart';
import '../../../../core/widgets/voice_note_widget.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/utils/location_utils.dart';
import '../../../../core/services/clinic_matching_service.dart';
import '../../../../core/services/fcm_notification_service.dart';

class AddMediaScreen extends StatefulWidget {
  final String emergencyType;

  const AddMediaScreen({Key? key, required this.emergencyType})
    : super(key: key);

  @override
  State<AddMediaScreen> createState() => _AddMediaScreenState();
}

class _AddMediaScreenState extends State<AddMediaScreen> {
  File? _capturedImage;
  File? _capturedVideo;
  File? _videoThumbnail;
  File? _audioFile;
  String? _selectedUrgency;
  final TextEditingController _notesController = TextEditingController();
  String? _imageSizeInfo;
  String? _videoSizeInfo;
  
  // Patient details
  String _patientId = '';
  String? _selectedGender;
  DateTime? _dateOfBirth;
  int? _age;
  bool _useAgeInstead = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ClinicMatchingService _clinicMatchingService = ClinicMatchingService();
  final FCMNotificationService _fcmService = FCMNotificationService();
  bool _isNotifying = false;

  @override
  void initState() {
    super.initState();
    _generatePatientId();
  }

  Future<void> _generatePatientId() async {
    try {
      final now = DateTime.now();
      final year = now.year.toString().substring(2); // Get last 2 digits (26 for 2026)
      
      // Get or create the patient counter document
      final counterRef = _firestore.collection('counters').doc('patientCounter');
      
      // Use transaction to atomically increment the counter
      final patientNumber = await _firestore.runTransaction<int>((transaction) async {
        final snapshot = await transaction.get(counterRef);
        
        int currentCount;
        final currentYear = now.year;
        
        if (!snapshot.exists || snapshot.data() == null) {
          // First patient ever, start at 1
          currentCount = 1;
          transaction.set(counterRef, {
            'count': 1,
            'year': currentYear,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          final data = snapshot.data()!;
          final storedYear = data['year'] as int? ?? currentYear;
          
          if (storedYear != currentYear) {
            // New year, reset counter to 1
            currentCount = 1;
            transaction.update(counterRef, {
              'count': 1,
              'year': currentYear,
              'lastUpdated': FieldValue.serverTimestamp(),
            });
          } else {
            // Same year, increment counter
            currentCount = (data['count'] as int? ?? 0) + 1;
            transaction.update(counterRef, {
              'count': currentCount,
              'lastUpdated': FieldValue.serverTimestamp(),
            });
          }
        }
        
        return currentCount;
      });
      
      // Format: P + 3-digit number + 2-digit year (e.g., P00126, P00226)
      // Ensure number doesn't exceed 999 (3 digits max)
      final safeNumber = patientNumber > 999 ? 999 : patientNumber;
      final formattedId = 'P${safeNumber.toString().padLeft(3, '0')}$year';
      
      if (mounted) {
        setState(() {
          _patientId = formattedId;
        });
      }
    } catch (e) {
      // Fallback: Use a simple counter stored locally if Firestore fails
      // This is a temporary fallback - should use Firestore in production
      if (mounted) {
        final now = DateTime.now();
        final year = now.year.toString().substring(2);
        // Simple fallback: use a random 3-digit number (001-999)
        final fallbackNumber = (DateTime.now().millisecondsSinceEpoch % 999) + 1;
        setState(() {
          _patientId = 'P${fallbackNumber.toString().padLeft(3, '0')}$year';
        });
      }
    }
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0077CC),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1A1A1A),
            ),
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
        _age = null;
        _useAgeInstead = false;
      });
    }
  }

  Future<void> _notifyClinic() async {
    setState(() {
      _isNotifying = true;
    });

    try {
      // Get VHT's current location
      final position = await LocationUtils.getCurrentLocation();
      if (position == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to get your location. Please enable location services.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isNotifying = false;
        });
        return;
      }

      // Find nearest matching clinic
      final clinicMatch = await _clinicMatchingService.findNearestMatchingClinic(
        vhtLatitude: position.latitude,
        vhtLongitude: position.longitude,
        emergencyType: widget.emergencyType,
        patientAge: _age,
      );

      if (clinicMatch == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No available clinic found. Please try again later.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          _isNotifying = false;
        });
        return;
      }

      // Create emergency case in Firestore
      final caseRef = _firestore.collection('emergencyCases').doc();
      final caseData = {
        'caseId': caseRef.id,
        'patientId': _patientId,
        'patientGender': _selectedGender,
        'patientAge': _age,
        'patientDateOfBirth': _dateOfBirth?.toIso8601String(),
        'emergencyType': widget.emergencyType,
        'urgencyLevel': _selectedUrgency ?? 'medium',
        'notes': _notesController.text,
        'vhtId': CurrentUserSession.uid,
        'vhtName': '${CurrentUserSession.firstName} ${CurrentUserSession.lastName}',
        'assignedClinicId': clinicMatch['clinicianId'],
        'assignedClinicName': clinicMatch['clinicName'],
        'assignedClinicianName': clinicMatch['clinicianName'],
        'status': 'pending',
        'vhtLatitude': position.latitude,
        'vhtLongitude': position.longitude,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await caseRef.set(caseData);

      // Send FCM notification to clinician
      final notificationSent = await _fcmService.notifyClinicianOfEmergency(
        fcmToken: clinicMatch['fcmToken'],
        emergencyType: widget.emergencyType,
        patientId: _patientId,
        caseId: caseRef.id,
        vhtName: '${CurrentUserSession.firstName} ${CurrentUserSession.lastName}',
        urgencyLevel: _selectedUrgency,
      );

      if (mounted) {
        if (notificationSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Clinic notified: ${clinicMatch['clinicName']}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Case created but notification failed. Clinic will be notified via other means.'),
              backgroundColor: Colors.orange,
            ),
          );
        }

        // Navigate to next screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VhtOnboardPatientScreen(
              emergencyType: widget.emergencyType,
              capturedImage: _capturedImage,
              capturedVideo: _capturedVideo,
              notes: _notesController.text,
              urgencyLevel: _selectedUrgency,
              caseId: caseRef.id,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error notifying clinic: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isNotifying = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onMediaCaptured(File? image, File? video) async {
    setState(() {
      _capturedImage = image;
      _capturedVideo = video;
      _imageSizeInfo = null;
      _videoSizeInfo = null;
      _videoThumbnail = null;
    });

    // Update file size info
    if (image != null) {
      final fileSize = await FileUtils.getFileSize(image);
      final fileSizeKB = fileSize / 1024;
      setState(() {
        _imageSizeInfo = 'Image: ${fileSizeKB.toStringAsFixed(1)}KB';
      });
    }

    if (video != null) {
      final fileSize = await FileUtils.getFileSize(video);
      final fileSizeMB = fileSize / (1024 * 1024);
      setState(() {
        _videoSizeInfo = 'Video: ${fileSizeMB.toStringAsFixed(2)}MB';
      });
      
      // Generate thumbnail
      _generateVideoThumbnail(video);
    }
  }

  Future<void> _generateVideoThumbnail(File videoFile) async {
    try {
      if (!videoFile.existsSync()) return;
      
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        thumbnailPath: videoFile.parent.path,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
        timeMs: 1000,
      );

      if (thumbnailPath != null && mounted) {
        final thumbFile = File(thumbnailPath);
        if (thumbFile.existsSync()) {
          setState(() {
            _videoThumbnail = thumbFile;
          });
        }
      }
    } catch (e) {
      // Ignore thumbnail generation errors, will show icon instead
      if (mounted) {
        setState(() {
          _videoThumbnail = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'VHT',
        profileImageUrl: CurrentUserSession.profileImageUrl,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Patient Details Section (First)
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Patient Details',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            height: 19 / 16,
                            color: Color(0xFF0077CC),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Patient ID (Auto-generated, display only)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F9FC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE3E8EF)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.badge_outlined,
                                color: Color(0xFF0077CC),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Patient ID',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: Color(0xFF667085),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _patientId,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Gender Dropdown
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Gender',
                            prefixIcon: const Icon(Icons.person_outline),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE3E8EF),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF0077CC),
                                width: 2,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE3E8EF),
                                width: 1,
                              ),
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xFF1A1A1A),
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF667085),
                          ),
                          iconSize: 24,
                          borderRadius: BorderRadius.circular(12),
                          dropdownColor: Colors.white,
                          elevation: 8,
                          items: const [
                            DropdownMenuItem(
                              value: 'male',
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Text('Male'),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'female',
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Text('Female'),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          value: _selectedGender,
                        ),
                        const SizedBox(height: 16),
                        // DOB or Age Toggle
                        Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                icon: Icon(
                                  _useAgeInstead ? Icons.radio_button_unchecked : Icons.radio_button_checked,
                                  size: 18,
                                ),
                                label: const Text('Date of Birth'),
                                onPressed: () {
                                  setState(() {
                                    _useAgeInstead = false;
                                    _age = null;
                                  });
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: _useAgeInstead ? const Color(0xFF667085) : const Color(0xFF0077CC),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextButton.icon(
                                icon: Icon(
                                  _useAgeInstead ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                  size: 18,
                                ),
                                label: const Text('Age'),
                                onPressed: () {
                                  setState(() {
                                    _useAgeInstead = true;
                                    _dateOfBirth = null;
                                  });
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: _useAgeInstead ? const Color(0xFF0077CC) : const Color(0xFF667085),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // DOB or Age Input
                        if (!_useAgeInstead)
                          GestureDetector(
                            onTap: () => _selectDateOfBirth(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE3E8EF)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    color: Color(0xFF667085),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _dateOfBirth != null
                                              ? 'Date of Birth: ${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                                              : 'Select Date of Birth',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            color: _dateOfBirth != null
                                                ? const Color(0xFF1A1A1A)
                                                : const Color(0xFF98A2B3),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Color(0xFF667085),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Age',
                              prefixIcon: const Icon(Icons.cake_outlined),
                              hintText: 'Enter age in years',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE3E8EF),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0077CC),
                                  width: 2,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE3E8EF),
                                  width: 1,
                                ),
                              ),
                            ),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xFF1A1A1A),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _age = value.isNotEmpty ? int.tryParse(value) : null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Notes Section (Second)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Notes',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 19 / 16,
                          color: Color(0xFF0077CC),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Type any important notes…',
                          hintStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            height: 18 / 14,
                            color: Color(0xFF98A2B3),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE3E8EF),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF0077CC),
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'These details will help clinic and ambulance staff prepare.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          height: 16 / 12,
                          color: Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Photo/Video Section (Third)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Photo / Video (optional)',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 19 / 16,
                          color: Color(0xFF0077CC),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _capturedImage != null || _capturedVideo != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 225,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE3E8EF),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context, rootNavigator: true).push(
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) => FullScreenMediaViewer(
                                              imageFile: _capturedImage,
                                              videoFile: _capturedVideo,
                                            ),
                                            fullscreenDialog: true,
                                            opaque: true,
                                            barrierColor: Colors.black,
                                            transitionDuration: const Duration(milliseconds: 300),
                                            reverseTransitionDuration: const Duration(milliseconds: 300),
                                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                              return FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          _capturedImage != null
                                              ? Image.file(
                                                  _capturedImage!,
                                                  fit: BoxFit.cover,
                                                )
                                              : _capturedVideo != null
                                                  ? _videoThumbnail != null && _videoThumbnail!.existsSync()
                                                      ? Image.file(
                                                          _videoThumbnail!,
                                                          fit: BoxFit.cover,
                                                          width: double.infinity,
                                                          height: double.infinity,
                                                        )
                                                      : Container(
                                                          color: Colors.black87,
                                                          width: double.infinity,
                                                          height: double.infinity,
                                                          child: const Center(
                                                            child: Icon(
                                                              Icons.videocam,
                                                              size: 64,
                                                              color: Color(0xFF0077CC),
                                                            ),
                                                          ),
                                                        )
                                                  : const SizedBox(),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  if (_capturedImage != null) {
                                                    _capturedImage = null;
                                                    _imageSizeInfo = null;
                                                  }
                                                  if (_capturedVideo != null) {
                                                    _capturedVideo = null;
                                                    _videoSizeInfo = null;
                                                    _videoThumbnail = null;
                                                  }
                                                });
                                                _onMediaCaptured(null, null);
                                              },
                                              style: IconButton.styleFrom(
                                                backgroundColor: Colors.black54,
                                              ),
                                            ),
                                          ),
                                          if (_capturedVideo != null)
                                            const Center(
                                              child: Icon(
                                                Icons.play_circle_filled,
                                                color: Colors.white,
                                                size: 64,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (_imageSizeInfo != null || _videoSizeInfo != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      _imageSizeInfo ?? _videoSizeInfo ?? '',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: Color(0xFF667085),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : CameraWidget(
                              onMediaCaptured: _onMediaCaptured,
                              allowVideo: true,
                              maxWidth: double.infinity,
                              maxHeight: 225,
                            ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Voice Note Section (Fourth)
                  VoiceNoteWidget(
                    onAudioRecorded: (audioFile) {
                      setState(() {
                        _audioFile = audioFile;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  // Triage Level Section (Fifth)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Triage level',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 19 / 16,
                          color: Color(0xFF0077CC),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'Select triage level',
                          hintStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            height: 18 / 14,
                            color: Color(0xFF98A2B3),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE3E8EF),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF0077CC),
                              width: 2,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE3E8EF),
                              width: 1,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xFF1A1A1A),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF667085),
                        ),
                        iconSize: 24,
                        borderRadius: BorderRadius.circular(12),
                        dropdownColor: Colors.white,
                        elevation: 8,
                        items: const [
                          DropdownMenuItem(
                            value: 'critical',
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text('Critical'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'high',
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text('High'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'medium',
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text('Moderate'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'low',
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text('Low'),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedUrgency = value;
                          });
                        },
                        value: _selectedUrgency,
                      ),
                    ],
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
                      onPressed: _isNotifying ? null : () async {
                        await _notifyClinic();
                      },
                      child: _isNotifying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Next → Notify Clinic',
                              style: TextStyle(
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
