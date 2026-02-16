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
import 'package:serverpod/serverpod.dart' as _i1;

/// A single row of data for bulk transaction import.
abstract class ImportRow
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ImportRow._({
    required this.description,
    required this.amountCents,
    required this.transactionDate,
  });

  factory ImportRow({
    required String description,
    required int amountCents,
    required DateTime transactionDate,
  }) = _ImportRowImpl;

  factory ImportRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return ImportRow(
      description: jsonSerialization['description'] as String,
      amountCents: jsonSerialization['amountCents'] as int,
      transactionDate: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['transactionDate'],
      ),
    );
  }

  String description;

  int amountCents;

  DateTime transactionDate;

  /// Returns a shallow copy of this [ImportRow]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ImportRow copyWith({
    String? description,
    int? amountCents,
    DateTime? transactionDate,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ImportRow',
      'description': description,
      'amountCents': amountCents,
      'transactionDate': transactionDate.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ImportRow',
      'description': description,
      'amountCents': amountCents,
      'transactionDate': transactionDate.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ImportRowImpl extends ImportRow {
  _ImportRowImpl({
    required String description,
    required int amountCents,
    required DateTime transactionDate,
  }) : super._(
         description: description,
         amountCents: amountCents,
         transactionDate: transactionDate,
       );

  /// Returns a shallow copy of this [ImportRow]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ImportRow copyWith({
    String? description,
    int? amountCents,
    DateTime? transactionDate,
  }) {
    return ImportRow(
      description: description ?? this.description,
      amountCents: amountCents ?? this.amountCents,
      transactionDate: transactionDate ?? this.transactionDate,
    );
  }
}
