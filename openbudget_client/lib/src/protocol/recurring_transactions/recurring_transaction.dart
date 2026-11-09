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
import 'package:openbudget_core/openbudget_core.dart' as _ifz8weqz;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// A schedule that creates a transaction on each due date.
abstract class RecurringTransaction
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RecurringTransaction._({
    this.id,
    required this.entityId,
    required this.accountId,
    this.payeeId,
    this.envelopeId,
    required this.description,
    this.memo,
    required this.amountMinor,
    required this.frequency,
    required this.nextDate,
    this.endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : isActive = isActive ?? true,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory RecurringTransaction({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required _isc.UuidValue accountId,
    _isc.UuidValue? payeeId,
    _isc.UuidValue? envelopeId,
    required String description,
    String? memo,
    required int amountMinor,
    required _ifz8weqz.RecurrenceFrequency frequency,
    required DateTime nextDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _RecurringTransactionImpl;

  factory RecurringTransaction.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return RecurringTransaction(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      accountId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountId'],
      ),
      payeeId: jsonSerialization['payeeId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['payeeId']),
      envelopeId: jsonSerialization['envelopeId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['envelopeId'],
            ),
      description: jsonSerialization['description'] as String,
      memo: jsonSerialization['memo'] as String?,
      amountMinor: jsonSerialization['amountMinor'] as int,
      frequency: _ifz8weqz.RecurrenceFrequency.fromJson(
        (jsonSerialization['frequency'] as String),
      ),
      nextDate: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['nextDate'],
      ),
      endDate: jsonSerialization['endDate'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['endDate']),
      isActive: jsonSerialization['isActive'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
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

  _isc.UuidValue entityId;

  _isc.UuidValue accountId;

  _isc.UuidValue? payeeId;

  _isc.UuidValue? envelopeId;

  String description;

  String? memo;

  /// Signed amount in account-currency minor units.
  int amountMinor;

  _ifz8weqz.RecurrenceFrequency frequency;

  /// Calendar date of the next transaction to create.
  DateTime nextDate;

  /// Calendar date after which nothing more is created.
  DateTime? endDate;

  bool isActive;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [RecurringTransaction]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RecurringTransaction copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    _isc.UuidValue? accountId,
    _isc.UuidValue? payeeId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? envelopeId = const _isc.$UndefinedUuidValue(),
    String? description,
    String? memo,
    int? amountMinor,
    _ifz8weqz.RecurrenceFrequency? frequency,
    DateTime? nextDate,
    DateTime? endDate = const _isc.$UndefinedDateTime(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RecurringTransaction',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'accountId': accountId.toJson(),
      if (payeeId != null) 'payeeId': payeeId?.toJson(),
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      'description': description,
      if (memo != null) 'memo': memo,
      'amountMinor': amountMinor,
      'frequency': frequency.toJson(),
      'nextDate': nextDate.toJson(),
      if (endDate != null) 'endDate': endDate?.toJson(),
      'isActive': isActive,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RecurringTransaction',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'accountId': accountId.toJson(),
      if (payeeId != null) 'payeeId': payeeId?.toJson(),
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      'description': description,
      if (memo != null) 'memo': memo,
      'amountMinor': amountMinor,
      'frequency': frequency.toJson(),
      'nextDate': nextDate.toJson(),
      if (endDate != null) 'endDate': endDate?.toJson(),
      'isActive': isActive,
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

class _RecurringTransactionImpl extends RecurringTransaction {
  _RecurringTransactionImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required _isc.UuidValue accountId,
    _isc.UuidValue? payeeId,
    _isc.UuidValue? envelopeId,
    required String description,
    String? memo,
    required int amountMinor,
    required _ifz8weqz.RecurrenceFrequency frequency,
    required DateTime nextDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         entityId: entityId,
         accountId: accountId,
         payeeId: payeeId,
         envelopeId: envelopeId,
         description: description,
         memo: memo,
         amountMinor: amountMinor,
         frequency: frequency,
         nextDate: nextDate,
         endDate: endDate,
         isActive: isActive,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [RecurringTransaction]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RecurringTransaction copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    _isc.UuidValue? accountId,
    _isc.UuidValue? payeeId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? envelopeId = const _isc.$UndefinedUuidValue(),
    String? description,
    Object? memo = _Undefined,
    int? amountMinor,
    _ifz8weqz.RecurrenceFrequency? frequency,
    DateTime? nextDate,
    DateTime? endDate = const _isc.$UndefinedDateTime(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringTransaction(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      accountId: accountId ?? this.accountId,
      payeeId: payeeId is _isc.UndefinedSentinel ? this.payeeId : payeeId,
      envelopeId: envelopeId is _isc.UndefinedSentinel
          ? this.envelopeId
          : envelopeId,
      description: description ?? this.description,
      memo: memo is String? ? memo : this.memo,
      amountMinor: amountMinor ?? this.amountMinor,
      frequency: frequency ?? this.frequency,
      nextDate: nextDate ?? this.nextDate,
      endDate: endDate is _isc.UndefinedSentinel ? this.endDate : endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
