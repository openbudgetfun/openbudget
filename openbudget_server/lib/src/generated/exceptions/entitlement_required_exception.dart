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
import 'package:serverpod/serverpod.dart' as _is;

/// Thrown when a feature needs OpenBudget Plus and the user has no active
/// subscription.
abstract class EntitlementRequiredException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  EntitlementRequiredException._({String? message})
    : message = message ?? 'OpenBudget Plus is required';

  factory EntitlementRequiredException({String? message}) =
      _EntitlementRequiredExceptionImpl;

  factory EntitlementRequiredException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return EntitlementRequiredException(
      message: jsonSerialization['message'] as String?,
    );
  }

  String message;

  /// Returns a shallow copy of this [EntitlementRequiredException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  EntitlementRequiredException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EntitlementRequiredException',
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EntitlementRequiredException',
      'message': message,
    };
  }

  @override
  String toString() {
    return 'EntitlementRequiredException(message: $message)';
  }
}

class _EntitlementRequiredExceptionImpl extends EntitlementRequiredException {
  _EntitlementRequiredExceptionImpl({String? message})
    : super._(message: message);

  /// Returns a shallow copy of this [EntitlementRequiredException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  EntitlementRequiredException copyWith({String? message}) {
    return EntitlementRequiredException(message: message ?? this.message);
  }
}
