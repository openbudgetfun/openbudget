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

/// Whether a holding is spendable now, or staked or unclaimed. Every
/// position counts toward net worth; the app shows them apart.
enum HoldingPosition implements _isc.SerializableModel {
  /// Spendable now.
  available,

  /// Staked, frozen or delegated: still owned, not spendable now.
  staked,

  /// Rewards earned but not yet claimed or withdrawn.
  unclaimedRewards;

  static HoldingPosition fromJson(String name) {
    switch (name) {
      case 'available':
        return HoldingPosition.available;
      case 'staked':
        return HoldingPosition.staked;
      case 'unclaimedRewards':
        return HoldingPosition.unclaimedRewards;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "HoldingPosition"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
