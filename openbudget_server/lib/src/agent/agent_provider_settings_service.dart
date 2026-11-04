import 'package:openbudget_server/src/agent/agent_secret_box.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// A decrypted BYO provider, ready for one call.
class AgentByoProvider {
  const AgentByoProvider({
    required this.endpoint,
    required this.model,
    required this.apiKey,
  });

  final Uri endpoint;
  final String model;
  final String apiKey;
}

/// Stores a user's own OpenAI-compatible provider.
///
/// Only the ciphertext, nonce and last four characters of the key reach the
/// database. The key itself is never returned to a client.
abstract final class AgentProviderSettingsService {
  static const String _encryptionKeyPassword = 'agentKeyEncryptionKey';

  /// Validates and normalises a base URL, which must use HTTPS.
  static Uri baseUri(String baseUrl) {
    final trimmed = baseUrl.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      throw ValidationException(
        'baseUrl must be an HTTPS URL without credentials.',
      );
    }

    final path = uri.path.endsWith('/')
        ? uri.path.substring(0, uri.path.length - 1)
        : uri.path;
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: path,
    );
  }

  /// The completions endpoint for a saved base URL.
  static Uri chatCompletionsUri(String baseUrl) {
    final uri = baseUri(baseUrl);
    final path = uri.path.endsWith('/chat/completions')
        ? uri.path
        : '${uri.path}/chat/completions';
    return uri.replace(path: path);
  }

  /// Returns the stored provider, or null when the user has not saved one.
  static Future<AgentByoProvider?> byoProvider(
    Session session,
    UuidValue userId,
  ) async {
    final settings = await AgentProviderSettings.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );
    if (settings == null) return null;

    final encryptionKey = session.passwords[_encryptionKeyPassword];
    if (encryptionKey == null || encryptionKey.trim().isEmpty) {
      throw AgentProviderUnavailableException(
        'agentKeyEncryptionKey is not configured.',
      );
    }
    final apiKey = await AgentSecretBox.open(
      cipherText: settings.encryptedApiKey,
      nonce: settings.nonce,
      base64Key: encryptionKey,
    );
    return AgentByoProvider(
      endpoint: chatCompletionsUri(settings.baseUrl),
      model: settings.model,
      apiKey: apiKey,
    );
  }

  /// Returns the public view of the user's provider settings.
  static Future<AgentProviderSettingsView?> view(
    Session session,
    UuidValue userId,
  ) async {
    final settings = await AgentProviderSettings.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );
    if (settings == null) return null;
    return AgentProviderSettingsView(
      baseUrl: settings.baseUrl,
      model: settings.model,
      keyHint: settings.keyHint,
    );
  }

  /// Creates or replaces the user's provider settings.
  static Future<AgentProviderSettingsView> save(
    Session session, {
    required UuidValue userId,
    required String baseUrl,
    required String model,
    required String apiKey,
  }) async {
    final base = baseUri(baseUrl);
    final trimmedModel = model.trim();
    if (trimmedModel.isEmpty) {
      throw ValidationException('model must not be empty.');
    }
    final trimmedKey = apiKey.trim();
    if (trimmedKey.isEmpty) {
      throw ValidationException('apiKey must not be empty.');
    }

    final encryptionKey = session.passwords[_encryptionKeyPassword];
    if (encryptionKey == null || encryptionKey.trim().isEmpty) {
      throw AgentProviderUnavailableException(
        'agentKeyEncryptionKey is not configured.',
      );
    }
    final sealed = await AgentSecretBox.seal(
      plaintext: trimmedKey,
      base64Key: encryptionKey,
    );
    final now = DateTime.now().toUtc();
    final existing = await AgentProviderSettings.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );

    final storedBaseUrl = base.toString();
    final hint = trimmedKey.length <= 4
        ? trimmedKey
        : trimmedKey.substring(trimmedKey.length - 4);

    if (existing == null) {
      await AgentProviderSettings.db.insertRow(
        session,
        AgentProviderSettings(
          userId: userId,
          baseUrl: storedBaseUrl,
          model: trimmedModel,
          encryptedApiKey: sealed.cipherText,
          nonce: sealed.nonce,
          keyHint: hint,
          updatedAt: now,
        ),
      );
    } else {
      await AgentProviderSettings.db.updateRow(
        session,
        existing.copyWith(
          baseUrl: storedBaseUrl,
          model: trimmedModel,
          encryptedApiKey: sealed.cipherText,
          nonce: sealed.nonce,
          keyHint: hint,
          updatedAt: now,
        ),
      );
    }

    return AgentProviderSettingsView(
      baseUrl: storedBaseUrl,
      model: trimmedModel,
      keyHint: hint,
    );
  }

  /// Deletes the user's provider settings, if any.
  static Future<void> clear(Session session, UuidValue userId) async {
    final existing = await AgentProviderSettings.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );
    if (existing == null) return;
    await AgentProviderSettings.db.deleteRow(session, existing);
  }
}
