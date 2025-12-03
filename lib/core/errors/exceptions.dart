// Exception classes
// Defines exceptions thrown by data sources

// Base exception class
// TODO: Abstract base class for all exceptions
abstract class AppException implements Exception {
  // TODO: Define exception message
  final String message;
  
  // TODO: Constructor
  const AppException(this.message);
  
  @override
  String toString() => message;
}

// Network exceptions
// TODO: Network-related exceptions
class NetworkException extends AppException {
  const NetworkException([String message = 'Network error occurred'])
      : super(message);
}

// Server exceptions
// TODO: API/Backend exceptions
class ServerException extends AppException {
  // TODO: HTTP status code
  final int? statusCode;
  
  const ServerException(String message, [this.statusCode])
      : super(message);
}

// Cache exceptions
// TODO: Local storage exceptions
class CacheException extends AppException {
  const CacheException([String message = 'Cache operation failed'])
      : super(message);
}

// Authentication exceptions
// TODO: Auth-related exceptions
class AuthException extends AppException {
  const AuthException([String message = 'Authentication failed'])
      : super(message);
}

// Permission exceptions
// TODO: Permission-related exceptions
class PermissionException extends AppException {
  const PermissionException([String message = 'Permission denied'])
      : super(message);
}

// NFC exceptions
// TODO: NFC operation exceptions
class NFCException extends AppException {
  const NFCException([String message = 'NFC operation failed'])
      : super(message);
}

// Location exceptions
// TODO: Location service exceptions
class LocationException extends AppException {
  const LocationException([String message = 'Location error'])
      : super(message);
}





