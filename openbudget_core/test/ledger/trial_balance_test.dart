import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

void main() {
  group('computeTrialBalance (T8.1)', () {
    test('totals the T3.1 scenario and balances exactly', () {
      // After the full T3.1 lifecycle: Bank 500.00 Dr, AR 0, Sales
      // 1,200.00 Cr, Sales returns 120.00 Dr, VAT output 83.33 Cr, bad
      // debt 663.33 Dr. Debits 1,283.33 = credits 1,283.33.
      final trialBalance = computeTrialBalance([
        const TrialBalanceEntry(
          accountCode: '1000',
          functionalDebitMinor: 50000,
          functionalCreditMinor: 0,
        ),
        // Trade debtors net to zero over the lifecycle (1,440.00 invoiced,
        // 500.00 + 144.00 + 796.00 released), so it carries no row.
        const TrialBalanceEntry(
          accountCode: '2200',
          functionalDebitMinor: 0,
          functionalCreditMinor: 8333,
        ),
        const TrialBalanceEntry(
          accountCode: '4000',
          functionalDebitMinor: 0,
          functionalCreditMinor: 120000,
        ),
        const TrialBalanceEntry(
          accountCode: '4100',
          functionalDebitMinor: 12000,
          functionalCreditMinor: 0,
        ),
        const TrialBalanceEntry(
          accountCode: '6500',
          functionalDebitMinor: 66333,
          functionalCreditMinor: 0,
        ),
      ]);

      final byAccount = {
        for (final row in trialBalance.rows) row.accountCode: row,
      };

      expect(byAccount['1000']!.netMinor, 50000);
      expect(byAccount['2200']!.netMinor, -8333);
      expect(byAccount['4000']!.netMinor, -120000);
      expect(byAccount['4100']!.netMinor, 12000);
      expect(byAccount['6500']!.netMinor, 66333);
      expect(trialBalance.totalDebitMinor, 128333);
      expect(trialBalance.totalCreditMinor, 128333);
      expect(trialBalance.isBalanced, isTrue);
    });

    test('orders rows by account code', () {
      final trialBalance = computeTrialBalance([
        const TrialBalanceEntry(
          accountCode: '4000',
          functionalDebitMinor: 0,
          functionalCreditMinor: 100,
        ),
        const TrialBalanceEntry(
          accountCode: '1000',
          functionalDebitMinor: 100,
          functionalCreditMinor: 0,
        ),
      ]);

      expect(
        trialBalance.rows.map((row) => row.accountCode),
        ['1000', '4000'],
      );
    });

    test('reports imbalance instead of hiding it', () {
      final trialBalance = computeTrialBalance([
        const TrialBalanceEntry(
          accountCode: '1000',
          functionalDebitMinor: 100,
          functionalCreditMinor: 0,
        ),
        const TrialBalanceEntry(
          accountCode: '4000',
          functionalDebitMinor: 0,
          functionalCreditMinor: 99,
        ),
      ]);

      expect(trialBalance.isBalanced, isFalse);
      expect(trialBalance.totalDebitMinor, 100);
      expect(trialBalance.totalCreditMinor, 99);
    });

    test('an empty ledger balances at zero', () {
      final trialBalance = computeTrialBalance(const []);

      expect(trialBalance.rows, isEmpty);
      expect(trialBalance.totalDebitMinor, 0);
      expect(trialBalance.totalCreditMinor, 0);
      expect(trialBalance.isBalanced, isTrue);
    });
  });

  group('computeTrialBalance (T8.2 balance-sheet identity)', () {
    test('opening balances plus a cash sale keep the identity', () {
      // Opening T7.8 plus a cash sale of 1,000 gross: assets 8,000,
      // liabilities 1,500, equity 100 + 5,400 + earnings 1,000 = 6,500.
      final trialBalance = computeTrialBalance([
        const TrialBalanceEntry(
          accountCode: '1000',
          functionalDebitMinor: 600000,
          functionalCreditMinor: 0,
        ),
        const TrialBalanceEntry(
          accountCode: '1100',
          functionalDebitMinor: 200000,
          functionalCreditMinor: 0,
        ),
        const TrialBalanceEntry(
          accountCode: '2100',
          functionalDebitMinor: 0,
          functionalCreditMinor: 150000,
        ),
        const TrialBalanceEntry(
          accountCode: '3000',
          functionalDebitMinor: 0,
          functionalCreditMinor: 10000,
        ),
        const TrialBalanceEntry(
          accountCode: '3100',
          functionalDebitMinor: 0,
          functionalCreditMinor: 540000,
        ),
        const TrialBalanceEntry(
          accountCode: '4000',
          functionalDebitMinor: 0,
          functionalCreditMinor: 100000,
        ),
      ]);

      expect(trialBalance.isBalanced, isTrue);
      final netByAccount = {
        for (final row in trialBalance.rows) row.accountCode: row.netMinor,
      };
      final assets = netByAccount['1000']! + netByAccount['1100']!;
      final liabilities = netByAccount['2100']!;
      final equity =
          netByAccount['3000']! + netByAccount['3100']! + netByAccount['4000']!;
      expect(assets, 800000);
      // Assets equal liabilities plus equity; liabilities and equity carry
      // credit balances, negative in the debit-positive net convention.
      expect(assets, -(liabilities + equity));
    });
  });
}
