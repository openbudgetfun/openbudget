import 'dart:convert';
import 'dart:io';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/accounts/account_service.dart';
import 'package:openbudget_server/src/accounts/account_valuation_service.dart';
import 'package:openbudget_server/src/common/secret_box.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/institutions/institution_service.dart';
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';

const _plaidClientIdKey = 'plaidClientId';
const _plaidSecretKey = 'plaidSecret';
const _plaidEnvironmentKey = 'plaidEnvironment';
const _plaidBaseUrlKey = 'plaidBaseUrl';
const _plaidProductsKey = 'plaidProducts';
const _plaidCountryCodesKey = 'plaidCountryCodes';
const _plaidTokenEncryptionKey = 'plaidTokenEncryptionKey';
const _plaidSandboxDefaultInstitutionId = 'ins_109508';

/// Links bank accounts through Plaid and imports their movements.
///
/// Every method is entity-scoped: a connection belongs to one entity and
/// ownership is checked through [EntityAccess] before any money is read or
/// written. The Plaid access token is sealed with [SecretBox] and both sealed
/// fields are `scope=serverOnly` on the model, so the client can never
/// receive it; the service must always write ciphertext and nonce together.
///
/// Movements reach the ledger only through [TransactionWriter.importRows], so
/// Plaid rows obey the same FX, balance, lock and payee rules as manual
/// entries. Pending transactions are skipped until they post, because their
/// ids change on posting (Q11).
class PlaidService {
  static final _log = ObLogger('PlaidService');

  static const _defaultEnvironment = 'sandbox';
  static const _defaultProducts = ['auth', 'transactions'];
  static const _defaultCountryCodes = ['US'];

  /// Plaid pages are 100 rows; ten pages bound one sync.
  static const _maxSyncPages = 10;

  static Future<String> createLinkToken(
    Session session, {
    required UuidValue entityId,
  }) async {
    await EntityAccess.requireOwned(session, entityId);
    final credentials = _resolveCredentials(session);
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null || userIdentifier.trim().isEmpty) {
      throw AuthenticationRequiredException();
    }

    final response = await _postJson(
      uri: credentials.baseUri.replace(path: '/link/token/create'),
      payload: {
        'client_id': credentials.clientId,
        'secret': credentials.secret,
        'client_name': 'OpenBudget',
        'language': 'en',
        'country_codes': credentials.countryCodes,
        'products': credentials.products,
        'user': {'client_user_id': userIdentifier},
      },
    );

    final linkToken = response['link_token'] as String?;
    if (linkToken == null || linkToken.isEmpty) {
      throw ValidationException(
        message: 'Plaid did not return a valid link token.',
      );
    }
    return linkToken;
  }

  /// Exchanges a public token, stores the sealed access token, imports the
  /// item's accounts with their opening balances and syncs posted movements.
  static Future<PlaidConnection> exchangePublicToken(
    Session session, {
    required UuidValue entityId,
    required String publicToken,
  }) async {
    if (publicToken.trim().isEmpty) {
      throw ValidationException(message: 'Plaid public token is required.');
    }

    final entity = await EntityAccess.requireOwned(session, entityId);
    final credentials = _resolveCredentials(session);
    final now = DateTime.now().toUtc();

    final exchangeResponse = await _postJson(
      uri: credentials.baseUri.replace(path: '/item/public_token/exchange'),
      payload: {
        'client_id': credentials.clientId,
        'secret': credentials.secret,
        'public_token': publicToken.trim(),
      },
    );

    final accessToken = exchangeResponse['access_token'] as String?;
    final plaidItemId = exchangeResponse['item_id'] as String?;
    if (accessToken == null ||
        accessToken.isEmpty ||
        plaidItemId == null ||
        plaidItemId.isEmpty) {
      throw ValidationException(
        message: 'Plaid exchange response was missing item credentials.',
      );
    }

    final accountsResponse = await _fetchAccounts(
      credentials: credentials,
      accessToken: accessToken,
    );

    final itemJson = accountsResponse['item'];
    String? institutionId;
    if (itemJson is Map<String, dynamic>) {
      institutionId = itemJson['institution_id'] as String?;
    }

    String? institutionName;
    if (institutionId != null && institutionId.isNotEmpty) {
      institutionName = await _fetchInstitutionName(
        credentials: credentials,
        institutionId: institutionId,
      );
    }
    final linkedInstitutionId = await InstitutionService.resolveInstitutionId(
      session,
      plaidInstitutionId: institutionId,
      institutionName: institutionName,
    );

    final connection = await _upsertConnection(
      session,
      entityId: entityId,
      plaidItemId: plaidItemId,
      accessToken: accessToken,
      institutionName: institutionName,
      institutionId: institutionId,
      now: now,
    );

    try {
      await _syncAccounts(
        session,
        entity: entity,
        connection: connection,
        accountsResponse: accountsResponse,
        institutionId: linkedInstitutionId,
        openingBalance: true,
      );
      final connection_ = await _syncTransactions(
        session,
        entity: entity,
        connection: connection,
        credentials: credentials,
        accessToken: accessToken,
      );
      _log.info(
        'Linked plaid item=$plaidItemId for entity=$entityId',
      );
      return connection_;
    } on Object catch (error) {
      await _markFailed(session, connection.id!, error);
      rethrow;
    }
  }

  /// Syncs one connection: account balances, valuations and posted movements.
  ///
  /// Pending Plaid transactions stay out until they post (Q11). Removed
  /// remote rows are reported by Plaid on the next sync with the same
  /// cursor; local rows are never deleted here, so a sync cannot silently
  /// drop posted history.
  static Future<PlaidConnection> syncConnection(
    Session session, {
    required UuidValue connectionId,
  }) async {
    final connection = await _requireOwnedConnection(session, connectionId);
    final entity = await Entity.db.findById(session, connection.entityId);
    if (entity == null) {
      throw NotFoundException(message: 'Entity not found');
    }
    final credentials = _resolveCredentials(session);
    final accessToken = await _openToken(session, connection);

    try {
      final accountsResponse = await _fetchAccounts(
        credentials: credentials,
        accessToken: accessToken,
      );
      await _syncAccounts(
        session,
        entity: entity,
        connection: connection,
        accountsResponse: accountsResponse,
        institutionId: connection.plaidInstitutionId == null
            ? null
            : await InstitutionService.resolveInstitutionId(
                session,
                plaidInstitutionId: connection.plaidInstitutionId,
                institutionName: connection.institutionName,
              ),
        openingBalance: false,
      );
      final updated = await _syncTransactions(
        session,
        entity: entity,
        connection: connection,
        credentials: credentials,
        accessToken: accessToken,
      );
      return updated;
    } on Object catch (error) {
      await _markFailed(session, connection.id!, error);
      rethrow;
    }
  }

  /// Lists the entity's connections.
  ///
  /// Safe to return whole: the token fields are `scope=serverOnly`, so the
  /// generated client class carries no secret.
  static Future<List<PlaidConnection>> listConnections(
    Session session, {
    required UuidValue entityId,
  }) async {
    await EntityAccess.requireOwned(session, entityId);
    return PlaidConnection.db.find(
      session,
      where: (t) => t.entityId.equals(entityId),
      orderBy: (t) => t.createdAt,
    );
  }

  /// Removes a connection and asks Plaid to revoke the item.
  ///
  /// Accounts keep their imported history; the `SetNull` foreign key clears
  /// their `plaidConnectionId`. A failed revoke call is logged and does not
  /// keep a dead local link alive.
  static Future<void> removeConnection(
    Session session, {
    required UuidValue connectionId,
  }) async {
    final connection = await _requireOwnedConnection(session, connectionId);
    final credentials = _resolveCredentials(session);
    try {
      final accessToken = await _openToken(session, connection);
      await _postJson(
        uri: credentials.baseUri.replace(path: '/item/remove'),
        payload: {
          'client_id': credentials.clientId,
          'secret': credentials.secret,
          'access_token': accessToken,
        },
      );
    } on Exception catch (error) {
      _log.warning('Plaid item remove failed: $error');
    }
    await PlaidConnection.db.deleteRow(session, connection);
    await EntityRealtimeNotifier.notify(
      session,
      connection.entityId,
      ChangeScope.accounts,
    );
  }

  /// Creates a Plaid sandbox item and links it without client-side Link.
  static Future<PlaidConnection> importSandboxAccounts(
    Session session, {
    required UuidValue entityId,
    String? plaidInstitutionId,
  }) async {
    await EntityAccess.requireOwned(session, entityId);
    final credentials = _resolveCredentials(session);
    final response = await _postJson(
      uri: credentials.baseUri.replace(path: '/sandbox/public_token/create'),
      payload: {
        'client_id': credentials.clientId,
        'secret': credentials.secret,
        'institution_id':
            (plaidInstitutionId == null || plaidInstitutionId.trim().isEmpty)
            ? _plaidSandboxDefaultInstitutionId
            : plaidInstitutionId.trim(),
        'initial_products': credentials.products,
      },
    );

    final publicToken = response['public_token'] as String?;
    if (publicToken == null || publicToken.isEmpty) {
      throw ValidationException(
        message: 'Plaid sandbox did not return a public token.',
      );
    }

    return exchangePublicToken(
      session,
      entityId: entityId,
      publicToken: publicToken,
    );
  }

  static Future<PlaidConnection> _requireOwnedConnection(
    Session session,
    UuidValue connectionId,
  ) async {
    final connection = await PlaidConnection.db.findById(session, connectionId);
    if (connection == null) {
      throw NotFoundException(message: 'Plaid connection not found.');
    }
    await EntityAccess.requireOwned(session, connection.entityId);
    return connection;
  }

  /// Decrypts the stored access token.
  ///
  /// A missing pair or a bad ciphertext is a server configuration or data
  /// fault, never something the client can fix, so the sync fails with a
  /// validation error instead of sending an empty token to Plaid.
  static Future<String> _openToken(
    Session session,
    PlaidConnection connection,
  ) async {
    final cipherText = connection.accessTokenCiphertext;
    final nonce = connection.accessTokenNonce;
    if (cipherText == null || nonce == null) {
      throw ValidationException(
        message: 'The Plaid access token is missing from this connection.',
      );
    }
    final key = session.serverpod.getPassword(_plaidTokenEncryptionKey);
    if (key == null || key.trim().isEmpty) {
      throw ValidationException(
        message: '$_plaidTokenEncryptionKey is not configured.',
      );
    }
    return SecretBox.open(cipherText: cipherText, nonce: nonce, base64Key: key);
  }

  static Future<PlaidConnection> _upsertConnection(
    Session session, {
    required UuidValue entityId,
    required String plaidItemId,
    required String accessToken,
    required String? institutionName,
    required String? institutionId,
    required DateTime now,
  }) async {
    final sealed = await _sealToken(session, accessToken);
    final existing = await PlaidConnection.db.findFirstRow(
      session,
      where: (t) => t.plaidItemId.equals(plaidItemId),
    );

    if (existing != null) {
      // The item is global in Plaid; re-linking it moves it to this entity
      // and re-seals the fresh token.
      return PlaidConnection.db.updateRow(
        session,
        existing.copyWith(
          entityId: entityId,
          accessTokenCiphertext: sealed.cipherText,
          accessTokenNonce: sealed.nonce,
          plaidInstitutionId: institutionId,
          institutionName: institutionName ?? existing.institutionName,
          syncStatus: SyncStatus.pending,
          // Explicit null clears a previous failure, not keeps it.
          // ignore: avoid_redundant_argument_values
          lastSyncError: null,
          updatedAt: now,
        ),
      );
    }
    return PlaidConnection.db.insertRow(
      session,
      PlaidConnection(
        entityId: entityId,
        plaidItemId: plaidItemId,
        accessTokenCiphertext: sealed.cipherText,
        accessTokenNonce: sealed.nonce,
        plaidInstitutionId: institutionId,
        institutionName: institutionName,
        syncStatus: SyncStatus.pending,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Seals the access token or rejects an unconfigured key before any row is
  /// written: the ciphertext and nonce are only ever stored together.
  static Future<SealedSecret> _sealToken(
    Session session,
    String accessToken,
  ) async {
    final key = session.serverpod.getPassword(_plaidTokenEncryptionKey);
    if (key == null || key.trim().isEmpty) {
      throw ValidationException(
        message: '$_plaidTokenEncryptionKey is not configured.',
      );
    }
    return SecretBox.seal(plaintext: accessToken, base64Key: key);
  }

  /// Creates missing accounts with their opening facts and refreshes what the
  /// institution last reported.
  ///
  /// Depository and credit accounts are transactions-sourced: link writes one
  /// `openingBalance` transaction through [AccountService], later syncs only
  /// record `reportedBalanceMinor`. Investment, loan and mortgage accounts
  /// are valuations-sourced and every sync upserts today's valuation from
  /// [ValuationSource.plaid].
  static Future<void> _syncAccounts(
    Session session, {
    required Entity entity,
    required PlaidConnection connection,
    required Map<String, dynamic> accountsResponse,
    required UuidValue? institutionId,
    required bool openingBalance,
  }) async {
    final accountsJson = accountsResponse['accounts'];
    if (accountsJson is! List) {
      throw ValidationException(message: 'Plaid accounts payload is invalid.');
    }

    for (final rawAccount in accountsJson) {
      if (rawAccount is! Map<String, dynamic>) continue;
      final externalAccountId = rawAccount['account_id'] as String?;
      final name = rawAccount['name'] as String?;
      if (externalAccountId == null ||
          externalAccountId.isEmpty ||
          name == null ||
          name.isEmpty) {
        continue;
      }

      final kind = _mapPlaidKind(
        (rawAccount['type'] as String?)?.toLowerCase(),
        (rawAccount['subtype'] as String?)?.toLowerCase(),
      );
      final currencyCode = _currencyFor(
        rawAccount['iso_currency_code'] as String?,
        fallback: entity.baseCurrencyCode,
      );
      final balances = rawAccount['balances'] as Map<String, dynamic>?;
      final currentMinor = _optionalMinor(
        balances?['current'],
        currencyCode,
        isLiability: kind.isLiability,
      );

      final existing = await Account.db.findFirstRow(
        session,
        where: (t) =>
            t.plaidConnectionId.equals(connection.id) &
            t.plaidAccountId.equals(externalAccountId),
      );

      if (existing == null) {
        final created = await AccountService.create(
          session,
          entity.id!,
          name,
          kind,
          currencyCode,
          balanceSource: kind.defaultBalanceSource,
          onBudget:
              kind.canBeOnBudget &&
              kind.defaultBalanceSource == AccountBalanceSource.transactions,
          openingBalanceMinor: openingBalance ? currentMinor : null,
          institutionId: institutionId,
          note: 'Imported from Plaid',
        );
        // A copied account row keeps the Plaid identity that the unique
        // index guards; balance writes belong to the account services.
        await Account.db.updateWhere(
          session,
          columnValues: (t) => [
            t.plaidConnectionId(connection.id),
            t.plaidAccountId(externalAccountId),
            if (!openingBalance && currentMinor != null) ...[
              t.reportedBalanceMinor(currentMinor),
              t.reportedBalanceAt(DateTime.now().toUtc()),
            ],
          ],
          where: (t) => t.id.equals(created.id),
        );
        continue;
      }

      final today = EntityClock.today(entity);
      if (kind.defaultBalanceSource == AccountBalanceSource.valuations) {
        if (currentMinor != null) {
          await session.db.transaction((tx) async {
            await AccountValuationService.setInTransaction(
              session,
              tx,
              existing.id!,
              today,
              currentMinor,
              source: ValuationSource.plaid,
            );
          });
        }
        continue;
      }

      await Account.db.updateWhere(
        session,
        columnValues: (t) => [
          if (!openingBalance && currentMinor != null) ...[
            t.reportedBalanceMinor(currentMinor),
            t.reportedBalanceAt(DateTime.now().toUtc()),
          ],
        ],
        where: (t) => t.id.equals(existing.id),
      );
    }

    if (connection.id != null) {
      await PlaidConnection.db.updateRow(
        session,
        connection.copyWith(updatedAt: DateTime.now().toUtc()),
      );
    }
  }

  /// Pulls every posted movement through the cursor and imports them per
  /// account with [TransactionWriter.importRows].
  static Future<PlaidConnection> _syncTransactions(
    Session session, {
    required Entity entity,
    required PlaidConnection connection,
    required _PlaidCredentials credentials,
    required String accessToken,
  }) async {
    final localAccounts = await Account.db.find(
      session,
      where: (t) => t.plaidConnectionId.equals(connection.id),
    );
    final byPlaidAccountId = {
      for (final account in localAccounts)
        if (account.plaidAccountId != null) account.plaidAccountId!: account,
    };

    var cursor = connection.transactionsCursor;
    for (var page = 0; page < _maxSyncPages; page++) {
      final response = await _postJson(
        uri: credentials.baseUri.replace(path: '/transactions/sync'),
        payload: {
          'client_id': credentials.clientId,
          'secret': credentials.secret,
          'access_token': accessToken,
          'cursor': ?cursor,
          'count': 100,
        },
      );

      final added = response['added'];
      if (added is! List) {
        throw ValidationException(
          message: 'Plaid transactions payload is invalid.',
        );
      }

      final rowsByAccountId = <String, List<ImportRow>>{};
      for (final rawTransaction in added) {
        if (rawTransaction is! Map<String, dynamic>) continue;
        final row = _importRow(rawTransaction);
        if (row == null) continue;
        rowsByAccountId.putIfAbsent(row.$1, () => []).add(row.$2);
      }

      for (final entry in rowsByAccountId.entries) {
        final account = byPlaidAccountId[entry.key];
        if (account == null) continue;
        final result = await TransactionWriter.importRows(
          session,
          account.id!,
          entry.value,
        );
        if (result.errors.isNotEmpty) {
          _log.info(
            'Plaid import skipped ${result.errors.length} rows for '
            'account=${account.id}: ${result.errors.take(3)}',
          );
        }
      }

      final nextCursor = response['next_cursor'] as String?;
      final hasMore = response['has_more'] == true;
      cursor = nextCursor ?? cursor;
      if (!hasMore) break;
    }

    final now = DateTime.now().toUtc();
    return PlaidConnection.db.updateRow(
      session,
      connection.copyWith(
        transactionsCursor: cursor,
        syncStatus: SyncStatus.synced,
        lastSyncedAt: now,
        // Explicit null clears a previous failure, not keeps it.
        // ignore: avoid_redundant_argument_values
        lastSyncError: null,
        updatedAt: now,
      ),
    );
  }

  /// Maps one Plaid transaction, or null when it must not import.
  ///
  /// Pending rows are skipped (Q11): their ids change when they post, so
  /// importing them would duplicate the posted row. Plaid's amount is
  /// positive for outflow; OpenBudget's is positive for inflow, so the sign
  /// flips.
  static (String, ImportRow)? _importRow(Map<String, dynamic> raw) {
    final transactionId = raw['transaction_id'] as String?;
    final accountId = raw['account_id'] as String?;
    if (transactionId == null ||
        transactionId.isEmpty ||
        accountId == null ||
        accountId.isEmpty) {
      return null;
    }
    if (raw['pending'] == true) return null;

    final dateText = raw['date'] as String?;
    final date = _civilDate(dateText);
    if (date == null) return null;

    final currencyCode =
        (raw['iso_currency_code'] as String?)?.toUpperCase() ?? 'USD';
    final amountMinor = _optionalMinor(
      raw['amount'],
      currencyCode,
      isLiability: false,
    );
    if (amountMinor == null || amountMinor == 0) return null;

    final name = (raw['merchant_name'] as String?)?.trim();
    final description =
        (raw['name'] as String?)?.trim() ?? (name ?? 'Plaid transaction');

    return (
      accountId,
      ImportRow(
        date: date,
        amountMinor: -amountMinor,
        description: description,
        payeeName: name,
        externalId: transactionId,
      ),
    );
  }

  static DateTime? _civilDate(String? text) {
    if (text == null) return null;
    final parsed = DateTime.tryParse(text);
    if (parsed == null) return null;
    return DateTime.utc(parsed.year, parsed.month, parsed.day);
  }

  static Future<void> _markFailed(
    Session session,
    UuidValue connectionId,
    Object error,
  ) async {
    try {
      await PlaidConnection.db.updateWhere(
        session,
        columnValues: (t) => [
          t.syncStatus(SyncStatus.failed),
          t.lastSyncError(error.toString()),
          t.updatedAt(DateTime.now().toUtc()),
        ],
        where: (t) => t.id.equals(connectionId),
      );
    } on Exception catch (loggingError) {
      _log.warning('Recording the Plaid sync failure failed: $loggingError');
    }
  }

  static String _currencyFor(String? code, {required String fallback}) {
    final candidate = code?.toUpperCase() ?? '';
    return CurrencyCode.tryParse(candidate) == null ? fallback : candidate;
  }

  /// Converts a Plaid decimal amount to signed minor units.
  ///
  /// Plaid reports the amount owed on liabilities as positive, while an
  /// OpenBudget liability balance is negative, so liability amounts negate.
  /// The magnitude string goes through [parseMinorUnits] with the sign
  /// handled here; a missing or malformed balance yields null rather than a
  /// fabricated zero.
  static int? _optionalMinor(
    Object? value,
    String currencyCode, {
    required bool isLiability,
  }) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    final negative = text.startsWith('-');
    final magnitudeText = (negative || text.startsWith('+'))
        ? text.substring(1)
        : text;
    final decimals = CurrencyCode.tryParse(currencyCode)?.decimals ?? 2;
    final magnitude = parseMinorUnits(magnitudeText, decimals);
    if (magnitude == null) return null;
    var minor = negative ? -magnitude : magnitude;
    if (isLiability) minor = -minor;
    return minor;
  }

  static AccountKind _mapPlaidKind(String? type, String? subtype) {
    if (type == 'depository') {
      if (subtype == 'savings') return AccountKind.savings;
      return AccountKind.checking;
    }
    if (type == 'credit') return AccountKind.creditCard;
    if (type == 'investment') return AccountKind.investment;
    if (type == 'loan') return AccountKind.loan;
    if (type == 'mortgage') return AccountKind.mortgage;
    return AccountKind.otherAsset;
  }

  static Future<Map<String, dynamic>> _fetchAccounts({
    required _PlaidCredentials credentials,
    required String accessToken,
  }) async => _postJson(
    uri: credentials.baseUri.replace(path: '/accounts/get'),
    payload: {
      'client_id': credentials.clientId,
      'secret': credentials.secret,
      'access_token': accessToken,
    },
  );

  static Future<String?> _fetchInstitutionName({
    required _PlaidCredentials credentials,
    required String institutionId,
  }) async {
    try {
      final response = await _postJson(
        uri: credentials.baseUri.replace(path: '/institutions/get_by_id'),
        payload: {
          'client_id': credentials.clientId,
          'secret': credentials.secret,
          'institution_id': institutionId,
          'country_codes': credentials.countryCodes,
        },
      );
      final institution = response['institution'];
      if (institution is! Map<String, dynamic>) return null;
      return institution['name'] as String?;
    } on Exception catch (error) {
      _log.warning('Unable to fetch institution metadata: $error');
      return null;
    }
  }

  static _PlaidCredentials _resolveCredentials(Session session) {
    String? fromEnv(String key) => Platform.environment[key];

    final clientId =
        fromEnv('PLAID_CLIENT_ID') ??
        session.serverpod.getPassword(_plaidClientIdKey);
    final secret =
        fromEnv('PLAID_SECRET') ??
        session.serverpod.getPassword(_plaidSecretKey);
    final environment =
        fromEnv('PLAID_ENV') ??
        session.serverpod.getPassword(_plaidEnvironmentKey) ??
        _defaultEnvironment;
    final productsRaw =
        fromEnv('PLAID_PRODUCTS') ??
        session.serverpod.getPassword(_plaidProductsKey);
    final countryCodesRaw =
        fromEnv('PLAID_COUNTRY_CODES') ??
        session.serverpod.getPassword(_plaidCountryCodesKey);
    final explicitBaseUrl =
        fromEnv('PLAID_BASE_URL') ??
        session.serverpod.getPassword(_plaidBaseUrlKey);

    if (clientId == null ||
        clientId.trim().isEmpty ||
        secret == null ||
        secret.trim().isEmpty) {
      throw ValidationException(
        message:
            'Plaid credentials are missing. Configure $_plaidClientIdKey and $_plaidSecretKey.',
      );
    }

    final products = _splitCsv(productsRaw, fallback: _defaultProducts);
    final countryCodes = _splitCsv(
      countryCodesRaw,
      fallback: _defaultCountryCodes,
    );
    final baseUrl = (explicitBaseUrl?.trim().isNotEmpty ?? false)
        ? explicitBaseUrl!.trim()
        : _environmentBaseUrl(environment.trim().toLowerCase());

    return _PlaidCredentials(
      clientId: clientId.trim(),
      secret: secret.trim(),
      baseUri: Uri.parse(baseUrl),
      products: products,
      countryCodes: countryCodes,
    );
  }

  static List<String> _splitCsv(String? raw, {required List<String> fallback}) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final values = raw
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (values.isEmpty) return fallback;
    return values;
  }

  static String _environmentBaseUrl(String env) {
    switch (env) {
      case 'production':
        return 'https://production.plaid.com';
      case 'development':
        return 'https://development.plaid.com';
      default:
        return 'https://sandbox.plaid.com';
    }
  }

  static Future<Map<String, dynamic>> _postJson({
    required Uri uri,
    required Map<String, dynamic> payload,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.write(jsonEncode(payload));

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ValidationException(
          message: 'Plaid request failed (${response.statusCode}): $body',
        );
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw ValidationException(
          message: 'Plaid returned an unexpected response.',
        );
      }
      return decoded;
    } finally {
      client.close(force: true);
    }
  }
}

class _PlaidCredentials {
  const _PlaidCredentials({
    required this.clientId,
    required this.secret,
    required this.baseUri,
    required this.products,
    required this.countryCodes,
  });

  final String clientId;
  final String secret;
  final Uri baseUri;
  final List<String> products;
  final List<String> countryCodes;
}
