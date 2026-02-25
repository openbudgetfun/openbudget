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

/// Individual currency exchange rate value in a snapshot.
abstract class FxRateEntry implements _i1.SerializableModel {
  FxRateEntry._({
    this.id,
    required this.snapshotId,
    required this.currencyCode,
    required this.rate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory FxRateEntry({
    _i1.UuidValue? id,
    required _i1.UuidValue snapshotId,
    required String currencyCode,
    required double rate,
    DateTime? createdAt,
  }) = _FxRateEntryImpl;

  factory FxRateEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return FxRateEntry(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      snapshotId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['snapshotId'],
      ),
      currencyCode: jsonSerialization['currencyCode'] as String,
      rate: (jsonSerialization['rate'] as num).toDouble(),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue snapshotId;

  String currencyCode;

  double rate;

  DateTime createdAt;

  /// Returns a shallow copy of this [FxRateEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  FxRateEntry copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? snapshotId,
    String? currencyCode,
    double? rate,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FxRateEntry',
      if (id != null) 'id': id?.toJson(),
      'snapshotId': snapshotId.toJson(),
      'currencyCode': currencyCode,
      'rate': rate,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FxRateEntryImpl extends FxRateEntry {
  _FxRateEntryImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue snapshotId,
    required String currencyCode,
    required double rate,
    DateTime? createdAt,
  }) : super._(
         id: id,
         snapshotId: snapshotId,
         currencyCode: currencyCode,
         rate: rate,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [FxRateEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  FxRateEntry copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? snapshotId,
    String? currencyCode,
    double? rate,
    DateTime? createdAt,
  }) {
    return FxRateEntry(
      id: id is _i1.UuidValue? ? id : this.id,
      snapshotId: snapshotId ?? this.snapshotId,
      currencyCode: currencyCode ?? this.currencyCode,
      rate: rate ?? this.rate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
