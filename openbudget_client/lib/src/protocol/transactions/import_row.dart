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

/// One row of a bulk import into one account.
abstract class ImportRow
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ImportRow._({
    required this.date,
    required this.amountMinor,
    required this.description,
    this.payeeName,
    this.memo,
    this.externalId,
  });

  factory ImportRow({
    required DateTime date,
    required int amountMinor,
    required String description,
    String? payeeName,
    String? memo,
    String? externalId,
  }) = _ImportRowImpl;

  factory ImportRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return ImportRow(
      date: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['date']),
      amountMinor: jsonSerialization['amountMinor'] as int,
      description: jsonSerialization['description'] as String,
      payeeName: jsonSerialization['payeeName'] as String?,
      memo: jsonSerialization['memo'] as String?,
      externalId: jsonSerialization['externalId'] as String?,
    );
  }

  /// Calendar date.
  DateTime date;

  /// Signed amount in the account's minor units.
  int amountMinor;

  String description;

  String? payeeName;

  String? memo;

  /// Stable id from the source. When null the server derives
  /// `csv:<sha256(date|amountMinor|description|n)>`, where n counts identical
  /// rows earlier in the same file.
  String? externalId;

  /// Returns a shallow copy of this [ImportRow]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ImportRow copyWith({
    DateTime? date,
    int? amountMinor,
    String? description,
    String? payeeName,
    String? memo,
    String? externalId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ImportRow',
      'date': date.toJson(),
      'amountMinor': amountMinor,
      'description': description,
      if (payeeName != null) 'payeeName': payeeName,
      if (memo != null) 'memo': memo,
      if (externalId != null) 'externalId': externalId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ImportRow',
      'date': date.toJson(),
      'amountMinor': amountMinor,
      'description': description,
      if (payeeName != null) 'payeeName': payeeName,
      if (memo != null) 'memo': memo,
      if (externalId != null) 'externalId': externalId,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ImportRowImpl extends ImportRow {
  _ImportRowImpl({
    required DateTime date,
    required int amountMinor,
    required String description,
    String? payeeName,
    String? memo,
    String? externalId,
  }) : super._(
         date: date,
         amountMinor: amountMinor,
         description: description,
         payeeName: payeeName,
         memo: memo,
         externalId: externalId,
       );

  /// Returns a shallow copy of this [ImportRow]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ImportRow copyWith({
    DateTime? date,
    int? amountMinor,
    String? description,
    Object? payeeName = _Undefined,
    Object? memo = _Undefined,
    Object? externalId = _Undefined,
  }) {
    return ImportRow(
      date: date ?? this.date,
      amountMinor: amountMinor ?? this.amountMinor,
      description: description ?? this.description,
      payeeName: payeeName is String? ? payeeName : this.payeeName,
      memo: memo is String? ? memo : this.memo,
      externalId: externalId is String? ? externalId : this.externalId,
    );
  }
}
