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

/// The balances of one account, in account minor units.
abstract class AccountBalancesView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  AccountBalancesView._({
    required this.accountId,
    required this.currencyCode,
    required this.balanceMinor,
    required this.clearedMinor,
    required this.unclearedMinor,
    this.reportedBalanceMinor,
    this.reportedBalanceAt,
    this.reconciledThroughDate,
  });

  factory AccountBalancesView({
    required _is.UuidValue accountId,
    required String currencyCode,
    required int balanceMinor,
    required int clearedMinor,
    required int unclearedMinor,
    int? reportedBalanceMinor,
    DateTime? reportedBalanceAt,
    DateTime? reconciledThroughDate,
  }) = _AccountBalancesViewImpl;

  factory AccountBalancesView.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccountBalancesView(
      accountId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountId'],
      ),
      currencyCode: jsonSerialization['currencyCode'] as String,
      balanceMinor: jsonSerialization['balanceMinor'] as int,
      clearedMinor: jsonSerialization['clearedMinor'] as int,
      unclearedMinor: jsonSerialization['unclearedMinor'] as int,
      reportedBalanceMinor: jsonSerialization['reportedBalanceMinor'] as int?,
      reportedBalanceAt: jsonSerialization['reportedBalanceAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['reportedBalanceAt'],
            ),
      reconciledThroughDate: jsonSerialization['reconciledThroughDate'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['reconciledThroughDate'],
            ),
    );
  }

  _is.UuidValue accountId;

  String currencyCode;

  /// account.balanceMinor.
  int balanceMinor;

  /// Cleared and reconciled transactions.
  int clearedMinor;

  int unclearedMinor;

  int? reportedBalanceMinor;

  DateTime? reportedBalanceAt;

  DateTime? reconciledThroughDate;

  /// Returns a shallow copy of this [AccountBalancesView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AccountBalancesView copyWith({
    _is.UuidValue? accountId,
    String? currencyCode,
    int? balanceMinor,
    int? clearedMinor,
    int? unclearedMinor,
    int? reportedBalanceMinor,
    DateTime? reportedBalanceAt = const _is.$UndefinedDateTime(),
    DateTime? reconciledThroughDate = const _is.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AccountBalancesView',
      'accountId': accountId.toJson(),
      'currencyCode': currencyCode,
      'balanceMinor': balanceMinor,
      'clearedMinor': clearedMinor,
      'unclearedMinor': unclearedMinor,
      if (reportedBalanceMinor != null)
        'reportedBalanceMinor': reportedBalanceMinor,
      if (reportedBalanceAt != null)
        'reportedBalanceAt': reportedBalanceAt?.toJson(),
      if (reconciledThroughDate != null)
        'reconciledThroughDate': reconciledThroughDate?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AccountBalancesView',
      'accountId': accountId.toJson(),
      'currencyCode': currencyCode,
      'balanceMinor': balanceMinor,
      'clearedMinor': clearedMinor,
      'unclearedMinor': unclearedMinor,
      if (reportedBalanceMinor != null)
        'reportedBalanceMinor': reportedBalanceMinor,
      if (reportedBalanceAt != null)
        'reportedBalanceAt': reportedBalanceAt?.toJson(),
      if (reconciledThroughDate != null)
        'reconciledThroughDate': reconciledThroughDate?.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountBalancesViewImpl extends AccountBalancesView {
  _AccountBalancesViewImpl({
    required _is.UuidValue accountId,
    required String currencyCode,
    required int balanceMinor,
    required int clearedMinor,
    required int unclearedMinor,
    int? reportedBalanceMinor,
    DateTime? reportedBalanceAt,
    DateTime? reconciledThroughDate,
  }) : super._(
         accountId: accountId,
         currencyCode: currencyCode,
         balanceMinor: balanceMinor,
         clearedMinor: clearedMinor,
         unclearedMinor: unclearedMinor,
         reportedBalanceMinor: reportedBalanceMinor,
         reportedBalanceAt: reportedBalanceAt,
         reconciledThroughDate: reconciledThroughDate,
       );

  /// Returns a shallow copy of this [AccountBalancesView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AccountBalancesView copyWith({
    _is.UuidValue? accountId,
    String? currencyCode,
    int? balanceMinor,
    int? clearedMinor,
    int? unclearedMinor,
    Object? reportedBalanceMinor = _Undefined,
    DateTime? reportedBalanceAt = const _is.$UndefinedDateTime(),
    DateTime? reconciledThroughDate = const _is.$UndefinedDateTime(),
  }) {
    return AccountBalancesView(
      accountId: accountId ?? this.accountId,
      currencyCode: currencyCode ?? this.currencyCode,
      balanceMinor: balanceMinor ?? this.balanceMinor,
      clearedMinor: clearedMinor ?? this.clearedMinor,
      unclearedMinor: unclearedMinor ?? this.unclearedMinor,
      reportedBalanceMinor: reportedBalanceMinor is int?
          ? reportedBalanceMinor
          : this.reportedBalanceMinor,
      reportedBalanceAt: reportedBalanceAt is _is.UndefinedSentinel
          ? this.reportedBalanceAt
          : reportedBalanceAt,
      reconciledThroughDate: reconciledThroughDate is _is.UndefinedSentinel
          ? this.reconciledThroughDate
          : reconciledThroughDate,
    );
  }
}
