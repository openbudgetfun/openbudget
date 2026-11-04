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

/// A user's own OpenAI-compatible provider for the financial assistant.
///
/// The API key is encrypted with AES-256-GCM before it reaches the database
/// and is never returned to a client.
abstract class AgentProviderSettings
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AgentProviderSettings._({
    this.id,
    required this.userId,
    required this.baseUrl,
    required this.model,
    required this.encryptedApiKey,
    required this.nonce,
    required this.keyHint,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory AgentProviderSettings({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    required String baseUrl,
    required String model,
    required String encryptedApiKey,
    required String nonce,
    required String keyHint,
    DateTime? updatedAt,
  }) = _AgentProviderSettingsImpl;

  factory AgentProviderSettings.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AgentProviderSettings(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      baseUrl: jsonSerialization['baseUrl'] as String,
      model: jsonSerialization['model'] as String,
      encryptedApiKey: jsonSerialization['encryptedApiKey'] as String,
      nonce: jsonSerialization['nonce'] as String,
      keyHint: jsonSerialization['keyHint'] as String,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue userId;

  /// HTTPS base URL of the provider's OpenAI-compatible API.
  String baseUrl;

  String model;

  /// Base64 AES-GCM ciphertext of the API key, including its MAC tag.
  String encryptedApiKey;

  /// Base64 nonce used for [encryptedApiKey].
  String nonce;

  /// The last four characters of the key, for display only.
  String keyHint;

  DateTime updatedAt;

  /// Returns a shallow copy of this [AgentProviderSettings]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AgentProviderSettings copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? userId,
    String? baseUrl,
    String? model,
    String? encryptedApiKey,
    String? nonce,
    String? keyHint,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentProviderSettings',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'baseUrl': baseUrl,
      'model': model,
      'encryptedApiKey': encryptedApiKey,
      'nonce': nonce,
      'keyHint': keyHint,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AgentProviderSettings',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'baseUrl': baseUrl,
      'model': model,
      'encryptedApiKey': encryptedApiKey,
      'nonce': nonce,
      'keyHint': keyHint,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AgentProviderSettingsImpl extends AgentProviderSettings {
  _AgentProviderSettingsImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    required String baseUrl,
    required String model,
    required String encryptedApiKey,
    required String nonce,
    required String keyHint,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         userId: userId,
         baseUrl: baseUrl,
         model: model,
         encryptedApiKey: encryptedApiKey,
         nonce: nonce,
         keyHint: keyHint,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AgentProviderSettings]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AgentProviderSettings copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? userId,
    String? baseUrl,
    String? model,
    String? encryptedApiKey,
    String? nonce,
    String? keyHint,
    DateTime? updatedAt,
  }) {
    return AgentProviderSettings(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      userId: userId ?? this.userId,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      encryptedApiKey: encryptedApiKey ?? this.encryptedApiKey,
      nonce: nonce ?? this.nonce,
      keyHint: keyHint ?? this.keyHint,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
