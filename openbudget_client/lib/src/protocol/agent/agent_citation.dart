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

/// One source behind a citation key in an assistant reply
/// (docs/money-guide.md, section 6).
///
/// A key can resolve to several sources: a knowledge card lists each of its
/// sources, and a tax report lists the authority pages it used.
abstract class AgentCitation
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AgentCitation._({
    required this.key,
    required this.title,
    required this.url,
    required this.authority,
    this.verifiedOn,
    required this.grade,
    required this.announced,
  });

  factory AgentCitation({
    required String key,
    required String title,
    required String url,
    required String authority,
    DateTime? verifiedOn,
    required String grade,
    required bool announced,
  }) = _AgentCitationImpl;

  factory AgentCitation.fromJson(Map<String, dynamic> jsonSerialization) {
    return AgentCitation(
      key: jsonSerialization['key'] as String,
      title: jsonSerialization['title'] as String,
      url: jsonSerialization['url'] as String,
      authority: jsonSerialization['authority'] as String,
      verifiedOn: jsonSerialization['verifiedOn'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['verifiedOn'],
            ),
      grade: jsonSerialization['grade'] as String,
      announced: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['announced'],
      ),
    );
  }

  /// The key the model wrote as `[^key]`: a card id or a tool `citeAs`.
  String key;

  /// What the source is called.
  String title;

  /// Where the source lives.
  String url;

  /// The authority that publishes it: the source's host without `www.`.
  String authority;

  /// When the source was last checked, as a date-only UTC value.
  DateTime? verifiedOn;

  /// `primary`, `secondary` or `inferred`.
  String grade;

  /// True when the source describes a rule that is not yet law.
  bool announced;

  /// Returns a shallow copy of this [AgentCitation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AgentCitation copyWith({
    String? key,
    String? title,
    String? url,
    String? authority,
    DateTime? verifiedOn = const _isc.$UndefinedDateTime(),
    String? grade,
    bool? announced,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentCitation',
      'key': key,
      'title': title,
      'url': url,
      'authority': authority,
      if (verifiedOn != null) 'verifiedOn': verifiedOn?.toJson(),
      'grade': grade,
      'announced': announced,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AgentCitation',
      'key': key,
      'title': title,
      'url': url,
      'authority': authority,
      if (verifiedOn != null) 'verifiedOn': verifiedOn?.toJson(),
      'grade': grade,
      'announced': announced,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AgentCitationImpl extends AgentCitation {
  _AgentCitationImpl({
    required String key,
    required String title,
    required String url,
    required String authority,
    DateTime? verifiedOn,
    required String grade,
    required bool announced,
  }) : super._(
         key: key,
         title: title,
         url: url,
         authority: authority,
         verifiedOn: verifiedOn,
         grade: grade,
         announced: announced,
       );

  /// Returns a shallow copy of this [AgentCitation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AgentCitation copyWith({
    String? key,
    String? title,
    String? url,
    String? authority,
    DateTime? verifiedOn = const _isc.$UndefinedDateTime(),
    String? grade,
    bool? announced,
  }) {
    return AgentCitation(
      key: key ?? this.key,
      title: title ?? this.title,
      url: url ?? this.url,
      authority: authority ?? this.authority,
      verifiedOn: verifiedOn is _isc.UndefinedSentinel
          ? this.verifiedOn
          : verifiedOn,
      grade: grade ?? this.grade,
      announced: announced ?? this.announced,
    );
  }
}
