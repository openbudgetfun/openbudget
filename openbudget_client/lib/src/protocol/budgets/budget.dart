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

/// A budget owned by a user, representing a financial plan in a specific currency.
abstract class Budget
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Budget._({
    this.id,
    required this.name,
    required this.currencyCode,
    this.displayCurrencyCode,
    required this.ownerId,
    String? accountingMode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : accountingMode = accountingMode ?? 'envelope',
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Budget({
    _isc.UuidValue? id,
    required String name,
    required String currencyCode,
    String? displayCurrencyCode,
    required _isc.UuidValue ownerId,
    String? accountingMode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BudgetImpl;

  factory Budget.fromJson(Map<String, dynamic> jsonSerialization) {
    return Budget(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      currencyCode: jsonSerialization['currencyCode'] as String,
      displayCurrencyCode: jsonSerialization['displayCurrencyCode'] as String?,
      ownerId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['ownerId'],
      ),
      accountingMode: jsonSerialization['accountingMode'] as String?,
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

  String name;

  /// ISO 4217 currency code (e.g. USD, EUR).
  String currencyCode;

  /// Optional display currency override for aggregated/reporting views.
  /// If null, the budget's native currencyCode is used for display.
  String? displayCurrencyCode;

  /// The user who owns this budget.
  _isc.UuidValue ownerId;

  /// AccountingMode name: `envelope` (default) or `ledger`. Only sole-trader
  /// and company budgets may switch to `ledger`, and switching back is not
  /// supported.
  String accountingMode;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [Budget]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Budget copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    String? name,
    String? currencyCode,
    String? displayCurrencyCode,
    _isc.UuidValue? ownerId,
    String? accountingMode,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Budget',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'currencyCode': currencyCode,
      if (displayCurrencyCode != null)
        'displayCurrencyCode': displayCurrencyCode,
      'ownerId': ownerId.toJson(),
      'accountingMode': accountingMode,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Budget',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'currencyCode': currencyCode,
      if (displayCurrencyCode != null)
        'displayCurrencyCode': displayCurrencyCode,
      'ownerId': ownerId.toJson(),
      'accountingMode': accountingMode,
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

class _BudgetImpl extends Budget {
  _BudgetImpl({
    _isc.UuidValue? id,
    required String name,
    required String currencyCode,
    String? displayCurrencyCode,
    required _isc.UuidValue ownerId,
    String? accountingMode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         name: name,
         currencyCode: currencyCode,
         displayCurrencyCode: displayCurrencyCode,
         ownerId: ownerId,
         accountingMode: accountingMode,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Budget]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Budget copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    String? name,
    String? currencyCode,
    Object? displayCurrencyCode = _Undefined,
    _isc.UuidValue? ownerId,
    String? accountingMode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      name: name ?? this.name,
      currencyCode: currencyCode ?? this.currencyCode,
      displayCurrencyCode: displayCurrencyCode is String?
          ? displayCurrencyCode
          : this.displayCurrencyCode,
      ownerId: ownerId ?? this.ownerId,
      accountingMode: accountingMode ?? this.accountingMode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
