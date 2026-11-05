/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// Thrown when the assistant has no usable provider, such as a missing
/// server-side Zen key.
abstract class AgentProviderUnavailableException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  AgentProviderUnavailableException._({String? message})
    : message = message ?? 'The agent provider is not available';

  factory AgentProviderUnavailableException({String? message}) =
      _AgentProviderUnavailableExceptionImpl;

  factory AgentProviderUnavailableException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AgentProviderUnavailableException(
      message: jsonSerialization['message'] as String?,
    );
  }

  String message;

  /// Returns a shallow copy of this [AgentProviderUnavailableException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AgentProviderUnavailableException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentProviderUnavailableException',
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AgentProviderUnavailableException',
      'message': message,
    };
  }

  @override
  String toString() {
    return 'AgentProviderUnavailableException(message: $message)';
  }
}

class _AgentProviderUnavailableExceptionImpl
    extends AgentProviderUnavailableException {
  _AgentProviderUnavailableExceptionImpl({String? message})
    : super._(message: message);

  /// Returns a shallow copy of this [AgentProviderUnavailableException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AgentProviderUnavailableException copyWith({String? message}) {
    return AgentProviderUnavailableException(message: message ?? this.message);
  }
}
