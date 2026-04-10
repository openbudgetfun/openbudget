import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/budgets/budget_service.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/fx_rates/fx_rate_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

const _solanaDefaultRpcUrl = 'https://api.mainnet-beta.solana.com';
const _solanaRpcUrlKey = 'solanaRpcUrl';
const _coingeckoBaseUrl = 'https://api.coingecko.com/api/v3';
const _walletChainSolana = 'solana';
const _nativeSolAssetId = 'SOL';

class WalletService {
  static final _log = ObLogger('WalletService');

  static Future<WalletConnectResult> connectSolanaWallet(
    Session session, {
    required UuidValue budgetId,
    required String address,
    String? label,
    bool onBudget = false,
  }) async {
    final budget = await BudgetService.getById(session, budgetId: budgetId);
    final normalizedAddress = address.trim();
    _validateSolanaAddress(normalizedAddress);

    final now = DateTime.now().toUtc();
    final connection = await _upsertConnection(
      session,
      budgetId: budgetId,
      address: normalizedAddress,
      label: label,
      now: now,
    );

    return _syncSolanaConnection(
      session,
      budget: budget,
      connection: connection,
      onBudget: onBudget,
      now: now,
    );
  }

  static Future<WalletConnectResult> refreshSolanaWallet(
    Session session, {
    required UuidValue budgetId,
    required UuidValue connectionId,
  }) async {
    final budget = await BudgetService.getById(session, budgetId: budgetId);
    final connection = await WalletConnection.db.findById(
      session,
      connectionId,
    );
    if (connection == null || connection.budgetId != budgetId) {
      throw NotFoundException('Wallet connection not found.');
    }

    final now = DateTime.now().toUtc();
    final existingAccount = await _findWalletAccount(
      session,
      budgetId: budgetId,
      connectionId: connectionId,
    );
    return _syncSolanaConnection(
      session,
      budget: budget,
      connection: connection,
      onBudget: existingAccount?.onBudget ?? false,
      now: now,
      existingAccount: existingAccount,
    );
  }

  static Future<List<WalletHolding>> listHoldings(
    Session session, {
    required UuidValue budgetId,
    required UuidValue connectionId,
  }) async {
    final connection = await WalletConnection.db.findById(
      session,
      connectionId,
    );
    if (connection == null || connection.budgetId != budgetId) {
      throw NotFoundException('Wallet connection not found.');
    }
    await BudgetService.getById(session, budgetId: budgetId);

    return WalletHolding.db.find(
      session,
      where: (t) => t.walletConnectionId.equals(connectionId),
      orderBy: (t) => t.symbol,
    );
  }

  static Future<WalletConnectResult> _syncSolanaConnection(
    Session session, {
    required Budget budget,
    required WalletConnection connection,
    required bool onBudget,
    required DateTime now,
    Account? existingAccount,
  }) async {
    final rpcUrl = _resolveSolanaRpcUrl(session);
    final rpcHoldings = await _fetchSolanaHoldings(
      rpcUrl: rpcUrl,
      address: connection.address,
    );
    final quotes = await _loadUsdQuotes(
      session,
      rpcHoldings: rpcHoldings,
      now: now,
    );

    final persistedHoldings = await _persistHoldings(
      session,
      connectionId: connection.id!,
      rpcHoldings: rpcHoldings,
      usdQuotes: quotes,
      now: now,
    );

    final totalUsdValue = persistedHoldings.fold<double>(
      0,
      (sum, holding) => sum + max(0, holding.usdValue ?? 0),
    );
    final balanceCents = await _convertUsdToCurrencyCents(
      session,
      totalUsdValue: totalUsdValue,
      currencyCode: budget.currencyCode,
    );

    final account = await _upsertWalletAccount(
      session,
      budget: budget,
      connection: connection,
      onBudget: onBudget,
      now: now,
      balanceCents: balanceCents,
      existingAccount: existingAccount,
    );

    await WalletConnection.db.updateRow(
      session,
      connection.copyWith(
        updatedAt: now,
        lastSyncedAt: now,
        syncStatus: 'synced',
      ),
    );

    return WalletConnectResult(
      account: account,
      holdings: persistedHoldings,
      totalUsdValue: totalUsdValue,
    );
  }

  static Future<WalletConnection> _upsertConnection(
    Session session, {
    required UuidValue budgetId,
    required String address,
    required String? label,
    required DateTime now,
  }) async {
    final existing = await WalletConnection.db.findFirstRow(
      session,
      where: (t) =>
          t.budgetId.equals(budgetId) &
          t.chain.equals(_walletChainSolana) &
          t.address.equals(address),
    );
    if (existing != null) {
      return WalletConnection.db.updateRow(
        session,
        existing.copyWith(label: label ?? existing.label, updatedAt: now),
      );
    }

    return WalletConnection.db.insertRow(
      session,
      WalletConnection(
        budgetId: budgetId,
        chain: _walletChainSolana,
        address: address,
        label: label,
        updatedAt: now,
      ),
    );
  }

  static Future<Account?> _findWalletAccount(
    Session session, {
    required UuidValue budgetId,
    required UuidValue connectionId,
  }) => Account.db.findFirstRow(
      session,
      where: (t) =>
          t.budgetId.equals(budgetId) &
          t.sourceType.equals('solana') &
          t.connectionId.equals(connectionId),
    );

  static Future<Account> _upsertWalletAccount(
    Session session, {
    required Budget budget,
    required WalletConnection connection,
    required bool onBudget,
    required DateTime now,
    required int balanceCents,
    Account? existingAccount,
  }) async {
    final budgetId = budget.id;
    if (budgetId == null) {
      throw ValidationException('Budget id is required.');
    }

    final shortAddress = _shortAddress(connection.address);
    final accountName = (connection.label ?? '').trim().isNotEmpty
        ? connection.label!.trim()
        : 'Solana Wallet ($shortAddress)';

    final current =
        existingAccount ??
        await _findWalletAccount(
          session,
          budgetId: budgetId,
          connectionId: connection.id!,
        );
    if (current != null) {
      return Account.db.updateRow(
        session,
        current.copyWith(
          name: accountName,
          accountType: 'investment',
          currencyCode: budget.currencyCode,
          balanceCents: balanceCents,
          onBudget: onBudget,
          sourceType: 'solana',
          externalAccountId: connection.address,
          connectionId: connection.id,
          lastSyncedAt: now,
          syncStatus: 'synced',
        ),
      );
    }

    final last = await Account.db.findFirstRow(
      session,
      where: (t) => t.budgetId.equals(budgetId),
      orderBy: (t) => t.sortOrder,
      orderDescending: true,
    );
    final sortOrder = (last?.sortOrder ?? -1) + 1;

    return Account.db.insertRow(
      session,
      Account(
        name: accountName,
        accountType: 'investment',
        balanceCents: balanceCents,
        currencyCode: budget.currencyCode,
        budgetId: budgetId,
        creatorId: budget.ownerId,
        onBudget: onBudget,
        sortOrder: sortOrder,
        isClosed: false,
        sourceType: 'solana',
        externalAccountId: connection.address,
        connectionId: connection.id,
        lastSyncedAt: now,
        syncStatus: 'synced',
      ),
    );
  }

  static Future<List<WalletHolding>> _persistHoldings(
    Session session, {
    required UuidValue connectionId,
    required List<_RpcHolding> rpcHoldings,
    required Map<String, double> usdQuotes,
    required DateTime now,
  }) async {
    final existing = await WalletHolding.db.find(
      session,
      where: (t) => t.walletConnectionId.equals(connectionId),
    );
    final existingByAsset = <String, WalletHolding>{
      for (final row in existing) row.assetId: row,
    };
    final incomingAssetIds = <String>{};
    final persisted = <WalletHolding>[];

    for (final holding in rpcHoldings) {
      incomingAssetIds.add(holding.assetId);
      final usdPrice = usdQuotes[holding.assetId];
      final usdValue = usdPrice == null
          ? null
          : usdPrice * holding.quantityDisplay;
      final row = existingByAsset[holding.assetId];

      if (row != null) {
        final updated = await WalletHolding.db.updateRow(
          session,
          row.copyWith(
            symbol: holding.symbol,
            decimals: holding.decimals,
            quantityBaseUnits: holding.quantityBaseUnits,
            quantityDisplay: holding.quantityDisplay,
            usdPrice: usdPrice,
            usdValue: usdValue,
            lastSyncedAt: now,
          ),
        );
        persisted.add(updated);
      } else {
        final inserted = await WalletHolding.db.insertRow(
          session,
          WalletHolding(
            walletConnectionId: connectionId,
            chain: _walletChainSolana,
            assetId: holding.assetId,
            symbol: holding.symbol,
            decimals: holding.decimals,
            quantityBaseUnits: holding.quantityBaseUnits,
            quantityDisplay: holding.quantityDisplay,
            usdPrice: usdPrice,
            usdValue: usdValue,
          ),
        );
        persisted.add(inserted);
      }
    }

    for (final row in existing) {
      if (incomingAssetIds.contains(row.assetId)) continue;
      await WalletHolding.db.deleteRow(session, row);
    }

    persisted.sort((a, b) => a.symbol.compareTo(b.symbol));
    return persisted;
  }

  static Future<Map<String, double>> _loadUsdQuotes(
    Session session, {
    required List<_RpcHolding> rpcHoldings,
    required DateTime now,
  }) async {
    final quotes = <String, double>{};
    final missing = <String>[];
    final symbolByAssetId = <String, String>{
      for (final holding in rpcHoldings) holding.assetId: holding.symbol,
    };

    for (final holding in rpcHoldings) {
      final cached = await AssetQuoteCache.db.findFirstRow(
        session,
        where: (t) =>
            t.chain.equals(_walletChainSolana) &
            t.assetId.equals(holding.assetId),
      );
      if (cached != null && cached.expiresAt.isAfter(now)) {
        quotes[holding.assetId] = cached.usdPrice;
      } else {
        missing.add(holding.assetId);
      }
    }

    if (missing.isEmpty) return quotes;

    final fetched = await _fetchMissingUsdQuotes(missing);
    for (final entry in fetched.entries) {
      final assetId = entry.key;
      final usdPrice = entry.value;
      quotes[assetId] = usdPrice;

      final existing = await AssetQuoteCache.db.findFirstRow(
        session,
        where: (t) =>
            t.chain.equals(_walletChainSolana) & t.assetId.equals(assetId),
      );
      final expiresAt = now.add(const Duration(minutes: 15));
      if (existing != null) {
        await AssetQuoteCache.db.updateRow(
          session,
          existing.copyWith(
            symbol: symbolByAssetId[assetId] ?? existing.symbol,
            usdPrice: usdPrice,
            fetchedAt: now,
            expiresAt: expiresAt,
          ),
        );
      } else {
        await AssetQuoteCache.db.insertRow(
          session,
          AssetQuoteCache(
            chain: _walletChainSolana,
            assetId: assetId,
            symbol: symbolByAssetId[assetId] ?? assetId,
            usdPrice: usdPrice,
            fetchedAt: now,
            expiresAt: expiresAt,
          ),
        );
      }
    }

    return quotes;
  }

  static Future<Map<String, double>> _fetchMissingUsdQuotes(
    List<String> assetIds,
  ) async {
    final quotes = <String, double>{};
    final mints = <String>[];
    for (final id in assetIds) {
      if (id == _nativeSolAssetId) {
        final solUsd = await _fetchSolUsdPrice();
        if (solUsd != null) quotes[_nativeSolAssetId] = solUsd;
      } else {
        mints.add(id);
      }
    }

    if (mints.isEmpty) return quotes;

    const chunkSize = 75;
    for (var i = 0; i < mints.length; i += chunkSize) {
      final chunk = mints.sublist(i, min(i + chunkSize, mints.length));
      final uri = Uri.parse('$_coingeckoBaseUrl/simple/token_price/solana')
          .replace(
            queryParameters: {
              'contract_addresses': chunk.join(','),
              'vs_currencies': 'usd',
            },
          );
      final payload = await _getJson(uri);
      for (final mint in chunk) {
        final row = payload[mint.toLowerCase()];
        if (row is! Map<String, dynamic>) continue;
        final usd = row['usd'];
        if (usd is num) {
          quotes[mint] = usd.toDouble();
        }
      }
    }

    return quotes;
  }

  static Future<double?> _fetchSolUsdPrice() async {
    final uri = Uri.parse(
      '$_coingeckoBaseUrl/simple/price',
    ).replace(queryParameters: {'ids': 'solana', 'vs_currencies': 'usd'});
    final payload = await _getJson(uri);
    final solana = payload['solana'];
    if (solana is! Map<String, dynamic>) return null;
    final usd = solana['usd'];
    if (usd is! num) return null;
    return usd.toDouble();
  }

  static Future<List<_RpcHolding>> _fetchSolanaHoldings({
    required String rpcUrl,
    required String address,
  }) async {
    final holdings = <_RpcHolding>[];
    final lamports = await _rpcCall<int>(
      rpcUrl: rpcUrl,
      method: 'getBalance',
      params: [address],
      resultSelector: (result) => result['value'] as int?,
    );
    final solAmount = lamports == null ? 0.0 : lamports / 1e9;
    holdings.add(
      _RpcHolding(
        assetId: _nativeSolAssetId,
        symbol: 'SOL',
        decimals: 9,
        quantityBaseUnits: (lamports ?? 0).toString(),
        quantityDisplay: solAmount,
      ),
    );

    final tokenAccounts = await _rpcCall<List<dynamic>>(
      rpcUrl: rpcUrl,
      method: 'getTokenAccountsByOwner',
      params: [
        address,
        {'programId': 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'},
        {'encoding': 'jsonParsed'},
      ],
      resultSelector: (result) => result['value'] as List<dynamic>?,
    );

    for (final raw in tokenAccounts ?? const <dynamic>[]) {
      if (raw is! Map<String, dynamic>) continue;
      final account = raw['account'];
      if (account is! Map<String, dynamic>) continue;
      final data = account['data'];
      if (data is! Map<String, dynamic>) continue;
      final parsed = data['parsed'];
      if (parsed is! Map<String, dynamic>) continue;
      final info = parsed['info'];
      if (info is! Map<String, dynamic>) continue;
      final mint = info['mint'] as String?;
      final amount = info['tokenAmount'];
      if (mint == null || amount is! Map<String, dynamic>) continue;

      final quantityBaseUnits = amount['amount'] as String?;
      final decimals = amount['decimals'] as int?;
      final quantityDisplayRaw = amount['uiAmountString'] as String?;
      if (quantityBaseUnits == null || decimals == null) continue;
      final quantityDisplay = double.tryParse(quantityDisplayRaw ?? '');
      if (quantityDisplay == null || quantityDisplay <= 0) continue;

      holdings.add(
        _RpcHolding(
          assetId: mint,
          symbol: _shortAddress(mint),
          decimals: decimals,
          quantityBaseUnits: quantityBaseUnits,
          quantityDisplay: quantityDisplay,
        ),
      );
    }

    return holdings;
  }

  static Future<int> _convertUsdToCurrencyCents(
    Session session, {
    required double totalUsdValue,
    required String currencyCode,
  }) async {
    final normalizedCode = currencyCode.toUpperCase();
    if (normalizedCode == 'USD') {
      return (totalUsdValue * 100).round();
    }

    try {
      final snapshot = await FxRateService.latest(session);
      final rate = snapshot.rates
          .firstWhere(
            (quote) => quote.currencyCode.toUpperCase() == normalizedCode,
            orElse: () => FxRateQuote(currencyCode: normalizedCode, rate: 1),
          )
          .rate;
      return (totalUsdValue * rate * 100).round();
    } on Exception catch (error) {
      _log.warning(
        'Unable to convert wallet USD value to $normalizedCode, using USD fallback: $error',
      );
      return (totalUsdValue * 100).round();
    }
  }

  static String _resolveSolanaRpcUrl(Session session) {
    final fromEnv = Platform.environment['SOLANA_RPC_URL'];
    if (fromEnv != null && fromEnv.trim().isNotEmpty) return fromEnv.trim();

    final fromPasswords = session.serverpod.getPassword(_solanaRpcUrlKey);
    if (fromPasswords != null && fromPasswords.trim().isNotEmpty) {
      return fromPasswords.trim();
    }
    return _solanaDefaultRpcUrl;
  }

  static void _validateSolanaAddress(String address) {
    final regex = RegExp(r'^[1-9A-HJ-NP-Za-km-z]{32,44}$');
    if (!regex.hasMatch(address)) {
      throw ValidationException('Invalid Solana wallet address.');
    }
  }

  static String _shortAddress(String value) {
    if (value.length <= 10) return value;
    return '${value.substring(0, 4)}...${value.substring(value.length - 4)}';
  }

  static Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ValidationException(
          'Request failed (${response.statusCode}) for $uri',
        );
      }
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw ValidationException(
          'Unexpected response payload for ${uri.path}.',
        );
      }
      return decoded;
    } finally {
      client.close(force: true);
    }
  }

  static Future<T?> _rpcCall<T>({
    required String rpcUrl,
    required String method,
    required List<dynamic> params,
    required T? Function(Map<String, dynamic>) resultSelector,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse(rpcUrl));
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.write(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': method,
          'method': method,
          'params': params,
        }),
      );

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ValidationException('Solana RPC request failed: $method');
      }
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw ValidationException('Invalid Solana RPC response for $method');
      }
      final error = decoded['error'];
      if (error != null) {
        throw ValidationException('Solana RPC error for $method: $error');
      }
      final result = decoded['result'];
      if (result is! Map<String, dynamic>) return null;
      return resultSelector(result);
    } finally {
      client.close(force: true);
    }
  }
}

class _RpcHolding {
  const _RpcHolding({
    required this.assetId,
    required this.symbol,
    required this.decimals,
    required this.quantityBaseUnits,
    required this.quantityDisplay,
  });

  final String assetId;
  final String symbol;
  final int decimals;
  final String quantityBaseUnits;
  final double quantityDisplay;
}
