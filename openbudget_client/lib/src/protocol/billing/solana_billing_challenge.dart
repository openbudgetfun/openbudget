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

/// A one-time wallet ownership challenge for a Solana subscription.
abstract class SolanaBillingChallenge
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SolanaBillingChallenge._({
    this.id,
    required this.userId,
    required this.message,
    required this.expiresAt,
    this.usedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SolanaBillingChallenge({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    required String message,
    required DateTime expiresAt,
    DateTime? usedAt,
    DateTime? createdAt,
  }) = _SolanaBillingChallengeImpl;

  factory SolanaBillingChallenge.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SolanaBillingChallenge(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      message: jsonSerialization['message'] as String,
      expiresAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      usedAt: jsonSerialization['usedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['usedAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue userId;

  String message;

  DateTime expiresAt;

  DateTime? usedAt;

  DateTime createdAt;

  /// Returns a shallow copy of this [SolanaBillingChallenge]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SolanaBillingChallenge copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? userId,
    String? message,
    DateTime? expiresAt,
    DateTime? usedAt = const _isc.$UndefinedDateTime(),
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SolanaBillingChallenge',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'message': message,
      'expiresAt': expiresAt.toJson(),
      if (usedAt != null) 'usedAt': usedAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SolanaBillingChallenge',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'message': message,
      'expiresAt': expiresAt.toJson(),
      if (usedAt != null) 'usedAt': usedAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _SolanaBillingChallengeImpl extends SolanaBillingChallenge {
  _SolanaBillingChallengeImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    required String message,
    required DateTime expiresAt,
    DateTime? usedAt,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         message: message,
         expiresAt: expiresAt,
         usedAt: usedAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [SolanaBillingChallenge]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SolanaBillingChallenge copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? userId,
    String? message,
    DateTime? expiresAt,
    DateTime? usedAt = const _isc.$UndefinedDateTime(),
    DateTime? createdAt,
  }) {
    return SolanaBillingChallenge(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      expiresAt: expiresAt ?? this.expiresAt,
      usedAt: usedAt is _isc.UndefinedSentinel ? this.usedAt : usedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
