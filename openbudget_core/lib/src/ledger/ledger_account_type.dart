/// The five accounting types a ledger account can have.
///
/// The type decides the account's normal balance: asset and expense accounts
/// increase with debits, the rest increase with credits.
enum LedgerAccountType {
  /// Resources the entity owns or is owed: bank, receivables, fixed assets.
  asset,

  /// What the entity owes: payables, tax, loans.
  liability,

  /// The owners' stake: share capital, retained earnings, opening balances.
  equity,

  /// Revenue the entity has earned.
  income,

  /// Costs the entity has incurred.
  expense;

  /// Returns the type whose enum name equals [name], or null.
  static LedgerAccountType? tryParse(String name) {
    for (final type in values) {
      if (type.name == name) {
        return type;
      }
    }
    return null;
  }

  /// True when the account increases with debits.
  bool get hasDebitNormalBalance => this == asset || this == expense;
}
