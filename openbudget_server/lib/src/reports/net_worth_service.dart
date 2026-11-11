import 'package:meta/meta.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/common/currency_validation.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/fx_rates/fx_quote_selection.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/reports/net_worth_periods.dart';
import 'package:openbudget_server/src/settings/user_settings_service.dart';
import 'package:serverpod/serverpod.dart';

/// Combined and historical net worth for the caller's entities.
///
/// The current view converts every non-zero account once and sums the same
/// converted atoms into every total, so assets plus liabilities equals net
/// worth and the entity and currency breakdowns add up exactly after rounding.
/// A liability is classified by [AccountKindRules.isLiability], never by the
/// sign of its balance: an overpaid card stays in liabilities and a negative
/// asset stays in assets.
///
/// An account with a zero balance produces no account row, no currency row and
/// no total. An entity with no non-zero accounts still appears with zero totals
/// and `isComplete == true`. A currency with no rate has `convertedMinor` null,
/// is listed in `missingCurrencyCodes`, and its atoms are excluded from every
/// total, so `isComplete` is false. Identity is used only when the account
/// currency and the reporting currency are the same code; no missing quote is
/// ever replaced with a 1:1 conversion.
///
/// Reports read one repeatable-read snapshot. Facts are fetched with one
/// batched statement per balance source, never one query per account or point.
abstract final class NetWorthService {
  /// A day balance from the account cache.
  ///
  /// [asOf] defaults to today in the first entity's time zone, or UTC when the
  /// scope is empty. A past date uses [history]'s balance engine for one point
  /// and keeps the full account, entity and currency breakdowns; the cached
  /// account balance is never used for a past date. A future date is rejected.
  ///
  /// A null [entityIds] selects the caller's entities with
  /// `includeInNetWorth` and no `archivedAt`. An explicit list is deduplicated
  /// and every id is ownership-checked before any fact is read: a missing id
  /// is `NotFound`, a foreign one is `Forbidden`, and nothing is silently
  /// dropped. Explicit selection keeps archived entities and entities whose
  /// `includeInNetWorth` is false. An explicit empty list is an empty scope,
  /// not the default scope.
  static Future<NetWorthView> current(
    Session session, {
    List<UuidValue>? entityIds,
    String? currencyCode,
    DateTime? asOf,
  }) async {
    final userId = EntityAccess.userId(session);
    if (asOf != null) _requireDate(asOf, 'asOf');

    final result = await session.db.transaction(
      (transaction) async {
        final entities = await _loadEntities(
          session,
          transaction,
          userId,
          entityIds,
        );
        final reporting = await _reportingCurrency(
          session,
          transaction,
          currencyCode,
        );
        final today = _todayFor(entities);
        final resolvedAsOf = asOf ?? today;
        if (resolvedAsOf.isAfter(today)) {
          throw ValidationException(message: 'asOf cannot be in the future');
        }

        final accounts = await _loadAccounts(session, transaction, entities);
        if (resolvedAsOf == today) {
          final atoms = await _currentAtoms(
            session,
            transaction,
            accounts,
            resolvedAsOf,
          );
          final fxRates = await _loadFxRates(
            session,
            transaction,
            fromDate: resolvedAsOf,
            toDate: resolvedAsOf,
            reportingCurrencyCode: reporting.code,
            accountCurrencies: atoms.map(
              (atom) => atom.account.currencyCode,
            ),
          );
          final point = _aggregate(
            date: resolvedAsOf,
            atoms: atoms,
            rates: _selectRates(
              atoms: atoms,
              reporting: reporting,
              date: resolvedAsOf,
              fxRates: fxRates,
              now: FxService.utcNow(),
            ),
            reportingExponent: reporting.exponent,
          );
          return _CurrentResult(
            view: _viewFromPoint(
              entities: entities,
              point: point,
              reporting: reporting,
              asOf: resolvedAsOf,
            ),
            missingDates: point.rates.missing.isEmpty
                ? const {}
                : {resolvedAsOf},
          );
        }

        final history = await _computeHistory(
          session,
          transaction,
          entities: entities,
          accounts: accounts,
          points: [resolvedAsOf],
          reporting: reporting,
        );
        return _CurrentResult(
          view: _viewFromPoint(
            entities: entities,
            point: history.points.single,
            reporting: reporting,
            asOf: resolvedAsOf,
          ),
          missingDates: history.missingDates,
        );
      },
      settings: const TransactionSettings(
        isolationLevel: IsolationLevel.repeatableRead,
      ),
    );

    await _requestBackfills(session, result.missingDates);
    return result.view;
  }

  /// Net worth on the last day of every period in [fromDate] to [toDate].
  ///
  /// A day range spans at most 92 days, a week range at most two calendar
  /// years, and a month range at most 400 months; no response carries more
  /// than 400 points. Weeks end on Sunday and months on their last day; when
  /// [toDate] is inside a period it is appended as the final point, once.
  ///
  /// Balances are rebuilt from live facts on every call: an opening total
  /// before [fromDate] plus daily transaction movements or dated valuations in
  /// the range. Edits, late imports, deletes and corrected valuations are
  /// therefore reflected without a snapshot table or a rebuild.
  static Future<NetWorthHistoryView> history(
    Session session, {
    required DateTime fromDate,
    required DateTime toDate,
    required NetWorthGranularity granularity,
    List<UuidValue>? entityIds,
    String? currencyCode,
  }) async {
    final userId = EntityAccess.userId(session);
    final points = NetWorthPeriods.points(
      fromDate: fromDate,
      toDate: toDate,
      granularity: granularity,
    );

    final result = await session.db.transaction(
      (transaction) async {
        final entities = await _loadEntities(
          session,
          transaction,
          userId,
          entityIds,
        );
        final reporting = await _reportingCurrency(
          session,
          transaction,
          currencyCode,
        );
        final accounts = await _loadAccounts(session, transaction, entities);
        final history = await _computeHistory(
          session,
          transaction,
          entities: entities,
          accounts: accounts,
          points: points,
          reporting: reporting,
        );
        return _HistoryResult(
          view: NetWorthHistoryView(
            currencyCode: reporting.code,
            granularity: granularity,
            points: [
              for (final point in history.points)
                NetWorthPoint(
                  date: point.date,
                  assetsMinor: point.assetsMinor,
                  liabilitiesMinor: point.liabilitiesMinor,
                  netWorthMinor: point.netWorthMinor,
                  isComplete: point.isComplete,
                ),
            ],
          ),
          missingDates: history.missingDates,
          today: _todayFor(entities),
        );
      },
      settings: const TransactionSettings(
        isolationLevel: IsolationLevel.repeatableRead,
      ),
    );

    await _requestBackfills(
      session,
      result.missingDates.where((date) => !date.isAfter(result.today)),
    );
    return result.view;
  }

  /// Transaction movements: one opening total before the range and one total
  /// per account and day inside it.
  @visibleForTesting
  static const transactionsSql = '''
SELECT
  t."accountId"::text AS "accountId",
  NULL::timestamp AS "day",
  SUM(t."amountMinor")::text AS "amount"
FROM "transaction" t
WHERE t."accountId" = ANY(@openingAccountIds::uuid[])
  AND t."date" < @fromDate::timestamp
GROUP BY t."accountId"
UNION ALL
SELECT
  t."accountId"::text AS "accountId",
  t."date" AS "day",
  SUM(t."amountMinor")::text AS "amount"
FROM "transaction" t
WHERE t."accountId" = ANY(@rangeAccountIds::uuid[])
  AND t."date" >= @fromDate::timestamp
  AND t."date" <= @toDate::timestamp
GROUP BY t."accountId", t."date"''';

  /// The last valuation before the range and every valuation inside it.
  @visibleForTesting
  static const valuationsSql = '''
(SELECT DISTINCT ON ("accountId")
  "accountId"::text AS "accountId",
  "valuationDate" AS "valuationDate",
  "valueMinor"::text AS "valueMinor"
FROM account_valuation
WHERE "accountId" = ANY(@openingAccountIds::uuid[])
  AND "valuationDate" < @fromDate::timestamp
ORDER BY "accountId", "valuationDate" DESC)
UNION ALL
SELECT
  "accountId"::text AS "accountId",
  "valuationDate" AS "valuationDate",
  "valueMinor"::text AS "valueMinor"
FROM account_valuation
WHERE "accountId" = ANY(@rangeAccountIds::uuid[])
  AND "valuationDate" >= @fromDate::timestamp
  AND "valuationDate" <= @toDate::timestamp''';

  /// Every stored daily rate the range can use, in one statement.
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

  /// The latest valuation date at or before the current date.
  @visibleForTesting
  static const latestValuationDatesSql = '''
SELECT DISTINCT ON ("accountId")
  "accountId"::text AS "accountId",
  "valuationDate"
FROM account_valuation
WHERE "accountId" = ANY(@accountIds::uuid[])
  AND "valuationDate" <= @asOf::timestamp
ORDER BY "accountId", "valuationDate" DESC''';

  static int _debugStatementCount = 0;
  static final List<String> _debugStatementLabels = [];

  /// Counts the statements this service issued since the last reset.
  ///
  /// This is a logical counter for the service's own reads. It is not a total
  /// of every SQL statement in the request: [UserSettingsService.get] may run
  /// its own lazy-create lookup inside the single `settings` step, and an FX
  /// backfill scheduled after commit is not counted.
  @visibleForTesting
  static int get debugStatementCount => _debugStatementCount;

  /// The labels of the statements counted by [debugStatementCount].
  @visibleForTesting
  static List<String> get debugStatementLabels =>
      List.unmodifiable(_debugStatementLabels);

  /// How many counted statements used [label].
  @visibleForTesting
  static int debugStatementCountFor(String label) =>
      _debugStatementLabels.where((entry) => entry == label).length;

  /// Resets the statement counter before a measured read.
  @visibleForTesting
  static void resetDebugStatementCount() {
    _debugStatementCount = 0;
    _debugStatementLabels.clear();
  }

  /// Runs once after the first fact statement, before the next one.
  ///
  /// A concurrency test commits a competing write here and proves the returned
  /// history still comes from one snapshot.
  @visibleForTesting
  static Future<void> Function()? debugAfterTransactionsQuery;

  static Future<List<Entity>> _loadEntities(
    Session session,
    Transaction transaction,
    UuidValue userId,
    List<UuidValue>? requested,
  ) async {
    if (requested == null) {
      _countStatement('scope');
      final entities = await Entity.db.find(
        session,
        where: (table) =>
            table.ownerId.equals(userId) &
            table.includeInNetWorth.equals(true) &
            table.archivedAt.equals(null),
        orderByList: (table) => [table.sortOrder, table.id],
        transaction: transaction,
      );
      return [...entities]..sort(_entityOrder);
    }

    final unique = <UuidValue>[];
    final seen = <UuidValue>{};
    for (final entityId in requested) {
      if (seen.add(entityId)) unique.add(entityId);
    }
    if (unique.isEmpty) return const [];

    _countStatement('scope');
    final rows = await Entity.db.find(
      session,
      where: (table) => table.id.inSet(unique.toSet()),
      transaction: transaction,
    );
    final byId = {for (final entity in rows) entity.id!: entity};

    final entities = <Entity>[];
    for (final entityId in unique) {
      final entity = byId[entityId];
      if (entity == null) throw NotFoundException();
      if (entity.ownerId != userId) throw ForbiddenException();
      entities.add(entity);
    }
    return entities..sort(_entityOrder);
  }

  static int _entityOrder(Entity first, Entity second) {
    final bySortOrder = first.sortOrder.compareTo(second.sortOrder);
    if (bySortOrder != 0) return bySortOrder;
    return first.id.toString().compareTo(second.id.toString());
  }

  static Future<_ReportingCurrency> _reportingCurrency(
    Session session,
    Transaction transaction,
    String? requested,
  ) async {
    final String code;
    if (requested != null) {
      code = requireSupportedCurrency(requested);
    } else {
      _countStatement('settings');
      final settings = await UserSettingsService.get(
        session,
        transaction: transaction,
      );
      code = requireSupportedCurrency(settings.reportingCurrencyCode);
    }

    final exponent = exponentForCurrency(code);
    if (exponent == null) {
      throw ValidationException(message: 'Unsupported currency: $code');
    }
    return _ReportingCurrency(code: code, exponent: exponent);
  }

  static Future<List<Account>> _loadAccounts(
    Session session,
    Transaction transaction,
    List<Entity> entities,
  ) async {
    if (entities.isEmpty) return const [];

    final entityIds = {for (final entity in entities) entity.id!};
    _countStatement('accounts');
    final accounts = await Account.db.find(
      session,
      where: (table) => table.entityId.inSet(entityIds),
      orderByList: (table) => [table.sortOrder, table.id],
      transaction: transaction,
    );
    for (final account in accounts) {
      _exponentFor(account.currencyCode);
    }
    final entityOrder = {
      for (var index = 0; index < entities.length; index++)
        entities[index].id!: index,
    };

    return [...accounts]..sort((first, second) {
      final byEntity = entityOrder[first.entityId]!.compareTo(
        entityOrder[second.entityId]!,
      );
      if (byEntity != 0) return byEntity;

      final bySortOrder = first.sortOrder.compareTo(second.sortOrder);
      if (bySortOrder != 0) return bySortOrder;

      return first.id.toString().compareTo(second.id.toString());
    });
  }

  static DateTime _todayFor(List<Entity> entities) {
    final now = FxService.utcNow();
    if (entities.isEmpty) {
      return DateTime.utc(now.year, now.month, now.day);
    }
    return EntityClock.today(entities.first, now: now);
  }

  static Future<List<_Atom>> _currentAtoms(
    Session session,
    Transaction transaction,
    List<Account> accounts,
    DateTime asOf,
  ) async {
    final valuationDates = await _latestValuationDates(
      session,
      transaction,
      accounts,
      asOf,
    );

    return [
      for (final account in accounts)
        if (account.balanceMinor != 0)
          _Atom(
            account: account,
            balanceMinor: account.balanceMinor,
            valuationDate: valuationDates[account.id!.toString()],
          ),
    ];
  }

  static Future<Map<String, DateTime>> _latestValuationDates(
    Session session,
    Transaction transaction,
    List<Account> accounts,
    DateTime asOf,
  ) async {
    final accountIds = [
      for (final account in accounts)
        if (account.balanceSource == AccountBalanceSource.valuations &&
            account.balanceMinor != 0)
          account.id!,
    ];
    if (accountIds.isEmpty) return const {};

    _countStatement('valuationDates');
    final rows = await session.db.unsafeQuery(
      latestValuationDatesSql,
      parameters: QueryParameters.named({
        'accountIds': _uuidArrayLiteral(accountIds),
        'asOf': asOf,
      }),
      transaction: transaction,
    );

    return {
      for (final row in rows) row[0] as String: row[1] as DateTime,
    };
  }

  static Future<_HistoryComputation> _computeHistory(
    Session session,
    Transaction transaction, {
    required List<Entity> entities,
    required List<Account> accounts,
    required List<DateTime> points,
    required _ReportingCurrency reporting,
  }) async {
    final transactionAccounts = [
      for (final account in accounts)
        if (account.balanceSource == AccountBalanceSource.transactions)
          account.id!,
    ];
    final valuationAccounts = [
      for (final account in accounts)
        if (account.balanceSource == AccountBalanceSource.valuations)
          account.id!,
    ];

    final transactions = transactionAccounts.isEmpty
        ? const <String, _TransactionMovements>{}
        : await _loadTransactions(
            session,
            transaction,
            accountIds: transactionAccounts,
            fromDate: points.first,
            toDate: points.last,
          );
    final hookRan = transactionAccounts.isNotEmpty;
    if (hookRan) await _runFactsHook();

    final valuations = valuationAccounts.isEmpty
        ? const <String, _ValuationMovements>{}
        : await _loadValuations(
            session,
            transaction,
            accountIds: valuationAccounts,
            fromDate: points.first,
            toDate: points.last,
          );
    if (!hookRan) await _runFactsHook();

    final histories = [
      for (final account in accounts)
        _AccountHistory(
          account: account,
          transactions: transactions[account.id!.toString()],
          valuations: valuations[account.id!.toString()],
        ),
    ];
    final fxRates = await _loadFxRates(
      session,
      transaction,
      fromDate: points.first,
      toDate: points.last,
      reportingCurrencyCode: reporting.code,
      accountCurrencies: accounts.map((account) => account.currencyCode),
    );
    final now = FxService.utcNow();
    final missingDates = <DateTime>{};
    final computed = <_PointComputation>[];

    for (final date in points) {
      final atoms = <_Atom>[];
      for (final history in histories) {
        final balance = history.advanceTo(date);
        if (balance != 0) {
          atoms.add(
            _Atom(
              account: history.account,
              balanceMinor: balance,
              valuationDate: history.valuationDate,
            ),
          );
        }
      }

      final rates = _selectRates(
        atoms: atoms,
        reporting: reporting,
        date: date,
        fxRates: fxRates,
        now: now,
      );
      if (rates.missing.isNotEmpty) missingDates.add(date);

      computed.add(
        _aggregate(
          date: date,
          atoms: atoms,
          rates: rates,
          reportingExponent: reporting.exponent,
        ),
      );
    }

    return _HistoryComputation(points: computed, missingDates: missingDates);
  }

  static Future<void> _runFactsHook() async {
    final hook = debugAfterTransactionsQuery;
    if (hook != null) await hook();
  }

  static Future<Map<String, _TransactionMovements>> _loadTransactions(
    Session session,
    Transaction transaction, {
    required List<UuidValue> accountIds,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    _countStatement('transactions');
    final rows = await session.db.unsafeQuery(
      transactionsSql,
      parameters: QueryParameters.named({
        'openingAccountIds': _uuidArrayLiteral(accountIds),
        'rangeAccountIds': _uuidArrayLiteral(accountIds),
        'fromDate': fromDate,
        'toDate': toDate,
      }),
      transaction: transaction,
    );

    final result = <String, _TransactionMovements>{};
    for (final row in rows) {
      final accountId = row[0] as String;
      final movements = result.putIfAbsent(
        accountId,
        _TransactionMovements.new,
      );
      final day = row[1] as DateTime?;
      final amount = _parseMinor(row[2], 'Transaction history');
      if (day == null) {
        movements.openingMinor = _checkedSum(
          movements.openingMinor,
          amount,
          'Transaction opening balance',
        );
      } else {
        movements.amounts.add((date: day, amountMinor: amount));
      }
    }

    for (final movements in result.values) {
      movements.amounts.sort(
        (first, second) => first.date.compareTo(second.date),
      );
    }
    return result;
  }

  static Future<Map<String, _ValuationMovements>> _loadValuations(
    Session session,
    Transaction transaction, {
    required List<UuidValue> accountIds,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    _countStatement('valuations');
    final rows = await session.db.unsafeQuery(
      valuationsSql,
      parameters: QueryParameters.named({
        'openingAccountIds': _uuidArrayLiteral(accountIds),
        'rangeAccountIds': _uuidArrayLiteral(accountIds),
        'fromDate': fromDate,
        'toDate': toDate,
      }),
      transaction: transaction,
    );

    final result = <String, _ValuationMovements>{};
    for (final row in rows) {
      final accountId = row[0] as String;
      final movements = result.putIfAbsent(
        accountId,
        _ValuationMovements.new,
      );
      final date = row[1] as DateTime;
      final value = _parseMinor(row[2], 'Account valuation');
      if (date.isBefore(fromDate)) {
        movements
          ..openingMinor = value
          ..openingDate = date;
      } else {
        movements.values.add((date: date, valueMinor: value));
      }
    }

    for (final movements in result.values) {
      movements.values.sort(
        (first, second) => first.date.compareTo(second.date),
      );
    }
    return result;
  }

  static Future<List<FxDailyRate>> _loadFxRates(
    Session session,
    Transaction transaction, {
    required DateTime fromDate,
    required DateTime toDate,
    required String reportingCurrencyCode,
    required Iterable<String> accountCurrencies,
  }) async {
    final needed = {
      for (final currency in accountCurrencies)
        if (currency != reportingCurrencyCode) currency,
    };
    if (needed.isEmpty) return const [];

    _countStatement('fx');
    final rows = await session.db.unsafeQuery(
      fxRowsSql,
      parameters: QueryParameters.named({
        'currencyCodes': _textArrayLiteral({
          ...needed,
          reportingCurrencyCode,
        }),
        'windowStart': fromDate.subtract(const Duration(days: 7)),
        'toDate': toDate,
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

  static _RateSelection _selectRates({
    required List<_Atom> atoms,
    required _ReportingCurrency reporting,
    required DateTime date,
    required List<FxDailyRate> fxRates,
    required DateTime now,
  }) {
    final currencies = {
      for (final atom in atoms) atom.account.currencyCode,
    };
    final byCurrency = <String, FxQuoteSelection?>{};
    final missing = <String>{};

    for (final currency in currencies) {
      final quote = FxQuoteSelection.select(
        fromCurrencyCode: currency,
        toCurrencyCode: reporting.code,
        date: date,
        rates: fxRates,
        now: now,
      );
      byCurrency[currency] = quote;
      if (quote == null) missing.add(currency);
    }
    return _RateSelection(byCurrency: byCurrency, missing: missing);
  }

  static _PointComputation _aggregate({
    required DateTime date,
    required List<_Atom> atoms,
    required _RateSelection rates,
    required int reportingExponent,
  }) {
    final converted = <_ConvertedAtom>[];
    var assetsMinor = 0;
    var liabilitiesMinor = 0;

    for (final atom in atoms) {
      final quote = rates.byCurrency[atom.account.currencyCode];
      if (quote == null) {
        converted.add(_ConvertedAtom(atom: atom, convertedMinor: null));
        continue;
      }

      final value = _convert(atom, quote, reportingExponent);
      converted.add(_ConvertedAtom(atom: atom, convertedMinor: value));
      if (atom.account.kind.isLiability) {
        liabilitiesMinor = _checkedSum(
          liabilitiesMinor,
          value,
          'Liability total',
        );
      } else {
        assetsMinor = _checkedSum(assetsMinor, value, 'Asset total');
      }
    }

    return _PointComputation(
      date: date,
      atoms: converted,
      rates: rates,
      assetsMinor: assetsMinor,
      liabilitiesMinor: liabilitiesMinor,
      netWorthMinor: _checkedSum(
        assetsMinor,
        liabilitiesMinor,
        'Net worth total',
      ),
    );
  }

  static int _convert(
    _Atom atom,
    FxQuoteSelection quote,
    int reportingExponent,
  ) {
    // Security: convertMinorUnits is the single checked conversion boundary
    // and reports an out-of-range result as RangeError. Surface it as a
    // validation failure instead of letting a raw Error escape the endpoint.
    try {
      return convertMinorUnits(
        amountMinor: atom.balanceMinor,
        exchangeRate: quote.rate,
        transactionExponent: _exponentFor(atom.account.currencyCode),
        functionalExponent: reportingExponent,
      );
      // The conversion boundary checks the range and throws RangeError; this
      // boundary is the one place that turns it into a validation failure.
      // ignore: avoid_catching_errors
    } on RangeError {
      throw ValidationException(
        message:
            'Converted balance for account ${atom.account.id} exceeds the '
            'safe minor-unit range',
      );
    }
  }

  static NetWorthView _viewFromPoint({
    required List<Entity> entities,
    required _PointComputation point,
    required _ReportingCurrency reporting,
    required DateTime asOf,
  }) {
    final currencyCodes = {
      for (final converted in point.atoms) converted.atom.account.currencyCode,
    }.toList()..sort();
    final currencyRows = <NetWorthCurrencyRow>[];
    for (final currency in currencyCodes) {
      var nativeMinor = 0;
      var convertedMinor = 0;
      var allConverted = true;
      var accountCount = 0;
      for (final converted in point.atoms) {
        if (converted.atom.account.currencyCode != currency) continue;

        nativeMinor = _checkedSum(
          nativeMinor,
          converted.atom.balanceMinor,
          'Native $currency total',
        );
        accountCount += 1;
        final value = converted.convertedMinor;
        if (value == null) {
          allConverted = false;
        } else {
          convertedMinor = _checkedSum(
            convertedMinor,
            value,
            'Converted $currency total',
          );
        }
      }

      final quote = point.rates.byCurrency[currency];
      currencyRows.add(
        NetWorthCurrencyRow(
          currencyCode: currency,
          nativeMinor: nativeMinor,
          convertedMinor: allConverted ? convertedMinor : null,
          fxRate: quote?.rateText,
          fxRateDate: quote?.rateDate,
          fxRateSource: quote?.source,
          isStale: quote?.isStale ?? false,
          accountCount: accountCount,
        ),
      );
    }

    final entityRows = <NetWorthEntityRow>[];
    for (final entity in entities) {
      var assetsMinor = 0;
      var liabilitiesMinor = 0;
      var isComplete = true;
      for (final converted in point.atoms) {
        if (converted.atom.account.entityId != entity.id) continue;

        final value = converted.convertedMinor;
        if (value == null) {
          isComplete = false;
          continue;
        }
        if (converted.atom.account.kind.isLiability) {
          liabilitiesMinor = _checkedSum(
            liabilitiesMinor,
            value,
            'Entity liability total',
          );
        } else {
          assetsMinor = _checkedSum(
            assetsMinor,
            value,
            'Entity asset total',
          );
        }
      }
      entityRows.add(
        NetWorthEntityRow(
          entityId: entity.id!,
          name: entity.name,
          kind: entity.kind,
          assetsMinor: assetsMinor,
          liabilitiesMinor: liabilitiesMinor,
          netWorthMinor: _checkedSum(
            assetsMinor,
            liabilitiesMinor,
            'Entity net worth',
          ),
          isComplete: isComplete,
        ),
      );
    }

    final accountRows = [
      for (final converted in point.atoms)
        NetWorthAccountRow(
          accountId: converted.atom.account.id!,
          entityId: converted.atom.account.entityId,
          name: converted.atom.account.name,
          kind: converted.atom.account.kind,
          isLiability: converted.atom.account.kind.isLiability,
          currencyCode: converted.atom.account.currencyCode,
          balanceMinor: converted.atom.balanceMinor,
          convertedMinor: converted.convertedMinor,
          valuationDate: converted.atom.valuationDate,
        ),
    ];
    final missing = point.rates.missing.toList()..sort();

    return NetWorthView(
      currencyCode: reporting.code,
      asOf: asOf,
      assetsMinor: point.assetsMinor,
      liabilitiesMinor: point.liabilitiesMinor,
      netWorthMinor: point.netWorthMinor,
      isComplete: missing.isEmpty,
      missingCurrencyCodes: missing,
      hasStaleRates: currencyRows.any((row) => row.isStale),
      currencies: currencyRows,
      entities: entityRows,
      accounts: accountRows,
    );
  }

  static Future<void> _requestBackfills(
    Session session,
    Iterable<DateTime> dates,
  ) async {
    final unique = dates.toSet().toList()..sort();
    for (final date in unique) {
      await FxService.requestBackfill(session, date);
    }
  }

  static int _exponentFor(String currencyCode) {
    final exponent = exponentForCurrency(currencyCode);
    if (exponent == null) {
      throw ValidationException(
        message: 'Unsupported currency: $currencyCode',
      );
    }
    return exponent;
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

  static int _checkedSum(int first, int second, String context) {
    final sum = BigInt.from(first) + BigInt.from(second);
    if (sum.abs() > BigInt.from(maxSafeMinor)) {
      throw ValidationException(
        message: '$context exceeds the safe minor-unit range',
      );
    }
    return sum.toInt();
  }

  static String _uuidArrayLiteral(Iterable<UuidValue> ids) =>
      '{${ids.map((id) => id.uuid).join(',')}}';

  static String _textArrayLiteral(Iterable<String> values) =>
      '{${values.join(',')}}';

  static void _requireDate(DateTime date, String field) {
    if (!isCivilDate(date) || date.year < 1900 || date.year > 9999) {
      throw ValidationException(
        message: '$field must be a UTC calendar date between 1900 and 9999',
      );
    }
  }

  static void _countStatement(String label) {
    _debugStatementCount += 1;
    _debugStatementLabels.add(label);
  }
}

class _ReportingCurrency {
  const _ReportingCurrency({required this.code, required this.exponent});

  final String code;
  final int exponent;
}

class _Atom {
  const _Atom({
    required this.account,
    required this.balanceMinor,
    required this.valuationDate,
  });

  final Account account;
  final int balanceMinor;
  final DateTime? valuationDate;
}

class _ConvertedAtom {
  const _ConvertedAtom({required this.atom, required this.convertedMinor});

  final _Atom atom;
  final int? convertedMinor;
}

class _RateSelection {
  const _RateSelection({required this.byCurrency, required this.missing});

  final Map<String, FxQuoteSelection?> byCurrency;
  final Set<String> missing;
}

class _PointComputation {
  const _PointComputation({
    required this.date,
    required this.atoms,
    required this.rates,
    required this.assetsMinor,
    required this.liabilitiesMinor,
    required this.netWorthMinor,
  });

  final DateTime date;
  final List<_ConvertedAtom> atoms;
  final _RateSelection rates;
  final int assetsMinor;
  final int liabilitiesMinor;
  final int netWorthMinor;

  bool get isComplete => rates.missing.isEmpty;
}

class _TransactionMovements {
  int openingMinor = 0;
  final List<({DateTime date, int amountMinor})> amounts = [];
}

class _ValuationMovements {
  int openingMinor = 0;
  DateTime? openingDate;
  final List<({DateTime date, int valueMinor})> values = [];
}

class _AccountHistory {
  _AccountHistory({
    required this.account,
    required _TransactionMovements? transactions,
    required _ValuationMovements? valuations,
  }) : _transactions = transactions,
       _valuations = valuations,
       _balance = transactions?.openingMinor ?? valuations?.openingMinor ?? 0,
       valuationDate = valuations?.openingDate;

  final Account account;
  final _TransactionMovements? _transactions;
  final _ValuationMovements? _valuations;
  int _balance;
  int _cursor = 0;

  DateTime? valuationDate;

  int advanceTo(DateTime date) {
    final transactions = _transactions;
    if (transactions != null) {
      while (_cursor < transactions.amounts.length &&
          !transactions.amounts[_cursor].date.isAfter(date)) {
        _balance = _sum(_balance, transactions.amounts[_cursor].amountMinor);
        _cursor += 1;
      }
      return _balance;
    }

    final valuations = _valuations;
    if (valuations == null) return _balance;
    while (_cursor < valuations.values.length &&
        !valuations.values[_cursor].date.isAfter(date)) {
      _balance = valuations.values[_cursor].valueMinor;
      valuationDate = valuations.values[_cursor].date;
      _cursor += 1;
    }
    return _balance;
  }

  static int _sum(int first, int second) {
    final sum = BigInt.from(first) + BigInt.from(second);
    if (sum.abs() > BigInt.from(maxSafeMinor)) {
      throw ValidationException(
        message: 'Running balance exceeds the safe minor-unit range',
      );
    }
    return sum.toInt();
  }
}

class _HistoryComputation {
  const _HistoryComputation({
    required this.points,
    required this.missingDates,
  });

  final List<_PointComputation> points;
  final Set<DateTime> missingDates;
}

class _CurrentResult {
  const _CurrentResult({required this.view, required this.missingDates});

  final NetWorthView view;
  final Set<DateTime> missingDates;
}

class _HistoryResult {
  const _HistoryResult({
    required this.view,
    required this.missingDates,
    required this.today,
  });

  final NetWorthHistoryView view;
  final Set<DateTime> missingDates;
  final DateTime today;
}
