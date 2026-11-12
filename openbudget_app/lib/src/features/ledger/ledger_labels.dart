import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The label for a journal's lifecycle state.
String ledgerStatusLabel(AppLocalizations l10n, JournalStatus status) =>
    switch (status) {
      JournalStatus.draft => l10n.ledgerStatusDraft,
      JournalStatus.posted => l10n.ledgerStatusPosted,
      JournalStatus.reversed => l10n.ledgerStatusReversed,
    };

/// The tone wash behind a journal's status chip.
///
/// Drafts ask for attention, posted journals are settled money, and a
/// reversed journal carries no warning — the word carries the meaning.
ObTone ledgerStatusTone(JournalStatus status) => switch (status) {
  JournalStatus.draft => ObTone.review,
  JournalStatus.posted => ObTone.funded,
  JournalStatus.reversed => ObTone.neutral,
};

/// The group heading for one ledger account type.
String ledgerAccountTypeLabel(AppLocalizations l10n, LedgerAccountType type) =>
    switch (type) {
      LedgerAccountType.asset => l10n.ledgerAccountTypeAsset,
      LedgerAccountType.liability => l10n.ledgerAccountTypeLiability,
      LedgerAccountType.equity => l10n.ledgerAccountTypeEquity,
      LedgerAccountType.income => l10n.ledgerAccountTypeIncome,
      LedgerAccountType.expense => l10n.ledgerAccountTypeExpense,
    };

/// The order account types group in on the Accounts tab.
const ledgerAccountTypeOrder = <LedgerAccountType>[
  LedgerAccountType.asset,
  LedgerAccountType.liability,
  LedgerAccountType.equity,
  LedgerAccountType.income,
  LedgerAccountType.expense,
];

/// The chart's account whose type is [name], or null for an unknown name.
LedgerAccountType? ledgerAccountTypeFor(String name) {
  for (final type in LedgerAccountType.values) {
    if (type.name == name) return type;
  }
  return null;
}

/// The journal status whose enum name equals [name], or null.
JournalStatus? ledgerStatusFor(String name) {
  for (final status in JournalStatus.values) {
    if (status.name == name) return status;
  }
  return null;
}
