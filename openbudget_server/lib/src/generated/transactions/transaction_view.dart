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
import 'package:openbudget_server/src/generated/protocol.dart' as _is0sbm8r;
import 'package:serverpod/serverpod.dart' as _is;

import '../transactions/transaction.dart' as _ixr6i6t3;
import '../transactions/transaction_line.dart' as _irmnubl8;
import '../transactions/transfer_peer_view.dart' as _io7yhe8n;

/// A transaction with everything a list row or detail screen shows.
abstract class TransactionView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TransactionView._({
    required this.transaction,
    required this.lines,
    required this.accountCurrencyCode,
    required this.accountName,
    this.payeeName,
    this.transferPeer,
  });

  factory TransactionView({
    required _ixr6i6t3.Transaction transaction,
    required List<_irmnubl8.TransactionLine> lines,
    required String accountCurrencyCode,
    required String accountName,
    String? payeeName,
    _io7yhe8n.TransferPeerView? transferPeer,
  }) = _TransactionViewImpl;

  factory TransactionView.fromJson(Map<String, dynamic> jsonSerialization) {
    return TransactionView(
      transaction: _is0sbm8r.Protocol().deserialize<_ixr6i6t3.Transaction>(
        jsonSerialization['transaction'],
      ),
      lines: _is0sbm8r.Protocol().deserialize<List<_irmnubl8.TransactionLine>>(
        jsonSerialization['lines'],
      ),
      accountCurrencyCode: jsonSerialization['accountCurrencyCode'] as String,
      accountName: jsonSerialization['accountName'] as String,
      payeeName: jsonSerialization['payeeName'] as String?,
      transferPeer: jsonSerialization['transferPeer'] == null
          ? null
          : _is0sbm8r.Protocol().deserialize<_io7yhe8n.TransferPeerView>(
              jsonSerialization['transferPeer'],
            ),
    );
  }

  _ixr6i6t3.Transaction transaction;

  List<_irmnubl8.TransactionLine> lines;

  /// ISO 4217 currency of the account.
  String accountCurrencyCode;

  String accountName;

  String? payeeName;

  /// The other leg, when this transaction is part of a transfer.
  _io7yhe8n.TransferPeerView? transferPeer;

  /// Returns a shallow copy of this [TransactionView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TransactionView copyWith({
    _ixr6i6t3.Transaction? transaction,
    List<_irmnubl8.TransactionLine>? lines,
    String? accountCurrencyCode,
    String? accountName,
    String? payeeName,
    _io7yhe8n.TransferPeerView? transferPeer =
        const _UndefinedTransactionView$transferPeer(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TransactionView',
      'transaction': transaction.toJson(),
      'lines': lines.toJson(valueToJson: (v) => v.toJson()),
      'accountCurrencyCode': accountCurrencyCode,
      'accountName': accountName,
      if (payeeName != null) 'payeeName': payeeName,
      if (transferPeer != null) 'transferPeer': transferPeer?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TransactionView',
      'transaction': transaction.toJsonForProtocol(),
      'lines': lines.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'accountCurrencyCode': accountCurrencyCode,
      'accountName': accountName,
      if (payeeName != null) 'payeeName': payeeName,
      if (transferPeer != null)
        'transferPeer': transferPeer?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UndefinedTransactionView$transferPeer extends _is.UndefinedSentinel
    implements _io7yhe8n.TransferPeerView {
  const _UndefinedTransactionView$transferPeer();
}

class _TransactionViewImpl extends TransactionView {
  _TransactionViewImpl({
    required _ixr6i6t3.Transaction transaction,
    required List<_irmnubl8.TransactionLine> lines,
    required String accountCurrencyCode,
    required String accountName,
    String? payeeName,
    _io7yhe8n.TransferPeerView? transferPeer,
  }) : super._(
         transaction: transaction,
         lines: lines,
         accountCurrencyCode: accountCurrencyCode,
         accountName: accountName,
         payeeName: payeeName,
         transferPeer: transferPeer,
       );

  /// Returns a shallow copy of this [TransactionView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TransactionView copyWith({
    _ixr6i6t3.Transaction? transaction,
    List<_irmnubl8.TransactionLine>? lines,
    String? accountCurrencyCode,
    String? accountName,
    Object? payeeName = _Undefined,
    _io7yhe8n.TransferPeerView? transferPeer =
        const _UndefinedTransactionView$transferPeer(),
  }) {
    return TransactionView(
      transaction: transaction ?? this.transaction.copyWith(),
      lines: lines ?? this.lines.map((e0) => e0.copyWith()).toList(),
      accountCurrencyCode: accountCurrencyCode ?? this.accountCurrencyCode,
      accountName: accountName ?? this.accountName,
      payeeName: payeeName is String? ? payeeName : this.payeeName,
      transferPeer: transferPeer is _is.UndefinedSentinel
          ? this.transferPeer?.copyWith()
          : transferPeer,
    );
  }
}
