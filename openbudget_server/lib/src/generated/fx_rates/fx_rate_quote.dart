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

/// One currency's rate against the snapshot base.
abstract class FxRateQuote
    implements _is.SerializableModel, _is.ProtocolSerialization {
  FxRateQuote._({
    required this.currencyCode,
    required this.rate,
  });

  factory FxRateQuote({
    required String currencyCode,
    required String rate,
  }) = _FxRateQuoteImpl;

  factory FxRateQuote.fromJson(Map<String, dynamic> jsonSerialization) {
    return FxRateQuote(
      currencyCode: jsonSerialization['currencyCode'] as String,
      rate: jsonSerialization['rate'] as String,
    );
  }

  String currencyCode;

  /// Units of currencyCode per one unit of the base, exact decimal string.
  String rate;

  /// Returns a shallow copy of this [FxRateQuote]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FxRateQuote copyWith({
    String? currencyCode,
    String? rate,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FxRateQuote',
      'currencyCode': currencyCode,
      'rate': rate,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FxRateQuote',
      'currencyCode': currencyCode,
      'rate': rate,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _FxRateQuoteImpl extends FxRateQuote {
  _FxRateQuoteImpl({
    required String currencyCode,
    required String rate,
  }) : super._(
         currencyCode: currencyCode,
         rate: rate,
       );

  /// Returns a shallow copy of this [FxRateQuote]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FxRateQuote copyWith({
    String? currencyCode,
    String? rate,
  }) {
    return FxRateQuote(
      currencyCode: currencyCode ?? this.currencyCode,
      rate: rate ?? this.rate,
    );
  }
}
