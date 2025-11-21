// Emergency case status enumeration
// Defines all possible states of an emergency case

enum CaseStatus {
  // Case created, awaiting dispatch
  // TODO: Initial status when VHT creates case
  pending,
  
  // Ambulance dispatched
  // TODO: Ambulance has been assigned to case
  dispatched,
  
  // Ambulance en route to patient
  // TODO: Ambulance is traveling to pickup location
  enRoute,
  
  // Ambulance arrived at patient location
  // TODO: Ambulance has reached the patient
  arrived,
  
  // Patient picked up, heading to clinic
  // TODO: Patient is in ambulance, traveling to clinic
  inTransit,
  
  // Patient delivered to clinic
  // TODO: Patient has been handed over to clinic
  delivered,
  
  // Case completed successfully
  // TODO: All procedures completed, case closed
  completed,
  
  // Case cancelled
  // TODO: Case was cancelled (with reason)
  cancelled,
}

// Extension methods for CaseStatus
extension CaseStatusExtension on CaseStatus {
  // TODO: Get display name for each status
  String get displayName {
    // TODO: Return human-readable status
    // TODO: Consider localization
    return '';
  }
  
  // TODO: Get color for status indicator
  // Color get color {
  //   TODO: Return appropriate color for each status
  // }
  
  // TODO: Check if case is active
  bool get isActive {
    // TODO: Return true if case is in progress
    return false;
  }
  
  // TODO: Check if case is final (completed or cancelled)
  bool get isFinal {
    // TODO: Return true if case is in terminal state
    return false;
  }
  
  // TODO: Get next possible statuses
  List<CaseStatus> get nextPossibleStatuses {
    // TODO: Return list of valid next states
    return [];
  }
}

