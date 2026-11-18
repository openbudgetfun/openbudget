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

/// Links the two legs of a move between two accounts.
abstract class Transfer
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Transfer._({
    this.id,
    required this.fromTransactionId,
    required this.toTransactionId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Transfer({
    _isc.UuidValue? id,
    required _isc.UuidValue fromTransactionId,
    required _isc.UuidValue toTransactionId,
    DateTime? createdAt,
  }) = _TransferImpl;

  factory Transfer.fromJson(Map<String, dynamic> jsonSerialization) {
    return Transfer(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      fromTransactionId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['fromTransactionId'],
      ),
      toTransactionId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['toTransactionId'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  /// The outflow leg.
  _isc.UuidValue fromTransactionId;

  /// The inflow leg.
  _isc.UuidValue toTransactionId;

  DateTime createdAt;

  /// Returns a shallow copy of this [Transfer]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Transfer copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? fromTransactionId,
    _isc.UuidValue? toTransactionId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Transfer',
      if (id != null) 'id': id?.toJson(),
      'fromTransactionId': fromTransactionId.toJson(),
      'toTransactionId': toTransactionId.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Transfer',
      if (id != null) 'id': id?.toJson(),
      'fromTransactionId': fromTransactionId.toJson(),
      'toTransactionId': toTransactionId.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _TransferImpl extends Transfer {
  _TransferImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue fromTransactionId,
    required _isc.UuidValue toTransactionId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         fromTransactionId: fromTransactionId,
         toTransactionId: toTransactionId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Transfer]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Transfer copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? fromTransactionId,
    _isc.UuidValue? toTransactionId,
    DateTime? createdAt,
  }) {
    return Transfer(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      fromTransactionId: fromTransactionId ?? this.fromTransactionId,
      toTransactionId: toTransactionId ?? this.toTransactionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
