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

import '../accounts/valuation_source.dart' as _iglrpvk1;

/// The value of an account from a calendar date onwards, for accounts whose
/// balance comes from valuations (a house, a car, a brokerage, a wallet).
abstract class AccountValuation
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AccountValuation._({
    this.id,
    required this.accountId,
    required this.valuationDate,
    required this.valueMinor,
    required this.source,
    this.note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory AccountValuation({
    _isc.UuidValue? id,
    required _isc.UuidValue accountId,
    required DateTime valuationDate,
    required int valueMinor,
    required _iglrpvk1.ValuationSource source,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AccountValuationImpl;

  factory AccountValuation.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccountValuation(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      accountId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountId'],
      ),
      valuationDate: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['valuationDate'],
      ),
      valueMinor: jsonSerialization['valueMinor'] as int,
      source: _iglrpvk1.ValuationSource.fromJson(
        (jsonSerialization['source'] as String),
      ),
      note: jsonSerialization['note'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue accountId;

  /// Calendar date the value applies from.
  DateTime valuationDate;

  /// Value in account-currency minor units, signed like Account.balanceMinor.
  int valueMinor;

  _iglrpvk1.ValuationSource source;

  String? note;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [AccountValuation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AccountValuation copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? accountId,
    DateTime? valuationDate,
    int? valueMinor,
    _iglrpvk1.ValuationSource? source,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AccountValuation',
      if (id != null) 'id': id?.toJson(),
      'accountId': accountId.toJson(),
      'valuationDate': valuationDate.toJson(),
      'valueMinor': valueMinor,
      'source': source.toJson(),
      if (note != null) 'note': note,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AccountValuation',
      if (id != null) 'id': id?.toJson(),
      'accountId': accountId.toJson(),
      'valuationDate': valuationDate.toJson(),
      'valueMinor': valueMinor,
      'source': source.toJson(),
      if (note != null) 'note': note,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountValuationImpl extends AccountValuation {
  _AccountValuationImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue accountId,
    required DateTime valuationDate,
    required int valueMinor,
    required _iglrpvk1.ValuationSource source,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         accountId: accountId,
         valuationDate: valuationDate,
         valueMinor: valueMinor,
         source: source,
         note: note,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AccountValuation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AccountValuation copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? accountId,
    DateTime? valuationDate,
    int? valueMinor,
    _iglrpvk1.ValuationSource? source,
    Object? note = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountValuation(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      accountId: accountId ?? this.accountId,
      valuationDate: valuationDate ?? this.valuationDate,
      valueMinor: valueMinor ?? this.valueMinor,
      source: source ?? this.source,
      note: note is String? ? note : this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
