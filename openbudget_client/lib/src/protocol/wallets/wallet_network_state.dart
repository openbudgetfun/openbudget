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

/// One network's read state for one wallet: when its holdings were last read,
/// why the last read failed, and where history sync stopped.
abstract class WalletNetworkState
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  WalletNetworkState._({
    this.id,
    required this.walletId,
    required this.network,
    this.lastReadAt,
    this.lastError,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory WalletNetworkState({
    _isc.UuidValue? id,
    required _isc.UuidValue walletId,
    required _ifz8weqz.WalletNetwork network,
    DateTime? lastReadAt,
    String? lastError,
    DateTime? updatedAt,
  }) = _WalletNetworkStateImpl;

  factory WalletNetworkState.fromJson(Map<String, dynamic> jsonSerialization) {
    return WalletNetworkState(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      walletId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['walletId'],
      ),
      network: _ifz8weqz.WalletNetwork.fromJson(
        (jsonSerialization['network'] as String),
      ),
      lastReadAt: jsonSerialization['lastReadAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastReadAt'],
            ),
      lastError: jsonSerialization['lastError'] as String?,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue walletId;

  _ifz8weqz.WalletNetwork network;

  /// When holdings on this network were last read successfully.
  DateTime? lastReadAt;

  /// The last read's failure in plain words, cleared by the next success.
  String? lastError;

  DateTime updatedAt;

  /// Returns a shallow copy of this [WalletNetworkState]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  WalletNetworkState copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? walletId,
    _ifz8weqz.WalletNetwork? network,
    DateTime? lastReadAt = const _isc.$UndefinedDateTime(),
    String? lastError,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WalletNetworkState',
      if (id != null) 'id': id?.toJson(),
      'walletId': walletId.toJson(),
      'network': network.toJson(),
      if (lastReadAt != null) 'lastReadAt': lastReadAt?.toJson(),
      if (lastError != null) 'lastError': lastError,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WalletNetworkState',
      if (id != null) 'id': id?.toJson(),
      'walletId': walletId.toJson(),
      'network': network.toJson(),
      if (lastReadAt != null) 'lastReadAt': lastReadAt?.toJson(),
      if (lastError != null) 'lastError': lastError,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WalletNetworkStateImpl extends WalletNetworkState {
  _WalletNetworkStateImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue walletId,
    required _ifz8weqz.WalletNetwork network,
    DateTime? lastReadAt,
    String? lastError,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         walletId: walletId,
         network: network,
         lastReadAt: lastReadAt,
         lastError: lastError,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [WalletNetworkState]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  WalletNetworkState copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? walletId,
    _ifz8weqz.WalletNetwork? network,
    DateTime? lastReadAt = const _isc.$UndefinedDateTime(),
    Object? lastError = _Undefined,
    DateTime? updatedAt,
  }) {
    return WalletNetworkState(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      walletId: walletId ?? this.walletId,
      network: network ?? this.network,
      lastReadAt: lastReadAt is _isc.UndefinedSentinel
          ? this.lastReadAt
          : lastReadAt,
      lastError: lastError is String? ? lastError : this.lastError,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
