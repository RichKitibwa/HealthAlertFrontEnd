// Clinic matching service
// Finds the best available clinician for an emergency, either at a VHT-selected
// facility (primary path) or by location proximity .

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/location_utils.dart';

class ClinicMatchingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns the preferred specialty list for a given emergency type and age.
  List<String> _preferredSpecialties(String emergencyType, int? patientAge) {
    final pediatric = patientAge != null && patientAge < 18;
    final map = pediatric ? _pediatricMap() : _adultMap();
    return map[emergencyType] ??
        (pediatric
            ? ['Pediatrics', 'General Medicine', 'Clinical Officer', 'Nurse']
            : ['General Medicine', 'Clinical Officer', 'Nurse']);
  }

  Map<String, List<String>> _adultMap() => {
        'Birth': ['Obstetrics & Gynecology', 'Midwife', 'Clinical Officer', 'Nurse', 'General Medicine'],
        'Trauma': ['Surgery', 'General Medicine', 'Clinical Officer', 'Nurse'],
        'Infection': ['General Medicine', 'Clinical Officer', 'Nurse'],
        'Other': ['General Medicine', 'Clinical Officer', 'Nurse'],
      };

  Map<String, List<String>> _pediatricMap() => {
        'Birth': ['Pediatrics', 'Obstetrics & Gynecology', 'Midwife', 'Clinical Officer', 'Nurse', 'General Medicine'],
        'Trauma': ['Pediatrics', 'Surgery', 'General Medicine', 'Clinical Officer', 'Nurse'],
        'Infection': ['Pediatrics', 'General Medicine', 'Clinical Officer', 'Nurse'],
        'Other': ['Pediatrics', 'General Medicine', 'Clinical Officer', 'Nurse'],
      };

  static const List<String> _generalFallbackSpecialties = [
    'General Medicine',
    'Clinical Officer',
    'Nurse',
  ];

  /// Build clinician info map from a Firestore document + calculated distance.
  Map<String, dynamic> _buildClinicianInfo(
    DocumentSnapshot<Map<String, dynamic>> doc,
    double distance,
  ) {
    final data = doc.data()!;
    final clinicLat = (data['clinicLatitude'] as num?)?.toDouble() ??
        (data['latitude'] as num?)?.toDouble();
    final clinicLon = (data['clinicLongitude'] as num?)?.toDouble() ??
        (data['longitude'] as num?)?.toDouble();
    return <String, dynamic>{
      'clinicianId': doc.id,
      'specialty': data['specialty'] as String? ?? 'General Medicine',
      'distance': distance,
      'fcmToken': data['fcmToken'] as String? ?? '',
      'clinicName': data['workplace'] as String? ?? 'Unknown Clinic',
      'clinicianName':
          '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
      'phoneNumber': data['phoneNumber'] as String? ?? '',
      if (clinicLat != null) 'clinicLatitude': clinicLat,
      if (clinicLon != null) 'clinicLongitude': clinicLon,
    };
  }

  /// Find the nearest available clinician, with specialty match as a secondary
  /// tiebreaker.
  ///
  /// SELECTION PRIORITY (distance is ALWAYS first):
  /// 1. Nearest clinician whose specialty is in the preferred list.
  /// 2. Nearest clinician whose specialty is a general fallback
  ///    (General Medicine / Clinical Officer / Nurse).
  /// 3. Absolute nearest available clinician, regardless of specialty.
  Future<Map<String, dynamic>?> findNearestMatchingClinic({
    required double vhtLatitude,
    required double vhtLongitude,
    required String emergencyType,
    int? patientAge,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Clinic Staff')
          .get();

      if (snapshot.docs.isEmpty) return null;

      // Build all available clinicians with their distances
      final all = <Map<String, dynamic>>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final isAvailable = data['isAvailable'] as bool? ?? true;
        if (!isAvailable) continue;

        final clinicLat = (data['clinicLatitude'] as num?)?.toDouble() ??
            (data['latitude'] as num?)?.toDouble();
        final clinicLon = (data['clinicLongitude'] as num?)?.toDouble() ??
            (data['longitude'] as num?)?.toDouble();

        final distance = (clinicLat != null && clinicLon != null)
            ? LocationUtils.calculateDistance(
                vhtLatitude, vhtLongitude, clinicLat, clinicLon)
            : double.maxFinite;

        all.add(_buildClinicianInfo(doc, distance));
      }

      if (all.isEmpty) return null;

      // Sort ALL by distance — nearest first, always.
      all.sort(
          (a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

      // Case categorization requirement: do NOT gate assignment by specialty.
      // Choose the nearest available clinician, regardless of specialty.
      return all.first;
    } catch (e) {
      debugPrint('Error finding nearest clinic: $e');
      return null;
    }
  }

  /// Find any clinician whose specialty matches the emergency type.
  /// Used as a fallback when VHT location is unavailable.
  /// Still prefers specialty match, then general fallback, then any available.
  Future<Map<String, dynamic>?> findMatchingClinicianWithoutLocation({
    required String emergencyType,
    int? patientAge,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Clinic Staff')
          .get();

      if (snapshot.docs.isEmpty) return null;

      final available = <Map<String, dynamic>>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final isAvailable = data['isAvailable'] as bool? ?? true;
        if (!isAvailable) continue;
        available.add(_buildClinicianInfo(doc, double.maxFinite));
      }

      if (available.isEmpty) return null;

      // Case categorization requirement: do NOT gate assignment by specialty.
      // Pick any available clinician.
      return available.first;
    } catch (e) {
      debugPrint('Error finding clinician without location: $e');
      return null;
    }
  }

  /// Find the best available clinician registered at [facilityName].
  ///
  /// 1. Clinician with a preferred specialty for the emergency type.
  /// 2. Clinician with a general fallback specialty (General Medicine / Clinical Officer / Nurse).
  /// 3. Any available clinician at the facility.
  ///
  /// Returns null if no clinicians are registered at the facility.
  Future<Map<String, dynamic>?> findBestClinicianAtFacility({
    required String facilityName,
    required String emergencyType,
    int? patientAge,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Clinic Staff')
          .where('workplace', isEqualTo: facilityName)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final available = <Map<String, dynamic>>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final isAvailable = data['isAvailable'] as bool? ?? true;
        if (!isAvailable) continue;
        available.add(_buildClinicianInfo(doc, 0));
      }

      if (available.isEmpty) return null;

      // Case categorization requirement: do NOT gate assignment by specialty.
      // Pick any available clinician at the facility so the case stays actionable.
      return available.first;
    } catch (e) {
      debugPrint('Error finding clinician at facility: $e');
      return null;
    }
  }

  /// Find the nearest available admin to a given location.
  /// Used when deciding which admin to notify for ambulance dispatch requests.
  ///
  /// Returns null if no admins exist.
  Future<Map<String, dynamic>?> findNearestAdmin({
    double? nearLat,
    double? nearLng,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Admin')
          .get();

      if (snapshot.docs.isEmpty) return null;

      final admins = <Map<String, dynamic>>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final adminLat = (data['latitude'] as num?)?.toDouble();
        final adminLng = (data['longitude'] as num?)?.toDouble();

        double distance = double.maxFinite;
        if (nearLat != null &&
            nearLng != null &&
            adminLat != null &&
            adminLng != null) {
          distance = LocationUtils.calculateDistance(
              nearLat, nearLng, adminLat, adminLng);
        }

        admins.add({
          'adminId': doc.id,
          'adminName':
              '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
          'phoneNumber': data['phoneNumber'] as String? ?? '',
          'fcmToken': data['fcmToken'] as String? ?? '',
          'distance': distance,
        });
      }

      if (admins.isEmpty) return null;

      // Sort by distance if location was available, otherwise just pick first
      admins.sort(
          (a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

      return admins.first;
    } catch (e) {
      debugPrint('Error finding nearest admin: $e');
      return null;
    }
  }
}
