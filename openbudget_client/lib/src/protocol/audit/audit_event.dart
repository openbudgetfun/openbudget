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

import '../audit/audit_action.dart' as _iz7hrpib;
import '../audit/audit_subject.dart' as _i1h8duvl;

/// One audit trail entry for an entity. Never updated or deleted.
abstract class AuditEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AuditEvent._({
    this.id,
    required this.entityId,
    required this.actorId,
    required this.action,
    this.subjectType,
    this.subjectId,
    String? payloadJson,
    DateTime? createdAt,
  }) : payloadJson = payloadJson ?? '{}',
       createdAt = createdAt ?? DateTime.now();

  factory AuditEvent({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required _isc.UuidValue actorId,
    required _iz7hrpib.AuditAction action,
    _i1h8duvl.AuditSubject? subjectType,
    _isc.UuidValue? subjectId,
    String? payloadJson,
    DateTime? createdAt,
  }) = _AuditEventImpl;

  factory AuditEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return AuditEvent(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      actorId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['actorId'],
      ),
      action: _iz7hrpib.AuditAction.fromJson(
        (jsonSerialization['action'] as String),
      ),
      subjectType: jsonSerialization['subjectType'] == null
          ? null
          : _i1h8duvl.AuditSubject.fromJson(
              (jsonSerialization['subjectType'] as String),
            ),
      subjectId: jsonSerialization['subjectId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['subjectId'],
            ),
      payloadJson: jsonSerialization['payloadJson'] as String?,
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

  /// The acting user, or the nil UUID for system actions.
  _isc.UuidValue actorId;

  _iz7hrpib.AuditAction action;

  _i1h8duvl.AuditSubject? subjectType;

  _isc.UuidValue? subjectId;

  /// JSON object with the action's details, including the before state of
  /// edited or deleted rows.
  String payloadJson;

  DateTime createdAt;

  /// Returns a shallow copy of this [AuditEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AuditEvent copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    _isc.UuidValue? actorId,
    _iz7hrpib.AuditAction? action,
    _i1h8duvl.AuditSubject? subjectType,
    _isc.UuidValue? subjectId = const _isc.$UndefinedUuidValue(),
    String? payloadJson,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AuditEvent',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'actorId': actorId.toJson(),
      'action': action.toJson(),
      if (subjectType != null) 'subjectType': subjectType?.toJson(),
      if (subjectId != null) 'subjectId': subjectId?.toJson(),
      'payloadJson': payloadJson,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AuditEvent',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'actorId': actorId.toJson(),
      'action': action.toJson(),
      if (subjectType != null) 'subjectType': subjectType?.toJson(),
      if (subjectId != null) 'subjectId': subjectId?.toJson(),
      'payloadJson': payloadJson,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AuditEventImpl extends AuditEvent {
  _AuditEventImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required _isc.UuidValue actorId,
    required _iz7hrpib.AuditAction action,
    _i1h8duvl.AuditSubject? subjectType,
    _isc.UuidValue? subjectId,
    String? payloadJson,
    DateTime? createdAt,
  }) : super._(
         id: id,
         entityId: entityId,
         actorId: actorId,
         action: action,
         subjectType: subjectType,
         subjectId: subjectId,
         payloadJson: payloadJson,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AuditEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AuditEvent copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    _isc.UuidValue? actorId,
    _iz7hrpib.AuditAction? action,
    Object? subjectType = _Undefined,
    _isc.UuidValue? subjectId = const _isc.$UndefinedUuidValue(),
    String? payloadJson,
    DateTime? createdAt,
  }) {
    return AuditEvent(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      actorId: actorId ?? this.actorId,
      action: action ?? this.action,
      subjectType: subjectType is _i1h8duvl.AuditSubject?
          ? subjectType
          : this.subjectType,
      subjectId: subjectId is _isc.UndefinedSentinel
          ? this.subjectId
          : subjectId,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
