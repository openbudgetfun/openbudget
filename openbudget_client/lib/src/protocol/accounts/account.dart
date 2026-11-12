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

/// Somewhere money or value is held or owed: a bank account, card, loan,
/// wallet, house or car. Belongs to exactly one entity.
abstract class Account
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Account._({
    this.id,
    required this.entityId,
    required this.name,
    required this.kind,
    required this.currencyCode,
    required this.balanceSource,
    int? balanceMinor,
    bool? onBudget,
    this.institutionId,
    this.plaidConnectionId,
    this.plaidAccountId,
    this.reportedBalanceMinor,
    this.reportedBalanceAt,
    this.ledgerAccountId,
    this.reconciledThroughDate,
    this.note,
    int? sortOrder,
    this.closedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : balanceMinor = balanceMinor ?? 0,
       onBudget = onBudget ?? false,
       sortOrder = sortOrder ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Account({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required String name,
    required _ifz8weqz.AccountKind kind,
    required String currencyCode,
    required _ifz8weqz.AccountBalanceSource balanceSource,
    int? balanceMinor,
    bool? onBudget,
    _isc.UuidValue? institutionId,
    _isc.UuidValue? plaidConnectionId,
    String? plaidAccountId,
    int? reportedBalanceMinor,
    DateTime? reportedBalanceAt,
    _isc.UuidValue? ledgerAccountId,
    DateTime? reconciledThroughDate,
    String? note,
    int? sortOrder,
    DateTime? closedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AccountImpl;

  factory Account.fromJson(Map<String, dynamic> jsonSerialization) {
    return Account(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      name: jsonSerialization['name'] as String,
      kind: _ifz8weqz.AccountKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      currencyCode: jsonSerialization['currencyCode'] as String,
      balanceSource: _ifz8weqz.AccountBalanceSource.fromJson(
        (jsonSerialization['balanceSource'] as String),
      ),
      balanceMinor: jsonSerialization['balanceMinor'] as int?,
      onBudget: jsonSerialization['onBudget'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['onBudget']),
      institutionId: jsonSerialization['institutionId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['institutionId'],
            ),
      plaidConnectionId: jsonSerialization['plaidConnectionId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['plaidConnectionId'],
            ),
      plaidAccountId: jsonSerialization['plaidAccountId'] as String?,
      reportedBalanceMinor: jsonSerialization['reportedBalanceMinor'] as int?,
      reportedBalanceAt: jsonSerialization['reportedBalanceAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['reportedBalanceAt'],
            ),
      ledgerAccountId: jsonSerialization['ledgerAccountId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['ledgerAccountId'],
            ),
      reconciledThroughDate: jsonSerialization['reconciledThroughDate'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['reconciledThroughDate'],
            ),
      note: jsonSerialization['note'] as String?,
      sortOrder: jsonSerialization['sortOrder'] as int?,
      closedAt: jsonSerialization['closedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['closedAt']),
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

  String name;

  _ifz8weqz.AccountKind kind;

  /// ISO 4217 code. Every transaction and valuation amount on the account is
  /// in this currency. Fixed after creation.
  String currencyCode;

  /// Fixed after creation.
  _ifz8weqz.AccountBalanceSource balanceSource;

  /// Cached current balance in account-currency minor units, signed:
  /// positive is owned, negative is owed. Equals the sum of the account's
  /// transaction amounts, or its latest valuation. Written only by
  /// `AccountBalanceService`.
  int balanceMinor;

  /// Whether the account's money is in the envelope plan.
  bool onBudget;

  _isc.UuidValue? institutionId;

  _isc.UuidValue? plaidConnectionId;

  /// Plaid `account_id`, when linked through Plaid.
  String? plaidAccountId;

  /// Balance the institution last reported, in account minor units. Shown to
  /// prompt a reconciliation; never used for budgeting or net worth.
  int? reportedBalanceMinor;

  DateTime? reportedBalanceAt;

  /// The ledger account that mirrors this account in ledger-mode books.
  _isc.UuidValue? ledgerAccountId;

  /// Statement date of the last completed reconciliation.
  DateTime? reconciledThroughDate;

  String? note;

  int sortOrder;

  DateTime? closedAt;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [Account]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Account copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    String? name,
    _ifz8weqz.AccountKind? kind,
    String? currencyCode,
    _ifz8weqz.AccountBalanceSource? balanceSource,
    int? balanceMinor,
    bool? onBudget,
    _isc.UuidValue? institutionId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? plaidConnectionId = const _isc.$UndefinedUuidValue(),
    String? plaidAccountId,
    int? reportedBalanceMinor,
    DateTime? reportedBalanceAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? ledgerAccountId = const _isc.$UndefinedUuidValue(),
    DateTime? reconciledThroughDate = const _isc.$UndefinedDateTime(),
    String? note,
    int? sortOrder,
    DateTime? closedAt = const _isc.$UndefinedDateTime(),
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Account',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'name': name,
      'kind': kind.toJson(),
      'currencyCode': currencyCode,
      'balanceSource': balanceSource.toJson(),
      'balanceMinor': balanceMinor,
      'onBudget': onBudget,
      if (institutionId != null) 'institutionId': institutionId?.toJson(),
      if (plaidConnectionId != null)
        'plaidConnectionId': plaidConnectionId?.toJson(),
      if (plaidAccountId != null) 'plaidAccountId': plaidAccountId,
      if (reportedBalanceMinor != null)
        'reportedBalanceMinor': reportedBalanceMinor,
      if (reportedBalanceAt != null)
        'reportedBalanceAt': reportedBalanceAt?.toJson(),
      if (ledgerAccountId != null) 'ledgerAccountId': ledgerAccountId?.toJson(),
      if (reconciledThroughDate != null)
        'reconciledThroughDate': reconciledThroughDate?.toJson(),
      if (note != null) 'note': note,
      'sortOrder': sortOrder,
      if (closedAt != null) 'closedAt': closedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Account',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'name': name,
      'kind': kind.toJson(),
      'currencyCode': currencyCode,
      'balanceSource': balanceSource.toJson(),
      'balanceMinor': balanceMinor,
      'onBudget': onBudget,
      if (institutionId != null) 'institutionId': institutionId?.toJson(),
      if (plaidConnectionId != null)
        'plaidConnectionId': plaidConnectionId?.toJson(),
      if (plaidAccountId != null) 'plaidAccountId': plaidAccountId,
      if (reportedBalanceMinor != null)
        'reportedBalanceMinor': reportedBalanceMinor,
      if (reportedBalanceAt != null)
        'reportedBalanceAt': reportedBalanceAt?.toJson(),
      if (ledgerAccountId != null) 'ledgerAccountId': ledgerAccountId?.toJson(),
      if (reconciledThroughDate != null)
        'reconciledThroughDate': reconciledThroughDate?.toJson(),
      if (note != null) 'note': note,
      'sortOrder': sortOrder,
      if (closedAt != null) 'closedAt': closedAt?.toJson(),
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

class _AccountImpl extends Account {
  _AccountImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required String name,
    required _ifz8weqz.AccountKind kind,
    required String currencyCode,
    required _ifz8weqz.AccountBalanceSource balanceSource,
    int? balanceMinor,
    bool? onBudget,
    _isc.UuidValue? institutionId,
    _isc.UuidValue? plaidConnectionId,
    String? plaidAccountId,
    int? reportedBalanceMinor,
    DateTime? reportedBalanceAt,
    _isc.UuidValue? ledgerAccountId,
    DateTime? reconciledThroughDate,
    String? note,
    int? sortOrder,
    DateTime? closedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         entityId: entityId,
         name: name,
         kind: kind,
         currencyCode: currencyCode,
         balanceSource: balanceSource,
         balanceMinor: balanceMinor,
         onBudget: onBudget,
         institutionId: institutionId,
         plaidConnectionId: plaidConnectionId,
         plaidAccountId: plaidAccountId,
         reportedBalanceMinor: reportedBalanceMinor,
         reportedBalanceAt: reportedBalanceAt,
         ledgerAccountId: ledgerAccountId,
         reconciledThroughDate: reconciledThroughDate,
         note: note,
         sortOrder: sortOrder,
         closedAt: closedAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Account]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Account copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    String? name,
    _ifz8weqz.AccountKind? kind,
    String? currencyCode,
    _ifz8weqz.AccountBalanceSource? balanceSource,
    int? balanceMinor,
    bool? onBudget,
    _isc.UuidValue? institutionId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? plaidConnectionId = const _isc.$UndefinedUuidValue(),
    Object? plaidAccountId = _Undefined,
    Object? reportedBalanceMinor = _Undefined,
    DateTime? reportedBalanceAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? ledgerAccountId = const _isc.$UndefinedUuidValue(),
    DateTime? reconciledThroughDate = const _isc.$UndefinedDateTime(),
    Object? note = _Undefined,
    int? sortOrder,
    DateTime? closedAt = const _isc.$UndefinedDateTime(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      currencyCode: currencyCode ?? this.currencyCode,
      balanceSource: balanceSource ?? this.balanceSource,
      balanceMinor: balanceMinor ?? this.balanceMinor,
      onBudget: onBudget ?? this.onBudget,
      institutionId: institutionId is _isc.UndefinedSentinel
          ? this.institutionId
          : institutionId,
      plaidConnectionId: plaidConnectionId is _isc.UndefinedSentinel
          ? this.plaidConnectionId
          : plaidConnectionId,
      plaidAccountId: plaidAccountId is String?
          ? plaidAccountId
          : this.plaidAccountId,
      reportedBalanceMinor: reportedBalanceMinor is int?
          ? reportedBalanceMinor
          : this.reportedBalanceMinor,
      reportedBalanceAt: reportedBalanceAt is _isc.UndefinedSentinel
          ? this.reportedBalanceAt
          : reportedBalanceAt,
      ledgerAccountId: ledgerAccountId is _isc.UndefinedSentinel
          ? this.ledgerAccountId
          : ledgerAccountId,
      reconciledThroughDate: reconciledThroughDate is _isc.UndefinedSentinel
          ? this.reconciledThroughDate
          : reconciledThroughDate,
      note: note is String? ? note : this.note,
      sortOrder: sortOrder ?? this.sortOrder,
      closedAt: closedAt is _isc.UndefinedSentinel ? this.closedAt : closedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
