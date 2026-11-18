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

/// Assigns an envelope automatically when a transaction uses a payee.
abstract class TransactionRule
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TransactionRule._({
    this.id,
    required this.entityId,
    required this.payeeId,
    required this.envelopeId,
    bool? enabled,
    DateTime? createdAt,
  }) : enabled = enabled ?? true,
       createdAt = createdAt ?? DateTime.now();

  factory TransactionRule({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required _isc.UuidValue payeeId,
    required _isc.UuidValue envelopeId,
    bool? enabled,
    DateTime? createdAt,
  }) = _TransactionRuleImpl;

  factory TransactionRule.fromJson(Map<String, dynamic> jsonSerialization) {
    return TransactionRule(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      payeeId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['payeeId'],
      ),
      envelopeId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['envelopeId'],
      ),
      enabled: jsonSerialization['enabled'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['enabled']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue entityId;

  _isc.UuidValue payeeId;

  _isc.UuidValue envelopeId;

  bool enabled;

  DateTime createdAt;

  /// Returns a shallow copy of this [TransactionRule]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TransactionRule copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    _isc.UuidValue? payeeId,
    _isc.UuidValue? envelopeId,
    bool? enabled,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TransactionRule',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'payeeId': payeeId.toJson(),
      'envelopeId': envelopeId.toJson(),
      'enabled': enabled,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TransactionRule',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'payeeId': payeeId.toJson(),
      'envelopeId': envelopeId.toJson(),
      'enabled': enabled,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _TransactionRuleImpl extends TransactionRule {
  _TransactionRuleImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required _isc.UuidValue payeeId,
    required _isc.UuidValue envelopeId,
    bool? enabled,
    DateTime? createdAt,
  }) : super._(
         id: id,
         entityId: entityId,
         payeeId: payeeId,
         envelopeId: envelopeId,
         enabled: enabled,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [TransactionRule]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TransactionRule copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    _isc.UuidValue? payeeId,
    _isc.UuidValue? envelopeId,
    bool? enabled,
    DateTime? createdAt,
  }) {
    return TransactionRule(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      payeeId: payeeId ?? this.payeeId,
      envelopeId: envelopeId ?? this.envelopeId,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
