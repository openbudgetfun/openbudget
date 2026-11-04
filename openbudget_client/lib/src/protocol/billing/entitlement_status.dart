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

/// Where a subscription is in its lifecycle on its payment rail.
enum EntitlementStatus implements _isc.SerializableModel {
  /// Paid through currentPeriodEnd.
  active,

  /// A renewal failed and the rail is retrying; access continues meanwhile.
  pastDue,

  /// The subscriber cancelled; access continues until currentPeriodEnd.
  canceled,

  /// The period ended without renewal; no access.
  expired;

  static EntitlementStatus fromJson(String name) {
    switch (name) {
      case 'active':
        return EntitlementStatus.active;
      case 'pastDue':
        return EntitlementStatus.pastDue;
      case 'canceled':
        return EntitlementStatus.canceled;
      case 'expired':
        return EntitlementStatus.expired;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "EntitlementStatus"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
