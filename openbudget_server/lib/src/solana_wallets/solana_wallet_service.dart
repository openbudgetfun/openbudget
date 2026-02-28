import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/accounts/account_service.dart';
import 'package:openbudget_server/src/budgets/budget_service.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/solana_wallets/jupiter_price_client.dart';
import 'package:openbudget_server/src/solana_wallets/solana_transaction_interpreter.dart';
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

  /// Returns estimated realized P&L grouped by tax year for a wallet.
  static Future<List<SolanaWalletTaxYearSummary>> listTaxYearSummaries(
    Session session, {
    required UuidValue walletId,
    required UuidValue budgetId,
  }) async {
    await _getWalletOrThrow(session, walletId: walletId, budgetId: budgetId);

    final transactions = await SolanaWalletTransaction.db.find(
      session,
      where: (t) => t.walletId.equals(walletId) & t.budgetId.equals(budgetId),
      orderBy: (t) => t.taxYear,
      orderDescending: true,
    );

    final byYear = <int, _TaxYearAccumulator>{};
    for (final tx in transactions) {
      final taxYear = tx.taxYear;
      if (taxYear == null) continue;
      final hasEstimate =
          tx.estimatedRealizedPnl != null ||
          tx.estimatedProceeds != null ||
          tx.estimatedCostBasis != null;
      if (!hasEstimate) continue;

      final bucket = byYear.putIfAbsent(taxYear, _TaxYearAccumulator.new)
        ..transactionCount += 1
        ..estimatedRealizedPnl += tx.estimatedRealizedPnl ?? 0
        ..estimatedProceeds += tx.estimatedProceeds ?? 0
        ..estimatedCostBasis += tx.estimatedCostBasis ?? 0;
      final currency = tx.pnlCurrency?.trim();
      if (bucket.pnlCurrency == null &&
          currency != null &&
          currency.isNotEmpty) {
        bucket.pnlCurrency = currency.toUpperCase();
      }
    }

    final summaries =
        byYear.entries
            .map(
              (entry) => SolanaWalletTaxYearSummary(
                walletId: walletId,
                taxYear: entry.key,
                transactionCount: entry.value.transactionCount,
                estimatedRealizedPnl: entry.value.estimatedRealizedPnl,
                estimatedProceeds: entry.value.estimatedProceeds,
                estimatedCostBasis: entry.value.estimatedCostBasis,
                pnlCurrency: entry.value.pnlCurrency ?? 'USD',
              ),
            )
            .toList(growable: false)
          ..sort((left, right) => right.taxYear.compareTo(left.taxYear));

    return summaries;
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
        pricedHoldingCount: valuation.pricedHoldingCount,
        staleHoldingCount: valuation.staleHoldingCount,
        unpricedHoldingCount: valuation.unpricedHoldingCount,
        nftHoldingCount: valuation.nftHoldingCount,
        pricedNftHoldingCount: valuation.pricedNftHoldingCount,
        staleNftHoldingCount: valuation.staleNftHoldingCount,
        unpricedNftHoldingCount: valuation.unpricedNftHoldingCount,
        valuationCoverageRatio: valuation.valuationCoverageRatio,
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
    final interpretation = SolanaTransactionInterpreter.interpret(
      transaction: tx,
      walletAddress: wallet.address,
    );

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

    final stateByAsset = <String, _AssetFifoState>{};
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

        final state = stateByAsset.putIfAbsent(mint, _AssetFifoState.new);
        if (deltaUi > 0) {
          state.addLot(quantityUi: deltaUi, unitCost: pricePerToken);
          continue;
        }

        final disposedUi = deltaUi.abs();
        final availableQuantity = state.totalQuantity;
        final removedCostBasis = state.disposeFifo(disposedUi);
        final proceeds = disposedUi * pricePerToken;
        final realizedPnl = proceeds - removedCostBasis;

        state.realizedPnl += realizedPnl;

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
      final estimatedCostBasis = _estimateHoldingCostBasis(
        holding,
        state,
        warnings: warnings,
        warningSet: warningSet,
      );
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
    _AssetFifoState? state, {
    required List<String> warnings,
    required Set<String> warningSet,
  }) {
    final balanceUi = double.tryParse(holding.balanceUi);
    final balanceFromRaw = int.tryParse(holding.balanceRaw);
    final currentBalance =
        balanceUi ??
        (balanceFromRaw == null
            ? 0
            : _toUiAmount(balanceFromRaw, holding.decimals));
    if (currentBalance.abs() <= _pnlEpsilon) return 0;

    if (state == null || state.totalQuantity <= _pnlEpsilon) {
      final fallbackPrice = holding.pricePerToken;
      if (fallbackPrice == null) return null;
      return currentBalance * fallbackPrice;
    }

    final trackedQuantity = state.totalQuantity;
    final trackedCostBasis = state.totalCostBasis;

    if ((currentBalance - trackedQuantity).abs() <= _pnlEpsilon) {
      return math.max(0, trackedCostBasis);
    }

    if (currentBalance < trackedQuantity) {
      final scaledCostBasis =
          trackedCostBasis * (currentBalance / trackedQuantity);
      if (!scaledCostBasis.isFinite || scaledCostBasis.isNaN) return null;
      final warning =
          'Estimated basis scaled down for ${holding.assetId}: tracked lots exceed current balance.';
      if (warningSet.add(warning)) warnings.add(warning);
      return math.max(0, scaledCostBasis);
    }

    final fallbackPrice = holding.pricePerToken;
    if (fallbackPrice == null) return math.max(0, trackedCostBasis);
    final additionalQuantity = currentBalance - trackedQuantity;
    final warning =
        'Estimated basis backfilled for ${holding.assetId}: current balance exceeds tracked lot quantity.';
    if (warningSet.add(warning)) warnings.add(warning);
    return math.max(0, trackedCostBasis + (additionalQuantity * fallbackPrice));
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
    final now = DateTime.now();
    final existingHoldings = await SolanaWalletHolding.db.find(
      session,
      where: (t) => t.walletId.equals(walletId),
    );
    final existingByAssetId = {
      for (final holding in existingHoldings) holding.assetId: holding,
    };

    final balances = await helius.wallet.getBalances(
      GetBalancesRequest(address: wallet.address),
    );

    final assets = await helius.das.getAssetsByOwner(
      GetAssetsByOwnerRequest(ownerAddress: wallet.address, limit: 1000),
    );

    final assetsById = {for (final asset in assets.items) asset.id: asset};
    final jupiterPrices = await JupiterPriceClient.fetchUsdPrices(
      mintAddresses: balances.tokens.map((token) => token.mint),
      onWarning: (warning) => warnings.add(warning),
    );

    final seenAssetIds = <String>{};
    var totalValuation = 0.0;
    String? valuationCurrency;
    var pricedHoldingCount = 0;
    var staleHoldingCount = 0;
    var unpricedHoldingCount = 0;
    var nftHoldingCount = 0;
    var pricedNftHoldingCount = 0;
    var staleNftHoldingCount = 0;
    var unpricedNftHoldingCount = 0;

    for (final token in balances.tokens) {
      final assetId = token.mint;
      seenAssetIds.add(assetId);

      final asset = assetsById[assetId];
      final existing = existingByAssetId[assetId];
      final decimals = token.decimals;
      final rawAmount = token.amount;
      final uiAmount = _toUiAmount(rawAmount, decimals);
      final priceInfo = asset?.tokenInfo?.priceInfo;
      var priceCurrency = priceInfo?.currency ?? existing?.priceCurrency;
      var pricePerToken = priceInfo?.pricePerToken;
      var totalValue = pricePerToken == null ? null : uiAmount * pricePerToken;
      var priceSource = priceInfo == null ? null : 'helius_das';
      var priceQuality = priceInfo == null ? 'unpriced' : 'provider';
      var isPriceStale = false;
      var priceAsOf = pricePerToken == null ? null : now;

      if (pricePerToken == null) {
        final derivedTotalPrice = priceInfo?.totalPrice;
        if (derivedTotalPrice != null && uiAmount.abs() > _pnlEpsilon) {
          pricePerToken = derivedTotalPrice / uiAmount;
          totalValue = derivedTotalPrice;
          priceSource = 'helius_das_total_price';
          priceQuality = 'derived';
          priceAsOf = now;
        }
      }

      if (pricePerToken == null) {
        final jupiterPrice = jupiterPrices[assetId];
        if (jupiterPrice != null) {
          pricePerToken = jupiterPrice;
          totalValue = uiAmount * jupiterPrice;
          priceCurrency = 'USD';
          priceSource = 'jupiter_price_v3';
          priceQuality = 'provider';
          isPriceStale = false;
          priceAsOf = now;
        }
      }

      if (pricePerToken == null) {
        final cachedPrice = existing?.pricePerToken;
        if (cachedPrice != null) {
          pricePerToken = cachedPrice;
          totalValue = uiAmount * cachedPrice;
          priceCurrency = priceCurrency ?? existing?.priceCurrency;
          priceSource = existing?.priceSource ?? 'cached';
          priceQuality = 'stale_cache';
          isPriceStale = true;
          priceAsOf = existing?.priceAsOf;
          warnings.add('Using cached price for asset $assetId');
        }
      }

      if (totalValue != null) {
        totalValuation += totalValue;
        valuationCurrency ??= priceCurrency;
      }
      final isNft = _isLikelyNft(asset);

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
        isNft: isNft,
        priceCurrency: priceCurrency,
        pricePerToken: pricePerToken,
        totalValue: totalValue,
        priceSource: priceSource,
        priceQuality: priceQuality,
        isPriceStale: isPriceStale,
        priceAsOf: priceAsOf,
        metadataJson: asset == null
            ? null
            : jsonEncode({
                'interface': asset.interface_,
                'symbol': asset.content?.metadata?.symbol,
                'name': asset.content?.metadata?.name,
              }),
        updatedAt: now,
      );

      if (holding.totalValue == null) {
        unpricedHoldingCount += 1;
      } else if (holding.isPriceStale ?? false) {
        staleHoldingCount += 1;
      } else {
        pricedHoldingCount += 1;
      }
      if (isNft) {
        nftHoldingCount += 1;
        if (holding.totalValue == null) {
          unpricedNftHoldingCount += 1;
        } else if (holding.isPriceStale ?? false) {
          staleNftHoldingCount += 1;
        } else {
          pricedNftHoldingCount += 1;
        }
      }

      await _upsertHolding(session, holding);

      if (pricePerToken == null) {
        warnings.add('Missing price for asset $assetId');
      }
    }

    // Include NFT-like assets that may not appear in fungible balances.
    for (final asset in assets.items.where(_isLikelyNft)) {
      if (!seenAssetIds.add(asset.id)) continue;

      final priceInfo = asset.tokenInfo?.priceInfo;
      final existing = existingByAssetId[asset.id];
      var priceCurrency = priceInfo?.currency ?? existing?.priceCurrency;
      var pricePerToken = priceInfo?.pricePerToken;
      var totalValue = priceInfo?.totalPrice;
      var priceSource = priceInfo == null ? null : 'helius_das';
      var priceQuality = priceInfo == null ? 'unpriced' : 'provider';
      var isPriceStale = false;
      var priceAsOf = priceInfo == null ? null : now;

      if (pricePerToken == null && totalValue != null) {
        // NFT-like balances are treated as 1 unit in this sync flow.
        pricePerToken = totalValue;
        priceSource = 'helius_das_total_price';
        priceQuality = 'derived';
      } else if (totalValue == null && pricePerToken != null) {
        totalValue = pricePerToken;
      }

      if (pricePerToken == null) {
        final cachedPrice = existing?.pricePerToken;
        if (cachedPrice != null) {
          pricePerToken = cachedPrice;
          totalValue = cachedPrice;
          priceCurrency = priceCurrency ?? existing?.priceCurrency;
          priceSource = existing?.priceSource ?? 'cached';
          priceQuality = 'stale_cache';
          isPriceStale = true;
          priceAsOf = existing?.priceAsOf;
          warnings.add('Using cached price for NFT asset ${asset.id}');
        }
      }

      if (totalValue != null) {
        totalValuation += totalValue;
        valuationCurrency ??= priceCurrency;
      }

      final nftHolding = SolanaWalletHolding(
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
        priceCurrency: priceCurrency,
        pricePerToken: pricePerToken,
        totalValue: totalValue,
        priceSource: priceSource,
        priceQuality: priceQuality,
        isPriceStale: isPriceStale,
        priceAsOf: priceAsOf,
        metadataJson: jsonEncode({
          'interface': asset.interface_,
          'symbol': asset.content?.metadata?.symbol,
          'name': asset.content?.metadata?.name,
        }),
        updatedAt: now,
      );
      await _upsertHolding(session, nftHolding);

      if (nftHolding.totalValue == null) {
        unpricedHoldingCount += 1;
        unpricedNftHoldingCount += 1;
      } else if (nftHolding.isPriceStale ?? false) {
        staleHoldingCount += 1;
        staleNftHoldingCount += 1;
      } else {
        pricedHoldingCount += 1;
        pricedNftHoldingCount += 1;
      }
      nftHoldingCount += 1;
    }

    for (final holding in existingHoldings) {
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

    final holdingCount = seenAssetIds.length;
    final coveredCount = pricedHoldingCount + staleHoldingCount;
    final valuationCoverageRatio = holdingCount == 0
        ? null
        : coveredCount / holdingCount;

    return _HoldingSyncSummary(
      holdingCount: holdingCount,
      pricedHoldingCount: pricedHoldingCount,
      staleHoldingCount: staleHoldingCount,
      unpricedHoldingCount: unpricedHoldingCount,
      nftHoldingCount: nftHoldingCount,
      pricedNftHoldingCount: pricedNftHoldingCount,
      staleNftHoldingCount: staleNftHoldingCount,
      unpricedNftHoldingCount: unpricedNftHoldingCount,
      valuationCoverageRatio: valuationCoverageRatio,
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
      priceQuality: incoming.priceQuality,
      isPriceStale: incoming.isPriceStale,
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
    required this.pricedHoldingCount,
    required this.staleHoldingCount,
    required this.unpricedHoldingCount,
    required this.nftHoldingCount,
    required this.pricedNftHoldingCount,
    required this.staleNftHoldingCount,
    required this.unpricedNftHoldingCount,
    required this.valuationCoverageRatio,
    required this.totalValuation,
    required this.valuationCurrency,
  });

  final int holdingCount;
  final int pricedHoldingCount;
  final int staleHoldingCount;
  final int unpricedHoldingCount;
  final int nftHoldingCount;
  final int pricedNftHoldingCount;
  final int staleNftHoldingCount;
  final int unpricedNftHoldingCount;
  final double? valuationCoverageRatio;
  final double? totalValuation;
  final String? valuationCurrency;
}

class _AssetFifoState {
  final List<_FifoLot> _lots = [];
  double realizedPnl = 0;

  double get totalQuantity =>
      _lots.fold<double>(0, (sum, lot) => sum + lot.quantityUi);

  double get totalCostBasis => _lots.fold<double>(
    0,
    (sum, lot) => sum + (lot.quantityUi * lot.unitCost),
  );

  void addLot({required double quantityUi, required double unitCost}) {
    if (quantityUi <= 0) return;
    _lots.add(_FifoLot(quantityUi: quantityUi, unitCost: unitCost));
  }

  double disposeFifo(double quantityUi) {
    var remaining = quantityUi;
    var removedCostBasis = 0.0;
    while (remaining > SolanaWalletService._pnlEpsilon && _lots.isNotEmpty) {
      final lot = _lots.first;
      final consumed = math.min(remaining, lot.quantityUi);
      removedCostBasis += consumed * lot.unitCost;
      lot.quantityUi -= consumed;
      remaining -= consumed;
      if (lot.quantityUi <= SolanaWalletService._pnlEpsilon) {
        _lots.removeAt(0);
      }
    }
    return removedCostBasis;
  }
}

class _FifoLot {
  _FifoLot({required this.quantityUi, required this.unitCost});

  double quantityUi;
  final double unitCost;
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

class _TaxYearAccumulator {
  int transactionCount = 0;
  double estimatedRealizedPnl = 0;
  double estimatedProceeds = 0;
  double estimatedCostBasis = 0;
  String? pnlCurrency;
}
