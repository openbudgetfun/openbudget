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

/// Thrown when no tax rule pack is available for a jurisdiction or year.
class TaxRulesUnavailableException implements Exception {
  TaxRulesUnavailableException([this.message = 'Tax rules are not available']);

  final String message;

  @override
  String toString() => 'TaxRulesUnavailableException: $message';
}

/// Thrown when an amount cannot be converted to the report's currency.
class TaxRateUnavailableException implements Exception {
  TaxRateUnavailableException([this.message = 'Exchange rate not available']);

  final String message;

  @override
  String toString() => 'TaxRateUnavailableException: $message';
}

/// Thrown when a feature needs OpenBudget Plus and the user has no active
/// subscription.
class EntitlementRequiredException implements Exception {
  EntitlementRequiredException([
    this.message = 'OpenBudget Plus is required',
  ]);

  final String message;

  @override
  String toString() => 'EntitlementRequiredException: $message';
}

/// Thrown when a billing rail is not configured or its provider rejects a
/// request.
class BillingRailUnavailableException implements Exception {
  BillingRailUnavailableException([
    this.message = 'This payment rail is not available',
  ]);

  final String message;

  @override
  String toString() => 'BillingRailUnavailableException: $message';
}

/// Thrown when a billing provider accepts a request but fails to complete it.
///
/// The message never contains response bodies or credentials.
class BillingProviderException implements Exception {
  BillingProviderException(this.provider, [this.details]);

  final String provider;
  final String? details;

  @override
  String toString() => details == null
      ? 'BillingProviderException: $provider request failed'
      : 'BillingProviderException: $provider request failed ($details)';
}

/// Thrown when the built-in agent allowance for the current period is spent.
class AgentAllowanceExhaustedException implements Exception {
  AgentAllowanceExhaustedException([
    this.message = 'The included OpenBudget Plus agent usage is used up',
  ]);

  final String message;

  @override
  String toString() => 'AgentAllowanceExhaustedException: $message';
}

/// Thrown when the assistant has no usable provider, such as a missing
/// server-side Zen key.
class AgentProviderUnavailableException implements Exception {
  AgentProviderUnavailableException([
    this.message = 'The agent provider is not available',
  ]);

  final String message;

  @override
  String toString() => 'AgentProviderUnavailableException: $message';
}

/// Thrown when a provider call fails or answers with something unusable.
class AgentProviderException implements Exception {
  AgentProviderException([this.message = 'The agent provider call failed']);

  final String message;

  @override
  String toString() => 'AgentProviderException: $message';
}
