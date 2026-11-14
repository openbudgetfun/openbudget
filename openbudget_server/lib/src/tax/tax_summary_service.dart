import 'package:meta/meta.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/fx_rates/fx_quote_selection.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/tax/tax_entry_builder.dart';
import 'package:openbudget_server/src/tax/tax_fx_rates.dart';
import 'package:openbudget_server/src/tax/tax_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// One summary computation, or the rates the read could not find.
class _MissingTaxRates implements Exception {
  const _MissingTaxRates(this.requests);

  final List<TaxFxRequest> requests;
}

/// The period a summary covers, always a half-open range of civil dates.
final class _SummaryPeriod {
  const _SummaryPeriod({
    required this.startYear,
    required this.start,
    required this.end,
    required this.label,
  });

  final int startYear;
  final DateTime start;
  final DateTime end;
  final String label;
}

/// Per-category accumulation inside one summary bucket.
final class _CategoryBucket {
  final totals = <String, ({int totalMinor, int entryCount})>{};

  void add(String code, int amountMinor) {
    final existing = totals[code];
    totals[code] = (
      totalMinor: (existing?.totalMinor ?? 0) + amountMinor,
      entryCount: (existing?.entryCount ?? 0) + 1,
    );
  }
}

/// Collected and paid sales tax accumulated for one rate or quarter.
final class _SalesTaxBucket {
  int collectedMinor = 0;
  int paidMinor = 0;
}

/// One distinct rate group of converted lines.
final class _FxGroup {
  _FxGroup(this.sourceCurrencyCode, this.quote);

  /// The currency the group's lines were converted from.
  final String sourceCurrencyCode;
  final FxQuoteSelection quote;
  int lineCount = 0;
  int convertedMinor = 0;
}

/// Estimated wallet figures for one wallet and P&L currency.
final class _WalletBucket {
  int transactionCount = 0;
  BigInt proceeds = BigInt.zero;
  BigInt costBasis = BigInt.zero;
  BigInt realized = BigInt.zero;
}

/// One summary computation together with the provenance the export needs.
///
/// [entries] are the mapped, converted entries that fed the view, one per
/// contributing line. Each keeps its position in the pre-mapping entry
/// list through [sourceIndexes], where [fxRequests] holds that entry's
/// conversion request and [rates] can quote it. [sourceLines] is every
/// in-period line the shared query loaded, keyed by line id, so the
/// export can show the original amount, payee and envelope per line.
final class TaxSummaryComputation {
  const TaxSummaryComputation({
    required this.view,
    required this.currencyCode,
    required this.entries,
    required this.sourceIndexes,
    required this.fxRequests,
    required this.rates,
    required this.sourceLines,
  });

  final TaxSummaryView view;

  /// ISO 4217 code every amount in the view is reported in.
  final String currencyCode;

  /// The mapped entries that fed the view, in line order.
  final List<TaxEntry> entries;

  /// For each entry, its index in the pre-mapping entry list.
  final List<int> sourceIndexes;

  /// One conversion request per pre-mapping entry.
  final List<TaxFxRequest> fxRequests;

  /// The exact daily rates the conversions used.
  final TaxFxRates rates;

  /// Every in-period source line the shared query loaded, by line id.
  final Map<String, TaxEntrySourceLine> sourceLines;
}

/// Which side of the sales-tax sections an embedded tax belongs to.
enum _SalesTaxDirection { collected, paid }

/// Builds the tax-ready summary for any entity and year
/// (docs/tax-jurisdictions.md, section 8.7).
///
/// A pack country uses the pack's tax year and reports totals under the
/// pack's own category codes; any other country uses the universal tax
/// year, and a company in either uses its own financial year. The summary
/// needs no tax profile: it totals tagged lines, it does not compute a
/// return. Wallet figures come from the stored FIFO estimates and keep the
/// wallet's own P&L currency; they are never converted here.
class TaxSummaryService {
  static final _log = ObLogger('TaxSummaryService');

  /// The ARB key the app renders beside every summary.
  static const disclaimerKey = 'taxSummaryDisclaimer';

  static const _walletCostBasisMethod = 'fifo';

  static const _walletMethodCaveat =
      'Wallet figures are FIFO estimates on stored wallet valuations, not '
      "a tax disposal computation; your jurisdiction's cost-basis and "
      'matching rules may differ.';

  /// Resolves the rule pack for a jurisdiction.
  ///
  /// Tests replace this with a fake pack; production uses [TaxRules].
  @visibleForTesting
  static TaxRulePack Function(TaxJurisdiction jurisdiction) packFor =
      TaxRules.forJurisdiction;

  /// The server clock used for the default tax year and quote staleness.
  @visibleForTesting
  static DateTime Function() clock = () => DateTime.now().toUtc();

  /// Builds the entity's summary for the year that starts in [startYear].
  ///
  /// When [startYear] is null the year containing the entity's local today
  /// is used. The whole read runs at repeatable-read isolation, so every
  /// line, wallet and rate comes from one committed snapshot even while a
  /// write is in flight. A missing rate fails the read with
  /// [FxRateUnavailableException] after requesting one backfill per date.
  ///
  /// A [systemOwner] replaces the session's authenticated user for one
  /// server-owned build, such as the export download serving a signed link;
  /// the ownership rule itself is unchanged.
  static Future<TaxSummaryView> build(
    Session session, {
    required UuidValue entityId,
    int? startYear,
    SystemEntityOwner? systemOwner,
  }) async => (await buildForExport(
    session,
    entityId: entityId,
    startYear: startYear,
    systemOwner: systemOwner,
  )).view;

  /// Builds the summary together with the provenance the export needs.
  ///
  /// Same read, same isolation and same ownership rule as [build]; the
  /// result adds the mapped entries with their position in the raw entry
  /// list, the conversion requests and rates behind them, and every
  /// in-period source line the query loaded.
  static Future<TaxSummaryComputation> buildForExport(
    Session session, {
    required UuidValue entityId,
    int? startYear,
    SystemEntityOwner? systemOwner,
  }) async {
    _log.info('Building tax summary entity=$entityId year=$startYear');

    try {
      return await session.db.transaction(
        (tx) async {
          final entity = await EntityAccess.requireOwned(
            session,
            entityId,
            transaction: tx,
            systemOwner: systemOwner,
          );
          final jurisdiction = TaxJurisdiction.fromCountryCode(
            entity.countryCode,
          );
          final pack = jurisdiction == null ? null : packFor(jurisdiction);
          // A pack country reports in the pack's currency; the universal
          // layer reports in the entity's own base currency.
          final currencyCode =
              pack?.jurisdiction.currencyCode ?? entity.baseCurrencyCode;
          final now = clock();
          final period = _resolvePeriod(entity, pack, startYear, now);

          final sourceLines =
              (await TaxService.loadTaxLines(
                session,
                {entity.id!},
                period.start,
                period.end,
                tx,
              ))[entity.id!] ??
              const <TaxEntrySourceLine>[];
          final requests = taxFxRequestsInPeriod(
            lines: sourceLines,
            periodStart: period.start,
            periodEnd: period.end,
            targetCurrencyCode: currencyCode,
          ).toList();
          final rates = await TaxService.loadTaxFxRates(
            session,
            requests,
            tx,
            targetCurrencyCode: currencyCode,
          );
          final missing = rates.missingFor(requests);
          if (missing.isNotEmpty) throw _MissingTaxRates(missing);

          final built = buildTaxEntriesInPeriod(
            lines: sourceLines,
            periodStart: period.start,
            periodEnd: period.end,
            rates: rates,
            targetCurrencyCode: currencyCode,
          );
          final fxGroups = _fxGroups(built.entries, requests, rates);

          var unmappedUniversalCount = 0;
          final entries = _mapUniversalEntries(
            built.entries,
            pack: pack,
            kind: entity.kind,
            onUnmapped: () => unmappedUniversalCount++,
          );

          final view = _toView(
            entity,
            [for (final (_, entry) in entries) entry],
            pack: pack,
            period: period,
            generatedAt: now,
            currencyCode: currencyCode,
            uncategorised: built.uncategorizedCount + unmappedUniversalCount,
            fxGroups: fxGroups.values.toList(),
            wallets: await _walletViews(session, entity, period, tx),
          );
          return TaxSummaryComputation(
            view: view,
            currencyCode: currencyCode,
            entries: [for (final (_, entry) in entries) entry],
            sourceIndexes: [for (final (index, _) in entries) index],
            fxRequests: requests,
            rates: rates,
            sourceLines: {
              for (final line in sourceLines) line.id.toString(): line,
            },
          );
        },
        settings: const TransactionSettings(
          isolationLevel: IsolationLevel.repeatableRead,
        ),
      );
    } on _MissingTaxRates catch (missing) {
      final dates = {for (final request in missing.requests) request.date};
      for (final date in dates.toList()..sort()) {
        await FxService.requestBackfill(session, date);
      }

      final first = missing.requests.first;
      throw FxRateUnavailableException(
        message:
            'No exchange rate is available to convert '
            '${first.fromCurrencyCode} to ${first.toCurrencyCode} on '
            '${first.date.toIso8601String()}.',
        fromCurrencyCode: first.fromCurrencyCode,
        toCurrencyCode: first.toCurrencyCode,
        date: first.date,
      );
    }
  }

  /// The year a summary for [entityId] covers when the caller gives none.
  ///
  /// The export link needs a year pinned into its token, so it resolves
  /// the default through this instead of guessing the rule twice.
  static Future<int> defaultStartYear(Session session, UuidValue entityId) =>
      session.db.transaction((tx) async {
        final entity = await EntityAccess.requireOwned(
          session,
          entityId,
          transaction: tx,
        );
        return currentStartYearFor(entity);
      });

  /// The start year a summary for [entity] covers today, on the server
  /// clock in the entity's own time zone.
  static int currentStartYearFor(Entity entity) =>
      startYearFor(entity, now: clock());

  /// The inclusive last day of the tax year [entity] is in today, on the
  /// server clock in the entity's own time zone.
  ///
  /// [period.end] is the half-open range's exclusive end, so the last
  /// calendar day is one day before it.
  static DateTime currentYearLastDayFor(Entity entity) {
    final now = clock();
    final jurisdiction = TaxJurisdiction.fromCountryCode(entity.countryCode);
    final pack = jurisdiction == null ? null : packFor(jurisdiction);
    final period = _resolvePeriod(entity, pack, null, now);
    return period.end.subtract(const Duration(days: 1));
  }

  /// Pure helper: the start year a summary for [entity] covers at [now],
  /// wrapping [_resolvePeriod] (docs/money-guide.md, section 5.3 clock).
  static int startYearFor(Entity entity, {required DateTime now}) {
    final jurisdiction = TaxJurisdiction.fromCountryCode(entity.countryCode);
    final pack = jurisdiction == null ? null : packFor(jurisdiction);
    return _resolvePeriod(entity, pack, null, now).startYear;
  }

  /// The summary period for [entity].
  ///
  /// A pack country uses the pack's tax year. Otherwise an individual uses
  /// the country's universal tax year and a company its own financial
  /// year, with the entity's financial year end as the fallback when the
  /// country data carries no tax year.
  static _SummaryPeriod _resolvePeriod(
    Entity entity,
    TaxRulePack? pack,
    int? startYear,
    DateTime now,
  ) {
    if (pack != null) {
      try {
        final year = startYear == null
            ? pack.taxYearFor(EntityClock.today(entity, now: now))
            : pack.taxYear(startYear);
        return _SummaryPeriod(
          startYear: year.startYear,
          start: year.start,
          end: year.end,
          label: year.label,
        );
      } on UnsupportedTaxYearException catch (error) {
        throw TaxRulesUnavailableException(message: error.toString());
      }
    }

    final country = Countries.byCode(entity.countryCode);
    final individualTaxYear = entity.kind == EntityKind.company
        ? null
        : country?.individualTaxYear;
    if (individualTaxYear != null) {
      final resolved = startYear ?? _yearContaining(now, individualTaxYear);
      final start = civilDate(
        resolved,
        individualTaxYear.startMonth,
        individualTaxYear.startDay,
      );
      final end = civilDate(
        resolved + 1,
        individualTaxYear.startMonth,
        individualTaxYear.startDay,
      );
      return _SummaryPeriod(
        startYear: resolved,
        start: start,
        end: end,
        label: _yearLabel(start, end, resolved),
      );
    }

    // The entity's financial year, from its own year end.
    final endMonth = entity.fiscalYearEndMonth;
    final endDay = entity.fiscalYearEndDay;
    final resolved = startYear ?? _fiscalYearContaining(now, endMonth, endDay);
    var start = civilDate(
      resolved - 1,
      endMonth,
      endDay,
    ).add(const Duration(days: 1));
    var end = civilDate(
      resolved,
      endMonth,
      endDay,
    ).add(const Duration(days: 1));
    if (start.isBefore(civilDate(resolved, 1, 1))) {
      // That year ends in the calendar year before [resolved]; the year
      // starting in [resolved] ends in the one after instead.
      start = civilDate(
        resolved,
        endMonth,
        endDay,
      ).add(const Duration(days: 1));
      end = civilDate(
        resolved + 1,
        endMonth,
        endDay,
      ).add(const Duration(days: 1));
    }
    return _SummaryPeriod(
      startYear: resolved,
      start: start,
      end: end,
      label: _yearLabel(start, end, resolved),
    );
  }

  /// The calendar year whose universal tax year contains [now].
  static int _yearContaining(DateTime now, IndividualTaxYear taxYear) {
    final startsThisYear = !DateTime.utc(
      now.year,
      now.month,
      now.day,
    ).isBefore(civilDate(now.year, taxYear.startMonth, taxYear.startDay));
    return startsThisYear ? now.year : now.year - 1;
  }

  /// The calendar year the financial year with the given year end starts
  /// in: the year that contains its last day minus one, which is its
  /// first.
  static int _fiscalYearContaining(DateTime now, int endMonth, int endDay) {
    final endThisYear = civilDate(now.year, endMonth, endDay);
    final endYear =
        !DateTime.utc(now.year, now.month, now.day).isAfter(endThisYear)
        ? now.year
        : now.year + 1;
    return endYear - 1;
  }

  /// `2026` for a calendar year, `2026/27` for any other shape.
  static String _yearLabel(DateTime start, DateTime end, int startYear) {
    if (start.month == 1 &&
        start.day == 1 &&
        end.month == 1 &&
        end.day == 1 &&
        end.year == startYear + 1) {
      return '$startYear';
    }
    return '$startYear/${((startYear + 1) % 100).toString().padLeft(2, '0')}';
  }

  /// Groups the converted lines by the quote each one used.
  ///
  /// [entries] and [requests] must come from the same builder call, so
  /// they are index-aligned: one entry and one request per included
  /// categorised line, in line order.
  static Map<(String, String, DateTime, FxRateSource), _FxGroup> _fxGroups(
    List<TaxEntry> entries,
    List<TaxFxRequest> requests,
    TaxFxRates rates,
  ) {
    final groups = <(String, String, DateTime, FxRateSource), _FxGroup>{};
    for (var index = 0; index < entries.length; index++) {
      final request = requests[index];
      if (request.isIdentity) continue;

      final quote = rates.quoteFor(request);
      if (quote == null) {
        // missingFor rejected the read before any conversion, so this
        // cannot happen; if it ever does, fail loudly rather than report
        // a rate the summary never used.
        throw StateError('A checked exchange rate vanished while grouping');
      }
      groups.putIfAbsent((
          request.fromCurrencyCode,
          quote.rateText,
          quote.rateDate,
          quote.source,
        ), () => _FxGroup(request.fromCurrencyCode, quote))
        ..lineCount += 1
        ..convertedMinor += entries[index].amountMinor;
    }
    return groups;
  }

  /// Maps universal category codes through [pack] for a pack country.
  ///
  /// The same rule the report path applies: a mapped entry keeps its
  /// figures under the pack's own code, and an entry whose universal code
  /// has no home in the pack is dropped and counted as uncategorised
  /// rather than land somewhere the pack's rules may not allow. Entries
  /// pass through unchanged when [pack] is null.
  ///
  /// Each result pair keeps the entry's index in [entries], so the export
  /// can look the entry's exchange-rate facts up in the pre-mapping
  /// request list.
  static List<(int, TaxEntry)> _mapUniversalEntries(
    List<TaxEntry> entries, {
    required TaxRulePack? pack,
    required EntityKind kind,
    required void Function() onUnmapped,
  }) {
    if (pack == null) {
      return [
        for (var index = 0; index < entries.length; index++)
          (index, entries[index]),
      ];
    }

    final mapped = <(int, TaxEntry)>[];
    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      final code = entry.categoryCode;
      if (!UniversalTaxCategories.isUniversalCode(code)) {
        mapped.add((index, entry));
        continue;
      }
      final packCode = pack.mapUniversalCategory(code, kind);
      if (packCode == null) {
        onUnmapped();
        continue;
      }
      if (packCode == code) {
        mapped.add((index, entry));
        continue;
      }
      mapped.add((
        index,
        TaxEntry(
          date: entry.date,
          amountMinor: entry.amountMinor,
          categoryCode: packCode,
          businessUsePercent: entry.businessUsePercent,
          salesTaxMinor: entry.salesTaxMinor,
          sourceId: entry.sourceId,
          note: entry.note,
        ),
      ));
    }
    return mapped;
  }

  /// Assembles the view from one entity's mapped entries.
  ///
  /// Business-use share applies wherever a line carries one, through
  /// [TaxEntry.allowableMinor]: amounts are net of any sales tax on the
  /// line and apportioned to business use, rounded down. A line's embedded
  /// sales tax contributes to the VAT sections at the same share, and a
  /// line whose category is itself a sales-tax category counts its whole
  /// apportioned amount as tax, at an unknown rate. A code the catalogue
  /// does not know counts as uncategorised, as the report path counts it.
  static TaxSummaryView _toView(
    Entity entity,
    List<TaxEntry> entries, {
    required TaxRulePack? pack,
    required _SummaryPeriod period,
    required DateTime generatedAt,
    required String currencyCode,
    required int uncategorised,
    required List<_FxGroup> fxGroups,
    required List<TaxSummaryWalletView> wallets,
  }) {
    final kind = entity.kind;
    final catalogue = pack == null
        ? UniversalTaxCategories.categoriesFor(kind)
        : pack.categoriesFor(kind);
    final kindByCode = <String, TaxCategoryKind>{};
    final labelByCode = <String, String>{};
    final order = <String, int>{};
    for (var index = 0; index < catalogue.length; index++) {
      final category = catalogue[index];
      kindByCode[category.code] = category.kind;
      labelByCode[category.code] = category.label;
      order[category.code] = index;
    }

    var uncategorizedCount = uncategorised;
    final income = _CategoryBucket();
    final expense = _CategoryBucket();
    final relief = _CategoryBucket();
    final taxPaid = _CategoryBucket();
    final byRate = <int?, _SalesTaxBucket>{};
    final quarters = List<_SalesTaxBucket>.generate(
      4,
      (_) => _SalesTaxBucket(),
    );
    var salesTaxCollectedMinor = 0;
    var salesTaxPaidMinor = 0;

    for (final entry in entries) {
      final categoryKind = kindByCode[entry.categoryCode];
      if (categoryKind == null) {
        uncategorizedCount++;
        continue;
      }

      final apportioned = entry.allowableMinor;
      switch (categoryKind) {
        case TaxCategoryKind.income:
        case TaxCategoryKind.disposalProceeds:
          income.add(entry.categoryCode, apportioned);
        case TaxCategoryKind.expense:
        case TaxCategoryKind.disposalCost:
          expense.add(entry.categoryCode, apportioned);
        case TaxCategoryKind.relief:
          relief.add(entry.categoryCode, apportioned);
        case TaxCategoryKind.taxPaid:
          taxPaid.add(entry.categoryCode, apportioned);
        case TaxCategoryKind.salesTaxCollected:
          salesTaxCollectedMinor += _recordSalesTax(
            byRate,
            quarters,
            period,
            entry,
            collectedMinor: apportioned,
          );
        case TaxCategoryKind.salesTaxPaid:
          salesTaxPaidMinor += _recordSalesTax(
            byRate,
            quarters,
            period,
            entry,
            paidMinor: apportioned,
          );
        case TaxCategoryKind.outOfScope:
          break;
      }

      final salesTaxMinor = entry.salesTaxMinor;
      if (salesTaxMinor > 0) {
        final direction = switch (categoryKind) {
          TaxCategoryKind.income ||
          TaxCategoryKind.disposalProceeds => _SalesTaxDirection.collected,
          TaxCategoryKind.expense ||
          TaxCategoryKind.disposalCost => _SalesTaxDirection.paid,
          _ => null,
        };
        if (direction != null) {
          // The rate is a property of the line, so it comes from the
          // unapportioned tax over its net amount.
          final net = entry.amountMinor - salesTaxMinor;
          final apportionedTax =
              salesTaxMinor * entry.businessUsePercent ~/ 100;
          final recorded = _recordSalesTax(
            byRate,
            quarters,
            period,
            entry,
            collectedMinor: direction == _SalesTaxDirection.collected
                ? apportionedTax
                : 0,
            paidMinor: direction == _SalesTaxDirection.paid
                ? apportionedTax
                : 0,
            ratePerMillion: net > 0
                ? _derivedRatePerMillion(salesTaxMinor, net)
                : null,
          );
          if (direction == _SalesTaxDirection.collected) {
            salesTaxCollectedMinor += recorded;
          } else {
            salesTaxPaidMinor += recorded;
          }
        }
      }
    }

    List<TaxSummaryCategoryTotalView> categoryViews(_CategoryBucket bucket) {
      final codes = bucket.totals.keys.toList()
        ..sort((a, b) {
          final byOrder = (order[a] ?? catalogue.length).compareTo(
            order[b] ?? catalogue.length,
          );
          if (byOrder != 0) return byOrder;
          return a.compareTo(b);
        });
      return [
        for (final code in codes)
          TaxSummaryCategoryTotalView(
            categoryCode: code,
            label: labelByCode[code] ?? code,
            totalMinor: bucket.totals[code]!.totalMinor,
            entryCount: bucket.totals[code]!.entryCount,
          ),
      ];
    }

    final incomeTotals = categoryViews(income);
    final expenseTotals = categoryViews(expense);
    final reliefTotals = categoryViews(relief);
    final taxPaidTotals = categoryViews(taxPaid);

    final rateKeys = byRate.keys.toList()
      ..sort((a, b) {
        if (a == null) return b == null ? 0 : 1;
        if (b == null) return -1;
        return a.compareTo(b);
      });
    final salesTaxByRate = [
      for (final rate in rateKeys)
        TaxSummarySalesTaxRateView(
          ratePerMillion: rate,
          collectedMinor: byRate[rate]!.collectedMinor,
          paidMinor: byRate[rate]!.paidMinor,
        ),
    ];

    final salesTaxByQuarter = <TaxSummarySalesTaxQuarterView>[];
    for (var quarter = 0; quarter < quarters.length; quarter++) {
      final bucket = quarters[quarter];
      if (bucket.collectedMinor == 0 && bucket.paidMinor == 0) continue;
      var quarterEnd = DateTime.utc(
        period.start.year,
        period.start.month + 3 * (quarter + 1),
        period.start.day,
      );
      if (quarterEnd.isAfter(period.end)) quarterEnd = period.end;
      salesTaxByQuarter.add(
        TaxSummarySalesTaxQuarterView(
          label: 'Q${quarter + 1}',
          periodStart: DateTime.utc(
            period.start.year,
            period.start.month + 3 * quarter,
            period.start.day,
          ),
          periodEnd: quarterEnd,
          collectedMinor: bucket.collectedMinor,
          paidMinor: bucket.paidMinor,
        ),
      );
    }

    final fxNotes =
        [
          for (final group in fxGroups)
            TaxSummaryFxNoteView(
              currencyCode: group.sourceCurrencyCode,
              fxRate: group.quote.rateText,
              fxRateDate: group.quote.rateDate,
              fxRateSource: group.quote.source,
              isStale: group.quote.isStale,
              lineCount: group.lineCount,
              convertedMinor: group.convertedMinor,
            ),
        ]..sort((a, b) {
          final byCurrency = a.currencyCode.compareTo(b.currencyCode);
          if (byCurrency != 0) return byCurrency;
          final byDate = a.fxRateDate.compareTo(b.fxRateDate);
          if (byDate != 0) return byDate;
          return a.fxRate.compareTo(b.fxRate);
        });
    final rateSourcesUsed =
        fxGroups.map((group) => group.quote.source.name).toSet().toList()
          ..sort();

    return TaxSummaryView(
      entityId: entity.id!,
      entityKind: kind,
      countryCode: entity.countryCode.toUpperCase(),
      currencyCode: currencyCode,
      startYear: period.startYear,
      yearLabel: period.label,
      yearStart: period.start,
      yearEnd: period.end,
      generatedAt: generatedAt,
      isUniversal: pack == null,
      rulesVersion: pack
          ?.ruleSet(period.startYear)
          .versionFor(pack.jurisdiction),
      rulesVerifiedOn: pack == null
          ? Countries.byCode(entity.countryCode)?.verifiedOn
          : pack.ruleSet(period.startYear).verifiedOn,
      disclaimerKey: disclaimerKey,
      incomeTotals: incomeTotals,
      expenseTotals: expenseTotals,
      reliefTotals: reliefTotals,
      taxPaidTotals: taxPaidTotals,
      totalIncomeMinor: incomeTotals.fold(
        0,
        (sum, total) => sum + total.totalMinor,
      ),
      totalExpenseMinor: expenseTotals.fold(
        0,
        (sum, total) => sum + total.totalMinor,
      ),
      totalReliefMinor: reliefTotals.fold(
        0,
        (sum, total) => sum + total.totalMinor,
      ),
      totalTaxPaidMinor: taxPaidTotals.fold(
        0,
        (sum, total) => sum + total.totalMinor,
      ),
      salesTaxCollectedMinor: salesTaxCollectedMinor,
      salesTaxPaidMinor: salesTaxPaidMinor,
      salesTaxByRate: salesTaxByRate,
      salesTaxByQuarter: salesTaxByQuarter,
      wallets: wallets,
      fxNotes: fxNotes,
      rateSourcesUsed: rateSourcesUsed,
      uncategorizedCount: uncategorizedCount,
    );
  }

  /// Adds [collectedMinor] and [paidMinor] to the rate and quarter
  /// buckets, and returns the total added.
  static int _recordSalesTax(
    Map<int?, _SalesTaxBucket> byRate,
    List<_SalesTaxBucket> quarters,
    _SummaryPeriod period,
    TaxEntry entry, {
    int collectedMinor = 0,
    int paidMinor = 0,
    int? ratePerMillion,
  }) {
    if (collectedMinor == 0 && paidMinor == 0) return 0;

    byRate.putIfAbsent(ratePerMillion, _SalesTaxBucket.new)
      ..collectedMinor += collectedMinor
      ..paidMinor += paidMinor;
    quarters[_quarterIndexOf(entry.date, period.start)]
      ..collectedMinor += collectedMinor
      ..paidMinor += paidMinor;
    return collectedMinor + paidMinor;
  }

  /// The rate [taxMinor] implies over [netMinor], in millionths of the
  /// taxed amount — the same unit as `IndirectTaxRate.ratePerMillion`.
  ///
  /// A derived ratio of two minor-unit amounts is still inexact at any
  /// fixed precision: the tax side is a whole minor unit, so a true
  /// 9.975% rate on a £100 line implies £9.975 and stores £9.98. To
  /// keep that error bounded the rule is round half away from zero at
  /// the millionth. The scaling runs in BigInt arithmetic so the
  /// product never overflows for safe minor-unit amounts; at this
  /// precision the derivation is one BigInt multiply per line with
  /// embedded tax.
  static int _derivedRatePerMillion(int taxMinor, int netMinor) {
    final scaled = BigInt.from(taxMinor.abs()) * BigInt.from(1000000);
    final net = BigInt.from(netMinor);
    final magnitude = (scaled * BigInt.two + net) ~/ (net * BigInt.two);
    return (taxMinor.isNegative ? -magnitude : magnitude).toInt();
  }

  /// The quarter of the summary period a civil date falls in.
  static int _quarterIndexOf(DateTime date, DateTime start) {
    final months = (date.year - start.year) * 12 + date.month - start.month;
    final quarter = months ~/ 3;
    if (quarter < 0) return 0;
    if (quarter > 3) return 3;
    return quarter;
  }

  /// The wallet section: stored FIFO estimates per wallet and P&L
  /// currency, dated inside the period in the entity's own time zone.
  ///
  /// A transaction whose stored estimates are all absent has no valuation;
  /// it is counted in the row's caveats and never invented.
  static Future<List<TaxSummaryWalletView>> _walletViews(
    Session session,
    Entity entity,
    _SummaryPeriod period,
    Transaction tx,
  ) async {
    final wallets = await Wallet.db.find(
      session,
      where: (t) => t.entityId.equals(entity.id),
      transaction: tx,
    );
    if (wallets.isEmpty) return const [];

    final rows = await WalletTransaction.db.find(
      session,
      where: (t) =>
          t.walletId.inSet({for (final wallet in wallets) wallet.id!}),
      transaction: tx,
    );
    final location = EntityClock.location(entity.timeZone);
    final buckets = <(UuidValue, String), _WalletBucket>{};
    final unpriced = <UuidValue, int>{};
    for (final row in rows) {
      final currency = row.pnlCurrencyCode?.trim().toUpperCase();
      final occurredAt = row.occurredAt;
      if (currency == null || currency.isEmpty || occurredAt == null) {
        continue;
      }
      final local = tz.TZDateTime.from(occurredAt.toUtc(), location);
      final day = DateTime.utc(local.year, local.month, local.day);
      if (day.isBefore(period.start) || !day.isBefore(period.end)) continue;

      if (row.costBasisMinor == null &&
          row.proceedsMinor == null &&
          row.realizedPnlMinor == null) {
        unpriced[row.walletId] = (unpriced[row.walletId] ?? 0) + 1;
        continue;
      }
      buckets.putIfAbsent((row.walletId, currency), _WalletBucket.new)
        ..transactionCount += 1
        ..proceeds += BigInt.from(row.proceedsMinor ?? 0)
        ..costBasis += BigInt.from(row.costBasisMinor ?? 0)
        ..realized += BigInt.from(row.realizedPnlMinor ?? 0);
    }

    final walletsById = {for (final wallet in wallets) wallet.id!: wallet};
    String walletName(UuidValue walletId) => walletsById[walletId]?.label ?? '';
    final keys = buckets.keys.toList()
      ..sort((a, b) {
        final byWallet = walletName(a.$1).compareTo(walletName(b.$1));
        if (byWallet != 0) return byWallet;
        final byId = a.$1.uuid.compareTo(b.$1.uuid);
        if (byId != 0) return byId;
        return a.$2.compareTo(b.$2);
      });

    final views = <TaxSummaryWalletView>[];
    for (final (walletId, currency) in keys) {
      final bucket = buckets[(walletId, currency)]!;
      final caveats = [_walletMethodCaveat];
      final unpricedCount = unpriced[walletId] ?? 0;
      if (unpricedCount > 0) {
        final noun = unpricedCount == 1 ? 'transaction' : 'transactions';
        final verb = unpricedCount == 1 ? 'has' : 'have';
        caveats.add(
          '$unpricedCount wallet $noun in the period $verb no stored '
          'valuation and $verb not been counted.',
        );
      }
      views.add(
        TaxSummaryWalletView(
          walletId: walletId,
          label: walletsById[walletId]?.label,
          currencyCode: currency,
          transactionCount: bucket.transactionCount,
          proceedsMinor: _safeMinor(bucket.proceeds, 'proceeds'),
          costBasisMinor: _safeMinor(bucket.costBasis, 'cost basis'),
          gainMinor: _safeMinor(bucket.realized, 'realised gain'),
          costBasisMethod: _walletCostBasisMethod,
          caveats: caveats,
        ),
      );
    }
    return views;
  }

  /// Rejects a sum that escaped the web-safe integer range.
  static int _safeMinor(BigInt value, String what) {
    if (value > BigInt.from(maxSafeMinor) ||
        value < BigInt.from(-maxSafeMinor)) {
      throw ValidationException(
        message: 'Wallet $what exceeds the safe minor-unit range.',
      );
    }
    return value.toInt();
  }
}
