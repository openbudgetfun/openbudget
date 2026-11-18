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

/// What an audit event records.
enum AuditAction implements _is.SerializableModel {
  ledgerEnabled,
  ledgerAccountCreated,
  ledgerAccountArchived,
  journalPosted,
  journalReversed,
  lockSet,

  /// A transaction in a ledger-mode entity was edited after posting.
  transactionEdited,

  /// A transaction in a ledger-mode entity was deleted after posting.
  transactionDeleted,

  /// The nightly check found and repaired a cached balance.
  balanceRepaired;

  static AuditAction fromJson(String name) {
    switch (name) {
      case 'ledgerEnabled':
        return AuditAction.ledgerEnabled;
      case 'ledgerAccountCreated':
        return AuditAction.ledgerAccountCreated;
      case 'ledgerAccountArchived':
        return AuditAction.ledgerAccountArchived;
      case 'journalPosted':
        return AuditAction.journalPosted;
      case 'journalReversed':
        return AuditAction.journalReversed;
      case 'lockSet':
        return AuditAction.lockSet;
      case 'transactionEdited':
        return AuditAction.transactionEdited;
      case 'transactionDeleted':
        return AuditAction.transactionDeleted;
      case 'balanceRepaired':
        return AuditAction.balanceRepaired;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "AuditAction"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
