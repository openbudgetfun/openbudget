import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/fx_rates/fx_quote_selection.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/tax/tax_entry_builder.dart';
import 'package:openbudget_server/src/tax/tax_fx_rates.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

final _year = TaxYear(
  jurisdiction: TaxJurisdiction.gb,
  startYear: 2026,
  start: DateTime.utc(2026, 4, 6),
  end: DateTime.utc(2027, 4, 6),
  label: '2026/27',
);

UuidValue _id(int suffix) => UuidValue.fromString(
  '00000000-0000-4000-8000-${suffix.toString().padLeft(12, '0')}',
);

TaxFxRates _rates({bool withGbp = true}) => TaxFxRates(
  rates: [
    FxDailyRate(
      currencyCode: 'USD',
      rateDate: DateTime.utc(2026, 5, 9),
      rate: '1',
      fetchedAt: DateTime.utc(2026, 5, 9, 2),
    ),
    if (withGbp)
      FxDailyRate(
        currencyCode: 'GBP',
        rateDate: DateTime.utc(2026, 5, 9),
        rate: '0.8',
        fetchedAt: DateTime.utc(2026, 5, 9, 2),
      ),
  ],
  evaluatedAt: DateTime.utc(2026, 5, 10),
);

TaxEntrySourceLine _line({
  int id = 1,
  DateTime? date,
  String description = 'Transaction',
  String currencyCode = 'GBP',
  int amountMinor = -10000,
  String? taxCategoryCode,
  String? envelopeTaxCategoryCode,
  int? businessUsePercent,
  int? salesTaxMinor,
  bool isTransfer = false,
}) => TaxEntrySourceLine(
  id: _id(id),
  date: date ?? DateTime.utc(2026, 5, 10),
  description: description,
  currencyCode: currencyCode,
  amountMinor: amountMinor,
  taxCategoryCode: taxCategoryCode,
  envelopeTaxCategoryCode: envelopeTaxCategoryCode,
  businessUsePercent: businessUsePercent,
  salesTaxMinor: salesTaxMinor,
  isTransfer: isTransfer,
);

TaxEntryBuildResult _build(
  List<TaxEntrySourceLine> lines, {
  TaxFxRates? rates,
}) => buildTaxEntries(
  lines: lines,
  year: _year,
  rates: rates ?? _rates(),
  targetCurrencyCode: 'GBP',
);

void main() {
  group('Given tax entries are built from stored transaction lines', () {
    test('when a transaction has several lines then each gets one entry', () {
      final result = _build([
        _line(
          amountMinor: -4000,
          taxCategoryCode: 'gb.ind.self_employment',
        ),
        _line(
          id: 2,
          amountMinor: -6000,
          taxCategoryCode: 'gb.ind.self_employment',
        ),
      ]);

      expect(result.entries, hasLength(2));
      expect(result.entries.map((entry) => entry.amountMinor), [4000, 6000]);
      expect(
        result.entries.map((entry) => entry.sourceId),
        [_id(1).toString(), _id(2).toString()],
      );
      expect(result.uncategorizedCount, 0);
    });

    test('when both codes exist then the line category wins', () {
      final result = _build([
        _line(
          envelopeTaxCategoryCode: 'gb.ind.self_employment',
          taxCategoryCode: 'gb.ind.employment',
        ),
      ]);

      expect(result.entries.single.categoryCode, 'gb.ind.employment');
    });

    test('when the line has no code then the envelope default applies', () {
      final result = _build([
        _line(envelopeTaxCategoryCode: 'gb.ind.self_employment'),
      ]);

      expect(result.entries.single.categoryCode, 'gb.ind.self_employment');
    });

    test('when neither side has a code then only a counter moves', () {
      final result = _build([_line()]);

      expect(result.entries, isEmpty);
      expect(result.uncategorizedCount, 1);
    });

    test('when a leg is a transfer then it is outside tax', () {
      final result = _build([
        _line(
          taxCategoryCode: 'gb.ind.self_employment',
          isTransfer: true,
        ),
      ]);

      expect(result.entries, isEmpty);
      expect(result.uncategorizedCount, 0);
      expect(
        taxFxRequestsFor(
          lines: [
            _line(
              currencyCode: 'USD',
              taxCategoryCode: 'gb.ind.self_employment',
              isTransfer: true,
            ),
          ],
          year: _year,
          targetCurrencyCode: 'GBP',
        ),
        isEmpty,
      );
    });

    test('when a line is outside the year then it is skipped before all '
        'counters', () {
      final result = _build([
        _line(date: _year.start.subtract(const Duration(days: 1))),
        _line(date: _year.end),
        _line(
          date: _year.start,
          taxCategoryCode: 'gb.ind.self_employment',
        ),
        _line(
          date: _year.end.subtract(const Duration(days: 1)),
          taxCategoryCode: 'gb.ind.self_employment',
        ),
      ]);

      expect(result.entries, hasLength(2));
      expect(result.uncategorizedCount, 0);
      expect(
        result.entries.map((entry) => entry.date),
        [_year.start, _year.end.subtract(const Duration(days: 1))],
      );
    });

    test('when business use and sales tax are stored then both pass through '
        'exactly', () {
      final result = _build([
        _line(
          amountMinor: -12345,
          businessUsePercent: 50,
          salesTaxMinor: -2000,
          taxCategoryCode: 'gb.ind.self_employment',
          description: 'Mixed-use receipt',
        ),
      ]);

      final entry = result.entries.single;
      expect(entry.amountMinor, 12345);
      expect(entry.businessUsePercent, 50);
      expect(entry.salesTaxMinor, 2000);
      expect(entry.allowableMinor, 5172);
      expect(entry.note, 'Mixed-use receipt');
    });

    test('when a line is in another currency then it is converted once', () {
      final result = _build([
        _line(
          currencyCode: 'USD',
          amountMinor: -12500,
          taxCategoryCode: 'gb.ind.self_employment',
        ),
        _line(
          id: 2,
          amountMinor: -8000,
          taxCategoryCode: 'gb.ind.self_employment',
        ),
      ]);

      expect(result.entries.map((entry) => entry.amountMinor), [10000, 8000]);
      expect(result.convertedCount, 1);
    });

    test('when sales tax is in another currency then it is converted once', () {
      final result = _build([
        _line(
          currencyCode: 'USD',
          amountMinor: -12500,
          salesTaxMinor: -2500,
          taxCategoryCode: 'gb.ind.self_employment',
        ),
      ]);

      expect(result.entries.single.amountMinor, 10000);
      expect(result.entries.single.salesTaxMinor, 2000);
    });

    test('when a request has no rate then building fails explicitly', () {
      expect(
        () => _build(
          [
            _line(
              currencyCode: 'USD',
              taxCategoryCode: 'gb.ind.self_employment',
            ),
          ],
          rates: _rates(withGbp: false),
        ),
        throwsA(isA<FxRateUnavailableException>()),
      );
    });
  });
}
