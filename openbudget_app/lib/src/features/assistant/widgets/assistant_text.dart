import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

/// The words for one tool the assistant used while answering.
String assistantToolLabel(AppLocalizations l10n, String toolName) =>
    switch (toolName) {
      'list_budgets' => l10n.assistantToolListBudgets,
      'list_envelopes' => l10n.assistantToolListEnvelopes,
      'search_transactions' => l10n.assistantToolSearchTransactions,
      'get_tax_report' => l10n.assistantToolGetTaxReport,
      'get_tax_summary' => l10n.assistantToolGetTaxSummary,
      'get_tax_calendar' => l10n.assistantToolGetTaxCalendar,
      'get_spending_summary' => l10n.assistantToolGetSpendingSummary,
      'get_net_worth' => l10n.assistantToolGetNetWorth,
      'list_entities' => l10n.assistantToolListEntities,
      'search_knowledge' => l10n.assistantToolSearchKnowledge,
      'list_tax_categories' => l10n.assistantToolListTaxCategories,
      'propose_move_money' => l10n.assistantToolProposeMoveMoney,
      'propose_transaction_tax_category' =>
        l10n.assistantToolProposeTransactionTax,
      'propose_envelope_tax_category' => l10n.assistantToolProposeEnvelopeTax,
      _ => l10n.assistantToolUnknown,
    };

/// The short disclaimer under a reply that touches tax or investments.
///
/// It follows the entity's [jurisdiction] through `guidanceDisclaimers` in
/// `openbudget_core`, so each pack country shows its own wording. A country
/// with no pack, or an entity that has not loaded yet, gets the generic
/// sentence, which never repeats the screen's fixed footer.
String assistantReplyDisclaimer(
  AppLocalizations l10n,
  TaxJurisdiction? jurisdiction,
) {
  final key = jurisdiction == null
      ? null
      : guidanceDisclaimerFor(jurisdiction)?.key;
  return switch (key) {
    'gb' => l10n.assistantReplyDisclaimerGb,
    'us' => l10n.assistantReplyDisclaimerUs,
    'de' => l10n.assistantReplyDisclaimerDe,
    'ng' => l10n.assistantReplyDisclaimerNg,
    _ => l10n.assistantReplyDisclaimerGeneric,
  };
}

/// The words for what a proposal will change.
String assistantProposalKindLabel(
  AppLocalizations l10n,
  AgentProposalKind kind,
) => switch (kind) {
  AgentProposalKind.moveMoney => l10n.assistantProposalMoveMoney,
  AgentProposalKind.setTransactionTaxCategory =>
    l10n.assistantProposalTransactionTax,
  AgentProposalKind.setEnvelopeTaxCategory => l10n.assistantProposalEnvelopeTax,
};

/// The label for a resolved proposal.
String assistantProposalStatusLabel(
  AppLocalizations l10n,
  AgentProposalStatus status,
) => switch (status) {
  AgentProposalStatus.pending => l10n.assistantProposalPendingLabel,
  AgentProposalStatus.applied => l10n.assistantProposalApplied,
  AgentProposalStatus.dismissed => l10n.assistantProposalDismissed,
};

/// Formats micro-dollars as the dollars a person reads.
String assistantDollars(int microUsd) => NumberFormat.currency(
  locale: 'en_US',
  symbol: r'$',
  decimalDigits: 2,
).format(microUsd / 1000000);
