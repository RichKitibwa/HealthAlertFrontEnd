// Background synchronization service
// Syncs offline data when connection is available

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../services/local_storage_service.dart';
import '../../data/repositories/emergency_case_repository.dart';
import '../../data/models/emergency_case_model.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Connectivity _connectivity = Connectivity();
  final EmergencyCaseRepository _caseRepository = EmergencyCaseRepository();

  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  // Trigger manual sync
  Future<void> syncNow() async {
    if (_isSyncing) return;

    try {
      _isSyncing = true;
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (!isOnline) {
        _isSyncing = false;
        return;
      }

      // Sync offline queue
      await _syncOfflineQueue();

      // Sync offline cases
      await _syncOfflineCases();

      _lastSyncTime = DateTime.now();
    } catch (e) {
      // Log error but don't throw
    } finally {
      _isSyncing = false;
    }
  }

  // Sync offline queue items
  Future<void> _syncOfflineQueue() async {
    final queueItems = await LocalStorageService.getPendingQueueItems();
    
    for (var item in queueItems) {
      try {
        final action = item['action'] as String;
        final data = item['data'] as Map<String, dynamic>;
        final key = item.keys.firstWhere((k) => k != 'action' && k != 'data' && k != 'timestamp' && k != 'retryCount');

        switch (action) {
          case 'createCase':
            await _syncCreateCase(data);
            break;
          case 'updateCaseStatus':
            await _syncUpdateCaseStatus(data);
            break;
          case 'uploadAttachment':
            await _syncUploadAttachment(data);
            break;
        }

        // Remove from queue after successful sync
        await LocalStorageService.removeFromQueue(key);
      } catch (e) {
        // Increment retry count and keep in queue
        final retryCount = (item['retryCount'] as int? ?? 0) + 1;
        if (retryCount < 5) {
          // Update retry count (would need to update queue item)
        } else {
          // Remove after max retries
          final key = item.keys.firstWhere((k) => k != 'action' && k != 'data' && k != 'timestamp' && k != 'retryCount');
          await LocalStorageService.removeFromQueue(key);
        }
      }
    }
  }

  // Sync create case
  Future<void> _syncCreateCase(Map<String, dynamic> data) async {
    final caseData = data['caseData'] as Map<String, dynamic>;
    final offlineId = data['offlineId'] as String;

    // Create in Firestore
    final docRef = await _firestore.collection('emergencyCases').add(caseData);
    final caseId = docRef.id;

    // Update local case with server ID
    final localCase = await LocalStorageService.getCaseById(offlineId);
    if (localCase != null) {
      final updatedCase = localCase.copyWith(
        id: caseId,
        isOffline: false,
        offlineId: null,
      );
      await LocalStorageService.saveEmergencyCaseLocally(updatedCase);
      await LocalStorageService.deleteSyncedCase(offlineId);
    }
  }

  // Sync update case status
  Future<void> _syncUpdateCaseStatus(Map<String, dynamic> data) async {
    final caseId = data['caseId'] as String;
    final status = data['status'] as String;

    await _firestore.collection('emergencyCases').doc(caseId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Sync upload attachment
  Future<void> _syncUploadAttachment(Map<String, dynamic> data) async {
    final caseId = data['caseId'] as String;
    final filePath = data['filePath'] as String;
    final attachmentId = data['attachmentId'] as String;

    final file = File(filePath);
    if (!await file.exists()) {
      return; // File doesn't exist, skip
    }

    final fileName = '${caseId}_${DateTime.now().millisecondsSinceEpoch}.${filePath.split('.').last}';
    final ref = _storage.ref().child('emergencyCases/$caseId/$fileName');
    await ref.putFile(file);
    final downloadUrl = await ref.getDownloadURL();

    // Update case with attachment URL
    final caseDoc = await _firestore.collection('emergencyCases').doc(caseId).get();
    if (caseDoc.exists) {
      final caseData = caseDoc.data()!;
      final attachmentUrls = List<String>.from(caseData['attachmentUrls'] ?? []);
      attachmentUrls.add(downloadUrl);
      await _firestore.collection('emergencyCases').doc(caseId).update({
        'attachmentUrls': attachmentUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    // Delete local attachment path
    await LocalStorageService.deleteAttachment(attachmentId);
  }

  // Sync offline cases
  Future<void> _syncOfflineCases() async {
    final offlineCases = await LocalStorageService.getOfflineCases();

    for (var caseModel in offlineCases) {
      try {
        if (caseModel.offlineId != null) {
          // This case was created offline, sync it
          final caseData = caseModel.toJson();
          caseData.remove('id'); // Remove ID so Firestore generates new one
          final docRef = await _firestore.collection('emergencyCases').add(caseData);
          
          // Update local case
          final updatedCase = caseModel.copyWith(
            id: docRef.id,
            isOffline: false,
            offlineId: null,
          );
          await LocalStorageService.saveEmergencyCaseLocally(updatedCase);
          await LocalStorageService.deleteSyncedCase(caseModel.offlineId!);
        }
      } catch (e) {
        // Continue with next case on error
      }
    }
  }

  // Get sync status
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  // Get pending sync count
  Future<int> getPendingSyncCount() async {
    final queueSize = await LocalStorageService.getQueueSize();
    final offlineCases = await LocalStorageService.getOfflineCases();
    return queueSize + offlineCases.length;
  }
}
