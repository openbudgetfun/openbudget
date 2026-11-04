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

/// A recurring/scheduled transaction template that generates transactions on a schedule.
abstract class RecurringTransaction
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RecurringTransaction._({
    this.id,
    required this.description,
    required this.amountCents,
    required this.currencyCode,
    this.envelopeId,
    required this.budgetId,
    this.accountId,
    this.payeeId,
    required this.frequency,
    required this.nextOccurrence,
    this.endDate,
    required this.isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory RecurringTransaction({
    _isc.UuidValue? id,
    required String description,
    required int amountCents,
    required String currencyCode,
    _isc.UuidValue? envelopeId,
    required _isc.UuidValue budgetId,
    _isc.UuidValue? accountId,
    _isc.UuidValue? payeeId,
    required String frequency,
    required DateTime nextOccurrence,
    DateTime? endDate,
    required bool isActive,
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
      description: jsonSerialization['description'] as String,
      amountCents: jsonSerialization['amountCents'] as int,
      currencyCode: jsonSerialization['currencyCode'] as String,
      envelopeId: jsonSerialization['envelopeId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['envelopeId'],
            ),
      budgetId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      accountId: jsonSerialization['accountId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['accountId'],
            ),
      payeeId: jsonSerialization['payeeId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['payeeId']),
      frequency: jsonSerialization['frequency'] as String,
      nextOccurrence: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['nextOccurrence'],
      ),
      endDate: jsonSerialization['endDate'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['endDate']),
      isActive: _isc.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
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

  String description;

  /// Amount in integer cents. Positive = inflow, negative = outflow.
  int amountCents;

  /// ISO 4217 currency code.
  String currencyCode;

  _isc.UuidValue? envelopeId;

  _isc.UuidValue budgetId;

  _isc.UuidValue? accountId;

  _isc.UuidValue? payeeId;

  /// Recurrence frequency: daily, weekly, biweekly, monthly, yearly.
  String frequency;

  /// The next date a transaction should be created.
  DateTime nextOccurrence;

  /// Optional end date after which no more transactions are generated.
  DateTime? endDate;

  /// Whether this recurring transaction is active.
  bool isActive;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [RecurringTransaction]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RecurringTransaction copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    String? description,
    int? amountCents,
    String? currencyCode,
    _isc.UuidValue? envelopeId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? budgetId,
    _isc.UuidValue? accountId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? payeeId = const _isc.$UndefinedUuidValue(),
    String? frequency,
    DateTime? nextOccurrence,
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
      'description': description,
      'amountCents': amountCents,
      'currencyCode': currencyCode,
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      'budgetId': budgetId.toJson(),
      if (accountId != null) 'accountId': accountId?.toJson(),
      if (payeeId != null) 'payeeId': payeeId?.toJson(),
      'frequency': frequency,
      'nextOccurrence': nextOccurrence.toJson(),
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
      'description': description,
      'amountCents': amountCents,
      'currencyCode': currencyCode,
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      'budgetId': budgetId.toJson(),
      if (accountId != null) 'accountId': accountId?.toJson(),
      if (payeeId != null) 'payeeId': payeeId?.toJson(),
      'frequency': frequency,
      'nextOccurrence': nextOccurrence.toJson(),
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

class _RecurringTransactionImpl extends RecurringTransaction {
  _RecurringTransactionImpl({
    _isc.UuidValue? id,
    required String description,
    required int amountCents,
    required String currencyCode,
    _isc.UuidValue? envelopeId,
    required _isc.UuidValue budgetId,
    _isc.UuidValue? accountId,
    _isc.UuidValue? payeeId,
    required String frequency,
    required DateTime nextOccurrence,
    DateTime? endDate,
    required bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         description: description,
         amountCents: amountCents,
         currencyCode: currencyCode,
         envelopeId: envelopeId,
         budgetId: budgetId,
         accountId: accountId,
         payeeId: payeeId,
         frequency: frequency,
         nextOccurrence: nextOccurrence,
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
    String? description,
    int? amountCents,
    String? currencyCode,
    _isc.UuidValue? envelopeId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? budgetId,
    _isc.UuidValue? accountId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? payeeId = const _isc.$UndefinedUuidValue(),
    String? frequency,
    DateTime? nextOccurrence,
    DateTime? endDate = const _isc.$UndefinedDateTime(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringTransaction(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      description: description ?? this.description,
      amountCents: amountCents ?? this.amountCents,
      currencyCode: currencyCode ?? this.currencyCode,
      envelopeId: envelopeId is _isc.UndefinedSentinel
          ? this.envelopeId
          : envelopeId,
      budgetId: budgetId ?? this.budgetId,
      accountId: accountId is _isc.UndefinedSentinel
          ? this.accountId
          : accountId,
      payeeId: payeeId is _isc.UndefinedSentinel ? this.payeeId : payeeId,
      frequency: frequency ?? this.frequency,
      nextOccurrence: nextOccurrence ?? this.nextOccurrence,
      endDate: endDate is _isc.UndefinedSentinel ? this.endDate : endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
