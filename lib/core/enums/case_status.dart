// Emergency case status enumeration
// Defines all possible states of an emergency case
enum CaseStatus {
  // Case created by VHT, awaiting clinician review
  pending,

  // Clinician sent advice to VHT (no ambulance needed)
  advised,

  // Clinician requested ambulance dispatch (admin assigns)
  ambulanceRequested,
  
  // Admin dispatched an ambulance
  dispatched,
  
  // Ambulance en route to patient
  enRoute,
  
  // Ambulance arrived at patient location
  arrived,
  
  // Patient picked up, heading to clinic
  inTransit,
  
  // Patient delivered to clinic
  delivered,
  
  // Case completed successfully
  completed,
  
  // Case cancelled
  cancelled,
}

// Extension methods for CaseStatus
extension CaseStatusExtension on CaseStatus {
  String get displayName {
    switch (this) {
      case CaseStatus.pending:
        return 'Pending Review';
      case CaseStatus.advised:
        return 'Advised';
      case CaseStatus.ambulanceRequested:
        return 'Ambulance Requested';
      case CaseStatus.dispatched:
        return 'Dispatched';
      case CaseStatus.enRoute:
        return 'En Route';
      case CaseStatus.arrived:
        return 'Arrived';
      case CaseStatus.inTransit:
        return 'In Transit';
      case CaseStatus.delivered:
        return 'Delivered';
      case CaseStatus.completed:
        return 'Completed';
      case CaseStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get value {
    switch (this) {
      case CaseStatus.pending:
        return 'pending';
      case CaseStatus.advised:
        return 'advised';
      case CaseStatus.ambulanceRequested:
        return 'ambulanceRequested';
      case CaseStatus.dispatched:
        return 'dispatched';
      case CaseStatus.enRoute:
        return 'enRoute';
      case CaseStatus.arrived:
        return 'arrived';
      case CaseStatus.inTransit:
        return 'inTransit';
      case CaseStatus.delivered:
        return 'delivered';
      case CaseStatus.completed:
        return 'completed';
      case CaseStatus.cancelled:
        return 'cancelled';
    }
  }

  static CaseStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return CaseStatus.pending;
      case 'advised':
        return CaseStatus.advised;
      case 'ambulancerequested':
      case 'ambulance_requested':
        return CaseStatus.ambulanceRequested;
      case 'dispatched':
        return CaseStatus.dispatched;
      case 'enroute':
      case 'en_route':
        return CaseStatus.enRoute;
      case 'arrived':
        return CaseStatus.arrived;
      case 'intransit':
      case 'in_transit':
        return CaseStatus.inTransit;
      case 'delivered':
        return CaseStatus.delivered;
      case 'completed':
        return CaseStatus.completed;
      case 'cancelled':
        return CaseStatus.cancelled;
      default:
        return CaseStatus.pending;
    }
  }

  bool get isActive {
    return this != CaseStatus.completed && this != CaseStatus.cancelled;
  }

  bool get isFinal {
    return this == CaseStatus.completed || this == CaseStatus.cancelled;
  }

  List<CaseStatus> get nextPossibleStatuses {
    switch (this) {
      case CaseStatus.pending:
        return [CaseStatus.advised, CaseStatus.ambulanceRequested, CaseStatus.cancelled];
      case CaseStatus.advised:
        return [CaseStatus.completed, CaseStatus.cancelled];
      case CaseStatus.ambulanceRequested:
        return [CaseStatus.dispatched, CaseStatus.cancelled];
      case CaseStatus.dispatched:
        return [CaseStatus.enRoute, CaseStatus.cancelled];
      case CaseStatus.enRoute:
        return [CaseStatus.arrived, CaseStatus.cancelled];
      case CaseStatus.arrived:
        return [CaseStatus.inTransit, CaseStatus.cancelled];
      case CaseStatus.inTransit:
        return [CaseStatus.delivered, CaseStatus.cancelled];
      case CaseStatus.delivered:
        return [CaseStatus.completed, CaseStatus.cancelled];
      case CaseStatus.completed:
      case CaseStatus.cancelled:
        return [];
    }
  }
}





