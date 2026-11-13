/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:openbudget_client/src/protocol/accounts/account.dart'
    as _iqudaadl;
import 'package:openbudget_client/src/protocol/accounts/account_valuation.dart'
    as _idms9t2z;
import 'package:openbudget_client/src/protocol/agent/agent_conversation.dart'
    as _in44ixo7;
import 'package:openbudget_client/src/protocol/agent/agent_message.dart'
    as _i8fbky0c;
import 'package:openbudget_client/src/protocol/agent/agent_proposal.dart'
    as _icv7zzda;
import 'package:openbudget_client/src/protocol/agent/mcp/agent_access_token_view.dart'
    as _itxn3wek;
import 'package:openbudget_client/src/protocol/audit/audit_event.dart'
    as _ioe147d0;
import 'package:openbudget_client/src/protocol/budget/allocation_input.dart'
    as _inutgv28;
import 'package:openbudget_client/src/protocol/budget/budget_month_summary.dart'
    as _i52laypj;
import 'package:openbudget_client/src/protocol/budget_templates/budget_template.dart'
    as _itiojbb0;
import 'package:openbudget_client/src/protocol/budget_templates/budget_template_line.dart'
    as _ik2p0evm;
import 'package:openbudget_client/src/protocol/categories/category.dart'
    as _iels1fku;
import 'package:openbudget_client/src/protocol/entities/entity.dart'
    as _i2ulk6h5;
import 'package:openbudget_client/src/protocol/entities/entity_summary_view.dart'
    as _ib1vbiwb;
import 'package:openbudget_client/src/protocol/envelope_goals/envelope_goal.dart'
    as _ibdhi9gv;
import 'package:openbudget_client/src/protocol/envelopes/envelope.dart'
    as _i29jf3by;
import 'package:openbudget_client/src/protocol/institutions/institution.dart'
    as _i6ysl1a4;
import 'package:openbudget_client/src/protocol/ledger/journal.dart'
    as _izuizaeu;
import 'package:openbudget_client/src/protocol/ledger/journal_line.dart'
    as _iwruw2s3;
import 'package:openbudget_client/src/protocol/ledger/journal_line_input.dart'
    as _i3j8x5or;
import 'package:openbudget_client/src/protocol/ledger/ledger_account.dart'
    as _ixq9t892;
import 'package:openbudget_client/src/protocol/payees/payee.dart' as _iaf6ifsb;
import 'package:openbudget_client/src/protocol/plaid/plaid_connection.dart'
    as _itydqisw;
import 'package:openbudget_client/src/protocol/recurring_transactions/recurring_transaction.dart'
    as _i41tn6nr;
import 'package:openbudget_client/src/protocol/reports/spending_row.dart'
    as _ia9y0al9;
import 'package:openbudget_client/src/protocol/tax/tax_category_view.dart'
    as _ic177lol;
import 'package:openbudget_client/src/protocol/transaction_rules/transaction_rule.dart'
    as _iwxd5v0a;
import 'package:openbudget_client/src/protocol/transactions/import_row.dart'
    as _iyud7cy9;
import 'package:openbudget_client/src/protocol/transactions/transaction_view.dart'
    as _irfj6dpt;
import 'package:openbudget_client/src/protocol/wallets/wallet.dart'
    as _igzh8mor;
import 'package:openbudget_client/src/protocol/wallets/wallet_holding.dart'
    as _izm3e498;
import 'package:openbudget_client/src/protocol/wallets/wallet_network_state.dart'
    as _i9c4hszu;
import 'package:openbudget_client/src/protocol/wallets/wallet_tax_year_summary.dart'
    as _il62txu0;
import 'package:openbudget_client/src/protocol/wallets/wallet_transaction.dart'
    as _itxp58mr;
import 'package:openbudget_core/openbudget_core.dart' as _ifz8weqz;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

import 'accounts/account.dart' as _iz2jf14v;
import 'accounts/account_balances_view.dart' as _i53yl4yp;
import 'accounts/account_valuation.dart' as _i87oqvv1;
import 'accounts/valuation_source.dart' as _ig9cy6ku;
import 'agent/agent_conversation.dart' as _isfmgqgu;
import 'agent/agent_event.dart' as _i769eo9u;
import 'agent/agent_event_kind.dart' as _iyhb15ax;
import 'agent/agent_message.dart' as _inwxyid7;
import 'agent/agent_message_role.dart' as _iy2njbiw;
import 'agent/agent_proposal.dart' as _iqh65hzq;
import 'agent/agent_proposal_kind.dart' as _idxyy01n;
import 'agent/agent_proposal_status.dart' as _iksk16ej;
import 'agent/agent_provider.dart' as _ic667156;
import 'agent/agent_provider_settings_view.dart' as _i0760q1h;
import 'agent/agent_usage_record.dart' as _igo4k2bu;
import 'agent/agent_usage_view.dart' as _ipqjijih;
import 'agent/mcp/agent_access_token_created.dart' as _iis6jewo;
import 'agent/mcp/agent_access_token_view.dart' as _i4mcrc97;
import 'audit/audit_action.dart' as _iqje9mi5;
import 'audit/audit_event.dart' as _ijhj7cd7;
import 'audit/audit_subject.dart' as _i2sn5a56;
import 'billing/entitlement.dart' as _iq2w1sa5;
import 'billing/entitlement_source.dart' as _ipnf4x0i;
import 'billing/entitlement_status.dart' as _imqwzx9j;
import 'billing/solana_plan_view.dart' as _iwxkomal;
import 'budget/allocation_input.dart' as _iouaddet;
import 'budget/budget_month_summary.dart' as _ixyov90t;
import 'budget/budget_month_view.dart' as _ihanl5km;
import 'budget/envelope_month_view.dart' as _ii8h2sft;
import 'budget_templates/budget_template.dart' as _i01fne9j;
import 'budget_templates/budget_template_line.dart' as _iagnrffn;
import 'categories/category.dart' as _iwxpkdmg;
import 'common/confidence.dart' as _i4zfq652;
import 'common/sync_status.dart' as _iynfhhr3;
import 'entities/change_scope.dart' as _i03vgs6n;
import 'entities/entity.dart' as _iamyw1yn;
import 'entities/entity_changed_event.dart' as _is12mxpv;
import 'entities/entity_summary_view.dart' as _ihqn2h4c;
import 'envelope_goals/envelope_goal.dart' as _ifl4yivq;
import 'envelope_goals/envelope_goal_kind.dart' as _i61aeoqs;
import 'envelopes/envelope.dart' as _ikt21dfw;
import 'exceptions/agent_allowance_exhausted_exception.dart' as _iozei2bz;
import 'exceptions/agent_provider_exception.dart' as _iurccglg;
import 'exceptions/agent_provider_unavailable_exception.dart' as _i6p28blo;
import 'exceptions/authentication_required_exception.dart' as _io2kod1y;
import 'exceptions/billing_provider_exception.dart' as _i9zkhl6f;
import 'exceptions/billing_rail_unavailable_exception.dart' as _i5kq7itn;
import 'exceptions/entitlement_required_exception.dart' as _ik3lny6q;
import 'exceptions/forbidden_exception.dart' as _iha6yc5u;
import 'exceptions/fx_rate_unavailable_exception.dart' as _if5umnl3;
import 'exceptions/not_found_exception.dart' as _izob2ctl;
import 'exceptions/tax_rules_unavailable_exception.dart' as _i4yu9vcq;
import 'exceptions/validation_exception.dart' as _igpdbyom;
import 'exceptions/wallet_preview_rate_limited_exception.dart' as _i4nmh6wd;
import 'fx_rates/fx_latest_snapshot.dart' as _i8cxakqz;
import 'fx_rates/fx_provider.dart' as _ifsg8hc8;
import 'fx_rates/fx_quote_view.dart' as _i8bj7347;
import 'fx_rates/fx_rate_quote.dart' as _i15udi7x;
import 'institutions/institution.dart' as _ikgmcjq7;
import 'institutions/institution_location.dart' as _iclizrec;
import 'ledger/journal.dart' as _iqqjzj2w;
import 'ledger/journal_line.dart' as _i6l0fo54;
import 'ledger/journal_line_input.dart' as _id7zp91q;
import 'ledger/ledger_account.dart' as _ivazbnnp;
import 'ledger/ledger_period_lock.dart' as _i7t4btg4;
import 'ledger/trial_balance_row_view.dart' as _i5gsx3ds;
import 'ledger/trial_balance_view.dart' as _i7q128aw;
import 'monthly_allocations/monthly_allocation.dart' as _igdgld5u;
import 'payees/payee.dart' as _ignezpci;
import 'plaid/plaid_connection.dart' as _i1vmvtrm;
import 'recurring_transactions/recurring_transaction.dart' as _i9is7zb8;
import 'reports/net_worth_account_row.dart' as _ieg4kkwo;
import 'reports/net_worth_currency_row.dart' as _if6ke1e2;
import 'reports/net_worth_entity_row.dart' as _i2p47r1m;
import 'reports/net_worth_granularity.dart' as _iiyi1fdi;
import 'reports/net_worth_history_view.dart' as _izpykydm;
import 'reports/net_worth_point.dart' as _ihwosu5p;
import 'reports/net_worth_view.dart' as _idk5va87;
import 'reports/report_grouping.dart' as _ijpgwwdu;
import 'reports/spending_row.dart' as _ikppksh7;
import 'settings/user_settings.dart' as _i99f9doz;
import 'tax/tax_band_slice_view.dart' as _ic4zfx3b;
import 'tax/tax_category_view.dart' as _iv5oayw3;
import 'tax/tax_figure_view.dart' as _ixm9q9lk;
import 'tax/tax_liability_view.dart' as _ivss6b81;
import 'tax/tax_opportunity_view.dart' as _iuft4v7q;
import 'tax/tax_profile.dart' as _i20z9jax;
import 'tax/tax_report_line_view.dart' as _i6llsezf;
import 'tax/tax_report_view.dart' as _inb54q20;
import 'tax/tax_rule_caveat_view.dart' as _i97pej5a;
import 'tax/tax_summary_category_total_view.dart' as _ilbx4erh;
import 'tax/tax_summary_fx_note_view.dart' as _iok5qj2e;
import 'tax/tax_summary_sales_tax_quarter_view.dart' as _it9yyajv;
import 'tax/tax_summary_sales_tax_rate_view.dart' as _iabhnw50;
import 'tax/tax_summary_view.dart' as _i5jsilqj;
import 'tax/tax_summary_wallet_view.dart' as _ij9k0z9z;
import 'transaction_rules/transaction_rule.dart' as _i6dj6ji0;
import 'transactions/import_result.dart' as _ibzcfs2k;
import 'transactions/import_row.dart' as _isp6bezg;
import 'transactions/reconcile_result.dart' as _igokbqfh;
import 'transactions/transaction.dart' as _iqhl4hru;
import 'transactions/transaction_flag.dart' as _i4fvctax;
import 'transactions/transaction_input.dart' as _ipd1rac6;
import 'transactions/transaction_kind.dart' as _ioneruif;
import 'transactions/transaction_line.dart' as _ipio7ws3;
import 'transactions/transaction_line_input.dart' as _imsv7m6w;
import 'transactions/transaction_page.dart' as _i7f3q91r;
import 'transactions/transaction_query.dart' as _ioinkgwn;
import 'transactions/transaction_status.dart' as _i3rynkdl;
import 'transactions/transaction_view.dart' as _ilixdhed;
import 'transactions/transfer.dart' as _ign516jt;
import 'transactions/transfer_input.dart' as _iah0rmrk;
import 'transactions/transfer_peer_view.dart' as _i3n9n3ej;
import 'wallets/holding_position.dart' as _iq0sbxsc;
import 'wallets/price_quality.dart' as _i6j30n20;
import 'wallets/price_source.dart' as _iu1a5mev;
import 'wallets/spam_verdict.dart' as _i4uehszw;
import 'wallets/wallet.dart' as _ilu5i0rn;
import 'wallets/wallet_holding.dart' as _iqqppnaa;
import 'wallets/wallet_network_state.dart' as _i73xhbar;
import 'wallets/wallet_preview.dart' as _iuw2colh;
import 'wallets/wallet_preview_network.dart' as _icbqx9y3;
import 'wallets/wallet_sync_result.dart' as _ipdq2p58;
import 'wallets/wallet_tax_year_summary.dart' as _ivsmsmw6;
import 'wallets/wallet_transaction.dart' as _i6m1jx15;
export 'accounts/account.dart';
export 'accounts/account_balances_view.dart';
export 'accounts/account_valuation.dart';
export 'accounts/valuation_source.dart';
export 'agent/agent_conversation.dart';
export 'agent/agent_event.dart';
export 'agent/agent_event_kind.dart';
export 'agent/agent_message.dart';
export 'agent/agent_message_role.dart';
export 'agent/agent_proposal.dart';
export 'agent/agent_proposal_kind.dart';
export 'agent/agent_proposal_status.dart';
export 'agent/agent_provider.dart';
export 'agent/agent_provider_settings_view.dart';
export 'agent/agent_usage_record.dart';
export 'agent/agent_usage_view.dart';
export 'agent/mcp/agent_access_token_created.dart';
export 'agent/mcp/agent_access_token_view.dart';
export 'audit/audit_action.dart';
export 'audit/audit_event.dart';
export 'audit/audit_subject.dart';
export 'billing/entitlement.dart';
export 'billing/entitlement_source.dart';
export 'billing/entitlement_status.dart';
export 'billing/solana_plan_view.dart';
export 'budget/allocation_input.dart';
export 'budget/budget_month_summary.dart';
export 'budget/budget_month_view.dart';
export 'budget/envelope_month_view.dart';
export 'budget_templates/budget_template.dart';
export 'budget_templates/budget_template_line.dart';
export 'categories/category.dart';
export 'common/confidence.dart';
export 'common/sync_status.dart';
export 'entities/change_scope.dart';
export 'entities/entity.dart';
export 'entities/entity_changed_event.dart';
export 'entities/entity_summary_view.dart';
export 'envelope_goals/envelope_goal.dart';
export 'envelope_goals/envelope_goal_kind.dart';
export 'envelopes/envelope.dart';
export 'exceptions/agent_allowance_exhausted_exception.dart';
export 'exceptions/agent_provider_exception.dart';
export 'exceptions/agent_provider_unavailable_exception.dart';
export 'exceptions/authentication_required_exception.dart';
export 'exceptions/billing_provider_exception.dart';
export 'exceptions/billing_rail_unavailable_exception.dart';
export 'exceptions/entitlement_required_exception.dart';
export 'exceptions/forbidden_exception.dart';
export 'exceptions/fx_rate_unavailable_exception.dart';
export 'exceptions/not_found_exception.dart';
export 'exceptions/tax_rules_unavailable_exception.dart';
export 'exceptions/validation_exception.dart';
export 'exceptions/wallet_preview_rate_limited_exception.dart';
export 'fx_rates/fx_latest_snapshot.dart';
export 'fx_rates/fx_provider.dart';
export 'fx_rates/fx_quote_view.dart';
export 'fx_rates/fx_rate_quote.dart';
export 'institutions/institution.dart';
export 'institutions/institution_location.dart';
export 'ledger/journal.dart';
export 'ledger/journal_line.dart';
export 'ledger/journal_line_input.dart';
export 'ledger/ledger_account.dart';
export 'ledger/ledger_period_lock.dart';
export 'ledger/trial_balance_row_view.dart';
export 'ledger/trial_balance_view.dart';
export 'monthly_allocations/monthly_allocation.dart';
export 'payees/payee.dart';
export 'plaid/plaid_connection.dart';
export 'recurring_transactions/recurring_transaction.dart';
export 'reports/net_worth_account_row.dart';
export 'reports/net_worth_currency_row.dart';
export 'reports/net_worth_entity_row.dart';
export 'reports/net_worth_granularity.dart';
export 'reports/net_worth_history_view.dart';
export 'reports/net_worth_point.dart';
export 'reports/net_worth_view.dart';
export 'reports/report_grouping.dart';
export 'reports/spending_row.dart';
export 'settings/user_settings.dart';
export 'tax/tax_band_slice_view.dart';
export 'tax/tax_category_view.dart';
export 'tax/tax_figure_view.dart';
export 'tax/tax_liability_view.dart';
export 'tax/tax_opportunity_view.dart';
export 'tax/tax_profile.dart';
export 'tax/tax_report_line_view.dart';
export 'tax/tax_report_view.dart';
export 'tax/tax_rule_caveat_view.dart';
export 'tax/tax_summary_category_total_view.dart';
export 'tax/tax_summary_fx_note_view.dart';
export 'tax/tax_summary_sales_tax_quarter_view.dart';
export 'tax/tax_summary_sales_tax_rate_view.dart';
export 'tax/tax_summary_view.dart';
export 'tax/tax_summary_wallet_view.dart';
export 'transaction_rules/transaction_rule.dart';
export 'transactions/import_result.dart';
export 'transactions/import_row.dart';
export 'transactions/reconcile_result.dart';
export 'transactions/transaction.dart';
export 'transactions/transaction_flag.dart';
export 'transactions/transaction_input.dart';
export 'transactions/transaction_kind.dart';
export 'transactions/transaction_line.dart';
export 'transactions/transaction_line_input.dart';
export 'transactions/transaction_page.dart';
export 'transactions/transaction_query.dart';
export 'transactions/transaction_status.dart';
export 'transactions/transaction_view.dart';
export 'transactions/transfer.dart';
export 'transactions/transfer_input.dart';
export 'transactions/transfer_peer_view.dart';
export 'wallets/holding_position.dart';
export 'wallets/price_quality.dart';
export 'wallets/price_source.dart';
export 'wallets/spam_verdict.dart';
export 'wallets/wallet.dart';
export 'wallets/wallet_holding.dart';
export 'wallets/wallet_network_state.dart';
export 'wallets/wallet_preview.dart';
export 'wallets/wallet_preview_network.dart';
export 'wallets/wallet_sync_result.dart';
export 'wallets/wallet_tax_year_summary.dart';
export 'wallets/wallet_transaction.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager
    implements _isc.ProtocolDeserializationProvider {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  @override
  _isc.ProtocolDeserialization get deserializationMetadata =>
      _isc.ProtocolDeserialization.cached(
        this,
        types: const [
          _isc.getType<_iz2jf14v.Account>,
          _isc.getType<_i53yl4yp.AccountBalancesView>,
          _isc.getType<_i87oqvv1.AccountValuation>,
          _isc.getType<_ig9cy6ku.ValuationSource>,
          _isc.getType<_isfmgqgu.AgentConversation>,
          _isc.getType<_i769eo9u.AgentEvent>,
          _isc.getType<_iyhb15ax.AgentEventKind>,
          _isc.getType<_inwxyid7.AgentMessage>,
          _isc.getType<_iy2njbiw.AgentMessageRole>,
          _isc.getType<_iqh65hzq.AgentProposal>,
          _isc.getType<_idxyy01n.AgentProposalKind>,
          _isc.getType<_iksk16ej.AgentProposalStatus>,
          _isc.getType<_ic667156.AgentProvider>,
          _isc.getType<_i0760q1h.AgentProviderSettingsView>,
          _isc.getType<_igo4k2bu.AgentUsageRecord>,
          _isc.getType<_ipqjijih.AgentUsageView>,
          _isc.getType<_iis6jewo.AgentAccessTokenCreated>,
          _isc.getType<_i4mcrc97.AgentAccessTokenView>,
          _isc.getType<_iqje9mi5.AuditAction>,
          _isc.getType<_ijhj7cd7.AuditEvent>,
          _isc.getType<_i2sn5a56.AuditSubject>,
          _isc.getType<_iq2w1sa5.Entitlement>,
          _isc.getType<_ipnf4x0i.EntitlementSource>,
          _isc.getType<_imqwzx9j.EntitlementStatus>,
          _isc.getType<_iwxkomal.SolanaPlanView>,
          _isc.getType<_iouaddet.AllocationInput>,
          _isc.getType<_ixyov90t.BudgetMonthSummary>,
          _isc.getType<_ihanl5km.BudgetMonthView>,
          _isc.getType<_ii8h2sft.EnvelopeMonthView>,
          _isc.getType<_i01fne9j.BudgetTemplate>,
          _isc.getType<_iagnrffn.BudgetTemplateLine>,
          _isc.getType<_iwxpkdmg.Category>,
          _isc.getType<_i4zfq652.Confidence>,
          _isc.getType<_iynfhhr3.SyncStatus>,
          _isc.getType<_i03vgs6n.ChangeScope>,
          _isc.getType<_iamyw1yn.Entity>,
          _isc.getType<_is12mxpv.EntityChangedEvent>,
          _isc.getType<_ihqn2h4c.EntitySummaryView>,
          _isc.getType<_ifl4yivq.EnvelopeGoal>,
          _isc.getType<_i61aeoqs.EnvelopeGoalKind>,
          _isc.getType<_ikt21dfw.Envelope>,
          _isc.getType<_iozei2bz.AgentAllowanceExhaustedException>,
          _isc.getType<_iurccglg.AgentProviderException>,
          _isc.getType<_i6p28blo.AgentProviderUnavailableException>,
          _isc.getType<_io2kod1y.AuthenticationRequiredException>,
          _isc.getType<_i9zkhl6f.BillingProviderException>,
          _isc.getType<_i5kq7itn.BillingRailUnavailableException>,
          _isc.getType<_ik3lny6q.EntitlementRequiredException>,
          _isc.getType<_iha6yc5u.ForbiddenException>,
          _isc.getType<_if5umnl3.FxRateUnavailableException>,
          _isc.getType<_izob2ctl.NotFoundException>,
          _isc.getType<_i4yu9vcq.TaxRulesUnavailableException>,
          _isc.getType<_igpdbyom.ValidationException>,
          _isc.getType<_i4nmh6wd.WalletPreviewRateLimitedException>,
          _isc.getType<_i8cxakqz.FxLatestSnapshot>,
          _isc.getType<_ifsg8hc8.FxProvider>,
          _isc.getType<_i8bj7347.FxQuoteView>,
          _isc.getType<_i15udi7x.FxRateQuote>,
          _isc.getType<_ikgmcjq7.Institution>,
          _isc.getType<_iclizrec.InstitutionLocation>,
          _isc.getType<_iqqjzj2w.Journal>,
          _isc.getType<_i6l0fo54.JournalLine>,
          _isc.getType<_id7zp91q.JournalLineInput>,
          _isc.getType<_ivazbnnp.LedgerAccount>,
          _isc.getType<_i7t4btg4.LedgerPeriodLock>,
          _isc.getType<_i5gsx3ds.TrialBalanceRowView>,
          _isc.getType<_i7q128aw.TrialBalanceView>,
          _isc.getType<_igdgld5u.MonthlyAllocation>,
          _isc.getType<_ignezpci.Payee>,
          _isc.getType<_i1vmvtrm.PlaidConnection>,
          _isc.getType<_i9is7zb8.RecurringTransaction>,
          _isc.getType<_ieg4kkwo.NetWorthAccountRow>,
          _isc.getType<_if6ke1e2.NetWorthCurrencyRow>,
          _isc.getType<_i2p47r1m.NetWorthEntityRow>,
          _isc.getType<_iiyi1fdi.NetWorthGranularity>,
          _isc.getType<_izpykydm.NetWorthHistoryView>,
          _isc.getType<_ihwosu5p.NetWorthPoint>,
          _isc.getType<_idk5va87.NetWorthView>,
          _isc.getType<_ijpgwwdu.ReportGrouping>,
          _isc.getType<_ikppksh7.SpendingRow>,
          _isc.getType<_i99f9doz.UserSettings>,
          _isc.getType<_ic4zfx3b.TaxBandSliceView>,
          _isc.getType<_iv5oayw3.TaxCategoryView>,
          _isc.getType<_ixm9q9lk.TaxFigureView>,
          _isc.getType<_ivss6b81.TaxLiabilityView>,
          _isc.getType<_iuft4v7q.TaxOpportunityView>,
          _isc.getType<_i20z9jax.TaxProfileRecord>,
          _isc.getType<_i6llsezf.TaxReportLineView>,
          _isc.getType<_inb54q20.TaxReportView>,
          _isc.getType<_i97pej5a.TaxRuleCaveatView>,
          _isc.getType<_ilbx4erh.TaxSummaryCategoryTotalView>,
          _isc.getType<_iok5qj2e.TaxSummaryFxNoteView>,
          _isc.getType<_it9yyajv.TaxSummarySalesTaxQuarterView>,
          _isc.getType<_iabhnw50.TaxSummarySalesTaxRateView>,
          _isc.getType<_i5jsilqj.TaxSummaryView>,
          _isc.getType<_ij9k0z9z.TaxSummaryWalletView>,
          _isc.getType<_i6dj6ji0.TransactionRule>,
          _isc.getType<_ibzcfs2k.ImportResult>,
          _isc.getType<_isp6bezg.ImportRow>,
          _isc.getType<_igokbqfh.ReconcileResult>,
          _isc.getType<_iqhl4hru.Transaction>,
          _isc.getType<_i4fvctax.TransactionFlag>,
          _isc.getType<_ipd1rac6.TransactionInput>,
          _isc.getType<_ioneruif.TransactionKind>,
          _isc.getType<_ipio7ws3.TransactionLine>,
          _isc.getType<_imsv7m6w.TransactionLineInput>,
          _isc.getType<_i7f3q91r.TransactionPage>,
          _isc.getType<_ioinkgwn.TransactionQuery>,
          _isc.getType<_i3rynkdl.TransactionStatus>,
          _isc.getType<_ilixdhed.TransactionView>,
          _isc.getType<_ign516jt.Transfer>,
          _isc.getType<_iah0rmrk.TransferInput>,
          _isc.getType<_i3n9n3ej.TransferPeerView>,
          _isc.getType<_iq0sbxsc.HoldingPosition>,
          _isc.getType<_i6j30n20.PriceQuality>,
          _isc.getType<_iu1a5mev.PriceSource>,
          _isc.getType<_i4uehszw.SpamVerdict>,
          _isc.getType<_ilu5i0rn.Wallet>,
          _isc.getType<_iqqppnaa.WalletHolding>,
          _isc.getType<_i73xhbar.WalletNetworkState>,
          _isc.getType<_iuw2colh.WalletPreview>,
          _isc.getType<_icbqx9y3.WalletPreviewNetwork>,
          _isc.getType<_ipdq2p58.WalletSyncResult>,
          _isc.getType<_ivsmsmw6.WalletTaxYearSummary>,
          _isc.getType<_i6m1jx15.WalletTransaction>,
          _isc.getType<_iz2jf14v.Account?>,
          _isc.getType<_i53yl4yp.AccountBalancesView?>,
          _isc.getType<_i87oqvv1.AccountValuation?>,
          _isc.getType<_ig9cy6ku.ValuationSource?>,
          _isc.getType<_isfmgqgu.AgentConversation?>,
          _isc.getType<_i769eo9u.AgentEvent?>,
          _isc.getType<_iyhb15ax.AgentEventKind?>,
          _isc.getType<_inwxyid7.AgentMessage?>,
          _isc.getType<_iy2njbiw.AgentMessageRole?>,
          _isc.getType<_iqh65hzq.AgentProposal?>,
          _isc.getType<_idxyy01n.AgentProposalKind?>,
          _isc.getType<_iksk16ej.AgentProposalStatus?>,
          _isc.getType<_ic667156.AgentProvider?>,
          _isc.getType<_i0760q1h.AgentProviderSettingsView?>,
          _isc.getType<_igo4k2bu.AgentUsageRecord?>,
          _isc.getType<_ipqjijih.AgentUsageView?>,
          _isc.getType<_iis6jewo.AgentAccessTokenCreated?>,
          _isc.getType<_i4mcrc97.AgentAccessTokenView?>,
          _isc.getType<_iqje9mi5.AuditAction?>,
          _isc.getType<_ijhj7cd7.AuditEvent?>,
          _isc.getType<_i2sn5a56.AuditSubject?>,
          _isc.getType<_iq2w1sa5.Entitlement?>,
          _isc.getType<_ipnf4x0i.EntitlementSource?>,
          _isc.getType<_imqwzx9j.EntitlementStatus?>,
          _isc.getType<_iwxkomal.SolanaPlanView?>,
          _isc.getType<_iouaddet.AllocationInput?>,
          _isc.getType<_ixyov90t.BudgetMonthSummary?>,
          _isc.getType<_ihanl5km.BudgetMonthView?>,
          _isc.getType<_ii8h2sft.EnvelopeMonthView?>,
          _isc.getType<_i01fne9j.BudgetTemplate?>,
          _isc.getType<_iagnrffn.BudgetTemplateLine?>,
          _isc.getType<_iwxpkdmg.Category?>,
          _isc.getType<_i4zfq652.Confidence?>,
          _isc.getType<_iynfhhr3.SyncStatus?>,
          _isc.getType<_i03vgs6n.ChangeScope?>,
          _isc.getType<_iamyw1yn.Entity?>,
          _isc.getType<_is12mxpv.EntityChangedEvent?>,
          _isc.getType<_ihqn2h4c.EntitySummaryView?>,
          _isc.getType<_ifl4yivq.EnvelopeGoal?>,
          _isc.getType<_i61aeoqs.EnvelopeGoalKind?>,
          _isc.getType<_ikt21dfw.Envelope?>,
          _isc.getType<_iozei2bz.AgentAllowanceExhaustedException?>,
          _isc.getType<_iurccglg.AgentProviderException?>,
          _isc.getType<_i6p28blo.AgentProviderUnavailableException?>,
          _isc.getType<_io2kod1y.AuthenticationRequiredException?>,
          _isc.getType<_i9zkhl6f.BillingProviderException?>,
          _isc.getType<_i5kq7itn.BillingRailUnavailableException?>,
          _isc.getType<_ik3lny6q.EntitlementRequiredException?>,
          _isc.getType<_iha6yc5u.ForbiddenException?>,
          _isc.getType<_if5umnl3.FxRateUnavailableException?>,
          _isc.getType<_izob2ctl.NotFoundException?>,
          _isc.getType<_i4yu9vcq.TaxRulesUnavailableException?>,
          _isc.getType<_igpdbyom.ValidationException?>,
          _isc.getType<_i4nmh6wd.WalletPreviewRateLimitedException?>,
          _isc.getType<_i8cxakqz.FxLatestSnapshot?>,
          _isc.getType<_ifsg8hc8.FxProvider?>,
          _isc.getType<_i8bj7347.FxQuoteView?>,
          _isc.getType<_i15udi7x.FxRateQuote?>,
          _isc.getType<_ikgmcjq7.Institution?>,
          _isc.getType<_iclizrec.InstitutionLocation?>,
          _isc.getType<_iqqjzj2w.Journal?>,
          _isc.getType<_i6l0fo54.JournalLine?>,
          _isc.getType<_id7zp91q.JournalLineInput?>,
          _isc.getType<_ivazbnnp.LedgerAccount?>,
          _isc.getType<_i7t4btg4.LedgerPeriodLock?>,
          _isc.getType<_i5gsx3ds.TrialBalanceRowView?>,
          _isc.getType<_i7q128aw.TrialBalanceView?>,
          _isc.getType<_igdgld5u.MonthlyAllocation?>,
          _isc.getType<_ignezpci.Payee?>,
          _isc.getType<_i1vmvtrm.PlaidConnection?>,
          _isc.getType<_i9is7zb8.RecurringTransaction?>,
          _isc.getType<_ieg4kkwo.NetWorthAccountRow?>,
          _isc.getType<_if6ke1e2.NetWorthCurrencyRow?>,
          _isc.getType<_i2p47r1m.NetWorthEntityRow?>,
          _isc.getType<_iiyi1fdi.NetWorthGranularity?>,
          _isc.getType<_izpykydm.NetWorthHistoryView?>,
          _isc.getType<_ihwosu5p.NetWorthPoint?>,
          _isc.getType<_idk5va87.NetWorthView?>,
          _isc.getType<_ijpgwwdu.ReportGrouping?>,
          _isc.getType<_ikppksh7.SpendingRow?>,
          _isc.getType<_i99f9doz.UserSettings?>,
          _isc.getType<_ic4zfx3b.TaxBandSliceView?>,
          _isc.getType<_iv5oayw3.TaxCategoryView?>,
          _isc.getType<_ixm9q9lk.TaxFigureView?>,
          _isc.getType<_ivss6b81.TaxLiabilityView?>,
          _isc.getType<_iuft4v7q.TaxOpportunityView?>,
          _isc.getType<_i20z9jax.TaxProfileRecord?>,
          _isc.getType<_i6llsezf.TaxReportLineView?>,
          _isc.getType<_inb54q20.TaxReportView?>,
          _isc.getType<_i97pej5a.TaxRuleCaveatView?>,
          _isc.getType<_ilbx4erh.TaxSummaryCategoryTotalView?>,
          _isc.getType<_iok5qj2e.TaxSummaryFxNoteView?>,
          _isc.getType<_it9yyajv.TaxSummarySalesTaxQuarterView?>,
          _isc.getType<_iabhnw50.TaxSummarySalesTaxRateView?>,
          _isc.getType<_i5jsilqj.TaxSummaryView?>,
          _isc.getType<_ij9k0z9z.TaxSummaryWalletView?>,
          _isc.getType<_i6dj6ji0.TransactionRule?>,
          _isc.getType<_ibzcfs2k.ImportResult?>,
          _isc.getType<_isp6bezg.ImportRow?>,
          _isc.getType<_igokbqfh.ReconcileResult?>,
          _isc.getType<_iqhl4hru.Transaction?>,
          _isc.getType<_i4fvctax.TransactionFlag?>,
          _isc.getType<_ipd1rac6.TransactionInput?>,
          _isc.getType<_ioneruif.TransactionKind?>,
          _isc.getType<_ipio7ws3.TransactionLine?>,
          _isc.getType<_imsv7m6w.TransactionLineInput?>,
          _isc.getType<_i7f3q91r.TransactionPage?>,
          _isc.getType<_ioinkgwn.TransactionQuery?>,
          _isc.getType<_i3rynkdl.TransactionStatus?>,
          _isc.getType<_ilixdhed.TransactionView?>,
          _isc.getType<_ign516jt.Transfer?>,
          _isc.getType<_iah0rmrk.TransferInput?>,
          _isc.getType<_i3n9n3ej.TransferPeerView?>,
          _isc.getType<_iq0sbxsc.HoldingPosition?>,
          _isc.getType<_i6j30n20.PriceQuality?>,
          _isc.getType<_iu1a5mev.PriceSource?>,
          _isc.getType<_i4uehszw.SpamVerdict?>,
          _isc.getType<_ilu5i0rn.Wallet?>,
          _isc.getType<_iqqppnaa.WalletHolding?>,
          _isc.getType<_i73xhbar.WalletNetworkState?>,
          _isc.getType<_iuw2colh.WalletPreview?>,
          _isc.getType<_icbqx9y3.WalletPreviewNetwork?>,
          _isc.getType<_ipdq2p58.WalletSyncResult?>,
          _isc.getType<_ivsmsmw6.WalletTaxYearSummary?>,
          _isc.getType<_i6m1jx15.WalletTransaction?>,
          _isc.getType<List<_iwxpkdmg.Category>>,
          _isc.getType<List<_ii8h2sft.EnvelopeMonthView>>,
          _isc.getType<List<_i15udi7x.FxRateQuote>>,
          _isc.getType<List<_i5gsx3ds.TrialBalanceRowView>>,
          _isc.getType<List<_ihwosu5p.NetWorthPoint>>,
          _isc.getType<List<String>>,
          _isc.getType<List<_if6ke1e2.NetWorthCurrencyRow>>,
          _isc.getType<List<_i2p47r1m.NetWorthEntityRow>>,
          _isc.getType<List<_ieg4kkwo.NetWorthAccountRow>>,
          _isc.getType<List<_ic4zfx3b.TaxBandSliceView>>,
          _isc.getType<List<_i6llsezf.TaxReportLineView>>,
          _isc.getType<List<_ivss6b81.TaxLiabilityView>>,
          _isc.getType<List<_i97pej5a.TaxRuleCaveatView>>,
          _isc.getType<List<_ixm9q9lk.TaxFigureView>>,
          _isc.getType<Map<String, String>>,
          _isc.getType<List<_iuft4v7q.TaxOpportunityView>>,
          _isc.getType<List<_ilbx4erh.TaxSummaryCategoryTotalView>>,
          _isc.getType<List<_iabhnw50.TaxSummarySalesTaxRateView>>,
          _isc.getType<List<_it9yyajv.TaxSummarySalesTaxQuarterView>>,
          _isc.getType<List<_ij9k0z9z.TaxSummaryWalletView>>,
          _isc.getType<List<_iok5qj2e.TaxSummaryFxNoteView>>,
          _isc.getType<List<_imsv7m6w.TransactionLineInput>>,
          _isc.getType<List<_ilixdhed.TransactionView>>,
          _isc.getType<List<_ipio7ws3.TransactionLine>>,
          _isc.getType<List<_ifz8weqz.WalletNetwork>>,
          _isc.getType<List<_ifz8weqz.WalletNetwork>?>,
          _isc.getType<List<_icbqx9y3.WalletPreviewNetwork>>,
          _isc.getType<List<String>?>,
          _isc.getType<List<_iqudaadl.Account>>,
          _isc.getType<List<_isc.UuidValue>>,
          _isc.getType<List<_idms9t2z.AccountValuation>>,
          _isc.getType<List<_in44ixo7.AgentConversation>>,
          _isc.getType<List<_i8fbky0c.AgentMessage>>,
          _isc.getType<List<_icv7zzda.AgentProposal>>,
          _isc.getType<List<_itxn3wek.AgentAccessTokenView>>,
          _isc.getType<List<_inutgv28.AllocationInput>>,
          _isc.getType<List<_itiojbb0.BudgetTemplate>>,
          _isc.getType<List<_ik2p0evm.BudgetTemplateLine>>,
          _isc.getType<List<_iels1fku.Category>>,
          _isc.getType<List<_i2ulk6h5.Entity>>,
          _isc.getType<List<_ib1vbiwb.EntitySummaryView>>,
          _isc.getType<List<_ibdhi9gv.EnvelopeGoal>>,
          _isc.getType<List<_i29jf3by.Envelope>>,
          _isc.getType<List<_i6ysl1a4.Institution>>,
          _isc.getType<List<_ixq9t892.LedgerAccount>>,
          _isc.getType<List<_i3j8x5or.JournalLineInput>>,
          _isc.getType<List<_izuizaeu.Journal>>,
          _isc.getType<List<_iwruw2s3.JournalLine>>,
          _isc.getType<List<_ioe147d0.AuditEvent>>,
          _isc.getType<List<_iaf6ifsb.Payee>>,
          _isc.getType<List<_itydqisw.PlaidConnection>>,
          _isc.getType<List<_i41tn6nr.RecurringTransaction>>,
          _isc.getType<List<_isc.UuidValue>?>,
          _isc.getType<List<_ia9y0al9.SpendingRow>>,
          _isc.getType<List<_i52laypj.BudgetMonthSummary>>,
          _isc.getType<List<_ic177lol.TaxCategoryView>>,
          _isc.getType<List<_iwxd5v0a.TransactionRule>>,
          _isc.getType<List<_irfj6dpt.TransactionView>>,
          _isc.getType<List<_iyud7cy9.ImportRow>>,
          _isc.getType<List<_ifz8weqz.WalletNetwork>>,
          _isc.getType<List<_ifz8weqz.WalletNetwork>?>,
          _isc.getType<List<_i9c4hszu.WalletNetworkState>>,
          _isc.getType<List<_igzh8mor.Wallet>>,
          _isc.getType<List<_izm3e498.WalletHolding>>,
          _isc.getType<List<_itxp58mr.WalletTransaction>>,
          _isc.getType<List<_il62txu0.WalletTaxYearSummary>>,
          _isc.getType<List<String>>,
          _isc.getType<List<String>?>,
        ],
        modules: const [
          _iaic.Protocol.new,
          _iacc.Protocol.new,
          _ifz8weqz.Protocol.new,
        ],
        classNames: const [
          'Account',
          'AccountBalancesView',
          'AccountValuation',
          'ValuationSource',
          'AgentConversation',
          'AgentEvent',
          'AgentEventKind',
          'AgentMessage',
          'AgentMessageRole',
          'AgentProposal',
          'AgentProposalKind',
          'AgentProposalStatus',
          'AgentProvider',
          'AgentProviderSettingsView',
          'AgentUsageRecord',
          'AgentUsageView',
          'AgentAccessTokenCreated',
          'AgentAccessTokenView',
          'AuditAction',
          'AuditEvent',
          'AuditSubject',
          'Entitlement',
          'EntitlementSource',
          'EntitlementStatus',
          'SolanaPlanView',
          'AllocationInput',
          'BudgetMonthSummary',
          'BudgetMonthView',
          'EnvelopeMonthView',
          'BudgetTemplate',
          'BudgetTemplateLine',
          'Category',
          'Confidence',
          'SyncStatus',
          'ChangeScope',
          'Entity',
          'EntityChangedEvent',
          'EntitySummaryView',
          'EnvelopeGoal',
          'EnvelopeGoalKind',
          'Envelope',
          'AgentAllowanceExhaustedException',
          'AgentProviderException',
          'AgentProviderUnavailableException',
          'AuthenticationRequiredException',
          'BillingProviderException',
          'BillingRailUnavailableException',
          'EntitlementRequiredException',
          'ForbiddenException',
          'FxRateUnavailableException',
          'NotFoundException',
          'TaxRulesUnavailableException',
          'ValidationException',
          'WalletPreviewRateLimitedException',
          'FxLatestSnapshot',
          'FxProvider',
          'FxQuoteView',
          'FxRateQuote',
          'Institution',
          'InstitutionLocation',
          'Journal',
          'JournalLine',
          'JournalLineInput',
          'LedgerAccount',
          'LedgerPeriodLock',
          'TrialBalanceRowView',
          'TrialBalanceView',
          'MonthlyAllocation',
          'Payee',
          'PlaidConnection',
          'RecurringTransaction',
          'NetWorthAccountRow',
          'NetWorthCurrencyRow',
          'NetWorthEntityRow',
          'NetWorthGranularity',
          'NetWorthHistoryView',
          'NetWorthPoint',
          'NetWorthView',
          'ReportGrouping',
          'SpendingRow',
          'UserSettings',
          'TaxBandSliceView',
          'TaxCategoryView',
          'TaxFigureView',
          'TaxLiabilityView',
          'TaxOpportunityView',
          'TaxProfileRecord',
          'TaxReportLineView',
          'TaxReportView',
          'TaxRuleCaveatView',
          'TaxSummaryCategoryTotalView',
          'TaxSummaryFxNoteView',
          'TaxSummarySalesTaxQuarterView',
          'TaxSummarySalesTaxRateView',
          'TaxSummaryView',
          'TaxSummaryWalletView',
          'TransactionRule',
          'ImportResult',
          'ImportRow',
          'ReconcileResult',
          'Transaction',
          'TransactionFlag',
          'TransactionInput',
          'TransactionKind',
          'TransactionLine',
          'TransactionLineInput',
          'TransactionPage',
          'TransactionQuery',
          'TransactionStatus',
          'TransactionView',
          'Transfer',
          'TransferInput',
          'TransferPeerView',
          'HoldingPosition',
          'PriceQuality',
          'PriceSource',
          'SpamVerdict',
          'Wallet',
          'WalletHolding',
          'WalletNetworkState',
          'WalletPreview',
          'WalletPreviewNetwork',
          'WalletSyncResult',
          'WalletTaxYearSummary',
          'WalletTransaction',
        ],
      );

  static String? getClassNameFromObjectJson(dynamic data) =>
      _isc.ProtocolDeserialization.readClassName(data);

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    final rawDataClassName = _isc.ProtocolDeserialization.readClassName(data);
    final dataClassName = rawDataClassName;
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _iz2jf14v.Account) {
      return _iz2jf14v.Account.fromJson(data) as T;
    }
    if (t == _i53yl4yp.AccountBalancesView) {
      return _i53yl4yp.AccountBalancesView.fromJson(data) as T;
    }
    if (t == _i87oqvv1.AccountValuation) {
      return _i87oqvv1.AccountValuation.fromJson(data) as T;
    }
    if (t == _ig9cy6ku.ValuationSource) {
      return _ig9cy6ku.ValuationSource.fromJson(data) as T;
    }
    if (t == _isfmgqgu.AgentConversation) {
      return _isfmgqgu.AgentConversation.fromJson(data) as T;
    }
    if (t == _i769eo9u.AgentEvent) {
      return _i769eo9u.AgentEvent.fromJson(data) as T;
    }
    if (t == _iyhb15ax.AgentEventKind) {
      return _iyhb15ax.AgentEventKind.fromJson(data) as T;
    }
    if (t == _inwxyid7.AgentMessage) {
      return _inwxyid7.AgentMessage.fromJson(data) as T;
    }
    if (t == _iy2njbiw.AgentMessageRole) {
      return _iy2njbiw.AgentMessageRole.fromJson(data) as T;
    }
    if (t == _iqh65hzq.AgentProposal) {
      return _iqh65hzq.AgentProposal.fromJson(data) as T;
    }
    if (t == _idxyy01n.AgentProposalKind) {
      return _idxyy01n.AgentProposalKind.fromJson(data) as T;
    }
    if (t == _iksk16ej.AgentProposalStatus) {
      return _iksk16ej.AgentProposalStatus.fromJson(data) as T;
    }
    if (t == _ic667156.AgentProvider) {
      return _ic667156.AgentProvider.fromJson(data) as T;
    }
    if (t == _i0760q1h.AgentProviderSettingsView) {
      return _i0760q1h.AgentProviderSettingsView.fromJson(data) as T;
    }
    if (t == _igo4k2bu.AgentUsageRecord) {
      return _igo4k2bu.AgentUsageRecord.fromJson(data) as T;
    }
    if (t == _ipqjijih.AgentUsageView) {
      return _ipqjijih.AgentUsageView.fromJson(data) as T;
    }
    if (t == _iis6jewo.AgentAccessTokenCreated) {
      return _iis6jewo.AgentAccessTokenCreated.fromJson(data) as T;
    }
    if (t == _i4mcrc97.AgentAccessTokenView) {
      return _i4mcrc97.AgentAccessTokenView.fromJson(data) as T;
    }
    if (t == _iqje9mi5.AuditAction) {
      return _iqje9mi5.AuditAction.fromJson(data) as T;
    }
    if (t == _ijhj7cd7.AuditEvent) {
      return _ijhj7cd7.AuditEvent.fromJson(data) as T;
    }
    if (t == _i2sn5a56.AuditSubject) {
      return _i2sn5a56.AuditSubject.fromJson(data) as T;
    }
    if (t == _iq2w1sa5.Entitlement) {
      return _iq2w1sa5.Entitlement.fromJson(data) as T;
    }
    if (t == _ipnf4x0i.EntitlementSource) {
      return _ipnf4x0i.EntitlementSource.fromJson(data) as T;
    }
    if (t == _imqwzx9j.EntitlementStatus) {
      return _imqwzx9j.EntitlementStatus.fromJson(data) as T;
    }
    if (t == _iwxkomal.SolanaPlanView) {
      return _iwxkomal.SolanaPlanView.fromJson(data) as T;
    }
    if (t == _iouaddet.AllocationInput) {
      return _iouaddet.AllocationInput.fromJson(data) as T;
    }
    if (t == _ixyov90t.BudgetMonthSummary) {
      return _ixyov90t.BudgetMonthSummary.fromJson(data) as T;
    }
    if (t == _ihanl5km.BudgetMonthView) {
      return _ihanl5km.BudgetMonthView.fromJson(data) as T;
    }
    if (t == _ii8h2sft.EnvelopeMonthView) {
      return _ii8h2sft.EnvelopeMonthView.fromJson(data) as T;
    }
    if (t == _i01fne9j.BudgetTemplate) {
      return _i01fne9j.BudgetTemplate.fromJson(data) as T;
    }
    if (t == _iagnrffn.BudgetTemplateLine) {
      return _iagnrffn.BudgetTemplateLine.fromJson(data) as T;
    }
    if (t == _iwxpkdmg.Category) {
      return _iwxpkdmg.Category.fromJson(data) as T;
    }
    if (t == _i4zfq652.Confidence) {
      return _i4zfq652.Confidence.fromJson(data) as T;
    }
    if (t == _iynfhhr3.SyncStatus) {
      return _iynfhhr3.SyncStatus.fromJson(data) as T;
    }
    if (t == _i03vgs6n.ChangeScope) {
      return _i03vgs6n.ChangeScope.fromJson(data) as T;
    }
    if (t == _iamyw1yn.Entity) {
      return _iamyw1yn.Entity.fromJson(data) as T;
    }
    if (t == _is12mxpv.EntityChangedEvent) {
      return _is12mxpv.EntityChangedEvent.fromJson(data) as T;
    }
    if (t == _ihqn2h4c.EntitySummaryView) {
      return _ihqn2h4c.EntitySummaryView.fromJson(data) as T;
    }
    if (t == _ifl4yivq.EnvelopeGoal) {
      return _ifl4yivq.EnvelopeGoal.fromJson(data) as T;
    }
    if (t == _i61aeoqs.EnvelopeGoalKind) {
      return _i61aeoqs.EnvelopeGoalKind.fromJson(data) as T;
    }
    if (t == _ikt21dfw.Envelope) {
      return _ikt21dfw.Envelope.fromJson(data) as T;
    }
    if (t == _iozei2bz.AgentAllowanceExhaustedException) {
      return _iozei2bz.AgentAllowanceExhaustedException.fromJson(data) as T;
    }
    if (t == _iurccglg.AgentProviderException) {
      return _iurccglg.AgentProviderException.fromJson(data) as T;
    }
    if (t == _i6p28blo.AgentProviderUnavailableException) {
      return _i6p28blo.AgentProviderUnavailableException.fromJson(data) as T;
    }
    if (t == _io2kod1y.AuthenticationRequiredException) {
      return _io2kod1y.AuthenticationRequiredException.fromJson(data) as T;
    }
    if (t == _i9zkhl6f.BillingProviderException) {
      return _i9zkhl6f.BillingProviderException.fromJson(data) as T;
    }
    if (t == _i5kq7itn.BillingRailUnavailableException) {
      return _i5kq7itn.BillingRailUnavailableException.fromJson(data) as T;
    }
    if (t == _ik3lny6q.EntitlementRequiredException) {
      return _ik3lny6q.EntitlementRequiredException.fromJson(data) as T;
    }
    if (t == _iha6yc5u.ForbiddenException) {
      return _iha6yc5u.ForbiddenException.fromJson(data) as T;
    }
    if (t == _if5umnl3.FxRateUnavailableException) {
      return _if5umnl3.FxRateUnavailableException.fromJson(data) as T;
    }
    if (t == _izob2ctl.NotFoundException) {
      return _izob2ctl.NotFoundException.fromJson(data) as T;
    }
    if (t == _i4yu9vcq.TaxRulesUnavailableException) {
      return _i4yu9vcq.TaxRulesUnavailableException.fromJson(data) as T;
    }
    if (t == _igpdbyom.ValidationException) {
      return _igpdbyom.ValidationException.fromJson(data) as T;
    }
    if (t == _i4nmh6wd.WalletPreviewRateLimitedException) {
      return _i4nmh6wd.WalletPreviewRateLimitedException.fromJson(data) as T;
    }
    if (t == _i8cxakqz.FxLatestSnapshot) {
      return _i8cxakqz.FxLatestSnapshot.fromJson(data) as T;
    }
    if (t == _ifsg8hc8.FxProvider) {
      return _ifsg8hc8.FxProvider.fromJson(data) as T;
    }
    if (t == _i8bj7347.FxQuoteView) {
      return _i8bj7347.FxQuoteView.fromJson(data) as T;
    }
    if (t == _i15udi7x.FxRateQuote) {
      return _i15udi7x.FxRateQuote.fromJson(data) as T;
    }
    if (t == _ikgmcjq7.Institution) {
      return _ikgmcjq7.Institution.fromJson(data) as T;
    }
    if (t == _iclizrec.InstitutionLocation) {
      return _iclizrec.InstitutionLocation.fromJson(data) as T;
    }
    if (t == _iqqjzj2w.Journal) {
      return _iqqjzj2w.Journal.fromJson(data) as T;
    }
    if (t == _i6l0fo54.JournalLine) {
      return _i6l0fo54.JournalLine.fromJson(data) as T;
    }
    if (t == _id7zp91q.JournalLineInput) {
      return _id7zp91q.JournalLineInput.fromJson(data) as T;
    }
    if (t == _ivazbnnp.LedgerAccount) {
      return _ivazbnnp.LedgerAccount.fromJson(data) as T;
    }
    if (t == _i7t4btg4.LedgerPeriodLock) {
      return _i7t4btg4.LedgerPeriodLock.fromJson(data) as T;
    }
    if (t == _i5gsx3ds.TrialBalanceRowView) {
      return _i5gsx3ds.TrialBalanceRowView.fromJson(data) as T;
    }
    if (t == _i7q128aw.TrialBalanceView) {
      return _i7q128aw.TrialBalanceView.fromJson(data) as T;
    }
    if (t == _igdgld5u.MonthlyAllocation) {
      return _igdgld5u.MonthlyAllocation.fromJson(data) as T;
    }
    if (t == _ignezpci.Payee) {
      return _ignezpci.Payee.fromJson(data) as T;
    }
    if (t == _i1vmvtrm.PlaidConnection) {
      return _i1vmvtrm.PlaidConnection.fromJson(data) as T;
    }
    if (t == _i9is7zb8.RecurringTransaction) {
      return _i9is7zb8.RecurringTransaction.fromJson(data) as T;
    }
    if (t == _ieg4kkwo.NetWorthAccountRow) {
      return _ieg4kkwo.NetWorthAccountRow.fromJson(data) as T;
    }
    if (t == _if6ke1e2.NetWorthCurrencyRow) {
      return _if6ke1e2.NetWorthCurrencyRow.fromJson(data) as T;
    }
    if (t == _i2p47r1m.NetWorthEntityRow) {
      return _i2p47r1m.NetWorthEntityRow.fromJson(data) as T;
    }
    if (t == _iiyi1fdi.NetWorthGranularity) {
      return _iiyi1fdi.NetWorthGranularity.fromJson(data) as T;
    }
    if (t == _izpykydm.NetWorthHistoryView) {
      return _izpykydm.NetWorthHistoryView.fromJson(data) as T;
    }
    if (t == _ihwosu5p.NetWorthPoint) {
      return _ihwosu5p.NetWorthPoint.fromJson(data) as T;
    }
    if (t == _idk5va87.NetWorthView) {
      return _idk5va87.NetWorthView.fromJson(data) as T;
    }
    if (t == _ijpgwwdu.ReportGrouping) {
      return _ijpgwwdu.ReportGrouping.fromJson(data) as T;
    }
    if (t == _ikppksh7.SpendingRow) {
      return _ikppksh7.SpendingRow.fromJson(data) as T;
    }
    if (t == _i99f9doz.UserSettings) {
      return _i99f9doz.UserSettings.fromJson(data) as T;
    }
    if (t == _ic4zfx3b.TaxBandSliceView) {
      return _ic4zfx3b.TaxBandSliceView.fromJson(data) as T;
    }
    if (t == _iv5oayw3.TaxCategoryView) {
      return _iv5oayw3.TaxCategoryView.fromJson(data) as T;
    }
    if (t == _ixm9q9lk.TaxFigureView) {
      return _ixm9q9lk.TaxFigureView.fromJson(data) as T;
    }
    if (t == _ivss6b81.TaxLiabilityView) {
      return _ivss6b81.TaxLiabilityView.fromJson(data) as T;
    }
    if (t == _iuft4v7q.TaxOpportunityView) {
      return _iuft4v7q.TaxOpportunityView.fromJson(data) as T;
    }
    if (t == _i20z9jax.TaxProfileRecord) {
      return _i20z9jax.TaxProfileRecord.fromJson(data) as T;
    }
    if (t == _i6llsezf.TaxReportLineView) {
      return _i6llsezf.TaxReportLineView.fromJson(data) as T;
    }
    if (t == _inb54q20.TaxReportView) {
      return _inb54q20.TaxReportView.fromJson(data) as T;
    }
    if (t == _i97pej5a.TaxRuleCaveatView) {
      return _i97pej5a.TaxRuleCaveatView.fromJson(data) as T;
    }
    if (t == _ilbx4erh.TaxSummaryCategoryTotalView) {
      return _ilbx4erh.TaxSummaryCategoryTotalView.fromJson(data) as T;
    }
    if (t == _iok5qj2e.TaxSummaryFxNoteView) {
      return _iok5qj2e.TaxSummaryFxNoteView.fromJson(data) as T;
    }
    if (t == _it9yyajv.TaxSummarySalesTaxQuarterView) {
      return _it9yyajv.TaxSummarySalesTaxQuarterView.fromJson(data) as T;
    }
    if (t == _iabhnw50.TaxSummarySalesTaxRateView) {
      return _iabhnw50.TaxSummarySalesTaxRateView.fromJson(data) as T;
    }
    if (t == _i5jsilqj.TaxSummaryView) {
      return _i5jsilqj.TaxSummaryView.fromJson(data) as T;
    }
    if (t == _ij9k0z9z.TaxSummaryWalletView) {
      return _ij9k0z9z.TaxSummaryWalletView.fromJson(data) as T;
    }
    if (t == _i6dj6ji0.TransactionRule) {
      return _i6dj6ji0.TransactionRule.fromJson(data) as T;
    }
    if (t == _ibzcfs2k.ImportResult) {
      return _ibzcfs2k.ImportResult.fromJson(data) as T;
    }
    if (t == _isp6bezg.ImportRow) {
      return _isp6bezg.ImportRow.fromJson(data) as T;
    }
    if (t == _igokbqfh.ReconcileResult) {
      return _igokbqfh.ReconcileResult.fromJson(data) as T;
    }
    if (t == _iqhl4hru.Transaction) {
      return _iqhl4hru.Transaction.fromJson(data) as T;
    }
    if (t == _i4fvctax.TransactionFlag) {
      return _i4fvctax.TransactionFlag.fromJson(data) as T;
    }
    if (t == _ipd1rac6.TransactionInput) {
      return _ipd1rac6.TransactionInput.fromJson(data) as T;
    }
    if (t == _ioneruif.TransactionKind) {
      return _ioneruif.TransactionKind.fromJson(data) as T;
    }
    if (t == _ipio7ws3.TransactionLine) {
      return _ipio7ws3.TransactionLine.fromJson(data) as T;
    }
    if (t == _imsv7m6w.TransactionLineInput) {
      return _imsv7m6w.TransactionLineInput.fromJson(data) as T;
    }
    if (t == _i7f3q91r.TransactionPage) {
      return _i7f3q91r.TransactionPage.fromJson(data) as T;
    }
    if (t == _ioinkgwn.TransactionQuery) {
      return _ioinkgwn.TransactionQuery.fromJson(data) as T;
    }
    if (t == _i3rynkdl.TransactionStatus) {
      return _i3rynkdl.TransactionStatus.fromJson(data) as T;
    }
    if (t == _ilixdhed.TransactionView) {
      return _ilixdhed.TransactionView.fromJson(data) as T;
    }
    if (t == _ign516jt.Transfer) {
      return _ign516jt.Transfer.fromJson(data) as T;
    }
    if (t == _iah0rmrk.TransferInput) {
      return _iah0rmrk.TransferInput.fromJson(data) as T;
    }
    if (t == _i3n9n3ej.TransferPeerView) {
      return _i3n9n3ej.TransferPeerView.fromJson(data) as T;
    }
    if (t == _iq0sbxsc.HoldingPosition) {
      return _iq0sbxsc.HoldingPosition.fromJson(data) as T;
    }
    if (t == _i6j30n20.PriceQuality) {
      return _i6j30n20.PriceQuality.fromJson(data) as T;
    }
    if (t == _iu1a5mev.PriceSource) {
      return _iu1a5mev.PriceSource.fromJson(data) as T;
    }
    if (t == _i4uehszw.SpamVerdict) {
      return _i4uehszw.SpamVerdict.fromJson(data) as T;
    }
    if (t == _ilu5i0rn.Wallet) {
      return _ilu5i0rn.Wallet.fromJson(data) as T;
    }
    if (t == _iqqppnaa.WalletHolding) {
      return _iqqppnaa.WalletHolding.fromJson(data) as T;
    }
    if (t == _i73xhbar.WalletNetworkState) {
      return _i73xhbar.WalletNetworkState.fromJson(data) as T;
    }
    if (t == _iuw2colh.WalletPreview) {
      return _iuw2colh.WalletPreview.fromJson(data) as T;
    }
    if (t == _icbqx9y3.WalletPreviewNetwork) {
      return _icbqx9y3.WalletPreviewNetwork.fromJson(data) as T;
    }
    if (t == _ipdq2p58.WalletSyncResult) {
      return _ipdq2p58.WalletSyncResult.fromJson(data) as T;
    }
    if (t == _ivsmsmw6.WalletTaxYearSummary) {
      return _ivsmsmw6.WalletTaxYearSummary.fromJson(data) as T;
    }
    if (t == _i6m1jx15.WalletTransaction) {
      return _i6m1jx15.WalletTransaction.fromJson(data) as T;
    }
    if (t == _isc.getType<_iz2jf14v.Account?>()) {
      return (data != null ? _iz2jf14v.Account.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i53yl4yp.AccountBalancesView?>()) {
      return (data != null
              ? _i53yl4yp.AccountBalancesView.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i87oqvv1.AccountValuation?>()) {
      return (data != null ? _i87oqvv1.AccountValuation.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ig9cy6ku.ValuationSource?>()) {
      return (data != null ? _ig9cy6ku.ValuationSource.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_isfmgqgu.AgentConversation?>()) {
      return (data != null ? _isfmgqgu.AgentConversation.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i769eo9u.AgentEvent?>()) {
      return (data != null ? _i769eo9u.AgentEvent.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iyhb15ax.AgentEventKind?>()) {
      return (data != null ? _iyhb15ax.AgentEventKind.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_inwxyid7.AgentMessage?>()) {
      return (data != null ? _inwxyid7.AgentMessage.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iy2njbiw.AgentMessageRole?>()) {
      return (data != null ? _iy2njbiw.AgentMessageRole.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iqh65hzq.AgentProposal?>()) {
      return (data != null ? _iqh65hzq.AgentProposal.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_idxyy01n.AgentProposalKind?>()) {
      return (data != null ? _idxyy01n.AgentProposalKind.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iksk16ej.AgentProposalStatus?>()) {
      return (data != null
              ? _iksk16ej.AgentProposalStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ic667156.AgentProvider?>()) {
      return (data != null ? _ic667156.AgentProvider.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i0760q1h.AgentProviderSettingsView?>()) {
      return (data != null
              ? _i0760q1h.AgentProviderSettingsView.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_igo4k2bu.AgentUsageRecord?>()) {
      return (data != null ? _igo4k2bu.AgentUsageRecord.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ipqjijih.AgentUsageView?>()) {
      return (data != null ? _ipqjijih.AgentUsageView.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iis6jewo.AgentAccessTokenCreated?>()) {
      return (data != null
              ? _iis6jewo.AgentAccessTokenCreated.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i4mcrc97.AgentAccessTokenView?>()) {
      return (data != null
              ? _i4mcrc97.AgentAccessTokenView.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iqje9mi5.AuditAction?>()) {
      return (data != null ? _iqje9mi5.AuditAction.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ijhj7cd7.AuditEvent?>()) {
      return (data != null ? _ijhj7cd7.AuditEvent.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i2sn5a56.AuditSubject?>()) {
      return (data != null ? _i2sn5a56.AuditSubject.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iq2w1sa5.Entitlement?>()) {
      return (data != null ? _iq2w1sa5.Entitlement.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ipnf4x0i.EntitlementSource?>()) {
      return (data != null ? _ipnf4x0i.EntitlementSource.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_imqwzx9j.EntitlementStatus?>()) {
      return (data != null ? _imqwzx9j.EntitlementStatus.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iwxkomal.SolanaPlanView?>()) {
      return (data != null ? _iwxkomal.SolanaPlanView.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iouaddet.AllocationInput?>()) {
      return (data != null ? _iouaddet.AllocationInput.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ixyov90t.BudgetMonthSummary?>()) {
      return (data != null ? _ixyov90t.BudgetMonthSummary.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ihanl5km.BudgetMonthView?>()) {
      return (data != null ? _ihanl5km.BudgetMonthView.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ii8h2sft.EnvelopeMonthView?>()) {
      return (data != null ? _ii8h2sft.EnvelopeMonthView.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i01fne9j.BudgetTemplate?>()) {
      return (data != null ? _i01fne9j.BudgetTemplate.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iagnrffn.BudgetTemplateLine?>()) {
      return (data != null ? _iagnrffn.BudgetTemplateLine.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iwxpkdmg.Category?>()) {
      return (data != null ? _iwxpkdmg.Category.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i4zfq652.Confidence?>()) {
      return (data != null ? _i4zfq652.Confidence.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iynfhhr3.SyncStatus?>()) {
      return (data != null ? _iynfhhr3.SyncStatus.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i03vgs6n.ChangeScope?>()) {
      return (data != null ? _i03vgs6n.ChangeScope.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iamyw1yn.Entity?>()) {
      return (data != null ? _iamyw1yn.Entity.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_is12mxpv.EntityChangedEvent?>()) {
      return (data != null ? _is12mxpv.EntityChangedEvent.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ihqn2h4c.EntitySummaryView?>()) {
      return (data != null ? _ihqn2h4c.EntitySummaryView.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ifl4yivq.EnvelopeGoal?>()) {
      return (data != null ? _ifl4yivq.EnvelopeGoal.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i61aeoqs.EnvelopeGoalKind?>()) {
      return (data != null ? _i61aeoqs.EnvelopeGoalKind.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ikt21dfw.Envelope?>()) {
      return (data != null ? _ikt21dfw.Envelope.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iozei2bz.AgentAllowanceExhaustedException?>()) {
      return (data != null
              ? _iozei2bz.AgentAllowanceExhaustedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iurccglg.AgentProviderException?>()) {
      return (data != null
              ? _iurccglg.AgentProviderException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i6p28blo.AgentProviderUnavailableException?>()) {
      return (data != null
              ? _i6p28blo.AgentProviderUnavailableException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_io2kod1y.AuthenticationRequiredException?>()) {
      return (data != null
              ? _io2kod1y.AuthenticationRequiredException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i9zkhl6f.BillingProviderException?>()) {
      return (data != null
              ? _i9zkhl6f.BillingProviderException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i5kq7itn.BillingRailUnavailableException?>()) {
      return (data != null
              ? _i5kq7itn.BillingRailUnavailableException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ik3lny6q.EntitlementRequiredException?>()) {
      return (data != null
              ? _ik3lny6q.EntitlementRequiredException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iha6yc5u.ForbiddenException?>()) {
      return (data != null ? _iha6yc5u.ForbiddenException.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_if5umnl3.FxRateUnavailableException?>()) {
      return (data != null
              ? _if5umnl3.FxRateUnavailableException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_izob2ctl.NotFoundException?>()) {
      return (data != null ? _izob2ctl.NotFoundException.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i4yu9vcq.TaxRulesUnavailableException?>()) {
      return (data != null
              ? _i4yu9vcq.TaxRulesUnavailableException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_igpdbyom.ValidationException?>()) {
      return (data != null
              ? _igpdbyom.ValidationException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i4nmh6wd.WalletPreviewRateLimitedException?>()) {
      return (data != null
              ? _i4nmh6wd.WalletPreviewRateLimitedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i8cxakqz.FxLatestSnapshot?>()) {
      return (data != null ? _i8cxakqz.FxLatestSnapshot.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ifsg8hc8.FxProvider?>()) {
      return (data != null ? _ifsg8hc8.FxProvider.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i8bj7347.FxQuoteView?>()) {
      return (data != null ? _i8bj7347.FxQuoteView.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i15udi7x.FxRateQuote?>()) {
      return (data != null ? _i15udi7x.FxRateQuote.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ikgmcjq7.Institution?>()) {
      return (data != null ? _ikgmcjq7.Institution.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iclizrec.InstitutionLocation?>()) {
      return (data != null
              ? _iclizrec.InstitutionLocation.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iqqjzj2w.Journal?>()) {
      return (data != null ? _iqqjzj2w.Journal.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i6l0fo54.JournalLine?>()) {
      return (data != null ? _i6l0fo54.JournalLine.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_id7zp91q.JournalLineInput?>()) {
      return (data != null ? _id7zp91q.JournalLineInput.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ivazbnnp.LedgerAccount?>()) {
      return (data != null ? _ivazbnnp.LedgerAccount.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i7t4btg4.LedgerPeriodLock?>()) {
      return (data != null ? _i7t4btg4.LedgerPeriodLock.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i5gsx3ds.TrialBalanceRowView?>()) {
      return (data != null
              ? _i5gsx3ds.TrialBalanceRowView.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i7q128aw.TrialBalanceView?>()) {
      return (data != null ? _i7q128aw.TrialBalanceView.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_igdgld5u.MonthlyAllocation?>()) {
      return (data != null ? _igdgld5u.MonthlyAllocation.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ignezpci.Payee?>()) {
      return (data != null ? _ignezpci.Payee.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i1vmvtrm.PlaidConnection?>()) {
      return (data != null ? _i1vmvtrm.PlaidConnection.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i9is7zb8.RecurringTransaction?>()) {
      return (data != null
              ? _i9is7zb8.RecurringTransaction.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ieg4kkwo.NetWorthAccountRow?>()) {
      return (data != null ? _ieg4kkwo.NetWorthAccountRow.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_if6ke1e2.NetWorthCurrencyRow?>()) {
      return (data != null
              ? _if6ke1e2.NetWorthCurrencyRow.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i2p47r1m.NetWorthEntityRow?>()) {
      return (data != null ? _i2p47r1m.NetWorthEntityRow.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iiyi1fdi.NetWorthGranularity?>()) {
      return (data != null
              ? _iiyi1fdi.NetWorthGranularity.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_izpykydm.NetWorthHistoryView?>()) {
      return (data != null
              ? _izpykydm.NetWorthHistoryView.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ihwosu5p.NetWorthPoint?>()) {
      return (data != null ? _ihwosu5p.NetWorthPoint.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_idk5va87.NetWorthView?>()) {
      return (data != null ? _idk5va87.NetWorthView.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ijpgwwdu.ReportGrouping?>()) {
      return (data != null ? _ijpgwwdu.ReportGrouping.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ikppksh7.SpendingRow?>()) {
      return (data != null ? _ikppksh7.SpendingRow.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i99f9doz.UserSettings?>()) {
      return (data != null ? _i99f9doz.UserSettings.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ic4zfx3b.TaxBandSliceView?>()) {
      return (data != null ? _ic4zfx3b.TaxBandSliceView.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iv5oayw3.TaxCategoryView?>()) {
      return (data != null ? _iv5oayw3.TaxCategoryView.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ixm9q9lk.TaxFigureView?>()) {
      return (data != null ? _ixm9q9lk.TaxFigureView.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ivss6b81.TaxLiabilityView?>()) {
      return (data != null ? _ivss6b81.TaxLiabilityView.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iuft4v7q.TaxOpportunityView?>()) {
      return (data != null ? _iuft4v7q.TaxOpportunityView.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i20z9jax.TaxProfileRecord?>()) {
      return (data != null ? _i20z9jax.TaxProfileRecord.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i6llsezf.TaxReportLineView?>()) {
      return (data != null ? _i6llsezf.TaxReportLineView.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_inb54q20.TaxReportView?>()) {
      return (data != null ? _inb54q20.TaxReportView.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i97pej5a.TaxRuleCaveatView?>()) {
      return (data != null ? _i97pej5a.TaxRuleCaveatView.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ilbx4erh.TaxSummaryCategoryTotalView?>()) {
      return (data != null
              ? _ilbx4erh.TaxSummaryCategoryTotalView.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iok5qj2e.TaxSummaryFxNoteView?>()) {
      return (data != null
              ? _iok5qj2e.TaxSummaryFxNoteView.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_it9yyajv.TaxSummarySalesTaxQuarterView?>()) {
      return (data != null
              ? _it9yyajv.TaxSummarySalesTaxQuarterView.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iabhnw50.TaxSummarySalesTaxRateView?>()) {
      return (data != null
              ? _iabhnw50.TaxSummarySalesTaxRateView.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i5jsilqj.TaxSummaryView?>()) {
      return (data != null ? _i5jsilqj.TaxSummaryView.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ij9k0z9z.TaxSummaryWalletView?>()) {
      return (data != null
              ? _ij9k0z9z.TaxSummaryWalletView.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i6dj6ji0.TransactionRule?>()) {
      return (data != null ? _i6dj6ji0.TransactionRule.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ibzcfs2k.ImportResult?>()) {
      return (data != null ? _ibzcfs2k.ImportResult.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_isp6bezg.ImportRow?>()) {
      return (data != null ? _isp6bezg.ImportRow.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_igokbqfh.ReconcileResult?>()) {
      return (data != null ? _igokbqfh.ReconcileResult.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iqhl4hru.Transaction?>()) {
      return (data != null ? _iqhl4hru.Transaction.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i4fvctax.TransactionFlag?>()) {
      return (data != null ? _i4fvctax.TransactionFlag.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ipd1rac6.TransactionInput?>()) {
      return (data != null ? _ipd1rac6.TransactionInput.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ioneruif.TransactionKind?>()) {
      return (data != null ? _ioneruif.TransactionKind.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ipio7ws3.TransactionLine?>()) {
      return (data != null ? _ipio7ws3.TransactionLine.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_imsv7m6w.TransactionLineInput?>()) {
      return (data != null
              ? _imsv7m6w.TransactionLineInput.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i7f3q91r.TransactionPage?>()) {
      return (data != null ? _i7f3q91r.TransactionPage.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ioinkgwn.TransactionQuery?>()) {
      return (data != null ? _ioinkgwn.TransactionQuery.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i3rynkdl.TransactionStatus?>()) {
      return (data != null ? _i3rynkdl.TransactionStatus.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ilixdhed.TransactionView?>()) {
      return (data != null ? _ilixdhed.TransactionView.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ign516jt.Transfer?>()) {
      return (data != null ? _ign516jt.Transfer.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iah0rmrk.TransferInput?>()) {
      return (data != null ? _iah0rmrk.TransferInput.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i3n9n3ej.TransferPeerView?>()) {
      return (data != null ? _i3n9n3ej.TransferPeerView.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iq0sbxsc.HoldingPosition?>()) {
      return (data != null ? _iq0sbxsc.HoldingPosition.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i6j30n20.PriceQuality?>()) {
      return (data != null ? _i6j30n20.PriceQuality.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iu1a5mev.PriceSource?>()) {
      return (data != null ? _iu1a5mev.PriceSource.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i4uehszw.SpamVerdict?>()) {
      return (data != null ? _i4uehszw.SpamVerdict.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ilu5i0rn.Wallet?>()) {
      return (data != null ? _ilu5i0rn.Wallet.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iqqppnaa.WalletHolding?>()) {
      return (data != null ? _iqqppnaa.WalletHolding.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i73xhbar.WalletNetworkState?>()) {
      return (data != null ? _i73xhbar.WalletNetworkState.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iuw2colh.WalletPreview?>()) {
      return (data != null ? _iuw2colh.WalletPreview.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_icbqx9y3.WalletPreviewNetwork?>()) {
      return (data != null
              ? _icbqx9y3.WalletPreviewNetwork.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ipdq2p58.WalletSyncResult?>()) {
      return (data != null ? _ipdq2p58.WalletSyncResult.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ivsmsmw6.WalletTaxYearSummary?>()) {
      return (data != null
              ? _ivsmsmw6.WalletTaxYearSummary.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i6m1jx15.WalletTransaction?>()) {
      return (data != null ? _i6m1jx15.WalletTransaction.fromJson(data) : null)
          as T;
    }
    if (t == List<_iwxpkdmg.Category>) {
      return (data as List)
              .map((e) => deserialize<_iwxpkdmg.Category>(e))
              .toList()
          as T;
    }
    if (t == List<_ii8h2sft.EnvelopeMonthView>) {
      return (data as List)
              .map((e) => deserialize<_ii8h2sft.EnvelopeMonthView>(e))
              .toList()
          as T;
    }
    if (t == List<_i15udi7x.FxRateQuote>) {
      return (data as List)
              .map((e) => deserialize<_i15udi7x.FxRateQuote>(e))
              .toList()
          as T;
    }
    if (t == List<_i5gsx3ds.TrialBalanceRowView>) {
      return (data as List)
              .map((e) => deserialize<_i5gsx3ds.TrialBalanceRowView>(e))
              .toList()
          as T;
    }
    if (t == List<_ihwosu5p.NetWorthPoint>) {
      return (data as List)
              .map((e) => deserialize<_ihwosu5p.NetWorthPoint>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_if6ke1e2.NetWorthCurrencyRow>) {
      return (data as List)
              .map((e) => deserialize<_if6ke1e2.NetWorthCurrencyRow>(e))
              .toList()
          as T;
    }
    if (t == List<_i2p47r1m.NetWorthEntityRow>) {
      return (data as List)
              .map((e) => deserialize<_i2p47r1m.NetWorthEntityRow>(e))
              .toList()
          as T;
    }
    if (t == List<_ieg4kkwo.NetWorthAccountRow>) {
      return (data as List)
              .map((e) => deserialize<_ieg4kkwo.NetWorthAccountRow>(e))
              .toList()
          as T;
    }
    if (t == List<_ic4zfx3b.TaxBandSliceView>) {
      return (data as List)
              .map((e) => deserialize<_ic4zfx3b.TaxBandSliceView>(e))
              .toList()
          as T;
    }
    if (t == List<_i6llsezf.TaxReportLineView>) {
      return (data as List)
              .map((e) => deserialize<_i6llsezf.TaxReportLineView>(e))
              .toList()
          as T;
    }
    if (t == List<_ivss6b81.TaxLiabilityView>) {
      return (data as List)
              .map((e) => deserialize<_ivss6b81.TaxLiabilityView>(e))
              .toList()
          as T;
    }
    if (t == List<_i97pej5a.TaxRuleCaveatView>) {
      return (data as List)
              .map((e) => deserialize<_i97pej5a.TaxRuleCaveatView>(e))
              .toList()
          as T;
    }
    if (t == List<_ixm9q9lk.TaxFigureView>) {
      return (data as List)
              .map((e) => deserialize<_ixm9q9lk.TaxFigureView>(e))
              .toList()
          as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
        (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
      ) as T;
    }
    if (t == List<_iuft4v7q.TaxOpportunityView>) {
      return (data as List)
              .map((e) => deserialize<_iuft4v7q.TaxOpportunityView>(e))
              .toList()
          as T;
    }
    if (t == List<_ilbx4erh.TaxSummaryCategoryTotalView>) {
      return (data as List)
              .map((e) => deserialize<_ilbx4erh.TaxSummaryCategoryTotalView>(e))
              .toList()
          as T;
    }
    if (t == List<_iabhnw50.TaxSummarySalesTaxRateView>) {
      return (data as List)
              .map((e) => deserialize<_iabhnw50.TaxSummarySalesTaxRateView>(e))
              .toList()
          as T;
    }
    if (t == List<_it9yyajv.TaxSummarySalesTaxQuarterView>) {
      return (data as List)
              .map(
                (e) => deserialize<_it9yyajv.TaxSummarySalesTaxQuarterView>(e),
              )
              .toList()
          as T;
    }
    if (t == List<_ij9k0z9z.TaxSummaryWalletView>) {
      return (data as List)
              .map((e) => deserialize<_ij9k0z9z.TaxSummaryWalletView>(e))
              .toList()
          as T;
    }
    if (t == List<_iok5qj2e.TaxSummaryFxNoteView>) {
      return (data as List)
              .map((e) => deserialize<_iok5qj2e.TaxSummaryFxNoteView>(e))
              .toList()
          as T;
    }
    if (t == List<_imsv7m6w.TransactionLineInput>) {
      return (data as List)
              .map((e) => deserialize<_imsv7m6w.TransactionLineInput>(e))
              .toList()
          as T;
    }
    if (t == List<_ilixdhed.TransactionView>) {
      return (data as List)
              .map((e) => deserialize<_ilixdhed.TransactionView>(e))
              .toList()
          as T;
    }
    if (t == List<_ipio7ws3.TransactionLine>) {
      return (data as List)
              .map((e) => deserialize<_ipio7ws3.TransactionLine>(e))
              .toList()
          as T;
    }
    if (t == List<_ifz8weqz.WalletNetwork>) {
      return (data as List)
              .map((e) => deserialize<_ifz8weqz.WalletNetwork>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_ifz8weqz.WalletNetwork>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_ifz8weqz.WalletNetwork>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_icbqx9y3.WalletPreviewNetwork>) {
      return (data as List)
              .map((e) => deserialize<_icbqx9y3.WalletPreviewNetwork>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_iqudaadl.Account>) {
      return (data as List)
              .map((e) => deserialize<_iqudaadl.Account>(e))
              .toList()
          as T;
    }
    if (t == List<_isc.UuidValue>) {
      return (data as List).map((e) => deserialize<_isc.UuidValue>(e)).toList()
          as T;
    }
    if (t == List<_idms9t2z.AccountValuation>) {
      return (data as List)
              .map((e) => deserialize<_idms9t2z.AccountValuation>(e))
              .toList()
          as T;
    }
    if (t == List<_in44ixo7.AgentConversation>) {
      return (data as List)
              .map((e) => deserialize<_in44ixo7.AgentConversation>(e))
              .toList()
          as T;
    }
    if (t == List<_i8fbky0c.AgentMessage>) {
      return (data as List)
              .map((e) => deserialize<_i8fbky0c.AgentMessage>(e))
              .toList()
          as T;
    }
    if (t == List<_icv7zzda.AgentProposal>) {
      return (data as List)
              .map((e) => deserialize<_icv7zzda.AgentProposal>(e))
              .toList()
          as T;
    }
    if (t == List<_itxn3wek.AgentAccessTokenView>) {
      return (data as List)
              .map((e) => deserialize<_itxn3wek.AgentAccessTokenView>(e))
              .toList()
          as T;
    }
    if (t == List<_inutgv28.AllocationInput>) {
      return (data as List)
              .map((e) => deserialize<_inutgv28.AllocationInput>(e))
              .toList()
          as T;
    }
    if (t == List<_itiojbb0.BudgetTemplate>) {
      return (data as List)
              .map((e) => deserialize<_itiojbb0.BudgetTemplate>(e))
              .toList()
          as T;
    }
    if (t == List<_ik2p0evm.BudgetTemplateLine>) {
      return (data as List)
              .map((e) => deserialize<_ik2p0evm.BudgetTemplateLine>(e))
              .toList()
          as T;
    }
    if (t == List<_iels1fku.Category>) {
      return (data as List)
              .map((e) => deserialize<_iels1fku.Category>(e))
              .toList()
          as T;
    }
    if (t == List<_i2ulk6h5.Entity>) {
      return (data as List)
              .map((e) => deserialize<_i2ulk6h5.Entity>(e))
              .toList()
          as T;
    }
    if (t == List<_ib1vbiwb.EntitySummaryView>) {
      return (data as List)
              .map((e) => deserialize<_ib1vbiwb.EntitySummaryView>(e))
              .toList()
          as T;
    }
    if (t == List<_ibdhi9gv.EnvelopeGoal>) {
      return (data as List)
              .map((e) => deserialize<_ibdhi9gv.EnvelopeGoal>(e))
              .toList()
          as T;
    }
    if (t == List<_i29jf3by.Envelope>) {
      return (data as List)
              .map((e) => deserialize<_i29jf3by.Envelope>(e))
              .toList()
          as T;
    }
    if (t == List<_i6ysl1a4.Institution>) {
      return (data as List)
              .map((e) => deserialize<_i6ysl1a4.Institution>(e))
              .toList()
          as T;
    }
    if (t == List<_ixq9t892.LedgerAccount>) {
      return (data as List)
              .map((e) => deserialize<_ixq9t892.LedgerAccount>(e))
              .toList()
          as T;
    }
    if (t == List<_i3j8x5or.JournalLineInput>) {
      return (data as List)
              .map((e) => deserialize<_i3j8x5or.JournalLineInput>(e))
              .toList()
          as T;
    }
    if (t == List<_izuizaeu.Journal>) {
      return (data as List)
              .map((e) => deserialize<_izuizaeu.Journal>(e))
              .toList()
          as T;
    }
    if (t == List<_iwruw2s3.JournalLine>) {
      return (data as List)
              .map((e) => deserialize<_iwruw2s3.JournalLine>(e))
              .toList()
          as T;
    }
    if (t == List<_ioe147d0.AuditEvent>) {
      return (data as List)
              .map((e) => deserialize<_ioe147d0.AuditEvent>(e))
              .toList()
          as T;
    }
    if (t == List<_iaf6ifsb.Payee>) {
      return (data as List).map((e) => deserialize<_iaf6ifsb.Payee>(e)).toList()
          as T;
    }
    if (t == List<_itydqisw.PlaidConnection>) {
      return (data as List)
              .map((e) => deserialize<_itydqisw.PlaidConnection>(e))
              .toList()
          as T;
    }
    if (t == List<_i41tn6nr.RecurringTransaction>) {
      return (data as List)
              .map((e) => deserialize<_i41tn6nr.RecurringTransaction>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_isc.UuidValue>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_isc.UuidValue>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_ia9y0al9.SpendingRow>) {
      return (data as List)
              .map((e) => deserialize<_ia9y0al9.SpendingRow>(e))
              .toList()
          as T;
    }
    if (t == List<_i52laypj.BudgetMonthSummary>) {
      return (data as List)
              .map((e) => deserialize<_i52laypj.BudgetMonthSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_ic177lol.TaxCategoryView>) {
      return (data as List)
              .map((e) => deserialize<_ic177lol.TaxCategoryView>(e))
              .toList()
          as T;
    }
    if (t == List<_iwxd5v0a.TransactionRule>) {
      return (data as List)
              .map((e) => deserialize<_iwxd5v0a.TransactionRule>(e))
              .toList()
          as T;
    }
    if (t == List<_irfj6dpt.TransactionView>) {
      return (data as List)
              .map((e) => deserialize<_irfj6dpt.TransactionView>(e))
              .toList()
          as T;
    }
    if (t == List<_iyud7cy9.ImportRow>) {
      return (data as List)
              .map((e) => deserialize<_iyud7cy9.ImportRow>(e))
              .toList()
          as T;
    }
    if (t == List<_ifz8weqz.WalletNetwork>) {
      return (data as List)
              .map((e) => deserialize<_ifz8weqz.WalletNetwork>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_ifz8weqz.WalletNetwork>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_ifz8weqz.WalletNetwork>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i9c4hszu.WalletNetworkState>) {
      return (data as List)
              .map((e) => deserialize<_i9c4hszu.WalletNetworkState>(e))
              .toList()
          as T;
    }
    if (t == List<_igzh8mor.Wallet>) {
      return (data as List)
              .map((e) => deserialize<_igzh8mor.Wallet>(e))
              .toList()
          as T;
    }
    if (t == List<_izm3e498.WalletHolding>) {
      return (data as List)
              .map((e) => deserialize<_izm3e498.WalletHolding>(e))
              .toList()
          as T;
    }
    if (t == List<_itxp58mr.WalletTransaction>) {
      return (data as List)
              .map((e) => deserialize<_itxp58mr.WalletTransaction>(e))
              .toList()
          as T;
    }
    if (t == List<_il62txu0.WalletTaxYearSummary>) {
      return (data as List)
              .map((e) => deserialize<_il62txu0.WalletTaxYearSummary>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _isc.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    final modules = deserializationMetadata.modulesForDeserialization(
      t,
      className: rawDataClassName,
    );
    for (final module in modules) {
      try {
        return module.deserialize<T>(data, t);
      } on _isc.DeserializationTypeNotFoundException catch (_) {}
    }

    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iz2jf14v.Account => 'Account',
      _i53yl4yp.AccountBalancesView => 'AccountBalancesView',
      _i87oqvv1.AccountValuation => 'AccountValuation',
      _ig9cy6ku.ValuationSource => 'ValuationSource',
      _isfmgqgu.AgentConversation => 'AgentConversation',
      _i769eo9u.AgentEvent => 'AgentEvent',
      _iyhb15ax.AgentEventKind => 'AgentEventKind',
      _inwxyid7.AgentMessage => 'AgentMessage',
      _iy2njbiw.AgentMessageRole => 'AgentMessageRole',
      _iqh65hzq.AgentProposal => 'AgentProposal',
      _idxyy01n.AgentProposalKind => 'AgentProposalKind',
      _iksk16ej.AgentProposalStatus => 'AgentProposalStatus',
      _ic667156.AgentProvider => 'AgentProvider',
      _i0760q1h.AgentProviderSettingsView => 'AgentProviderSettingsView',
      _igo4k2bu.AgentUsageRecord => 'AgentUsageRecord',
      _ipqjijih.AgentUsageView => 'AgentUsageView',
      _iis6jewo.AgentAccessTokenCreated => 'AgentAccessTokenCreated',
      _i4mcrc97.AgentAccessTokenView => 'AgentAccessTokenView',
      _iqje9mi5.AuditAction => 'AuditAction',
      _ijhj7cd7.AuditEvent => 'AuditEvent',
      _i2sn5a56.AuditSubject => 'AuditSubject',
      _iq2w1sa5.Entitlement => 'Entitlement',
      _ipnf4x0i.EntitlementSource => 'EntitlementSource',
      _imqwzx9j.EntitlementStatus => 'EntitlementStatus',
      _iwxkomal.SolanaPlanView => 'SolanaPlanView',
      _iouaddet.AllocationInput => 'AllocationInput',
      _ixyov90t.BudgetMonthSummary => 'BudgetMonthSummary',
      _ihanl5km.BudgetMonthView => 'BudgetMonthView',
      _ii8h2sft.EnvelopeMonthView => 'EnvelopeMonthView',
      _i01fne9j.BudgetTemplate => 'BudgetTemplate',
      _iagnrffn.BudgetTemplateLine => 'BudgetTemplateLine',
      _iwxpkdmg.Category => 'Category',
      _i4zfq652.Confidence => 'Confidence',
      _iynfhhr3.SyncStatus => 'SyncStatus',
      _i03vgs6n.ChangeScope => 'ChangeScope',
      _iamyw1yn.Entity => 'Entity',
      _is12mxpv.EntityChangedEvent => 'EntityChangedEvent',
      _ihqn2h4c.EntitySummaryView => 'EntitySummaryView',
      _ifl4yivq.EnvelopeGoal => 'EnvelopeGoal',
      _i61aeoqs.EnvelopeGoalKind => 'EnvelopeGoalKind',
      _ikt21dfw.Envelope => 'Envelope',
      _iozei2bz.AgentAllowanceExhaustedException =>
        'AgentAllowanceExhaustedException',
      _iurccglg.AgentProviderException => 'AgentProviderException',
      _i6p28blo.AgentProviderUnavailableException =>
        'AgentProviderUnavailableException',
      _io2kod1y.AuthenticationRequiredException =>
        'AuthenticationRequiredException',
      _i9zkhl6f.BillingProviderException => 'BillingProviderException',
      _i5kq7itn.BillingRailUnavailableException =>
        'BillingRailUnavailableException',
      _ik3lny6q.EntitlementRequiredException => 'EntitlementRequiredException',
      _iha6yc5u.ForbiddenException => 'ForbiddenException',
      _if5umnl3.FxRateUnavailableException => 'FxRateUnavailableException',
      _izob2ctl.NotFoundException => 'NotFoundException',
      _i4yu9vcq.TaxRulesUnavailableException => 'TaxRulesUnavailableException',
      _igpdbyom.ValidationException => 'ValidationException',
      _i4nmh6wd.WalletPreviewRateLimitedException =>
        'WalletPreviewRateLimitedException',
      _i8cxakqz.FxLatestSnapshot => 'FxLatestSnapshot',
      _ifsg8hc8.FxProvider => 'FxProvider',
      _i8bj7347.FxQuoteView => 'FxQuoteView',
      _i15udi7x.FxRateQuote => 'FxRateQuote',
      _ikgmcjq7.Institution => 'Institution',
      _iclizrec.InstitutionLocation => 'InstitutionLocation',
      _iqqjzj2w.Journal => 'Journal',
      _i6l0fo54.JournalLine => 'JournalLine',
      _id7zp91q.JournalLineInput => 'JournalLineInput',
      _ivazbnnp.LedgerAccount => 'LedgerAccount',
      _i7t4btg4.LedgerPeriodLock => 'LedgerPeriodLock',
      _i5gsx3ds.TrialBalanceRowView => 'TrialBalanceRowView',
      _i7q128aw.TrialBalanceView => 'TrialBalanceView',
      _igdgld5u.MonthlyAllocation => 'MonthlyAllocation',
      _ignezpci.Payee => 'Payee',
      _i1vmvtrm.PlaidConnection => 'PlaidConnection',
      _i9is7zb8.RecurringTransaction => 'RecurringTransaction',
      _ieg4kkwo.NetWorthAccountRow => 'NetWorthAccountRow',
      _if6ke1e2.NetWorthCurrencyRow => 'NetWorthCurrencyRow',
      _i2p47r1m.NetWorthEntityRow => 'NetWorthEntityRow',
      _iiyi1fdi.NetWorthGranularity => 'NetWorthGranularity',
      _izpykydm.NetWorthHistoryView => 'NetWorthHistoryView',
      _ihwosu5p.NetWorthPoint => 'NetWorthPoint',
      _idk5va87.NetWorthView => 'NetWorthView',
      _ijpgwwdu.ReportGrouping => 'ReportGrouping',
      _ikppksh7.SpendingRow => 'SpendingRow',
      _i99f9doz.UserSettings => 'UserSettings',
      _ic4zfx3b.TaxBandSliceView => 'TaxBandSliceView',
      _iv5oayw3.TaxCategoryView => 'TaxCategoryView',
      _ixm9q9lk.TaxFigureView => 'TaxFigureView',
      _ivss6b81.TaxLiabilityView => 'TaxLiabilityView',
      _iuft4v7q.TaxOpportunityView => 'TaxOpportunityView',
      _i20z9jax.TaxProfileRecord => 'TaxProfileRecord',
      _i6llsezf.TaxReportLineView => 'TaxReportLineView',
      _inb54q20.TaxReportView => 'TaxReportView',
      _i97pej5a.TaxRuleCaveatView => 'TaxRuleCaveatView',
      _ilbx4erh.TaxSummaryCategoryTotalView => 'TaxSummaryCategoryTotalView',
      _iok5qj2e.TaxSummaryFxNoteView => 'TaxSummaryFxNoteView',
      _it9yyajv.TaxSummarySalesTaxQuarterView =>
        'TaxSummarySalesTaxQuarterView',
      _iabhnw50.TaxSummarySalesTaxRateView => 'TaxSummarySalesTaxRateView',
      _i5jsilqj.TaxSummaryView => 'TaxSummaryView',
      _ij9k0z9z.TaxSummaryWalletView => 'TaxSummaryWalletView',
      _i6dj6ji0.TransactionRule => 'TransactionRule',
      _ibzcfs2k.ImportResult => 'ImportResult',
      _isp6bezg.ImportRow => 'ImportRow',
      _igokbqfh.ReconcileResult => 'ReconcileResult',
      _iqhl4hru.Transaction => 'Transaction',
      _i4fvctax.TransactionFlag => 'TransactionFlag',
      _ipd1rac6.TransactionInput => 'TransactionInput',
      _ioneruif.TransactionKind => 'TransactionKind',
      _ipio7ws3.TransactionLine => 'TransactionLine',
      _imsv7m6w.TransactionLineInput => 'TransactionLineInput',
      _i7f3q91r.TransactionPage => 'TransactionPage',
      _ioinkgwn.TransactionQuery => 'TransactionQuery',
      _i3rynkdl.TransactionStatus => 'TransactionStatus',
      _ilixdhed.TransactionView => 'TransactionView',
      _ign516jt.Transfer => 'Transfer',
      _iah0rmrk.TransferInput => 'TransferInput',
      _i3n9n3ej.TransferPeerView => 'TransferPeerView',
      _iq0sbxsc.HoldingPosition => 'HoldingPosition',
      _i6j30n20.PriceQuality => 'PriceQuality',
      _iu1a5mev.PriceSource => 'PriceSource',
      _i4uehszw.SpamVerdict => 'SpamVerdict',
      _ilu5i0rn.Wallet => 'Wallet',
      _iqqppnaa.WalletHolding => 'WalletHolding',
      _i73xhbar.WalletNetworkState => 'WalletNetworkState',
      _iuw2colh.WalletPreview => 'WalletPreview',
      _icbqx9y3.WalletPreviewNetwork => 'WalletPreviewNetwork',
      _ipdq2p58.WalletSyncResult => 'WalletSyncResult',
      _ivsmsmw6.WalletTaxYearSummary => 'WalletTaxYearSummary',
      _i6m1jx15.WalletTransaction => 'WalletTransaction',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('openbudget.', '');
    }

    switch (data) {
      case _iz2jf14v.Account():
        return 'Account';
      case _i53yl4yp.AccountBalancesView():
        return 'AccountBalancesView';
      case _i87oqvv1.AccountValuation():
        return 'AccountValuation';
      case _ig9cy6ku.ValuationSource():
        return 'ValuationSource';
      case _isfmgqgu.AgentConversation():
        return 'AgentConversation';
      case _i769eo9u.AgentEvent():
        return 'AgentEvent';
      case _iyhb15ax.AgentEventKind():
        return 'AgentEventKind';
      case _inwxyid7.AgentMessage():
        return 'AgentMessage';
      case _iy2njbiw.AgentMessageRole():
        return 'AgentMessageRole';
      case _iqh65hzq.AgentProposal():
        return 'AgentProposal';
      case _idxyy01n.AgentProposalKind():
        return 'AgentProposalKind';
      case _iksk16ej.AgentProposalStatus():
        return 'AgentProposalStatus';
      case _ic667156.AgentProvider():
        return 'AgentProvider';
      case _i0760q1h.AgentProviderSettingsView():
        return 'AgentProviderSettingsView';
      case _igo4k2bu.AgentUsageRecord():
        return 'AgentUsageRecord';
      case _ipqjijih.AgentUsageView():
        return 'AgentUsageView';
      case _iis6jewo.AgentAccessTokenCreated():
        return 'AgentAccessTokenCreated';
      case _i4mcrc97.AgentAccessTokenView():
        return 'AgentAccessTokenView';
      case _iqje9mi5.AuditAction():
        return 'AuditAction';
      case _ijhj7cd7.AuditEvent():
        return 'AuditEvent';
      case _i2sn5a56.AuditSubject():
        return 'AuditSubject';
      case _iq2w1sa5.Entitlement():
        return 'Entitlement';
      case _ipnf4x0i.EntitlementSource():
        return 'EntitlementSource';
      case _imqwzx9j.EntitlementStatus():
        return 'EntitlementStatus';
      case _iwxkomal.SolanaPlanView():
        return 'SolanaPlanView';
      case _iouaddet.AllocationInput():
        return 'AllocationInput';
      case _ixyov90t.BudgetMonthSummary():
        return 'BudgetMonthSummary';
      case _ihanl5km.BudgetMonthView():
        return 'BudgetMonthView';
      case _ii8h2sft.EnvelopeMonthView():
        return 'EnvelopeMonthView';
      case _i01fne9j.BudgetTemplate():
        return 'BudgetTemplate';
      case _iagnrffn.BudgetTemplateLine():
        return 'BudgetTemplateLine';
      case _iwxpkdmg.Category():
        return 'Category';
      case _i4zfq652.Confidence():
        return 'Confidence';
      case _iynfhhr3.SyncStatus():
        return 'SyncStatus';
      case _i03vgs6n.ChangeScope():
        return 'ChangeScope';
      case _iamyw1yn.Entity():
        return 'Entity';
      case _is12mxpv.EntityChangedEvent():
        return 'EntityChangedEvent';
      case _ihqn2h4c.EntitySummaryView():
        return 'EntitySummaryView';
      case _ifl4yivq.EnvelopeGoal():
        return 'EnvelopeGoal';
      case _i61aeoqs.EnvelopeGoalKind():
        return 'EnvelopeGoalKind';
      case _ikt21dfw.Envelope():
        return 'Envelope';
      case _iozei2bz.AgentAllowanceExhaustedException():
        return 'AgentAllowanceExhaustedException';
      case _iurccglg.AgentProviderException():
        return 'AgentProviderException';
      case _i6p28blo.AgentProviderUnavailableException():
        return 'AgentProviderUnavailableException';
      case _io2kod1y.AuthenticationRequiredException():
        return 'AuthenticationRequiredException';
      case _i9zkhl6f.BillingProviderException():
        return 'BillingProviderException';
      case _i5kq7itn.BillingRailUnavailableException():
        return 'BillingRailUnavailableException';
      case _ik3lny6q.EntitlementRequiredException():
        return 'EntitlementRequiredException';
      case _iha6yc5u.ForbiddenException():
        return 'ForbiddenException';
      case _if5umnl3.FxRateUnavailableException():
        return 'FxRateUnavailableException';
      case _izob2ctl.NotFoundException():
        return 'NotFoundException';
      case _i4yu9vcq.TaxRulesUnavailableException():
        return 'TaxRulesUnavailableException';
      case _igpdbyom.ValidationException():
        return 'ValidationException';
      case _i4nmh6wd.WalletPreviewRateLimitedException():
        return 'WalletPreviewRateLimitedException';
      case _i8cxakqz.FxLatestSnapshot():
        return 'FxLatestSnapshot';
      case _ifsg8hc8.FxProvider():
        return 'FxProvider';
      case _i8bj7347.FxQuoteView():
        return 'FxQuoteView';
      case _i15udi7x.FxRateQuote():
        return 'FxRateQuote';
      case _ikgmcjq7.Institution():
        return 'Institution';
      case _iclizrec.InstitutionLocation():
        return 'InstitutionLocation';
      case _iqqjzj2w.Journal():
        return 'Journal';
      case _i6l0fo54.JournalLine():
        return 'JournalLine';
      case _id7zp91q.JournalLineInput():
        return 'JournalLineInput';
      case _ivazbnnp.LedgerAccount():
        return 'LedgerAccount';
      case _i7t4btg4.LedgerPeriodLock():
        return 'LedgerPeriodLock';
      case _i5gsx3ds.TrialBalanceRowView():
        return 'TrialBalanceRowView';
      case _i7q128aw.TrialBalanceView():
        return 'TrialBalanceView';
      case _igdgld5u.MonthlyAllocation():
        return 'MonthlyAllocation';
      case _ignezpci.Payee():
        return 'Payee';
      case _i1vmvtrm.PlaidConnection():
        return 'PlaidConnection';
      case _i9is7zb8.RecurringTransaction():
        return 'RecurringTransaction';
      case _ieg4kkwo.NetWorthAccountRow():
        return 'NetWorthAccountRow';
      case _if6ke1e2.NetWorthCurrencyRow():
        return 'NetWorthCurrencyRow';
      case _i2p47r1m.NetWorthEntityRow():
        return 'NetWorthEntityRow';
      case _iiyi1fdi.NetWorthGranularity():
        return 'NetWorthGranularity';
      case _izpykydm.NetWorthHistoryView():
        return 'NetWorthHistoryView';
      case _ihwosu5p.NetWorthPoint():
        return 'NetWorthPoint';
      case _idk5va87.NetWorthView():
        return 'NetWorthView';
      case _ijpgwwdu.ReportGrouping():
        return 'ReportGrouping';
      case _ikppksh7.SpendingRow():
        return 'SpendingRow';
      case _i99f9doz.UserSettings():
        return 'UserSettings';
      case _ic4zfx3b.TaxBandSliceView():
        return 'TaxBandSliceView';
      case _iv5oayw3.TaxCategoryView():
        return 'TaxCategoryView';
      case _ixm9q9lk.TaxFigureView():
        return 'TaxFigureView';
      case _ivss6b81.TaxLiabilityView():
        return 'TaxLiabilityView';
      case _iuft4v7q.TaxOpportunityView():
        return 'TaxOpportunityView';
      case _i20z9jax.TaxProfileRecord():
        return 'TaxProfileRecord';
      case _i6llsezf.TaxReportLineView():
        return 'TaxReportLineView';
      case _inb54q20.TaxReportView():
        return 'TaxReportView';
      case _i97pej5a.TaxRuleCaveatView():
        return 'TaxRuleCaveatView';
      case _ilbx4erh.TaxSummaryCategoryTotalView():
        return 'TaxSummaryCategoryTotalView';
      case _iok5qj2e.TaxSummaryFxNoteView():
        return 'TaxSummaryFxNoteView';
      case _it9yyajv.TaxSummarySalesTaxQuarterView():
        return 'TaxSummarySalesTaxQuarterView';
      case _iabhnw50.TaxSummarySalesTaxRateView():
        return 'TaxSummarySalesTaxRateView';
      case _i5jsilqj.TaxSummaryView():
        return 'TaxSummaryView';
      case _ij9k0z9z.TaxSummaryWalletView():
        return 'TaxSummaryWalletView';
      case _i6dj6ji0.TransactionRule():
        return 'TransactionRule';
      case _ibzcfs2k.ImportResult():
        return 'ImportResult';
      case _isp6bezg.ImportRow():
        return 'ImportRow';
      case _igokbqfh.ReconcileResult():
        return 'ReconcileResult';
      case _iqhl4hru.Transaction():
        return 'Transaction';
      case _i4fvctax.TransactionFlag():
        return 'TransactionFlag';
      case _ipd1rac6.TransactionInput():
        return 'TransactionInput';
      case _ioneruif.TransactionKind():
        return 'TransactionKind';
      case _ipio7ws3.TransactionLine():
        return 'TransactionLine';
      case _imsv7m6w.TransactionLineInput():
        return 'TransactionLineInput';
      case _i7f3q91r.TransactionPage():
        return 'TransactionPage';
      case _ioinkgwn.TransactionQuery():
        return 'TransactionQuery';
      case _i3rynkdl.TransactionStatus():
        return 'TransactionStatus';
      case _ilixdhed.TransactionView():
        return 'TransactionView';
      case _ign516jt.Transfer():
        return 'Transfer';
      case _iah0rmrk.TransferInput():
        return 'TransferInput';
      case _i3n9n3ej.TransferPeerView():
        return 'TransferPeerView';
      case _iq0sbxsc.HoldingPosition():
        return 'HoldingPosition';
      case _i6j30n20.PriceQuality():
        return 'PriceQuality';
      case _iu1a5mev.PriceSource():
        return 'PriceSource';
      case _i4uehszw.SpamVerdict():
        return 'SpamVerdict';
      case _ilu5i0rn.Wallet():
        return 'Wallet';
      case _iqqppnaa.WalletHolding():
        return 'WalletHolding';
      case _i73xhbar.WalletNetworkState():
        return 'WalletNetworkState';
      case _iuw2colh.WalletPreview():
        return 'WalletPreview';
      case _icbqx9y3.WalletPreviewNetwork():
        return 'WalletPreviewNetwork';
      case _ipdq2p58.WalletSyncResult():
        return 'WalletSyncResult';
      case _ivsmsmw6.WalletTaxYearSummary():
        return 'WalletTaxYearSummary';
      case _i6m1jx15.WalletTransaction():
        return 'WalletTransaction';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _ifz8weqz.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'openbudget_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Account') {
      return deserialize<_iz2jf14v.Account>(data['data']);
    }
    if (dataClassName == 'AccountBalancesView') {
      return deserialize<_i53yl4yp.AccountBalancesView>(data['data']);
    }
    if (dataClassName == 'AccountValuation') {
      return deserialize<_i87oqvv1.AccountValuation>(data['data']);
    }
    if (dataClassName == 'ValuationSource') {
      return deserialize<_ig9cy6ku.ValuationSource>(data['data']);
    }
    if (dataClassName == 'AgentConversation') {
      return deserialize<_isfmgqgu.AgentConversation>(data['data']);
    }
    if (dataClassName == 'AgentEvent') {
      return deserialize<_i769eo9u.AgentEvent>(data['data']);
    }
    if (dataClassName == 'AgentEventKind') {
      return deserialize<_iyhb15ax.AgentEventKind>(data['data']);
    }
    if (dataClassName == 'AgentMessage') {
      return deserialize<_inwxyid7.AgentMessage>(data['data']);
    }
    if (dataClassName == 'AgentMessageRole') {
      return deserialize<_iy2njbiw.AgentMessageRole>(data['data']);
    }
    if (dataClassName == 'AgentProposal') {
      return deserialize<_iqh65hzq.AgentProposal>(data['data']);
    }
    if (dataClassName == 'AgentProposalKind') {
      return deserialize<_idxyy01n.AgentProposalKind>(data['data']);
    }
    if (dataClassName == 'AgentProposalStatus') {
      return deserialize<_iksk16ej.AgentProposalStatus>(data['data']);
    }
    if (dataClassName == 'AgentProvider') {
      return deserialize<_ic667156.AgentProvider>(data['data']);
    }
    if (dataClassName == 'AgentProviderSettingsView') {
      return deserialize<_i0760q1h.AgentProviderSettingsView>(data['data']);
    }
    if (dataClassName == 'AgentUsageRecord') {
      return deserialize<_igo4k2bu.AgentUsageRecord>(data['data']);
    }
    if (dataClassName == 'AgentUsageView') {
      return deserialize<_ipqjijih.AgentUsageView>(data['data']);
    }
    if (dataClassName == 'AgentAccessTokenCreated') {
      return deserialize<_iis6jewo.AgentAccessTokenCreated>(data['data']);
    }
    if (dataClassName == 'AgentAccessTokenView') {
      return deserialize<_i4mcrc97.AgentAccessTokenView>(data['data']);
    }
    if (dataClassName == 'AuditAction') {
      return deserialize<_iqje9mi5.AuditAction>(data['data']);
    }
    if (dataClassName == 'AuditEvent') {
      return deserialize<_ijhj7cd7.AuditEvent>(data['data']);
    }
    if (dataClassName == 'AuditSubject') {
      return deserialize<_i2sn5a56.AuditSubject>(data['data']);
    }
    if (dataClassName == 'Entitlement') {
      return deserialize<_iq2w1sa5.Entitlement>(data['data']);
    }
    if (dataClassName == 'EntitlementSource') {
      return deserialize<_ipnf4x0i.EntitlementSource>(data['data']);
    }
    if (dataClassName == 'EntitlementStatus') {
      return deserialize<_imqwzx9j.EntitlementStatus>(data['data']);
    }
    if (dataClassName == 'SolanaPlanView') {
      return deserialize<_iwxkomal.SolanaPlanView>(data['data']);
    }
    if (dataClassName == 'AllocationInput') {
      return deserialize<_iouaddet.AllocationInput>(data['data']);
    }
    if (dataClassName == 'BudgetMonthSummary') {
      return deserialize<_ixyov90t.BudgetMonthSummary>(data['data']);
    }
    if (dataClassName == 'BudgetMonthView') {
      return deserialize<_ihanl5km.BudgetMonthView>(data['data']);
    }
    if (dataClassName == 'EnvelopeMonthView') {
      return deserialize<_ii8h2sft.EnvelopeMonthView>(data['data']);
    }
    if (dataClassName == 'BudgetTemplate') {
      return deserialize<_i01fne9j.BudgetTemplate>(data['data']);
    }
    if (dataClassName == 'BudgetTemplateLine') {
      return deserialize<_iagnrffn.BudgetTemplateLine>(data['data']);
    }
    if (dataClassName == 'Category') {
      return deserialize<_iwxpkdmg.Category>(data['data']);
    }
    if (dataClassName == 'Confidence') {
      return deserialize<_i4zfq652.Confidence>(data['data']);
    }
    if (dataClassName == 'SyncStatus') {
      return deserialize<_iynfhhr3.SyncStatus>(data['data']);
    }
    if (dataClassName == 'ChangeScope') {
      return deserialize<_i03vgs6n.ChangeScope>(data['data']);
    }
    if (dataClassName == 'Entity') {
      return deserialize<_iamyw1yn.Entity>(data['data']);
    }
    if (dataClassName == 'EntityChangedEvent') {
      return deserialize<_is12mxpv.EntityChangedEvent>(data['data']);
    }
    if (dataClassName == 'EntitySummaryView') {
      return deserialize<_ihqn2h4c.EntitySummaryView>(data['data']);
    }
    if (dataClassName == 'EnvelopeGoal') {
      return deserialize<_ifl4yivq.EnvelopeGoal>(data['data']);
    }
    if (dataClassName == 'EnvelopeGoalKind') {
      return deserialize<_i61aeoqs.EnvelopeGoalKind>(data['data']);
    }
    if (dataClassName == 'Envelope') {
      return deserialize<_ikt21dfw.Envelope>(data['data']);
    }
    if (dataClassName == 'AgentAllowanceExhaustedException') {
      return deserialize<_iozei2bz.AgentAllowanceExhaustedException>(
        data['data'],
      );
    }
    if (dataClassName == 'AgentProviderException') {
      return deserialize<_iurccglg.AgentProviderException>(data['data']);
    }
    if (dataClassName == 'AgentProviderUnavailableException') {
      return deserialize<_i6p28blo.AgentProviderUnavailableException>(
        data['data'],
      );
    }
    if (dataClassName == 'AuthenticationRequiredException') {
      return deserialize<_io2kod1y.AuthenticationRequiredException>(
        data['data'],
      );
    }
    if (dataClassName == 'BillingProviderException') {
      return deserialize<_i9zkhl6f.BillingProviderException>(data['data']);
    }
    if (dataClassName == 'BillingRailUnavailableException') {
      return deserialize<_i5kq7itn.BillingRailUnavailableException>(
        data['data'],
      );
    }
    if (dataClassName == 'EntitlementRequiredException') {
      return deserialize<_ik3lny6q.EntitlementRequiredException>(data['data']);
    }
    if (dataClassName == 'ForbiddenException') {
      return deserialize<_iha6yc5u.ForbiddenException>(data['data']);
    }
    if (dataClassName == 'FxRateUnavailableException') {
      return deserialize<_if5umnl3.FxRateUnavailableException>(data['data']);
    }
    if (dataClassName == 'NotFoundException') {
      return deserialize<_izob2ctl.NotFoundException>(data['data']);
    }
    if (dataClassName == 'TaxRulesUnavailableException') {
      return deserialize<_i4yu9vcq.TaxRulesUnavailableException>(data['data']);
    }
    if (dataClassName == 'ValidationException') {
      return deserialize<_igpdbyom.ValidationException>(data['data']);
    }
    if (dataClassName == 'WalletPreviewRateLimitedException') {
      return deserialize<_i4nmh6wd.WalletPreviewRateLimitedException>(
        data['data'],
      );
    }
    if (dataClassName == 'FxLatestSnapshot') {
      return deserialize<_i8cxakqz.FxLatestSnapshot>(data['data']);
    }
    if (dataClassName == 'FxProvider') {
      return deserialize<_ifsg8hc8.FxProvider>(data['data']);
    }
    if (dataClassName == 'FxQuoteView') {
      return deserialize<_i8bj7347.FxQuoteView>(data['data']);
    }
    if (dataClassName == 'FxRateQuote') {
      return deserialize<_i15udi7x.FxRateQuote>(data['data']);
    }
    if (dataClassName == 'Institution') {
      return deserialize<_ikgmcjq7.Institution>(data['data']);
    }
    if (dataClassName == 'InstitutionLocation') {
      return deserialize<_iclizrec.InstitutionLocation>(data['data']);
    }
    if (dataClassName == 'Journal') {
      return deserialize<_iqqjzj2w.Journal>(data['data']);
    }
    if (dataClassName == 'JournalLine') {
      return deserialize<_i6l0fo54.JournalLine>(data['data']);
    }
    if (dataClassName == 'JournalLineInput') {
      return deserialize<_id7zp91q.JournalLineInput>(data['data']);
    }
    if (dataClassName == 'LedgerAccount') {
      return deserialize<_ivazbnnp.LedgerAccount>(data['data']);
    }
    if (dataClassName == 'LedgerPeriodLock') {
      return deserialize<_i7t4btg4.LedgerPeriodLock>(data['data']);
    }
    if (dataClassName == 'TrialBalanceRowView') {
      return deserialize<_i5gsx3ds.TrialBalanceRowView>(data['data']);
    }
    if (dataClassName == 'TrialBalanceView') {
      return deserialize<_i7q128aw.TrialBalanceView>(data['data']);
    }
    if (dataClassName == 'MonthlyAllocation') {
      return deserialize<_igdgld5u.MonthlyAllocation>(data['data']);
    }
    if (dataClassName == 'Payee') {
      return deserialize<_ignezpci.Payee>(data['data']);
    }
    if (dataClassName == 'PlaidConnection') {
      return deserialize<_i1vmvtrm.PlaidConnection>(data['data']);
    }
    if (dataClassName == 'RecurringTransaction') {
      return deserialize<_i9is7zb8.RecurringTransaction>(data['data']);
    }
    if (dataClassName == 'NetWorthAccountRow') {
      return deserialize<_ieg4kkwo.NetWorthAccountRow>(data['data']);
    }
    if (dataClassName == 'NetWorthCurrencyRow') {
      return deserialize<_if6ke1e2.NetWorthCurrencyRow>(data['data']);
    }
    if (dataClassName == 'NetWorthEntityRow') {
      return deserialize<_i2p47r1m.NetWorthEntityRow>(data['data']);
    }
    if (dataClassName == 'NetWorthGranularity') {
      return deserialize<_iiyi1fdi.NetWorthGranularity>(data['data']);
    }
    if (dataClassName == 'NetWorthHistoryView') {
      return deserialize<_izpykydm.NetWorthHistoryView>(data['data']);
    }
    if (dataClassName == 'NetWorthPoint') {
      return deserialize<_ihwosu5p.NetWorthPoint>(data['data']);
    }
    if (dataClassName == 'NetWorthView') {
      return deserialize<_idk5va87.NetWorthView>(data['data']);
    }
    if (dataClassName == 'ReportGrouping') {
      return deserialize<_ijpgwwdu.ReportGrouping>(data['data']);
    }
    if (dataClassName == 'SpendingRow') {
      return deserialize<_ikppksh7.SpendingRow>(data['data']);
    }
    if (dataClassName == 'UserSettings') {
      return deserialize<_i99f9doz.UserSettings>(data['data']);
    }
    if (dataClassName == 'TaxBandSliceView') {
      return deserialize<_ic4zfx3b.TaxBandSliceView>(data['data']);
    }
    if (dataClassName == 'TaxCategoryView') {
      return deserialize<_iv5oayw3.TaxCategoryView>(data['data']);
    }
    if (dataClassName == 'TaxFigureView') {
      return deserialize<_ixm9q9lk.TaxFigureView>(data['data']);
    }
    if (dataClassName == 'TaxLiabilityView') {
      return deserialize<_ivss6b81.TaxLiabilityView>(data['data']);
    }
    if (dataClassName == 'TaxOpportunityView') {
      return deserialize<_iuft4v7q.TaxOpportunityView>(data['data']);
    }
    if (dataClassName == 'TaxProfileRecord') {
      return deserialize<_i20z9jax.TaxProfileRecord>(data['data']);
    }
    if (dataClassName == 'TaxReportLineView') {
      return deserialize<_i6llsezf.TaxReportLineView>(data['data']);
    }
    if (dataClassName == 'TaxReportView') {
      return deserialize<_inb54q20.TaxReportView>(data['data']);
    }
    if (dataClassName == 'TaxRuleCaveatView') {
      return deserialize<_i97pej5a.TaxRuleCaveatView>(data['data']);
    }
    if (dataClassName == 'TaxSummaryCategoryTotalView') {
      return deserialize<_ilbx4erh.TaxSummaryCategoryTotalView>(data['data']);
    }
    if (dataClassName == 'TaxSummaryFxNoteView') {
      return deserialize<_iok5qj2e.TaxSummaryFxNoteView>(data['data']);
    }
    if (dataClassName == 'TaxSummarySalesTaxQuarterView') {
      return deserialize<_it9yyajv.TaxSummarySalesTaxQuarterView>(data['data']);
    }
    if (dataClassName == 'TaxSummarySalesTaxRateView') {
      return deserialize<_iabhnw50.TaxSummarySalesTaxRateView>(data['data']);
    }
    if (dataClassName == 'TaxSummaryView') {
      return deserialize<_i5jsilqj.TaxSummaryView>(data['data']);
    }
    if (dataClassName == 'TaxSummaryWalletView') {
      return deserialize<_ij9k0z9z.TaxSummaryWalletView>(data['data']);
    }
    if (dataClassName == 'TransactionRule') {
      return deserialize<_i6dj6ji0.TransactionRule>(data['data']);
    }
    if (dataClassName == 'ImportResult') {
      return deserialize<_ibzcfs2k.ImportResult>(data['data']);
    }
    if (dataClassName == 'ImportRow') {
      return deserialize<_isp6bezg.ImportRow>(data['data']);
    }
    if (dataClassName == 'ReconcileResult') {
      return deserialize<_igokbqfh.ReconcileResult>(data['data']);
    }
    if (dataClassName == 'Transaction') {
      return deserialize<_iqhl4hru.Transaction>(data['data']);
    }
    if (dataClassName == 'TransactionFlag') {
      return deserialize<_i4fvctax.TransactionFlag>(data['data']);
    }
    if (dataClassName == 'TransactionInput') {
      return deserialize<_ipd1rac6.TransactionInput>(data['data']);
    }
    if (dataClassName == 'TransactionKind') {
      return deserialize<_ioneruif.TransactionKind>(data['data']);
    }
    if (dataClassName == 'TransactionLine') {
      return deserialize<_ipio7ws3.TransactionLine>(data['data']);
    }
    if (dataClassName == 'TransactionLineInput') {
      return deserialize<_imsv7m6w.TransactionLineInput>(data['data']);
    }
    if (dataClassName == 'TransactionPage') {
      return deserialize<_i7f3q91r.TransactionPage>(data['data']);
    }
    if (dataClassName == 'TransactionQuery') {
      return deserialize<_ioinkgwn.TransactionQuery>(data['data']);
    }
    if (dataClassName == 'TransactionStatus') {
      return deserialize<_i3rynkdl.TransactionStatus>(data['data']);
    }
    if (dataClassName == 'TransactionView') {
      return deserialize<_ilixdhed.TransactionView>(data['data']);
    }
    if (dataClassName == 'Transfer') {
      return deserialize<_ign516jt.Transfer>(data['data']);
    }
    if (dataClassName == 'TransferInput') {
      return deserialize<_iah0rmrk.TransferInput>(data['data']);
    }
    if (dataClassName == 'TransferPeerView') {
      return deserialize<_i3n9n3ej.TransferPeerView>(data['data']);
    }
    if (dataClassName == 'HoldingPosition') {
      return deserialize<_iq0sbxsc.HoldingPosition>(data['data']);
    }
    if (dataClassName == 'PriceQuality') {
      return deserialize<_i6j30n20.PriceQuality>(data['data']);
    }
    if (dataClassName == 'PriceSource') {
      return deserialize<_iu1a5mev.PriceSource>(data['data']);
    }
    if (dataClassName == 'SpamVerdict') {
      return deserialize<_i4uehszw.SpamVerdict>(data['data']);
    }
    if (dataClassName == 'Wallet') {
      return deserialize<_ilu5i0rn.Wallet>(data['data']);
    }
    if (dataClassName == 'WalletHolding') {
      return deserialize<_iqqppnaa.WalletHolding>(data['data']);
    }
    if (dataClassName == 'WalletNetworkState') {
      return deserialize<_i73xhbar.WalletNetworkState>(data['data']);
    }
    if (dataClassName == 'WalletPreview') {
      return deserialize<_iuw2colh.WalletPreview>(data['data']);
    }
    if (dataClassName == 'WalletPreviewNetwork') {
      return deserialize<_icbqx9y3.WalletPreviewNetwork>(data['data']);
    }
    if (dataClassName == 'WalletSyncResult') {
      return deserialize<_ipdq2p58.WalletSyncResult>(data['data']);
    }
    if (dataClassName == 'WalletTaxYearSummary') {
      return deserialize<_ivsmsmw6.WalletTaxYearSummary>(data['data']);
    }
    if (dataClassName == 'WalletTransaction') {
      return deserialize<_i6m1jx15.WalletTransaction>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      return _iaic.Protocol().deserializeByClassName({
        ...data,
        'className': dataClassName.substring(19),
      });
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      return _iacc.Protocol().deserializeByClassName({
        ...data,
        'className': dataClassName.substring(20),
      });
    }
    if (dataClassName.startsWith('openbudget_core.')) {
      return _ifz8weqz.Protocol().deserializeByClassName({
        ...data,
        'className': dataClassName.substring(16),
      });
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('openbudget', this);
    _iacc.Protocol().registerHostProtocol('openbudget', this);
    _ifz8weqz.Protocol().registerHostProtocol('openbudget', this);
  }

  @override
  String getModuleName() => 'openbudget';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
