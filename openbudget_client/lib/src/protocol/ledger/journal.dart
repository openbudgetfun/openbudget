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
import 'package:openbudget_core/openbudget_core.dart' as _ifz8weqz;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// A journal in an entity's books: a dated, referenced bundle of lines.
///
/// Drafts may be edited or deleted. Posted journals are immutable:
/// corrections are journals with reversalOfJournalId pointing back, and the
/// original flips to reversed. No update or delete path exists for posted
/// rows.
abstract class Journal
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Journal._({
    this.id,
    required this.entityId,
    required this.date,
    String? reference,
    this.narration,
    _ifz8weqz.JournalStatus? status,
    _ifz8weqz.JournalSource? source,
    this.sourceTransactionId,
    this.sourceRevision,
    this.postedAt,
    this.postedBy,
    this.reversalOfJournalId,
    DateTime? createdAt,
  }) : reference = reference ?? '',
       status = status ?? _ifz8weqz.JournalStatus.draft,
       source = source ?? _ifz8weqz.JournalSource.manual,
       createdAt = createdAt ?? DateTime.now();

  factory Journal({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required DateTime date,
    String? reference,
    String? narration,
    _ifz8weqz.JournalStatus? status,
    _ifz8weqz.JournalSource? source,
    _isc.UuidValue? sourceTransactionId,
    int? sourceRevision,
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
      entityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      date: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['date']),
      reference: jsonSerialization['reference'] as String?,
      narration: jsonSerialization['narration'] as String?,
      status: jsonSerialization['status'] == null
          ? null
          : _ifz8weqz.JournalStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      source: jsonSerialization['source'] == null
          ? null
          : _ifz8weqz.JournalSource.fromJson(
              (jsonSerialization['source'] as String),
            ),
      sourceTransactionId: jsonSerialization['sourceTransactionId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['sourceTransactionId'],
            ),
      sourceRevision: jsonSerialization['sourceRevision'] as int?,
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

  _isc.UuidValue entityId;

  /// Calendar date in the entity's time zone.
  DateTime date;

  /// Human reference, such as `JB-2026-0001`.
  String reference;

  String? narration;

  _ifz8weqz.JournalStatus status;

  _ifz8weqz.JournalSource source;

  /// The transaction this journal posts, when source is `transaction`.
  /// No foreign key: posted journals outlive deleted transactions.
  _isc.UuidValue? sourceTransactionId;

  /// The transaction revision this journal posts.
  int? sourceRevision;

  /// Server time of posting. Never trusted from the client.
  DateTime? postedAt;

  _isc.UuidValue? postedBy;

  /// The posted journal this one reverses, when source is `reversal`.
  _isc.UuidValue? reversalOfJournalId;

  DateTime createdAt;

  /// Returns a shallow copy of this [Journal]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Journal copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    DateTime? date,
    String? reference,
    String? narration,
    _ifz8weqz.JournalStatus? status,
    _ifz8weqz.JournalSource? source,
    _isc.UuidValue? sourceTransactionId = const _isc.$UndefinedUuidValue(),
    int? sourceRevision,
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
      'entityId': entityId.toJson(),
      'date': date.toJson(),
      'reference': reference,
      if (narration != null) 'narration': narration,
      'status': status.toJson(),
      'source': source.toJson(),
      if (sourceTransactionId != null)
        'sourceTransactionId': sourceTransactionId?.toJson(),
      if (sourceRevision != null) 'sourceRevision': sourceRevision,
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
      'entityId': entityId.toJson(),
      'date': date.toJson(),
      'reference': reference,
      if (narration != null) 'narration': narration,
      'status': status.toJson(),
      'source': source.toJson(),
      if (sourceTransactionId != null)
        'sourceTransactionId': sourceTransactionId?.toJson(),
      if (sourceRevision != null) 'sourceRevision': sourceRevision,
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
    required _isc.UuidValue entityId,
    required DateTime date,
    String? reference,
    String? narration,
    _ifz8weqz.JournalStatus? status,
    _ifz8weqz.JournalSource? source,
    _isc.UuidValue? sourceTransactionId,
    int? sourceRevision,
    DateTime? postedAt,
    _isc.UuidValue? postedBy,
    _isc.UuidValue? reversalOfJournalId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         entityId: entityId,
         date: date,
         reference: reference,
         narration: narration,
         status: status,
         source: source,
         sourceTransactionId: sourceTransactionId,
         sourceRevision: sourceRevision,
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
    _isc.UuidValue? entityId,
    DateTime? date,
    String? reference,
    Object? narration = _Undefined,
    _ifz8weqz.JournalStatus? status,
    _ifz8weqz.JournalSource? source,
    _isc.UuidValue? sourceTransactionId = const _isc.$UndefinedUuidValue(),
    Object? sourceRevision = _Undefined,
    DateTime? postedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? postedBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? reversalOfJournalId = const _isc.$UndefinedUuidValue(),
    DateTime? createdAt,
  }) {
    return Journal(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      date: date ?? this.date,
      reference: reference ?? this.reference,
      narration: narration is String? ? narration : this.narration,
      status: status ?? this.status,
      source: source ?? this.source,
      sourceTransactionId: sourceTransactionId is _isc.UndefinedSentinel
          ? this.sourceTransactionId
          : sourceTransactionId,
      sourceRevision: sourceRevision is int?
          ? sourceRevision
          : this.sourceRevision,
      postedAt: postedAt is _isc.UndefinedSentinel ? this.postedAt : postedAt,
      postedBy: postedBy is _isc.UndefinedSentinel ? this.postedBy : postedBy,
      reversalOfJournalId: reversalOfJournalId is _isc.UndefinedSentinel
          ? this.reversalOfJournalId
          : reversalOfJournalId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
