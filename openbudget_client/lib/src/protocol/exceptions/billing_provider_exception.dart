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

/// Thrown when a billing provider accepts a request but fails to complete it.
///
/// The details never contain response bodies or credentials.
abstract class BillingProviderException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  BillingProviderException._({
    required this.provider,
    this.details,
  });

  factory BillingProviderException({
    required String provider,
    String? details,
  }) = _BillingProviderExceptionImpl;

  factory BillingProviderException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return BillingProviderException(
      provider: jsonSerialization['provider'] as String,
      details: jsonSerialization['details'] as String?,
    );
  }

  /// The rail that failed: stripe, revenuecat or solana.
  String provider;

  String? details;

  /// Returns a shallow copy of this [BillingProviderException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  BillingProviderException copyWith({
    String? provider,
    String? details,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BillingProviderException',
      'provider': provider,
      if (details != null) 'details': details,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'BillingProviderException',
      'provider': provider,
      if (details != null) 'details': details,
    };
  }

  @override
  String toString() {
    return 'BillingProviderException(provider: $provider, details: $details)';
  }
}

class _Undefined {}

class _BillingProviderExceptionImpl extends BillingProviderException {
  _BillingProviderExceptionImpl({
    required String provider,
    String? details,
  }) : super._(
         provider: provider,
         details: details,
       );

  /// Returns a shallow copy of this [BillingProviderException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  BillingProviderException copyWith({
    String? provider,
    Object? details = _Undefined,
  }) {
    return BillingProviderException(
      provider: provider ?? this.provider,
      details: details is String? ? details : this.details,
    );
  }
}
