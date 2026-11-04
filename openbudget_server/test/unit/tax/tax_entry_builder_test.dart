import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/tax/tax_entry_builder.dart';
import 'package:openbudget_server/src/tax/tax_fx_rates.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;
import 'package:test/test.dart';

import '../../support/tax_fake_pack.dart';

final _budgetId = UuidValue.fromString(
  '11111111-1111-4111-8111-111111111111',
);
final _categoryId = UuidValue.fromString(
  '22222222-2222-4222-8222-222222222222',
);
final _envelopeId = UuidValue.fromString(
  '33333333-3333-4333-8333-333333333333',
);

final _year = TaxYear(
  jurisdiction: TaxJurisdiction.gb,
  startYear: 2026,
  start: DateTime.utc(2026),
  end: DateTime.utc(2027),
  label: '2026/27',
);

Envelope _envelope({
  UuidValue? id,
  String? taxCategoryCode,
}) => Envelope(
  id: id ?? _envelopeId,
  name: 'Envelope',
  categoryId: _categoryId,
  budgetedAmountCents: 0,
  spentAmountCents: 0,
  currencyCode: 'GBP',
  sortOrder: 0,
  taxCategoryCode: taxCategoryCode,
);

Transaction _transaction({
  UuidValue? id,
  String description = 'Transaction',
  int amountCents = -10000,
  String currencyCode = 'GBP',
  UuidValue? envelopeId,
  DateTime? transactionDate,
  UuidValue? transferPairId,
  UuidValue? parentTransactionId,
  String? taxCategoryCode,
  int? businessUsePercent,
  int? salesTaxCents,
}) => Transaction(
  id: id,
  description: description,
  amountCents: amountCents,
  currencyCode: currencyCode,
  budgetId: _budgetId,
  envelopeId: envelopeId,
  transactionDate: transactionDate ?? DateTime.utc(2026, 1, 15),
  transferPairId: transferPairId,
  parentTransactionId: parentTransactionId,
  taxCategoryCode: taxCategoryCode,
  businessUsePercent: businessUsePercent,
  salesTaxCents: salesTaxCents,
);

TaxFxRates _rates() => TaxFxRates([
  TaxFxSnapshotRates(
    baseCurrencyCode: 'USD',
    fetchedAt: DateTime.utc(2026, 1, 10),
    rates: const {'USD': 1, 'GBP': 0.8, 'EUR': 0.9},
  ),
  TaxFxSnapshotRates(
    baseCurrencyCode: 'USD',
    fetchedAt: DateTime.utc(2026, 2, 10),
    rates: const {'USD': 1, 'GBP': 0.9},
  ),
]);

void main() {
  group('Given tax entries are built from transactions', () {
    test(
      'when both set then the transaction category wins over the envelope',
      () {
        final envelope = _envelope(
          taxCategoryCode: FakeTaxPack.officeCosts.code,
        );
        final transactions = [
          _transaction(
            id: UuidValue.fromString('55555555-5555-4555-8555-555555555555'),
            envelopeId: envelope.id,
          ),
          _transaction(
            id: UuidValue.fromString('66666666-6666-4666-8666-666666666666'),
            amountCents: -5000,
            envelopeId: envelope.id,
            taxCategoryCode: FakeTaxPack.turnover.code,
          ),
        ];

        final result = buildTaxEntries(
          transactions: transactions,
          envelopesById: {envelope.id!: envelope},
          year: _year,
          rates: _rates(),
          targetCurrencyCode: 'GBP',
        );

        expect(result.entries, hasLength(2));
        expect(result.entries[0].categoryCode, FakeTaxPack.officeCosts.code);
        expect(result.entries[0].amountMinor, 10000);
        expect(result.entries[1].categoryCode, FakeTaxPack.turnover.code);
        expect(result.uncategorizedCount, 0);
        expect(result.convertedCount, 0);
      },
    );

    test(
      'when transfers and split parents are present then neither is taxed',
      () {
        final parentId = UuidValue.fromString(
          '77777777-7777-4777-8777-777777777777',
        );
        final transfer = _transaction(
          id: UuidValue.fromString('88888888-8888-4888-8888-888888888888'),
          amountCents: -30000,
          envelopeId: _envelopeId,
          transferPairId: UuidValue.fromString(
            '99999999-9999-4999-8999-999999999999',
          ),
          taxCategoryCode: FakeTaxPack.officeCosts.code,
        );
        final parent = _transaction(
          id: parentId,
          amountCents: -20000,
          envelopeId: _envelopeId,
          taxCategoryCode: FakeTaxPack.officeCosts.code,
        );
        final children = [
          _transaction(
            id: UuidValue.fromString('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'),
            amountCents: -12000,
            envelopeId: _envelopeId,
            parentTransactionId: parentId,
            taxCategoryCode: FakeTaxPack.officeCosts.code,
          ),
          _transaction(
            id: UuidValue.fromString('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'),
            amountCents: -8000,
            envelopeId: _envelopeId,
            parentTransactionId: parentId,
            taxCategoryCode: FakeTaxPack.officeCosts.code,
          ),
        ];
        final envelope = _envelope(
          taxCategoryCode: FakeTaxPack.officeCosts.code,
        );

        final result = buildTaxEntries(
          transactions: [transfer, parent, ...children],
          envelopesById: {envelope.id!: envelope},
          year: _year,
          rates: _rates(),
          targetCurrencyCode: 'GBP',
        );

        expect(result.entries, hasLength(2));
        expect(result.entries.map((entry) => entry.amountMinor), [12000, 8000]);
        expect(result.uncategorizedCount, 0);
      },
    );

    test('when a transaction has no category then it is only counted', () {
      final envelope = _envelope();
      final result = buildTaxEntries(
        transactions: [
          _transaction(
            id: UuidValue.fromString('cccccccc-cccc-4ccc-8ccc-cccccccccccc'),
          ),
          _transaction(
            id: UuidValue.fromString('dddddddd-dddd-4ddd-8ddd-dddddddddddd'),
            envelopeId: envelope.id,
          ),
        ],
        envelopesById: {envelope.id!: envelope},
        year: _year,
        rates: _rates(),
        targetCurrencyCode: 'GBP',
      );

      expect(result.entries, isEmpty);
      expect(result.uncategorizedCount, 2);
    });

    test('when the transaction is outside the tax year then it is skipped', () {
      final envelope = _envelope(taxCategoryCode: FakeTaxPack.turnover.code);
      final result = buildTaxEntries(
        transactions: [
          _transaction(
            envelopeId: envelope.id,
            transactionDate: DateTime.utc(2025, 12, 31),
          ),
          _transaction(
            envelopeId: envelope.id,
            transactionDate: DateTime.utc(2027),
          ),
        ],
        envelopesById: {envelope.id!: envelope},
        year: _year,
        rates: _rates(),
        targetCurrencyCode: 'GBP',
      );

      expect(result.entries, isEmpty);
      expect(result.uncategorizedCount, 0);
    });

    test('when business use and sales tax are set then both pass through', () {
      final envelope = _envelope(taxCategoryCode: FakeTaxPack.turnover.code);
      final result = buildTaxEntries(
        transactions: [
          _transaction(
            amountCents: -12345,
            envelopeId: envelope.id,
            businessUsePercent: 50,
            salesTaxCents: 2000,
            description: 'Mixed-use receipt',
          ),
        ],
        envelopesById: {envelope.id!: envelope},
        year: _year,
        rates: _rates(),
        targetCurrencyCode: 'GBP',
      );

      final entry = result.entries.single;
      expect(entry.amountMinor, 12345);
      expect(entry.businessUsePercent, 50);
      expect(entry.salesTaxMinor, 2000);
      expect(entry.allowableMinor, 5172);
      expect(entry.note, 'Mixed-use receipt');
    });

    test('when a transaction is in another currency then it is converted', () {
      final envelope = _envelope(taxCategoryCode: FakeTaxPack.turnover.code);
      final result = buildTaxEntries(
        transactions: [
          _transaction(
            currencyCode: 'USD',
            envelopeId: envelope.id,
            transactionDate: DateTime.utc(2026, 1, 15),
          ),
          _transaction(
            amountCents: -8000,
            envelopeId: envelope.id,
            transactionDate: DateTime.utc(2026, 1, 16),
          ),
        ],
        envelopesById: {envelope.id!: envelope},
        year: _year,
        rates: _rates(),
        targetCurrencyCode: 'GBP',
      );

      expect(result.entries.map((entry) => entry.amountMinor), [8000, 8000]);
      expect(result.convertedCount, 1);
    });
  });

  group('Given FX snapshots', () {
    test('when converting in either direction then rates are divided', () {
      final rates = _rates();
      final date = DateTime.utc(2026, 1, 20);

      expect(
        rates.convert(
          amountMinor: 10000,
          fromCurrencyCode: 'USD',
          toCurrencyCode: 'GBP',
          date: date,
        ),
        8000,
      );
      expect(
        rates.convert(
          amountMinor: 8000,
          fromCurrencyCode: 'GBP',
          toCurrencyCode: 'USD',
          date: date,
        ),
        10000,
      );
      expect(
        rates.convert(
          amountMinor: 8000,
          fromCurrencyCode: 'GBP',
          toCurrencyCode: 'EUR',
          date: date,
        ),
        9000,
      );
    });

    test('when a snapshot predates the date then the latest one wins', () {
      final rates = _rates();
      final converted = rates.convert(
        amountMinor: 10000,
        fromCurrencyCode: 'USD',
        toCurrencyCode: 'GBP',
        date: DateTime.utc(2026, 2, 15),
      );

      expect(converted, 9000);
    });

    test('when every snapshot is newer then the earliest one is used', () {
      final rates = _rates();
      final converted = rates.convert(
        amountMinor: 10000,
        fromCurrencyCode: 'USD',
        toCurrencyCode: 'GBP',
        date: DateTime.utc(2026, 1, 5),
      );

      expect(converted, 8000);
    });

    test('when the currency is missing then conversion throws', () {
      final rates = _rates();

      expect(
        () => rates.convert(
          amountMinor: 10000,
          fromCurrencyCode: 'EUR',
          toCurrencyCode: 'GBP',
          date: DateTime.utc(2026, 2, 15),
        ),
        throwsA(isA<TaxRateUnavailableException>()),
      );
    });

    test('when no snapshot exists then conversion throws', () {
      final rates = TaxFxRates([]);

      expect(
        () => rates.convert(
          amountMinor: 10000,
          fromCurrencyCode: 'USD',
          toCurrencyCode: 'GBP',
          date: DateTime.utc(2026, 1, 15),
        ),
        throwsA(isA<TaxRateUnavailableException>()),
      );
    });

    test('when the currencies match then no snapshot is needed', () {
      final converted = TaxFxRates([]).convert(
        amountMinor: 10000,
        fromCurrencyCode: 'GBP',
        toCurrencyCode: 'GBP',
        date: DateTime.utc(2026, 1, 15),
      );

      expect(converted, 10000);
    });
  });
}
