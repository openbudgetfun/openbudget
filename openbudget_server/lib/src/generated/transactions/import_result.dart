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
import 'package:openbudget_server/src/generated/protocol.dart' as _is0sbm8r;
import 'package:serverpod/serverpod.dart' as _is;

/// What `transaction.importRows` did.
abstract class ImportResult
    implements _is.SerializableModel, _is.ProtocolSerialization {
  ImportResult._({
    required this.insertedCount,
    required this.skippedDuplicateCount,
    required this.errors,
  });

  factory ImportResult({
    required int insertedCount,
    required int skippedDuplicateCount,
    required List<String> errors,
  }) = _ImportResultImpl;

  factory ImportResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return ImportResult(
      insertedCount: jsonSerialization['insertedCount'] as int,
      skippedDuplicateCount: jsonSerialization['skippedDuplicateCount'] as int,
      errors: _is0sbm8r.Protocol().deserialize<List<String>>(
        jsonSerialization['errors'],
      ),
    );
  }

  int insertedCount;

  /// Rows whose externalId already existed on the account.
  int skippedDuplicateCount;

  /// Rows rejected, with their 0-based index and reason.
  List<String> errors;

  /// Returns a shallow copy of this [ImportResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ImportResult copyWith({
    int? insertedCount,
    int? skippedDuplicateCount,
    List<String>? errors,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ImportResult',
      'insertedCount': insertedCount,
      'skippedDuplicateCount': skippedDuplicateCount,
      'errors': errors.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ImportResult',
      'insertedCount': insertedCount,
      'skippedDuplicateCount': skippedDuplicateCount,
      'errors': errors.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _ImportResultImpl extends ImportResult {
  _ImportResultImpl({
    required int insertedCount,
    required int skippedDuplicateCount,
    required List<String> errors,
  }) : super._(
         insertedCount: insertedCount,
         skippedDuplicateCount: skippedDuplicateCount,
         errors: errors,
       );

  /// Returns a shallow copy of this [ImportResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ImportResult copyWith({
    int? insertedCount,
    int? skippedDuplicateCount,
    List<String>? errors,
  }) {
    return ImportResult(
      insertedCount: insertedCount ?? this.insertedCount,
      skippedDuplicateCount:
          skippedDuplicateCount ?? this.skippedDuplicateCount,
      errors: errors ?? this.errors.map((e0) => e0).toList(),
    );
  }
}
