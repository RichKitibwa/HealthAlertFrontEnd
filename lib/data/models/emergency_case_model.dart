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
  final String? patientName;
  final int? patientAge;
  final String? patientGender;
  final String? description;
  final String? symptoms;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? vhtId;
  final String? vhtName;
  final String? assignedAmbulanceId;
  final String? assignedClinicId;
  final List<String>? attachmentUrls;
  final List<String>? localAttachmentPaths;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final bool isOffline;
  final String? offlineId; // Local ID for offline cases

  EmergencyCaseModel({
    this.id,
    required this.caseType,
    required this.urgencyLevel,
    this.status = CaseStatus.pending,
    this.patientName,
    this.patientAge,
    this.patientGender,
    this.description,
    this.symptoms,
    this.latitude,
    this.longitude,
    this.address,
    this.vhtId,
    this.vhtName,
    this.assignedAmbulanceId,
    this.assignedClinicId,
    this.attachmentUrls,
    this.localAttachmentPaths,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
    this.completedAt,
    this.isOffline = false,
    this.offlineId,
  }) : createdAt = createdAt ?? DateTime.now();

  // Factory constructor from JSON (from backend)
  factory EmergencyCaseModel.fromJson(Map<String, dynamic> json) {
    return EmergencyCaseModel(
      id: json['id'] as String?,
      caseType: CaseTypeExtension.fromString(json['caseType'] as String? ?? 'other'),
      urgencyLevel: UrgencyLevelExtension.fromString(json['urgencyLevel'] as String? ?? 'medium'),
      status: CaseStatusExtension.fromString(json['status'] as String? ?? 'pending'),
      patientName: json['patientName'] as String?,
      patientAge: json['patientAge'] as int?,
      patientGender: json['patientGender'] as String?,
      description: json['description'] as String?,
      symptoms: json['symptoms'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      vhtId: json['vhtId'] as String?,
      vhtName: json['vhtName'] as String?,
      assignedAmbulanceId: json['assignedAmbulanceId'] as String?,
      assignedClinicId: json['assignedClinicId'] as String?,
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
      patientName: map['patientName'] as String?,
      patientAge: map['patientAge'] as int?,
      patientGender: map['patientGender'] as String?,
      description: map['description'] as String?,
      symptoms: map['symptoms'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      address: map['address'] as String?,
      vhtId: map['vhtId'] as String?,
      vhtName: map['vhtName'] as String?,
      assignedAmbulanceId: map['assignedAmbulanceId'] as String?,
      assignedClinicId: map['assignedClinicId'] as String?,
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
    );
  }

  // Convert to JSON (for backend)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'caseType': caseType.value,
      'urgencyLevel': urgencyLevel.value,
      'status': status.value,
      if (patientName != null) 'patientName': patientName,
      if (patientAge != null) 'patientAge': patientAge,
      if (patientGender != null) 'patientGender': patientGender,
      if (description != null) 'description': description,
      if (symptoms != null) 'symptoms': symptoms,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (address != null) 'address': address,
      if (vhtId != null) 'vhtId': vhtId,
      if (vhtName != null) 'vhtName': vhtName,
      if (assignedAmbulanceId != null) 'assignedAmbulanceId': assignedAmbulanceId,
      if (assignedClinicId != null) 'assignedClinicId': assignedClinicId,
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
      if (patientName != null) 'patientName': patientName,
      if (patientAge != null) 'patientAge': patientAge,
      if (patientGender != null) 'patientGender': patientGender,
      if (description != null) 'description': description,
      if (symptoms != null) 'symptoms': symptoms,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (address != null) 'address': address,
      if (vhtId != null) 'vhtId': vhtId,
      if (vhtName != null) 'vhtName': vhtName,
      if (assignedAmbulanceId != null) 'assignedAmbulanceId': assignedAmbulanceId,
      if (assignedClinicId != null) 'assignedClinicId': assignedClinicId,
      if (attachmentUrls != null) 'attachmentUrls': attachmentUrls,
      if (localAttachmentPaths != null) 'localAttachmentPaths': localAttachmentPaths,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      'isOffline': isOffline,
    };
  }

  // Copy with method
  EmergencyCaseModel copyWith({
    String? id,
    CaseType? caseType,
    UrgencyLevel? urgencyLevel,
    CaseStatus? status,
    String? patientName,
    int? patientAge,
    String? patientGender,
    String? description,
    String? symptoms,
    double? latitude,
    double? longitude,
    String? address,
    String? vhtId,
    String? vhtName,
    String? assignedAmbulanceId,
    String? assignedClinicId,
    List<String>? attachmentUrls,
    List<String>? localAttachmentPaths,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool? isOffline,
    String? offlineId,
  }) {
    return EmergencyCaseModel(
      id: id ?? this.id,
      caseType: caseType ?? this.caseType,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      status: status ?? this.status,
      patientName: patientName ?? this.patientName,
      patientAge: patientAge ?? this.patientAge,
      patientGender: patientGender ?? this.patientGender,
      description: description ?? this.description,
      symptoms: symptoms ?? this.symptoms,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      vhtId: vhtId ?? this.vhtId,
      vhtName: vhtName ?? this.vhtName,
      assignedAmbulanceId: assignedAmbulanceId ?? this.assignedAmbulanceId,
      assignedClinicId: assignedClinicId ?? this.assignedClinicId,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      localAttachmentPaths: localAttachmentPaths ?? this.localAttachmentPaths,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      isOffline: isOffline ?? this.isOffline,
      offlineId: offlineId ?? this.offlineId,
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
