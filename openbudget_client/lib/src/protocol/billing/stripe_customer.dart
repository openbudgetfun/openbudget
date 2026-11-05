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

/// Links an OpenBudget user to their Stripe customer for billing portal and
/// checkout reuse.
abstract class StripeCustomer
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  StripeCustomer._({
    this.id,
    required this.userId,
    required this.customerId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory StripeCustomer({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    required String customerId,
    DateTime? createdAt,
  }) = _StripeCustomerImpl;

  factory StripeCustomer.fromJson(Map<String, dynamic> jsonSerialization) {
    return StripeCustomer(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      customerId: jsonSerialization['customerId'] as String,
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

  String customerId;

  DateTime createdAt;

  /// Returns a shallow copy of this [StripeCustomer]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  StripeCustomer copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? userId,
    String? customerId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StripeCustomer',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'customerId': customerId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'StripeCustomer',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'customerId': customerId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _StripeCustomerImpl extends StripeCustomer {
  _StripeCustomerImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    required String customerId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         customerId: customerId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [StripeCustomer]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  StripeCustomer copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? userId,
    String? customerId,
    DateTime? createdAt,
  }) {
    return StripeCustomer(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      userId: userId ?? this.userId,
      customerId: customerId ?? this.customerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
