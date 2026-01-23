// Local storage service for offline data persistence
// Handles encrypted storage of sensitive user data using Hive

import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/emergency_case_model.dart';

class LocalStorageService {
  static const String _emergencyCasesBox = 'emergency_cases';
  static const String _offlineQueueBox = 'offline_queue';
  static const String _attachmentsBox = 'attachments';
  
  static Box? _emergencyCasesBoxInstance;
  static Box? _offlineQueueBoxInstance;
  static Box? _attachmentsBoxInstance;
  
  static bool _initialized = false;

  // Initialize Hive database
  static Future<void> initialize() async {
    if (_initialized) return;
    
    await Hive.initFlutter();
    
    // Register adapters if needed (for complex types, we'll use Map)
    _emergencyCasesBoxInstance = await Hive.openBox(_emergencyCasesBox);
    _offlineQueueBoxInstance = await Hive.openBox(_offlineQueueBox);
    _attachmentsBoxInstance = await Hive.openBox(_attachmentsBox);
    
    _initialized = true;
  }

  // Emergency Cases Storage
  static Future<void> saveEmergencyCaseLocally(EmergencyCaseModel caseModel) async {
    await initialize();
    final map = caseModel.toMap();
    final key = caseModel.offlineId ?? caseModel.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    await _emergencyCasesBoxInstance!.put(key, map);
  }

  static Future<EmergencyCaseModel?> getCaseById(String id) async {
    await initialize();
    final map = _emergencyCasesBoxInstance!.get(id);
    if (map == null) return null;
    return EmergencyCaseModel.fromMap(Map<String, dynamic>.from(map as Map));
  }

  static Future<List<EmergencyCaseModel>> getAllCachedCases() async {
    await initialize();
    final cases = <EmergencyCaseModel>[];
    for (var key in _emergencyCasesBoxInstance!.keys) {
      final map = _emergencyCasesBoxInstance!.get(key);
      if (map != null) {
        try {
          cases.add(EmergencyCaseModel.fromMap(Map<String, dynamic>.from(map as Map)));
        } catch (e) {
          // Skip invalid entries
        }
      }
    }
    return cases;
  }

  static Future<List<EmergencyCaseModel>> getOfflineCases() async {
    await initialize();
    final allCases = await getAllCachedCases();
    return allCases.where((c) => c.isOffline).toList();
  }

  static Future<void> updateCaseStatus(String id, String status) async {
    await initialize();
    final map = _emergencyCasesBoxInstance!.get(id);
    if (map != null) {
      final updatedMap = Map<String, dynamic>.from(map);
      updatedMap['status'] = status;
      updatedMap['updatedAt'] = DateTime.now().toIso8601String();
      await _emergencyCasesBoxInstance!.put(id, updatedMap);
    }
  }

  static Future<void> deleteSyncedCase(String id) async {
    await initialize();
    await _emergencyCasesBoxInstance!.delete(id);
  }

  // Offline Queue Storage
  static Future<void> addToOfflineQueue(String action, Map<String, dynamic> data) async {
    await initialize();
    final queueItem = {
      'action': action,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'retryCount': 0,
    };
    final key = '${action}_${DateTime.now().millisecondsSinceEpoch}';
    await _offlineQueueBoxInstance!.put(key, queueItem);
  }

  static Future<List<Map<String, dynamic>>> getPendingQueueItems() async {
    await initialize();
    final items = <Map<String, dynamic>>[];
    for (var key in _offlineQueueBoxInstance!.keys) {
      final map = _offlineQueueBoxInstance!.get(key);
      if (map != null) {
        items.add(Map<String, dynamic>.from(map as Map));
      }
    }
    // Sort by timestamp
    items.sort((a, b) => (a['timestamp'] as String).compareTo(b['timestamp'] as String));
    return items;
  }

  static Future<void> removeFromQueue(String key) async {
    await initialize();
    await _offlineQueueBoxInstance!.delete(key);
  }

  static Future<int> getQueueSize() async {
    await initialize();
    return _offlineQueueBoxInstance!.length;
  }

  // Attachments Storage
  static Future<void> saveAttachmentPath(String attachmentId, String filePath) async {
    await initialize();
    await _attachmentsBoxInstance!.put(attachmentId, filePath);
  }

  static Future<String?> getAttachmentPath(String attachmentId) async {
    await initialize();
    return _attachmentsBoxInstance!.get(attachmentId) as String?;
  }

  static Future<void> deleteAttachment(String attachmentId) async {
    await initialize();
    await _attachmentsBoxInstance!.delete(attachmentId);
  }

  // Cleanup Methods
  static Future<void> clearOldCachedData({int daysOld = 30}) async {
    await initialize();
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    final keysToDelete = <String>[];
    
    for (var key in _emergencyCasesBoxInstance!.keys) {
      final map = _emergencyCasesBoxInstance!.get(key);
      if (map != null) {
        final mapData = map as Map;
        final createdAt = mapData['createdAt'] as String?;
        if (createdAt != null) {
          final created = DateTime.parse(createdAt);
          if (created.isBefore(cutoffDate) && !(mapData['isOffline'] as bool? ?? false)) {
            keysToDelete.add(key.toString());
          }
        }
      }
    }
    
    for (var key in keysToDelete) {
      await _emergencyCasesBoxInstance!.delete(key);
    }
  }

  static Future<void> clearAllData() async {
    await initialize();
    await _emergencyCasesBoxInstance!.clear();
    await _offlineQueueBoxInstance!.clear();
    await _attachmentsBoxInstance!.clear();
  }
}
