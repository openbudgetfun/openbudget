import 'dart:convert';
import 'dart:io';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/budgets/budget_service.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/institutions/institution_service.dart';
import 'package:serverpod/serverpod.dart';

const _plaidClientIdKey = 'plaidClientId';
const _plaidSecretKey = 'plaidSecret';
const _plaidEnvironmentKey = 'plaidEnvironment';
const _plaidBaseUrlKey = 'plaidBaseUrl';
const _plaidProductsKey = 'plaidProducts';
const _plaidCountryCodesKey = 'plaidCountryCodes';
const _plaidSandboxDefaultInstitutionId = 'ins_109508';

class PlaidService {
  static final _log = ObLogger('PlaidService');

  static const _defaultEnvironment = 'sandbox';
  static const _defaultProducts = ['auth', 'transactions'];
  static const _defaultCountryCodes = ['US'];

  static Future<String> createLinkToken(
    Session session, {
    required UuidValue budgetId,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);
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
      throw ValidationException('Plaid did not return a valid link token.');
    }
    return linkToken;
  }

  static Future<List<Account>> exchangePublicTokenAndImportAccounts(
    Session session, {
    required UuidValue budgetId,
    required String publicToken,
  }) async {
    if (publicToken.trim().isEmpty) {
      throw ValidationException('Plaid public token is required.');
    }

    final budget = await BudgetService.getById(session, budgetId: budgetId);
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
        'Plaid exchange response was missing item credentials.',
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
      budgetId: budgetId,
      plaidItemId: plaidItemId,
      accessToken: accessToken,
      institutionName: institutionName,
      institutionId: institutionId,
      now: now,
    );

    final imported = await _importAccounts(
      session,
      budget: budget,
      budgetId: budgetId,
      connection: connection,
      accountsResponse: accountsResponse,
      now: now,
      institutionId: linkedInstitutionId,
    );

    _log.info(
      'Imported ${imported.length} plaid accounts for budget=$budgetId item=$plaidItemId',
    );
    return imported;
  }

  static Future<List<Account>> syncConnection(
    Session session, {
    required UuidValue budgetId,
    required UuidValue connectionId,
  }) async {
    final connection = await PlaidConnection.db.findById(session, connectionId);
    if (connection == null || connection.budgetId != budgetId) {
      throw NotFoundException('Plaid connection not found.');
    }
    final budget = await BudgetService.getById(session, budgetId: budgetId);
    final credentials = _resolveCredentials(session);
    final now = DateTime.now().toUtc();
    final linkedInstitutionId = await InstitutionService.resolveInstitutionId(
      session,
      plaidInstitutionId: connection.institutionId,
      institutionName: connection.institutionName,
    );
    final accountsResponse = await _fetchAccounts(
      credentials: credentials,
      accessToken: connection.accessToken,
    );
    final refresh = await _importAccounts(
      session,
      budget: budget,
      budgetId: budgetId,
      connection: connection,
      accountsResponse: accountsResponse,
      now: now,
      institutionId: linkedInstitutionId,
    );
    return refresh;
  }

  static Future<List<Account>> importSandboxAccounts(
    Session session, {
    required UuidValue budgetId,
    String? plaidInstitutionId,
  }) async {
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
      throw ValidationException('Plaid sandbox did not return a public token.');
    }

    return exchangePublicTokenAndImportAccounts(
      session,
      budgetId: budgetId,
      publicToken: publicToken,
    );
  }

  static Future<Map<String, dynamic>> _fetchAccounts({
    required _PlaidCredentials credentials,
    required String accessToken,
  }) async {
    return _postJson(
      uri: credentials.baseUri.replace(path: '/accounts/get'),
      payload: {
        'client_id': credentials.clientId,
        'secret': credentials.secret,
        'access_token': accessToken,
      },
    );
  }

  static Future<List<Account>> _importAccounts(
    Session session, {
    required Budget budget,
    required UuidValue budgetId,
    required PlaidConnection connection,
    required Map<String, dynamic> accountsResponse,
    required DateTime now,
    required UuidValue? institutionId,
  }) async {
    final accountsJson = accountsResponse['accounts'];
    if (accountsJson is! List) {
      throw ValidationException('Plaid accounts payload is invalid.');
    }

    final imported = <Account>[];
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

      final subtype = (rawAccount['subtype'] as String?)?.toLowerCase();
      final type = (rawAccount['type'] as String?)?.toLowerCase();
      final mappedAccountType = _mapPlaidAccountType(type, subtype);
      final onBudget = _isOnBudgetDefault(type, mappedAccountType);
      final currencyCode =
          (rawAccount['iso_currency_code'] as String?)?.toUpperCase() ??
          budget.currencyCode;
      final balances = rawAccount['balances'] as Map<String, dynamic>?;
      final balanceNumber = balances?['current'] as num?;
      final balanceCents = ((balanceNumber ?? 0).toDouble() * 100).round();

      final existing = await Account.db.findFirstRow(
        session,
        where: (t) =>
            t.budgetId.equals(budgetId) &
            t.externalAccountId.equals(externalAccountId),
      );

      if (existing != null) {
        final updated = await Account.db.updateRow(
          session,
          existing.copyWith(
            name: name,
            accountType: mappedAccountType,
            balanceCents: balanceCents,
            currencyCode: currencyCode,
            onBudget: onBudget,
            sourceType: 'plaid',
            connectionId: connection.id,
            institutionId: institutionId ?? existing.institutionId,
            lastSyncedAt: now,
            syncStatus: 'synced',
          ),
        );
        imported.add(updated);
        continue;
      }

      final maxSortOrder = await _nextSortOrder(session, budgetId: budgetId);
      final created = await Account.db.insertRow(
        session,
        Account(
          name: name,
          accountType: mappedAccountType,
          balanceCents: balanceCents,
          currencyCode: currencyCode,
          budgetId: budgetId,
          creatorId: budget.ownerId,
          institutionId: institutionId,
          onBudget: onBudget,
          sortOrder: maxSortOrder,
          isClosed: false,
          sourceType: 'plaid',
          externalAccountId: externalAccountId,
          connectionId: connection.id,
          lastSyncedAt: now,
          syncStatus: 'synced',
        ),
      );
      imported.add(created);
    }

    if (connection.id != null) {
      await PlaidConnection.db.updateRow(
        session,
        connection.copyWith(updatedAt: now, lastSyncedAt: now),
      );
    }

    return imported;
  }

  static Future<PlaidConnection> _upsertConnection(
    Session session, {
    required UuidValue budgetId,
    required String plaidItemId,
    required String accessToken,
    required String? institutionName,
    required String? institutionId,
    required DateTime now,
  }) async {
    final existing = await PlaidConnection.db.findFirstRow(
      session,
      where: (t) =>
          t.budgetId.equals(budgetId) & t.plaidItemId.equals(plaidItemId),
    );

    if (existing != null) {
      return PlaidConnection.db.updateRow(
        session,
        existing.copyWith(
          accessToken: accessToken,
          institutionName: institutionName ?? existing.institutionName,
          institutionId: institutionId ?? existing.institutionId,
          updatedAt: now,
          lastSyncedAt: now,
        ),
      );
    }

    return PlaidConnection.db.insertRow(
      session,
      PlaidConnection(
        budgetId: budgetId,
        plaidItemId: plaidItemId,
        accessToken: accessToken,
        institutionName: institutionName,
        institutionId: institutionId,
        updatedAt: now,
        lastSyncedAt: now,
      ),
    );
  }

  static Future<int> _nextSortOrder(
    Session session, {
    required UuidValue budgetId,
  }) async {
    final last = await Account.db.findFirstRow(
      session,
      where: (t) => t.budgetId.equals(budgetId),
      orderBy: (t) => t.sortOrder,
      orderDescending: true,
    );
    return (last?.sortOrder ?? -1) + 1;
  }

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

  static String _mapPlaidAccountType(String? type, String? subtype) {
    if (type == 'depository') {
      if (subtype == 'savings') return 'savings';
      return 'checking';
    }
    if (type == 'credit') return 'creditCard';
    if (type == 'investment') return 'investment';
    return 'other';
  }

  static bool _isOnBudgetDefault(String? plaidType, String mappedType) {
    if (plaidType == 'credit' || plaidType == 'loan') return false;
    if (mappedType == 'investment') return false;
    return true;
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
          'Plaid request failed (${response.statusCode}): $body',
        );
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw ValidationException('Plaid returned an unexpected response.');
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
