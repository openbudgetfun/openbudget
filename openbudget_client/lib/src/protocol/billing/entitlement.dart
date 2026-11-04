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

import '../billing/entitlement_source.dart' as _i34ejbb7;
import '../billing/entitlement_status.dart' as _iudzg4q8;

/// A user's paid OpenBudget Plus subscription on one payment rail.
///
/// Each rail writes its own row, keyed by the rail's subscription id, so a
/// user who pays twice by mistake keeps two rows and the later period wins.
abstract class Entitlement
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Entitlement._({
    this.id,
    required this.userId,
    required this.source,
    required this.externalId,
    required this.status,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Entitlement({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    required _i34ejbb7.EntitlementSource source,
    required String externalId,
    required _iudzg4q8.EntitlementStatus status,
    required DateTime currentPeriodStart,
    required DateTime currentPeriodEnd,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _EntitlementImpl;

  factory Entitlement.fromJson(Map<String, dynamic> jsonSerialization) {
    return Entitlement(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      source: _i34ejbb7.EntitlementSource.fromJson(
        (jsonSerialization['source'] as String),
      ),
      externalId: jsonSerialization['externalId'] as String,
      status: _iudzg4q8.EntitlementStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      currentPeriodStart: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['currentPeriodStart'],
      ),
      currentPeriodEnd: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['currentPeriodEnd'],
      ),
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

  _i34ejbb7.EntitlementSource source;

  /// The rail's subscription id: a Stripe subscription, a RevenueCat
  /// original transaction, or a Solana subscription account address.
  String externalId;

  _iudzg4q8.EntitlementStatus status;

  DateTime currentPeriodStart;

  DateTime currentPeriodEnd;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [Entitlement]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Entitlement copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? userId,
    _i34ejbb7.EntitlementSource? source,
    String? externalId,
    _iudzg4q8.EntitlementStatus? status,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Entitlement',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'source': source.toJson(),
      'externalId': externalId,
      'status': status.toJson(),
      'currentPeriodStart': currentPeriodStart.toJson(),
      'currentPeriodEnd': currentPeriodEnd.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Entitlement',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'source': source.toJson(),
      'externalId': externalId,
      'status': status.toJson(),
      'currentPeriodStart': currentPeriodStart.toJson(),
      'currentPeriodEnd': currentPeriodEnd.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _EntitlementImpl extends Entitlement {
  _EntitlementImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    required _i34ejbb7.EntitlementSource source,
    required String externalId,
    required _iudzg4q8.EntitlementStatus status,
    required DateTime currentPeriodStart,
    required DateTime currentPeriodEnd,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         userId: userId,
         source: source,
         externalId: externalId,
         status: status,
         currentPeriodStart: currentPeriodStart,
         currentPeriodEnd: currentPeriodEnd,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Entitlement]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Entitlement copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? userId,
    _i34ejbb7.EntitlementSource? source,
    String? externalId,
    _iudzg4q8.EntitlementStatus? status,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Entitlement(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      userId: userId ?? this.userId,
      source: source ?? this.source,
      externalId: externalId ?? this.externalId,
      status: status ?? this.status,
      currentPeriodStart: currentPeriodStart ?? this.currentPeriodStart,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
