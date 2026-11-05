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

/// The per-budget period lock date.
///
/// Posting or reversing into a date on or before [lockDate] is rejected.
/// Every change writes a `ledger_audit_event`, so the lock's history lives
/// in the audit trail rather than in append-only lock rows.
abstract class LedgerPeriodLock
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  LedgerPeriodLock._({
    this.id,
    required this.budgetId,
    required this.lockDate,
    required this.setBy,
    DateTime? setAt,
  }) : setAt = setAt ?? DateTime.now();

  factory LedgerPeriodLock({
    _isc.UuidValue? id,
    required _isc.UuidValue budgetId,
    required DateTime lockDate,
    required _isc.UuidValue setBy,
    DateTime? setAt,
  }) = _LedgerPeriodLockImpl;

  factory LedgerPeriodLock.fromJson(Map<String, dynamic> jsonSerialization) {
    return LedgerPeriodLock(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      budgetId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      lockDate: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['lockDate'],
      ),
      setBy: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['setBy']),
      setAt: jsonSerialization['setAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['setAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue budgetId;

  /// Dates on or before this date are locked.
  DateTime lockDate;

  /// The user who set the lock.
  _isc.UuidValue setBy;

  DateTime setAt;

  /// Returns a shallow copy of this [LedgerPeriodLock]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  LedgerPeriodLock copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? budgetId,
    DateTime? lockDate,
    _isc.UuidValue? setBy,
    DateTime? setAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LedgerPeriodLock',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'lockDate': lockDate.toJson(),
      'setBy': setBy.toJson(),
      'setAt': setAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LedgerPeriodLock',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'lockDate': lockDate.toJson(),
      'setBy': setBy.toJson(),
      'setAt': setAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _LedgerPeriodLockImpl extends LedgerPeriodLock {
  _LedgerPeriodLockImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue budgetId,
    required DateTime lockDate,
    required _isc.UuidValue setBy,
    DateTime? setAt,
  }) : super._(
         id: id,
         budgetId: budgetId,
         lockDate: lockDate,
         setBy: setBy,
         setAt: setAt,
       );

  /// Returns a shallow copy of this [LedgerPeriodLock]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  LedgerPeriodLock copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? budgetId,
    DateTime? lockDate,
    _isc.UuidValue? setBy,
    DateTime? setAt,
  }) {
    return LedgerPeriodLock(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      budgetId: budgetId ?? this.budgetId,
      lockDate: lockDate ?? this.lockDate,
      setBy: setBy ?? this.setBy,
      setAt: setAt ?? this.setAt,
    );
  }
}
