// Emergency case data model
// Represents an emergency case with all details

import '../../core/enums/case_status.dart';
import '../../core/enums/case_type.dart';
import '../../core/enums/urgency_level.dart';

class EmergencyCaseModel {
  final String? id;
  final CaseType caseType;
  final UrgencyLevel urgencyLevel;
  final CaseStatus status;
  final String? patientId;
  final String? patientName;
  final int? patientAge;
  final String? patientGender;
  final String? patientDateOfBirth;
  final String? emergencyType; 
  final String? description;
  final String? symptoms;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? vhtId;
  final String? vhtName;
  final String? vhtPhoneNumber;
  final String? assignedAmbulanceId;
  final String? assignedClinicId;
  final String? assignedClinicName;
  final String? assignedClinicianName;
  final String? clinicianPhoneNumber;
  final String? clinicianNotes;
  final List<String>? attachmentUrls;
  final List<String>? localAttachmentPaths;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final bool isOffline;
  final String? offlineId; // Local ID for offline cases
  final bool isSynced; // Whether this case has been synced to Firestore

  EmergencyCaseModel({
    this.id,
    required this.caseType,
    required this.urgencyLevel,
    this.status = CaseStatus.pending,
    this.patientId,
    this.patientName,
    this.patientAge,
    this.patientGender,
    this.patientDateOfBirth,
    this.emergencyType,
    this.description,
    this.symptoms,
    this.latitude,
    this.longitude,
    this.address,
    this.vhtId,
    this.vhtName,
    this.vhtPhoneNumber,
    this.assignedAmbulanceId,
    this.assignedClinicId,
    this.assignedClinicName,
    this.assignedClinicianName,
    this.clinicianPhoneNumber,
    this.clinicianNotes,
    this.attachmentUrls,
    this.localAttachmentPaths,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
    this.completedAt,
    this.isOffline = false,
    this.offlineId,
    this.isSynced = false,
  }) : createdAt = createdAt ?? DateTime.now();

  // Factory constructor from JSON (from backend)
  factory EmergencyCaseModel.fromJson(Map<String, dynamic> json) {
    return EmergencyCaseModel(
      id: json['id'] as String?,
      caseType: CaseTypeExtension.fromString(json['caseType'] as String? ?? 'other'),
      urgencyLevel: UrgencyLevelExtension.fromString(json['urgencyLevel'] as String? ?? 'medium'),
      status: CaseStatusExtension.fromString(json['status'] as String? ?? 'pending'),
      patientId: json['patientId'] as String?,
      patientName: json['patientName'] as String?,
      patientAge: json['patientAge'] as int?,
      patientGender: json['patientGender'] as String?,
      patientDateOfBirth: json['patientDateOfBirth'] as String?,
      emergencyType: json['emergencyType'] as String?,
      description: json['description'] as String?,
      symptoms: json['symptoms'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      vhtId: json['vhtId'] as String?,
      vhtName: json['vhtName'] as String?,
      vhtPhoneNumber: json['vhtPhoneNumber'] as String?,
      assignedAmbulanceId: json['assignedAmbulanceId'] as String?,
      assignedClinicId: json['assignedClinicId'] as String?,
      assignedClinicName: json['assignedClinicName'] as String?,
      assignedClinicianName: json['assignedClinicianName'] as String?,
      clinicianPhoneNumber: json['clinicianPhoneNumber'] as String?,
      clinicianNotes: json['clinicianNotes'] as String?,
      attachmentUrls: json['attachmentUrls'] != null
          ? List<String>.from(json['attachmentUrls'] as List)
          : null,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      isOffline: json['isOffline'] as bool? ?? false,
      isSynced: json['isSynced'] as bool? ?? true,
    );
  }

  // Factory constructor from Map (for local database)
  factory EmergencyCaseModel.fromMap(Map<String, dynamic> map) {
    return EmergencyCaseModel(
      id: map['id'] as String?,
      offlineId: map['offlineId'] as String?,
      caseType: CaseTypeExtension.fromString(map['caseType'] as String? ?? 'other'),
      urgencyLevel: UrgencyLevelExtension.fromString(map['urgencyLevel'] as String? ?? 'medium'),
      status: CaseStatusExtension.fromString(map['status'] as String? ?? 'pending'),
      patientId: map['patientId'] as String?,
      patientName: map['patientName'] as String?,
      patientAge: map['patientAge'] as int?,
      patientGender: map['patientGender'] as String?,
      patientDateOfBirth: map['patientDateOfBirth'] as String?,
      emergencyType: map['emergencyType'] as String?,
      description: map['description'] as String?,
      symptoms: map['symptoms'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      address: map['address'] as String?,
      vhtId: map['vhtId'] as String?,
      vhtName: map['vhtName'] as String?,
      vhtPhoneNumber: map['vhtPhoneNumber'] as String?,
      assignedAmbulanceId: map['assignedAmbulanceId'] as String?,
      assignedClinicId: map['assignedClinicId'] as String?,
      assignedClinicName: map['assignedClinicName'] as String?,
      assignedClinicianName: map['assignedClinicianName'] as String?,
      clinicianPhoneNumber: map['clinicianPhoneNumber'] as String?,
      clinicianNotes: map['clinicianNotes'] as String?,
      attachmentUrls: map['attachmentUrls'] != null
          ? List<String>.from(map['attachmentUrls'] as List)
          : null,
      localAttachmentPaths: map['localAttachmentPaths'] != null
          ? List<String>.from(map['localAttachmentPaths'] as List)
          : null,
      notes: map['notes'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      isOffline: map['isOffline'] as bool? ?? false,
      isSynced: map['isSynced'] as bool? ?? false,
    );
  }

  // Convert to JSON (for backend)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'caseType': caseType.value,
      'urgencyLevel': urgencyLevel.value,
      'status': status.value,
      if (patientId != null) 'patientId': patientId,
      if (patientName != null) 'patientName': patientName,
      if (patientAge != null) 'patientAge': patientAge,
      if (patientGender != null) 'patientGender': patientGender,
      if (patientDateOfBirth != null) 'patientDateOfBirth': patientDateOfBirth,
      if (emergencyType != null) 'emergencyType': emergencyType,
      if (description != null) 'description': description,
      if (symptoms != null) 'symptoms': symptoms,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (address != null) 'address': address,
      if (vhtId != null) 'vhtId': vhtId,
      if (vhtName != null) 'vhtName': vhtName,
      if (vhtPhoneNumber != null) 'vhtPhoneNumber': vhtPhoneNumber,
      if (assignedAmbulanceId != null) 'assignedAmbulanceId': assignedAmbulanceId,
      if (assignedClinicId != null) 'assignedClinicId': assignedClinicId,
      if (assignedClinicName != null) 'assignedClinicName': assignedClinicName,
      if (assignedClinicianName != null) 'assignedClinicianName': assignedClinicianName,
      if (clinicianPhoneNumber != null) 'clinicianPhoneNumber': clinicianPhoneNumber,
      if (clinicianNotes != null) 'clinicianNotes': clinicianNotes,
      if (attachmentUrls != null) 'attachmentUrls': attachmentUrls,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
    };
  }

  // Convert to Map (for local database)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (offlineId != null) 'offlineId': offlineId,
      'caseType': caseType.value,
      'urgencyLevel': urgencyLevel.value,
      'status': status.value,
      if (patientId != null) 'patientId': patientId,
      if (patientName != null) 'patientName': patientName,
      if (patientAge != null) 'patientAge': patientAge,
      if (patientGender != null) 'patientGender': patientGender,
      if (patientDateOfBirth != null) 'patientDateOfBirth': patientDateOfBirth,
      if (emergencyType != null) 'emergencyType': emergencyType,
      if (description != null) 'description': description,
      if (symptoms != null) 'symptoms': symptoms,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (address != null) 'address': address,
      if (vhtId != null) 'vhtId': vhtId,
      if (vhtName != null) 'vhtName': vhtName,
      if (vhtPhoneNumber != null) 'vhtPhoneNumber': vhtPhoneNumber,
      if (assignedAmbulanceId != null) 'assignedAmbulanceId': assignedAmbulanceId,
      if (assignedClinicId != null) 'assignedClinicId': assignedClinicId,
      if (assignedClinicName != null) 'assignedClinicName': assignedClinicName,
      if (assignedClinicianName != null) 'assignedClinicianName': assignedClinicianName,
      if (clinicianPhoneNumber != null) 'clinicianPhoneNumber': clinicianPhoneNumber,
      if (clinicianNotes != null) 'clinicianNotes': clinicianNotes,
      if (attachmentUrls != null) 'attachmentUrls': attachmentUrls,
      if (localAttachmentPaths != null) 'localAttachmentPaths': localAttachmentPaths,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      'isOffline': isOffline,
      'isSynced': isSynced,
    };
  }

  // Copy with method
  EmergencyCaseModel copyWith({
    String? id,
    CaseType? caseType,
    UrgencyLevel? urgencyLevel,
    CaseStatus? status,
    String? patientId,
    String? patientName,
    int? patientAge,
    String? patientGender,
    String? patientDateOfBirth,
    String? emergencyType,
    String? description,
    String? symptoms,
    double? latitude,
    double? longitude,
    String? address,
    String? vhtId,
    String? vhtName,
    String? vhtPhoneNumber,
    String? assignedAmbulanceId,
    String? assignedClinicId,
    String? assignedClinicName,
    String? assignedClinicianName,
    String? clinicianPhoneNumber,
    String? clinicianNotes,
    List<String>? attachmentUrls,
    List<String>? localAttachmentPaths,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool? isOffline,
    String? offlineId,
    bool? isSynced,
  }) {
    return EmergencyCaseModel(
      id: id ?? this.id,
      caseType: caseType ?? this.caseType,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      status: status ?? this.status,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientAge: patientAge ?? this.patientAge,
      patientGender: patientGender ?? this.patientGender,
      patientDateOfBirth: patientDateOfBirth ?? this.patientDateOfBirth,
      emergencyType: emergencyType ?? this.emergencyType,
      description: description ?? this.description,
      symptoms: symptoms ?? this.symptoms,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      vhtId: vhtId ?? this.vhtId,
      vhtName: vhtName ?? this.vhtName,
      vhtPhoneNumber: vhtPhoneNumber ?? this.vhtPhoneNumber,
      assignedAmbulanceId: assignedAmbulanceId ?? this.assignedAmbulanceId,
      assignedClinicId: assignedClinicId ?? this.assignedClinicId,
      assignedClinicName: assignedClinicName ?? this.assignedClinicName,
      assignedClinicianName: assignedClinicianName ?? this.assignedClinicianName,
      clinicianPhoneNumber: clinicianPhoneNumber ?? this.clinicianPhoneNumber,
      clinicianNotes: clinicianNotes ?? this.clinicianNotes,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      localAttachmentPaths: localAttachmentPaths ?? this.localAttachmentPaths,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      isOffline: isOffline ?? this.isOffline,
      offlineId: offlineId ?? this.offlineId,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  // Status Helpers
  bool get isPending => status == CaseStatus.pending;
  bool get isDispatched => status == CaseStatus.dispatched;
  bool get isCompleted => status == CaseStatus.completed;
  bool get canBeEdited => status == CaseStatus.pending || status == CaseStatus.dispatched;

  // Urgency Helpers
  bool get isCritical => urgencyLevel == UrgencyLevel.critical;
}
