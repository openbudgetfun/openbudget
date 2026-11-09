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

/// A group of envelopes in an entity's envelope plan.
abstract class Category
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Category._({
    this.id,
    required this.entityId,
    required this.name,
    int? sortOrder,
    bool? isHidden,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : sortOrder = sortOrder ?? 0,
       isHidden = isHidden ?? false,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Category({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required String name,
    int? sortOrder,
    bool? isHidden,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CategoryImpl;

  factory Category.fromJson(Map<String, dynamic> jsonSerialization) {
    return Category(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      name: jsonSerialization['name'] as String,
      sortOrder: jsonSerialization['sortOrder'] as int?,
      isHidden: jsonSerialization['isHidden'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['isHidden']),
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

  _isc.UuidValue entityId;

  String name;

  int sortOrder;

  /// Hidden categories are left out of the default Plan view.
  bool isHidden;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [Category]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Category copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    String? name,
    int? sortOrder,
    bool? isHidden,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Category',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'name': name,
      'sortOrder': sortOrder,
      'isHidden': isHidden,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Category',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'name': name,
      'sortOrder': sortOrder,
      'isHidden': isHidden,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CategoryImpl extends Category {
  _CategoryImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required String name,
    int? sortOrder,
    bool? isHidden,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         entityId: entityId,
         name: name,
         sortOrder: sortOrder,
         isHidden: isHidden,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Category]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Category copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    String? name,
    int? sortOrder,
    bool? isHidden,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
