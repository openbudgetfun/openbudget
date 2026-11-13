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
import 'package:openbudget_core/openbudget_core.dart' as _ifz8weqz;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// What one network exposed about one address during a preview.
abstract class WalletPreviewNetwork
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  WalletPreviewNetwork._({
    required this.network,
    required this.holdingCount,
    required this.pricedHoldingCount,
    this.valueMinor,
    this.valueCurrencyCode,
    this.readError,
  });

  factory WalletPreviewNetwork({
    required _ifz8weqz.WalletNetwork network,
    required int holdingCount,
    required int pricedHoldingCount,
    int? valueMinor,
    String? valueCurrencyCode,
    String? readError,
  }) = _WalletPreviewNetworkImpl;

  factory WalletPreviewNetwork.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return WalletPreviewNetwork(
      network: _ifz8weqz.WalletNetwork.fromJson(
        (jsonSerialization['network'] as String),
      ),
      holdingCount: jsonSerialization['holdingCount'] as int,
      pricedHoldingCount: jsonSerialization['pricedHoldingCount'] as int,
      valueMinor: jsonSerialization['valueMinor'] as int?,
      valueCurrencyCode: jsonSerialization['valueCurrencyCode'] as String?,
      readError: jsonSerialization['readError'] as String?,
    );
  }

  _ifz8weqz.WalletNetwork network;

  /// Every holding the provider reported on this network, priced or not.
  int holdingCount;

  /// The holdings that carry a price, which the picker can total.
  int pricedHoldingCount;

  /// Sum of the priced holdings, in valueCurrencyCode minor units. Null when
  /// nothing was priced.
  int? valueMinor;

  String? valueCurrencyCode;

  /// Why this network could not be read, in plain words. Null when it read.
  String? readError;

  /// Returns a shallow copy of this [WalletPreviewNetwork]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  WalletPreviewNetwork copyWith({
    _ifz8weqz.WalletNetwork? network,
    int? holdingCount,
    int? pricedHoldingCount,
    int? valueMinor,
    String? valueCurrencyCode,
    String? readError,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WalletPreviewNetwork',
      'network': network.toJson(),
      'holdingCount': holdingCount,
      'pricedHoldingCount': pricedHoldingCount,
      if (valueMinor != null) 'valueMinor': valueMinor,
      if (valueCurrencyCode != null) 'valueCurrencyCode': valueCurrencyCode,
      if (readError != null) 'readError': readError,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WalletPreviewNetwork',
      'network': network.toJson(),
      'holdingCount': holdingCount,
      'pricedHoldingCount': pricedHoldingCount,
      if (valueMinor != null) 'valueMinor': valueMinor,
      if (valueCurrencyCode != null) 'valueCurrencyCode': valueCurrencyCode,
      if (readError != null) 'readError': readError,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WalletPreviewNetworkImpl extends WalletPreviewNetwork {
  _WalletPreviewNetworkImpl({
    required _ifz8weqz.WalletNetwork network,
    required int holdingCount,
    required int pricedHoldingCount,
    int? valueMinor,
    String? valueCurrencyCode,
    String? readError,
  }) : super._(
         network: network,
         holdingCount: holdingCount,
         pricedHoldingCount: pricedHoldingCount,
         valueMinor: valueMinor,
         valueCurrencyCode: valueCurrencyCode,
         readError: readError,
       );

  /// Returns a shallow copy of this [WalletPreviewNetwork]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  WalletPreviewNetwork copyWith({
    _ifz8weqz.WalletNetwork? network,
    int? holdingCount,
    int? pricedHoldingCount,
    Object? valueMinor = _Undefined,
    Object? valueCurrencyCode = _Undefined,
    Object? readError = _Undefined,
  }) {
    return WalletPreviewNetwork(
      network: network ?? this.network,
      holdingCount: holdingCount ?? this.holdingCount,
      pricedHoldingCount: pricedHoldingCount ?? this.pricedHoldingCount,
      valueMinor: valueMinor is int? ? valueMinor : this.valueMinor,
      valueCurrencyCode: valueCurrencyCode is String?
          ? valueCurrencyCode
          : this.valueCurrencyCode,
      readError: readError is String? ? readError : this.readError,
    );
  }
}
