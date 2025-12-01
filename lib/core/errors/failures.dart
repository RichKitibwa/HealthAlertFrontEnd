// Failure classes for error handling
// Defines different types of failures that can occur

// Base failure class
// TODO: Abstract base class for all failures
abstract class Failure {
  // TODO: Define failure message
  final String message;
  
  // TODO: Define error code (optional)
  final String? code;
  
  // TODO: Constructor
  const Failure(this.message, [this.code]);
}

// Network-related failures
// TODO: Failures related to network connectivity
class NetworkFailure extends Failure {
  // TODO: Network connection error
  const NetworkFailure([String message = 'No internet connection']) 
      : super(message, 'NETWORK_ERROR');
}

// Server-related failures
// TODO: Failures from backend API
class ServerFailure extends Failure {
  // TODO: Server error (4xx, 5xx)
  const ServerFailure([String message = 'Server error occurred'])
      : super(message, 'SERVER_ERROR');
}

// Cache-related failures
// TODO: Failures from local storage operations
class CacheFailure extends Failure {
  // TODO: Local database error
  const CacheFailure([String message = 'Cache operation failed'])
      : super(message, 'CACHE_ERROR');
}

// Authentication failures
// TODO: Failures during authentication
class AuthFailure extends Failure {
  // TODO: Authentication/authorization errors
  const AuthFailure([String message = 'Authentication failed'])
      : super(message, 'AUTH_ERROR');
}

// Permission failures
// TODO: Failures related to device permissions
class PermissionFailure extends Failure {
  // TODO: Permission denied errors
  const PermissionFailure([String message = 'Permission denied'])
      : super(message, 'PERMISSION_ERROR');
}

// NFC failures
// TODO: Failures during NFC operations
class NFCFailure extends Failure {
  // TODO: NFC-specific errors
  const NFCFailure([String message = 'NFC operation failed'])
      : super(message, 'NFC_ERROR');
}

// Location failures
// TODO: Failures getting location
class LocationFailure extends Failure {
  // TODO: GPS/location errors
  const LocationFailure([String message = 'Location unavailable'])
      : super(message, 'LOCATION_ERROR');
}

// Validation failures
// TODO: Failures from input validation
class ValidationFailure extends Failure {
  // TODO: Form/input validation errors
  const ValidationFailure([String message = 'Validation failed'])
      : super(message, 'VALIDATION_ERROR');
}

// Sync failures
// TODO: Failures during offline sync
class SyncFailure extends Failure {
  // TODO: Background sync errors
  const SyncFailure([String message = 'Sync failed'])
      : super(message, 'SYNC_ERROR');
}




