// Emergency urgency level enumeration
// Defines priority levels for emergency cases

enum UrgencyLevel {
  // Life-threatening emergency
  // TODO: Requires immediate response
  critical,
  
  // Serious condition
  // TODO: Urgent but not immediately life-threatening
  high,
  
  // Moderate condition
  // TODO: Needs attention but not urgent
  medium,
  
  // Non-urgent case
  // TODO: Can wait for response
  low,
}

// Extension methods for UrgencyLevel
extension UrgencyLevelExtension on UrgencyLevel {
  String get displayName {
    switch (this) {
      case UrgencyLevel.critical:
        return 'Critical';
      case UrgencyLevel.high:
        return 'High';
      case UrgencyLevel.medium:
        return 'Moderate';
      case UrgencyLevel.low:
        return 'Low';
    }
  }
  
  String get value {
    switch (this) {
      case UrgencyLevel.critical:
        return 'critical';
      case UrgencyLevel.high:
        return 'high';
      case UrgencyLevel.medium:
        return 'medium';
      case UrgencyLevel.low:
        return 'low';
    }
  }
  
  static UrgencyLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'critical':
        return UrgencyLevel.critical;
      case 'high':
        return UrgencyLevel.high;
      case 'medium':
        return UrgencyLevel.medium;
      case 'low':
        return UrgencyLevel.low;
      default:
        return UrgencyLevel.medium;
    }
  }
  
  int get targetResponseTime {
    switch (this) {
      case UrgencyLevel.critical:
        return 15;
      case UrgencyLevel.high:
        return 30;
      case UrgencyLevel.medium:
        return 60;
      case UrgencyLevel.low:
        return 120;
    }
  }
  
  int get priority {
    switch (this) {
      case UrgencyLevel.critical:
        return 1;
      case UrgencyLevel.high:
        return 2;
      case UrgencyLevel.medium:
        return 3;
      case UrgencyLevel.low:
        return 4;
    }
  }
}





