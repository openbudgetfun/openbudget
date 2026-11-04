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

/// The user's own provider settings, without the API key.
abstract class AgentProviderSettingsView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  AgentProviderSettingsView._({
    required this.baseUrl,
    required this.model,
    required this.keyHint,
  });

  factory AgentProviderSettingsView({
    required String baseUrl,
    required String model,
    required String keyHint,
  }) = _AgentProviderSettingsViewImpl;

  factory AgentProviderSettingsView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AgentProviderSettingsView(
      baseUrl: jsonSerialization['baseUrl'] as String,
      model: jsonSerialization['model'] as String,
      keyHint: jsonSerialization['keyHint'] as String,
    );
  }

  String baseUrl;

  String model;

  /// Last four characters of the stored key.
  String keyHint;

  /// Returns a shallow copy of this [AgentProviderSettingsView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AgentProviderSettingsView copyWith({
    String? baseUrl,
    String? model,
    String? keyHint,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentProviderSettingsView',
      'baseUrl': baseUrl,
      'model': model,
      'keyHint': keyHint,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AgentProviderSettingsView',
      'baseUrl': baseUrl,
      'model': model,
      'keyHint': keyHint,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _AgentProviderSettingsViewImpl extends AgentProviderSettingsView {
  _AgentProviderSettingsViewImpl({
    required String baseUrl,
    required String model,
    required String keyHint,
  }) : super._(
         baseUrl: baseUrl,
         model: model,
         keyHint: keyHint,
       );

  /// Returns a shallow copy of this [AgentProviderSettingsView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AgentProviderSettingsView copyWith({
    String? baseUrl,
    String? model,
    String? keyHint,
  }) {
    return AgentProviderSettingsView(
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      keyHint: keyHint ?? this.keyHint,
    );
  }
}
