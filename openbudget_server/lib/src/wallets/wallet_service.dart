import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/accounts/account_service.dart';
import 'package:openbudget_server/src/accounts/account_valuation_service.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/wallets/wallet_math.dart';
import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:openbudget_server/src/wallets/wallet_provider_registry.dart';
import 'package:openbudget_server/src/wallets/wallet_spam_classifier.dart';
import 'package:serverpod/serverpod.dart';
import 'package:timezone/timezone.dart' as tz;

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

  static WalletProviderFactory _providerFactory = _registryProvider;
  static WalletProviderRegistry _registry =
      WalletProviderRegistry.defaultRegistry;

  /// The server clock used for sync cadence and throttling. Tests inject a
  /// fake clock here; production defaults to UTC now.
  static DateTime Function() clock = () => DateTime.now().toUtc();

  static WalletChangePublisher _publisher = EntityRealtimeNotifier.notify;
  static final _previewRateLimiter = _PreviewRateLimiter(
    clock: () => clock(),
  );

  /// The chain provider used by [connect], [sync] and [preview].
  @visibleForTesting
  static WalletProviderFactory get debugProviderFactory => _providerFactory;

  /// Replaces the chain provider factory so a test can vary by network.
  @visibleForTesting
  static set debugProviderFactory(WalletProviderFactory factory) {
    _providerFactory = factory;
  }

  /// The provider registry behind provider resolution and
  /// [supportedNetworks].
  @visibleForTesting
  static WalletProviderRegistry get debugRegistry => _registry;

  /// Replaces the registry so a test can register a fake chain family.
  @visibleForTesting
  static set debugRegistry(WalletProviderRegistry registry) {
    _registry = registry;
  }

  /// The publisher receiving committed wallet changes.
  @visibleForTesting
  static WalletChangePublisher get debugPublisher => _publisher;

  /// Replaces how committed wallet changes are delivered.
  @visibleForTesting
  static set debugPublisher(WalletChangePublisher publisher) {
    _publisher = publisher;
  }

  /// Restores the production registry, provider and message bus, and forgets
  /// the in-memory preview rate windows.
  @visibleForTesting
  static void resetForTests() {
    _providerFactory = _registryProvider;
    _registry = WalletProviderRegistry.defaultRegistry;
    _publisher = EntityRealtimeNotifier.notify;
    _previewRateLimiter.reset();
    clock = () => DateTime.now().toUtc();
  }

  /// Creates the wallet and its fixed crypto account in one transaction, then
  /// syncs.
  ///
  /// The address is validated through the core parser before anything is
  /// stored or read, and [scanNetworks] names the networks an EVM wallet
  /// reads; every other family reads its one network. A sync failure keeps
  /// the usable local wallet and account, marks the wallet failed with a
  /// clear error, and never erases committed facts.
  static Future<Wallet> connect(
    Session session,
    UuidValue entityId,
    WalletNetwork network,
    String address, {
    String? label,
    String? accountName,
    List<WalletNetwork>? scanNetworks,
  }) async {
    final normalizedAddress = _requireAddressForNetwork(address, network);
    final cleanScanNetworks = _requireScanNetworks(network, scanNetworks);
    _requireReaderFor(network);
    final cleanLabel = _normaliseOptional(label);
    final cleanAccountName = _normaliseOptional(accountName);

    final connection = await session.db.transaction((tx) async {
      final entity = await EntityAccess.requireOwned(
        session,
        entityId,
        transaction: tx,
        lockMode: LockMode.forNoKeyUpdate,
      );
      _requireWritable(entity);

      // Discover without a lock, then take the account before the wallet. A
      // wallet cascades from its account, so account deletion holds the
      // account row and then waits for the wallet; locking the wallet first
      // would invert that order and deadlock.
      final existing = await Wallet.db.findFirstRow(
        session,
        where: (t) =>
            t.entityId.equals(entityId) &
            t.network.equals(network) &
            t.address.equals(normalizedAddress),
        transaction: tx,
      );
      if (existing != null) {
        final account = await _lockWalletAccount(
          session,
          existing.accountId,
          tx,
        );
        final current = await Wallet.db.findById(
          session,
          existing.id!,
          transaction: tx,
          lockMode: LockMode.forUpdate,
        );
        if (current == null) throw NotFoundException();
        if (current.accountId != account.id) {
          throw StateError('Wallet ${current.id} changed its crypto account.');
        }
        var wallet = current;
        if (cleanLabel != null && cleanLabel != current.label) {
          wallet = await Wallet.db.updateRow(
            session,
            current.copyWith(label: cleanLabel, updatedAt: clock()),
            transaction: tx,
          );
        }
        if (cleanAccountName != null && cleanAccountName != account.name) {
          await Account.db.updateRow(
            session,
            account.copyWith(name: cleanAccountName, updatedAt: clock()),
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
            '${network.displayName} Wallet (${_shortAddress(normalizedAddress)})',
        kind: AccountKind.crypto,
        currencyCode: _valuationCurrency,
        balanceSource: AccountBalanceSource.valuations,
        onBudget: false,
      );
      final now = clock();
      return Wallet.db.insertRow(
        session,
        Wallet(
          entityId: entityId,
          accountId: account.id!,
          network: network,
          address: normalizedAddress,
          scanNetworks: cleanScanNetworks,
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
  static Future<List<Wallet>> list(Session session, UuidValue entityId) async {
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

  /// Fetches the chain, then commits holdings, transactions, the cursors,
  /// the per-network read state and today's wallet valuation in one
  /// transaction.
  ///
  /// Holdings are replaced only for the networks the provider read; a
  /// network that failed keeps its stored quantities and is re-priced from
  /// cache. When no network could be read, every committed fact stands and
  /// the wallet is marked failed.
  static Future<WalletSyncResult> sync(
    Session session,
    UuidValue walletId, {
    bool force = false,
    SystemEntityOwner? systemOwner,
  }) async {
    var wallet = await _ownedWallet(
      session,
      walletId,
      systemOwner: systemOwner,
    );
    _requireWritable(
      await EntityAccess.requireOwned(
        session,
        wallet.entityId,
        systemOwner: systemOwner,
      ),
    );

    // Manual throttle: a sync within 5 minutes of the last one makes no
    // provider call. The timestamp lives on the wallet row, so it is
    // consistent across server instances.
    if (!force) {
      final now = clock();
      if (wallet.lastSyncedAt != null &&
          now.difference(wallet.lastSyncedAt!) < const Duration(minutes: 5)) {
        return _throttledSyncResult(session, wallet);
      }
    }

    var startedAt = clock();
    var attempt = 0;

    while (true) {
      final networks = _readNetworksFor(wallet);
      try {
        // Every network call happens before the transaction opens: the
        // per-network history cursors are read here, outside any
        // transaction, and the provider is resolved before the commit below
        // opens one.
        final states = await WalletNetworkState.db.find(
          session,
          where: (t) => t.walletId.equals(wallet.id),
        );
        final cursors = {
          for (final state in states)
            if (state.historyCursor != null && networks.contains(state.network))
              state.network: state.historyCursor!,
        };
        final provider = _providerFactory(session, wallet.network);
        final snapshot = await provider.fetchSnapshot(
          WalletReadRequest(
            homeNetwork: wallet.network,
            networks: networks,
            address: wallet.address,
            // HD wallets pass the opened descriptor here from W4.2 on.
            untilSignature: wallet.lastSignature,
            // Solana keeps its cursor in the wallet row (multichain-wallets.md
            // 7.3); other families resume from these wallet_network_state
            // cursors once history sync covers them.
            historyCursors: cursors,
          ),
        );
        if (snapshot.readNetworks.isEmpty) {
          // Nothing was readable: the catch below keeps every committed
          // fact and records each network's own reason.
          throw _AllNetworksFailed(
            _combinedFailureMessage(networks, snapshot.failedNetworks),
            snapshot.failedNetworks,
          );
        }
        final outcome = await _commit(
          session,
          wallet,
          snapshot,
          requestNetworks: networks,
          cursorsByNetwork: cursors,
          startedAt: startedAt,
          systemOwner: systemOwner,
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
        wallet = await _ownedWallet(
          session,
          walletId,
          systemOwner: systemOwner,
        );
        startedAt = clock();
      } on _AllNetworksFailed catch (failure, stackTrace) {
        _log.warning('Wallet sync failed for $walletId: $failure', stackTrace);
        await _markFailed(
          session,
          walletId,
          startedAt,
          WalletProviderException(failure.message),
          networks,
          reasonsByNetwork: failure.reasonsByNetwork,
        );
        throw WalletProviderException(failure.message);
      } on Object catch (error, stackTrace) {
        _log.warning('Wallet sync failed for $walletId: $error', stackTrace);
        await _markFailed(session, walletId, startedAt, error, networks);
        rethrow;
      }
    }
  }

  /// Revalues a wallet from its stored quantities and cached prices without
  /// any provider read. Updates today's account valuation only.
  static Future<void> revalue(
    Session session,
    UuidValue walletId, {
    SystemEntityOwner? systemOwner,
  }) async {
    final wallet = await _ownedWallet(
      session,
      walletId,
      systemOwner: systemOwner,
    );
    _requireWritable(
      await EntityAccess.requireOwned(
        session,
        wallet.entityId,
        systemOwner: systemOwner,
      ),
    );

    await session.db.transaction((tx) async {
      final entity = await EntityAccess.requireOwned(
        session,
        wallet.entityId,
        transaction: tx,
        lockMode: LockMode.forNoKeyUpdate,
        systemOwner: systemOwner,
      );
      _requireWritable(entity);

      final account = await _lockWalletAccount(session, wallet.accountId, tx);
      final current = await Wallet.db.findById(
        session,
        wallet.id!,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (current == null) throw NotFoundException();
      if (current.accountId != account.id) {
        throw StateError('Wallet ${current.id} changed its crypto account.');
      }

      final holdings = await WalletHolding.db.find(
        session,
        where: (t) => t.walletId.equals(wallet.id),
        transaction: tx,
      );
      var total = BigInt.zero;
      for (final holding in holdings) {
        if (holding.valueMinor != null) {
          total += BigInt.from(holding.valueMinor!);
        }
      }
      final valuationDate = EntityClock.today(entity, now: clock());
      await AccountValuationService.setInTransaction(
        session,
        tx,
        wallet.accountId,
        valuationDate,
        _safeMinor(total, 'wallet total value'),
        source: ValuationSource.wallet,
        note: 'Wallet revaluation',
      );

      final now = clock();
      await Wallet.db.updateRow(
        session,
        current.copyWith(updatedAt: now),
        transaction: tx,
      );
    });
  }

  /// Returns the last stored sync result when a manual sync is throttled.
  static Future<WalletSyncResult> _throttledSyncResult(
    Session session,
    Wallet wallet,
  ) async {
    final holdings = await WalletHolding.db.find(
      session,
      where: (t) => t.walletId.equals(wallet.id),
    );
    final valuation = await AccountValuation.db.findFirstRow(
      session,
      where: (t) => t.accountId.equals(wallet.accountId),
      orderBy: (t) => t.valuationDate.desc(),
    );
    return WalletSyncResult(
      walletId: wallet.id!,
      insertedTransactions: 0,
      updatedTransactions: 0,
      holdingCount: holdings.length,
      pricedHoldingCount: 0,
      cachedHoldingCount: 0,
      unpricedHoldingCount: 0,
      nftHoldingCount: holdings.where((h) => h.isNft).length,
      pricedNftHoldingCount: 0,
      cachedNftHoldingCount: 0,
      unpricedNftHoldingCount: 0,
      totalValueMinor: valuation?.valueMinor,
      valuationCurrencyCode: _valuationCurrency,
      readNetworks: const [],
      failedNetworks: const [],
      syncedAt: wallet.lastSyncedAt ?? clock(),
      warnings: const ['Sync throttled; returned the last result.'],
    );
  }

  /// Reads what one address holds across its family's supported networks,
  /// without connecting or writing anything.
  ///
  /// Rate limited to 20 reads an hour per user, counting reads only: a
  /// refused input or an unsupported chain never reaches a provider and
  /// consumes none of the hour.
  static Future<WalletPreview> preview(
    Session session,
    UuidValue entityId,
    String address,
  ) async {
    await EntityAccess.requireOwned(session, entityId);
    final (candidate, ambiguous) = _requirePreviewAddress(address);
    final supported = [
      for (final network in candidate.networks)
        if (_registry.isSupported(
          passwords: session.passwords,
          environment: Platform.environment,
          family: network.family,
        ))
          network,
    ];
    if (supported.isEmpty) {
      return WalletPreview(
        network: candidate.networks.first,
        address: candidate.canonical,
        networks: const [],
        warnings: const ['No reader is set up for that chain yet.'],
      );
    }

    if (!_previewRateLimiter.allow(EntityAccess.userId(session))) {
      throw WalletPreviewRateLimitedException();
    }

    final home = supported.first;
    final provider = _providerFactory(session, home);
    final snapshot = await provider.fetchSnapshot(
      WalletReadRequest(
        homeNetwork: home,
        networks: supported,
        address: candidate.canonical,
        // Previews report holdings only; history is a sync concern.
        includeHistory: false,
      ),
    );

    final warnings = [...snapshot.warnings];
    if (ambiguous) {
      warnings.add(
        'That address could belong to more than one chain; '
        'showing the first.',
      );
    }
    final rows = [
      for (final network in supported)
        _previewNetworkRow(network, snapshot, warnings),
    ];
    return WalletPreview(
      network: home,
      address: candidate.canonical,
      networks: rows,
      warnings: warnings,
    );
  }

  /// The networks that can be read now: each one's family has a registered
  /// provider and its secret is present. Test networks are never offered.
  static List<WalletNetwork> supportedNetworks(Session session) {
    final passwords = session.passwords;
    final environment = Platform.environment;
    return [
      for (final network in WalletNetwork.values)
        if (!network.isTestnet &&
            _registry.isSupported(
              passwords: passwords,
              environment: environment,
              family: network.family,
            ))
          network,
    ];
  }

  /// Replaces which networks an EVM wallet reads, or clears them back to its
  /// home network when [networks] is null.
  ///
  /// When the set of networks changes the wallet is read at once, so a
  /// network that was added shows its holdings, and one that was removed
  /// loses its holdings and read state, with the valuation recomputed, before
  /// this answers. A read that fails on every network is already recorded
  /// per network by [sync]; it does not undo the change. Setting the same
  /// networks again reads nothing.
  static Future<Wallet> setScanNetworks(
    Session session,
    UuidValue walletId,
    List<WalletNetwork>? networks,
  ) async {
    final wallet = await _ownedWallet(session, walletId);
    _requireWritable(await EntityAccess.requireOwned(session, wallet.entityId));
    final cleanNetworks = _requireScanNetworks(wallet.network, networks);

    final changed = await session.db.transaction((tx) async {
      await EntityAccess.requireOwned(
        session,
        wallet.entityId,
        transaction: tx,
        lockMode: LockMode.forNoKeyUpdate,
      );
      final current = await Wallet.db.findById(
        session,
        walletId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (current == null) throw NotFoundException();
      final next = current.copyWith(
        // An explicit null clears the list, it does not keep it.
        scanNetworks: cleanNetworks,
        updatedAt: clock(),
      );
      await Wallet.db.updateRow(session, next, transaction: tx);
      return !_sameNetworks(_readNetworksFor(current), _readNetworksFor(next));
    });

    await _publish(
      session,
      wallet.entityId,
      ChangeScope.accounts,
      accountId: wallet.accountId,
    );
    if (changed) {
      try {
        await sync(session, walletId);
      } on WalletProviderException {
        // Every network failed: sync recorded each reason on its state row.
      }
    }
    return await Wallet.db.findById(session, walletId) ?? wallet;
  }

  static bool _sameNetworks(
    List<WalletNetwork> left,
    List<WalletNetwork> right,
  ) =>
      left.toSet().difference(right.toSet()).isEmpty &&
      right.toSet().difference(left.toSet()).isEmpty;

  /// One row per network the wallet reads: when its holdings were last read
  /// and why the last read failed, in display order.
  static Future<List<WalletNetworkState>> listNetworkStates(
    Session session,
    UuidValue walletId,
  ) async {
    await _ownedWallet(session, walletId);
    final states = await WalletNetworkState.db.find(
      session,
      where: (t) => t.walletId.equals(walletId),
    );
    final order = {
      for (final (index, network) in WalletNetwork.values.indexed)
        network: index,
    };
    return states..sort((left, right) {
      final byNetwork = order[left.network]!.compareTo(order[right.network]!);
      if (byNetwork != 0) return byNetwork;
      return left.updatedAt.compareTo(right.updatedAt);
    });
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

  /// Sets a user verdict on one holding.
  ///
  /// [verdict] of [SpamVerdict.hiddenByUser] or [SpamVerdict.allowedByUser]
  /// overrides the classifier; [SpamVerdict.clean] (or null) clears the
  /// override and re-runs the classifier on the holding. [SpamVerdict.suspected]
  /// is stored as given.
  static Future<WalletHolding> setHoldingVerdict(
    Session session,
    UuidValue walletHoldingId,
    SpamVerdict? verdict,
  ) async {
    final discovered = await WalletHolding.db.findById(
      session,
      walletHoldingId,
    );
    if (discovered == null) throw NotFoundException();
    final wallet = await Wallet.db.findById(session, discovered.walletId);
    if (wallet == null) throw NotFoundException();
    final entity = await EntityAccess.requireOwned(session, wallet.entityId);
    _requireWritable(entity);

    SpamVerdict newVerdict;
    if (verdict == null || verdict == SpamVerdict.clean) {
      final siblings = await WalletHolding.db.find(
        session,
        where: (t) => t.walletId.equals(wallet.id),
      );
      final total = siblings.fold<int>(
        0,
        (sum, holding) =>
            holding.valueMinor == null ? sum : sum + holding.valueMinor!,
      );
      newVerdict = WalletSpamClassifier.classify(
        holding: discovered,
        walletTotalValueMinor: total,
      );
    } else {
      newVerdict = verdict;
    }

    final updated = await session.db.transaction((tx) async {
      await EntityAccess.requireOwned(
        session,
        wallet.entityId,
        transaction: tx,
        lockMode: LockMode.forNoKeyUpdate,
      );
      await Wallet.db.findById(
        session,
        wallet.id!,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      final current = await WalletHolding.db.findById(
        session,
        walletHoldingId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (current == null) throw NotFoundException();
      return WalletHolding.db.updateRow(
        session,
        current.copyWith(spamVerdict: newVerdict, updatedAt: clock()),
        transaction: tx,
      );
    });

    await _publish(
      session,
      wallet.entityId,
      ChangeScope.accounts,
      accountId: wallet.accountId,
    );
    return updated;
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
        lockMode: LockMode.forNoKeyUpdate,
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
          updatedAt: clock(),
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
        lockMode: LockMode.forNoKeyUpdate,
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
    required List<WalletNetwork> requestNetworks,
    required Map<WalletNetwork, String> cursorsByNetwork,
    required DateTime startedAt,
    SystemEntityOwner? systemOwner,
  }) async {
    final outcome = await session.db.transaction((tx) async {
      final entity = await EntityAccess.requireOwned(
        session,
        wallet.entityId,
        transaction: tx,
        lockMode: LockMode.forNoKeyUpdate,
        systemOwner: systemOwner,
      );
      _requireWritable(entity);

      // Discover the account without a lock, lock it, then re-read the wallet
      // under its own lock. The account comes first because deleting an
      // account cascades into its wallet; taking the wallet first would let an
      // account delete hold the account while this sync waits for it, and each
      // would wait for the other.
      final discovered = await Wallet.db.findById(
        session,
        wallet.id!,
        transaction: tx,
      );
      if (discovered == null) throw NotFoundException();
      final account = await _lockWalletAccount(
        session,
        discovered.accountId,
        tx,
      );
      final current = await Wallet.db.findById(
        session,
        wallet.id!,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (current == null) throw NotFoundException();
      if (current.accountId != account.id) {
        throw StateError('Wallet ${current.id} changed its crypto account.');
      }

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

      // The commit replaces holdings only for the networks this read read. A
      // network that failed keeps its stored holdings, which are re-priced
      // from cache below, and a network that left the scan set loses its
      // holdings (multichain-wallets.md 8.1 and 8.3).
      final readNetworks = [
        for (final network in requestNetworks)
          if (snapshot.readNetworks.contains(network)) network,
      ];
      final failedReasons = {
        for (final network in requestNetworks)
          if (!readNetworks.contains(network))
            network: _capMessage(
              snapshot.failedNetworks[network] ??
                  '${network.displayName} could not be read.',
            ),
      };
      final failedNetworks = failedReasons.keys.toList();
      // A provider that answers with holdings for a network it did not read
      // is broken; refuse them rather than commit unverifiable quantities.
      for (final holding in snapshot.holdings) {
        if (!readNetworks.contains(holding.network)) {
          throw ValidationException(
            message:
                'Provider returned holdings for a network it did not read.',
          );
        }
      }

      final warnings = [...snapshot.warnings];
      final existingHoldings = await WalletHolding.db.find(
        session,
        where: (t) => t.walletId.equals(wallet.id),
        transaction: tx,
      );
      final existingByKey = {
        for (final holding in existingHoldings)
          (holding.network, holding.assetId, holding.position): holding,
      };
      final existingByFailedNetwork = {
        for (final network in failedNetworks)
          network: [
            for (final holding in existingHoldings)
              if (holding.network == network) holding,
          ],
      };
      // Price cache rows for every asset the sync touches: the read
      // networks' assets and the failed networks' stored assets.
      final assetIdsByNetwork = <WalletNetwork, Set<String>>{};
      for (final holding in snapshot.holdings) {
        assetIdsByNetwork
            .putIfAbsent(holding.network, () => {})
            .add(holding.assetId.trim());
      }
      for (final holdings in existingByFailedNetwork.values) {
        for (final holding in holdings) {
          assetIdsByNetwork
              .putIfAbsent(holding.network, () => {})
              .add(holding.assetId);
        }
      }
      final cacheRows = assetIdsByNetwork.isEmpty
          ? const <AssetPrice>[]
          : await AssetPrice.db.find(
              session,
              where: (t) =>
                  t.network.inSet(assetIdsByNetwork.keys.toSet()) &
                  t.assetId.inSet({
                    for (final assetIds in assetIdsByNetwork.values)
                      ...assetIds,
                  }),
              transaction: tx,
            );
      final cacheByKey = {
        for (final row in cacheRows) (row.network, row.assetId): row,
      };

      final resolved = <_ResolvedHolding>[];
      final seenKeys = <(WalletNetwork, String, HoldingPosition)>{};
      for (final holding in snapshot.holdings) {
        final assetId = holding.assetId.trim();
        if (assetId.isEmpty ||
            !seenKeys.add((holding.network, assetId, holding.position))) {
          throw ValidationException(
            message: 'Provider returned an invalid or duplicate asset id.',
          );
        }
        _requireHoldingQuantity(assetId, holding.quantityRaw, holding.decimals);
        resolved.add(
          _resolveHolding(
            source: holding,
            existing:
                existingByKey[(holding.network, assetId, holding.position)],
            cached: cacheByKey[(holding.network, assetId)],
            warnings: warnings,
          ),
        );
      }
      // A failed network keeps its stored holdings: same quantities, priced
      // again from the cache where a price is still available.
      for (final entry in existingByFailedNetwork.entries) {
        for (final existing in entry.value) {
          if (!seenKeys.add((entry.key, existing.assetId, existing.position))) {
            continue;
          }
          resolved.add(
            _resolveHolding(
              source: _holdingFromRow(existing),
              existing: existing,
              cached: cacheByKey[(entry.key, existing.assetId)],
              warnings: warnings,
            ),
          );
        }
      }

      // Classify every resolved holding. User choices survive; the
      // classifier only moves holdings between clean and suspected.
      final pricedTotalMinor = resolved.fold<BigInt>(
        BigInt.zero,
        (sum, holding) => holding.valueMinor == null
            ? sum
            : sum + BigInt.from(holding.valueMinor!),
      );
      final verdicts =
          <(WalletNetwork, String, HoldingPosition), SpamVerdict>{};
      for (final holding in resolved) {
        final key = (holding.network, holding.assetId, holding.position);
        final existingVerdict = existingByKey[key]?.spamVerdict;
        if (existingVerdict == SpamVerdict.hiddenByUser ||
            existingVerdict == SpamVerdict.allowedByUser) {
          verdicts[key] = existingVerdict!;
        } else {
          verdicts[key] = WalletSpamClassifier.classify(
            network: holding.network,
            assetId: holding.assetId,
            symbol: holding.symbol,
            name: holding.name,
            priceSource: holding.source,
            priceQuality: holding.quality,
            valueMinor: holding.valueMinor,
            walletTotalValueMinor: pricedTotalMinor.toInt(),
          );
        }
      }

      var total = BigInt.zero;
      for (final holding in resolved) {
        final key = (holding.network, holding.assetId, holding.position);
        final verdict = verdicts[key]!;
        if (holding.valueMinor != null &&
            (verdict == SpamVerdict.clean ||
                verdict == SpamVerdict.allowedByUser)) {
          total += BigInt.from(holding.valueMinor!);
        }
      }
      final totalValueMinor = _safeMinor(total, 'wallet total value');

      final persistedHoldings =
          <(WalletNetwork, String, HoldingPosition), WalletHolding>{};
      final transactions = <String, WalletTransaction>{};
      final now = clock();
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
              t.network.equals(wallet.network) &
              t.signature.equals(transaction.signature),
          transaction: tx,
          lockMode: LockMode.forUpdate,
        );
        if (existing == null) {
          final inserted = await WalletTransaction.db.insertRow(
            session,
            WalletTransaction(
              walletId: wallet.id!,
              network: wallet.network,
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
        final key = (holding.network, holding.assetId, holding.position);
        final existing = existingByKey[key];
        if (existing == null) {
          persistedHoldings[key] = await WalletHolding.db.insertRow(
            session,
            WalletHolding(
              walletId: wallet.id!,
              network: holding.network,
              assetId: holding.assetId,
              position: holding.position,
              symbol: holding.symbol,
              name: holding.name,
              tokenProgram: holding.tokenProgram,
              decimals: holding.decimals,
              quantityRaw: holding.quantityRaw,
              isNft: holding.isNft,
              spamVerdict: verdicts[key],
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
          persistedHoldings[key] = await WalletHolding.db.updateRow(
            session,
            existing.copyWith(
              network: holding.network,
              assetId: holding.assetId,
              position: holding.position,
              symbol: holding.symbol,
              name: holding.name,
              tokenProgram: holding.tokenProgram,
              decimals: holding.decimals,
              quantityRaw: holding.quantityRaw,
              isNft: holding.isNft,
              spamVerdict: verdicts[key],
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

      final keepNetworks = {...readNetworks, ...failedNetworks};
      for (final existing in existingHoldings) {
        final key = (existing.network, existing.assetId, existing.position);
        final replaced =
            !keepNetworks.contains(existing.network) ||
            (readNetworks.contains(existing.network) &&
                !seenKeys.contains(key));
        if (replaced) {
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
          // P&L stays scoped to the home network until history lands for the
          // other families (multichain-wallets.md 8.4); ids can repeat
          // across networks.
          for (final holding in resolved)
            if (holding.unitPrice != null && holding.network == wallet.network)
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
        final holding = entry.value;
        final estimate = pnl.holdings[holding.assetId];
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

      await _upsertFreshPrices(session, tx, resolved, warnings, now);

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

      // One state row per network: a read refreshes lastReadAt and clears
      // the error, a failure records the reason and keeps the facts
      // (multichain-wallets.md 8.1).
      final syncedAt = clock();
      for (final network in readNetworks) {
        await WalletNetworkState.db.upsertRow(
          session,
          WalletNetworkState(
            walletId: wallet.id!,
            network: network,
            lastReadAt: syncedAt,
            historyCursor:
                snapshot.historyCursors[network] ?? cursorsByNetwork[network],
            updatedAt: syncedAt,
          ),
          conflictColumns: (t) => [t.walletId, t.network],
          updateColumns: (t) => [
            t.lastReadAt,
            t.lastError,
            t.historyCursor,
            t.updatedAt,
          ],
          transaction: tx,
        );
      }
      for (final network in failedNetworks) {
        await WalletNetworkState.db.upsertRow(
          session,
          WalletNetworkState(
            walletId: wallet.id!,
            network: network,
            lastError: failedReasons[network],
            updatedAt: syncedAt,
          ),
          conflictColumns: (t) => [t.walletId, t.network],
          // Only the error moves: lastReadAt and the history cursor stand
          // with the network's facts.
          updateColumns: (t) => [t.lastError, t.updatedAt],
          transaction: tx,
        );
      }

      // A network that left the scan set takes its read state with its
      // holdings, so it no longer shows as a section or a stale failure.
      await WalletNetworkState.db.deleteWhere(
        session,
        where: (t) =>
            t.walletId.equals(wallet.id) &
            t.network.notInSet(requestNetworks.toSet()),
        transaction: tx,
      );

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
          readNetworks: readNetworks,
          failedNetworks: failedNetworks,
          syncedAt: syncedAt,
          warnings: uniqueWarnings,
        ),
        entityId: wallet.entityId,
        accountId: wallet.accountId,
      );
    });
    return outcome.result;
  }

  /// Resolves one provider holding into a persisted shape: picks the price
  /// (fresh quote first, then the stored or cached price) and computes the
  /// value.
  ///
  /// A holding with no price anywhere stays unpriced; its row keeps any
  /// previous price through the copyWith semantics of the update below.
  static _ResolvedHolding _resolveHolding({
    required WalletProviderHolding source,
    required WalletHolding? existing,
    required AssetPrice? cached,
    required List<String> warnings,
  }) {
    final assetId = source.assetId.trim();
    final choice = _choosePrice(
      source,
      existing: existing,
      cached: cached,
      warnings: warnings,
    );
    int? valueMinor;
    String? unitPrice;
    if (choice != null) {
      final value = _valueFromChoice(
        choice,
        assetId,
        source.quantityRaw,
        source.decimals,
      );
      valueMinor = value.valueMinor;
      unitPrice = value.unitPrice;
      if (valueMinor == null) {
        warnings.add(
          'No supported currency exponent for $assetId; left unpriced.',
        );
      }
    }
    if (choice == null || valueMinor == null) {
      warnings.add('Missing price for asset $assetId');
    }
    return _ResolvedHolding(
      network: source.network,
      assetId: assetId,
      position: source.position,
      symbol: source.symbol,
      name: source.name,
      tokenProgram: source.tokenProgram,
      decimals: source.decimals,
      quantityRaw: source.quantityRaw,
      isNft: source.isNft,
      metadataJson: source.metadataJson,
      unitPrice: valueMinor == null ? null : unitPrice,
      valueMinor: valueMinor,
      currencyCode: valueMinor == null ? null : choice!.currencyCode,
      source: valueMinor == null ? null : choice!.source,
      quality: valueMinor == null ? PriceQuality.unpriced : choice!.quality,
      confidence: valueMinor == null ? null : choice!.confidence,
      asOf: valueMinor == null ? null : choice!.asOf,
      freshCache:
          choice != null &&
          choice.quality != PriceQuality.cached &&
          choice.source != null,
    );
  }

  /// The value of one holding under a price choice, half up, once.
  static ({int? valueMinor, String? unitPrice}) _valueFromChoice(
    _PriceChoice choice,
    String assetId,
    BigInt quantityRaw,
    int decimals,
  ) {
    var unitPrice = choice.unitPrice;
    int? valueMinor;
    try {
      valueMinor = choice.totalPrice == null
          ? WalletMath.valueMinor(
              quantityRaw: quantityRaw,
              decimals: decimals,
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
          quantityRaw: quantityRaw,
          decimals: decimals,
        );
      }
    } on WalletValueException catch (error) {
      throw ValidationException(
        message: 'Wallet value for $assetId is unsafe: ${error.message}',
      );
    }
    return (valueMinor: valueMinor, unitPrice: unitPrice);
  }

  /// A stored holding, re-presented for pricing: same identity and quantity,
  /// no fresh quote, so [_choosePrice] falls back to the stored or cached
  /// price.
  static WalletProviderHolding _holdingFromRow(WalletHolding row) =>
      WalletProviderHolding(
        network: row.network,
        assetId: row.assetId,
        decimals: row.decimals,
        quantityRaw: row.quantityRaw,
        isNft: row.isNft,
        position: row.position,
        symbol: row.symbol,
        name: row.name,
        tokenProgram: row.tokenProgram,
        metadataJson: row.metadataJson,
        prices: const [],
      );

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
        warnings.add('Ignoring invalid provider price for ${holding.assetId}.');
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
    final asOf = existing?.priceAsOf ?? cached?.fetchedAt;
    // A cached price counts for 7 days; older than that the holding is
    // unpriced until a source quotes it again.
    if (asOf == null || clock().difference(asOf) > const Duration(days: 7)) {
      return null;
    }
    warnings.add('Using cached price for asset ${holding.assetId}');
    return _PriceChoice(
      unitPrice: cachedPrice.toString(),
      exactUnitPrice: cachedPrice,
      currencyCode: _valuationCurrency,
      source: existing?.priceSource ?? cached?.source,
      quality: PriceQuality.cached,
      confidence: Confidence.low,
      asOf: asOf,
    );
  }

  static Future<void> _upsertFreshPrices(
    Session session,
    Transaction tx,
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
          network: holding.network,
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

  /// Marks a failed sync on the wallet and every attempted network, keeping
  /// the last committed facts alone.
  ///
  /// The stored message is user-safe by construction: a provider failure
  /// carries its own plain-words message, anything else becomes a fixed
  /// sentence, so no URL, key or address ever reaches the user. The full
  /// error still goes to the log at the call site.
  static Future<void> _markFailed(
    Session session,
    UuidValue walletId,
    DateTime startedAt,
    Object error,
    List<WalletNetwork> attemptedNetworks, {
    Map<WalletNetwork, String> reasonsByNetwork = const {},
  }) async {
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
        final message = _capMessage(_userSafeFailureMessage(error));
        final now = clock();
        await Wallet.db.updateRow(
          session,
          current.copyWith(
            syncStatus: SyncStatus.failed,
            lastSyncError: message,
            updatedAt: now,
          ),
          transaction: tx,
        );
        for (final network in attemptedNetworks) {
          final reason = _capMessage(reasonsByNetwork[network] ?? message);
          await WalletNetworkState.db.upsertRow(
            session,
            WalletNetworkState(
              walletId: current.id!,
              network: network,
              lastError: reason,
              updatedAt: now,
            ),
            conflictColumns: (t) => [t.walletId, t.network],
            updateColumns: (t) => [t.lastError, t.updatedAt],
            transaction: tx,
          );
        }
      });
    } on Object catch (failure) {
      _log.warning('Could not mark wallet $walletId failed: $failure');
    }
  }

  /// Locks the account a wallet values before any wallet row.
  ///
  /// A wallet row cascades from its account, so account deletion locks the
  /// account and then waits for the wallet. Every wallet write that also locks
  /// an account must take the account first, matching the account-before-row
  /// hierarchy the transaction writer uses. The account id is read without a
  /// lock because a wallet never changes it.
  static Future<Account> _lockWalletAccount(
    Session session,
    UuidValue accountId,
    Transaction tx,
  ) async {
    final account = await Account.db.findById(
      session,
      accountId,
      transaction: tx,
      lockMode: LockMode.forUpdate,
    );
    if (account == null) throw NotFoundException();
    return account;
  }

  static Future<Wallet> _ownedWallet(
    Session session,
    UuidValue walletId, {
    SystemEntityOwner? systemOwner,
  }) async {
    final wallet = await Wallet.db.findById(session, walletId);
    if (wallet == null) throw NotFoundException();
    await EntityAccess.requireOwned(
      session,
      wallet.entityId,
      systemOwner: systemOwner,
    );
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

  /// Validates [raw] through the core parser and returns its canonical form.
  ///
  /// The address must parse as [network]'s chain family. A refusal — a
  /// private key, a recovery phrase, a testnet form — and invalid input are
  /// rejected here, before anything is stored or sent to a provider.
  static String _requireAddressForNetwork(String raw, WalletNetwork network) {
    final result = WalletAddressParser.parse(raw);
    switch (result) {
      case WalletAddressRefused(:final refusal):
        throw ValidationException(message: refusal.message);
      case WalletAddressInvalid(:final hint):
        throw ValidationException(message: hint);
      case WalletAddressMatch(:final candidates):
        final forFamily = candidates
            .where((candidate) => candidate.family == network.family)
            .toList();
        if (forFamily.isEmpty) {
          throw ValidationException(
            message: "That address isn't a ${network.displayName} address.",
          );
        }
        if (forFamily.length > 1) {
          throw ValidationException(
            message:
                'That address form is ambiguous for ${network.displayName}; '
                'pick one in the app.',
          );
        }
        return forFamily.single.canonical;
    }
  }

  /// Validates the networks one read covers.
  ///
  /// Only an EVM wallet scans several networks; its home is always
  /// ethereumMainnet, so one address is one wallet, and every scanned
  /// network belongs to the EVM family and includes the home. Every other
  /// family reads its one network and takes no list.
  static List<WalletNetwork>? _requireScanNetworks(
    WalletNetwork network,
    List<WalletNetwork>? scanNetworks,
  ) {
    if (network.family != ChainFamily.evm) {
      if (scanNetworks != null) {
        throw ValidationException(
          message: 'Only an EVM wallet reads more than one network.',
        );
      }
      return null;
    }
    if (network != WalletNetwork.ethereumMainnet) {
      throw ValidationException(
        message:
            'An EVM wallet connects through Ethereum; its other networks '
            'are scan networks.',
      );
    }
    if (scanNetworks == null) return null;
    final seen = <WalletNetwork>{};
    for (final candidate in scanNetworks) {
      if (candidate.family != ChainFamily.evm) {
        throw ValidationException(message: 'A wallet scans EVM networks only.');
      }
      if (!seen.add(candidate)) {
        throw ValidationException(message: 'A wallet scans each network once.');
      }
    }
    if (!seen.contains(network)) {
      throw ValidationException(
        message: 'A wallet always reads its home network.',
      );
    }
    return [...scanNetworks];
  }

  /// The wallet's chain family must have a registered reader before a wallet
  /// row exists. A registered family whose secret is missing still connects
  /// and fails at its first sync with the factory's setup message.
  static void _requireReaderFor(WalletNetwork network) {
    if (_registry.registrationFor(network.family) == null) {
      throw ValidationException(
        message: 'That network has no wallet reader yet',
      );
    }
  }

  /// The networks one read covers: an EVM wallet's scanNetworks, or the
  /// wallet's home network for every other family.
  static List<WalletNetwork> _readNetworksFor(Wallet wallet) {
    final scan = wallet.scanNetworks;
    if (wallet.network.family == ChainFamily.evm &&
        scan != null &&
        scan.isNotEmpty) {
      return [...scan];
    }
    return [wallet.network];
  }

  /// Validates a previewed address and returns its candidate, plus whether
  /// the input was ambiguous across chain families.
  static (WalletAddressCandidate, bool) _requirePreviewAddress(String raw) {
    final result = WalletAddressParser.parse(raw);
    switch (result) {
      case WalletAddressRefused(:final refusal):
        throw ValidationException(message: refusal.message);
      case WalletAddressInvalid(:final hint):
        throw ValidationException(message: hint);
      case WalletAddressMatch(:final candidates):
        return (candidates.first, candidates.length > 1);
    }
  }

  /// One preview row for [network]: what the snapshot carried, or the
  /// plain-words reason it could not be read.
  static WalletPreviewNetwork _previewNetworkRow(
    WalletNetwork network,
    WalletProviderSnapshot snapshot,
    List<String> warnings,
  ) {
    final reason = snapshot.failedNetworks[network];
    if (reason != null) {
      return WalletPreviewNetwork(
        network: network,
        holdingCount: 0,
        pricedHoldingCount: 0,
        readError: _capMessage(reason),
      );
    }
    if (!snapshot.readNetworks.contains(network)) {
      return WalletPreviewNetwork(
        network: network,
        holdingCount: 0,
        pricedHoldingCount: 0,
        readError: '${network.displayName} could not be read.',
      );
    }
    var holdingCount = 0;
    var pricedHoldingCount = 0;
    var total = BigInt.zero;
    for (final holding in snapshot.holdings) {
      if (holding.network != network) continue;
      holdingCount += 1;
      final value = _previewHoldingValue(holding, warnings);
      if (value == null) continue;
      pricedHoldingCount += 1;
      total += BigInt.from(value);
    }
    return WalletPreviewNetwork(
      network: network,
      holdingCount: holdingCount,
      pricedHoldingCount: pricedHoldingCount,
      valueMinor: pricedHoldingCount == 0
          ? null
          : _safeMinor(total, 'preview value'),
      valueCurrencyCode: pricedHoldingCount == 0 ? null : _valuationCurrency,
    );
  }

  /// The first usable USD price of one previewed holding, as minor units.
  static int? _previewHoldingValue(
    WalletProviderHolding holding,
    List<String> warnings,
  ) {
    for (final candidate in holding.prices) {
      if (candidate.currencyCode.toUpperCase() != _valuationCurrency) continue;
      final unit = candidate.unitPrice;
      final total = candidate.totalPrice;
      if ((unit == null && total == null) ||
          (unit != null && unit.numerator <= BigInt.zero) ||
          (total != null && total.numerator <= BigInt.zero)) {
        continue;
      }
      try {
        return total != null
            ? WalletMath.totalValueMinor(
                totalPrice: total,
                currencyCode: _valuationCurrency,
              )
            : WalletMath.valueMinor(
                quantityRaw: holding.quantityRaw,
                decimals: holding.decimals,
                unitPrice: unit!,
                currencyCode: _valuationCurrency,
              );
      } on WalletValueException catch (error) {
        warnings.add(
          'Wallet value for ${holding.assetId} is unsafe: ${error.message}',
        );
        return null;
      }
    }
    return null;
  }

  /// One plain-words line for a read where every network failed, from the
  /// provider's per-network reasons.
  static String _combinedFailureMessage(
    List<WalletNetwork> networks,
    Map<WalletNetwork, String> failedNetworks,
  ) => _capMessage(
    [
      for (final network in networks)
        failedNetworks[network] ?? '${network.displayName} could not be read.',
    ].join(' '),
  );

  /// The message stored on a failed sync. Provider failures carry their own
  /// plain-words message; anything else becomes a fixed sentence, so no URL,
  /// key or address ever reaches the user.
  static String _userSafeFailureMessage(Object error) {
    if (error is WalletProviderException) return error.message;
    return 'The wallet could not be synced. Your saved figures are unchanged.';
  }

  static String _capMessage(String message) =>
      message.length <= 1000 ? message : '${message.substring(0, 997)}...';

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
    final start = DateTime.utc(
      endYear - 1,
      endMonth,
      endDay,
    ).add(const Duration(days: 1));
    return start.year;
  }

  static String _shortAddress(String value) {
    if (value.length <= 10) return value;
    return '${value.substring(0, 4)}...${value.substring(value.length - 4)}';
  }

  /// Resolves the wallet's provider through the registry.
  ///
  /// A family without a registered provider has no reader yet; a registered
  /// family whose secret is missing fails in its factory with its setup
  /// message, as any provider failure does.
  static WalletProvider _registryProvider(
    Session session,
    WalletNetwork network,
  ) {
    final registration = _registry.registrationFor(network.family);
    if (registration == null) {
      throw WalletProviderException(
        'No wallet reader is registered for ${network.name} yet.',
      );
    }
    return registration.factory(session, network);
  }
}

final class _ResolvedHolding {
  const _ResolvedHolding({
    required this.network,
    required this.assetId,
    required this.position,
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

  final WalletNetwork network;
  final String assetId;
  final HoldingPosition position;
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

/// A fixed-window, in-memory limit on wallet previews: 20 per hour per user.
///
/// Each user gets their own window, so one busy client cannot lock out
/// another. The window resets after it opens; a server restart forgets it,
/// matching the MCP rate limiter's trade-off.
final class _PreviewRateLimiter {
  _PreviewRateLimiter({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const _limit = 20;
  static const _window = Duration(hours: 1);

  final DateTime Function() _clock;
  final Map<UuidValue, ({DateTime openedAt, int count})> _windows = {};

  /// Returns true when [userId] may read another preview now.
  bool allow(UuidValue userId) {
    final now = _clock();
    final current = _windows[userId];
    if (current == null || now.difference(current.openedAt) >= _window) {
      _windows[userId] = (openedAt: now, count: 1);
      return true;
    }
    if (current.count >= _limit) return false;
    _windows[userId] = (openedAt: current.openedAt, count: current.count + 1);
    return true;
  }

  /// Forgets every window.
  void reset() => _windows.clear();
}

final class _SyncConflict implements Exception {
  const _SyncConflict();
}

/// A read where the provider answered but no network could be read. It
/// carries each network's own plain-words reason for the network state rows
/// and one combined line for the wallet.
final class _AllNetworksFailed implements Exception {
  const _AllNetworksFailed(this.message, this.reasonsByNetwork);

  final String message;
  final Map<WalletNetwork, String> reasonsByNetwork;

  @override
  String toString() => message;
}
