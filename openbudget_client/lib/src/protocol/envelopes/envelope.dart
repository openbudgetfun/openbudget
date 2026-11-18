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

/// A pot of money for one purpose in an entity's envelope plan. Its
/// activity and available balance are derived, never stored.
abstract class Envelope
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Envelope._({
    this.id,
    required this.entityId,
    required this.categoryId,
    required this.name,
    int? sortOrder,
    this.note,
    this.taxCategoryCode,
    this.defaultLedgerAccountId,
    bool? isHidden,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : sortOrder = sortOrder ?? 0,
       isHidden = isHidden ?? false,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Envelope({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required _isc.UuidValue categoryId,
    required String name,
    int? sortOrder,
    String? note,
    String? taxCategoryCode,
    _isc.UuidValue? defaultLedgerAccountId,
    bool? isHidden,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _EnvelopeImpl;

  factory Envelope.fromJson(Map<String, dynamic> jsonSerialization) {
    return Envelope(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      categoryId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['categoryId'],
      ),
      name: jsonSerialization['name'] as String,
      sortOrder: jsonSerialization['sortOrder'] as int?,
      note: jsonSerialization['note'] as String?,
      taxCategoryCode: jsonSerialization['taxCategoryCode'] as String?,
      defaultLedgerAccountId:
          jsonSerialization['defaultLedgerAccountId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['defaultLedgerAccountId'],
            ),
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

  _isc.UuidValue categoryId;

  String name;

  int sortOrder;

  String? note;

  /// Default tax category for lines assigned to this envelope.
  String? taxCategoryCode;

  /// Default ledger account for lines assigned to this envelope in
  /// ledger-mode books.
  _isc.UuidValue? defaultLedgerAccountId;

  bool isHidden;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [Envelope]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Envelope copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    _isc.UuidValue? categoryId,
    String? name,
    int? sortOrder,
    String? note,
    String? taxCategoryCode,
    _isc.UuidValue? defaultLedgerAccountId = const _isc.$UndefinedUuidValue(),
    bool? isHidden,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Envelope',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'categoryId': categoryId.toJson(),
      'name': name,
      'sortOrder': sortOrder,
      if (note != null) 'note': note,
      if (taxCategoryCode != null) 'taxCategoryCode': taxCategoryCode,
      if (defaultLedgerAccountId != null)
        'defaultLedgerAccountId': defaultLedgerAccountId?.toJson(),
      'isHidden': isHidden,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Envelope',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'categoryId': categoryId.toJson(),
      'name': name,
      'sortOrder': sortOrder,
      if (note != null) 'note': note,
      if (taxCategoryCode != null) 'taxCategoryCode': taxCategoryCode,
      if (defaultLedgerAccountId != null)
        'defaultLedgerAccountId': defaultLedgerAccountId?.toJson(),
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

class _Undefined {}

class _EnvelopeImpl extends Envelope {
  _EnvelopeImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required _isc.UuidValue categoryId,
    required String name,
    int? sortOrder,
    String? note,
    String? taxCategoryCode,
    _isc.UuidValue? defaultLedgerAccountId,
    bool? isHidden,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         entityId: entityId,
         categoryId: categoryId,
         name: name,
         sortOrder: sortOrder,
         note: note,
         taxCategoryCode: taxCategoryCode,
         defaultLedgerAccountId: defaultLedgerAccountId,
         isHidden: isHidden,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Envelope]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Envelope copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    _isc.UuidValue? categoryId,
    String? name,
    int? sortOrder,
    Object? note = _Undefined,
    Object? taxCategoryCode = _Undefined,
    _isc.UuidValue? defaultLedgerAccountId = const _isc.$UndefinedUuidValue(),
    bool? isHidden,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Envelope(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      note: note is String? ? note : this.note,
      taxCategoryCode: taxCategoryCode is String?
          ? taxCategoryCode
          : this.taxCategoryCode,
      defaultLedgerAccountId: defaultLedgerAccountId is _isc.UndefinedSentinel
          ? this.defaultLedgerAccountId
          : defaultLedgerAccountId,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
