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
import 'package:serverpod/serverpod.dart' as _is;

/// One envelope's new allocation in `budget.setAllocations`.
abstract class AllocationInput
    implements _is.SerializableModel, _is.ProtocolSerialization {
  AllocationInput._({
    required this.envelopeId,
    required this.allocatedMinor,
  });

  factory AllocationInput({
    required _is.UuidValue envelopeId,
    required int allocatedMinor,
  }) = _AllocationInputImpl;

  factory AllocationInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return AllocationInput(
      envelopeId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['envelopeId'],
      ),
      allocatedMinor: jsonSerialization['allocatedMinor'] as int,
    );
  }

  _is.UuidValue envelopeId;

  /// The new total for the month in base minor units. 0 deletes the row.
  int allocatedMinor;

  /// Returns a shallow copy of this [AllocationInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AllocationInput copyWith({
    _is.UuidValue? envelopeId,
    int? allocatedMinor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AllocationInput',
      'envelopeId': envelopeId.toJson(),
      'allocatedMinor': allocatedMinor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AllocationInput',
      'envelopeId': envelopeId.toJson(),
      'allocatedMinor': allocatedMinor,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _AllocationInputImpl extends AllocationInput {
  _AllocationInputImpl({
    required _is.UuidValue envelopeId,
    required int allocatedMinor,
  }) : super._(
         envelopeId: envelopeId,
         allocatedMinor: allocatedMinor,
       );

  /// Returns a shallow copy of this [AllocationInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AllocationInput copyWith({
    _is.UuidValue? envelopeId,
    int? allocatedMinor,
  }) {
    return AllocationInput(
      envelopeId: envelopeId ?? this.envelopeId,
      allocatedMinor: allocatedMinor ?? this.allocatedMinor,
    );
  }
}
