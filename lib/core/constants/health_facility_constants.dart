/// Health facility and clinician specialty constants for Rhino and Imvepi settlements.
class HealthFacilityConstants {
  HealthFacilityConstants._();

  // Camps 
  static const String imvepiCamp = 'Imvepi Camp';
  static const String rhinoCamp = 'Rhino Camp';

  static const List<String> camps = [
    imvepiCamp,
    rhinoCamp,
  ];

  //Facilities by camp
  static const List<String> imvepiFacilities = [
    'Zone 3 HCIII',
    'Yinga HC III',
    'Imvepi HC II',
    'Tank 29 HC II',
  ];

  static const List<String> rhinoFacilities = [
    'Widi Omugo Extension HC III',
    'Ocia HC III',
    'Uriama HC III',
    'OCEA HC II',
    'Odobu HC II',
  ];

  static const List<String> allFacilities = [
    ...imvepiFacilities,
    ...rhinoFacilities,
  ];

  static const Map<String, List<String>> facilitiesByCamp = {
    imvepiCamp: imvepiFacilities,
    rhinoCamp: rhinoFacilities,
  };

  static String? campForFacility(String facilityName) {
    for (final entry in facilitiesByCamp.entries) {
      if (entry.value.contains(facilityName)) return entry.key;
    }
    return null;
  }

  // specialties
  static const List<String> clinicianSpecialties = [
    'General Medicine',
    'Pediatrics',
    'Obstetrics & Gynecology',
    'Surgery',
    'Clinical Officer',
    'Nurse',
    'Midwife',
  ];
}
