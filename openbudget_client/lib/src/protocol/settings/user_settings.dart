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

/// Per-user preferences that span entities.
abstract class UserSettings
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  UserSettings._({
    this.id,
    required this.userId,
    required this.reportingCurrencyCode,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory UserSettings({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    required String reportingCurrencyCode,
    DateTime? updatedAt,
  }) = _UserSettingsImpl;

  factory UserSettings.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserSettings(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      reportingCurrencyCode:
          jsonSerialization['reportingCurrencyCode'] as String,
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

  /// ISO 4217 code that combined net worth and cross-entity totals use.
  String reportingCurrencyCode;

  DateTime updatedAt;

  /// Returns a shallow copy of this [UserSettings]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  UserSettings copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? userId,
    String? reportingCurrencyCode,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserSettings',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'reportingCurrencyCode': reportingCurrencyCode,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserSettings',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'reportingCurrencyCode': reportingCurrencyCode,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _UserSettingsImpl extends UserSettings {
  _UserSettingsImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    required String reportingCurrencyCode,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         userId: userId,
         reportingCurrencyCode: reportingCurrencyCode,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [UserSettings]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  UserSettings copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? userId,
    String? reportingCurrencyCode,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      userId: userId ?? this.userId,
      reportingCurrencyCode:
          reportingCurrencyCode ?? this.reportingCurrencyCode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
