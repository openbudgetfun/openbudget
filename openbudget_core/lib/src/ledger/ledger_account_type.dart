import 'package:openbudget_core/src/generated/ledger_account_type.dart';
export 'package:openbudget_core/src/generated/ledger_account_type.dart';

/// Normal balance rules for the persisted chart account type.
extension LedgerAccountTypeRules on LedgerAccountType {
  bool get hasDebitNormalBalance =>
      this == LedgerAccountType.asset || this == LedgerAccountType.expense;
}
