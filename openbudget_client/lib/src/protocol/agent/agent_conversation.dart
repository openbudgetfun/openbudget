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

/// One chat between a user and the financial assistant about a budget.
abstract class AgentConversation
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AgentConversation._({
    this.id,
    required this.userId,
    required this.budgetId,
    required this.title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory AgentConversation({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    required _isc.UuidValue budgetId,
    required String title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AgentConversationImpl;

  factory AgentConversation.fromJson(Map<String, dynamic> jsonSerialization) {
    return AgentConversation(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      budgetId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      title: jsonSerialization['title'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue userId;

  _isc.UuidValue budgetId;

  /// Short title, taken from the first message.
  String title;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [AgentConversation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AgentConversation copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? userId,
    _isc.UuidValue? budgetId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentConversation',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'budgetId': budgetId.toJson(),
      'title': title,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AgentConversation',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'budgetId': budgetId.toJson(),
      'title': title,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AgentConversationImpl extends AgentConversation {
  _AgentConversationImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    required _isc.UuidValue budgetId,
    required String title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         userId: userId,
         budgetId: budgetId,
         title: title,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AgentConversation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AgentConversation copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? userId,
    _isc.UuidValue? budgetId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AgentConversation(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      userId: userId ?? this.userId,
      budgetId: budgetId ?? this.budgetId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
