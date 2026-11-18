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

/// What a transaction represents, beyond an ordinary movement.
enum TransactionKind implements _isc.SerializableModel {
  standard,

  /// The balance an account started with.
  openingBalance,

  /// A difference found while reconciling against a statement.
  balanceAdjustment,

  /// Recognises the change in base-currency value of a foreign-currency
  /// account. amountMinor is 0; baseAmountMinor carries the difference.
  fxRevaluation;

  static TransactionKind fromJson(String name) {
    switch (name) {
      case 'standard':
        return TransactionKind.standard;
      case 'openingBalance':
        return TransactionKind.openingBalance;
      case 'balanceAdjustment':
        return TransactionKind.balanceAdjustment;
      case 'fxRevaluation':
        return TransactionKind.fxRevaluation;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "TransactionKind"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
