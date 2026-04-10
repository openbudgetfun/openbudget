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

/// Snapshot of exchange rates fetched from an upstream FX provider.
abstract class FxRateSnapshot implements _i1.SerializableModel {
  FxRateSnapshot._({
    this.id,
    required this.provider,
    required this.baseCurrencyCode,
    required this.fetchedAt,
    bool? isLatest,
    DateTime? createdAt,
  }) : isLatest = isLatest ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory FxRateSnapshot({
    _i1.UuidValue? id,
    required String provider,
    required String baseCurrencyCode,
    required DateTime fetchedAt,
    bool? isLatest,
    DateTime? createdAt,
  }) = _FxRateSnapshotImpl;

  factory FxRateSnapshot.fromJson(Map<String, dynamic> jsonSerialization) {
    return FxRateSnapshot(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      provider: jsonSerialization['provider'] as String,
      baseCurrencyCode: jsonSerialization['baseCurrencyCode'] as String,
      fetchedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['fetchedAt'],
      ),
      isLatest: jsonSerialization['isLatest'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isLatest']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  String provider;

  String baseCurrencyCode;

  DateTime fetchedAt;

  bool isLatest;

  DateTime createdAt;

  /// Returns a shallow copy of this [FxRateSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  FxRateSnapshot copyWith({
    _i1.UuidValue? id,
    String? provider,
    String? baseCurrencyCode,
    DateTime? fetchedAt,
    bool? isLatest,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FxRateSnapshot',
      if (id != null) 'id': id?.toJson(),
      'provider': provider,
      'baseCurrencyCode': baseCurrencyCode,
      'fetchedAt': fetchedAt.toJson(),
      'isLatest': isLatest,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FxRateSnapshotImpl extends FxRateSnapshot {
  _FxRateSnapshotImpl({
    _i1.UuidValue? id,
    required String provider,
    required String baseCurrencyCode,
    required DateTime fetchedAt,
    bool? isLatest,
    DateTime? createdAt,
  }) : super._(
         id: id,
         provider: provider,
         baseCurrencyCode: baseCurrencyCode,
         fetchedAt: fetchedAt,
         isLatest: isLatest,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [FxRateSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  FxRateSnapshot copyWith({
    Object? id = _Undefined,
    String? provider,
    String? baseCurrencyCode,
    DateTime? fetchedAt,
    bool? isLatest,
    DateTime? createdAt,
  }) {
    return FxRateSnapshot(
      id: id is _i1.UuidValue? ? id : this.id,
      provider: provider ?? this.provider,
      baseCurrencyCode: baseCurrencyCode ?? this.baseCurrencyCode,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      isLatest: isLatest ?? this.isLatest,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
