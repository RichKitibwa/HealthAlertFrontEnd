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
  String get displayName {
    switch (this) {
      case CaseType.medical:
        return 'Medical';
      case CaseType.trauma:
        return 'Trauma';
      case CaseType.maternal:
        return 'Maternal';
      case CaseType.pediatric:
        return 'Pediatric';
      case CaseType.other:
        return 'Other';
    }
  }
  
  String get value {
    switch (this) {
      case CaseType.medical:
        return 'medical';
      case CaseType.trauma:
        return 'trauma';
      case CaseType.maternal:
        return 'maternal';
      case CaseType.pediatric:
        return 'pediatric';
      case CaseType.other:
        return 'other';
    }
  }
  
  static CaseType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'medical':
        return CaseType.medical;
      case 'trauma':
        return CaseType.trauma;
      case 'maternal':
      case 'birth':
        return CaseType.maternal;
      case 'pediatric':
        return CaseType.pediatric;
      case 'other':
      case 'infection':
        return CaseType.other;
      default:
        return CaseType.other;
    }
  }
  
  List<String> get commonIndicators {
    switch (this) {
      case CaseType.medical:
        return ['Fever', 'Pain', 'Difficulty breathing', 'Nausea'];
      case CaseType.trauma:
        return ['Bleeding', 'Bruising', 'Fracture', 'Laceration'];
      case CaseType.maternal:
        return ['Labor pains', 'Bleeding', 'High blood pressure', 'Contractions'];
      case CaseType.pediatric:
        return ['Fever', 'Dehydration', 'Difficulty feeding', 'Rash'];
      case CaseType.other:
        return ['Varies'];
    }
  }
}





