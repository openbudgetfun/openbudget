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

/// How trustworthy a holding's price is right now.
enum PriceQuality implements _is.SerializableModel {
  /// Fresh from a provider.
  live,

  /// Computed rather than quoted.
  derived,

  /// A cached price used because the provider failed.
  cached,

  /// No price; the holding is left out of the valuation.
  unpriced;

  static PriceQuality fromJson(String name) {
    switch (name) {
      case 'live':
        return PriceQuality.live;
      case 'derived':
        return PriceQuality.derived;
      case 'cached':
        return PriceQuality.cached;
      case 'unpriced':
        return PriceQuality.unpriced;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "PriceQuality"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
