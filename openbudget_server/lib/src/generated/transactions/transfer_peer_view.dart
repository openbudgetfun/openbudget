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

/// The other leg of a transfer, as seen from one leg.
abstract class TransferPeerView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TransferPeerView._({
    required this.transferId,
    required this.transactionId,
    required this.accountId,
    required this.accountName,
    required this.entityId,
    required this.amountMinor,
    required this.currencyCode,
  });

  factory TransferPeerView({
    required _is.UuidValue transferId,
    required _is.UuidValue transactionId,
    required _is.UuidValue accountId,
    required String accountName,
    required _is.UuidValue entityId,
    required int amountMinor,
    required String currencyCode,
  }) = _TransferPeerViewImpl;

  factory TransferPeerView.fromJson(Map<String, dynamic> jsonSerialization) {
    return TransferPeerView(
      transferId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['transferId'],
      ),
      transactionId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['transactionId'],
      ),
      accountId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountId'],
      ),
      accountName: jsonSerialization['accountName'] as String,
      entityId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      amountMinor: jsonSerialization['amountMinor'] as int,
      currencyCode: jsonSerialization['currencyCode'] as String,
    );
  }

  _is.UuidValue transferId;

  _is.UuidValue transactionId;

  _is.UuidValue accountId;

  String accountName;

  _is.UuidValue entityId;

  /// Signed amount of the other leg in its own account's minor units.
  int amountMinor;

  String currencyCode;

  /// Returns a shallow copy of this [TransferPeerView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TransferPeerView copyWith({
    _is.UuidValue? transferId,
    _is.UuidValue? transactionId,
    _is.UuidValue? accountId,
    String? accountName,
    _is.UuidValue? entityId,
    int? amountMinor,
    String? currencyCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TransferPeerView',
      'transferId': transferId.toJson(),
      'transactionId': transactionId.toJson(),
      'accountId': accountId.toJson(),
      'accountName': accountName,
      'entityId': entityId.toJson(),
      'amountMinor': amountMinor,
      'currencyCode': currencyCode,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TransferPeerView',
      'transferId': transferId.toJson(),
      'transactionId': transactionId.toJson(),
      'accountId': accountId.toJson(),
      'accountName': accountName,
      'entityId': entityId.toJson(),
      'amountMinor': amountMinor,
      'currencyCode': currencyCode,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _TransferPeerViewImpl extends TransferPeerView {
  _TransferPeerViewImpl({
    required _is.UuidValue transferId,
    required _is.UuidValue transactionId,
    required _is.UuidValue accountId,
    required String accountName,
    required _is.UuidValue entityId,
    required int amountMinor,
    required String currencyCode,
  }) : super._(
         transferId: transferId,
         transactionId: transactionId,
         accountId: accountId,
         accountName: accountName,
         entityId: entityId,
         amountMinor: amountMinor,
         currencyCode: currencyCode,
       );

  /// Returns a shallow copy of this [TransferPeerView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TransferPeerView copyWith({
    _is.UuidValue? transferId,
    _is.UuidValue? transactionId,
    _is.UuidValue? accountId,
    String? accountName,
    _is.UuidValue? entityId,
    int? amountMinor,
    String? currencyCode,
  }) {
    return TransferPeerView(
      transferId: transferId ?? this.transferId,
      transactionId: transactionId ?? this.transactionId,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      entityId: entityId ?? this.entityId,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }
}
