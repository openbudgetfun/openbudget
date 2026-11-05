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

/// Thrown when no tax rule pack is available for a jurisdiction or year.
abstract class TaxRulesUnavailableException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  TaxRulesUnavailableException._({String? message})
    : message = message ?? 'Tax rules are not available';

  factory TaxRulesUnavailableException({String? message}) =
      _TaxRulesUnavailableExceptionImpl;

  factory TaxRulesUnavailableException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return TaxRulesUnavailableException(
      message: jsonSerialization['message'] as String?,
    );
  }

  String message;

  /// Returns a shallow copy of this [TaxRulesUnavailableException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TaxRulesUnavailableException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TaxRulesUnavailableException',
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TaxRulesUnavailableException',
      'message': message,
    };
  }

  @override
  String toString() {
    return 'TaxRulesUnavailableException(message: $message)';
  }
}

class _TaxRulesUnavailableExceptionImpl extends TaxRulesUnavailableException {
  _TaxRulesUnavailableExceptionImpl({String? message})
    : super._(message: message);

  /// Returns a shallow copy of this [TaxRulesUnavailableException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TaxRulesUnavailableException copyWith({String? message}) {
    return TaxRulesUnavailableException(message: message ?? this.message);
  }
}
