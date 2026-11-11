import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/accounts/account_service.dart';
import 'package:openbudget_server/src/accounts/account_valuation_service.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/wallets/solana_wallet_provider.dart';
import 'package:openbudget_server/src/wallets/wallet_math.dart';
import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:serverpod/serverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Builds the chain provider for one wallet and network.
typedef WalletProviderFactory = WalletProvider Function(
  Session session,
  WalletNetwork network,
);

/// Publishes a committed wallet change.
typedef WalletChangePublisher = Future<void> Function(
  Session session,
  UuidValue entityId,
  ChangeScope scope, {
  int? month,
  UuidValue? accountId,
});

/// Owns read-only blockchain wallets, their holdings, transactions and the
/// crypto account whose valuation carries the wallet into net worth.
///
/// Every read and write crosses [EntityAccess]. Network fetches happen before
/// the sync transaction opens; holdings, the today valuation, the cursor and
/// parsed transactions then commit together or not at all.
abstract final class WalletService {
  static final _log = ObLogger('WalletService');
  static const _valuationCurrency = 'USD';
  static const _defaultTransactionLimit = 100;
  static const _maxTransactionLimit = 200;
  static const _maxTags = 20;
  static const _maxTagLength = 50;

  static WalletProviderFactory _providerFactory = _heliusProvider;
  static WalletChangePublisher _publisher = EntityRealtimeNotifier.notify;

  /// The chain provider used by [connect] and [sync].
  @visibleForTesting
  static WalletProviderFactory get debugProviderFactory => _providerFactory;

  /// Replaces the chain provider factory so a test can vary by network.
  @visibleForTesting
  static set debugProviderFactory(WalletProviderFactory factory) {
    _providerFactory = factory;
  }

  /// The publisher receiving committed wallet changes.
  @visibleForTesting
  static WalletChangePublisher get debugPublisher => _publisher;

  /// Replaces how committed wallet changes are delivered.
  @visibleForTesting
  static set debugPublisher(WalletChangePublisher publisher) {
    _publisher = publisher;
  }

  /// Restores the production provider and message bus.
  @visibleForTesting
  static void resetForTests() {
    _providerFactory = _heliusProvider;
    _publisher = EntityRealtimeNotifier.notify;
  }

  /// Creates the wallet and its fixed crypto account in one transaction, then
  /// syncs.
  ///
  /// A sync failure keeps the usable local wallet and account, marks the
  /// wallet failed with a clear error, and never erases committed facts.
  static Future<Wallet> connect(
    Session session,
    UuidValue entityId,
    WalletNetwork network,
    String address, {
    String? label,
    String? accountName,
  }) async {
    final normalizedAddress = _requireAddress(address);
    _requireNetwork(network);
    final cleanLabel = _normaliseOptional(label);
    final cleanAccountName = _normaliseOptional(accountName);

    final connection = await session.db.transaction((tx) async {
      final entity = await EntityAccess.requireOwned(
        session,
        entityId,
        transaction: tx,
        lock: true,
      );
      _requireWritable(entity);

      final existing = await Wallet.db.findFirstRow(
        session,
        where: (t) =>
            t.entityId.equals(entityId) &
            t.network.equals(network) &
            t.address.equals(normalizedAddress),
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (existing != null) {
        var wallet = existing;
        final account = await Account.db.findById(
          session,
          existing.accountId,
          transaction: tx,
          lockMode: LockMode.forUpdate,
        );
        if (account == null) {
          throw StateError('Wallet ${existing.id} has no crypto account.');
        }
        if (cleanLabel != null && cleanLabel != existing.label) {
          wallet = await Wallet.db.updateRow(
            session,
            existing.copyWith(
              label: cleanLabel,
              updatedAt: DateTime.now().toUtc(),
            ),
            transaction: tx,
          );
        }
        if (cleanAccountName != null && cleanAccountName != account.name) {
          await Account.db.updateRow(
            session,
            account.copyWith(
              name: cleanAccountName,
              updatedAt: DateTime.now().toUtc(),
            ),
            transaction: tx,
          );
        }
        return wallet;
      }

      final account = await AccountService.createInTransaction(
        session,
        tx,
        entityId: entityId,
        name:
            cleanAccountName ??
            cleanLabel ??
            'Solana Wallet (${_shortAddress(normalizedAddress)})',
        kind: AccountKind.crypto,
        currencyCode: _valuationCurrency,
        balanceSource: AccountBalanceSource.valuations,
        onBudget: false,
      );
      final now = DateTime.now().toUtc();
      return Wallet.db.insertRow(
        session,
        Wallet(
          entityId: entityId,
          accountId: account.id!,
          network: network,
          address: normalizedAddress,
          label: cleanLabel,
          syncStatus: SyncStatus.pending,
          createdAt: now,
          updatedAt: now,
        ),
        transaction: tx,
      );
    });

    await _publish(
      session,
      connection.entityId,
      ChangeScope.accounts,
      accountId: connection.accountId,
    );

    try {
      await sync(session, connection.id!);
    } on Exception catch (error, stackTrace) {
      _log.warning(
        'Wallet connected but initial sync failed for ${connection.id}: $error',
        stackTrace,
      );
    }
    return await Wallet.db.findById(session, connection.id!) ?? connection;
  }

  /// Lists the wallets of one owned entity, newest first.
  static Future<List<Wallet>> list(
    Session session,
    UuidValue entityId,
  ) async {
    await EntityAccess.requireOwned(session, entityId);
    return Wallet.db.find(
      session,
      where: (t) => t.entityId.equals(entityId),
      orderByList: (t) => [t.createdAt.desc(), t.id.desc()],
    );
  }

  /// Loads the wallet that values one owned account, if any.
  static Future<Wallet?> getForAccount(
    Session session,
    UuidValue accountId,
  ) async {
    final account = await Account.db.findById(session, accountId);
    if (account == null) throw NotFoundException();
    await EntityAccess.requireOwned(session, account.entityId);
    return Wallet.db.findFirstRow(
      session,
      where: (t) => t.accountId.equals(accountId),
    );
  }

  /// Fetches the chain, then commits holdings, transactions, the cursor and
  /// today's wallet valuation in one transaction.
  static Future<WalletSyncResult> sync(
    Session session,
    UuidValue walletId,
  ) async {
    var wallet = await _ownedWallet(session, walletId);
    _requireWritable(await EntityAccess.requireOwned(session, wallet.entityId));
    var startedAt = DateTime.now().toUtc();
    var attempt = 0;

    while (true) {
      try {
        final snapshot =
            await _providerFactory(
              session,
              wallet.network,
            ).fetchSnapshot(
              network: wallet.network,
              address: wallet.address,
              untilSignature: wallet.lastSignature,
            );
        final outcome = await _commit(
          session,
          wallet,
          snapshot,
          startedAt: startedAt,
        );
        await _publish(
          session,
          wallet.entityId,
          ChangeScope.accounts,
          accountId: wallet.accountId,
        );
        await _publish(
          session,
          wallet.entityId,
          ChangeScope.transactions,
          accountId: wallet.accountId,
        );
        return outcome;
      } on _SyncConflict {
        attempt += 1;
        if (attempt >= 2) {
          throw ValidationException(
            message: 'Wallet changed while syncing; retry the sync.',
          );
        }
        wallet = await _ownedWallet(session, walletId);
        startedAt = DateTime.now().toUtc();
      } on Object catch (error, stackTrace) {
        _log.warning(
          'Wallet sync failed for $walletId: $error',
          stackTrace,
        );
        await _markFailed(session, walletId, startedAt, error);
        rethrow;
      }
    }
  }

  /// Lists current holdings largest first, with unpriced assets last.
  static Future<List<WalletHolding>> listHoldings(
    Session session,
    UuidValue walletId,
  ) async {
    await _ownedWallet(session, walletId);
    final holdings = await WalletHolding.db.find(
      session,
      where: (t) => t.walletId.equals(walletId),
    );
    return holdings..sort((left, right) {
      final leftValue = left.valueMinor;
      final rightValue = right.valueMinor;
      if (leftValue != rightValue) {
        if (leftValue == null) return 1;
        if (rightValue == null) return -1;
        return rightValue.compareTo(leftValue);
      }
      return left.assetId.compareTo(right.assetId);
    });
  }

  /// Lists one wallet's transactions newest first.
  ///
  /// [limit] is 1-200 and defaults to 100. [before] pages strictly behind the
  /// given timestamp, and ties are ordered by slot then signature so a cursor
  /// cannot skip or repeat a row.
  static Future<List<WalletTransaction>> listTransactions(
    Session session,
    UuidValue walletId, {
    DateTime? before,
    int? limit,
  }) async {
    await _ownedWallet(session, walletId);
    final boundedLimit = limit ?? _defaultTransactionLimit;
    if (boundedLimit < 1 || boundedLimit > _maxTransactionLimit) {
      throw ValidationException(
        message: 'limit must be between 1 and $_maxTransactionLimit',
      );
    }

    final rows = await session.db.unsafeQuery(
      '''
SELECT id::text
FROM wallet_transaction
WHERE "walletId" = @walletId::uuid
  ${before == null ? '' : 'AND "occurredAt" < @before'}
ORDER BY "occurredAt" DESC NULLS LAST, slot DESC, signature DESC
LIMIT @limit''',
      parameters: QueryParameters.named({
        'walletId': walletId.toString(),
        if (before != null) 'before': before.toUtc().toIso8601String(),
        'limit': boundedLimit,
      }),
    );
    if (rows.isEmpty) return const [];
    final ids = {
      for (final row in rows) UuidValue.fromString(row.first as String),
    };
    final transactions = await WalletTransaction.db.find(
      session,
      where: (t) => t.id.inSet(ids),
    );
    return transactions..sort(_compareTransactions);
  }

  /// Groups estimated realised P&L by the entity's fiscal year and currency.
  static Future<List<WalletTaxYearSummary>> listTaxYearSummaries(
    Session session,
    UuidValue walletId,
  ) async {
    final wallet = await _ownedWallet(session, walletId);
    final entity = await EntityAccess.requireOwned(session, wallet.entityId);
    final rows = await WalletTransaction.db.find(
      session,
      where: (t) => t.walletId.equals(walletId),
    );

    final buckets = <({int taxYear, String currency}), _TaxBucket>{};
    for (final row in rows) {
      final currency = _normaliseOptional(row.pnlCurrencyCode)?.toUpperCase();
      final occurredAt = row.occurredAt;
      if (currency == null || occurredAt == null) continue;
      if (row.costBasisMinor == null &&
          row.proceedsMinor == null &&
          row.realizedPnlMinor == null) {
        continue;
      }
      final local = tz.TZDateTime.from(
        occurredAt.toUtc(),
        EntityClock.location(entity.timeZone),
      );
      final taxYear = _fiscalYearStart(
        local.year,
        local.month,
        local.day,
        entity.fiscalYearEndMonth,
        entity.fiscalYearEndDay,
      );
      final key = (taxYear: taxYear, currency: currency);
      buckets.putIfAbsent(key, _TaxBucket.new)
        ..transactionCount += 1
        ..realized += BigInt.from(row.realizedPnlMinor ?? 0)
        ..proceeds += BigInt.from(row.proceedsMinor ?? 0)
        ..costBasis += BigInt.from(row.costBasisMinor ?? 0);
    }

    final summaries = <WalletTaxYearSummary>[];
    for (final entry in buckets.entries) {
      summaries.add(
        WalletTaxYearSummary(
          walletId: walletId,
          taxYear: entry.key.taxYear,
          transactionCount: entry.value.transactionCount,
          pnlCurrencyCode: entry.key.currency,
          realizedPnlMinor: _safeMinor(entry.value.realized, 'realised P&L'),
          proceedsMinor: _safeMinor(entry.value.proceeds, 'proceeds'),
          costBasisMinor: _safeMinor(entry.value.costBasis, 'cost basis'),
        ),
      );
    }
    return summaries..sort((left, right) {
      final byYear = right.taxYear.compareTo(left.taxYear);
      if (byYear != 0) return byYear;
      return left.pnlCurrencyCode.compareTo(right.pnlCurrencyCode);
    });
  }

  /// Replaces the user-managed classification of one wallet transaction.
  ///
  /// A null field keeps the current value; an empty category or memo clears
  /// it, and an empty tag list clears every tag. Tags are trimmed, deduplicated
  /// and bounded so a metadata patch cannot grow without limit.
  static Future<WalletTransaction> updateTransactionMetadata(
    Session session,
    UuidValue walletTransactionId, {
    String? category,
    List<String>? tags,
    String? memo,
  }) async {
    final discovered = await WalletTransaction.db.findById(
      session,
      walletTransactionId,
    );
    if (discovered == null) throw NotFoundException();
    final wallet = await Wallet.db.findById(session, discovered.walletId);
    if (wallet == null) throw NotFoundException();
    final entity = await EntityAccess.requireOwned(session, wallet.entityId);
    _requireWritable(entity);

    final cleanCategory = category == null
        ? null
        : _normaliseOptional(category);
    final cleanMemo = memo == null ? null : _normaliseOptional(memo);
    final cleanTags = tags == null ? null : _normaliseTags(tags);

    final updated = await session.db.transaction((tx) async {
      await EntityAccess.requireOwned(
        session,
        wallet.entityId,
        transaction: tx,
        lock: true,
      );
      await Wallet.db.findById(
        session,
        wallet.id!,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      final current = await WalletTransaction.db.findById(
        session,
        walletTransactionId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (current == null) throw NotFoundException();
      return WalletTransaction.db.updateRow(
        session,
        current.copyWith(
          category: category == null ? current.category : cleanCategory,
          tags: tags == null ? current.tags : cleanTags,
          memo: memo == null ? current.memo : cleanMemo,
          updatedAt: DateTime.now().toUtc(),
        ),
        transaction: tx,
      );
    });

    await _publish(
      session,
      wallet.entityId,
      ChangeScope.transactions,
      accountId: wallet.accountId,
    );
    return updated;
  }

  /// Deletes the wallet. With [deleteAccount] the crypto account is deleted
  /// through [AccountService], so every account deletion protection applies;
  /// otherwise the account and its valuation history remain.
  static Future<void> disconnect(
    Session session,
    UuidValue walletId, {
    bool? deleteAccount,
  }) async {
    final wallet = await _ownedWallet(session, walletId);
    final entity = await EntityAccess.requireOwned(session, wallet.entityId);
    _requireWritable(entity);

    if (deleteAccount ?? false) {
      await AccountService.delete(session, wallet.accountId);
      return;
    }

    final entityId = await session.db.transaction((tx) async {
      final currentEntity = await EntityAccess.requireOwned(
        session,
        wallet.entityId,
        transaction: tx,
        lock: true,
      );
      _requireWritable(currentEntity);
      final current = await Wallet.db.findById(
        session,
        walletId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (current == null) throw NotFoundException();
      await Wallet.db.deleteRow(session, current, transaction: tx);
      return current.entityId;
    });

    await _publish(
      session,
      entityId,
      ChangeScope.accounts,
      accountId: wallet.accountId,
    );
  }

  static Future<WalletSyncResult> _commit(
    Session session,
    Wallet wallet,
    WalletProviderSnapshot snapshot, {
    required DateTime startedAt,
  }) async {
    final outcome = await session.db.transaction((tx) async {
      final entity = await EntityAccess.requireOwned(
        session,
        wallet.entityId,
        transaction: tx,
        lock: true,
      );
      _requireWritable(entity);
      final current = await Wallet.db.findById(
        session,
        wallet.id!,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (current == null) throw NotFoundException();

      final lastSyncedAt = current.lastSyncedAt;
      if (lastSyncedAt != null && lastSyncedAt.isAfter(startedAt)) {
        throw const _SyncConflict();
      }
      final fetchedSignatures = {
        for (final transaction in snapshot.transactions) transaction.signature,
      };
      final newest = snapshot.newestSignature;
      if (current.lastSignature != null &&
          current.lastSignature != wallet.lastSignature &&
          !fetchedSignatures.contains(current.lastSignature) &&
          current.lastSignature != newest) {
        throw const _SyncConflict();
      }

      final warnings = [...snapshot.warnings];
      final existingHoldings = await WalletHolding.db.find(
        session,
        where: (t) => t.walletId.equals(wallet.id),
        transaction: tx,
      );
      final existingByAsset = {
        for (final holding in existingHoldings) holding.assetId: holding,
      };
      final cacheRows = snapshot.holdings.isEmpty
          ? const <AssetPrice>[]
          : await AssetPrice.db.find(
              session,
              where: (t) =>
                  t.network.equals(wallet.network) &
                  t.assetId.inSet({
                    for (final holding in snapshot.holdings) holding.assetId,
                  }),
              transaction: tx,
            );
      final cacheByAsset = {
        for (final row in cacheRows) row.assetId: row,
      };

      final resolved = <_ResolvedHolding>[];
      final seenAssets = <String>{};
      for (final holding in snapshot.holdings) {
        final assetId = holding.assetId.trim();
        if (assetId.isEmpty || !seenAssets.add(assetId)) {
          throw ValidationException(
            message: 'Provider returned an invalid or duplicate asset id.',
          );
        }
        _requireHoldingQuantity(assetId, holding.quantityRaw, holding.decimals);
        final existing = existingByAsset[assetId];
        final choice = _choosePrice(
          holding,
          existing: existing,
          cached: cacheByAsset[assetId],
          warnings: warnings,
        );
        int? valueMinor;
        String? unitPrice;
        if (choice != null) {
          unitPrice = choice.unitPrice;
          try {
            valueMinor = choice.totalPrice == null
                ? WalletMath.valueMinor(
                    quantityRaw: holding.quantityRaw,
                    decimals: holding.decimals,
                    unitPrice: choice.exactUnitPrice!,
                    currencyCode: choice.currencyCode,
                  )
                : WalletMath.totalValueMinor(
                    totalPrice: choice.totalPrice!,
                    currencyCode: choice.currencyCode,
                  );
            if (unitPrice == null && choice.totalPrice != null) {
              unitPrice = WalletMath.unitPriceFromTotal(
                totalPrice: choice.totalPrice!,
                quantityRaw: holding.quantityRaw,
                decimals: holding.decimals,
              );
            }
          } on WalletValueException catch (error) {
            throw ValidationException(
              message: 'Wallet value for $assetId is unsafe: ${error.message}',
            );
          }
          if (valueMinor == null) {
            warnings.add(
              'No supported currency exponent for $assetId; left unpriced.',
            );
          }
        }
        if (choice == null || valueMinor == null) {
          warnings.add('Missing price for asset $assetId');
        }

        resolved.add(
          _ResolvedHolding(
            assetId: assetId,
            symbol: holding.symbol,
            name: holding.name,
            tokenProgram: holding.tokenProgram,
            decimals: holding.decimals,
            quantityRaw: holding.quantityRaw,
            isNft: holding.isNft,
            metadataJson: holding.metadataJson,
            unitPrice: valueMinor == null ? null : unitPrice,
            valueMinor: valueMinor,
            currencyCode: valueMinor == null ? null : choice!.currencyCode,
            source: valueMinor == null ? null : choice!.source,
            quality: valueMinor == null
                ? PriceQuality.unpriced
                : choice!.quality,
            confidence: valueMinor == null ? null : choice!.confidence,
            asOf: valueMinor == null ? null : choice!.asOf,
            freshCache:
                choice != null &&
                choice.quality != PriceQuality.cached &&
                choice.source != null,
          ),
        );
      }

      var total = BigInt.zero;
      for (final holding in resolved) {
        if (holding.valueMinor != null) {
          total += BigInt.from(holding.valueMinor!);
        }
      }
      final totalValueMinor = _safeMinor(total, 'wallet total value');

      final persistedHoldings = <String, WalletHolding>{};
      final transactions = <String, WalletTransaction>{};
      final now = DateTime.now().toUtc();
      var insertedTransactions = 0;
      var updatedTransactions = 0;

      for (final transaction in snapshot.transactions) {
        if (transaction.signature.trim().isEmpty) {
          throw ValidationException(
            message: 'Provider returned a transaction without a signature.',
          );
        }
        final existing = await WalletTransaction.db.findFirstRow(
          session,
          where: (t) =>
              t.walletId.equals(wallet.id) &
              t.signature.equals(transaction.signature),
          transaction: tx,
          lockMode: LockMode.forUpdate,
        );
        if (existing == null) {
          final inserted = await WalletTransaction.db.insertRow(
            session,
            WalletTransaction(
              walletId: wallet.id!,
              signature: transaction.signature,
              slot: transaction.slot,
              occurredAt: transaction.occurredAt,
              description: transaction.description,
              txType: transaction.txType,
              source: transaction.source,
              interpretationConfidence: transaction.interpretationConfidence,
              programsJson: transaction.programsJson,
              nativeTransfersJson: transaction.nativeTransfersJson,
              tokenTransfersJson: transaction.tokenTransfersJson,
              rawJson: transaction.rawJson,
              createdAt: now,
              updatedAt: now,
            ),
            transaction: tx,
          );
          transactions[inserted.signature] = inserted;
          insertedTransactions += 1;
        } else {
          final updated = await WalletTransaction.db.updateRow(
            session,
            existing.copyWith(
              slot: transaction.slot,
              occurredAt: transaction.occurredAt,
              description: transaction.description,
              txType: transaction.txType,
              source: transaction.source,
              interpretationConfidence: transaction.interpretationConfidence,
              programsJson: transaction.programsJson,
              nativeTransfersJson: transaction.nativeTransfersJson,
              tokenTransfersJson: transaction.tokenTransfersJson,
              rawJson: transaction.rawJson,
              updatedAt: now,
            ),
            transaction: tx,
          );
          transactions[updated.signature] = updated;
          updatedTransactions += 1;
        }
      }

      for (final holding in resolved) {
        final existing = existingByAsset[holding.assetId];
        if (existing == null) {
          persistedHoldings[holding.assetId] = await WalletHolding.db.insertRow(
            session,
            WalletHolding(
              walletId: wallet.id!,
              assetId: holding.assetId,
              symbol: holding.symbol,
              name: holding.name,
              tokenProgram: holding.tokenProgram,
              decimals: holding.decimals,
              quantityRaw: holding.quantityRaw,
              isNft: holding.isNft,
              priceCurrencyCode: holding.currencyCode,
              unitPrice: holding.unitPrice,
              valueMinor: holding.valueMinor,
              priceSource: holding.source,
              priceQuality: holding.quality,
              priceConfidence: holding.confidence,
              priceAsOf: holding.asOf,
              metadataJson: holding.metadataJson,
              updatedAt: now,
            ),
            transaction: tx,
          );
        } else {
          persistedHoldings[holding.assetId] = await WalletHolding.db.updateRow(
            session,
            existing.copyWith(
              symbol: holding.symbol,
              name: holding.name,
              tokenProgram: holding.tokenProgram,
              decimals: holding.decimals,
              quantityRaw: holding.quantityRaw,
              isNft: holding.isNft,
              priceCurrencyCode: holding.currencyCode,
              unitPrice: holding.unitPrice,
              valueMinor: holding.valueMinor,
              priceSource: holding.source,
              priceQuality: holding.quality,
              priceConfidence: holding.confidence,
              priceAsOf: holding.asOf,
              metadataJson: holding.metadataJson,
              updatedAt: now,
            ),
            transaction: tx,
          );
        }
      }

      for (final existing in existingHoldings) {
        if (!seenAssets.contains(existing.assetId)) {
          await WalletHolding.db.deleteRow(session, existing, transaction: tx);
        }
      }

      final allTransactions = await WalletTransaction.db.find(
        session,
        where: (t) => t.walletId.equals(wallet.id),
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      final pnlTransactions = <WalletPnlTransaction>[];
      for (final row in allTransactions) {
        final movements = _decodeMovements(
          row.tokenTransfersJson,
          warnings: warnings,
          signature: row.signature,
        );
        if (movements == null) continue;
        pnlTransactions.add(
          WalletPnlTransaction(
            signature: row.signature,
            slot: row.slot,
            occurredAt: row.occurredAt,
            movements: movements,
          ),
        );
      }
      final pnl = WalletPnlCalculator.estimate(
        walletAddress: wallet.address,
        transactions: pnlTransactions,
        holdings: [
          for (final holding in resolved)
            if (holding.unitPrice != null)
              WalletPnlHolding(
                assetId: holding.assetId,
                quantityRaw: holding.quantityRaw,
                decimals: holding.decimals,
                unitPrice: ExactDecimal.tryParse(holding.unitPrice!)!,
                currencyCode: holding.currencyCode!,
              ),
        ],
      );
      warnings.addAll(pnl.warnings);
      for (final transaction in allTransactions) {
        final estimate = pnl.transactions[transaction.signature];
        if (!_pnlTransactionChanged(transaction, estimate)) continue;
        await WalletTransaction.db.updateRow(
          session,
          transaction.copyWith(
            costBasisMinor: estimate?.costBasisMinor,
            proceedsMinor: estimate?.proceedsMinor,
            realizedPnlMinor: estimate?.realizedPnlMinor,
            pnlCurrencyCode: estimate?.currencyCode,
            updatedAt: now,
          ),
          transaction: tx,
        );
      }
      for (final entry in persistedHoldings.entries) {
        final estimate = pnl.holdings[entry.key];
        final holding = entry.value;
        final costBasis = estimate?.costBasisMinor;
        final realized = estimate?.realizedPnlMinor;
        final changed =
            holding.costBasisMinor != costBasis ||
            holding.realizedPnlMinor != realized;
        if (!changed) continue;
        await WalletHolding.db.updateRow(
          session,
          holding.copyWith(
            costBasisMinor: costBasis,
            realizedPnlMinor: realized,
            pnlAsOf: costBasis == null && realized == null ? null : now,
            updatedAt: now,
          ),
          transaction: tx,
        );
      }

      await _upsertFreshPrices(
        session,
        tx,
        wallet.network,
        resolved,
        warnings,
        now,
      );

      final valuationDate = EntityClock.today(entity);
      await AccountValuationService.setInTransaction(
        session,
        tx,
        wallet.accountId,
        valuationDate,
        totalValueMinor,
        source: ValuationSource.wallet,
        note: 'Wallet sync',
      );

      final syncedAt = DateTime.now().toUtc();
      final updatedWallet = await Wallet.db.updateRow(
        session,
        current.copyWith(
          lastSignature: newest ?? current.lastSignature,
          syncStatus: SyncStatus.synced,
          lastSyncedAt: syncedAt,
          // Explicit null clears a previous failure, not keeps it.
          // ignore: avoid_redundant_argument_values
          lastSyncError: null,
          updatedAt: syncedAt,
        ),
        transaction: tx,
      );

      final priced = resolved
          .where(
            (h) => h.valueMinor != null && h.quality != PriceQuality.cached,
          )
          .length;
      final cached = resolved
          .where((h) => h.quality == PriceQuality.cached)
          .length;
      final unpriced = resolved.length - priced - cached;
      final pricedNfts = resolved
          .where(
            (h) =>
                h.isNft &&
                h.valueMinor != null &&
                h.quality != PriceQuality.cached,
          )
          .length;
      final cachedNfts = resolved
          .where((h) => h.isNft && h.quality == PriceQuality.cached)
          .length;
      final unpricedNfts = resolved
          .where((h) => h.isNft && h.valueMinor == null)
          .length;
      final uniqueWarnings = <String>[];
      final seenWarnings = <String>{};
      for (final warning in warnings) {
        if (seenWarnings.add(warning)) uniqueWarnings.add(warning);
      }

      return (
        result: WalletSyncResult(
          walletId: updatedWallet.id!,
          insertedTransactions: insertedTransactions,
          updatedTransactions: updatedTransactions,
          holdingCount: resolved.length,
          pricedHoldingCount: priced,
          cachedHoldingCount: cached,
          unpricedHoldingCount: unpriced,
          nftHoldingCount: resolved.where((h) => h.isNft).length,
          pricedNftHoldingCount: pricedNfts,
          cachedNftHoldingCount: cachedNfts,
          unpricedNftHoldingCount: unpricedNfts,
          valuationCoverageRatio: resolved.isEmpty
              ? null
              : (priced + cached) / resolved.length,
          totalValueMinor: resolved.isEmpty ? null : totalValueMinor,
          valuationCurrencyCode: resolved.isEmpty ? null : _valuationCurrency,
          syncedAt: syncedAt,
          warnings: uniqueWarnings,
        ),
        entityId: wallet.entityId,
        accountId: wallet.accountId,
      );
    });
    return outcome.result;
  }

  static _PriceChoice? _choosePrice(
    WalletProviderHolding holding, {
    required WalletHolding? existing,
    required AssetPrice? cached,
    required List<String> warnings,
  }) {
    for (final candidate in holding.prices) {
      if (candidate.currencyCode.toUpperCase() != _valuationCurrency) {
        warnings.add(
          'Ignoring ${candidate.currencyCode} price for ${holding.assetId}; '
          'wallets value in $_valuationCurrency only.',
        );
        continue;
      }
      final unit = candidate.unitPrice;
      final total = candidate.totalPrice;
      if ((unit == null && total == null) ||
          (unit != null && unit.numerator <= BigInt.zero) ||
          (total != null && total.numerator <= BigInt.zero)) {
        warnings.add(
          'Ignoring invalid provider price for ${holding.assetId}.',
        );
        continue;
      }
      return _PriceChoice(
        unitPrice: unit?.toString(),
        exactUnitPrice: unit,
        totalPrice: total,
        currencyCode: _valuationCurrency,
        source: candidate.source,
        quality: candidate.quality,
        confidence: candidate.confidence,
        asOf: candidate.asOf,
      );
    }

    final cachedPrice =
        WalletMath.parseUnitPrice(existing?.unitPrice) ??
        WalletMath.parseUnitPrice(cached?.unitPrice);
    if (cachedPrice == null) return null;
    warnings.add('Using cached price for asset ${holding.assetId}');
    return _PriceChoice(
      unitPrice: cachedPrice.toString(),
      exactUnitPrice: cachedPrice,
      currencyCode: _valuationCurrency,
      source: existing?.priceSource ?? cached?.source,
      quality: PriceQuality.cached,
      confidence: Confidence.low,
      asOf: existing?.priceAsOf ?? cached?.fetchedAt,
    );
  }

  static Future<void> _upsertFreshPrices(
    Session session,
    Transaction tx,
    WalletNetwork network,
    List<_ResolvedHolding> holdings,
    List<String> warnings,
    DateTime now,
  ) async {
    for (final holding in holdings) {
      if (!holding.freshCache || holding.unitPrice == null) continue;
      final unitPrice = ExactDecimal.tryParse(holding.unitPrice!);
      if (unitPrice == null) continue;
      final source = holding.source;
      if (source == null) {
        warnings.add('Price for ${holding.assetId} has no source; not cached.');
        continue;
      }
      await AssetPrice.db.upsertRow(
        session,
        AssetPrice(
          network: network,
          assetId: holding.assetId,
          symbol: holding.symbol,
          currencyCode: _valuationCurrency,
          unitPrice: unitPrice.toString(),
          source: source,
          fetchedAt: now,
          expiresAt: now.add(const Duration(minutes: 15)),
        ),
        conflictColumns: (t) => [t.network, t.assetId],
        updateColumns: (t) => [
          t.symbol,
          t.currencyCode,
          t.unitPrice,
          t.source,
          t.fetchedAt,
          t.expiresAt,
        ],
        transaction: tx,
      );
    }
  }

  static Future<void> _markFailed(
    Session session,
    UuidValue walletId,
    DateTime startedAt,
    Object error,
  ) async {
    try {
      await session.db.transaction((tx) async {
        final current = await Wallet.db.findById(
          session,
          walletId,
          transaction: tx,
          lockMode: LockMode.forUpdate,
        );
        if (current == null) return;
        final entity = await Entity.db.findById(
          session,
          current.entityId,
          transaction: tx,
        );
        if (entity == null || entity.archivedAt != null) return;
        final lastSyncedAt = current.lastSyncedAt;
        if (lastSyncedAt != null && lastSyncedAt.isAfter(startedAt)) {
          return;
        }
        final message = error.toString();
        await Wallet.db.updateRow(
          session,
          current.copyWith(
            syncStatus: SyncStatus.failed,
            lastSyncError: message.length <= 1000
                ? message
                : '${message.substring(0, 997)}...',
            updatedAt: DateTime.now().toUtc(),
          ),
          transaction: tx,
        );
      });
    } on Object catch (failure) {
      _log.warning('Could not mark wallet $walletId failed: $failure');
    }
  }

  static Future<Wallet> _ownedWallet(
    Session session,
    UuidValue walletId,
  ) async {
    final wallet = await Wallet.db.findById(session, walletId);
    if (wallet == null) throw NotFoundException();
    await EntityAccess.requireOwned(session, wallet.entityId);
    return wallet;
  }

  static Future<void> _publish(
    Session session,
    UuidValue entityId,
    ChangeScope scope, {
    UuidValue? accountId,
  }) async {
    try {
      await _publisher(session, entityId, scope, accountId: accountId);
    } on Object catch (error, stackTrace) {
      _log.warning(
        'Wallet event $scope for $entityId could not be published: $error',
        stackTrace,
      );
    }
  }

  static int _compareTransactions(
    WalletTransaction left,
    WalletTransaction right,
  ) {
    final leftAt = left.occurredAt;
    final rightAt = right.occurredAt;
    if (leftAt == null && rightAt != null) return 1;
    if (leftAt != null && rightAt == null) return -1;
    if (leftAt != null && rightAt != null) {
      final byTime = rightAt.compareTo(leftAt);
      if (byTime != 0) return byTime;
    }
    final bySlot = right.slot.compareTo(left.slot);
    if (bySlot != 0) return bySlot;
    return right.signature.compareTo(left.signature);
  }

  static List<WalletTokenMovement>? _decodeMovements(
    String? tokenTransfersJson, {
    required List<String> warnings,
    required String signature,
  }) {
    if (tokenTransfersJson == null || tokenTransfersJson.trim().isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(tokenTransfersJson);
      if (decoded is! List) {
        warnings.add('Could not decode token transfers for $signature.');
        return null;
      }
      final movements = <WalletTokenMovement>[];
      for (final item in decoded) {
        if (item is! Map) {
          warnings.add('Could not decode token transfers for $signature.');
          return null;
        }
        final mint = item['mint'];
        final from = item['fromUserAccount'];
        final to = item['toUserAccount'];
        final amount = _coerceBigInt(item['tokenAmount']);
        if (mint is! String ||
            mint.trim().isEmpty ||
            from is! String ||
            to is! String ||
            amount == null ||
            amount.isNegative) {
          warnings.add('Could not decode token transfers for $signature.');
          return null;
        }
        movements.add(
          WalletTokenMovement(
            mint: mint,
            fromAccount: from,
            toAccount: to,
            amountRaw: amount,
          ),
        );
      }
      return movements;
    } on FormatException {
      warnings.add('Could not decode token transfers for $signature.');
      return null;
    }
  }

  static BigInt? _coerceBigInt(Object? value) {
    if (value is BigInt) return value;
    if (value is int) return BigInt.from(value);
    if (value is num) return BigInt.from(value.toInt());
    if (value is String) return BigInt.tryParse(value);
    return null;
  }

  static bool _pnlTransactionChanged(
    WalletTransaction transaction,
    WalletTransactionPnl? estimate,
  ) =>
      transaction.costBasisMinor != estimate?.costBasisMinor ||
      transaction.proceedsMinor != estimate?.proceedsMinor ||
      transaction.realizedPnlMinor != estimate?.realizedPnlMinor ||
      transaction.pnlCurrencyCode != estimate?.currencyCode;

  static void _requireHoldingQuantity(
    String assetId,
    BigInt quantityRaw,
    int decimals,
  ) {
    if (quantityRaw.isNegative) {
      throw ValidationException(
        message: 'Provider returned a negative quantity for $assetId.',
      );
    }
    if (decimals < 0 || decimals > 36) {
      throw ValidationException(
        message: 'Provider returned invalid decimals for $assetId.',
      );
    }
  }

  static String _requireAddress(String raw) {
    final address = raw.trim();
    if (!_isSolanaAddress(address)) {
      throw ValidationException(
        message: 'Invalid Solana wallet address.',
      );
    }
    return address;
  }

  static void _requireNetwork(WalletNetwork network) {
    switch (network) {
      case WalletNetwork.solanaMainnet:
      case WalletNetwork.solanaDevnet:
        return;
    }
  }

  static Entity _requireWritable(Entity entity) {
    if (entity.archivedAt != null) {
      throw ValidationException(
        message: 'An archived entity rejects wallet changes',
      );
    }
    return entity;
  }

  static String? _normaliseOptional(String? raw) {
    if (raw == null) return null;
    final value = raw.trim();
    return value.isEmpty ? null : value;
  }

  static List<String> _normaliseTags(List<String> tags) {
    final cleaned = <String>[];
    final seen = <String>{};
    for (final raw in tags) {
      final tag = raw.trim();
      if (tag.isEmpty) continue;
      if (tag.length > _maxTagLength) {
        throw ValidationException(
          message: 'A wallet tag is longer than $_maxTagLength characters.',
        );
      }
      if (seen.add(tag)) cleaned.add(tag);
    }
    if (cleaned.length > _maxTags) {
      throw ValidationException(
        message: 'A wallet transaction holds at most $_maxTags tags.',
      );
    }
    return cleaned;
  }

  static int _safeMinor(BigInt value, String field) {
    if (value > BigInt.from(maxSafeMinor) ||
        value < BigInt.from(-maxSafeMinor)) {
      throw ValidationException(
        message: 'Wallet $field exceeds the safe minor-unit range.',
      );
    }
    return value.toInt();
  }

  static int _fiscalYearStart(
    int year,
    int month,
    int day,
    int endMonth,
    int endDay,
  ) {
    final endThisYear = DateTime.utc(year, endMonth, endDay);
    final endYear = !DateTime.utc(year, month, day).isAfter(endThisYear)
        ? year
        : year + 1;
    final start = DateTime.utc(endYear - 1, endMonth, endDay).add(
      const Duration(days: 1),
    );
    return start.year;
  }

  static String _shortAddress(String value) {
    if (value.length <= 10) return value;
    return '${value.substring(0, 4)}...${value.substring(value.length - 4)}';
  }

  static bool _isSolanaAddress(String value) {
    if (value.length < 32 || value.length > 44) return false;
    const alphabet =
        '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    var number = BigInt.zero;
    final base = BigInt.from(58);
    for (final unit in value.codeUnits) {
      final digit = alphabet.indexOf(String.fromCharCode(unit));
      if (digit < 0) return false;
      number = number * base + BigInt.from(digit);
    }
    var leadingZeros = 0;
    while (leadingZeros < value.length && value[leadingZeros] == '1') {
      leadingZeros += 1;
    }
    var byteLength = 0;
    while (number > BigInt.zero) {
      byteLength += 1;
      number >>= 8;
    }
    return leadingZeros + byteLength == 32;
  }

  static WalletProvider _heliusProvider(
    Session session,
    WalletNetwork network,
  ) => SolanaWalletProvider.fromSession(session, network);
}

final class _ResolvedHolding {
  const _ResolvedHolding({
    required this.assetId,
    required this.symbol,
    required this.name,
    required this.tokenProgram,
    required this.decimals,
    required this.quantityRaw,
    required this.isNft,
    required this.metadataJson,
    required this.unitPrice,
    required this.valueMinor,
    required this.currencyCode,
    required this.source,
    required this.quality,
    required this.confidence,
    required this.asOf,
    required this.freshCache,
  });

  final String assetId;
  final String? symbol;
  final String? name;
  final String? tokenProgram;
  final int decimals;
  final BigInt quantityRaw;
  final bool isNft;
  final String? metadataJson;
  final String? unitPrice;
  final int? valueMinor;
  final String? currencyCode;
  final PriceSource? source;
  final PriceQuality quality;
  final Confidence? confidence;
  final DateTime? asOf;
  final bool freshCache;
}

final class _PriceChoice {
  const _PriceChoice({
    required this.unitPrice,
    required this.exactUnitPrice,
    required this.currencyCode,
    required this.source,
    required this.quality,
    required this.confidence,
    required this.asOf,
    this.totalPrice,
  });

  final String? unitPrice;
  final ExactDecimal? exactUnitPrice;
  final ExactDecimal? totalPrice;
  final String currencyCode;
  final PriceSource? source;
  final PriceQuality quality;
  final Confidence confidence;
  final DateTime? asOf;
}

final class _TaxBucket {
  int transactionCount = 0;
  BigInt realized = BigInt.zero;
  BigInt proceeds = BigInt.zero;
  BigInt costBasis = BigInt.zero;
}

final class _SyncConflict implements Exception {
  const _SyncConflict();
}
