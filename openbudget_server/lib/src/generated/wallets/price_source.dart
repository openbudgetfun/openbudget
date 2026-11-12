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

/// Which pricing source valued a holding.
enum PriceSource implements _is.SerializableModel {
  helius,
  jupiter,
  magicEden,

  /// Computed from a related asset or pool.
  derived;

  static PriceSource fromJson(String name) {
    switch (name) {
      case 'helius':
        return PriceSource.helius;
      case 'jupiter':
        return PriceSource.jupiter;
      case 'magicEden':
        return PriceSource.magicEden;
      case 'derived':
        return PriceSource.derived;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "PriceSource"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
