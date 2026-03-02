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
import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// A financial account within a budget (checking, savings, credit card, cash, etc.).
abstract class Account implements _i1.SerializableModel {
  Account._({
    this.id,
    required this.name,
    required this.accountType,
    required this.balanceCents,
    required this.currencyCode,
    required this.budgetId,
    this.creatorId,
    this.institutionId,
    required this.onBudget,
    required this.sortOrder,
    required this.isClosed,
    this.sourceType,
    this.externalAccountId,
    this.connectionId,
    this.lastSyncedAt,
    this.syncStatus,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Account({
    _i1.UuidValue? id,
    required String name,
    required String accountType,
    required int balanceCents,
    required String currencyCode,
    required _i1.UuidValue budgetId,
    _i1.UuidValue? creatorId,
    _i1.UuidValue? institutionId,
    required bool onBudget,
    required int sortOrder,
    required bool isClosed,
    String? sourceType,
    String? externalAccountId,
    _i1.UuidValue? connectionId,
    DateTime? lastSyncedAt,
    String? syncStatus,
    DateTime? createdAt,
  }) = _AccountImpl;

  factory Account.fromJson(Map<String, dynamic> jsonSerialization) {
    return Account(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      accountType: jsonSerialization['accountType'] as String,
      balanceCents: jsonSerialization['balanceCents'] as int,
      currencyCode: jsonSerialization['currencyCode'] as String,
      budgetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      creatorId: jsonSerialization['creatorId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['creatorId']),
      institutionId: jsonSerialization['institutionId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['institutionId'],
            ),
      onBudget: jsonSerialization['onBudget'] as bool,
      sortOrder: jsonSerialization['sortOrder'] as int,
      isClosed: jsonSerialization['isClosed'] as bool,
      sourceType: jsonSerialization['sourceType'] as String?,
      externalAccountId: jsonSerialization['externalAccountId'] as String?,
      connectionId: jsonSerialization['connectionId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['connectionId'],
            ),
      lastSyncedAt: jsonSerialization['lastSyncedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncedAt'],
            ),
      syncStatus: jsonSerialization['syncStatus'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  String name;

  /// Account type: checking, savings, creditCard, cash, investment, other.
  String accountType;

  /// Current balance in integer cents.
  int balanceCents;

  /// ISO 4217 currency code.
  String currencyCode;

  _i1.UuidValue budgetId;

  /// The authenticated user that created this account record.
  _i1.UuidValue? creatorId;

  /// Optional linked financial institution for this account.
  _i1.UuidValue? institutionId;

  /// Whether this account is included in the budget's "on budget" calculations.
  bool onBudget;

  /// Sort order for display.
  int sortOrder;

  /// Whether this account has been closed/archived.
  bool isClosed;

  /// Source of account data: manual, plaid, solana.
  String? sourceType;

  /// External source account identifier (e.g. Plaid account_id or wallet address).
  String? externalAccountId;

  /// Connection identifier used by external account sync providers.
  _i1.UuidValue? connectionId;

  /// Last time the account was synchronized from an external provider.
  DateTime? lastSyncedAt;

  /// Latest sync status for the account (e.g. synced, stale, error).
  String? syncStatus;

  DateTime createdAt;

  /// Returns a shallow copy of this [Account]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Account copyWith({
    _i1.UuidValue? id,
    String? name,
    String? accountType,
    int? balanceCents,
    String? currencyCode,
    _i1.UuidValue? budgetId,
    _i1.UuidValue? creatorId,
    _i1.UuidValue? institutionId,
    bool? onBudget,
    int? sortOrder,
    bool? isClosed,
    String? sourceType,
    String? externalAccountId,
    _i1.UuidValue? connectionId,
    DateTime? lastSyncedAt,
    String? syncStatus,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Account',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'accountType': accountType,
      'balanceCents': balanceCents,
      'currencyCode': currencyCode,
      'budgetId': budgetId.toJson(),
      if (creatorId != null) 'creatorId': creatorId?.toJson(),
      if (institutionId != null) 'institutionId': institutionId?.toJson(),
      'onBudget': onBudget,
      'sortOrder': sortOrder,
      'isClosed': isClosed,
      if (sourceType != null) 'sourceType': sourceType,
      if (externalAccountId != null) 'externalAccountId': externalAccountId,
      if (connectionId != null) 'connectionId': connectionId?.toJson(),
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
      if (syncStatus != null) 'syncStatus': syncStatus,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountImpl extends Account {
  _AccountImpl({
    _i1.UuidValue? id,
    required String name,
    required String accountType,
    required int balanceCents,
    required String currencyCode,
    required _i1.UuidValue budgetId,
    _i1.UuidValue? creatorId,
    _i1.UuidValue? institutionId,
    required bool onBudget,
    required int sortOrder,
    required bool isClosed,
    String? sourceType,
    String? externalAccountId,
    _i1.UuidValue? connectionId,
    DateTime? lastSyncedAt,
    String? syncStatus,
    DateTime? createdAt,
  }) : super._(
         id: id,
         name: name,
         accountType: accountType,
         balanceCents: balanceCents,
         currencyCode: currencyCode,
         budgetId: budgetId,
         creatorId: creatorId,
         institutionId: institutionId,
         onBudget: onBudget,
         sortOrder: sortOrder,
         isClosed: isClosed,
         sourceType: sourceType,
         externalAccountId: externalAccountId,
         connectionId: connectionId,
         lastSyncedAt: lastSyncedAt,
         syncStatus: syncStatus,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Account]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Account copyWith({
    Object? id = _Undefined,
    String? name,
    String? accountType,
    int? balanceCents,
    String? currencyCode,
    _i1.UuidValue? budgetId,
    Object? creatorId = _Undefined,
    Object? institutionId = _Undefined,
    bool? onBudget,
    int? sortOrder,
    bool? isClosed,
    Object? sourceType = _Undefined,
    Object? externalAccountId = _Undefined,
    Object? connectionId = _Undefined,
    Object? lastSyncedAt = _Undefined,
    Object? syncStatus = _Undefined,
    DateTime? createdAt,
  }) {
    return Account(
      id: id is _i1.UuidValue? ? id : this.id,
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      balanceCents: balanceCents ?? this.balanceCents,
      currencyCode: currencyCode ?? this.currencyCode,
      budgetId: budgetId ?? this.budgetId,
      creatorId: creatorId is _i1.UuidValue? ? creatorId : this.creatorId,
      institutionId: institutionId is _i1.UuidValue?
          ? institutionId
          : this.institutionId,
      onBudget: onBudget ?? this.onBudget,
      sortOrder: sortOrder ?? this.sortOrder,
      isClosed: isClosed ?? this.isClosed,
      sourceType: sourceType is String? ? sourceType : this.sourceType,
      externalAccountId: externalAccountId is String?
          ? externalAccountId
          : this.externalAccountId,
      connectionId: connectionId is _i1.UuidValue?
          ? connectionId
          : this.connectionId,
      lastSyncedAt: lastSyncedAt is DateTime?
          ? lastSyncedAt
          : this.lastSyncedAt,
      syncStatus: syncStatus is String? ? syncStatus : this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
