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
  static const _pnlEpsilon = 0.0000001;

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
      await _recomputeEstimatedPnl(
        session,
        walletId: walletId,
        wallet: wallet,
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
    final description = _resolveDescription(tx);

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
      description: description,
      txType: tx.type,
      source: tx.source,
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
      programsJson: payload.programsJson,
      nativeTransfersJson: payload.nativeTransfersJson,
      tokenTransfersJson: payload.tokenTransfersJson,
      rawJson: payload.rawJson,
      updatedAt: DateTime.now(),
    );

    await SolanaWalletTransaction.db.updateRow(session, updated);
    return false;
  }

  static String _resolveDescription(EnhancedTransaction tx) {
    final directDescription = tx.description?.trim();
    if (directDescription != null && directDescription.isNotEmpty) {
      return directDescription;
    }

    final readableType = tx.type
        .toLowerCase()
        .replaceAll('_', ' ')
        .replaceAllMapped(RegExp(r'\b\w'), (match) {
          return match.group(0)!.toUpperCase();
        });

    final source = _friendlySource(tx.source);
    final transferSummary = switch ((
      tx.nativeTransfers.length,
      tx.tokenTransfers.length,
    )) {
      (0, 0) => '',
      (final nativeCount, 0) =>
        ' ($nativeCount SOL transfer${nativeCount == 1 ? '' : 's'})',
      (0, final tokenCount) =>
        ' ($tokenCount token transfer${tokenCount == 1 ? '' : 's'})',
      (final nativeCount, final tokenCount) =>
        ' ($nativeCount SOL transfer${nativeCount == 1 ? '' : 's'}, '
            '$tokenCount token transfer${tokenCount == 1 ? '' : 's'})',
    };

    final programLabels = tx.instructions
        .map((instruction) => _friendlyProgram(instruction.programId))
        .where((label) => label != null)
        .cast<String>()
        .toSet()
        .toList(growable: false);

    final shortProgramLabels = programLabels.take(2).toList(growable: false);
    final remainingPrograms = programLabels.length - shortProgramLabels.length;
    final programSummary = shortProgramLabels.isEmpty
        ? ''
        : ' using ${shortProgramLabels.join(', ')}'
              '${remainingPrograms > 0 ? ' +$remainingPrograms' : ''}';

    return '$readableType via $source$transferSummary$programSummary';
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
    if (normalized.startsWith('JUP') || normalized.contains('jup')) {
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

  static Future<void> _recomputeEstimatedPnl(
    Session session, {
    required UuidValue walletId,
    required SolanaWallet wallet,
    required List<String> warnings,
  }) async {
    final holdings = await SolanaWalletHolding.db.find(
      session,
      where: (t) =>
          t.walletId.equals(walletId) & t.budgetId.equals(wallet.budgetId),
    );
    final holdingsByAsset = {
      for (final holding in holdings) holding.assetId: holding,
    };
    final pnlCurrency = _resolvePnlCurrency(holdings);

    final transactions =
        await SolanaWalletTransaction.db.find(
            session,
            where: (t) =>
                t.walletId.equals(walletId) &
                t.budgetId.equals(wallet.budgetId),
            orderBy: (t) => t.occurredAt,
          )
          ..sort(_transactionSort);

    final stateByAsset = <String, _CostBasisState>{};
    final warningSet = warnings.toSet();

    for (final tx in transactions) {
      final tokenTransfers = _decodeTokenTransfers(tx.tokenTransfersJson);
      final netRawByAsset = <String, int>{};

      for (final transfer in tokenTransfers) {
        final mint = transfer.mint?.trim();
        if (mint == null || mint.isEmpty) continue;

        var deltaRaw = 0;
        if (_isSameAddress(transfer.toUserAccount, wallet.address)) {
          deltaRaw += transfer.tokenAmount;
        }
        if (_isSameAddress(transfer.fromUserAccount, wallet.address)) {
          deltaRaw -= transfer.tokenAmount;
        }

        if (deltaRaw == 0) continue;
        netRawByAsset[mint] = (netRawByAsset[mint] ?? 0) + deltaRaw;
      }

      var txCostBasis = 0.0;
      var txProceeds = 0.0;
      var txRealized = 0.0;
      var hasEstimate = false;

      for (final entry in netRawByAsset.entries) {
        final mint = entry.key;
        final deltaRaw = entry.value;
        final holding = holdingsByAsset[mint];
        if (holding == null) continue;

        final pricePerToken = holding.pricePerToken;
        if (pricePerToken == null) {
          final warning = 'Missing price for P&L estimate asset $mint';
          if (warningSet.add(warning)) warnings.add(warning);
          continue;
        }

        final deltaUi = _toUiAmount(deltaRaw, holding.decimals);
        if (deltaUi.abs() <= _pnlEpsilon) continue;

        final state = stateByAsset.putIfAbsent(mint, _CostBasisState.new);
        if (deltaUi > 0) {
          final addedCostBasis = deltaUi * pricePerToken;
          state
            ..quantityUi += deltaUi
            ..costBasis += addedCostBasis;
          continue;
        }

        final disposedUi = deltaUi.abs();
        final availableQuantity = state.quantityUi;
        final averageCostPerUnit = availableQuantity > _pnlEpsilon
            ? state.costBasis / availableQuantity
            : 0.0;
        final matchedQuantity = math.min(disposedUi, availableQuantity);
        final removedCostBasis = matchedQuantity * averageCostPerUnit;
        final proceeds = disposedUi * pricePerToken;
        final realizedPnl = proceeds - removedCostBasis;

        state
          ..quantityUi = math.max(0, availableQuantity - disposedUi)
          ..costBasis = math.max(0, state.costBasis - removedCostBasis)
          ..realizedPnl += realizedPnl;

        txCostBasis += removedCostBasis;
        txProceeds += proceeds;
        txRealized += realizedPnl;
        hasEstimate = true;

        if (disposedUi > availableQuantity + _pnlEpsilon) {
          final warning =
              'Partial P&L estimate for $mint: disposal exceeded tracked basis quantity.';
          if (warningSet.add(warning)) warnings.add(warning);
        }
      }

      final estimatedCostBasis = hasEstimate ? txCostBasis : null;
      final estimatedProceeds = hasEstimate ? txProceeds : null;
      final estimatedRealizedPnl = hasEstimate ? txRealized : null;
      final nextPnlCurrency = hasEstimate ? pnlCurrency : null;
      final nextTaxYear = tx.occurredAt?.year;

      final requiresUpdate =
          !_doubleEqualsNullable(tx.estimatedCostBasis, estimatedCostBasis) ||
          !_doubleEqualsNullable(tx.estimatedProceeds, estimatedProceeds) ||
          !_doubleEqualsNullable(
            tx.estimatedRealizedPnl,
            estimatedRealizedPnl,
          ) ||
          tx.pnlCurrency != nextPnlCurrency ||
          tx.taxYear != nextTaxYear;

      if (!requiresUpdate) continue;

      await SolanaWalletTransaction.db.updateRow(
        session,
        tx.copyWith(
          estimatedCostBasis: estimatedCostBasis,
          estimatedProceeds: estimatedProceeds,
          estimatedRealizedPnl: estimatedRealizedPnl,
          pnlCurrency: nextPnlCurrency,
          taxYear: nextTaxYear,
          updatedAt: DateTime.now(),
        ),
      );
    }

    for (final holding in holdings) {
      final state = stateByAsset[holding.assetId];
      final estimatedCostBasis = _estimateHoldingCostBasis(holding, state);
      final estimatedUnrealizedPnl =
          holding.totalValue != null && estimatedCostBasis != null
          ? holding.totalValue! - estimatedCostBasis
          : null;
      final estimatedUnrealizedPnlPercent =
          estimatedCostBasis != null &&
              estimatedCostBasis.abs() > _pnlEpsilon &&
              estimatedUnrealizedPnl != null
          ? (estimatedUnrealizedPnl / estimatedCostBasis) * 100
          : null;
      final estimatedRealizedPnl = state?.realizedPnl;
      final shouldSetPnlMetadata =
          estimatedCostBasis != null || estimatedRealizedPnl != null;
      final nextPnlCurrency = shouldSetPnlMetadata ? pnlCurrency : null;
      final pnlValuesChanged =
          !_doubleEqualsNullable(
            holding.estimatedCostBasis,
            estimatedCostBasis,
          ) ||
          !_doubleEqualsNullable(
            holding.estimatedUnrealizedPnl,
            estimatedUnrealizedPnl,
          ) ||
          !_doubleEqualsNullable(
            holding.estimatedUnrealizedPnlPercent,
            estimatedUnrealizedPnlPercent,
          ) ||
          !_doubleEqualsNullable(
            holding.estimatedRealizedPnl,
            estimatedRealizedPnl,
          ) ||
          holding.pnlCurrency != nextPnlCurrency;
      final nextPnlAsOf = shouldSetPnlMetadata
          ? (pnlValuesChanged ? DateTime.now() : holding.pnlAsOf)
          : null;
      final requiresUpdate = pnlValuesChanged || holding.pnlAsOf != nextPnlAsOf;

      if (!requiresUpdate) continue;

      await SolanaWalletHolding.db.updateRow(
        session,
        holding.copyWith(
          estimatedCostBasis: estimatedCostBasis,
          estimatedUnrealizedPnl: estimatedUnrealizedPnl,
          estimatedUnrealizedPnlPercent: estimatedUnrealizedPnlPercent,
          estimatedRealizedPnl: estimatedRealizedPnl,
          pnlCurrency: nextPnlCurrency,
          pnlAsOf: nextPnlAsOf,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  static int _transactionSort(
    SolanaWalletTransaction left,
    SolanaWalletTransaction right,
  ) {
    final leftOccurredAt =
        left.occurredAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final rightOccurredAt =
        right.occurredAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final occurredAtComparison = leftOccurredAt.compareTo(rightOccurredAt);
    if (occurredAtComparison != 0) return occurredAtComparison;
    return left.slot.compareTo(right.slot);
  }

  static String _resolvePnlCurrency(List<SolanaWalletHolding> holdings) {
    for (final holding in holdings) {
      final currency = holding.priceCurrency?.trim();
      if (currency != null && currency.isNotEmpty) {
        return currency.toUpperCase();
      }
    }
    return 'USD';
  }

  static List<_WalletTokenTransfer> _decodeTokenTransfers(
    String? tokenTransfersJson,
  ) {
    if (tokenTransfersJson == null || tokenTransfersJson.trim().isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(tokenTransfersJson);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((item) {
            final tokenAmount = _coerceInt(item['tokenAmount']);
            if (tokenAmount == null) return null;
            return _WalletTokenTransfer(
              fromUserAccount: item['fromUserAccount'] as String?,
              toUserAccount: item['toUserAccount'] as String?,
              mint: item['mint'] as String?,
              tokenAmount: tokenAmount,
            );
          })
          .whereType<_WalletTokenTransfer>()
          .toList(growable: false);
    } on FormatException {
      return const [];
    }
  }

  static int? _coerceInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool _isSameAddress(String? left, String? right) {
    if (left == null || right == null) return false;
    return left.trim() == right.trim();
  }

  static double? _estimateHoldingCostBasis(
    SolanaWalletHolding holding,
    _CostBasisState? state,
  ) {
    final balanceUi = double.tryParse(holding.balanceUi);
    final balanceFromRaw = int.tryParse(holding.balanceRaw);
    final currentBalance =
        balanceUi ??
        (balanceFromRaw == null
            ? 0
            : _toUiAmount(balanceFromRaw, holding.decimals));
    if (currentBalance.abs() <= _pnlEpsilon) return 0;

    if (state == null || state.quantityUi <= _pnlEpsilon) {
      final fallbackPrice = holding.pricePerToken;
      if (fallbackPrice == null) return null;
      return currentBalance * fallbackPrice;
    }

    final scaledCostBasis =
        state.costBasis * (currentBalance / state.quantityUi);
    if (!scaledCostBasis.isFinite || scaledCostBasis.isNaN) return null;
    return math.max(0, scaledCostBasis);
  }

  static bool _doubleEqualsNullable(double? left, double? right) {
    if (left == null && right == null) return true;
    if (left == null || right == null) return false;
    return (left - right).abs() <= _pnlEpsilon;
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

class _CostBasisState {
  double quantityUi = 0;
  double costBasis = 0;
  double realizedPnl = 0;
}

class _WalletTokenTransfer {
  const _WalletTokenTransfer({
    required this.fromUserAccount,
    required this.toUserAccount,
    required this.mint,
    required this.tokenAmount,
  });

  final String? fromUserAccount;
  final String? toUserAccount;
  final String? mint;
  final int tokenAmount;
}
