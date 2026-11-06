/// Lifecycle states of a journal.
enum JournalStatus {
  /// Editable and deletable; never affects balances.
  draft,

  /// Posted. Immutable: corrections are reversal journals.
  posted,

  /// A posted journal that a reversal journal has undone. Still immutable.
  reversed;

  /// Returns the status whose enum name equals [name], or null.
  static JournalStatus? tryParse(String name) {
    for (final status in values) {
      if (status.name == name) {
        return status;
      }
    }
    return null;
  }
}

/// Where a journal came from.
enum JournalSource {
  /// Entered by hand.
  manual,

  /// Opening-balance or migration journal.
  opening,

  /// Created by a bulk import, such as a Xero migration.
  import,

  /// Created by reversing another journal.
  reversal;

  /// Returns the source whose enum name equals [name], or null.
  static JournalSource? tryParse(String name) {
    for (final source in values) {
      if (source.name == name) {
        return source;
      }
    }
    return null;
  }
}

/// How a budget records money movements.
///
/// `envelope` is the single-entry planning model. `ledger` is double-entry:
/// only sole-trader and company budgets may switch to it, and switching back
/// is not supported.
enum AccountingMode {
  /// Single-entry envelope budgeting. The default for every budget.
  envelope,

  /// Double-entry general ledger, the source of truth for money movements.
  ledger;

  /// Returns the mode whose enum name equals [name], or null.
  static AccountingMode? tryParse(String name) {
    for (final mode in values) {
      if (mode.name == name) {
        return mode;
      }
    }
    return null;
  }
}
