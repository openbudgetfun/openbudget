import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

/// Frozen descriptions of the four country charts, keyed by
/// (jurisdiction, entity kind): one `code|type|role|name` line per
/// account. Any edit to a country chart must update these on purpose.
final Map<(TaxJurisdiction, EntityKind), String> _countryCharts = {
  (TaxJurisdiction.gb, EntityKind.company): '''
    1099|asset|bankClearing|Bank clearing
    1000|asset|bank|Bank current account
    1100|asset|accountsReceivable|Trade debtors
    2100|liability|accountsPayable|Trade creditors
    2200|liability|vatControl|VAT control
    2300|liability|payrollLiabilities|PAYE, NIC and pension liabilities
    2400|liability||Corporation tax liability
    2500|asset|directorsLoan|Directors' loan account
    3000|equity||Share capital
    3100|equity|retainedEarnings|Retained earnings
    3200|equity|openingBalanceEquity|Opening balance equity
    3300|equity||Dividends declared
    4000|income||Sales
    4100|income||Other income
    5000|expense||Cost of sales
    5100|expense||Wages and salaries
    5200|expense||Employer NIC and pension costs
    5300|expense||Rent and utilities
    5400|expense||Software subscriptions
    5500|expense||Professional fees
    5600|expense||Bank charges
    5800|expense|realisedFx|Realised exchange differences
    5810|expense|unrealisedFx|Unrealised exchange differences
    9900|expense|rounding|Rounding
    9990|liability|suspense|Suspense
  ''',
  (TaxJurisdiction.gb, EntityKind.soleTrader): '''
    1099|asset|bankClearing|Bank clearing
    1000|asset|bank|Business bank account
    1100|asset|accountsReceivable|Trade debtors
    2100|liability|accountsPayable|Trade creditors
    2200|liability|vatControl|VAT control
    2300|liability|payrollLiabilities|Staff PAYE, NIC and pension liabilities
    3000|equity||Owner's capital
    3100|equity|retainedEarnings|Retained earnings
    3200|equity|openingBalanceEquity|Opening balance equity
    3300|equity|ownerDrawings|Owner's drawings
    4000|income||Sales
    4100|income||Other income
    5000|expense||Cost of sales
    5100|expense||Wages
    5200|expense||Rent and utilities
    5300|expense||Software subscriptions
    5400|expense||Professional fees
    5500|expense||Bank charges
    5800|expense|realisedFx|Realised exchange differences
    5810|expense|unrealisedFx|Unrealised exchange differences
    9900|expense|rounding|Rounding
    9990|liability|suspense|Suspense
  ''',
  (TaxJurisdiction.us, EntityKind.company): '''
    1099|asset|bankClearing|Bank clearing
    1000|asset|bank|Operating bank account
    1100|asset|accountsReceivable|Accounts receivable
    2100|liability|accountsPayable|Accounts payable
    2200|liability|vatControl|Sales tax payable
    2300|liability|payrollLiabilities|Payroll liabilities (withholding, FICA)
    2500|asset|directorsLoan|Shareholder loan account
    3000|equity||Common stock
    3100|equity|retainedEarnings|Retained earnings
    3200|equity|openingBalanceEquity|Opening balance equity
    3300|equity||Shareholder distributions
    4000|income||Sales revenue
    4100|income||Other income
    5000|expense||Cost of sales
    5100|expense||Officer compensation
    5200|expense||Payroll wages
    5300|expense||Rent and utilities
    5400|expense||Software subscriptions
    5500|expense||Professional fees
    5600|expense||Bank charges
    5800|expense|realisedFx|Realised exchange gain or loss
    5810|expense|unrealisedFx|Unrealised exchange gain or loss
    9900|expense|rounding|Rounding
    9990|liability|suspense|Suspense
  ''',
  (TaxJurisdiction.us, EntityKind.soleTrader): '''
    1099|asset|bankClearing|Bank clearing
    1000|asset|bank|Business bank account
    1100|asset|accountsReceivable|Accounts receivable
    2100|liability|accountsPayable|Accounts payable
    2200|liability|vatControl|Sales tax payable
    2300|liability|payrollLiabilities|Payroll liabilities (withholding, FICA)
    3000|equity||Owner's equity
    3100|equity|retainedEarnings|Retained earnings
    3200|equity|openingBalanceEquity|Opening balance equity
    3300|equity|ownerDrawings|Owner distributions
    4000|income||Sales revenue
    4100|income||Other income
    5000|expense||Cost of sales
    5100|expense||Wages
    5200|expense||Rent and utilities
    5300|expense||Software subscriptions
    5400|expense||Professional fees
    5500|expense||Bank charges
    5800|expense|realisedFx|Realised exchange gain or loss
    5810|expense|unrealisedFx|Unrealised exchange gain or loss
    9900|expense|rounding|Rounding
    9990|liability|suspense|Suspense
  ''',
  (TaxJurisdiction.ng, EntityKind.company): '''
    1099|asset|bankClearing|Bank clearing
    1000|asset|bank|Bank current account
    1100|asset|accountsReceivable|Trade debtors
    1150|asset||Withholding tax receivable
    2100|liability|accountsPayable|Trade creditors
    2150|liability||Withholding tax payable
    2200|liability|vatControl|VAT control (7.5%)
    2300|liability|payrollLiabilities|PAYE, pension (PenCom) and NSITF liabilities
    2400|liability||Company income tax liability
    2500|asset|directorsLoan|Directors loan account
    3000|equity||Share capital
    3100|equity|retainedEarnings|Retained earnings
    3200|equity|openingBalanceEquity|Opening balance equity
    4000|income||Sales
    4100|income||Other income
    5000|expense||Cost of sales
    5100|expense||Wages and salaries
    5200|expense||Rent and utilities
    5300|expense||Software subscriptions
    5400|expense||Professional fees
    5500|expense||Bank charges
    5800|expense|realisedFx|Realised exchange differences
    5810|expense|unrealisedFx|Unrealised exchange differences
    9900|expense|rounding|Rounding
    9990|liability|suspense|Suspense
  ''',
  (TaxJurisdiction.ng, EntityKind.soleTrader): '''
    1099|asset|bankClearing|Bank clearing
    1000|asset|bank|Business bank account
    1100|asset|accountsReceivable|Trade debtors
    1150|asset||Withholding tax receivable
    2100|liability|accountsPayable|Trade creditors
    2150|liability||Withholding tax payable
    2200|liability|vatControl|VAT control (7.5%)
    2300|liability|payrollLiabilities|PAYE, pension (PenCom) and NSITF liabilities
    3000|equity||Owner's capital
    3100|equity|retainedEarnings|Retained earnings
    3200|equity|openingBalanceEquity|Opening balance equity
    3300|equity|ownerDrawings|Owner's drawings
    4000|income||Sales
    4100|income||Other income
    5000|expense||Cost of sales
    5100|expense||Wages
    5200|expense||Rent and utilities
    5300|expense||Software subscriptions
    5400|expense||Professional fees
    5500|expense||Bank charges
    5800|expense|realisedFx|Realised exchange differences
    5810|expense|unrealisedFx|Unrealised exchange differences
    9900|expense|rounding|Rounding
    9990|liability|suspense|Suspense
  ''',
  (TaxJurisdiction.de, EntityKind.company): '''
    1099|asset|bankClearing|Bank clearing
    1800|asset|bank|Bank
    1200|asset|accountsReceivable|Forderungen aus Lieferungen und Leistungen
    3300|liability|accountsPayable|Verbindlichkeiten aus Lieferungen und Leistungen
    3806|liability|vatControl|Umsatzsteuer-Kontrolle
    0810|liability|payrollLiabilities|Lohnsteuer und Sozialabgaben
    1500|liability|directorsLoan|Verbindlichkeiten gegenüber Gesellschaftern
    2900|equity||Stammkapital
    2925|equity|retainedEarnings|Gewinnvortrag
    9000|equity|openingBalanceEquity|Eröffnungsbilanzkonto
    4400|income||Erlöse 19 %
    4300|income||Erlöse 7 %
    4100|income||Steuerfreie Umsätze §4 UStG
    6000|expense||Löhne
    6800|expense||Gehälter
    7250|expense||Miete
    6480|expense||Software
    6300|expense||Rechts- und Steuerberatung
    6560|expense||Bankgebühren
    6860|expense|realisedFx|Realisierte Kursdifferenzen
    6865|expense|unrealisedFx|Unrealisierte Kursdifferenzen
    9995|expense|rounding|Rundung
    9990|liability|suspense|Verrechnungskonto
  ''',
  (TaxJurisdiction.de, EntityKind.soleTrader): '''
    1099|asset|bankClearing|Bank clearing
    1800|asset|bank|Bank
    1200|asset|accountsReceivable|Forderungen aus Lieferungen und Leistungen
    3300|liability|accountsPayable|Verbindlichkeiten aus Lieferungen und Leistungen
    3806|liability|vatControl|Umsatzsteuer-Kontrolle
    0810|liability|payrollLiabilities|Lohnsteuer und Sozialabgaben
    1950|equity||Privateinlagen
    2925|equity|retainedEarnings|Gewinnvortrag
    9000|equity|openingBalanceEquity|Eröffnungsbilanzkonto
    1900|equity|ownerDrawings|Privatentnahmen
    4400|income||Erlöse 19 %
    4300|income||Erlöse 7 %
    4100|income||Steuerfreie Umsätze §4 UStG
    6000|expense||Löhne
    6800|expense||Gehälter
    7250|expense||Miete
    6480|expense||Software
    6300|expense||Rechts- und Steuerberatung
    6560|expense||Bankgebühren
    6860|expense|realisedFx|Realisierte Kursdifferenzen
    6865|expense|unrealisedFx|Unrealisierte Kursdifferenzen
    9995|expense|rounding|Rundung
    9990|liability|suspense|Verrechnungskonto
  ''',
};

void main() {
  final bookKinds = [EntityKind.soleTrader, EntityKind.company];
  final combinations = [
    for (final jurisdiction in TaxJurisdiction.values)
      for (final entityKind in bookKinds)
        (jurisdiction: jurisdiction, entityKind: entityKind),
  ];

  // Every template the resolver can produce: the country charts for both
  // kinds of books plus the generic charts. One stamp per kind for the
  // generic ones; the account data is the same for every stamp.
  final everyTemplate = [
    for (final combination in combinations)
      LedgerChartTemplate.forBooks(
        jurisdiction: combination.jurisdiction,
        entityKind: combination.entityKind,
      )!,
    for (final entityKind in bookKinds)
      LedgerChartTemplate.generic(
        jurisdiction: TaxJurisdiction.gb,
        entityKind: entityKind,
      )!,
  ];

  group('LedgerChartTemplate.forBooks', () {
    test('ships a template for every supported combination', () {
      for (final combination in combinations) {
        final template = LedgerChartTemplate.forBooks(
          jurisdiction: combination.jurisdiction,
          entityKind: combination.entityKind,
        );

        expect(
          template,
          isNotNull,
          reason:
              '${combination.jurisdiction.name}/'
              '${combination.entityKind.name} has no template',
        );
      }
    });

    test('ships no template for personal books', () {
      // Individual budgets stay envelope-only and never get a ledger.
      for (final jurisdiction in TaxJurisdiction.values) {
        expect(
          LedgerChartTemplate.forBooks(
            jurisdiction: jurisdiction,
            entityKind: EntityKind.individual,
          ),
          isNull,
        );
      }
    });

    test('keeps every charted country off the generic chart', () {
      // forBooks prefers the country's own chart; the generic chart is
      // the fallback for countries without one, never a replacement.
      for (final combination in combinations) {
        final template = LedgerChartTemplate.forBooks(
          jurisdiction: combination.jurisdiction,
          entityKind: combination.entityKind,
        )!;
        final generic = LedgerChartTemplate.generic(
          jurisdiction: combination.jurisdiction,
          entityKind: combination.entityKind,
        )!;

        expect(
          _sameAccounts(template, generic),
          isFalse,
          reason:
              '${combination.jurisdiction.name}/'
              '${combination.entityKind.name} resolved to the generic chart',
        );
      }
    });

    test(
      'resolves every books combination to its own chart or the generic one',
      () {
        // Countries without a tax pack (KE, BR, JP, …) join
        // TaxJurisdiction in the later country batches and have no chart of
        // their own; they resolve to the generic chart for both kinds of
        // business books. Every enum jurisdiction is charted today, so this
        // pins the resolver contract: the answer is always the frozen
        // country chart or the generic chart.
        for (final combination in combinations) {
          final template = LedgerChartTemplate.forBooks(
            jurisdiction: combination.jurisdiction,
            entityKind: combination.entityKind,
          )!;
          final generic = LedgerChartTemplate.generic(
            jurisdiction: combination.jurisdiction,
            entityKind: combination.entityKind,
          )!;
          final key = (
            combination.jurisdiction,
            combination.entityKind,
          );
          final frozen = _expected(_countryCharts[key]!);

          expect(
            _sameAccounts(template, generic) || _describe(template) == frozen,
            isTrue,
            reason:
                '${combination.jurisdiction.name}/'
                '${combination.entityKind.name} resolved to an unknown chart',
          );
        }
      },
    );
  });

  group('every template', () {
    test('has unique account codes', () {
      for (final template in everyTemplate) {
        final codes = template.accounts.map((account) => account.code);

        expect(
          codes.toSet(),
          hasLength(codes.length),
          reason:
              '${template.jurisdiction.name}/'
              '${template.entityKind.name} codes repeat',
        );
      }
    });

    test('has exactly one account per system role', () {
      for (final template in everyTemplate) {
        final roles = template.accounts
            .map((account) => account.systemRole)
            .whereType<LedgerSystemRole>()
            .toList();

        expect(
          roles.toSet(),
          hasLength(roles.length),
          reason:
              '${template.jurisdiction.name}/'
              '${template.entityKind.name} repeats a role',
        );
      }
    });

    test('covers the roles its entity kind needs', () {
      const companyRoles = [
        LedgerSystemRole.bank,
        LedgerSystemRole.accountsReceivable,
        LedgerSystemRole.accountsPayable,
        LedgerSystemRole.vatControl,
        LedgerSystemRole.payrollLiabilities,
        LedgerSystemRole.directorsLoan,
        LedgerSystemRole.retainedEarnings,
        LedgerSystemRole.openingBalanceEquity,
        LedgerSystemRole.suspense,
        LedgerSystemRole.rounding,
        LedgerSystemRole.realisedFx,
        LedgerSystemRole.unrealisedFx,
      ];
      const soleTraderRoles = [
        LedgerSystemRole.bank,
        LedgerSystemRole.accountsReceivable,
        LedgerSystemRole.accountsPayable,
        LedgerSystemRole.vatControl,
        LedgerSystemRole.payrollLiabilities,
        LedgerSystemRole.ownerDrawings,
        LedgerSystemRole.retainedEarnings,
        LedgerSystemRole.openingBalanceEquity,
        LedgerSystemRole.suspense,
        LedgerSystemRole.rounding,
        LedgerSystemRole.realisedFx,
        LedgerSystemRole.unrealisedFx,
      ];

      for (final template in everyTemplate) {
        final roles = template.accounts
            .map((account) => account.systemRole)
            .whereType<LedgerSystemRole>()
            .toSet();
        final expected = template.entityKind == EntityKind.company
            ? companyRoles
            : soleTraderRoles;

        expect(
          roles.containsAll(expected),
          isTrue,
          reason:
              '${template.jurisdiction.name}/'
              '${template.entityKind.name} is missing roles',
        );
        expect(
          roles.containsAll([
            LedgerSystemRole.suspense,
            LedgerSystemRole.rounding,
          ]),
          isTrue,
        );
      }
    });

    test(
      'gives company books no drawings and sole traders no director loans',
      () {
        for (final template in everyTemplate) {
          final roles = template.accounts
              .map((account) => account.systemRole)
              .whereType<LedgerSystemRole>()
              .toSet();

          if (template.entityKind == EntityKind.company) {
            expect(roles, isNot(contains(LedgerSystemRole.ownerDrawings)));
          } else {
            expect(roles, isNot(contains(LedgerSystemRole.directorsLoan)));
          }
        }
      },
    );

    test('has at least two accounts of every type it can post to', () {
      for (final template in everyTemplate) {
        final byType = <LedgerAccountType, int>{};
        for (final account in template.accounts) {
          byType[account.type] = (byType[account.type] ?? 0) + 1;
        }

        for (final type in LedgerAccountType.values) {
          expect(
            byType[type] ?? 0,
            greaterThanOrEqualTo(2),
            reason:
                '${template.jurisdiction.name}/'
                '${template.entityKind.name} has few ${type.name} accounts',
          );
        }
      }
    });

    test('never names a currency in template data', () {
      // The budget's currencyCode is the functional currency, so template
      // data stays currency-free and any budget currency can use any chart.
      for (final template in everyTemplate) {
        for (final account in template.accounts) {
          for (final jurisdiction in TaxJurisdiction.values) {
            expect(
              account.name.contains(jurisdiction.currencyCode),
              isFalse,
              reason: '${account.code} hard-codes a currency',
            );
          }
        }
      }
    });
  });

  group('generic chart', () {
    test('is offered for every business kind and stamps the books', () {
      for (final jurisdiction in TaxJurisdiction.values) {
        for (final entityKind in bookKinds) {
          final template = LedgerChartTemplate.generic(
            jurisdiction: jurisdiction,
            entityKind: entityKind,
          );

          expect(
            template,
            isNotNull,
            reason:
                '${jurisdiction.name}/${entityKind.name} has no generic chart',
          );
          expect(template!.jurisdiction, jurisdiction);
          expect(template.entityKind, entityKind);
        }
      }
    });

    test('is not offered for personal books', () {
      for (final jurisdiction in TaxJurisdiction.values) {
        expect(
          LedgerChartTemplate.generic(
            jurisdiction: jurisdiction,
            entityKind: EntityKind.individual,
          ),
          isNull,
        );
      }
    });

    test('covers every system role, including bankClearing', () {
      final roles = {
        for (final entityKind in bookKinds)
          entityKind:
              LedgerChartTemplate.generic(
                    jurisdiction: TaxJurisdiction.gb,
                    entityKind: entityKind,
                  )!.accounts
                  .map((account) => account.systemRole)
                  .whereType<LedgerSystemRole>()
                  .toSet(),
      };

      // Roles both kinds of books need; the equity roles below are
      // entity-kind specific.
      const shared = [
        LedgerSystemRole.bank,
        LedgerSystemRole.accountsReceivable,
        LedgerSystemRole.accountsPayable,
        LedgerSystemRole.vatControl,
        LedgerSystemRole.payrollLiabilities,
        LedgerSystemRole.retainedEarnings,
        LedgerSystemRole.openingBalanceEquity,
        LedgerSystemRole.suspense,
        LedgerSystemRole.rounding,
        LedgerSystemRole.realisedFx,
        LedgerSystemRole.unrealisedFx,
        LedgerSystemRole.bankClearing,
      ];
      for (final entityKind in bookKinds) {
        expect(
          roles[entityKind],
          containsAll(shared),
          reason: '${entityKind.name} generic chart is missing roles',
        );
      }
      expect(
        roles[EntityKind.company],
        contains(LedgerSystemRole.directorsLoan),
      );
      expect(
        roles[EntityKind.company],
        isNot(contains(LedgerSystemRole.ownerDrawings)),
      );
      expect(
        roles[EntityKind.soleTrader],
        contains(LedgerSystemRole.ownerDrawings),
      );
      expect(
        roles[EntityKind.soleTrader],
        isNot(contains(LedgerSystemRole.directorsLoan)),
      );

      // Together the two charts carry every role value.
      expect(
        {
          ...roles[EntityKind.company]!,
          ...roles[EntityKind.soleTrader]!,
        },
        containsAll(LedgerSystemRole.values),
      );
    });
  });

  group('country charts are unchanged', () {
    test('GB, US, NG and DE still return exactly their existing templates', () {
      for (final entry in _countryCharts.entries) {
        final template = LedgerChartTemplate.forBooks(
          jurisdiction: entry.key.$1,
          entityKind: entry.key.$2,
        )!;

        expect(
          _describe(template),
          _expected(entry.value),
          reason: '${entry.key.$1.name}/${entry.key.$2.name} chart changed',
        );
      }
    });
  });

  group('normal balances', () {
    test('assets and expenses increase with debits', () {
      expect(LedgerAccountType.asset.hasDebitNormalBalance, isTrue);
      expect(LedgerAccountType.expense.hasDebitNormalBalance, isTrue);
      expect(LedgerAccountType.liability.hasDebitNormalBalance, isFalse);
      expect(LedgerAccountType.equity.hasDebitNormalBalance, isFalse);
      expect(LedgerAccountType.income.hasDebitNormalBalance, isFalse);
    });

    test('parses from enum names', () {
      expect(
        LedgerAccountType.values.asNameMap()['asset'],
        LedgerAccountType.asset,
      );
      expect(LedgerAccountType.values.asNameMap()['nope'], isNull);
      expect(
        LedgerSystemRole.values.asNameMap()['vatControl'],
        LedgerSystemRole.vatControl,
      );
      expect(LedgerSystemRole.values.asNameMap()['VAT'], isNull);
    });
  });
}

/// One `code|type|role|name` line per account, in template order.
String _describe(LedgerChartTemplate template) => template.accounts
    .map(
      (account) =>
          '${account.code}|${account.type.name}|'
          '${account.systemRole?.name ?? ''}|${account.name}',
    )
    .join('\n');

/// Trims the snapshot blocks above back to their lines.
String _expected(String block) => block
    .split('\n')
    .map((line) => line.trim())
    .where((line) => line.isNotEmpty)
    .join('\n');

/// Field-by-field account comparison; [ChartAccountTemplate] has no `==`.
bool _sameAccounts(LedgerChartTemplate a, LedgerChartTemplate b) {
  if (a.accounts.length != b.accounts.length) {
    return false;
  }
  for (var i = 0; i < a.accounts.length; i++) {
    final x = a.accounts[i];
    final y = b.accounts[i];
    if (x.code != y.code ||
        x.name != y.name ||
        x.type != y.type ||
        x.systemRole != y.systemRole) {
      return false;
    }
  }
  return true;
}
