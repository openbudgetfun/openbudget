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

/// Catalog entry for a financial institution that can be linked to accounts.
abstract class Institution implements _i1.SerializableModel {
  Institution._({
    this.id,
    required this.slug,
    required this.name,
    this.website,
    this.plaidInstitutionId,
    bool? isDigitalBank,
    DateTime? createdAt,
  }) : isDigitalBank = isDigitalBank ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory Institution({
    _i1.UuidValue? id,
    required String slug,
    required String name,
    String? website,
    String? plaidInstitutionId,
    bool? isDigitalBank,
    DateTime? createdAt,
  }) = _InstitutionImpl;

  factory Institution.fromJson(Map<String, dynamic> jsonSerialization) {
    return Institution(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      slug: jsonSerialization['slug'] as String,
      name: jsonSerialization['name'] as String,
      website: jsonSerialization['website'] as String?,
      plaidInstitutionId: jsonSerialization['plaidInstitutionId'] as String?,
      isDigitalBank: jsonSerialization['isDigitalBank'] as bool?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  /// Stable identifier used for idempotent catalog seeding.
  String slug;

  /// Institution display name.
  String name;

  /// Optional homepage domain for discovery/search.
  String? website;

  /// Optional Plaid institution id, when known.
  String? plaidInstitutionId;

  /// Marks digital-first challengers (e.g., Monzo, Revolut, Wise).
  bool isDigitalBank;

  DateTime createdAt;

  /// Returns a shallow copy of this [Institution]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Institution copyWith({
    _i1.UuidValue? id,
    String? slug,
    String? name,
    String? website,
    String? plaidInstitutionId,
    bool? isDigitalBank,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Institution',
      if (id != null) 'id': id?.toJson(),
      'slug': slug,
      'name': name,
      if (website != null) 'website': website,
      if (plaidInstitutionId != null) 'plaidInstitutionId': plaidInstitutionId,
      'isDigitalBank': isDigitalBank,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _InstitutionImpl extends Institution {
  _InstitutionImpl({
    _i1.UuidValue? id,
    required String slug,
    required String name,
    String? website,
    String? plaidInstitutionId,
    bool? isDigitalBank,
    DateTime? createdAt,
  }) : super._(
         id: id,
         slug: slug,
         name: name,
         website: website,
         plaidInstitutionId: plaidInstitutionId,
         isDigitalBank: isDigitalBank,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Institution]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Institution copyWith({
    Object? id = _Undefined,
    String? slug,
    String? name,
    Object? website = _Undefined,
    Object? plaidInstitutionId = _Undefined,
    bool? isDigitalBank,
    DateTime? createdAt,
  }) {
    return Institution(
      id: id is _i1.UuidValue? ? id : this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      website: website is String? ? website : this.website,
      plaidInstitutionId: plaidInstitutionId is String?
          ? plaidInstitutionId
          : this.plaidInstitutionId,
      isDigitalBank: isDigitalBank ?? this.isDigitalBank,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
