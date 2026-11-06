import 'package:openbudget_core/src/ledger/ledger_account_type.dart';

/// One account's posted movement feeding a trial balance.
class TrialBalanceEntry {
  const TrialBalanceEntry({
    required this.accountCode,
    required this.functionalDebitMinor,
    required this.functionalCreditMinor,
  });

  /// The ledger account's code.
  final String accountCode;

  /// Sum of posted functional debits.
  final int functionalDebitMinor;

  /// Sum of posted functional credits.
  final int functionalCreditMinor;
}

/// One row of a computed trial balance.
class TrialBalanceRow {
  const TrialBalanceRow({
    required this.accountCode,
    required this.debitMinor,
    required this.creditMinor,
  });

  /// The ledger account's code.
  final String accountCode;

  /// Total debits posted to the account.
  final int debitMinor;

  /// Total credits posted to the account.
  final int creditMinor;

  /// The balance with debits positive: a debit balance is positive, a
  /// credit balance negative, matching [LedgerAccountType] normal balances.
  int get netMinor => debitMinor - creditMinor;
}

/// A computed trial balance over posted journal lines.
class TrialBalance {
  const TrialBalance({
    required this.rows,
    required this.totalDebitMinor,
    required this.totalCreditMinor,
  });

  /// Per-account debit and credit totals, ordered by account code.
  final List<TrialBalanceRow> rows;

  /// Total debits across all accounts.
  final int totalDebitMinor;

  /// Total credits across all accounts.
  final int totalCreditMinor;

  /// True when total debits equal total credits.
  bool get isBalanced => totalDebitMinor == totalCreditMinor;
}

/// Sums posted movements per account into a trial balance.
///
/// A trial balance whose debits differ from its credits is a hard error in
/// the books, never a row labelled "difference"; callers check
/// [TrialBalance.isBalanced] and refuse to report an unbalanced result.
TrialBalance computeTrialBalance(List<TrialBalanceEntry> entries) {
  final debitByAccount = <String, int>{};
  final creditByAccount = <String, int>{};
  var totalDebit = 0;
  var totalCredit = 0;

  for (final entry in entries) {
    final currentDebit = debitByAccount[entry.accountCode] ?? 0;
    final currentCredit = creditByAccount[entry.accountCode] ?? 0;
    debitByAccount[entry.accountCode] =
        currentDebit + entry.functionalDebitMinor;
    creditByAccount[entry.accountCode] =
        currentCredit + entry.functionalCreditMinor;
    totalDebit += entry.functionalDebitMinor;
    totalCredit += entry.functionalCreditMinor;
  }

  final accounts = debitByAccount.keys.toList()..sort();
  final rows = [
    for (final account in accounts)
      TrialBalanceRow(
        accountCode: account,
        debitMinor: debitByAccount[account]!,
        creditMinor: creditByAccount[account]!,
      ),
  ];

  return TrialBalance(
    rows: rows,
    totalDebitMinor: totalDebit,
    totalCreditMinor: totalCredit,
  );
}
