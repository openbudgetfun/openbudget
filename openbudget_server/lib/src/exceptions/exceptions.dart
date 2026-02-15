/// Thrown when an endpoint requires authentication but the user is not
/// authenticated.
class AuthenticationRequiredException implements Exception {
  AuthenticationRequiredException([this.message = 'Authentication required']);

  final String message;

  @override
  String toString() => 'AuthenticationRequiredException: $message';
}

/// Thrown when a requested resource does not exist or the user does not have
/// access to it.
class NotFoundException implements Exception {
  NotFoundException([this.message = 'Resource not found']);

  final String message;

  @override
  String toString() => 'NotFoundException: $message';
}

/// Thrown when a user attempts an action they are not authorized to perform.
class ForbiddenException implements Exception {
  ForbiddenException([this.message = 'Forbidden']);

  final String message;

  @override
  String toString() => 'ForbiddenException: $message';
}

/// Thrown when input validation fails.
class ValidationException implements Exception {
  ValidationException([this.message = 'Validation failed']);

  final String message;

  @override
  String toString() => 'ValidationException: $message';
}
