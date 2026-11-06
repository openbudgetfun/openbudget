import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

void main() {
  final combinations = [
    for (final jurisdiction in TaxJurisdiction.values)
      for (final entityKind in [
        TaxEntityKind.soleTrader,
        TaxEntityKind.company,
      ])
        (jurisdiction: jurisdiction, entityKind: entityKind),
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
            entityKind: TaxEntityKind.individual,
          ),
          isNull,
        );
      }
    });
  });

  group('every template', () {
    test('has unique account codes', () {
      for (final combination in combinations) {
        final template = LedgerChartTemplate.forBooks(
          jurisdiction: combination.jurisdiction,
          entityKind: combination.entityKind,
        )!;
        final codes = template.accounts.map((account) => account.code);

        expect(
          codes.toSet(),
          hasLength(codes.length),
          reason: '${template.jurisdiction.name} codes repeat',
        );
      }
    });

    test('has exactly one account per system role', () {
      for (final combination in combinations) {
        final template = LedgerChartTemplate.forBooks(
          jurisdiction: combination.jurisdiction,
          entityKind: combination.entityKind,
        )!;
        final roles = template.accounts
            .map((account) => account.systemRole)
            .whereType<LedgerSystemRole>()
            .toList();

        expect(
          roles.toSet(),
          hasLength(roles.length),
          reason: '${template.jurisdiction.name} repeats a role',
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

      for (final combination in combinations) {
        final template = LedgerChartTemplate.forBooks(
          jurisdiction: combination.jurisdiction,
          entityKind: combination.entityKind,
        )!;
        final roles = template.accounts
            .map((account) => account.systemRole)
            .whereType<LedgerSystemRole>()
            .toSet();
        final expected = combination.entityKind == TaxEntityKind.company
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
        for (final combination in combinations) {
          final template = LedgerChartTemplate.forBooks(
            jurisdiction: combination.jurisdiction,
            entityKind: combination.entityKind,
          )!;
          final roles = template.accounts
              .map((account) => account.systemRole)
              .whereType<LedgerSystemRole>()
              .toSet();

          if (combination.entityKind == TaxEntityKind.company) {
            expect(roles, isNot(contains(LedgerSystemRole.ownerDrawings)));
          } else {
            expect(roles, isNot(contains(LedgerSystemRole.directorsLoan)));
          }
        }
      },
    );

    test('has at least two accounts of every type it can post to', () {
      for (final combination in combinations) {
        final template = LedgerChartTemplate.forBooks(
          jurisdiction: combination.jurisdiction,
          entityKind: combination.entityKind,
        )!;
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
      for (final combination in combinations) {
        final template = LedgerChartTemplate.forBooks(
          jurisdiction: combination.jurisdiction,
          entityKind: combination.entityKind,
        )!;

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

  group('normal balances', () {
    test('assets and expenses increase with debits', () {
      expect(LedgerAccountType.asset.hasDebitNormalBalance, isTrue);
      expect(LedgerAccountType.expense.hasDebitNormalBalance, isTrue);
      expect(LedgerAccountType.liability.hasDebitNormalBalance, isFalse);
      expect(LedgerAccountType.equity.hasDebitNormalBalance, isFalse);
      expect(LedgerAccountType.income.hasDebitNormalBalance, isFalse);
    });

    test('parses from enum names', () {
      expect(LedgerAccountType.tryParse('asset'), LedgerAccountType.asset);
      expect(LedgerAccountType.tryParse('nope'), isNull);
      expect(
        LedgerSystemRole.tryParse('vatControl'),
        LedgerSystemRole.vatControl,
      );
      expect(LedgerSystemRole.tryParse('VAT'), isNull);
    });
  });
}
