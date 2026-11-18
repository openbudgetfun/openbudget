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

import '../entities/change_scope.dart' as _iqgtpa5g;

/// Tells a subscribed client which part of an entity changed, so it reloads
/// only the providers that depend on it.
abstract class EntityChangedEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  EntityChangedEvent._({
    required this.entityId,
    required this.scope,
    this.month,
    this.accountId,
  });

  factory EntityChangedEvent({
    required _isc.UuidValue entityId,
    required _iqgtpa5g.ChangeScope scope,
    int? month,
    _isc.UuidValue? accountId,
  }) = _EntityChangedEventImpl;

  factory EntityChangedEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return EntityChangedEvent(
      entityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      scope: _iqgtpa5g.ChangeScope.fromJson(
        (jsonSerialization['scope'] as String),
      ),
      month: jsonSerialization['month'] as int?,
      accountId: jsonSerialization['accountId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['accountId'],
            ),
    );
  }

  _isc.UuidValue entityId;

  _iqgtpa5g.ChangeScope scope;

  /// The budget month affected, when the change has one.
  int? month;

  /// The account affected, when the change has one.
  _isc.UuidValue? accountId;

  /// Returns a shallow copy of this [EntityChangedEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  EntityChangedEvent copyWith({
    _isc.UuidValue? entityId,
    _iqgtpa5g.ChangeScope? scope,
    int? month,
    _isc.UuidValue? accountId = const _isc.$UndefinedUuidValue(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EntityChangedEvent',
      'entityId': entityId.toJson(),
      'scope': scope.toJson(),
      if (month != null) 'month': month,
      if (accountId != null) 'accountId': accountId?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EntityChangedEvent',
      'entityId': entityId.toJson(),
      'scope': scope.toJson(),
      if (month != null) 'month': month,
      if (accountId != null) 'accountId': accountId?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EntityChangedEventImpl extends EntityChangedEvent {
  _EntityChangedEventImpl({
    required _isc.UuidValue entityId,
    required _iqgtpa5g.ChangeScope scope,
    int? month,
    _isc.UuidValue? accountId,
  }) : super._(
         entityId: entityId,
         scope: scope,
         month: month,
         accountId: accountId,
       );

  /// Returns a shallow copy of this [EntityChangedEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  EntityChangedEvent copyWith({
    _isc.UuidValue? entityId,
    _iqgtpa5g.ChangeScope? scope,
    Object? month = _Undefined,
    _isc.UuidValue? accountId = const _isc.$UndefinedUuidValue(),
  }) {
    return EntityChangedEvent(
      entityId: entityId ?? this.entityId,
      scope: scope ?? this.scope,
      month: month is int? ? month : this.month,
      accountId: accountId is _isc.UndefinedSentinel
          ? this.accountId
          : accountId,
    );
  }
}
