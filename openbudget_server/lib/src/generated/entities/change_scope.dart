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

/// Which part of an entity an EntityChangedEvent is about.
enum ChangeScope implements _is.SerializableModel {
  /// The entity row itself, its settings or its tax profile.
  entity,

  /// Accounts, balances or valuations.
  accounts,

  /// Transactions, transfers or lines. Balances and the plan may also change.
  transactions,

  /// Categories, envelopes, allocations, goals or templates.
  plan,

  /// Ledger accounts, journals or the lock date.
  ledger,

  /// Assistant proposals.
  proposals;

  static ChangeScope fromJson(String name) {
    switch (name) {
      case 'entity':
        return ChangeScope.entity;
      case 'accounts':
        return ChangeScope.accounts;
      case 'transactions':
        return ChangeScope.transactions;
      case 'plan':
        return ChangeScope.plan;
      case 'ledger':
        return ChangeScope.ledger;
      case 'proposals':
        return ChangeScope.proposals;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "ChangeScope"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
