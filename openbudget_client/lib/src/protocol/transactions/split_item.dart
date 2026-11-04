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

/// A single split within a split transaction.
abstract class SplitItem
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SplitItem._({
    required this.amountCents,
    this.envelopeId,
    this.memo,
  });

  factory SplitItem({
    required int amountCents,
    _isc.UuidValue? envelopeId,
    String? memo,
  }) = _SplitItemImpl;

  factory SplitItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return SplitItem(
      amountCents: jsonSerialization['amountCents'] as int,
      envelopeId: jsonSerialization['envelopeId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['envelopeId'],
            ),
      memo: jsonSerialization['memo'] as String?,
    );
  }

  /// Amount in integer cents for this split.
  int amountCents;

  /// The envelope to assign this split to.
  _isc.UuidValue? envelopeId;

  /// Optional memo for this specific split.
  String? memo;

  /// Returns a shallow copy of this [SplitItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SplitItem copyWith({
    int? amountCents,
    _isc.UuidValue? envelopeId = const _isc.$UndefinedUuidValue(),
    String? memo,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SplitItem',
      'amountCents': amountCents,
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      if (memo != null) 'memo': memo,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SplitItem',
      'amountCents': amountCents,
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      if (memo != null) 'memo': memo,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SplitItemImpl extends SplitItem {
  _SplitItemImpl({
    required int amountCents,
    _isc.UuidValue? envelopeId,
    String? memo,
  }) : super._(
         amountCents: amountCents,
         envelopeId: envelopeId,
         memo: memo,
       );

  /// Returns a shallow copy of this [SplitItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SplitItem copyWith({
    int? amountCents,
    _isc.UuidValue? envelopeId = const _isc.$UndefinedUuidValue(),
    Object? memo = _Undefined,
  }) {
    return SplitItem(
      amountCents: amountCents ?? this.amountCents,
      envelopeId: envelopeId is _isc.UndefinedSentinel
          ? this.envelopeId
          : envelopeId,
      memo: memo is String? ? memo : this.memo,
    );
  }
}
