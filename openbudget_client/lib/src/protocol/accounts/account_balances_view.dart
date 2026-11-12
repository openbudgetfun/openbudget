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

/// The balances of one account, in account minor units.
abstract class AccountBalancesView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
    required _isc.UuidValue accountId,
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
      accountId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountId'],
      ),
      currencyCode: jsonSerialization['currencyCode'] as String,
      balanceMinor: jsonSerialization['balanceMinor'] as int,
      clearedMinor: jsonSerialization['clearedMinor'] as int,
      unclearedMinor: jsonSerialization['unclearedMinor'] as int,
      reportedBalanceMinor: jsonSerialization['reportedBalanceMinor'] as int?,
      reportedBalanceAt: jsonSerialization['reportedBalanceAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['reportedBalanceAt'],
            ),
      reconciledThroughDate: jsonSerialization['reconciledThroughDate'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['reconciledThroughDate'],
            ),
    );
  }

  _isc.UuidValue accountId;

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
  @_isc.useResult
  AccountBalancesView copyWith({
    _isc.UuidValue? accountId,
    String? currencyCode,
    int? balanceMinor,
    int? clearedMinor,
    int? unclearedMinor,
    int? reportedBalanceMinor,
    DateTime? reportedBalanceAt = const _isc.$UndefinedDateTime(),
    DateTime? reconciledThroughDate = const _isc.$UndefinedDateTime(),
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
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountBalancesViewImpl extends AccountBalancesView {
  _AccountBalancesViewImpl({
    required _isc.UuidValue accountId,
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
  @_isc.useResult
  @override
  AccountBalancesView copyWith({
    _isc.UuidValue? accountId,
    String? currencyCode,
    int? balanceMinor,
    int? clearedMinor,
    int? unclearedMinor,
    Object? reportedBalanceMinor = _Undefined,
    DateTime? reportedBalanceAt = const _isc.$UndefinedDateTime(),
    DateTime? reconciledThroughDate = const _isc.$UndefinedDateTime(),
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
      reportedBalanceAt: reportedBalanceAt is _isc.UndefinedSentinel
          ? this.reportedBalanceAt
          : reportedBalanceAt,
      reconciledThroughDate: reconciledThroughDate is _isc.UndefinedSentinel
          ? this.reconciledThroughDate
          : reconciledThroughDate,
    );
  }
}
