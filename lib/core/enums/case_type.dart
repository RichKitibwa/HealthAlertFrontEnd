// Emergency case type enumeration
// Defines categories of medical emergencies

enum CaseType {
  // General medical emergency
  // TODO: Non-trauma medical conditions
  medical,
  
  // Injury or accident
  // TODO: Physical trauma cases
  trauma,
  
  // Pregnancy/childbirth related
  // TODO: Maternal health emergencies
  maternal,
  
  // Child-specific emergency
  // TODO: Pediatric cases
  pediatric,
  
  // Other/unspecified
  // TODO: Cases that don't fit other categories
  other,
}

// Extension methods for CaseType
extension CaseTypeExtension on CaseType {
  // TODO: Get display name for each case type
  String get displayName {
    // TODO: Return human-readable type name
    // TODO: Consider localization
    return '';
  }
  
  // TODO: Get icon for case type
  // IconData get icon {
  //   TODO: Return appropriate icon for each type
  // }
  
  // TODO: Get color for case type indicator
  // Color get color {
  //   TODO: Return distinguishing color for each type
  // }
  
  // TODO: Get common symptoms/indicators for case type
  List<String> get commonIndicators {
    // TODO: Return list of typical symptoms for this type
    return [];
  }
}




