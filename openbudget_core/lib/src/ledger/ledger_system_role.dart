/// Stable, internal roles the ledger machinery depends on.
///
/// Accounts carry a role; jurisdiction template charts map their codes onto
/// them. Account codes are user-visible and can be renumbered, so nothing in
/// the posting or reporting code keys on a code — only on a role. There is
/// exactly one active (non-archived) account per role per ledger.
enum LedgerSystemRole {
  /// The entity's primary current account. Foreign-currency bank accounts
  /// are plain asset accounts; this role marks the default bank account.
  bank,

  /// Control account for amounts customers owe on approved invoices.
  accountsReceivable,

  /// Control account for amounts owed to suppliers on approved bills.
  accountsPayable,

  /// Net sales tax owed to the authority: output tax less recoverable input
  /// tax (VAT in GB/DE/NG, sales tax payable in the US).
  vatControl,

  /// Withholding for staff: PAYE and NIC (GB), FICA and state withholding
  /// (US), PAYE, PenCom and NSITF (NG), Lohnsteuer (DE).
  payrollLiabilities,

  /// Loans between the company and its directors. Sole traders have no
  /// directors' loan account.
  directorsLoan,

  /// Accumulated profits kept in the entity after distributions.
  retainedEarnings,

  /// Equity account every opening-balance journal balances against.
  openingBalanceEquity,

  /// Holding account for entries awaiting correct coding. A non-zero
  /// suspense balance blocks period close.
  suspense,

  /// Last-resort account for per-line rounding residue.
  rounding,

  /// Exchange differences realised when a foreign-currency item settles.
  realisedFx,

  /// Exchange differences on open foreign-currency items at a revaluation
  /// date; its journals auto-reverse in the following period.
  unrealisedFx,

  /// Money the sole trader takes out of (or puts into) the business outside
  /// capital. Companies have no drawings account.
  ownerDrawings;

  /// Returns the role whose enum name equals [name], or null.
  static LedgerSystemRole? tryParse(String name) {
    for (final role in values) {
      if (role.name == name) {
        return role;
      }
    }
    return null;
  }
}
