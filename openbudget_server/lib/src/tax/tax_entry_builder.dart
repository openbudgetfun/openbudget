import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/tax/tax_catalogue_validation.dart';
import 'package:openbudget_server/src/tax/tax_fx_rates.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;

/// One stored transaction line reduced to what a tax entry needs.
///
/// A transaction header supplies the date and description; the line supplies
/// the signed amount, its account currency and its tax treatment. The envelope
/// code is carried separately so a line override can win without a second
/// lookup.
class TaxEntrySourceLine {
  const TaxEntrySourceLine({
    required this.id,
    required this.date,
    required this.description,
    required this.currencyCode,
    required this.amountMinor,
    required this.envelopeTaxCategoryCode,
    this.salesTaxMinor,
    this.businessUsePercent,
    this.taxCategoryCode,
    this.envelopeName,
    this.payeeName,
    this.isTransfer = false,
  });

  final UuidValue id;

  /// Civil date of the transaction header.
  final DateTime date;

  /// Transaction header description, shown with the entry.
  final String description;

  /// Account currency of [amountMinor].
  final String currencyCode;

  /// Signed amount in the account currency's minor units.
  final int amountMinor;

  /// Sales tax included in [amountMinor], same sign.
  final int? salesTaxMinor;

  /// Share of the line used for business, 0-100.
  final int? businessUsePercent;

  /// The line's own tax category, which overrides the envelope default.
  final String? taxCategoryCode;

  /// The envelope's default tax category.
  final String? envelopeTaxCategoryCode;

  /// The envelope the line is assigned to, for the export's envelope column.
  final String? envelopeName;

  /// The transaction's payee, for the export's payee column.
  final String? payeeName;

  /// A transfer leg is outside tax, as it always was.
  final bool isTransfer;
}

/// What one entity's lines contribute to a tax input.
class TaxEntryBuildResult {
  const TaxEntryBuildResult({
    required this.entries,
    required this.uncategorizedCount,
    required this.convertedCount,
  });

  /// The entries dated inside the tax year, in the report's currency.
  final List<TaxEntry> entries;

  /// Categorized-in-year lines that carry no tax category.
  final int uncategorizedCount;

  /// Entries whose amount was converted from another currency.
  final int convertedCount;
}

/// The conversion requests one entity's in-year categorized lines need.
///
/// Identity requests are included so the caller submits one uniform batch;
/// [TaxFxRates.missingFor] skips them without reading a rate.
Iterable<TaxFxRequest> taxFxRequestsFor({
  required Iterable<TaxEntrySourceLine> lines,
  required TaxYear year,
  required String targetCurrencyCode,
}) => taxFxRequestsInPeriod(
  lines: lines,
  periodStart: year.start,
  periodEnd: year.end,
  targetCurrencyCode: targetCurrencyCode,
);

/// The conversion requests for the half-open period `[periodStart,
/// periodEnd)`.
///
/// Same rules as [taxFxRequestsFor], for callers whose period is not a
/// rule pack's [TaxYear], such as the universal-layer summary.
Iterable<TaxFxRequest> taxFxRequestsInPeriod({
  required Iterable<TaxEntrySourceLine> lines,
  required DateTime periodStart,
  required DateTime periodEnd,
  required String targetCurrencyCode,
}) sync* {
  for (final line in lines) {
    if (!_inPeriod(line, periodStart, periodEnd)) continue;
    if (_categoryCode(line) == null) continue;

    yield TaxFxRequest(
      fromCurrencyCode: line.currencyCode,
      toCurrencyCode: targetCurrencyCode,
      date: line.date,
    );
  }
}

/// Turns one entity's stored transaction lines into tax entries for [year].
///
/// One entry is produced per line. Transfers are skipped, the line's own
/// category overrides its envelope's default, and a line without either is
/// counted rather than invented. Amounts are converted exactly once from the
/// account currency into the jurisdiction's currency.
TaxEntryBuildResult buildTaxEntries({
  required List<TaxEntrySourceLine> lines,
  required TaxYear year,
  required TaxFxRates rates,
  required String targetCurrencyCode,
}) => buildTaxEntriesInPeriod(
  lines: lines,
  periodStart: year.start,
  periodEnd: year.end,
  rates: rates,
  targetCurrencyCode: targetCurrencyCode,
);

/// The same reduction for the half-open period `[periodStart, periodEnd)`.
///
/// Used where the period is not a rule pack's [TaxYear], such as the
/// universal-layer summary, so a report and a summary share one entry
/// builder.
TaxEntryBuildResult buildTaxEntriesInPeriod({
  required List<TaxEntrySourceLine> lines,
  required DateTime periodStart,
  required DateTime periodEnd,
  required TaxFxRates rates,
  required String targetCurrencyCode,
}) {
  final entries = <TaxEntry>[];
  var uncategorizedCount = 0;
  var convertedCount = 0;

  for (final line in lines) {
    if (!_inPeriod(line, periodStart, periodEnd)) continue;

    final categoryCode = _categoryCode(line);
    if (categoryCode == null) {
      uncategorizedCount++;
      continue;
    }

    final converted = line.currencyCode != targetCurrencyCode;
    entries.add(
      TaxEntry(
        date: line.date,
        amountMinor: rates.convert(
          amountMinor: line.amountMinor.abs(),
          fromCurrencyCode: line.currencyCode,
          toCurrencyCode: targetCurrencyCode,
          date: line.date,
        ),
        categoryCode: categoryCode,
        businessUsePercent: line.businessUsePercent ?? 100,
        salesTaxMinor: _convertSalesTax(
          line,
          rates: rates,
          targetCurrencyCode: targetCurrencyCode,
        ),
        sourceId: line.id.toString(),
        note: line.description,
      ),
    );
    if (converted) convertedCount++;
  }

  return TaxEntryBuildResult(
    entries: entries,
    uncategorizedCount: uncategorizedCount,
    convertedCount: convertedCount,
  );
}

/// Whether a line can contribute to the period at all.
///
/// Out-of-period lines are skipped before category counting, so moving a
/// transaction outside the period removes it from every figure without
/// leaving an uncategorized marker behind. The date is normalised to UTC
/// midnight exactly as [TaxYear.contains] does, so a [TaxYear] and its own
/// start and end select the same lines.
bool _inPeriod(TaxEntrySourceLine line, DateTime start, DateTime end) {
  if (line.isTransfer) return false;
  final day = DateTime.utc(line.date.year, line.date.month, line.date.day);
  return !day.isBefore(start) && day.isBefore(end);
}

String? _categoryCode(TaxEntrySourceLine line) =>
    TaxCatalogueValidation.normalise(line.taxCategoryCode) ??
    TaxCatalogueValidation.normalise(line.envelopeTaxCategoryCode);

int _convertSalesTax(
  TaxEntrySourceLine line, {
  required TaxFxRates rates,
  required String targetCurrencyCode,
}) {
  final salesTaxMinor = line.salesTaxMinor;
  if (salesTaxMinor == null || salesTaxMinor == 0) return 0;

  return rates.convert(
    amountMinor: salesTaxMinor.abs(),
    fromCurrencyCode: line.currencyCode,
    toCurrencyCode: targetCurrencyCode,
    date: line.date,
  );
}
