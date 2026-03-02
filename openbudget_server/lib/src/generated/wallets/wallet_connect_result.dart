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
import 'package:serverpod/serverpod.dart' as _i1;
import '../accounts/account.dart' as _i2;
import '../wallets/wallet_holding.dart' as _i3;
import 'package:openbudget_server/src/generated/protocol.dart' as _i4;

/// Result payload after connecting or refreshing a wallet.
abstract class WalletConnectResult
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  WalletConnectResult._({
    required this.account,
    required this.holdings,
    required this.totalUsdValue,
  });

  factory WalletConnectResult({
    required _i2.Account account,
    required List<_i3.WalletHolding> holdings,
    required double totalUsdValue,
  }) = _WalletConnectResultImpl;

  factory WalletConnectResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return WalletConnectResult(
      account: _i4.Protocol().deserialize<_i2.Account>(
        jsonSerialization['account'],
      ),
      holdings: _i4.Protocol().deserialize<List<_i3.WalletHolding>>(
        jsonSerialization['holdings'],
      ),
      totalUsdValue: (jsonSerialization['totalUsdValue'] as num).toDouble(),
    );
  }

  _i2.Account account;

  List<_i3.WalletHolding> holdings;

  double totalUsdValue;

  /// Returns a shallow copy of this [WalletConnectResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  WalletConnectResult copyWith({
    _i2.Account? account,
    List<_i3.WalletHolding>? holdings,
    double? totalUsdValue,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WalletConnectResult',
      'account': account.toJson(),
      'holdings': holdings.toJson(valueToJson: (v) => v.toJson()),
      'totalUsdValue': totalUsdValue,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WalletConnectResult',
      'account': account.toJsonForProtocol(),
      'holdings': holdings.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'totalUsdValue': totalUsdValue,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _WalletConnectResultImpl extends WalletConnectResult {
  _WalletConnectResultImpl({
    required _i2.Account account,
    required List<_i3.WalletHolding> holdings,
    required double totalUsdValue,
  }) : super._(
         account: account,
         holdings: holdings,
         totalUsdValue: totalUsdValue,
       );

  /// Returns a shallow copy of this [WalletConnectResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  WalletConnectResult copyWith({
    _i2.Account? account,
    List<_i3.WalletHolding>? holdings,
    double? totalUsdValue,
  }) {
    return WalletConnectResult(
      account: account ?? this.account.copyWith(),
      holdings: holdings ?? this.holdings.map((e0) => e0.copyWith()).toList(),
      totalUsdValue: totalUsdValue ?? this.totalUsdValue,
    );
  }
}
