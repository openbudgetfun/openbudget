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

/// The stable internal role of a structural ledger account. At most one
/// account per role per entity; system accounts cannot be archived.
enum LedgerSystemRole implements _iss.SerializableModel {
  bank,
  accountsReceivable,
  accountsPayable,
  vatControl,
  payrollLiabilities,
  directorsLoan,
  retainedEarnings,
  openingBalanceEquity,
  suspense,
  rounding,
  realisedFx,
  unrealisedFx,
  ownerDrawings,

  /// Clears the two legs of a transfer between the entity's own accounts.
  bankClearing;

  static LedgerSystemRole fromJson(String name) {
    switch (name) {
      case 'bank':
        return LedgerSystemRole.bank;
      case 'accountsReceivable':
        return LedgerSystemRole.accountsReceivable;
      case 'accountsPayable':
        return LedgerSystemRole.accountsPayable;
      case 'vatControl':
        return LedgerSystemRole.vatControl;
      case 'payrollLiabilities':
        return LedgerSystemRole.payrollLiabilities;
      case 'directorsLoan':
        return LedgerSystemRole.directorsLoan;
      case 'retainedEarnings':
        return LedgerSystemRole.retainedEarnings;
      case 'openingBalanceEquity':
        return LedgerSystemRole.openingBalanceEquity;
      case 'suspense':
        return LedgerSystemRole.suspense;
      case 'rounding':
        return LedgerSystemRole.rounding;
      case 'realisedFx':
        return LedgerSystemRole.realisedFx;
      case 'unrealisedFx':
        return LedgerSystemRole.unrealisedFx;
      case 'ownerDrawings':
        return LedgerSystemRole.ownerDrawings;
      case 'bankClearing':
        return LedgerSystemRole.bankClearing;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "LedgerSystemRole"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
