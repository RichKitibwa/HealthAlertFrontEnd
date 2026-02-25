import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'vht_case_submitted_screen.dart';
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
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../data/models/emergency_case_model.dart';
import '../../../../core/enums/case_type.dart';
import '../../../../core/enums/urgency_level.dart';
import '../../../common/presentation/widgets/app_drawer.dart';
import '../../../../core/utils/logout_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/health_facility_constants.dart';
import '../../../../l10n/app_localizations.dart';

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
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String? _selectedGender;
  DateTime? _dateOfBirth;
  int? _age;
  bool _useAgeInstead = false;

  // Facility selection (VHT chooses which clinic to send the case to)
  String? _selectedFacility;

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
    final now = DateTime.now();
    final year = now.year.toString().substring(2); 

    try {
      // Check connectivity first
      final isOnline = await ConnectivityService().checkConnectivity();

      if (isOnline) {
        final counterRef = _firestore.collection('counters').doc('patientCounter');

        final patientNumber = await _firestore.runTransaction<int>((transaction) async {
          final snapshot = await transaction.get(counterRef);

          int currentCount;
          final currentYear = now.year;

          if (!snapshot.exists || snapshot.data() == null) {
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
              currentCount = 1;
              transaction.update(counterRef, {
                'count': 1,
                'year': currentYear,
                'lastUpdated': FieldValue.serverTimestamp(),
              });
            } else {
              currentCount = (data['count'] as int? ?? 0) + 1;
              transaction.update(counterRef, {
                'count': currentCount,
                'lastUpdated': FieldValue.serverTimestamp(),
              });
            }
          }

          return currentCount;
        });

        final safeNumber = patientNumber > 999 ? 999 : patientNumber;
        final formattedId = 'P${safeNumber.toString().padLeft(3, '0')}$year';

        if (mounted) {
          setState(() {
            _patientId = formattedId;
          });
        }
      } else {
        // Offline: generate a local ID using timestamp
        _generateOfflinePatientId(year);
      }
    } catch (e) {
      // Fallback: Use offline ID generation if Firestore fails
      _generateOfflinePatientId(year);
    }
  }

  void _generateOfflinePatientId(String year) {
    if (mounted) {
      final fallbackNumber = (DateTime.now().millisecondsSinceEpoch % 999) + 1;
      setState(() {
        _patientId = 'P${fallbackNumber.toString().padLeft(3, '0')}$year';
      });
    }
  }

  int _calculateAgeFromDob(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
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
            colorScheme: ColorScheme.light(
              primary: AppColors.vhtAccent,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
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
        _age = _calculateAgeFromDob(picked);
        _useAgeInstead = false;
      });
    }
  }

  /// Validates required fields before submission
  bool _validateForm() {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectPatientGender),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }
    if (_dateOfBirth == null && _age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterDobOrAge),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }
    if (_selectedUrgency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectTriageLevel),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }
    if (_selectedFacility == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectHealthFacilityToNotify),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }
    return true;
  }

  /// Request location permission 
  Future<LocationResult> _getLocationWithPermission() async {
    final result = await LocationUtils.getCurrentLocationWithDetails();

    if (!result.success && result.permissionDeniedForever && mounted) {
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vhtAccent,
              ),
              child: Text(l10n.openSettings, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (shouldOpenSettings == true) {
        await openAppSettings();
      }
    }

    return result;
  }

  /// Upload a file to Firebase Storage and return the download URL.
  /// Returns null if the file is null or upload fails.
  Future<String?> _uploadMediaFile(File? file, String caseId, String folder) async {
    if (file == null) return null;
    try {
      // Verify file exists and is readable
      if (!await file.exists()) {
        debugPrint('Upload $folder: File does not exist at ${file.path}');
        return null;
      }
      final fileSize = await file.length();
      debugPrint('Upload $folder: Starting upload (${(fileSize / 1024).toStringAsFixed(1)} KB)');

      final ext = file.path.split('.').last;
      final fileName = '${caseId}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final ref = FirebaseStorage.instance
          .ref()
          .child('emergencyCases/$caseId/$folder/$fileName');
      final uploadTask = ref.putFile(file);

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        debugPrint('Upload $folder: ${(progress * 100).toStringAsFixed(0)}%');
      });

      await uploadTask;
      final url = await ref.getDownloadURL();
      debugPrint('Upload $folder: SUCCESS - $url');
      return url;
    } catch (e, stack) {
      debugPrint('Upload $folder FAILED: $e');
      debugPrint('Stack: $stack');
      return null;
    }
  }

  /// Build the case data map for both local storage and Firestore.
  Map<String, dynamic> _buildCaseData({
    required String caseId,
    required String vhtName,
    double? latitude,
    double? longitude,
    String? selectedFacilityName,
    Map<String, dynamic>? clinicMatch,
    String? imageUrl,
    String? videoUrl,
    String? voiceNoteUrl,
  }) {
    return <String, dynamic>{
      'caseId': caseId,
      'patientId': _patientId,
      'patientFirstName': _firstNameController.text.trim(),
      'patientLastName': _lastNameController.text.trim(),
      'patientGender': _selectedGender,
      'patientAge': _age,
      'patientDateOfBirth': _dateOfBirth?.toIso8601String(),
      'emergencyType': widget.emergencyType,
      'urgencyLevel': _selectedUrgency ?? 'medium',
      'notes': _notesController.text.trim(),
      'vhtId': CurrentUserSession.uid,
      'vhtName': vhtName,
      'vhtPhoneNumber': CurrentUserSession.phoneNumber,
      // Always record the VHT-selected facility name
      if (selectedFacilityName != null) 'selectedFacilityName': selectedFacilityName,
      // Clinician-specific assignment (online path only)
      if (clinicMatch != null) 'assignedClinicId': clinicMatch['clinicianId'],
      'assignedClinicName': clinicMatch != null
          ? clinicMatch['clinicName']
          : (selectedFacilityName ?? ''),
      if (clinicMatch != null) 'assignedClinicianName': clinicMatch['clinicianName'],
      if (clinicMatch != null) 'clinicianPhoneNumber': clinicMatch['phoneNumber'],
      if (clinicMatch != null && clinicMatch['clinicLatitude'] != null)
        'clinicLatitude': clinicMatch['clinicLatitude'],
      if (clinicMatch != null && clinicMatch['clinicLongitude'] != null)
        'clinicLongitude': clinicMatch['clinicLongitude'],
      'status': 'pending',
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (latitude != null) 'vhtLatitude': latitude,
      if (longitude != null) 'vhtLongitude': longitude,
      'imageUrl': imageUrl ?? '',
      'videoUrl': videoUrl ?? '',
      'voiceNoteUrl': voiceNoteUrl ?? '',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Save the case locally first 
  Future<void> _saveCaseLocally(Map<String, dynamic> caseData, {bool isSynced = false}) async {
    try {
      final localCase = EmergencyCaseModel(
        id: isSynced ? caseData['caseId'] as String? : null,
        offlineId: caseData['caseId'] as String?,
        caseType: CaseTypeExtension.fromString(widget.emergencyType.toLowerCase()),
        urgencyLevel: UrgencyLevelExtension.fromString(_selectedUrgency ?? 'medium'),
        patientId: _patientId,
        patientAge: _age,
        patientGender: _selectedGender,
        patientDateOfBirth: _dateOfBirth?.toIso8601String(),
        emergencyType: widget.emergencyType,
        notes: _notesController.text.trim(),
        latitude: caseData['latitude'] as double?,
        longitude: caseData['longitude'] as double?,
        vhtId: CurrentUserSession.uid,
        vhtName: caseData['vhtName'] as String?,
        vhtPhoneNumber: CurrentUserSession.phoneNumber,
        assignedClinicId: caseData['assignedClinicId'] as String?,
        assignedClinicName: caseData['assignedClinicName'] as String?,
        assignedClinicianName: caseData['assignedClinicianName'] as String?,
        clinicianPhoneNumber: caseData['clinicianPhoneNumber'] as String?,
        isOffline: !isSynced,
        isSynced: isSynced,
      );

      await LocalStorageService.saveEmergencyCaseLocally(localCase);
    } catch (e) {
      debugPrint('Failed to save case locally: $e');
    }
  }

  Future<void> _notifyClinic() async {
    // Validate required fields first
    if (!_validateForm()) return;

    setState(() {
      _isNotifying = true;
    });

    try {
      final locationResult = await _getLocationWithPermission();
      double? latitude;
      double? longitude;

      if (locationResult.success) {
        latitude = locationResult.position!.latitude;
        longitude = locationResult.position!.longitude;
      }
      // If location fails, continue without it. clinician will be matched by expertise

      final vhtName = '${CurrentUserSession.firstName ?? ''} ${CurrentUserSession.lastName ?? ''}'.trim();

      // Check connectivity
      final connectivityService = ConnectivityService();
      final isOnline = await connectivityService.checkConnectivity();

      if (!isOnline) {
        // Save locally with the selected facility name; clinician will be matched on sync
        final offlineCaseId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
        final caseData = _buildCaseData(
          caseId: offlineCaseId,
          vhtName: vhtName,
          latitude: latitude,
          longitude: longitude,
          selectedFacilityName: _selectedFacility,
        );

        await _saveCaseLocally(caseData, isSynced: false);

        // Add to offline queue for later sync
        await LocalStorageService.addToOfflineQueue('createCase', {
          'offlineId': offlineCaseId,
          'caseData': caseData,
        });

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VhtCaseSubmittedScreen(
                caseId: offlineCaseId,
                emergencyType: widget.emergencyType,
                clinicName: _selectedFacility ?? AppLocalizations.of(context)!.pendingOffline,
                clinicianName: '',
                patientId: _patientId,
                urgencyLevel: _selectedUrgency,
                isOffline: true,
              ),
            ),
          );
        }
        return;
      }

      // ONLINE PATH: Find the best available clinician at the VHT-selected facility
      final clinicMatch = await _clinicMatchingService.findBestClinicianAtFacility(
        facilityName: _selectedFacility!,
        emergencyType: widget.emergencyType,
        patientAge: _age,
      );

      if (clinicMatch == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.noStaffAtFacility(_selectedFacility!)),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        setState(() {
          _isNotifying = false;
        });
        return;
      }

      // Create case reference and upload media
      final caseRef = _firestore.collection('emergencyCases').doc();

      // Upload media files in parallel
      String? imageUrl;
      String? videoUrl;
      String? voiceNoteUrl;
      final hasMedia = _capturedImage != null || _capturedVideo != null || _audioFile != null;
      try {
        final uploads = await Future.wait([
          _uploadMediaFile(_capturedImage, caseRef.id, 'images'),
          _uploadMediaFile(_capturedVideo, caseRef.id, 'videos'),
          _uploadMediaFile(_audioFile, caseRef.id, 'voiceNotes'),
        ]);
        imageUrl = uploads[0];
        videoUrl = uploads[1];
        voiceNoteUrl = uploads[2];

        // Warn user if media was captured but upload failed
        if (hasMedia && mounted) {
          final l10n = AppLocalizations.of(context)!;
          final failedUploads = <String>[];
          if (_capturedImage != null && imageUrl == null) failedUploads.add(l10n.pickImage);
          if (_capturedVideo != null && videoUrl == null) failedUploads.add(l10n.pickVideo);
          if (_audioFile != null && voiceNoteUrl == null) failedUploads.add(l10n.voiceNote);
          if (failedUploads.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.warningFailedUploadMedia(failedUploads.join(', '))),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Media upload error: $e');
        if (hasMedia && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.warningMediaUploadFailed),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }

      final caseData = _buildCaseData(
        caseId: caseRef.id,
        vhtName: vhtName,
        latitude: latitude,
        longitude: longitude,
        selectedFacilityName: _selectedFacility,
        clinicMatch: clinicMatch,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
        voiceNoteUrl: voiceNoteUrl,
      );

      // Save locally first (offline-first)
      await _saveCaseLocally(caseData, isSynced: true);

      //  Save to Firestore
      final firestoreData = Map<String, dynamic>.from(caseData);
      firestoreData['createdAt'] = FieldValue.serverTimestamp();
      firestoreData['updatedAt'] = FieldValue.serverTimestamp();
      await caseRef.set(firestoreData);

      // Send notifications: clinician gets popup+in-app, VHT gets in-app only
      try {
        final clinicianId = (clinicMatch ?? {})['clinicianId'] as String? ?? '';
        final clinicName = (clinicMatch ?? {})['clinicName'] as String? ?? 'clinic';
        final patientFirst = _firstNameController.text.trim();
        final patientLast = _lastNameController.text.trim();
        final patientName = '$patientFirst $patientLast'.trim().isNotEmpty
            ? '$patientFirst $patientLast'.trim()
            : 'Unknown Patient';
        final vhtId = CurrentUserSession.uid ?? '';
        if (clinicianId.isNotEmpty && vhtId.isNotEmpty) {
          await _fcmService.notifyOnCaseCreated(
            clinicianId: clinicianId,
            vhtId: vhtId,
            caseId: caseRef.id,
            emergencyType: widget.emergencyType,
            patientName: patientName,
            urgencyLevel: _selectedUrgency ?? 'medium',
            clinicName: clinicName,
            vhtName: vhtName,
          );
        }
      } catch (e) {
        debugPrint('Failed to send case creation notifications: $e');
      }

      if (mounted) {
        // Navigate to case submitted confirmation screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VhtCaseSubmittedScreen(
              caseId: caseRef.id,
              emergencyType: widget.emergencyType,
              clinicName: clinicMatch!['clinicName'] as String? ?? 'Unknown Clinic',
              clinicianName: clinicMatch['clinicianName'] as String? ?? '',
              patientId: _patientId,
              urgencyLevel: _selectedUrgency,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorSubmittingCase}: $e'),
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
    _firstNameController.dispose();
    _lastNameController.dispose();
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: TopNavigationBar(
        role: CurrentUserSession.role ?? 'VHT',
        profileImageUrl: CurrentUserSession.profileImageUrl,
        pageTitle: l10n.reportEmergency,
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
        onDashboard: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/vht-dashboard',
            (route) => false,
          );
        },
        onSettings: () {
        },
        onLearningResources: () {
        },
      ),
      endDrawer: AppDrawer(
        onDashboard: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/vht-dashboard',
            (route) => false,
          );
        },
        onSettings: () {
        },
        onLearningResources: () {
        },
        onLogout: () async {
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
      bottomNavigationBar: VhtNavigationBar(
        currentIndex: 0,
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
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.patientInformation,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            height: 19 / 16,
                            color: AppColors.vhtAccent,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Patient ID (Auto-generated, display only)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.badge_outlined,
                                color: AppColors.vhtAccent,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.patientIdLabel,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _patientId,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Patient First Name
                        TextField(
                          controller: _firstNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: l10n.firstName,
                            prefixIcon: const Icon(Icons.person_outline),
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.vhtAccent, width: 2),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border, width: 1),
                            ),
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 16),
                        // Patient Last Name
                        TextField(
                          controller: _lastNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: l10n.lastName,
                            prefixIcon: const Icon(Icons.person_outline),
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.vhtAccent, width: 2),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border, width: 1),
                            ),
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 16),
                        // Gender Dropdown
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: l10n.gender,
                            prefixIcon: const Icon(Icons.person_outline),
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.vhtAccent,
                                width: 2,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textSecondary,
                          ),
                          iconSize: 24,
                          borderRadius: BorderRadius.circular(12),
                          dropdownColor: Colors.white,
                          elevation: 8,
                          items: [
                            DropdownMenuItem(
                              value: 'male',
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(l10n.male),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'female',
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(l10n.female),
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
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _useAgeInstead = false;
                                    _age = null;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _useAgeInstead
                                            ? Icons.radio_button_unchecked
                                            : Icons.radio_button_checked,
                                        size: 18,
                                        color: _useAgeInstead
                                            ? AppColors.textSecondary
                                            : AppColors.vhtAccent,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        l10n.dateOfBirth,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: _useAgeInstead
                                              ? AppColors.textSecondary
                                              : AppColors.vhtAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _useAgeInstead = true;
                                    _dateOfBirth = null;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _useAgeInstead
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_unchecked,
                                        size: 18,
                                        color: _useAgeInstead
                                            ? AppColors.vhtAccent
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        l10n.age,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: _useAgeInstead
                                              ? AppColors.vhtAccent
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _dateOfBirth != null
                                              ? '${l10n.dateOfBirth}: ${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                                              : l10n.selectDateOfBirth,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: _dateOfBirth != null
                                                ? AppColors.textPrimary
                                                : AppColors.textSecondary
                                                      .withAlpha(
                                                        (0.65 * 255).toInt(),
                                                      ),
                                          ),
                                        ),
                                        if (_dateOfBirth != null && _age != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            '${l10n.age}: ${l10n.ageYears(_age!)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.vhtAccent,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: l10n.age,
                              prefixIcon: const Icon(Icons.cake_outlined),
                              hintText: l10n.enterAgeInYears,
                              filled: true,
                              fillColor: AppColors.surface,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.vhtAccent,
                                  width: 2,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                              ),
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _age = value.isNotEmpty
                                    ? int.tryParse(value)
                                    : null;
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
                      Text(
                        l10n.notesLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 19 / 16,
                          color: AppColors.vhtAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: l10n.typeImportantNotes,
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            height: 18 / 14,
                            color: AppColors.textSecondary.withAlpha(
                              (0.65 * 255).toInt(),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.vhtAccent,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.patientDetailsHelp,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          height: 16 / 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Photo/Video Section (Third)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.photoVideoOptional,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 19 / 16,
                          color: AppColors.vhtAccent,
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
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(
                                          context,
                                          rootNavigator: true,
                                        ).push(
                                          PageRouteBuilder(
                                            pageBuilder:
                                                (
                                                  context,
                                                  animation,
                                                  secondaryAnimation,
                                                ) => FullScreenMediaViewer(
                                                  imageFile: _capturedImage,
                                                  videoFile: _capturedVideo,
                                                ),
                                            fullscreenDialog: true,
                                            opaque: true,
                                            barrierColor: Colors.black,
                                            transitionDuration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            reverseTransitionDuration:
                                                const Duration(
                                                  milliseconds: 300,
                                                ),
                                            transitionsBuilder:
                                                (
                                                  context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child,
                                                ) {
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
                                              ? _videoThumbnail != null &&
                                                        _videoThumbnail!
                                                            .existsSync()
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
                                                            color: AppColors
                                                                .vhtAccent,
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
                                if (_imageSizeInfo != null ||
                                    _videoSizeInfo != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      _imageSizeInfo ?? _videoSizeInfo ?? '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
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
                      Text(
                        l10n.triageLevel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 19 / 16,
                          color: AppColors.vhtAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: l10n.selectTriageLevel,
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            height: 18 / 14,
                            color: AppColors.textSecondary.withAlpha(
                              (0.65 * 255).toInt(),
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.vhtAccent,
                              width: 2,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary,
                        ),
                        iconSize: 24,
                        borderRadius: BorderRadius.circular(12),
                        dropdownColor: Colors.white,
                        elevation: 8,
                        items: [
                          DropdownMenuItem(
                            value: 'critical',
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(l10n.critical),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'high',
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(l10n.high),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'medium',
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(l10n.moderate),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'low',
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(l10n.low),
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

                  // Select Health Facility Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.selectHealthFacility,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 19 / 16,
                          color: AppColors.vhtAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.chooseClinicForPatient,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedFacility,
                        isExpanded: true,
                        decoration: InputDecoration(
                          hintText: l10n.selectFacility,
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary.withAlpha(
                              (0.65 * 255).toInt(),
                            ),
                          ),
                          prefixIcon: const Icon(Icons.local_hospital_outlined),
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.vhtAccent,
                              width: 2,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary,
                        ),
                        iconSize: 24,
                        borderRadius: BorderRadius.circular(12),
                        dropdownColor: Colors.white,
                        elevation: 8,
                        items: [
                          // Imvepi Camp group
                          const DropdownMenuItem<String>(
                            enabled: false,
                            value: '__imvepi_header__',
                            child: Text(
                              'IMVEPI CAMP',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                          ...HealthFacilityConstants.imvepiFacilities.map(
                            (f) => DropdownMenuItem<String>(
                              value: f,
                              child: Text(f),
                            ),
                          ),
                          // Rhino Camp group
                          const DropdownMenuItem<String>(
                            enabled: false,
                            value: '__rhino_header__',
                            child: Text(
                              'RHINO CAMP',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                          ...HealthFacilityConstants.rhinoFacilities.map(
                            (f) => DropdownMenuItem<String>(
                              value: f,
                              child: Text(f),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => _selectedFacility = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vhtAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isNotifying
                          ? null
                          : () async {
                              await _notifyClinic();
                            },
                      child: _isNotifying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              l10n.notifyClinic,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                height: 22 / 18,
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
