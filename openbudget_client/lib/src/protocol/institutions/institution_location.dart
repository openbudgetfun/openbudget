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

/// Geographic availability and popularity metadata for an institution.
abstract class InstitutionLocation implements _i1.SerializableModel {
  InstitutionLocation._({
    this.id,
    required this.institutionId,
    required this.locationCode,
    bool? isPopular,
    this.popularityRank,
    DateTime? createdAt,
  }) : isPopular = isPopular ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory InstitutionLocation({
    _i1.UuidValue? id,
    required _i1.UuidValue institutionId,
    required String locationCode,
    bool? isPopular,
    int? popularityRank,
    DateTime? createdAt,
  }) = _InstitutionLocationImpl;

  factory InstitutionLocation.fromJson(Map<String, dynamic> jsonSerialization) {
    return InstitutionLocation(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      institutionId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['institutionId'],
      ),
      locationCode: jsonSerialization['locationCode'] as String,
      isPopular: jsonSerialization['isPopular'] as bool?,
      popularityRank: jsonSerialization['popularityRank'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue institutionId;

  /// ISO 3166 country code (e.g. US, GB) or regional marker (e.g. EU).
  String locationCode;

  /// Whether this institution should be shown in "Popular options" for location.
  bool isPopular;

  /// Lower rank means higher priority in popular ordering.
  int? popularityRank;

  DateTime createdAt;

  /// Returns a shallow copy of this [InstitutionLocation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  InstitutionLocation copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? institutionId,
    String? locationCode,
    bool? isPopular,
    int? popularityRank,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InstitutionLocation',
      if (id != null) 'id': id?.toJson(),
      'institutionId': institutionId.toJson(),
      'locationCode': locationCode,
      'isPopular': isPopular,
      if (popularityRank != null) 'popularityRank': popularityRank,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _InstitutionLocationImpl extends InstitutionLocation {
  _InstitutionLocationImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue institutionId,
    required String locationCode,
    bool? isPopular,
    int? popularityRank,
    DateTime? createdAt,
  }) : super._(
         id: id,
         institutionId: institutionId,
         locationCode: locationCode,
         isPopular: isPopular,
         popularityRank: popularityRank,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [InstitutionLocation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  InstitutionLocation copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? institutionId,
    String? locationCode,
    bool? isPopular,
    Object? popularityRank = _Undefined,
    DateTime? createdAt,
  }) {
    return InstitutionLocation(
      id: id is _i1.UuidValue? ? id : this.id,
      institutionId: institutionId ?? this.institutionId,
      locationCode: locationCode ?? this.locationCode,
      isPopular: isPopular ?? this.isPopular,
      popularityRank: popularityRank is int?
          ? popularityRank
          : this.popularityRank,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
