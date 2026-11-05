import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Creates, lists, revokes and authenticates personal access tokens.
///
/// A token is a bearer secret for one user. Only its SHA-256 hash is stored,
/// so a created token is returned to the user once and can never be recovered.
class AgentAccessTokenService {
  AgentAccessTokenService({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  /// The prefix every OpenBudget access token carries.
  static const String tokenScheme = 'obk_';

  /// The most active tokens one user may hold at once.
  static const int maxActiveTokens = 10;

  static const int _maxNameLength = 60;
  static const int _tokenBytes = 32;
  static const int _displayPrefixLength = 12;
  static const Duration _lastUsedResolution = Duration(minutes: 1);

  final DateTime Function() _clock;

  /// Creates a token and returns its secret exactly once.
  Future<AgentAccessTokenCreated> create(
    Session session, {
    required UuidValue userId,
    required String name,
    required bool canPropose,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > _maxNameLength) {
      throw ValidationException(
        message: 'name must be between 1 and $_maxNameLength characters.',
      );
    }

    final active = await AgentAccessToken.db.count(
      session,
      where: (t) => t.userId.equals(userId) & t.revokedAt.equals(null),
    );
    if (active >= maxActiveTokens) {
      throw ValidationException(
        message:
            'A user can have at most $maxActiveTokens unrevoked access tokens.',
      );
    }

    final secret = generateToken();
    final token = await AgentAccessToken.db.insertRow(
      session,
      AgentAccessToken(
        userId: userId,
        name: trimmed,
        tokenHash: hashToken(secret),
        tokenPrefix: secret.substring(0, _displayPrefixLength),
        canPropose: canPropose,
        createdAt: _clock().toUtc(),
      ),
    );
    return AgentAccessTokenCreated(token: secret, view: view(token));
  }

  /// Lists every token the user owns, newest first.
  Future<List<AgentAccessTokenView>> list(
    Session session,
    UuidValue userId,
  ) async {
    final rows = await AgentAccessToken.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.createdAt.desc(),
    );
    return [for (final row in rows) view(row)];
  }

  /// Revokes one of the user's tokens. Revoking twice is harmless.
  Future<AgentAccessTokenView> revoke(
    Session session, {
    required UuidValue userId,
    required UuidValue id,
  }) async {
    final token = await AgentAccessToken.db.findById(session, id);
    if (token == null || token.userId != userId) {
      throw NotFoundException(message: 'Access token not found');
    }
    if (token.revokedAt != null) return view(token);

    final revoked = await AgentAccessToken.db.updateRow(
      session,
      token.copyWith(revokedAt: _clock().toUtc()),
    );
    return view(revoked);
  }

  /// Returns the token for a bearer header, or null when it cannot be used.
  ///
  /// The stored hash is compared in constant time, and [AgentAccessToken.lastUsedAt]
  /// is recorded at most once per minute.
  Future<AgentAccessToken?> authenticate(
    Session session,
    String? authorization,
  ) async {
    final secret = bearerToken(authorization);
    if (secret == null) return null;

    final hash = hashToken(secret);
    final token = await AgentAccessToken.db.findFirstRow(
      session,
      where: (t) => t.tokenHash.equals(hash),
    );
    if (token == null || !constantTimeEquals(token.tokenHash, hash)) {
      return null;
    }
    if (token.revokedAt != null) return null;

    final now = _clock().toUtc();
    final lastUsedAt = token.lastUsedAt;
    if (lastUsedAt == null ||
        now.difference(lastUsedAt.toUtc()) >= _lastUsedResolution) {
      return AgentAccessToken.db.updateRow(
        session,
        token.copyWith(lastUsedAt: now),
      );
    }
    return token;
  }

  /// Reads the secret from an `Authorization: Bearer <token>` header.
  static String? bearerToken(String? authorization) {
    if (authorization == null) return null;
    final match = RegExp(
      r'^\s*Bearer\s+(\S+)\s*$',
      caseSensitive: false,
    ).firstMatch(authorization);
    return match?.group(1);
  }

  /// Generates a new token: [tokenScheme] plus 32 random bytes, base64url
  /// encoded without padding.
  static String generateToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(_tokenBytes, (_) => random.nextInt(256));
    return '$tokenScheme${base64UrlEncode(bytes).replaceAll('=', '')}';
  }

  /// Returns the lowercase hex SHA-256 of [secret].
  static String hashToken(String secret) =>
      sha256.convert(utf8.encode(secret)).toString();

  /// Converts a stored row to its public view.
  static AgentAccessTokenView view(AgentAccessToken token) =>
      AgentAccessTokenView(
        id: token.id!,
        name: token.name,
        tokenPrefix: token.tokenPrefix,
        canPropose: token.canPropose,
        createdAt: token.createdAt,
        lastUsedAt: token.lastUsedAt,
        revokedAt: token.revokedAt,
      );

  /// Compares two equal-length hex digests without early exit.
  static bool constantTimeEquals(String first, String second) {
    if (first.length != second.length) return false;
    var difference = 0;
    for (var index = 0; index < first.length; index++) {
      difference |= first.codeUnitAt(index) ^ second.codeUnitAt(index);
    }
    return difference == 0;
  }
}
