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
import 'package:openbudget_client/src/protocol/protocol.dart' as _irkl4crj;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// One thing a rule pack could not verify, in plain language, as data
/// (docs/tax-jurisdictions.md, section 5.4). A report carries only the
/// caveats that touch the sections and rule keys it used.
abstract class TaxRuleCaveatView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TaxRuleCaveatView._({
    required this.id,
    required this.text,
    required this.grade,
    required this.sections,
    required this.keys,
    required this.recheckBy,
    required this.announced,
  });

  factory TaxRuleCaveatView({
    required String id,
    required String text,
    required String grade,
    required List<String> sections,
    required List<String> keys,
    required DateTime recheckBy,
    required bool announced,
  }) = _TaxRuleCaveatViewImpl;

  factory TaxRuleCaveatView.fromJson(Map<String, dynamic> jsonSerialization) {
    return TaxRuleCaveatView(
      id: jsonSerialization['id'] as String,
      text: jsonSerialization['text'] as String,
      grade: jsonSerialization['grade'] as String,
      sections: _irkl4crj.Protocol().deserialize<List<String>>(
        jsonSerialization['sections'],
      ),
      keys: _irkl4crj.Protocol().deserialize<List<String>>(
        jsonSerialization['keys'],
      ),
      recheckBy: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['recheckBy'],
      ),
      announced: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['announced'],
      ),
    );
  }

  /// Stable identifier, prefixed by country: `gb.student-loan-unearned-threshold`.
  String id;

  /// One plain sentence saying what could not be verified.
  String text;

  /// `primary`, `secondary` or `inferred`.
  String grade;

  /// The report sections the caveat touches, by section name.
  List<String> sections;

  /// The rule keys and figure ids the caveat touches.
  List<String> keys;

  /// The last day the caveat is trusted without a re-check.
  DateTime recheckBy;

  /// True when the caveat describes a change announced but not yet law.
  bool announced;

  /// Returns a shallow copy of this [TaxRuleCaveatView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TaxRuleCaveatView copyWith({
    String? id,
    String? text,
    String? grade,
    List<String>? sections,
    List<String>? keys,
    DateTime? recheckBy,
    bool? announced,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TaxRuleCaveatView',
      'id': id,
      'text': text,
      'grade': grade,
      'sections': sections.toJson(),
      'keys': keys.toJson(),
      'recheckBy': recheckBy.toJson(),
      'announced': announced,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TaxRuleCaveatView',
      'id': id,
      'text': text,
      'grade': grade,
      'sections': sections.toJson(),
      'keys': keys.toJson(),
      'recheckBy': recheckBy.toJson(),
      'announced': announced,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _TaxRuleCaveatViewImpl extends TaxRuleCaveatView {
  _TaxRuleCaveatViewImpl({
    required String id,
    required String text,
    required String grade,
    required List<String> sections,
    required List<String> keys,
    required DateTime recheckBy,
    required bool announced,
  }) : super._(
         id: id,
         text: text,
         grade: grade,
         sections: sections,
         keys: keys,
         recheckBy: recheckBy,
         announced: announced,
       );

  /// Returns a shallow copy of this [TaxRuleCaveatView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TaxRuleCaveatView copyWith({
    String? id,
    String? text,
    String? grade,
    List<String>? sections,
    List<String>? keys,
    DateTime? recheckBy,
    bool? announced,
  }) {
    return TaxRuleCaveatView(
      id: id ?? this.id,
      text: text ?? this.text,
      grade: grade ?? this.grade,
      sections: sections ?? this.sections.map((e0) => e0).toList(),
      keys: keys ?? this.keys.map((e0) => e0).toList(),
      recheckBy: recheckBy ?? this.recheckBy,
      announced: announced ?? this.announced,
    );
  }
}
