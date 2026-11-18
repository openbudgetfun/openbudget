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

/// What an account holds or owes.
///
/// Whether a kind is a liability, may be on budget, and which balance
/// sources it allows are rules in `AccountKindRules`, never stored.
enum AccountKind implements _iss.SerializableModel {
  cash,
  checking,
  savings,
  creditCard,
  loan,
  mortgage,
  investment,
  crypto,
  property,
  vehicle,
  otherAsset,
  otherLiability;

  static AccountKind fromJson(String name) {
    switch (name) {
      case 'cash':
        return AccountKind.cash;
      case 'checking':
        return AccountKind.checking;
      case 'savings':
        return AccountKind.savings;
      case 'creditCard':
        return AccountKind.creditCard;
      case 'loan':
        return AccountKind.loan;
      case 'mortgage':
        return AccountKind.mortgage;
      case 'investment':
        return AccountKind.investment;
      case 'crypto':
        return AccountKind.crypto;
      case 'property':
        return AccountKind.property;
      case 'vehicle':
        return AccountKind.vehicle;
      case 'otherAsset':
        return AccountKind.otherAsset;
      case 'otherLiability':
        return AccountKind.otherLiability;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "AccountKind"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
