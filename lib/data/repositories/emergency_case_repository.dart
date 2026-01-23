// Emergency case repository
// Handles emergency case data operations with offline support

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/enums/case_status.dart';
import '../../core/enums/urgency_level.dart';
import '../models/emergency_case_model.dart';
import '../../features/auth/current_user_session.dart';

class EmergencyCaseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Connectivity _connectivity = Connectivity();

  // Create new emergency case
  Future<EmergencyCaseModel> createCase(EmergencyCaseModel caseModel) async {
    try {
      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      // Prepare case data with VHT info
      final caseData = caseModel.toJson();
      caseData['vhtId'] = CurrentUserSession.uid;
      caseData['vhtName'] = CurrentUserSession.fullName;
      caseData['createdAt'] = FieldValue.serverTimestamp();
      caseData['updatedAt'] = FieldValue.serverTimestamp();

      if (isOnline) {
        // Create in Firestore
        final docRef = await _firestore.collection('emergencyCases').add(caseData);
        final createdCase = caseModel.copyWith(
          id: docRef.id,
          isOffline: false,
        );

        // Save locally for caching
        await LocalStorageService.saveEmergencyCaseLocally(createdCase);
        return createdCase;
      } else {
        // Save offline
        final offlineId = DateTime.now().millisecondsSinceEpoch.toString();
        final offlineCase = caseModel.copyWith(
          offlineId: offlineId,
          isOffline: true,
        );

        // Save to local storage
        await LocalStorageService.saveEmergencyCaseLocally(offlineCase);

        // Add to offline queue for sync
        await LocalStorageService.addToOfflineQueue('createCase', {
          'caseData': caseData,
          'offlineId': offlineId,
        });

        return offlineCase;
      }
    } catch (e) {
      // If online but failed, save offline
      final offlineId = DateTime.now().millisecondsSinceEpoch.toString();
      final offlineCase = caseModel.copyWith(
        offlineId: offlineId,
        isOffline: true,
      );
      await LocalStorageService.saveEmergencyCaseLocally(offlineCase);
      await LocalStorageService.addToOfflineQueue('createCase', {
        'caseData': caseModel.toJson(),
        'offlineId': offlineId,
      });
      return offlineCase;
    }
  }

  // Get case by ID
  Future<EmergencyCaseModel?> getCaseById(String id) async {
    try {
      // Try to get from Firestore first
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        final docSnapshot = await _firestore.collection('emergencyCases').doc(id).get();
        if (docSnapshot.exists) {
          final data = Map<String, dynamic>.from(docSnapshot.data()!);
          data['id'] = docSnapshot.id;
          // Convert Firestore timestamps
          if (data['createdAt'] is Timestamp) {
            data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
          }
          if (data['updatedAt'] is Timestamp) {
            data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
          }
          if (data['completedAt'] is Timestamp) {
            data['completedAt'] = (data['completedAt'] as Timestamp).toDate().toIso8601String();
          }
          final caseModel = EmergencyCaseModel.fromJson(data);
          // Cache locally
          await LocalStorageService.saveEmergencyCaseLocally(caseModel);
          return caseModel;
        }
      }

      // Fallback to local storage
      return await LocalStorageService.getCaseById(id);
    } catch (e) {
      // Fallback to local storage on error
      return await LocalStorageService.getCaseById(id);
    }
  }

  // Get list of cases (with filters)
  Future<List<EmergencyCaseModel>> getCases({
    CaseStatus? status,
    UrgencyLevel? urgency,
    String? vhtId,
    int? limit,
  }) async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        Query query = _firestore.collection('emergencyCases');

        if (status != null) {
          query = query.where('status', isEqualTo: status.value);
        }
        if (urgency != null) {
          query = query.where('urgencyLevel', isEqualTo: urgency.value);
        }
        if (vhtId != null) {
          query = query.where('vhtId', isEqualTo: vhtId);
        }

        query = query.orderBy('createdAt', descending: true);
        if (limit != null) {
          query = query.limit(limit);
        }

        final querySnapshot = await query.get();
        final cases = querySnapshot.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data() as Map);
          data['id'] = doc.id;
          // Convert Firestore timestamps
          if (data['createdAt'] is Timestamp) {
            data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
          }
          if (data['updatedAt'] is Timestamp) {
            data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
          }
          if (data['completedAt'] is Timestamp) {
            data['completedAt'] = (data['completedAt'] as Timestamp).toDate().toIso8601String();
          }
          return EmergencyCaseModel.fromJson(data);
        }).toList();

        // Cache locally
        for (var caseModel in cases) {
          await LocalStorageService.saveEmergencyCaseLocally(caseModel);
        }

        return cases;
      } else {
        // Return offline cases
        final allCases = await LocalStorageService.getAllCachedCases();
        var filtered = allCases;

        if (status != null) {
          filtered = filtered.where((c) => c.status == status).toList();
        }
        if (urgency != null) {
          filtered = filtered.where((c) => c.urgencyLevel == urgency).toList();
        }
        if (vhtId != null) {
          filtered = filtered.where((c) => c.vhtId == vhtId).toList();
        }

        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (limit != null) {
          filtered = filtered.take(limit).toList();
        }

        return filtered;
      }
    } catch (e) {
      // Fallback to local storage
      final allCases = await LocalStorageService.getAllCachedCases();
      return allCases;
    }
  }

  // Update case status
  Future<void> updateCaseStatus(String id, CaseStatus status) async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        await _firestore.collection('emergencyCases').doc(id).update({
          'status': status.value,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        await LocalStorageService.updateCaseStatus(id, status.value);
      } else {
        // Queue for sync
        await LocalStorageService.addToOfflineQueue('updateCaseStatus', {
          'caseId': id,
          'status': status.value,
        });
        await LocalStorageService.updateCaseStatus(id, status.value);
      }
    } catch (e) {
      // Queue for sync on error
      await LocalStorageService.addToOfflineQueue('updateCaseStatus', {
        'caseId': id,
        'status': status.value,
      });
      await LocalStorageService.updateCaseStatus(id, status.value);
    }
  }

  // Upload case attachment (image/voice)
  Future<String> uploadAttachment(String caseId, File file, String type) async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        final fileName = '${caseId}_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
        final ref = _storage.ref().child('emergencyCases/$caseId/$fileName');
        await ref.putFile(file);
        final downloadUrl = await ref.getDownloadURL();
        return downloadUrl;
      } else {
        // Save path locally for later upload
        final attachmentId = '${caseId}_${DateTime.now().millisecondsSinceEpoch}';
        await LocalStorageService.saveAttachmentPath(attachmentId, file.path);
        await LocalStorageService.addToOfflineQueue('uploadAttachment', {
          'caseId': caseId,
          'filePath': file.path,
          'type': type,
          'attachmentId': attachmentId,
        });
        return file.path; // Return local path temporarily
      }
    } catch (e) {
      // Save locally on error
      final attachmentId = '${caseId}_${DateTime.now().millisecondsSinceEpoch}';
      await LocalStorageService.saveAttachmentPath(attachmentId, file.path);
      await LocalStorageService.addToOfflineQueue('uploadAttachment', {
        'caseId': caseId,
        'filePath': file.path,
        'type': type,
        'attachmentId': attachmentId,
      });
      return file.path;
    }
  }

  // Stream case status updates
  Stream<EmergencyCaseModel?> streamCaseUpdates(String id) {
    return _firestore
        .collection('emergencyCases')
        .doc(id)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      final data = Map<String, dynamic>.from(snapshot.data()! as Map);
      data['id'] = snapshot.id;
      // Convert Firestore timestamps
      if (data['createdAt'] is Timestamp) {
        data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
      }
      if (data['updatedAt'] is Timestamp) {
        data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
      }
      if (data['completedAt'] is Timestamp) {
        data['completedAt'] = (data['completedAt'] as Timestamp).toDate().toIso8601String();
      }
      return EmergencyCaseModel.fromJson(data);
    });
  }
}
