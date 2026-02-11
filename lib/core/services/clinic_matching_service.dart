// Clinic matching service
// Finds the nearest clinic and matches emergency type to clinician specialty

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/location_utils.dart';

class ClinicMatchingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Maps emergency types to preferred specialties
  Map<String, List<String>> _getEmergencyTypeToSpecialty() {
    return {
      'Birth': ['Obstetrics & Gynecology', 'Clinical Officer', 'Nurse', 'General Medicine'],
      'Trauma': ['Surgery', 'General Medicine', 'Clinical Officer', 'Nurse'],
      'Infection': ['General Medicine', 'Clinical Officer', 'Nurse'],
      'Other': ['General Medicine', 'Clinical Officer', 'Nurse'],
    };
  }

  /// Maps emergency types to pediatric specialties (if patient is a child)
  Map<String, List<String>> _getPediatricSpecialty() {
    return {
      'Birth': ['Pediatrics', 'Obstetrics & Gynecology', 'Clinical Officer', 'Nurse', 'General Medicine'],
      'Trauma': ['Pediatrics', 'Surgery', 'General Medicine', 'Clinical Officer', 'Nurse'],
      'Infection': ['Pediatrics', 'General Medicine', 'Clinical Officer', 'Nurse'],
      'Other': ['Pediatrics', 'General Medicine', 'Clinical Officer', 'Nurse'],
    };
  }

  /// Find the nearest clinic with matching specialty.
  /// Returns clinician info including document ID, name, clinic name, etc.
  ///
  /// Matching priority:
  /// 1. Specialty match + has location → sorted by distance
  /// 2. Specialty match + no location → any matching clinician
  /// 3. No specialty match → fall back to any available clinician
  Future<Map<String, dynamic>?> findNearestMatchingClinic({
    required double vhtLatitude,
    required double vhtLongitude,
    required String emergencyType,
    int? patientAge,
  }) async {
    try {
      // Determine preferred specialties based on emergency type and patient age
      List<String> preferredSpecialties;
      if (patientAge != null && patientAge < 18) {
        preferredSpecialties = _getPediatricSpecialty()[emergencyType] ??
            ['Pediatrics', 'General Medicine', 'Clinical Officer', 'Nurse'];
      } else {
        preferredSpecialties = _getEmergencyTypeToSpecialty()[emergencyType] ??
            ['General Medicine', 'Clinical Officer', 'Nurse'];
      }

      // Query clinicians - role is stored as 'Clinic Staff' during registration
      final cliniciansSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Clinic Staff')
          .get();

      if (cliniciansSnapshot.docs.isEmpty) {
        return null;
      }

      // Separate clinicians into those with and without location data
      List<Map<String, dynamic>> matchingWithLocation = [];
      List<Map<String, dynamic>> matchingWithoutLocation = [];

      for (var doc in cliniciansSnapshot.docs) {
        final data = doc.data();
        final specialty = data['specialty'] as String?;
        final isAvailable = data['isAvailable'] as bool? ?? true;

        // Skip if not available
        if (!isAvailable) {
          continue;
        }

        // Check if specialty matches preferred list
        final hasSpecialtyMatch = specialty != null && preferredSpecialties.contains(specialty);

        if (!hasSpecialtyMatch) {
          continue;
        }

        final Map<String, dynamic> clinicianInfo = {
          'clinicianId': doc.id,
          'specialty': specialty ?? 'General Medicine',
          'fcmToken': data['fcmToken'] as String? ?? '',
          'clinicName': data['workplace'] as String? ?? 'Unknown Clinic',
          'clinicianName': '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
          'phoneNumber': data['phoneNumber'] as String? ?? '',
        };

        // Check if clinician has location data
        final clinicLat = (data['clinicLatitude'] as num?)?.toDouble()
            ?? (data['latitude'] as num?)?.toDouble();
        final clinicLon = (data['clinicLongitude'] as num?)?.toDouble()
            ?? (data['longitude'] as num?)?.toDouble();

        if (clinicLat != null && clinicLon != null) {
          final distance = LocationUtils.calculateDistance(
            vhtLatitude,
            vhtLongitude,
            clinicLat,
            clinicLon,
          );
          clinicianInfo['distance'] = distance;
          clinicianInfo['clinicLatitude'] = clinicLat;
          clinicianInfo['clinicLongitude'] = clinicLon;
          matchingWithLocation.add(clinicianInfo);
        } else {
          clinicianInfo['distance'] = double.maxFinite;
          matchingWithoutLocation.add(clinicianInfo);
        }
      }

      // Priority 1: Specialty match + has location → sorted by distance
      if (matchingWithLocation.isNotEmpty) {
        matchingWithLocation.sort(
          (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
        );
        return matchingWithLocation.first;
      }

      // Priority 2: Specialty match + no location → return first available
      if (matchingWithoutLocation.isNotEmpty) {
        return matchingWithoutLocation.first;
      }

      // Priority 3: No specialty match → fall back to ANY available clinician
      for (var doc in cliniciansSnapshot.docs) {
        final data = doc.data();
        final isAvailable = data['isAvailable'] as bool? ?? true;

        if (!isAvailable) {
          continue;
        }

        final clinicLat = (data['clinicLatitude'] as num?)?.toDouble()
            ?? (data['latitude'] as num?)?.toDouble();
        final clinicLon = (data['clinicLongitude'] as num?)?.toDouble()
            ?? (data['longitude'] as num?)?.toDouble();

        double distance = double.maxFinite;
        if (clinicLat != null && clinicLon != null) {
          distance = LocationUtils.calculateDistance(
            vhtLatitude,
            vhtLongitude,
            clinicLat,
            clinicLon,
          );
        }

        return {
          'clinicianId': doc.id,
          'specialty': data['specialty'] as String? ?? 'General Medicine',
          'distance': distance,
          'fcmToken': data['fcmToken'] as String? ?? '',
          'clinicName': data['workplace'] as String? ?? 'Unknown Clinic',
          'clinicianName': '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
          'phoneNumber': data['phoneNumber'] as String? ?? '',
          if (clinicLat != null) 'clinicLatitude': clinicLat,
          if (clinicLon != null) 'clinicLongitude': clinicLon,
        };
      }

      return null;
    } catch (e) {
      debugPrint('Error finding nearest clinic: $e');
      return null;
    }
  }

  /// Find any clinician whose specialty matches the emergency type.
  /// Used as a fallback when VHT location is unavailable.
  /// Does NOT consider distance — just matches by expertise.
  Future<Map<String, dynamic>?> findMatchingClinicianWithoutLocation({
    required String emergencyType,
    int? patientAge,
  }) async {
    try {
      List<String> preferredSpecialties;
      if (patientAge != null && patientAge < 18) {
        preferredSpecialties = _getPediatricSpecialty()[emergencyType] ??
            ['Pediatrics', 'General Medicine', 'Clinical Officer', 'Nurse'];
      } else {
        preferredSpecialties = _getEmergencyTypeToSpecialty()[emergencyType] ??
            ['General Medicine', 'Clinical Officer', 'Nurse'];
      }

      final cliniciansSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Clinic Staff')
          .get();

      if (cliniciansSnapshot.docs.isEmpty) return null;

      // Try specialty match first
      for (var doc in cliniciansSnapshot.docs) {
        final data = doc.data();
        final specialty = data['specialty'] as String?;
        final isAvailable = data['isAvailable'] as bool? ?? true;

        if (!isAvailable) continue;

        if (specialty != null && preferredSpecialties.contains(specialty)) {
          return {
            'clinicianId': doc.id,
            'specialty': specialty,
            'fcmToken': data['fcmToken'] as String? ?? '',
            'clinicName': data['workplace'] as String? ?? 'Unknown Clinic',
            'clinicianName': '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
            'phoneNumber': data['phoneNumber'] as String? ?? '',
            'distance': double.maxFinite,
          };
        }
      }

      // Fall back to any available clinician
      for (var doc in cliniciansSnapshot.docs) {
        final data = doc.data();
        final isAvailable = data['isAvailable'] as bool? ?? true;
        if (!isAvailable) continue;

        return {
          'clinicianId': doc.id,
          'specialty': data['specialty'] as String? ?? 'General Medicine',
          'fcmToken': data['fcmToken'] as String? ?? '',
          'clinicName': data['workplace'] as String? ?? 'Unknown Clinic',
          'clinicianName': '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
          'phoneNumber': data['phoneNumber'] as String? ?? '',
          'distance': double.maxFinite,
        };
      }

      return null;
    } catch (e) {
      debugPrint('Error finding clinician without location: $e');
      return null;
    }
  }
}
