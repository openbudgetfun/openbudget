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

/// One envelope's amount in a budget template.
abstract class BudgetTemplateLine
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  BudgetTemplateLine._({
    this.id,
    required this.templateId,
    required this.envelopeId,
    required this.allocatedMinor,
  });

  factory BudgetTemplateLine({
    _isc.UuidValue? id,
    required _isc.UuidValue templateId,
    required _isc.UuidValue envelopeId,
    required int allocatedMinor,
  }) = _BudgetTemplateLineImpl;

  factory BudgetTemplateLine.fromJson(Map<String, dynamic> jsonSerialization) {
    return BudgetTemplateLine(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      templateId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['templateId'],
      ),
      envelopeId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['envelopeId'],
      ),
      allocatedMinor: jsonSerialization['allocatedMinor'] as int,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue templateId;

  _isc.UuidValue envelopeId;

  /// Base-currency minor units.
  int allocatedMinor;

  /// Returns a shallow copy of this [BudgetTemplateLine]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  BudgetTemplateLine copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? templateId,
    _isc.UuidValue? envelopeId,
    int? allocatedMinor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BudgetTemplateLine',
      if (id != null) 'id': id?.toJson(),
      'templateId': templateId.toJson(),
      'envelopeId': envelopeId.toJson(),
      'allocatedMinor': allocatedMinor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'BudgetTemplateLine',
      if (id != null) 'id': id?.toJson(),
      'templateId': templateId.toJson(),
      'envelopeId': envelopeId.toJson(),
      'allocatedMinor': allocatedMinor,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _BudgetTemplateLineImpl extends BudgetTemplateLine {
  _BudgetTemplateLineImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue templateId,
    required _isc.UuidValue envelopeId,
    required int allocatedMinor,
  }) : super._(
         id: id,
         templateId: templateId,
         envelopeId: envelopeId,
         allocatedMinor: allocatedMinor,
       );

  /// Returns a shallow copy of this [BudgetTemplateLine]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  BudgetTemplateLine copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? templateId,
    _isc.UuidValue? envelopeId,
    int? allocatedMinor,
  }) {
    return BudgetTemplateLine(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      templateId: templateId ?? this.templateId,
      envelopeId: envelopeId ?? this.envelopeId,
      allocatedMinor: allocatedMinor ?? this.allocatedMinor,
    );
  }
}
