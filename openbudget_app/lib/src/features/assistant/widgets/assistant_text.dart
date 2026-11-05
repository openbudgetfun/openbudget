import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_client/openbudget_client.dart';

/// The words for one tool the assistant used while answering.
String assistantToolLabel(AppLocalizations l10n, String toolName) =>
    switch (toolName) {
      'list_budgets' => l10n.assistantToolListBudgets,
      'list_envelopes' => l10n.assistantToolListEnvelopes,
      'search_transactions' => l10n.assistantToolSearchTransactions,
      'get_tax_report' => l10n.assistantToolGetTaxReport,
      'list_tax_categories' => l10n.assistantToolListTaxCategories,
      'propose_move_money' => l10n.assistantToolProposeMoveMoney,
      'propose_transaction_tax_category' =>
        l10n.assistantToolProposeTransactionTax,
      'propose_envelope_tax_category' => l10n.assistantToolProposeEnvelopeTax,
      _ => l10n.assistantToolUnknown,
    };

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
