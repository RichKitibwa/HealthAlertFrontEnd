// User role enumeration
// Defines all possible user roles in the system

enum UserRole {
  // Village Health Team member
  // TODO: VHT role for community health workers
  vht,
  
  // Ambulance driver
  // TODO: Driver role for ambulance operators
  ambulanceDriver,
  
  // Clinic staff member
  // TODO: Clinic role for healthcare practitioners
  clinicStaff,
  
  // Administrator/NGO/OPM
  // TODO: Admin role for system administrators and monitors
  admin,
}

// Extension methods for UserRole
extension UserRoleExtension on UserRole {
  // TODO: Get display name for each role
  String get displayName {
    // TODO: Return human-readable role name
    // TODO: Consider localization
    return '';
  }
  
  // TODO: Get role identifier for API
  String get apiValue {
    // TODO: Return API-compatible role string
    return '';
  }
  
  // TODO: Get dashboard route for each role
  String get dashboardRoute {
    // TODO: Return appropriate dashboard route
    return '';
  }
}




