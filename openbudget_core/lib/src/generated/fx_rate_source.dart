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
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;

/// Where a stored exchange rate came from.
enum FxRateSource implements _iss.SerializableModel {
  /// Same currency; the rate is exactly 1.
  identity,

  /// The daily provider rate from `fx_rate`.
  market,

  /// Implied by the two amounts that actually moved in a transfer.
  implied,

  /// Entered by the user.
  manual;

  static FxRateSource fromJson(String name) {
    switch (name) {
      case 'identity':
        return FxRateSource.identity;
      case 'market':
        return FxRateSource.market;
      case 'implied':
        return FxRateSource.implied;
      case 'manual':
        return FxRateSource.manual;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "FxRateSource"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
