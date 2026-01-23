// Clinic matching service
// Finds the nearest clinic and matches emergency type to clinician specialty

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/location_utils.dart';

class ClinicMatchingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Maps emergency types to preferred specialties
  Map<String, List<String>> _getEmergencyTypeToSpecialty() {
    return {
      'Birth': ['Obstetrics & Gynecology', 'Clinical Officer', 'Nurse'],
      'Trauma': ['Surgery', 'General Medicine', 'Clinical Officer', 'Nurse'],
      'Infection': ['General Medicine', 'Clinical Officer', 'Nurse'],
      'Other': ['General Medicine', 'Clinical Officer', 'Nurse'],
    };
  }

  /// Maps emergency types to pediatric specialties (if patient is a child)
  Map<String, List<String>> _getPediatricSpecialty() {
    return {
      'Birth': ['Pediatrics', 'Obstetrics & Gynecology', 'Clinical Officer', 'Nurse'],
      'Trauma': ['Pediatrics', 'Surgery', 'General Medicine', 'Clinical Officer', 'Nurse'],
      'Infection': ['Pediatrics', 'General Medicine', 'Clinical Officer', 'Nurse'],
      'Other': ['Pediatrics', 'General Medicine', 'Clinical Officer', 'Nurse'],
    };
  }

  /// Find the nearest clinic with matching specialty
  /// Returns the clinician document ID and FCM token
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
        // Child patient - prefer pediatric specialties
        preferredSpecialties = _getPediatricSpecialty()[emergencyType] ?? 
            ['Pediatrics', 'General Medicine', 'Clinical Officer', 'Nurse'];
      } else {
        // Adult patient or unknown age
        preferredSpecialties = _getEmergencyTypeToSpecialty()[emergencyType] ?? 
            ['General Medicine', 'Clinical Officer', 'Nurse'];
      }

      // Get all clinicians
      final cliniciansSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Clinician')
          .get();

      if (cliniciansSnapshot.docs.isEmpty) {
        return null;
      }

      // Calculate distances and filter by specialty
      List<Map<String, dynamic>> matchingClinicians = [];

      for (var doc in cliniciansSnapshot.docs) {
        final data = doc.data();
        final specialty = data['specialty'] as String?;
        final clinicLat = data['clinicLatitude'] as double?;
        final clinicLon = data['longitude'] as double?;
        final fcmToken = data['fcmToken'] as String?;
        final isAvailable = data['isAvailable'] as bool? ?? true;

        // Skip if no location or FCM token
        if (clinicLat == null || clinicLon == null || fcmToken == null || fcmToken.isEmpty) {
          continue;
        }

        // Skip if not available
        if (!isAvailable) {
          continue;
        }

        // Check if specialty matches
        if (specialty != null && preferredSpecialties.contains(specialty)) {
          // Calculate distance
          final distance = LocationUtils.calculateDistance(
            vhtLatitude,
            vhtLongitude,
            clinicLat,
            clinicLon,
          );

          matchingClinicians.add({
            'clinicianId': doc.id,
            'specialty': specialty,
            'distance': distance,
            'fcmToken': fcmToken,
            'clinicName': data['workplace'] as String? ?? 'Unknown Clinic',
            'clinicianName': '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
          });
        }
      }

      // If no exact specialty match, fall back to any clinician
      if (matchingClinicians.isEmpty) {
        for (var doc in cliniciansSnapshot.docs) {
          final data = doc.data();
          final clinicLat = data['clinicLatitude'] as double?;
          final clinicLon = data['longitude'] as double?;
          final fcmToken = data['fcmToken'] as String?;
          final isAvailable = data['isAvailable'] as bool? ?? true;

          if (clinicLat == null || clinicLon == null || fcmToken == null || fcmToken.isEmpty || !isAvailable) {
            continue;
          }

          final distance = LocationUtils.calculateDistance(
            vhtLatitude,
            vhtLongitude,
            clinicLat,
            clinicLon,
          );

          matchingClinicians.add({
            'clinicianId': doc.id,
            'specialty': data['specialty'] as String? ?? 'General Medicine',
            'distance': distance,
            'fcmToken': fcmToken,
            'clinicName': data['workplace'] as String? ?? 'Unknown Clinic',
            'clinicianName': '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
          });
        }
      }

      // Sort by distance and return the nearest
      if (matchingClinicians.isEmpty) {
        return null;
      }

      matchingClinicians.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

      return matchingClinicians.first;
    } catch (e) {
      print('Error finding nearest clinic: $e');
      return null;
    }
  }
}
