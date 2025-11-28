// Immunization status enumeration
// Defines status of individual immunization records

enum ImmunizationStatus {
  // Immunization scheduled but not yet due
  // TODO: Future scheduled vaccination
  scheduled,
  
  // Immunization is due soon (within 7 days)
  // TODO: Upcoming vaccination
  dueSoon,
  
  // Immunization is currently due
  // TODO: Should be administered now
  due,
  
  // Immunization is overdue
  // TODO: Past due date, needs attention
  overdue,
  
  // Immunization completed
  // TODO: Successfully administered
  completed,
  
  // Immunization missed/skipped
  // TODO: Was not administered when due
  missed,
}

// Extension methods for ImmunizationStatus
extension ImmunizationStatusExtension on ImmunizationStatus {
  // TODO: Get display name for each status
  String get displayName {
    // TODO: Return human-readable status
    // TODO: Consider localization
    return '';
  }
  
  // TODO: Get color for status indicator
  // Color get color {
  //   TODO: Return appropriate color
  //   - completed: green
  //   - due/dueSoon: yellow
  //   - overdue: orange
  //   - missed: red
  //   - scheduled: blue
  // }
  
  // TODO: Check if action is needed
  bool get requiresAction {
    // TODO: Return true if VHT should take action
    // (due, overdue, missed)
    return false;
  }
  
  // TODO: Get priority level
  int get priority {
    // TODO: Return urgency of addressing this status
    // overdue/missed: highest priority
    // due: medium priority
    // dueSoon: low priority
    // completed/scheduled: no priority
    return 0;
  }
}


