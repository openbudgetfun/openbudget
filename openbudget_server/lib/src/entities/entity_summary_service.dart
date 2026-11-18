import 'package:meta/meta.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/budget/budget_validation.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/fx_rates/fx_quote_selection.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:serverpod/serverpod.dart';

/// Headline figures for every entity on the home screen, in one call.
///
/// The service reads one repeatable-read snapshot and batches every fact by
/// entity id. The number of statements depends on the number of fact kinds,
/// never on the number of entities: one each for entities, accounts, rates,
/// envelope activity, allocations, uncategorised flows, uncategorised counts,
/// proposals and recurring schedules.
abstract final class EntitySummaryService {
  /// Envelope activity through the requested month, grouped by entity.
  @visibleForTesting
  static const activitySql = '''
SELECT
  t."entityId"::text AS "entityId",
  l."envelopeId"::text AS "envelopeId",
  (EXTRACT(YEAR FROM t."date")::int * 100
    + EXTRACT(MONTH FROM t."date")::int) AS "month",
  SUM(l."baseAmountMinor")::text AS "activity"
FROM "transaction" t
JOIN transaction_line l ON l."transactionId" = t.id
WHERE t."entityId" = ANY(@entityIds::uuid[])
  AND t."date" < @firstDayOfNextMonth::timestamp
  AND l."envelopeId" IS NOT NULL
GROUP BY 1, 2, 3''';

  /// Every allocation of the entities, past and future.
  @visibleForTesting
  static const allocationsSql = '''
SELECT
  "entityId"::text AS "entityId",
  "envelopeId"::text AS "envelopeId",
  "month"::int AS "month",
  "allocatedMinor"::text AS "allocatedMinor"
FROM monthly_allocation
WHERE "entityId" = ANY(@entityIds::uuid[])''';

  /// Money with no envelope on an on-budget account, grouped by entity.
  @visibleForTesting
  static const flowsSql = '''
SELECT
  t."entityId"::text AS "entityId",
  (EXTRACT(YEAR FROM t."date")::int * 100
    + EXTRACT(MONTH FROM t."date")::int) AS "month",
  SUM(CASE WHEN l."baseAmountMinor" > 0
    THEN l."baseAmountMinor" ELSE 0 END)::text AS "inflow",
  SUM(CASE WHEN l."baseAmountMinor" < 0
    THEN l."baseAmountMinor" ELSE 0 END)::text AS "outflow"
FROM "transaction" t
JOIN account a ON a.id = t."accountId" AND a."onBudget"
JOIN transaction_line l
  ON l."transactionId" = t.id AND l."envelopeId" IS NULL
LEFT JOIN transfer tf
  ON t.id IN (tf."fromTransactionId", tf."toTransactionId")
LEFT JOIN "transaction" peer
  ON peer.id = CASE WHEN tf."fromTransactionId" = t.id
    THEN tf."toTransactionId" ELSE tf."fromTransactionId" END
LEFT JOIN account pa ON pa.id = peer."accountId"
WHERE t."entityId" = ANY(@entityIds::uuid[])
  AND t."date" < @firstDayOfNextMonth::timestamp
  AND NOT COALESCE(pa."onBudget" AND peer."entityId" = t."entityId", false)
GROUP BY 1, 2''';

  /// Headers with an uncategorised outflow line on budget, grouped by entity.
  @visibleForTesting
  static const uncategorizedSql = '''
SELECT
  t."entityId"::text AS "entityId",
  (EXTRACT(YEAR FROM t."date")::int * 100
    + EXTRACT(MONTH FROM t."date")::int) AS "month",
  COUNT(DISTINCT t.id)::bigint AS "transactionCount"
FROM "transaction" t
JOIN account a ON a.id = t."accountId" AND a."onBudget"
JOIN transaction_line l
  ON l."transactionId" = t.id
  AND l."envelopeId" IS NULL
  AND l."baseAmountMinor" < 0
LEFT JOIN transfer tf
  ON t.id IN (tf."fromTransactionId", tf."toTransactionId")
LEFT JOIN "transaction" peer
  ON peer.id = CASE WHEN tf."fromTransactionId" = t.id
    THEN tf."toTransactionId" ELSE tf."fromTransactionId" END
LEFT JOIN account pa ON pa.id = peer."accountId"
WHERE t."entityId" = ANY(@entityIds::uuid[])
  AND t."date" < @firstDayOfNextMonth::timestamp
  AND NOT COALESCE(pa."onBudget" AND peer."entityId" = t."entityId", false)
GROUP BY 1, 2''';

  /// Every stored daily rate the entities' balances can use.
  @visibleForTesting
  static const fxRowsSql = '''
SELECT
  "currencyCode",
  "rateDate",
  "rate",
  "fetchedAt"
FROM fx_rate
WHERE "currencyCode" = ANY(@currencyCodes::text[])
  AND "rateDate" > @windowStart::timestamp
  AND "rateDate" <= @toDate::timestamp
ORDER BY "currencyCode", "rateDate" DESC''';

  static int _debugStatementCount = 0;

  /// Counts the statements this service issued since the last reset.
  @visibleForTesting
  static int get debugStatementCount => _debugStatementCount;

  /// The statement labels in the order they ran.
  @visibleForTesting
  static List<String> get debugStatementLabels =>
      List.unmodifiable(_debugStatementLabels);

  /// Resets the statement counter before a measured read.
  @visibleForTesting
  static void resetDebugStatementCount() {
    _debugStatementCount = 0;
    _debugStatementLabels.clear();
  }

  static final List<String> _debugStatementLabels = [];

  /// One summary per active entity owned by the caller.
  ///
  /// A row's month and due-recurring count use the entity's own IANA time
  /// zone. Ready to Assign is null when the entity has no on-budget account.
  /// Net worth is the section 6.5 calculation in the entity's base currency:
  /// a foreign account without a usable rate is left out and sets
  /// `netWorthComplete` false.
  static Future<List<EntitySummaryView>> list(Session session) {
    final userId = EntityAccess.userId(session);
    final now = FxService.utcNow();
    return session.db.transaction(
      (transaction) async {
        _countStatement('entities');
        final entities = await Entity.db.find(
          session,
          where: (table) =>
              table.ownerId.equals(userId) & table.archivedAt.equals(null),
          orderByList: (table) => [table.sortOrder, table.id],
          transaction: transaction,
        );
        if (entities.isEmpty) return const [];

        final entityIds = {for (final entity in entities) entity.id!};
        final monthByEntity = {
          for (final entity in entities)
            entity.id!: MonthKey.fromDate(EntityClock.today(entity, now: now)),
        };
        final todayByEntity = {
          for (final entity in entities)
            entity.id!: EntityClock.today(entity, now: now),
        };
        final cutoffs = [for (final month in monthByEntity.values) month];
        final maxCutoff = cutoffs
            .map(BudgetValidation.firstDayOfNextMonth)
            .reduce((first, second) => first.isAfter(second) ? first : second);

        final accounts = await _loadAccounts(
          session,
          entityIds,
          transaction: transaction,
        );
        final rates = await _loadFxRates(
          session,
          entities,
          accounts,
          todayByEntity: todayByEntity,
          transaction: transaction,
        );
        final perEnvelope = await _loadEnvelopeFacts(
          session,
          entityIds,
          maxCutoff: maxCutoff,
          transaction: transaction,
        );
        final flows = await _loadFlows(
          session,
          entityIds,
          maxCutoff: maxCutoff,
          transaction: transaction,
        );
        final uncategorized = await _loadUncategorized(
          session,
          entityIds,
          maxCutoff: maxCutoff,
          transaction: transaction,
        );
        final pendingProposals = await _loadPendingProposals(
          session,
          entityIds,
          transaction: transaction,
        );
        final dueRecurring = await _loadDueRecurring(
          session,
          entityIds,
          todayByEntity: todayByEntity,
          transaction: transaction,
        );

        final accountsByEntity = <UuidValue, List<Account>>{};
        for (final account in accounts) {
          (accountsByEntity[account.entityId] ??= []).add(account);
        }
        final onBudgetEntities = {
          for (final account in accounts)
            if (account.onBudget) account.entityId,
        };
        final uncategorizedCounts = {
          for (final entity in entities)
            entity.id!:
                uncategorized[entity.id
                    .toString()]?[monthByEntity[entity.id]] ??
                0,
        };

        return [
          for (final entity in entities)
            _summaryFor(
              entity: entity,
              month: monthByEntity[entity.id]!,
              today: todayByEntity[entity.id]!,
              accounts: accountsByEntity[entity.id] ?? const [],
              hasOnBudgetAccount: onBudgetEntities.contains(entity.id),
              rates: rates,
              perEnvelope: perEnvelope[entity.id.toString()] ?? const {},
              flows: flows[entity.id.toString()] ?? const {},
              uncategorizedCount: uncategorizedCounts[entity.id]!,
              pendingProposalCount: pendingProposals[entity.id] ?? 0,
              dueRecurringCount: dueRecurring[entity.id] ?? 0,
              now: now,
            ),
        ];
      },
      settings: const TransactionSettings(
        isolationLevel: IsolationLevel.repeatableRead,
      ),
    );
  }

  static EntitySummaryView _summaryFor({
    required Entity entity,
    required int month,
    required DateTime today,
    required List<Account> accounts,
    required bool hasOnBudgetAccount,
    required List<FxDailyRate> rates,
    required Map<String, Map<int, EnvelopeMonthAmounts>> perEnvelope,
    required Map<int, int> flows,
    required int uncategorizedCount,
    required int pendingProposalCount,
    required int dueRecurringCount,
    required DateTime now,
  }) {
    final folded = foldEnvelopeMonths(
      month: month,
      envelopes: perEnvelope,
      flows: flows,
    );
    final overspentEnvelopeCount = folded.envelopes.values
        .where((balance) => balance.availableMinor < 0)
        .length;
    final netWorth = _netWorth(
      entity: entity,
      accounts: accounts,
      rates: rates,
      today: today,
      now: now,
    );

    return EntitySummaryView(
      entity: entity,
      month: month,
      readyToAssignMinor: hasOnBudgetAccount ? folded.readyToAssignMinor : null,
      overspentEnvelopeCount: overspentEnvelopeCount,
      netWorthMinor: netWorth.netWorthMinor,
      netWorthComplete: netWorth.isComplete,
      uncategorizedCount: uncategorizedCount,
      pendingProposalCount: pendingProposalCount,
      dueRecurringCount: dueRecurringCount,
    );
  }

  static Future<List<Account>> _loadAccounts(
    Session session,
    Set<UuidValue> entityIds, {
    required Transaction transaction,
  }) {
    _countStatement('accounts');
    return Account.db.find(
      session,
      where: (table) => table.entityId.inSet(entityIds),
      orderByList: (table) => [table.entityId, table.sortOrder, table.id],
      transaction: transaction,
    );
  }

  static Future<List<FxDailyRate>> _loadFxRates(
    Session session,
    List<Entity> entities,
    List<Account> accounts, {
    required Map<UuidValue, DateTime> todayByEntity,
    required Transaction transaction,
  }) async {
    final entityById = {for (final entity in entities) entity.id!: entity};
    final needed = <String>{};
    for (final account in accounts) {
      final entity = entityById[account.entityId];
      if (entity == null) continue;
      if (account.currencyCode == entity.baseCurrencyCode) continue;
      needed
        ..add(account.currencyCode)
        ..add(entity.baseCurrencyCode);
    }
    if (needed.isEmpty) return const [];

    final todayValues = todayByEntity.values.toList();
    final earliest = todayValues.reduce(
      (first, second) => first.isBefore(second) ? first : second,
    );
    final latest = todayValues.reduce(
      (first, second) => first.isAfter(second) ? first : second,
    );

    _countStatement('fx');
    final rows = await session.db.unsafeQuery(
      fxRowsSql,
      parameters: QueryParameters.named({
        'currencyCodes': _textArrayLiteral(needed),
        'windowStart': earliest.subtract(const Duration(days: 7)),
        'toDate': latest,
      }),
      transaction: transaction,
    );

    return [
      for (final row in rows)
        FxDailyRate(
          currencyCode: row[0] as String,
          rateDate: row[1] as DateTime,
          rate: row[2] as String,
          fetchedAt: row[3] as DateTime,
        ),
    ];
  }

  static Future<Map<String, Map<String, Map<int, EnvelopeMonthAmounts>>>>
  _loadEnvelopeFacts(
    Session session,
    Set<UuidValue> entityIds, {
    required DateTime maxCutoff,
    required Transaction transaction,
  }) async {
    _countStatement('envelopeActivity');
    final activityRows = await session.db.unsafeQuery(
      activitySql,
      parameters: QueryParameters.named({
        'entityIds': _uuidArrayLiteral(entityIds),
        'firstDayOfNextMonth': maxCutoff,
      }),
      transaction: transaction,
    );
    _countStatement('allocations');
    final allocationRows = await session.db.unsafeQuery(
      allocationsSql,
      parameters: QueryParameters.named({
        'entityIds': _uuidArrayLiteral(entityIds),
      }),
      transaction: transaction,
    );

    final perEnvelope = <String, Map<String, Map<int, EnvelopeMonthAmounts>>>{};
    for (final row in activityRows) {
      final entityId = row[0] as String;
      final envelopeId = row[1] as String;
      final month = _safeMonth(row[2] as int);
      final activity = _parseMinor(row[3], 'Envelope activity');
      final byEnvelope = perEnvelope.putIfAbsent(entityId, () => {});
      final byMonth = byEnvelope.putIfAbsent(envelopeId, () => {});
      final current = byMonth[month] ?? (allocatedMinor: 0, activityMinor: 0);
      byMonth[month] = (
        allocatedMinor: current.allocatedMinor,
        activityMinor: BudgetValidation.checkedSum(
          current.activityMinor,
          activity,
          'Envelope activity for month $month',
        ),
      );
    }

    for (final row in allocationRows) {
      final entityId = row[0] as String;
      final envelopeId = row[1] as String;
      final month = _safeMonth(row[2] as int);
      final allocated = _parseMinor(row[3], 'Monthly allocation');
      final byEnvelope = perEnvelope.putIfAbsent(entityId, () => {});
      final byMonth = byEnvelope.putIfAbsent(envelopeId, () => {});
      final current = byMonth[month] ?? (allocatedMinor: 0, activityMinor: 0);
      byMonth[month] = (
        allocatedMinor: BudgetValidation.checkedSum(
          current.allocatedMinor,
          allocated,
          'Monthly allocation for month $month',
        ),
        activityMinor: current.activityMinor,
      );
    }

    return perEnvelope;
  }

  static Future<Map<String, Map<int, int>>> _loadFlows(
    Session session,
    Set<UuidValue> entityIds, {
    required DateTime maxCutoff,
    required Transaction transaction,
  }) async {
    _countStatement('uncategorisedFlows');
    final rows = await session.db.unsafeQuery(
      flowsSql,
      parameters: QueryParameters.named({
        'entityIds': _uuidArrayLiteral(entityIds),
        'firstDayOfNextMonth': maxCutoff,
      }),
      transaction: transaction,
    );

    final flows = <String, Map<int, int>>{};
    for (final row in rows) {
      final entityId = row[0] as String;
      final month = _safeMonth(row[1] as int);
      final inflow = _parseMinor(row[2], 'Uncategorised inflow');
      final outflow = _parseMinor(row[3], 'Uncategorised outflow');
      final net = BudgetValidation.checkedSum(
        inflow,
        outflow,
        'Uncategorised flow',
      );
      final byMonth = flows.putIfAbsent(entityId, () => {});
      byMonth[month] = BudgetValidation.checkedSum(
        byMonth[month] ?? 0,
        net,
        'Uncategorised flow for month $month',
      );
    }
    return flows;
  }

  static Future<Map<String, Map<int, int>>> _loadUncategorized(
    Session session,
    Set<UuidValue> entityIds, {
    required DateTime maxCutoff,
    required Transaction transaction,
  }) async {
    _countStatement('uncategorisedCount');
    final rows = await session.db.unsafeQuery(
      uncategorizedSql,
      parameters: QueryParameters.named({
        'entityIds': _uuidArrayLiteral(entityIds),
        'firstDayOfNextMonth': maxCutoff,
      }),
      transaction: transaction,
    );

    final counts = <String, Map<int, int>>{};
    for (final row in rows) {
      final entityId = row[0] as String;
      final month = _safeMonth(row[1] as int);
      final count = row[2] as int;
      (counts[entityId] ??= {})[month] = count;
    }
    return counts;
  }

  static Future<Map<UuidValue, int>> _loadPendingProposals(
    Session session,
    Set<UuidValue> entityIds, {
    required Transaction transaction,
  }) async {
    _countStatement('proposals');
    final rows = await AgentProposal.db.find(
      session,
      where: (table) =>
          table.entityId.inSet(entityIds) &
          table.status.equals(AgentProposalStatus.pending),
      transaction: transaction,
    );
    final counts = <UuidValue, int>{};
    for (final row in rows) {
      counts[row.entityId] = (counts[row.entityId] ?? 0) + 1;
    }
    return counts;
  }

  static Future<Map<UuidValue, int>> _loadDueRecurring(
    Session session,
    Set<UuidValue> entityIds, {
    required Map<UuidValue, DateTime> todayByEntity,
    required Transaction transaction,
  }) async {
    _countStatement('recurring');
    final rows = await RecurringTransaction.db.find(
      session,
      where: (table) => table.entityId.inSet(entityIds),
      transaction: transaction,
    );
    final counts = <UuidValue, int>{};
    for (final row in rows) {
      if (!row.isActive) continue;
      final today = todayByEntity[row.entityId];
      if (today == null || row.nextDate.isAfter(today)) continue;
      final endDate = row.endDate;
      if (endDate != null && row.nextDate.isAfter(endDate)) continue;
      counts[row.entityId] = (counts[row.entityId] ?? 0) + 1;
    }
    return counts;
  }

  static _NetWorth _netWorth({
    required Entity entity,
    required List<Account> accounts,
    required List<FxDailyRate> rates,
    required DateTime today,
    required DateTime now,
  }) {
    var netWorthMinor = 0;
    var isComplete = true;
    for (final account in accounts) {
      if (account.balanceMinor == 0) continue;

      final quote = FxQuoteSelection.select(
        fromCurrencyCode: account.currencyCode,
        toCurrencyCode: entity.baseCurrencyCode,
        date: today,
        rates: rates,
        now: now,
      );
      if (quote == null) {
        isComplete = false;
        continue;
      }

      final converted = _convert(
        amountMinor: account.balanceMinor,
        quote: quote,
        accountCurrencyCode: account.currencyCode,
        baseCurrencyCode: entity.baseCurrencyCode,
      );
      netWorthMinor = BudgetValidation.checkedSum(
        netWorthMinor,
        converted,
        'Entity net worth',
      );
    }

    return _NetWorth(netWorthMinor: netWorthMinor, isComplete: isComplete);
  }

  static int _convert({
    required int amountMinor,
    required FxQuoteSelection quote,
    required String accountCurrencyCode,
    required String baseCurrencyCode,
  }) {
    try {
      return convertMinorUnits(
        amountMinor: amountMinor,
        exchangeRate: quote.rate,
        transactionExponent: _exponentFor(accountCurrencyCode),
        functionalExponent: _exponentFor(baseCurrencyCode),
      );
      // The conversion boundary checks the range and throws RangeError; this
      // boundary is the one place that turns it into a validation failure.
      // ignore: avoid_catching_errors
    } on RangeError {
      throw ValidationException(
        message: 'Converted account balance exceeds the safe minor-unit range',
      );
    }
  }

  static int _exponentFor(String currencyCode) {
    final exponent = exponentForCurrency(currencyCode);
    if (exponent == null) {
      throw ValidationException(message: 'Unsupported currency: $currencyCode');
    }
    return exponent;
  }

  static int _safeMonth(int month) => BudgetValidation.checkedMonth(month);

  static int _parseMinor(Object? value, String context) {
    final BigInt parsed;
    if (value is int) {
      parsed = BigInt.from(value);
    } else if (value is String) {
      final text = BigInt.tryParse(value);
      if (text == null) {
        throw StateError('$context is not an integer: "$value"');
      }
      parsed = text;
    } else if (value is BigInt) {
      parsed = value;
    } else {
      throw StateError('$context has an unexpected type: $value');
    }

    if (parsed.abs() > BigInt.from(maxSafeMinor)) {
      throw ValidationException(
        message: '$context exceeds the safe minor-unit range',
      );
    }
    return parsed.toInt();
  }

  static String _uuidArrayLiteral(Iterable<UuidValue> ids) =>
      '{${ids.map((id) => id.uuid).join(',')}}';

  static String _textArrayLiteral(Iterable<String> values) =>
      '{${values.join(',')}}';

  static void _countStatement(String label) {
    _debugStatementCount += 1;
    _debugStatementLabels.add(label);
  }
}

class _NetWorth {
  const _NetWorth({required this.netWorthMinor, required this.isComplete});

  final int netWorthMinor;
  final bool isComplete;
}
