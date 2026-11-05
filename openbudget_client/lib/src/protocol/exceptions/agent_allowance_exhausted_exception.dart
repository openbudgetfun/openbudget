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

/// Thrown when the built-in agent allowance for the current period is spent.
abstract class AgentAllowanceExhaustedException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  AgentAllowanceExhaustedException._({String? message})
    : message =
          message ?? 'The included OpenBudget Plus agent usage is used up';

  factory AgentAllowanceExhaustedException({String? message}) =
      _AgentAllowanceExhaustedExceptionImpl;

  factory AgentAllowanceExhaustedException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AgentAllowanceExhaustedException(
      message: jsonSerialization['message'] as String?,
    );
  }

  String message;

  /// Returns a shallow copy of this [AgentAllowanceExhaustedException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AgentAllowanceExhaustedException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentAllowanceExhaustedException',
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AgentAllowanceExhaustedException',
      'message': message,
    };
  }

  @override
  String toString() {
    return 'AgentAllowanceExhaustedException(message: $message)';
  }
}

class _AgentAllowanceExhaustedExceptionImpl
    extends AgentAllowanceExhaustedException {
  _AgentAllowanceExhaustedExceptionImpl({String? message})
    : super._(message: message);

  /// Returns a shallow copy of this [AgentAllowanceExhaustedException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AgentAllowanceExhaustedException copyWith({String? message}) {
    return AgentAllowanceExhaustedException(message: message ?? this.message);
  }
}
