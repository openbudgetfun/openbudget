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

/// A journal in a budget's books: a dated, referenced bundle of lines.
///
/// Drafts may be edited or deleted. Posted journals are immutable —
/// corrections are [Journal]s with `reversalOfJournalId` pointing back, and
/// the original flips to `reversed`. No update or delete path exists for
/// posted rows.
abstract class Journal
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Journal._({
    this.id,
    required this.budgetId,
    required this.date,
    String? reference,
    this.narration,
    String? status,
    String? source,
    this.postedAt,
    this.postedBy,
    this.reversalOfJournalId,
    DateTime? createdAt,
  }) : reference = reference ?? '',
       status = status ?? 'draft',
       source = source ?? 'manual',
       createdAt = createdAt ?? DateTime.now();

  factory Journal({
    _isc.UuidValue? id,
    required _isc.UuidValue budgetId,
    required DateTime date,
    String? reference,
    String? narration,
    String? status,
    String? source,
    DateTime? postedAt,
    _isc.UuidValue? postedBy,
    _isc.UuidValue? reversalOfJournalId,
    DateTime? createdAt,
  }) = _JournalImpl;

  factory Journal.fromJson(Map<String, dynamic> jsonSerialization) {
    return Journal(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      budgetId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      date: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['date']),
      reference: jsonSerialization['reference'] as String?,
      narration: jsonSerialization['narration'] as String?,
      status: jsonSerialization['status'] as String?,
      source: jsonSerialization['source'] as String?,
      postedAt: jsonSerialization['postedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['postedAt']),
      postedBy: jsonSerialization['postedBy'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['postedBy']),
      reversalOfJournalId: jsonSerialization['reversalOfJournalId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['reversalOfJournalId'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue budgetId;

  /// Calendar date in the budget's time zone, not a UTC instant.
  DateTime date;

  /// Human reference, such as `JB-2026-0001`.
  String reference;

  /// Optional narrative.
  String? narration;

  /// JournalStatus name: draft, posted or reversed.
  String status;

  /// JournalSource name: manual, opening, import or reversal.
  String source;

  /// Server time of posting. Never trusted from the client.
  DateTime? postedAt;

  /// The user who posted the journal.
  _isc.UuidValue? postedBy;

  /// The posted journal this one reverses, when source is `reversal`.
  _isc.UuidValue? reversalOfJournalId;

  DateTime createdAt;

  /// Returns a shallow copy of this [Journal]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Journal copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? budgetId,
    DateTime? date,
    String? reference,
    String? narration,
    String? status,
    String? source,
    DateTime? postedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? postedBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? reversalOfJournalId = const _isc.$UndefinedUuidValue(),
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Journal',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'date': date.toJson(),
      'reference': reference,
      if (narration != null) 'narration': narration,
      'status': status,
      'source': source,
      if (postedAt != null) 'postedAt': postedAt?.toJson(),
      if (postedBy != null) 'postedBy': postedBy?.toJson(),
      if (reversalOfJournalId != null)
        'reversalOfJournalId': reversalOfJournalId?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Journal',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'date': date.toJson(),
      'reference': reference,
      if (narration != null) 'narration': narration,
      'status': status,
      'source': source,
      if (postedAt != null) 'postedAt': postedAt?.toJson(),
      if (postedBy != null) 'postedBy': postedBy?.toJson(),
      if (reversalOfJournalId != null)
        'reversalOfJournalId': reversalOfJournalId?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _JournalImpl extends Journal {
  _JournalImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue budgetId,
    required DateTime date,
    String? reference,
    String? narration,
    String? status,
    String? source,
    DateTime? postedAt,
    _isc.UuidValue? postedBy,
    _isc.UuidValue? reversalOfJournalId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         budgetId: budgetId,
         date: date,
         reference: reference,
         narration: narration,
         status: status,
         source: source,
         postedAt: postedAt,
         postedBy: postedBy,
         reversalOfJournalId: reversalOfJournalId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Journal]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Journal copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? budgetId,
    DateTime? date,
    String? reference,
    Object? narration = _Undefined,
    String? status,
    String? source,
    DateTime? postedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? postedBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? reversalOfJournalId = const _isc.$UndefinedUuidValue(),
    DateTime? createdAt,
  }) {
    return Journal(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      budgetId: budgetId ?? this.budgetId,
      date: date ?? this.date,
      reference: reference ?? this.reference,
      narration: narration is String? ? narration : this.narration,
      status: status ?? this.status,
      source: source ?? this.source,
      postedAt: postedAt is _isc.UndefinedSentinel ? this.postedAt : postedAt,
      postedBy: postedBy is _isc.UndefinedSentinel ? this.postedBy : postedBy,
      reversalOfJournalId: reversalOfJournalId is _isc.UndefinedSentinel
          ? this.reversalOfJournalId
          : reversalOfJournalId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
