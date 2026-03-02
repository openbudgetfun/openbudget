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
import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// Response payload containing a wallet-signable login challenge.
abstract class SolanaWalletAuthChallengeResponse
    implements _i1.SerializableModel {
  SolanaWalletAuthChallengeResponse._({
    required this.challengeId,
    required this.message,
    required this.expiresAt,
  });

  factory SolanaWalletAuthChallengeResponse({
    required _i1.UuidValue challengeId,
    required String message,
    required DateTime expiresAt,
  }) = _SolanaWalletAuthChallengeResponseImpl;

  factory SolanaWalletAuthChallengeResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SolanaWalletAuthChallengeResponse(
      challengeId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['challengeId'],
      ),
      message: jsonSerialization['message'] as String,
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  _i1.UuidValue challengeId;

  String message;

  DateTime expiresAt;

  /// Returns a shallow copy of this [SolanaWalletAuthChallengeResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SolanaWalletAuthChallengeResponse copyWith({
    _i1.UuidValue? challengeId,
    String? message,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SolanaWalletAuthChallengeResponse',
      'challengeId': challengeId.toJson(),
      'message': message,
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _SolanaWalletAuthChallengeResponseImpl
    extends SolanaWalletAuthChallengeResponse {
  _SolanaWalletAuthChallengeResponseImpl({
    required _i1.UuidValue challengeId,
    required String message,
    required DateTime expiresAt,
  }) : super._(
         challengeId: challengeId,
         message: message,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [SolanaWalletAuthChallengeResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SolanaWalletAuthChallengeResponse copyWith({
    _i1.UuidValue? challengeId,
    String? message,
    DateTime? expiresAt,
  }) {
    return SolanaWalletAuthChallengeResponse(
      challengeId: challengeId ?? this.challengeId,
      message: message ?? this.message,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
