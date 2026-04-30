import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RecentCaseEntry {
  final String caseId;
  final String emergencyType;
  final DateTime viewedAt;
  final String patientId;
  final String patientName;

  RecentCaseEntry({
    required this.caseId,
    required this.emergencyType,
    required this.viewedAt,
    this.patientId = '',
    this.patientName = '',
  });

  Map<String, dynamic> toMap() => {
        'caseId': caseId,
        'emergencyType': emergencyType,
        'viewedAt': viewedAt.toIso8601String(),
        'patientId': patientId,
        'patientName': patientName,
      };

  static RecentCaseEntry fromMap(Map<String, dynamic> map) {
    final viewedAtRaw = map['viewedAt']?.toString();
    return RecentCaseEntry(
      caseId: map['caseId']?.toString() ?? '',
      emergencyType: map['emergencyType']?.toString() ?? '',
      viewedAt: viewedAtRaw != null ? DateTime.parse(viewedAtRaw) : DateTime.fromMillisecondsSinceEpoch(0),
      patientId: map['patientId']?.toString() ?? '',
      patientName: map['patientName']?.toString() ?? '',
    );
  }
}

/// Lightweight "Return to Case" support:
/// stores a small per-user list of recently viewed cases in SharedPreferences.
class RecentCasesService {
  static const int maxRecentCases = 8;

  static String _prefsKeyForUser(String userId) => 'recent_cases_$userId';

  static Future<void> markCaseAsRecent({
    required String userId,
    required String caseId,
    required String emergencyType,
    String patientId = '',
    String patientName = '',
  }) async {
    final trimmedUserId = userId.trim();
    final trimmedCaseId = caseId.trim();
    if (trimmedUserId.isEmpty || trimmedCaseId.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final key = _prefsKeyForUser(trimmedUserId);

    final raw = prefs.getStringList(key) ?? <String>[];
    final now = DateTime.now();

    final entries = raw
        .map((s) {
          try {
            return RecentCaseEntry.fromMap(jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<RecentCaseEntry>()
        .toList();

    entries.removeWhere((e) => e.caseId == trimmedCaseId);
    entries.insert(
      0,
      RecentCaseEntry(
        caseId: trimmedCaseId,
        emergencyType: emergencyType.trim(),
        viewedAt: now,
        patientId: patientId.trim(),
        patientName: patientName.trim(),
      ),
    );

    final trimmed = entries.take(maxRecentCases).toList();
    await prefs.setStringList(key, trimmed.map((e) => jsonEncode(e.toMap())).toList());
  }

  static Future<List<RecentCaseEntry>> getRecentCasesForUser(String userId) async {
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) return const [];

    final prefs = await SharedPreferences.getInstance();
    final key = _prefsKeyForUser(trimmedUserId);
    final raw = prefs.getStringList(key) ?? <String>[];

    final entries = <RecentCaseEntry>[];
    for (final s in raw) {
      try {
        final decoded = jsonDecode(s) as Map<String, dynamic>;
        entries.add(RecentCaseEntry.fromMap(decoded));
      } catch (_) {
        // Skip invalid entries
      }
    }

    return entries;
  }

  static Future<void> removeCaseFromRecent({
    required String userId,
    required String caseId,
  }) async {
    final trimmedUserId = userId.trim();
    final trimmedCaseId = caseId.trim();
    if (trimmedUserId.isEmpty || trimmedCaseId.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final key = _prefsKeyForUser(trimmedUserId);
    final raw = prefs.getStringList(key) ?? <String>[];

    final updated = raw.where((s) {
      try {
        final decoded = jsonDecode(s) as Map<String, dynamic>;
        return decoded['caseId']?.toString() != trimmedCaseId;
      } catch (_) {
        return false;
      }
    }).toList();

    await prefs.setStringList(key, updated);
  }

  static Future<void> removeCompletedCases({
    required String userId,
    required Set<String> completedCaseIds,
  }) async {
    if (completedCaseIds.isEmpty) return;
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final key = _prefsKeyForUser(trimmedUserId);
    final raw = prefs.getStringList(key) ?? <String>[];

    final updated = raw.where((s) {
      try {
        final decoded = jsonDecode(s) as Map<String, dynamic>;
        final id = decoded['caseId']?.toString() ?? '';
        return !completedCaseIds.contains(id);
      } catch (_) {
        return false;
      }
    }).toList();

    await prefs.setStringList(key, updated);
  }
}

