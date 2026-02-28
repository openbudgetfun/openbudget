import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/accounts/account_service.dart';
import 'package:openbudget_server/src/budgets/budget_service.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';

/// Business logic for attaching and syncing Solana wallets.
class SolanaWalletService {
  static final _log = ObLogger('SolanaWalletService');
  static final RegExp _base58Address = RegExp(r'^[1-9A-HJ-NP-Za-km-z]{32,44}$');

  static const _clusterMainnet = 'mainnet';
  static const _clusterDevnet = 'devnet';

  /// Attaches a Solana wallet to an existing account.
  static Future<SolanaWallet> attachWallet(
    Session session, {
    required UuidValue budgetId,
    required UuidValue accountId,
    required String address,
    String? label,
    String cluster = _clusterMainnet,
  }) async {
    final normalizedAddress = address.trim();
    if (!_base58Address.hasMatch(normalizedAddress)) {
      throw ValidationException('Invalid Solana wallet address');
    }

    final normalizedCluster = _normalizeCluster(cluster);

    await BudgetService.getById(session, budgetId: budgetId);
    final account = await AccountService.getById(session, accountId: accountId);
    if (account.budgetId != budgetId) {
      throw ValidationException('Account does not belong to this budget');
    }

    final existing = await SolanaWallet.db.findFirstRow(
      session,
      where: (t) => t.accountId.equals(accountId),
    );

    if (existing != null) {
      final updated = existing.copyWith(
        address: normalizedAddress,
        label: label ?? existing.label,
        cluster: normalizedCluster,
        syncStatus: 'pending',
        updatedAt: DateTime.now(),
      );
      return SolanaWallet.db.updateRow(session, updated);
    }

    final now = DateTime.now();
    final wallet = SolanaWallet(
      accountId: accountId,
      budgetId: budgetId,
      address: normalizedAddress,
      label: label,
      cluster: normalizedCluster,
      syncStatus: 'pending',
      createdAt: now,
      updatedAt: now,
    );

    return SolanaWallet.db.insertRow(session, wallet);
  }

  /// Returns all wallets for a budget.
  static Future<List<SolanaWallet>> listForBudget(
    Session session, {
    required UuidValue budgetId,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    return SolanaWallet.db.find(
      session,
      where: (t) => t.budgetId.equals(budgetId),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  /// Returns wallet metadata for an account.
  static Future<SolanaWallet?> getForAccount(
    Session session, {
    required UuidValue accountId,
    required UuidValue budgetId,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    final account = await AccountService.getById(session, accountId: accountId);
    if (account.budgetId != budgetId) {
      throw ValidationException('Account does not belong to this budget');
    }

    return SolanaWallet.db.findFirstRow(
      session,
      where: (t) => t.accountId.equals(accountId),
    );
  }

  /// Lists parsed wallet transactions.
  static Future<List<SolanaWalletTransaction>> listTransactions(
    Session session, {
    required UuidValue walletId,
    required UuidValue budgetId,
    int limit = 100,
  }) async {
    await _getWalletOrThrow(session, walletId: walletId, budgetId: budgetId);

    final boundedLimit = limit.clamp(1, 1000);
    return SolanaWalletTransaction.db.find(
      session,
      where: (t) => t.walletId.equals(walletId) & t.budgetId.equals(budgetId),
      orderBy: (t) => t.occurredAt,
      orderDescending: true,
      limit: boundedLimit,
    );
  }

  /// Lists current wallet holdings.
  static Future<List<SolanaWalletHolding>> listHoldings(
    Session session, {
    required UuidValue walletId,
    required UuidValue budgetId,
  }) async {
    await _getWalletOrThrow(session, walletId: walletId, budgetId: budgetId);

    final holdings = await SolanaWalletHolding.db.find(
      session,
      where: (t) => t.walletId.equals(walletId) & t.budgetId.equals(budgetId),
      orderBy: (t) => t.totalValue,
      orderDescending: true,
    );

    return holdings;
  }

  /// Updates user metadata for a wallet transaction.
  static Future<SolanaWalletTransaction> updateTransactionMetadata(
    Session session, {
    required UuidValue transactionId,
    required UuidValue budgetId,
    String? category,
    String? tagsCsv,
    String? memo,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    final transaction = await SolanaWalletTransaction.db.findById(
      session,
      transactionId,
    );
    if (transaction == null || transaction.budgetId != budgetId) {
      throw NotFoundException('Wallet transaction not found');
    }

    final updated = transaction.copyWith(
      category: category ?? transaction.category,
      tagsCsv: tagsCsv ?? transaction.tagsCsv,
      memo: memo ?? transaction.memo,
      updatedAt: DateTime.now(),
    );

    return SolanaWalletTransaction.db.updateRow(session, updated);
  }

  /// Syncs recent Solana data for a wallet and stores parsed transactions and holdings.
  static Future<SolanaWalletSyncResult> syncWallet(
    Session session, {
    required UuidValue walletId,
    required UuidValue budgetId,
    int limit = 200,
  }) async {
    final wallet = await _getWalletOrThrow(
      session,
      walletId: walletId,
      budgetId: budgetId,
    );

    final apiKey = _readHeliusApiKey(session);
    if (apiKey == null) {
      throw ValidationException(
        'Missing Helius API key. Set HELIUS_API_KEY or passwords.heliusApiKey.',
      );
    }

    final helius = createHelius(
      HeliusConfig(
        apiKey: apiKey,
        cluster: wallet.cluster == _clusterDevnet
            ? HeliusCluster.devnet
            : HeliusCluster.mainnet,
      ),
    );

    var insertedTransactions = 0;
    var updatedTransactions = 0;
    final warnings = <String>[];

    try {
      final boundedLimit = limit.clamp(1, 1000);
      final history = await helius.wallet.getHistory(
        GetHistoryRequest(
          address: wallet.address,
          limit: boundedLimit,
          until: wallet.lastSignature,
        ),
      );

      for (final tx in history) {
        final upserted = await _upsertTransaction(
          session,
          walletId: walletId,
          wallet: wallet,
          tx: tx,
        );
        if (upserted) {
          insertedTransactions += 1;
        } else {
          updatedTransactions += 1;
        }
      }

      if (history.isNotEmpty) {
        // Helius returns most recent signatures first.
        wallet.lastSignature = history.first.signature;
      }

      final valuation = await _syncHoldings(
        session,
        walletId: walletId,
        wallet: wallet,
        helius: helius,
        warnings: warnings,
      );

      wallet
        ..syncStatus = 'success'
        ..lastSyncError = null
        ..lastSyncedAt = DateTime.now()
        ..updatedAt = DateTime.now();
      await SolanaWallet.db.updateRow(session, wallet);

      return SolanaWalletSyncResult(
        walletId: wallet.id!,
        insertedTransactions: insertedTransactions,
        updatedTransactions: updatedTransactions,
        holdingCount: valuation.holdingCount,
        totalValuation: valuation.totalValuation,
        valuationCurrency: valuation.valuationCurrency,
        syncedAt: wallet.lastSyncedAt!,
        warnings: warnings.isEmpty ? null : warnings.join('; '),
      );
    } catch (error, stackTrace) {
      _log.severe(
        'Wallet sync failed for wallet=${wallet.id} address=${wallet.address}',
        error,
        stackTrace,
      );

      wallet
        ..syncStatus = 'error'
        ..lastSyncError = error.toString()
        ..updatedAt = DateTime.now();
      await SolanaWallet.db.updateRow(session, wallet);

      rethrow;
    }
  }

  static Future<SolanaWallet> _getWalletOrThrow(
    Session session, {
    required UuidValue walletId,
    required UuidValue budgetId,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    final wallet = await SolanaWallet.db.findById(session, walletId);
    if (wallet == null || wallet.budgetId != budgetId) {
      throw NotFoundException('Solana wallet not found');
    }
    return wallet;
  }

  static String _normalizeCluster(String cluster) {
    final normalized = cluster.trim().toLowerCase();
    if (normalized == _clusterMainnet || normalized == _clusterDevnet) {
      return normalized;
    }
    throw ValidationException('Unsupported Solana cluster "$cluster"');
  }

  static String? _readHeliusApiKey(Session session) {
    final passwordValue = _trimToNull(session.passwords['heliusApiKey']);
    if (passwordValue != null) return passwordValue;

    // Fallback for deployments that inject secrets via environment variables.
    // ignore: do_not_use_environment
    return _trimToNull(Platform.environment['HELIUS_API_KEY']);
  }

  static String? _trimToNull(String? input) {
    if (input == null) return null;
    final trimmed = input.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static Future<bool> _upsertTransaction(
    Session session, {
    required UuidValue walletId,
    required SolanaWallet wallet,
    required EnhancedTransaction tx,
  }) async {
    final programs = tx.instructions.map(
      (instruction) => instruction.programId,
    );
    final uniquePrograms = programs.toSet().toList()..sort();
    final interpretation = _resolveDescription(tx, wallet.address);

    final existing = await SolanaWalletTransaction.db.findFirstRow(
      session,
      where: (t) =>
          t.walletId.equals(walletId) & t.signature.equals(tx.signature),
    );

    final occurredAt = tx.timestamp == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(tx.timestamp! * 1000);

    final payload = SolanaWalletTransaction(
      walletId: walletId,
      budgetId: wallet.budgetId,
      signature: tx.signature,
      slot: tx.slot,
      occurredAt: occurredAt,
      description: interpretation.description,
      txType: tx.type,
      source: tx.source,
      interpretationConfidence: interpretation.confidence,
      programsJson: uniquePrograms.isEmpty ? null : jsonEncode(uniquePrograms),
      nativeTransfersJson: tx.nativeTransfers.isEmpty
          ? null
          : jsonEncode(tx.nativeTransfers.map((e) => e.toJson()).toList()),
      tokenTransfersJson: tx.tokenTransfers.isEmpty
          ? null
          : jsonEncode(tx.tokenTransfers.map((e) => e.toJson()).toList()),
      rawJson: jsonEncode(tx.toJson()),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (existing == null) {
      await SolanaWalletTransaction.db.insertRow(session, payload);
      return true;
    }

    final updated = existing.copyWith(
      slot: payload.slot,
      occurredAt: payload.occurredAt,
      description: payload.description,
      txType: payload.txType,
      source: payload.source,
      interpretationConfidence: payload.interpretationConfidence,
      programsJson: payload.programsJson,
      nativeTransfersJson: payload.nativeTransfersJson,
      tokenTransfersJson: payload.tokenTransfersJson,
      rawJson: payload.rawJson,
      updatedAt: DateTime.now(),
    );

    await SolanaWalletTransaction.db.updateRow(session, updated);
    return false;
  }

  static ({String description, String confidence}) _resolveDescription(
    EnhancedTransaction tx,
    String walletAddress,
  ) {
    final directDescription = tx.description?.trim();
    if (directDescription != null && directDescription.isNotEmpty) {
      return (description: directDescription, confidence: 'high');
    }

    final flow = _walletFlow(tx, walletAddress);
    final source = _friendlySource(tx.source);

    final programLabels = tx.instructions
        .map((instruction) => _friendlyProgram(instruction.programId))
        .where((label) => label != null)
        .cast<String>()
        .toSet()
        .toList(growable: false);

    final normalizedSource = tx.source.toLowerCase();
    final hasJupiter =
        normalizedSource.contains('jup') || programLabels.contains('Jupiter');
    final hasPump =
        normalizedSource.contains('pump') || programLabels.contains('Pump.fun');
    final hasNftMarketplace =
        normalizedSource.contains('magiceden') ||
        normalizedSource.contains('tensor');
    final hasSwapSignals = flow.tokenIn > 0 && flow.tokenOut > 0;

    String action;
    var confidence = 'low';
    if (hasJupiter || hasSwapSignals) {
      action = hasJupiter ? 'Token swap on Jupiter' : 'Token swap';
      confidence = hasJupiter ? 'high' : 'medium';
    } else if (hasPump) {
      action = 'Trade on Pump.fun';
      confidence = 'high';
    } else if (hasNftMarketplace) {
      action = 'NFT activity on $source';
      confidence = 'high';
    } else if (flow.tokenOut > 0 && flow.tokenIn == 0 && flow.nativeIn == 0) {
      action = 'Token transfer sent';
      confidence = 'medium';
    } else if (flow.tokenIn > 0 && flow.tokenOut == 0 && flow.nativeOut == 0) {
      action = 'Token transfer received';
      confidence = 'medium';
    } else if (flow.nativeOut > 0 && flow.nativeIn == 0 && flow.tokenIn == 0) {
      action = 'SOL transfer sent';
      confidence = 'medium';
    } else if (flow.nativeIn > 0 && flow.nativeOut == 0 && flow.tokenOut == 0) {
      action = 'SOL transfer received';
      confidence = 'medium';
    } else {
      final readableType = tx.type
          .toLowerCase()
          .replaceAll('_', ' ')
          .replaceAllMapped(RegExp(r'\b\w'), (match) {
            return match.group(0)!.toUpperCase();
          });
      action = '$readableType via $source';
    }

    final transferSummary = _walletFlowSummary(flow);
    final shortProgramLabels = programLabels.take(2).toList(growable: false);
    final remainingPrograms = programLabels.length - shortProgramLabels.length;
    final programSummary = shortProgramLabels.isEmpty
        ? ''
        : ' using ${shortProgramLabels.join(', ')}'
              '${remainingPrograms > 0 ? ' +$remainingPrograms' : ''}';

    return (
      description: '$action$transferSummary$programSummary',
      confidence: confidence,
    );
  }

  static ({int nativeIn, int nativeOut, int tokenIn, int tokenOut}) _walletFlow(
    EnhancedTransaction tx,
    String walletAddress,
  ) {
    var nativeIn = 0;
    var nativeOut = 0;
    for (final transfer in tx.nativeTransfers) {
      if (transfer.toUserAccount == walletAddress) nativeIn += 1;
      if (transfer.fromUserAccount == walletAddress) nativeOut += 1;
    }

    var tokenIn = 0;
    var tokenOut = 0;
    for (final transfer in tx.tokenTransfers) {
      if (transfer.toUserAccount == walletAddress) tokenIn += 1;
      if (transfer.fromUserAccount == walletAddress) tokenOut += 1;
    }

    return (
      nativeIn: nativeIn,
      nativeOut: nativeOut,
      tokenIn: tokenIn,
      tokenOut: tokenOut,
    );
  }

  static String _walletFlowSummary(
    ({int nativeIn, int nativeOut, int tokenIn, int tokenOut}) flow,
  ) {
    final segments = <String>[];
    if (flow.nativeIn > 0) segments.add('${flow.nativeIn} SOL in');
    if (flow.nativeOut > 0) segments.add('${flow.nativeOut} SOL out');
    if (flow.tokenIn > 0) segments.add('${flow.tokenIn} token in');
    if (flow.tokenOut > 0) segments.add('${flow.tokenOut} token out');
    if (segments.isEmpty) return '';
    return ' (${segments.join(', ')})';
  }

  static String _friendlySource(String source) {
    final normalized = source.toLowerCase();
    return switch (normalized) {
      'jupiter' => 'Jupiter',
      'pumpfun' => 'Pump.fun',
      'magiceden' => 'Magic Eden',
      'tensor' => 'Tensor',
      'system_program' => 'System Program',
      'token_program' => 'SPL Token Program',
      'token_2022' => 'SPL Token 2022 Program',
      _ => source,
    };
  }

  static String? _friendlyProgram(String? programId) {
    if (programId == null) return null;
    final normalized = programId.trim();
    if (normalized.isEmpty) return null;

    if (normalized == '11111111111111111111111111111111') {
      return 'System Program';
    }
    if (normalized.startsWith('TokenkegQfe')) return 'SPL Token';
    if (normalized.startsWith('TokenzQd')) return 'Token-2022';
    if (normalized.startsWith('AToken')) return 'Associated Token';
    if (normalized.startsWith('ComputeBudget')) return 'Compute Budget';
    if (normalized.startsWith('MemoSq4')) return 'Memo Program';
    if (normalized.startsWith('JUP') ||
        normalized.toLowerCase().contains('jup')) {
      return 'Jupiter';
    }
    if (normalized.startsWith('6EF8rrecthR') ||
        normalized.toLowerCase().contains('pump')) {
      return 'Pump.fun';
    }
    if (normalized.startsWith('metaqbxx')) return 'Metaplex Metadata';
    if (normalized.startsWith('whirLbM')) return 'Orca Whirlpool';
    if (normalized.startsWith('9W959DqE')) return 'Raydium';
    return null;
  }

  static Future<_HoldingSyncSummary> _syncHoldings(
    Session session, {
    required UuidValue walletId,
    required SolanaWallet wallet,
    required HeliusClient helius,
    required List<String> warnings,
  }) async {
    final balances = await helius.wallet.getBalances(
      GetBalancesRequest(address: wallet.address),
    );

    final assets = await helius.das.getAssetsByOwner(
      GetAssetsByOwnerRequest(ownerAddress: wallet.address, limit: 1000),
    );

    final assetsById = {for (final asset in assets.items) asset.id: asset};

    final seenAssetIds = <String>{};
    var totalValuation = 0.0;
    String? valuationCurrency;

    for (final token in balances.tokens) {
      final assetId = token.mint;
      seenAssetIds.add(assetId);

      final asset = assetsById[assetId];
      final decimals = token.decimals;
      final rawAmount = token.amount;
      final uiAmount = _toUiAmount(rawAmount, decimals);
      final priceInfo = asset?.tokenInfo?.priceInfo;
      final pricePerToken = priceInfo?.pricePerToken;
      final totalValue = pricePerToken == null
          ? null
          : uiAmount * pricePerToken;

      if (totalValue != null) {
        totalValuation += totalValue;
        valuationCurrency ??= priceInfo?.currency;
      }

      final holding = SolanaWalletHolding(
        walletId: walletId,
        budgetId: wallet.budgetId,
        assetId: assetId,
        symbol: asset?.content?.metadata?.symbol,
        name: asset?.content?.metadata?.name,
        tokenProgram: asset?.tokenInfo?.tokenProgram,
        decimals: decimals,
        balanceRaw: rawAmount.toString(),
        balanceUi: _formatUiAmount(rawAmount, decimals),
        isNft: _isLikelyNft(asset),
        priceCurrency: priceInfo?.currency,
        pricePerToken: pricePerToken,
        totalValue: totalValue,
        priceSource: priceInfo == null ? null : 'helius_das',
        priceAsOf: DateTime.now(),
        metadataJson: asset == null
            ? null
            : jsonEncode({
                'interface': asset.interface_,
                'symbol': asset.content?.metadata?.symbol,
                'name': asset.content?.metadata?.name,
              }),
        updatedAt: DateTime.now(),
      );

      await _upsertHolding(session, holding);

      if (pricePerToken == null) {
        warnings.add('Missing price for asset $assetId');
      }
    }

    // Include NFT-like assets that may not appear in fungible balances.
    for (final asset in assets.items.where(_isLikelyNft)) {
      if (!seenAssetIds.add(asset.id)) continue;

      final priceInfo = asset.tokenInfo?.priceInfo;
      final totalValue = priceInfo?.totalPrice ?? priceInfo?.pricePerToken;
      if (totalValue != null) {
        totalValuation += totalValue;
        valuationCurrency ??= priceInfo?.currency;
      }

      await _upsertHolding(
        session,
        SolanaWalletHolding(
          walletId: walletId,
          budgetId: wallet.budgetId,
          assetId: asset.id,
          symbol: asset.content?.metadata?.symbol,
          name: asset.content?.metadata?.name,
          tokenProgram: asset.tokenInfo?.tokenProgram,
          decimals: asset.tokenInfo?.decimals ?? 0,
          balanceRaw: '1',
          balanceUi: '1',
          isNft: true,
          priceCurrency: priceInfo?.currency,
          pricePerToken: priceInfo?.pricePerToken,
          totalValue: totalValue,
          priceSource: priceInfo == null ? null : 'helius_das',
          priceAsOf: DateTime.now(),
          metadataJson: jsonEncode({
            'interface': asset.interface_,
            'symbol': asset.content?.metadata?.symbol,
            'name': asset.content?.metadata?.name,
          }),
          updatedAt: DateTime.now(),
        ),
      );
    }

    final existing = await SolanaWalletHolding.db.find(
      session,
      where: (t) => t.walletId.equals(walletId),
    );

    for (final holding in existing) {
      if (!seenAssetIds.contains(holding.assetId)) {
        await SolanaWalletHolding.db.deleteRow(session, holding);
      }
    }

    await _syncAccountBalanceFromValuation(
      session,
      wallet: wallet,
      totalValuation: totalValuation,
      valuationCurrency: valuationCurrency,
    );

    return _HoldingSyncSummary(
      holdingCount: seenAssetIds.length,
      totalValuation: seenAssetIds.isEmpty ? null : totalValuation,
      valuationCurrency: valuationCurrency,
    );
  }

  static Future<void> _upsertHolding(
    Session session,
    SolanaWalletHolding incoming,
  ) async {
    final existing = await SolanaWalletHolding.db.findFirstRow(
      session,
      where: (t) =>
          t.walletId.equals(incoming.walletId) &
          t.assetId.equals(incoming.assetId),
    );

    if (existing == null) {
      await SolanaWalletHolding.db.insertRow(session, incoming);
      return;
    }

    final updated = existing.copyWith(
      symbol: incoming.symbol,
      name: incoming.name,
      tokenProgram: incoming.tokenProgram,
      decimals: incoming.decimals,
      balanceRaw: incoming.balanceRaw,
      balanceUi: incoming.balanceUi,
      isNft: incoming.isNft,
      priceCurrency: incoming.priceCurrency,
      pricePerToken: incoming.pricePerToken,
      totalValue: incoming.totalValue,
      priceSource: incoming.priceSource,
      priceAsOf: incoming.priceAsOf,
      metadataJson: incoming.metadataJson,
      updatedAt: DateTime.now(),
    );

    await SolanaWalletHolding.db.updateRow(session, updated);
  }

  static Future<void> _syncAccountBalanceFromValuation(
    Session session, {
    required SolanaWallet wallet,
    required double totalValuation,
    required String? valuationCurrency,
  }) async {
    if (valuationCurrency == null) return;

    final account = await AccountService.getById(
      session,
      accountId: wallet.accountId,
    );
    if (account.currencyCode.toUpperCase() != valuationCurrency.toUpperCase()) {
      return;
    }

    final cents = (totalValuation * 100).round();
    final updatedAccount = account.copyWith(balanceCents: cents);
    await Account.db.updateRow(session, updatedAccount);
  }

  static bool _isLikelyNft(HeliusAsset? asset) {
    if (asset == null) return false;
    final interfaceName = asset.interface_?.toLowerCase() ?? '';
    if (interfaceName.contains('nft')) return true;

    final decimals = asset.tokenInfo?.decimals;
    if (decimals != null && decimals == 0) {
      final supply = asset.tokenInfo?.supply;
      if (supply != null && supply == 1) return true;
    }

    return false;
  }

  static String _formatUiAmount(int amount, int decimals) {
    final asBigInt = BigInt.from(amount);
    if (decimals <= 0) return asBigInt.toString();

    final divisor = BigInt.from(10).pow(decimals);
    final whole = asBigInt ~/ divisor;
    var fractional = (asBigInt % divisor).toString().padLeft(decimals, '0');
    fractional = fractional.replaceFirst(RegExp(r'0+$'), '');
    if (fractional.isEmpty) return whole.toString();
    return '$whole.$fractional';
  }

  static double _toUiAmount(int amount, int decimals) {
    if (decimals <= 0) return amount.toDouble();
    return amount / math.pow(10, decimals);
  }
}

class _HoldingSyncSummary {
  const _HoldingSyncSummary({
    required this.holdingCount,
    required this.totalValuation,
    required this.valuationCurrency,
  });

  final int holdingCount;
  final double? totalValuation;
  final String? valuationCurrency;
}
