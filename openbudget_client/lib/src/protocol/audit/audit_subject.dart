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

/// The kind of record an audit event is about.
enum AuditSubject implements _isc.SerializableModel {
  entity,
  account,
  transaction,
  ledgerAccount,
  journal,
  periodLock;

  static AuditSubject fromJson(String name) {
    switch (name) {
      case 'entity':
        return AuditSubject.entity;
      case 'account':
        return AuditSubject.account;
      case 'transaction':
        return AuditSubject.transaction;
      case 'ledgerAccount':
        return AuditSubject.ledgerAccount;
      case 'journal':
        return AuditSubject.journal;
      case 'periodLock':
        return AuditSubject.periodLock;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "AuditSubject"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
