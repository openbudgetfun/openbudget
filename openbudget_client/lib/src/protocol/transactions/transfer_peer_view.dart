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

/// The other leg of a transfer, as seen from one leg.
abstract class TransferPeerView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
    required _isc.UuidValue transferId,
    required _isc.UuidValue transactionId,
    required _isc.UuidValue accountId,
    required String accountName,
    required _isc.UuidValue entityId,
    required int amountMinor,
    required String currencyCode,
  }) = _TransferPeerViewImpl;

  factory TransferPeerView.fromJson(Map<String, dynamic> jsonSerialization) {
    return TransferPeerView(
      transferId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['transferId'],
      ),
      transactionId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['transactionId'],
      ),
      accountId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountId'],
      ),
      accountName: jsonSerialization['accountName'] as String,
      entityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      amountMinor: jsonSerialization['amountMinor'] as int,
      currencyCode: jsonSerialization['currencyCode'] as String,
    );
  }

  _isc.UuidValue transferId;

  _isc.UuidValue transactionId;

  _isc.UuidValue accountId;

  String accountName;

  _isc.UuidValue entityId;

  /// Signed amount of the other leg in its own account's minor units.
  int amountMinor;

  String currencyCode;

  /// Returns a shallow copy of this [TransferPeerView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TransferPeerView copyWith({
    _isc.UuidValue? transferId,
    _isc.UuidValue? transactionId,
    _isc.UuidValue? accountId,
    String? accountName,
    _isc.UuidValue? entityId,
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
    return _isc.SerializationManager.encode(this);
  }
}

class _TransferPeerViewImpl extends TransferPeerView {
  _TransferPeerViewImpl({
    required _isc.UuidValue transferId,
    required _isc.UuidValue transactionId,
    required _isc.UuidValue accountId,
    required String accountName,
    required _isc.UuidValue entityId,
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
  @_isc.useResult
  @override
  TransferPeerView copyWith({
    _isc.UuidValue? transferId,
    _isc.UuidValue? transactionId,
    _isc.UuidValue? accountId,
    String? accountName,
    _isc.UuidValue? entityId,
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
