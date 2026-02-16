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
import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// A rule that auto-assigns an envelope when a specific payee is used.
abstract class TransactionRule implements _i1.SerializableModel {
  TransactionRule._({
    this.id,
    required this.budgetId,
    required this.payeeId,
    required this.targetEnvelopeId,
    bool? enabled,
    DateTime? createdAt,
  }) : enabled = enabled ?? true,
       createdAt = createdAt ?? DateTime.now();

  factory TransactionRule({
    _i1.UuidValue? id,
    required _i1.UuidValue budgetId,
    required _i1.UuidValue payeeId,
    required _i1.UuidValue targetEnvelopeId,
    bool? enabled,
    DateTime? createdAt,
  }) = _TransactionRuleImpl;

  factory TransactionRule.fromJson(Map<String, dynamic> jsonSerialization) {
    return TransactionRule(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      budgetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      payeeId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['payeeId'],
      ),
      targetEnvelopeId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['targetEnvelopeId'],
      ),
      enabled: jsonSerialization['enabled'] as bool?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue budgetId;

  /// The payee this rule matches against.
  _i1.UuidValue payeeId;

  /// The envelope to auto-assign when this rule matches.
  _i1.UuidValue targetEnvelopeId;

  /// Whether this rule is active.
  bool enabled;

  DateTime createdAt;

  /// Returns a shallow copy of this [TransactionRule]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TransactionRule copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? budgetId,
    _i1.UuidValue? payeeId,
    _i1.UuidValue? targetEnvelopeId,
    bool? enabled,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TransactionRule',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'payeeId': payeeId.toJson(),
      'targetEnvelopeId': targetEnvelopeId.toJson(),
      'enabled': enabled,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TransactionRuleImpl extends TransactionRule {
  _TransactionRuleImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue budgetId,
    required _i1.UuidValue payeeId,
    required _i1.UuidValue targetEnvelopeId,
    bool? enabled,
    DateTime? createdAt,
  }) : super._(
         id: id,
         budgetId: budgetId,
         payeeId: payeeId,
         targetEnvelopeId: targetEnvelopeId,
         enabled: enabled,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [TransactionRule]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TransactionRule copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? budgetId,
    _i1.UuidValue? payeeId,
    _i1.UuidValue? targetEnvelopeId,
    bool? enabled,
    DateTime? createdAt,
  }) {
    return TransactionRule(
      id: id is _i1.UuidValue? ? id : this.id,
      budgetId: budgetId ?? this.budgetId,
      payeeId: payeeId ?? this.payeeId,
      targetEnvelopeId: targetEnvelopeId ?? this.targetEnvelopeId,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
