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

/// A grouping of envelopes within a budget.
abstract class Category implements _i1.SerializableModel {
  Category._({
    this.id,
    required this.name,
    required this.budgetId,
    required this.sortOrder,
    bool? isHidden,
    DateTime? createdAt,
  }) : isHidden = isHidden ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory Category({
    _i1.UuidValue? id,
    required String name,
    required _i1.UuidValue budgetId,
    required int sortOrder,
    bool? isHidden,
    DateTime? createdAt,
  }) = _CategoryImpl;

  factory Category.fromJson(Map<String, dynamic> jsonSerialization) {
    return Category(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      budgetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      sortOrder: jsonSerialization['sortOrder'] as int,
      isHidden: jsonSerialization['isHidden'] as bool?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  String name;

  _i1.UuidValue budgetId;

  int sortOrder;

  /// Whether this category is hidden from the default budget view.
  bool? isHidden;

  DateTime createdAt;

  /// Returns a shallow copy of this [Category]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Category copyWith({
    _i1.UuidValue? id,
    String? name,
    _i1.UuidValue? budgetId,
    int? sortOrder,
    bool? isHidden,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Category',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'budgetId': budgetId.toJson(),
      'sortOrder': sortOrder,
      if (isHidden != null) 'isHidden': isHidden,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CategoryImpl extends Category {
  _CategoryImpl({
    _i1.UuidValue? id,
    required String name,
    required _i1.UuidValue budgetId,
    required int sortOrder,
    bool? isHidden,
    DateTime? createdAt,
  }) : super._(
         id: id,
         name: name,
         budgetId: budgetId,
         sortOrder: sortOrder,
         isHidden: isHidden,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Category]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Category copyWith({
    Object? id = _Undefined,
    String? name,
    _i1.UuidValue? budgetId,
    int? sortOrder,
    Object? isHidden = _Undefined,
    DateTime? createdAt,
  }) {
    return Category(
      id: id is _i1.UuidValue? ? id : this.id,
      name: name ?? this.name,
      budgetId: budgetId ?? this.budgetId,
      sortOrder: sortOrder ?? this.sortOrder,
      isHidden: isHidden is bool? ? isHidden : this.isHidden,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
