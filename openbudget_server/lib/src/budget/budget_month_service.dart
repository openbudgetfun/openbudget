import 'package:meta/meta.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/budget/budget_validation.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:serverpod/serverpod.dart';

/// Derives the whole Plan screen for one month from three sparse aggregates.
///
/// The read path never loads transactions or per-envelope history. One
/// repeatable-read transaction supplies a single snapshot, so a concurrent
/// write cannot make the returned summary disagree with its envelope rows.
/// A plan write commits first and then calls [month], so a write response is
/// the latest coherent snapshot rather than three aggregates read inside the
/// write transaction.
///
/// Every amount in the result is in the entity's base-currency minor units.
abstract final class BudgetMonthService {
  /// Envelope activity through the requested month, grouped by month.
  ///
  /// Served by `transaction_entity_date_idx` with the line envelope index.
  @visibleForTesting
  static const envelopeActivitySql = '''
SELECT
  l."envelopeId"::text AS "envelopeId",
  (EXTRACT(YEAR FROM t."date")::int * 100
    + EXTRACT(MONTH FROM t."date")::int) AS "month",
  SUM(l."baseAmountMinor")::text AS "activity"
FROM "transaction" t
JOIN transaction_line l ON l."transactionId" = t.id
WHERE t."entityId" = @entityId::uuid
  AND t."date" < @firstDayOfNextMonth::timestamp
  AND l."envelopeId" IS NOT NULL
GROUP BY 1, 2''';

  /// Every allocation of the entity, past and future.
  ///
  /// Served by `monthly_allocation_entity_month_idx`; the table is sparse.
  @visibleForTesting
  static const allocationsSql = '''
SELECT
  "envelopeId"::text AS "envelopeId",
  "month"::int AS "month",
  "allocatedMinor"::text AS "allocatedMinor"
FROM monthly_allocation
WHERE "entityId" = @entityId::uuid''';

  /// Money with no envelope on an on-budget account, by month and kind.
  ///
  /// Internal transfers, where both legs are on budget in the same entity,
  /// are excluded. Cross-entity and off-budget legs stay in the plan.
  @visibleForTesting
  static const uncategorisedFlowSql = '''
SELECT
  (EXTRACT(YEAR FROM t."date")::int * 100
    + EXTRACT(MONTH FROM t."date")::int) AS "month",
  t.kind AS "kind",
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
WHERE t."entityId" = @entityId::uuid
  AND t."date" < @firstDayOfNextMonth::timestamp
  AND NOT COALESCE(pa."onBudget" AND peer."entityId" = t."entityId", false)
GROUP BY 1, 2''';

  static int _debugStatementCount = 0;
  static final List<String> _debugStatementLabels = [];

  /// Counts the real statements this service issued since the last reset.
  ///
  /// Tests use it with `EXPLAIN` to prove the read stays bounded and indexed.
  @visibleForTesting
  static int get debugStatementCount => _debugStatementCount;

  /// The labels of the statements counted by [debugStatementCount].
  @visibleForTesting
  static List<String> get debugStatementLabels =>
      List.unmodifiable(_debugStatementLabels);

  /// Resets the statement counter before a measured read.
  @visibleForTesting
  static void resetDebugStatementCount() {
    _debugStatementCount = 0;
    _debugStatementLabels.clear();
  }

  /// Runs after the activity aggregate and before the other two.
  ///
  /// A concurrency test uses it to commit a competing write while the read is
  /// open and then proves the returned view still comes from one snapshot.
  @visibleForTesting
  static Future<void> Function()? debugAfterActivityQuery;

  /// Reads one month of the envelope plan for an owned entity.
  static Future<BudgetMonthView> month(
    Session session, {
    required UuidValue entityId,
    required int month,
  }) async {
    BudgetValidation.requireMonth(month);
    return session.db.transaction(
      (transaction) async {
        _countStatement('entity');
        final entity = await EntityAccess.requireOwned(
          session,
          entityId,
          transaction: transaction,
        );
        return _build(session, transaction, entity, month);
      },
      settings: const TransactionSettings(
        isolationLevel: IsolationLevel.repeatableRead,
      ),
    );
  }

  /// Reads the summary of every month from [fromMonth] to [toMonth].
  ///
  /// The three section 6.4 aggregates run once up to [toMonth] and one walk
  /// derives every month in the range, so a whole report costs the same
  /// queries as a single month.
  static Future<List<BudgetMonthSummary>> summaries(
    Session session, {
    required UuidValue entityId,
    required int fromMonth,
    required int toMonth,
  }) async {
    BudgetValidation.requireMonth(fromMonth);
    BudgetValidation.requireMonth(toMonth);
    if (toMonth < fromMonth) {
      throw ValidationException(
        message: 'toMonth must be on or after fromMonth',
      );
    }

    return session.db.transaction(
      (transaction) async {
        _countStatement('entity');
        final entity = await EntityAccess.requireOwned(
          session,
          entityId,
          transaction: transaction,
        );
        final facts = await _loadFacts(
          session,
          transaction,
          _requireId(entity),
          throughMonth: toMonth,
        );
        final folded = foldEnvelopeMonthRange(
          fromMonth: fromMonth,
          toMonth: toMonth,
          envelopes: facts.perEnvelope,
          flows: facts.flows,
        );

        return [
          for (final entry in folded.months.entries)
            BudgetMonthSummary(
              month: entry.key,
              incomeMinor: facts.income[entry.key] ?? 0,
              uncategorizedMinor: facts.uncategorised[entry.key] ?? 0,
              fxDifferenceMinor: facts.fxDifference[entry.key] ?? 0,
              allocatedMinor: entry.value.allocatedMinor,
              activityMinor: entry.value.activityMinor,
              overspentLastMonthMinor: entry.value.overspentLastMonthMinor,
              assignedInFutureMinor: entry.value.assignedInFutureMinor,
              readyToAssignMinor: entry.value.readyToAssignMinor,
              availableMinor: entry.value.availableMinor,
            ),
        ];
      },
      settings: const TransactionSettings(
        isolationLevel: IsolationLevel.repeatableRead,
      ),
    );
  }

  static Future<BudgetMonthView> _build(
    Session session,
    Transaction transaction,
    Entity entity,
    int month,
  ) async {
    final facts = await _loadFacts(
      session,
      transaction,
      entity.id!,
      throughMonth: month,
    );
    final categories = await _categories(session, entity, transaction);
    final envelopes = await _envelopes(session, entity, transaction);
    final goals = await _goals(session, envelopes, transaction);

    final perEnvelope = <String, Map<int, EnvelopeMonthAmounts>>{};
    for (final envelope in envelopes) {
      final id = _requireId(envelope).toString();
      perEnvelope[id] = facts.perEnvelope[id] ?? <int, EnvelopeMonthAmounts>{};
    }
    for (final entry in facts.perEnvelope.entries) {
      perEnvelope.putIfAbsent(entry.key, () => entry.value);
    }

    final folded = foldEnvelopeMonths(
      month: month,
      envelopes: perEnvelope,
      flows: facts.flows,
    );

    final categoryOrder = <UuidValue, int>{
      for (var index = 0; index < categories.length; index++)
        _requireId(categories[index]): index,
    };
    final orderedEnvelopes = [...envelopes]
      ..sort((first, second) {
        final firstCategory =
            categoryOrder[first.categoryId] ?? categoryOrder.length;
        final secondCategory =
            categoryOrder[second.categoryId] ?? categoryOrder.length;
        final byCategory = firstCategory.compareTo(secondCategory);
        if (byCategory != 0) return byCategory;
        final bySort = first.sortOrder.compareTo(second.sortOrder);
        if (bySort != 0) return bySort;
        return _requireId(first).uuid.compareTo(_requireId(second).uuid);
      });

    final envelopeViews = <EnvelopeMonthView>[];
    var allocatedThisMonth = 0;
    var activityThisMonth = 0;
    var available = 0;
    for (final envelope in orderedEnvelopes) {
      final id = _requireId(envelope);
      final balance =
          folded.envelopes[id.toString()] ??
          (
            carryoverMinor: 0,
            allocatedMinor: 0,
            activityMinor: 0,
            availableMinor: 0,
          );
      allocatedThisMonth = BudgetValidation.checkedSum(
        allocatedThisMonth,
        balance.allocatedMinor,
        'Allocated this month',
      );
      activityThisMonth = BudgetValidation.checkedSum(
        activityThisMonth,
        balance.activityMinor,
        'Activity this month',
      );
      available = BudgetValidation.checkedSum(
        available,
        balance.availableMinor,
        'Available this month',
      );
      final goal = goals[id];
      envelopeViews.add(
        EnvelopeMonthView(
          envelope: envelope,
          goal: goal,
          carryoverMinor: balance.carryoverMinor,
          allocatedMinor: balance.allocatedMinor,
          activityMinor: balance.activityMinor,
          availableMinor: balance.availableMinor,
          goalUnderfundedMinor: goal == null
              ? 0
              : _safeMinor(
                  underfundedMinor(
                    (
                      kind: goal.kind.name,
                      amountMinor: goal.amountMinor,
                      targetDate: goal.targetDate,
                    ),
                    month,
                    balance.carryoverMinor,
                    balance.allocatedMinor,
                    balance.activityMinor,
                  ),
                  'Goal underfunded amount',
                ),
        ),
      );
    }

    // Activity or allocation rows can only reference existing envelopes under
    // the foreign keys, but include any stray key in the totals so the
    // zero-sum invariant can never hide money.
    final displayedIds = {
      for (final envelope in orderedEnvelopes) _requireId(envelope),
    };
    for (final entry in perEnvelope.entries) {
      if (displayedIds.contains(UuidValue.fromString(entry.key))) continue;
      final balance =
          folded.envelopes[entry.key] ??
          (
            carryoverMinor: 0,
            allocatedMinor: 0,
            activityMinor: 0,
            availableMinor: 0,
          );
      allocatedThisMonth = BudgetValidation.checkedSum(
        allocatedThisMonth,
        balance.allocatedMinor,
        'Allocated this month',
      );
      activityThisMonth = BudgetValidation.checkedSum(
        activityThisMonth,
        balance.activityMinor,
        'Activity this month',
      );
      available = BudgetValidation.checkedSum(
        available,
        balance.availableMinor,
        'Available this month',
      );
    }

    return BudgetMonthView(
      entityId: _requireId(entity),
      month: month,
      currencyCode: entity.baseCurrencyCode,
      summary: BudgetMonthSummary(
        month: month,
        incomeMinor: facts.income[month] ?? 0,
        uncategorizedMinor: facts.uncategorised[month] ?? 0,
        fxDifferenceMinor: facts.fxDifference[month] ?? 0,
        allocatedMinor: allocatedThisMonth,
        activityMinor: activityThisMonth,
        overspentLastMonthMinor: folded.overspentLastMonthMinor,
        assignedInFutureMinor: folded.assignedInFutureMinor,
        readyToAssignMinor: folded.readyToAssignMinor,
        availableMinor: available,
      ),
      categories: categories,
      envelopes: envelopeViews,
    );
  }

  /// Loads and folds the three sparse section 6.4 aggregates once.
  static Future<_MonthFacts> _loadFacts(
    Session session,
    Transaction transaction,
    UuidValue entityId, {
    required int throughMonth,
  }) async {
    final entityParameters = QueryParameters.named({
      'entityId': entityId.toString(),
    });
    final windowParameters = QueryParameters.named({
      'entityId': entityId.toString(),
      'firstDayOfNextMonth': BudgetValidation.firstDayOfNextMonth(throughMonth),
    });

    _countStatement('envelopeActivity');
    final activityRows = await session.db.unsafeQuery(
      envelopeActivitySql,
      parameters: windowParameters,
      transaction: transaction,
    );
    final snapshotHook = debugAfterActivityQuery;
    if (snapshotHook != null) await snapshotHook();

    _countStatement('allocations');
    final allocationRows = await session.db.unsafeQuery(
      allocationsSql,
      parameters: entityParameters,
      transaction: transaction,
    );

    _countStatement('uncategorisedFlows');
    final flowRows = await session.db.unsafeQuery(
      uncategorisedFlowSql,
      parameters: windowParameters,
      transaction: transaction,
    );

    final perEnvelope = <String, Map<int, EnvelopeMonthAmounts>>{};
    for (final row in activityRows) {
      final envelopeId = row[0] as String;
      final month = _safeMonth(row[1] as int);
      final activity = _safeMinor(row[2], 'Envelope activity');
      final byMonth = perEnvelope.putIfAbsent(
        envelopeId,
        () => <int, EnvelopeMonthAmounts>{},
      );
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
      final envelopeId = row[0] as String;
      final month = _safeMonth(row[1] as int);
      final allocated = _safeMinor(row[2], 'Monthly allocation');
      final byMonth = perEnvelope.putIfAbsent(
        envelopeId,
        () => <int, EnvelopeMonthAmounts>{},
      );
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

    final flows = <int, int>{};
    final income = <int, int>{};
    final uncategorised = <int, int>{};
    final fxDifference = <int, int>{};
    for (final row in flowRows) {
      final month = _safeMonth(row[0] as int);
      final kind = row[1] as String;
      final inflow = _safeMinor(row[2], 'Uncategorised inflow');
      final outflow = _safeMinor(row[3], 'Uncategorised outflow');
      final net = BudgetValidation.checkedSum(
        inflow,
        outflow,
        'Uncategorised flow',
      );
      flows[month] = BudgetValidation.checkedSum(
        flows[month] ?? 0,
        net,
        'Uncategorised flow for month $month',
      );

      if (kind == TransactionKind.fxRevaluation.name) {
        fxDifference[month] = BudgetValidation.checkedSum(
          fxDifference[month] ?? 0,
          net,
          'FX difference for month $month',
        );
      } else {
        income[month] = BudgetValidation.checkedSum(
          income[month] ?? 0,
          inflow,
          'Income for month $month',
        );
        uncategorised[month] = BudgetValidation.checkedSum(
          uncategorised[month] ?? 0,
          outflow,
          'Uncategorised outflow for month $month',
        );
      }
    }

    return _MonthFacts(
      perEnvelope: perEnvelope,
      flows: flows,
      income: income,
      uncategorised: uncategorised,
      fxDifference: fxDifference,
    );
  }

  static Future<List<Category>> _categories(
    Session session,
    Entity entity,
    Transaction transaction,
  ) {
    _countStatement('categories');
    return Category.db.find(
      session,
      where: (t) => t.entityId.equals(entity.id),
      orderByList: (t) => [t.sortOrder, t.id],
      transaction: transaction,
    );
  }

  static Future<List<Envelope>> _envelopes(
    Session session,
    Entity entity,
    Transaction transaction,
  ) {
    _countStatement('envelopes');
    return Envelope.db.find(
      session,
      where: (t) => t.entityId.equals(entity.id),
      orderByList: (t) => [t.sortOrder, t.id],
      transaction: transaction,
    );
  }

  static Future<Map<UuidValue, EnvelopeGoal>> _goals(
    Session session,
    List<Envelope> envelopes,
    Transaction transaction,
  ) async {
    if (envelopes.isEmpty) return const {};

    final ids = {for (final envelope in envelopes) _requireId(envelope)};
    _countStatement('goals');
    final goals = await EnvelopeGoal.db.find(
      session,
      where: (t) => t.envelopeId.inSet(ids),
      orderByList: (t) => [t.envelopeId],
      transaction: transaction,
    );
    return {
      for (final goal in goals)
        if (goal.entityId == envelopes.first.entityId) goal.envelopeId: goal,
    };
  }

  static void _countStatement(String label) {
    _debugStatementCount++;
    _debugStatementLabels.add(label);
  }

  static int _safeMonth(int month) => BudgetValidation.checkedMonth(month);

  static int _safeMinor(Object? value, String context) {
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

  static UuidValue _requireId(Object row) {
    final id = switch (row) {
      Entity(:final id) => id,
      Category(:final id) => id,
      Envelope(:final id) => id,
      _ => throw StateError('Row has no id: $row'),
    };
    if (id == null) throw StateError('A persisted row has no id');
    return id;
  }
}

/// The parsed section 6.4 aggregates for one entity.
class _MonthFacts {
  const _MonthFacts({
    required this.perEnvelope,
    required this.flows,
    required this.income,
    required this.uncategorised,
    required this.fxDifference,
  });

  final Map<String, Map<int, EnvelopeMonthAmounts>> perEnvelope;
  final Map<int, int> flows;
  final Map<int, int> income;
  final Map<int, int> uncategorised;
  final Map<int, int> fxDifference;
}
