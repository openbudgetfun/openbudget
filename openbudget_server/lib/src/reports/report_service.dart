import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/budget/budget_month_service.dart';
import 'package:openbudget_server/src/budget/budget_validation.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:serverpod/serverpod.dart';

/// Spending, month summaries and age of money for one owned entity.
///
/// Every read is scoped by [EntityAccess] and every amount is a base-currency
/// minor unit. Lines flow through the same internal-transfer predicate as the
/// plan: a transfer with both legs on budget in one entity is excluded, while
/// cross-entity and off-budget legs stay in reports.
abstract final class ReportService {
  /// The exact aggregate behind [spending].
  ///
  /// The grouping expression is one of the fixed strings [spending] chooses,
  /// never caller input. The two sums use negative and positive base amounts
  /// separately so a refund stays in the same group as the spending it offsets.
  @visibleForTesting
  static const spendingSqlTemplate = '''
SELECT
  __GROUP__ AS "groupId",
  __MONTH__ AS "month",
  SUM(CASE WHEN l."baseAmountMinor" < 0
    THEN l."baseAmountMinor" ELSE 0 END)::text AS "outflow",
  SUM(CASE WHEN l."baseAmountMinor" > 0
    THEN l."baseAmountMinor" ELSE 0 END)::text AS "inflow",
  COUNT(DISTINCT t.id)::bigint AS "transactionCount"
FROM "transaction" t
JOIN account a ON a.id = t."accountId" AND a."onBudget"
JOIN transaction_line l ON l."transactionId" = t.id
__GROUP_JOIN__
LEFT JOIN transfer tf
  ON t.id IN (tf."fromTransactionId", tf."toTransactionId")
LEFT JOIN "transaction" peer
  ON peer.id = CASE WHEN tf."fromTransactionId" = t.id
    THEN tf."toTransactionId" ELSE tf."fromTransactionId" END
LEFT JOIN account pa ON pa.id = peer."accountId"
WHERE t."entityId" = @entityId::uuid
  AND t."date" >= @fromDate::timestamp
  AND t."date" < @toDate::timestamp
  AND NOT COALESCE(pa."onBudget" AND peer."entityId" = t."entityId", false)
GROUP BY __GROUP_BY__''';

  /// Every inflow and outflow line in the age-of-money window.
  @visibleForTesting
  static const ageOfMoneySql = '''
SELECT
  t."date",
  l."baseAmountMinor"::text AS "amount"
FROM "transaction" t
JOIN account a ON a.id = t."accountId" AND a."onBudget"
JOIN transaction_line l ON l."transactionId" = t.id
LEFT JOIN transfer tf
  ON t.id IN (tf."fromTransactionId", tf."toTransactionId")
LEFT JOIN "transaction" peer
  ON peer.id = CASE WHEN tf."fromTransactionId" = t.id
    THEN tf."toTransactionId" ELSE tf."fromTransactionId" END
LEFT JOIN account pa ON pa.id = peer."accountId"
WHERE t."entityId" = @entityId::uuid
  AND t."date" >= @fromDate::timestamp
  AND t."date" <= @toDate::timestamp
  AND NOT COALESCE(pa."onBudget" AND peer."entityId" = t."entityId", false)
  AND (
    (l."envelopeId" IS NULL AND l."baseAmountMinor" > 0)
    OR (l."envelopeId" IS NOT NULL AND l."baseAmountMinor" < 0)
  )
ORDER BY t."date", t.id, l."sortOrder", l.id''';

  static int _debugStatementCount = 0;
  static final List<String> _debugStatementLabels = [];

  /// Counts the statements this service issued since the last reset.
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

  /// One group's spending and income over a month range.
  ///
  /// Rows come from on-budget lines only, in base minor units, with internal
  /// transfers excluded. `byMonth` adds the month to the grouping and returns
  /// one row per group and month. Rows are ordered by month, then by outflow
  /// (largest spending first), then by name, so repeated reads are stable.
  static Future<List<SpendingRow>> spending(
    Session session,
    UuidValue entityId,
    int fromMonth,
    int toMonth,
    ReportGrouping grouping,
    // The public contract keeps `byMonth` positional.
    // ignore: avoid_positional_boolean_parameters
    bool byMonth,
  ) async {
    BudgetValidation.requireMonth(fromMonth);
    BudgetValidation.requireMonth(toMonth);
    if (toMonth < fromMonth) {
      throw ValidationException(
        message: 'toMonth must be on or after fromMonth',
      );
    }

    final groupingSelect = switch (grouping) {
      ReportGrouping.envelope => 'l."envelopeId"::text',
      ReportGrouping.category => 'e."categoryId"::text',
      ReportGrouping.payee => 't."payeeId"::text',
    };
    final groupJoin = grouping == ReportGrouping.category
        ? 'LEFT JOIN envelope e ON e.id = l."envelopeId"'
        : '';
    final monthSelect = byMonth
        ? '(EXTRACT(YEAR FROM t."date")::int * 100 '
              '+ EXTRACT(MONTH FROM t."date")::int)::int'
        : 'NULL::int';
    final sql = spendingSqlTemplate
        .replaceAll('__GROUP__', groupingSelect)
        .replaceAll('__MONTH__', monthSelect)
        .replaceAll('__GROUP_JOIN__', groupJoin)
        .replaceAll('__GROUP_BY__', byMonth ? '1, 2' : '1');
    final fallbackName = switch (grouping) {
      ReportGrouping.envelope => 'No envelope',
      ReportGrouping.category => 'No category',
      ReportGrouping.payee => 'No payee',
    };

    return session.db.transaction(
      (transaction) async {
        _countStatement('entity');
        final entity = await EntityAccess.requireOwned(
          session,
          entityId,
          transaction: transaction,
        );

        _countStatement('spending');
        final rows = await session.db.unsafeQuery(
          sql,
          parameters: QueryParameters.named({
            'entityId': entityId.toString(),
            'fromDate': DateTime.utc(fromMonth ~/ 100, fromMonth % 100),
            'toDate': BudgetValidation.firstDayOfNextMonth(toMonth),
          }),
          transaction: transaction,
        );

        final names = await _groupNames(
          session,
          entity.id!,
          grouping,
          transaction: transaction,
        );

        return <SpendingRow>[
          for (final row in rows)
            SpendingRow(
              groupId: row[0] == null
                  ? null
                  : UuidValue.fromString(row[0] as String),
              name: _groupName(row[0], names, fallbackName),
              month: row[1] as int?,
              outflowMinor: _parseMinor(row[2], 'Spending outflow'),
              inflowMinor: _parseMinor(row[3], 'Spending inflow'),
              transactionCount: row[4] as int,
            ),
        ]..sort((first, second) {
          final byMonth = (first.month ?? 0).compareTo(second.month ?? 0);
          if (byMonth != 0) return byMonth;
          final byOutflow = first.outflowMinor.compareTo(second.outflowMinor);
          if (byOutflow != 0) return byOutflow;
          final byName = first.name.compareTo(second.name);
          if (byName != 0) return byName;
          return (first.groupId?.uuid ?? '').compareTo(
            second.groupId?.uuid ?? '',
          );
        });
      },
      settings: const TransactionSettings(
        isolationLevel: IsolationLevel.repeatableRead,
      ),
    );
  }

  /// Every month from [fromMonth] to [toMonth] from one section 6.4 fold.
  static Future<List<BudgetMonthSummary>> monthSummaries(
    Session session,
    UuidValue entityId,
    int fromMonth,
    int toMonth,
  ) => BudgetMonthService.summaries(
    session,
    entityId: entityId,
    fromMonth: fromMonth,
    toMonth: toMonth,
  );

  /// The mean age in days of the last ten outflows' money, or null.
  ///
  /// Each outflow consumes the oldest unspent inflow on or before its date.
  /// Inflows are lines with no envelope and a positive base amount; outflows
  /// have a negative base amount and an envelope. Internal transfers are
  /// excluded and only the 365 days ending today are read.
  static Future<int?> ageOfMoney(Session session, UuidValue entityId) =>
      session.db.transaction(
        (transaction) async {
          _countStatement('entity');
          final entity = await EntityAccess.requireOwned(
            session,
            entityId,
            transaction: transaction,
          );
          final today = EntityClock.today(entity, now: FxService.utcNow());

          _countStatement('ageOfMoney');
          final rows = await session.db.unsafeQuery(
            ageOfMoneySql,
            parameters: QueryParameters.named({
              'entityId': entityId.toString(),
              'fromDate': today.subtract(const Duration(days: 365)),
              'toDate': today,
            }),
            transaction: transaction,
          );

          final inflows = <({DateTime date, int amountMinor})>[];
          final outflows = <({DateTime date, int amountMinor})>[];
          for (final row in rows) {
            final date = row[0] as DateTime;
            final amount = _parseMinor(row[1], 'Age of money line');
            if (amount > 0) {
              inflows.add((date: date, amountMinor: amount));
            } else if (amount < 0) {
              outflows.add((date: date, amountMinor: -amount));
            }
          }
          if (inflows.isEmpty || outflows.isEmpty) return null;

          final unspent = <({DateTime date, int remainingMinor})>[];
          var inflowIndex = 0;
          var head = 0;
          final ages = <int>[];
          for (final outflow in outflows) {
            while (inflowIndex < inflows.length &&
                !inflows[inflowIndex].date.isAfter(outflow.date)) {
              unspent.add((
                date: inflows[inflowIndex].date,
                remainingMinor: inflows[inflowIndex].amountMinor,
              ));
              inflowIndex += 1;
            }

            var remaining = outflow.amountMinor;
            while (remaining > 0 && head < unspent.length) {
              final inflow = unspent[head];
              final consumed = math.min(remaining, inflow.remainingMinor);
              ages.add(outflow.date.difference(inflow.date).inDays);
              remaining -= consumed;
              final left = inflow.remainingMinor - consumed;
              if (left <= 0) {
                head += 1;
              } else {
                unspent[head] = (date: inflow.date, remainingMinor: left);
              }
            }
          }
          if (ages.isEmpty) return null;

          final recent = ages.length > 10
              ? ages.sublist(ages.length - 10)
              : ages;
          final sum = recent.fold<int>(0, (total, age) => total + age);
          return (sum / recent.length).round();
        },
        settings: const TransactionSettings(
          isolationLevel: IsolationLevel.repeatableRead,
        ),
      );

  static Future<Map<UuidValue, String>> _groupNames(
    Session session,
    UuidValue entityId,
    ReportGrouping grouping, {
    required Transaction transaction,
  }) async {
    _countStatement('groupNames');
    return switch (grouping) {
      ReportGrouping.envelope => {
        for (final row in await Envelope.db.find(
          session,
          where: (table) => table.entityId.equals(entityId),
          transaction: transaction,
        ))
          row.id!: row.name,
      },
      ReportGrouping.category => {
        for (final row in await Category.db.find(
          session,
          where: (table) => table.entityId.equals(entityId),
          transaction: transaction,
        ))
          row.id!: row.name,
      },
      ReportGrouping.payee => {
        for (final row in await Payee.db.find(
          session,
          where: (table) => table.entityId.equals(entityId),
          transaction: transaction,
        ))
          row.id!: row.name,
      },
    };
  }

  static String _groupName(
    Object? rawId,
    Map<UuidValue, String> names,
    String fallback,
  ) {
    if (rawId == null) return fallback;
    return names[UuidValue.fromString(rawId as String)] ?? fallback;
  }

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

  static void _countStatement(String label) {
    _debugStatementCount += 1;
    _debugStatementLabels.add(label);
  }
}
