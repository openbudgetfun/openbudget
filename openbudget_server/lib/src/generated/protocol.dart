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
import 'package:openbudget_core/openbudget_core.dart' as _ifz8weqz;
import 'package:openbudget_server/src/generated/accounts/account.dart'
    as _i3fh9aci;
import 'package:openbudget_server/src/generated/accounts/account_valuation.dart'
    as _itqzh2rv;
import 'package:openbudget_server/src/generated/agent/agent_conversation.dart'
    as _ihq3j0fx;
import 'package:openbudget_server/src/generated/agent/agent_message.dart'
    as _ixbh63dx;
import 'package:openbudget_server/src/generated/agent/agent_proposal.dart'
    as _iqa5uoc4;
import 'package:openbudget_server/src/generated/agent/mcp/agent_access_token_view.dart'
    as _i8fy0qox;
import 'package:openbudget_server/src/generated/audit/audit_event.dart'
    as _ictk02ka;
import 'package:openbudget_server/src/generated/budget/allocation_input.dart'
    as _inwbkajl;
import 'package:openbudget_server/src/generated/budget/budget_month_summary.dart'
    as _ipz3w5am;
import 'package:openbudget_server/src/generated/budget_templates/budget_template.dart'
    as _ihbdj8p6;
import 'package:openbudget_server/src/generated/budget_templates/budget_template_line.dart'
    as _iz4ekkcc;
import 'package:openbudget_server/src/generated/categories/category.dart'
    as _iwlneq7u;
import 'package:openbudget_server/src/generated/entities/entity.dart'
    as _if2ry2np;
import 'package:openbudget_server/src/generated/entities/entity_summary_view.dart'
    as _im3neacv;
import 'package:openbudget_server/src/generated/envelope_goals/envelope_goal.dart'
    as _iuyjld9f;
import 'package:openbudget_server/src/generated/envelopes/envelope.dart'
    as _igwnqatb;
import 'package:openbudget_server/src/generated/institutions/institution.dart'
    as _izagyfe8;
import 'package:openbudget_server/src/generated/ledger/journal.dart'
    as _ixvlhhyv;
import 'package:openbudget_server/src/generated/ledger/journal_line.dart'
    as _icjh3b69;
import 'package:openbudget_server/src/generated/ledger/journal_line_input.dart'
    as _in0sxdux;
import 'package:openbudget_server/src/generated/ledger/ledger_account.dart'
    as _iab1c098;
import 'package:openbudget_server/src/generated/payees/payee.dart' as _i2xhh3nq;
import 'package:openbudget_server/src/generated/plaid/plaid_connection.dart'
    as _iyqk0wcc;
import 'package:openbudget_server/src/generated/recurring_transactions/recurring_transaction.dart'
    as _i6lbncsb;
import 'package:openbudget_server/src/generated/reports/spending_row.dart'
    as _ijvd4zl8;
import 'package:openbudget_server/src/generated/tax/tax_category_view.dart'
    as _i687t6y5;
import 'package:openbudget_server/src/generated/transaction_rules/transaction_rule.dart'
    as _i4wqhpw2;
import 'package:openbudget_server/src/generated/transactions/import_row.dart'
    as _iyod81ld;
import 'package:openbudget_server/src/generated/transactions/transaction_view.dart'
    as _iw07wj0h;
import 'package:openbudget_server/src/generated/wallets/wallet.dart'
    as _igcr1vxe;
import 'package:openbudget_server/src/generated/wallets/wallet_holding.dart'
    as _icu5m6lt;
import 'package:openbudget_server/src/generated/wallets/wallet_tax_year_summary.dart'
    as _ilgsya0a;
import 'package:openbudget_server/src/generated/wallets/wallet_transaction.dart'
    as _imzwq91q;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;

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
import 'agent/agent_provider_settings.dart' as _ipqgbdtd;
import 'agent/agent_provider_settings_view.dart' as _i0760q1h;
import 'agent/agent_usage_record.dart' as _igo4k2bu;
import 'agent/agent_usage_view.dart' as _ipqjijih;
import 'agent/mcp/agent_access_token.dart' as _i8betnj7;
import 'agent/mcp/agent_access_token_created.dart' as _iis6jewo;
import 'agent/mcp/agent_access_token_view.dart' as _i4mcrc97;
import 'audit/audit_action.dart' as _iqje9mi5;
import 'audit/audit_event.dart' as _ijhj7cd7;
import 'audit/audit_subject.dart' as _i2sn5a56;
import 'billing/entitlement.dart' as _iq2w1sa5;
import 'billing/entitlement_source.dart' as _ipnf4x0i;
import 'billing/entitlement_status.dart' as _imqwzx9j;
import 'billing/solana_billing_challenge.dart' as _iw7l0hzr;
import 'billing/solana_plan_view.dart' as _iwxkomal;
import 'billing/stripe_customer.dart' as _in1nt6tx;
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
import 'future_calls_generated_models/fx_backfill_future_call_fetch_model.dart'
    as _iuflqeka;
import 'fx_rates/fx_latest_snapshot.dart' as _i8cxakqz;
import 'fx_rates/fx_provider.dart' as _ifsg8hc8;
import 'fx_rates/fx_quote_view.dart' as _i8bj7347;
import 'fx_rates/fx_rate.dart' as _i46rvf1t;
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
import 'tax/tax_liability_view.dart' as _ivss6b81;
import 'tax/tax_opportunity_view.dart' as _iuft4v7q;
import 'tax/tax_profile.dart' as _i20z9jax;
import 'tax/tax_report_line_view.dart' as _i6llsezf;
import 'tax/tax_report_view.dart' as _inb54q20;
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
import 'wallets/asset_price.dart' as _iw6q2afx;
import 'wallets/holding_position.dart' as _iq0sbxsc;
import 'wallets/price_quality.dart' as _i6j30n20;
import 'wallets/price_source.dart' as _iu1a5mev;
import 'wallets/spam_verdict.dart' as _i4uehszw;
import 'wallets/wallet.dart' as _ilu5i0rn;
import 'wallets/wallet_holding.dart' as _iqqppnaa;
import 'wallets/wallet_network_state.dart' as _i73xhbar;
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
export 'agent/agent_provider_settings.dart';
export 'agent/agent_provider_settings_view.dart';
export 'agent/agent_usage_record.dart';
export 'agent/agent_usage_view.dart';
export 'agent/mcp/agent_access_token.dart';
export 'agent/mcp/agent_access_token_created.dart';
export 'agent/mcp/agent_access_token_view.dart';
export 'audit/audit_action.dart';
export 'audit/audit_event.dart';
export 'audit/audit_subject.dart';
export 'billing/entitlement.dart';
export 'billing/entitlement_source.dart';
export 'billing/entitlement_status.dart';
export 'billing/solana_billing_challenge.dart';
export 'billing/solana_plan_view.dart';
export 'billing/stripe_customer.dart';
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
export 'fx_rates/fx_latest_snapshot.dart';
export 'fx_rates/fx_provider.dart';
export 'fx_rates/fx_quote_view.dart';
export 'fx_rates/fx_rate.dart';
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
export 'tax/tax_liability_view.dart';
export 'tax/tax_opportunity_view.dart';
export 'tax/tax_profile.dart';
export 'tax/tax_report_line_view.dart';
export 'tax/tax_report_view.dart';
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
export 'wallets/asset_price.dart';
export 'wallets/holding_position.dart';
export 'wallets/price_quality.dart';
export 'wallets/price_source.dart';
export 'wallets/spam_verdict.dart';
export 'wallets/wallet.dart';
export 'wallets/wallet_holding.dart';
export 'wallets/wallet_network_state.dart';
export 'wallets/wallet_sync_result.dart';
export 'wallets/wallet_tax_year_summary.dart';
export 'wallets/wallet_transaction.dart';

class Protocol extends _is.DatabaseSerializationManager
    implements _is.DatabaseProtocolDeserializationProvider {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  @override
  _is.ProtocolDeserialization get deserializationMetadata =>
      _is.ProtocolDeserialization.cached(
        this,
        types: const [
          _is.getType<_iz2jf14v.Account>,
          _is.getType<_i53yl4yp.AccountBalancesView>,
          _is.getType<_i87oqvv1.AccountValuation>,
          _is.getType<_ig9cy6ku.ValuationSource>,
          _is.getType<_isfmgqgu.AgentConversation>,
          _is.getType<_i769eo9u.AgentEvent>,
          _is.getType<_iyhb15ax.AgentEventKind>,
          _is.getType<_inwxyid7.AgentMessage>,
          _is.getType<_iy2njbiw.AgentMessageRole>,
          _is.getType<_iqh65hzq.AgentProposal>,
          _is.getType<_idxyy01n.AgentProposalKind>,
          _is.getType<_iksk16ej.AgentProposalStatus>,
          _is.getType<_ic667156.AgentProvider>,
          _is.getType<_ipqgbdtd.AgentProviderSettings>,
          _is.getType<_i0760q1h.AgentProviderSettingsView>,
          _is.getType<_igo4k2bu.AgentUsageRecord>,
          _is.getType<_ipqjijih.AgentUsageView>,
          _is.getType<_i8betnj7.AgentAccessToken>,
          _is.getType<_iis6jewo.AgentAccessTokenCreated>,
          _is.getType<_i4mcrc97.AgentAccessTokenView>,
          _is.getType<_iqje9mi5.AuditAction>,
          _is.getType<_ijhj7cd7.AuditEvent>,
          _is.getType<_i2sn5a56.AuditSubject>,
          _is.getType<_iq2w1sa5.Entitlement>,
          _is.getType<_ipnf4x0i.EntitlementSource>,
          _is.getType<_imqwzx9j.EntitlementStatus>,
          _is.getType<_iw7l0hzr.SolanaBillingChallenge>,
          _is.getType<_iwxkomal.SolanaPlanView>,
          _is.getType<_in1nt6tx.StripeCustomer>,
          _is.getType<_iouaddet.AllocationInput>,
          _is.getType<_ixyov90t.BudgetMonthSummary>,
          _is.getType<_ihanl5km.BudgetMonthView>,
          _is.getType<_ii8h2sft.EnvelopeMonthView>,
          _is.getType<_i01fne9j.BudgetTemplate>,
          _is.getType<_iagnrffn.BudgetTemplateLine>,
          _is.getType<_iwxpkdmg.Category>,
          _is.getType<_i4zfq652.Confidence>,
          _is.getType<_iynfhhr3.SyncStatus>,
          _is.getType<_i03vgs6n.ChangeScope>,
          _is.getType<_iamyw1yn.Entity>,
          _is.getType<_is12mxpv.EntityChangedEvent>,
          _is.getType<_ihqn2h4c.EntitySummaryView>,
          _is.getType<_ifl4yivq.EnvelopeGoal>,
          _is.getType<_i61aeoqs.EnvelopeGoalKind>,
          _is.getType<_ikt21dfw.Envelope>,
          _is.getType<_iozei2bz.AgentAllowanceExhaustedException>,
          _is.getType<_iurccglg.AgentProviderException>,
          _is.getType<_i6p28blo.AgentProviderUnavailableException>,
          _is.getType<_io2kod1y.AuthenticationRequiredException>,
          _is.getType<_i9zkhl6f.BillingProviderException>,
          _is.getType<_i5kq7itn.BillingRailUnavailableException>,
          _is.getType<_ik3lny6q.EntitlementRequiredException>,
          _is.getType<_iha6yc5u.ForbiddenException>,
          _is.getType<_if5umnl3.FxRateUnavailableException>,
          _is.getType<_izob2ctl.NotFoundException>,
          _is.getType<_i4yu9vcq.TaxRulesUnavailableException>,
          _is.getType<_igpdbyom.ValidationException>,
          _is.getType<_iuflqeka.FxBackfillFutureCallFetchModel>,
          _is.getType<_i8cxakqz.FxLatestSnapshot>,
          _is.getType<_ifsg8hc8.FxProvider>,
          _is.getType<_i8bj7347.FxQuoteView>,
          _is.getType<_i46rvf1t.FxRate>,
          _is.getType<_i15udi7x.FxRateQuote>,
          _is.getType<_ikgmcjq7.Institution>,
          _is.getType<_iclizrec.InstitutionLocation>,
          _is.getType<_iqqjzj2w.Journal>,
          _is.getType<_i6l0fo54.JournalLine>,
          _is.getType<_id7zp91q.JournalLineInput>,
          _is.getType<_ivazbnnp.LedgerAccount>,
          _is.getType<_i7t4btg4.LedgerPeriodLock>,
          _is.getType<_i5gsx3ds.TrialBalanceRowView>,
          _is.getType<_i7q128aw.TrialBalanceView>,
          _is.getType<_igdgld5u.MonthlyAllocation>,
          _is.getType<_ignezpci.Payee>,
          _is.getType<_i1vmvtrm.PlaidConnection>,
          _is.getType<_i9is7zb8.RecurringTransaction>,
          _is.getType<_ieg4kkwo.NetWorthAccountRow>,
          _is.getType<_if6ke1e2.NetWorthCurrencyRow>,
          _is.getType<_i2p47r1m.NetWorthEntityRow>,
          _is.getType<_iiyi1fdi.NetWorthGranularity>,
          _is.getType<_izpykydm.NetWorthHistoryView>,
          _is.getType<_ihwosu5p.NetWorthPoint>,
          _is.getType<_idk5va87.NetWorthView>,
          _is.getType<_ijpgwwdu.ReportGrouping>,
          _is.getType<_ikppksh7.SpendingRow>,
          _is.getType<_i99f9doz.UserSettings>,
          _is.getType<_ic4zfx3b.TaxBandSliceView>,
          _is.getType<_iv5oayw3.TaxCategoryView>,
          _is.getType<_ivss6b81.TaxLiabilityView>,
          _is.getType<_iuft4v7q.TaxOpportunityView>,
          _is.getType<_i20z9jax.TaxProfileRecord>,
          _is.getType<_i6llsezf.TaxReportLineView>,
          _is.getType<_inb54q20.TaxReportView>,
          _is.getType<_ilbx4erh.TaxSummaryCategoryTotalView>,
          _is.getType<_iok5qj2e.TaxSummaryFxNoteView>,
          _is.getType<_it9yyajv.TaxSummarySalesTaxQuarterView>,
          _is.getType<_iabhnw50.TaxSummarySalesTaxRateView>,
          _is.getType<_i5jsilqj.TaxSummaryView>,
          _is.getType<_ij9k0z9z.TaxSummaryWalletView>,
          _is.getType<_i6dj6ji0.TransactionRule>,
          _is.getType<_ibzcfs2k.ImportResult>,
          _is.getType<_isp6bezg.ImportRow>,
          _is.getType<_igokbqfh.ReconcileResult>,
          _is.getType<_iqhl4hru.Transaction>,
          _is.getType<_i4fvctax.TransactionFlag>,
          _is.getType<_ipd1rac6.TransactionInput>,
          _is.getType<_ioneruif.TransactionKind>,
          _is.getType<_ipio7ws3.TransactionLine>,
          _is.getType<_imsv7m6w.TransactionLineInput>,
          _is.getType<_i7f3q91r.TransactionPage>,
          _is.getType<_ioinkgwn.TransactionQuery>,
          _is.getType<_i3rynkdl.TransactionStatus>,
          _is.getType<_ilixdhed.TransactionView>,
          _is.getType<_ign516jt.Transfer>,
          _is.getType<_iah0rmrk.TransferInput>,
          _is.getType<_i3n9n3ej.TransferPeerView>,
          _is.getType<_iw6q2afx.AssetPrice>,
          _is.getType<_iq0sbxsc.HoldingPosition>,
          _is.getType<_i6j30n20.PriceQuality>,
          _is.getType<_iu1a5mev.PriceSource>,
          _is.getType<_i4uehszw.SpamVerdict>,
          _is.getType<_ilu5i0rn.Wallet>,
          _is.getType<_iqqppnaa.WalletHolding>,
          _is.getType<_i73xhbar.WalletNetworkState>,
          _is.getType<_ipdq2p58.WalletSyncResult>,
          _is.getType<_ivsmsmw6.WalletTaxYearSummary>,
          _is.getType<_i6m1jx15.WalletTransaction>,
          _is.getType<_iz2jf14v.Account?>,
          _is.getType<_i53yl4yp.AccountBalancesView?>,
          _is.getType<_i87oqvv1.AccountValuation?>,
          _is.getType<_ig9cy6ku.ValuationSource?>,
          _is.getType<_isfmgqgu.AgentConversation?>,
          _is.getType<_i769eo9u.AgentEvent?>,
          _is.getType<_iyhb15ax.AgentEventKind?>,
          _is.getType<_inwxyid7.AgentMessage?>,
          _is.getType<_iy2njbiw.AgentMessageRole?>,
          _is.getType<_iqh65hzq.AgentProposal?>,
          _is.getType<_idxyy01n.AgentProposalKind?>,
          _is.getType<_iksk16ej.AgentProposalStatus?>,
          _is.getType<_ic667156.AgentProvider?>,
          _is.getType<_ipqgbdtd.AgentProviderSettings?>,
          _is.getType<_i0760q1h.AgentProviderSettingsView?>,
          _is.getType<_igo4k2bu.AgentUsageRecord?>,
          _is.getType<_ipqjijih.AgentUsageView?>,
          _is.getType<_i8betnj7.AgentAccessToken?>,
          _is.getType<_iis6jewo.AgentAccessTokenCreated?>,
          _is.getType<_i4mcrc97.AgentAccessTokenView?>,
          _is.getType<_iqje9mi5.AuditAction?>,
          _is.getType<_ijhj7cd7.AuditEvent?>,
          _is.getType<_i2sn5a56.AuditSubject?>,
          _is.getType<_iq2w1sa5.Entitlement?>,
          _is.getType<_ipnf4x0i.EntitlementSource?>,
          _is.getType<_imqwzx9j.EntitlementStatus?>,
          _is.getType<_iw7l0hzr.SolanaBillingChallenge?>,
          _is.getType<_iwxkomal.SolanaPlanView?>,
          _is.getType<_in1nt6tx.StripeCustomer?>,
          _is.getType<_iouaddet.AllocationInput?>,
          _is.getType<_ixyov90t.BudgetMonthSummary?>,
          _is.getType<_ihanl5km.BudgetMonthView?>,
          _is.getType<_ii8h2sft.EnvelopeMonthView?>,
          _is.getType<_i01fne9j.BudgetTemplate?>,
          _is.getType<_iagnrffn.BudgetTemplateLine?>,
          _is.getType<_iwxpkdmg.Category?>,
          _is.getType<_i4zfq652.Confidence?>,
          _is.getType<_iynfhhr3.SyncStatus?>,
          _is.getType<_i03vgs6n.ChangeScope?>,
          _is.getType<_iamyw1yn.Entity?>,
          _is.getType<_is12mxpv.EntityChangedEvent?>,
          _is.getType<_ihqn2h4c.EntitySummaryView?>,
          _is.getType<_ifl4yivq.EnvelopeGoal?>,
          _is.getType<_i61aeoqs.EnvelopeGoalKind?>,
          _is.getType<_ikt21dfw.Envelope?>,
          _is.getType<_iozei2bz.AgentAllowanceExhaustedException?>,
          _is.getType<_iurccglg.AgentProviderException?>,
          _is.getType<_i6p28blo.AgentProviderUnavailableException?>,
          _is.getType<_io2kod1y.AuthenticationRequiredException?>,
          _is.getType<_i9zkhl6f.BillingProviderException?>,
          _is.getType<_i5kq7itn.BillingRailUnavailableException?>,
          _is.getType<_ik3lny6q.EntitlementRequiredException?>,
          _is.getType<_iha6yc5u.ForbiddenException?>,
          _is.getType<_if5umnl3.FxRateUnavailableException?>,
          _is.getType<_izob2ctl.NotFoundException?>,
          _is.getType<_i4yu9vcq.TaxRulesUnavailableException?>,
          _is.getType<_igpdbyom.ValidationException?>,
          _is.getType<_iuflqeka.FxBackfillFutureCallFetchModel?>,
          _is.getType<_i8cxakqz.FxLatestSnapshot?>,
          _is.getType<_ifsg8hc8.FxProvider?>,
          _is.getType<_i8bj7347.FxQuoteView?>,
          _is.getType<_i46rvf1t.FxRate?>,
          _is.getType<_i15udi7x.FxRateQuote?>,
          _is.getType<_ikgmcjq7.Institution?>,
          _is.getType<_iclizrec.InstitutionLocation?>,
          _is.getType<_iqqjzj2w.Journal?>,
          _is.getType<_i6l0fo54.JournalLine?>,
          _is.getType<_id7zp91q.JournalLineInput?>,
          _is.getType<_ivazbnnp.LedgerAccount?>,
          _is.getType<_i7t4btg4.LedgerPeriodLock?>,
          _is.getType<_i5gsx3ds.TrialBalanceRowView?>,
          _is.getType<_i7q128aw.TrialBalanceView?>,
          _is.getType<_igdgld5u.MonthlyAllocation?>,
          _is.getType<_ignezpci.Payee?>,
          _is.getType<_i1vmvtrm.PlaidConnection?>,
          _is.getType<_i9is7zb8.RecurringTransaction?>,
          _is.getType<_ieg4kkwo.NetWorthAccountRow?>,
          _is.getType<_if6ke1e2.NetWorthCurrencyRow?>,
          _is.getType<_i2p47r1m.NetWorthEntityRow?>,
          _is.getType<_iiyi1fdi.NetWorthGranularity?>,
          _is.getType<_izpykydm.NetWorthHistoryView?>,
          _is.getType<_ihwosu5p.NetWorthPoint?>,
          _is.getType<_idk5va87.NetWorthView?>,
          _is.getType<_ijpgwwdu.ReportGrouping?>,
          _is.getType<_ikppksh7.SpendingRow?>,
          _is.getType<_i99f9doz.UserSettings?>,
          _is.getType<_ic4zfx3b.TaxBandSliceView?>,
          _is.getType<_iv5oayw3.TaxCategoryView?>,
          _is.getType<_ivss6b81.TaxLiabilityView?>,
          _is.getType<_iuft4v7q.TaxOpportunityView?>,
          _is.getType<_i20z9jax.TaxProfileRecord?>,
          _is.getType<_i6llsezf.TaxReportLineView?>,
          _is.getType<_inb54q20.TaxReportView?>,
          _is.getType<_ilbx4erh.TaxSummaryCategoryTotalView?>,
          _is.getType<_iok5qj2e.TaxSummaryFxNoteView?>,
          _is.getType<_it9yyajv.TaxSummarySalesTaxQuarterView?>,
          _is.getType<_iabhnw50.TaxSummarySalesTaxRateView?>,
          _is.getType<_i5jsilqj.TaxSummaryView?>,
          _is.getType<_ij9k0z9z.TaxSummaryWalletView?>,
          _is.getType<_i6dj6ji0.TransactionRule?>,
          _is.getType<_ibzcfs2k.ImportResult?>,
          _is.getType<_isp6bezg.ImportRow?>,
          _is.getType<_igokbqfh.ReconcileResult?>,
          _is.getType<_iqhl4hru.Transaction?>,
          _is.getType<_i4fvctax.TransactionFlag?>,
          _is.getType<_ipd1rac6.TransactionInput?>,
          _is.getType<_ioneruif.TransactionKind?>,
          _is.getType<_ipio7ws3.TransactionLine?>,
          _is.getType<_imsv7m6w.TransactionLineInput?>,
          _is.getType<_i7f3q91r.TransactionPage?>,
          _is.getType<_ioinkgwn.TransactionQuery?>,
          _is.getType<_i3rynkdl.TransactionStatus?>,
          _is.getType<_ilixdhed.TransactionView?>,
          _is.getType<_ign516jt.Transfer?>,
          _is.getType<_iah0rmrk.TransferInput?>,
          _is.getType<_i3n9n3ej.TransferPeerView?>,
          _is.getType<_iw6q2afx.AssetPrice?>,
          _is.getType<_iq0sbxsc.HoldingPosition?>,
          _is.getType<_i6j30n20.PriceQuality?>,
          _is.getType<_iu1a5mev.PriceSource?>,
          _is.getType<_i4uehszw.SpamVerdict?>,
          _is.getType<_ilu5i0rn.Wallet?>,
          _is.getType<_iqqppnaa.WalletHolding?>,
          _is.getType<_i73xhbar.WalletNetworkState?>,
          _is.getType<_ipdq2p58.WalletSyncResult?>,
          _is.getType<_ivsmsmw6.WalletTaxYearSummary?>,
          _is.getType<_i6m1jx15.WalletTransaction?>,
          _is.getType<List<_iwxpkdmg.Category>>,
          _is.getType<List<_ii8h2sft.EnvelopeMonthView>>,
          _is.getType<List<_i15udi7x.FxRateQuote>>,
          _is.getType<List<_i5gsx3ds.TrialBalanceRowView>>,
          _is.getType<List<_ihwosu5p.NetWorthPoint>>,
          _is.getType<List<String>>,
          _is.getType<List<_if6ke1e2.NetWorthCurrencyRow>>,
          _is.getType<List<_i2p47r1m.NetWorthEntityRow>>,
          _is.getType<List<_ieg4kkwo.NetWorthAccountRow>>,
          _is.getType<List<_ic4zfx3b.TaxBandSliceView>>,
          _is.getType<List<_i6llsezf.TaxReportLineView>>,
          _is.getType<List<_ivss6b81.TaxLiabilityView>>,
          _is.getType<Map<String, String>>,
          _is.getType<List<_iuft4v7q.TaxOpportunityView>>,
          _is.getType<List<_ilbx4erh.TaxSummaryCategoryTotalView>>,
          _is.getType<List<_iabhnw50.TaxSummarySalesTaxRateView>>,
          _is.getType<List<_it9yyajv.TaxSummarySalesTaxQuarterView>>,
          _is.getType<List<_ij9k0z9z.TaxSummaryWalletView>>,
          _is.getType<List<_iok5qj2e.TaxSummaryFxNoteView>>,
          _is.getType<List<_imsv7m6w.TransactionLineInput>>,
          _is.getType<List<_ilixdhed.TransactionView>>,
          _is.getType<List<_ipio7ws3.TransactionLine>>,
          _is.getType<List<_ifz8weqz.WalletNetwork>>,
          _is.getType<List<_ifz8weqz.WalletNetwork>?>,
          _is.getType<List<String>?>,
          _is.getType<List<_i3fh9aci.Account>>,
          _is.getType<List<_is.UuidValue>>,
          _is.getType<List<_itqzh2rv.AccountValuation>>,
          _is.getType<List<_ihq3j0fx.AgentConversation>>,
          _is.getType<List<_ixbh63dx.AgentMessage>>,
          _is.getType<List<_iqa5uoc4.AgentProposal>>,
          _is.getType<List<_i8fy0qox.AgentAccessTokenView>>,
          _is.getType<List<_inwbkajl.AllocationInput>>,
          _is.getType<List<_ihbdj8p6.BudgetTemplate>>,
          _is.getType<List<_iz4ekkcc.BudgetTemplateLine>>,
          _is.getType<List<_iwlneq7u.Category>>,
          _is.getType<List<_if2ry2np.Entity>>,
          _is.getType<List<_im3neacv.EntitySummaryView>>,
          _is.getType<List<_iuyjld9f.EnvelopeGoal>>,
          _is.getType<List<_igwnqatb.Envelope>>,
          _is.getType<List<_izagyfe8.Institution>>,
          _is.getType<List<_iab1c098.LedgerAccount>>,
          _is.getType<List<_in0sxdux.JournalLineInput>>,
          _is.getType<List<_ixvlhhyv.Journal>>,
          _is.getType<List<_icjh3b69.JournalLine>>,
          _is.getType<List<_ictk02ka.AuditEvent>>,
          _is.getType<List<_i2xhh3nq.Payee>>,
          _is.getType<List<_iyqk0wcc.PlaidConnection>>,
          _is.getType<List<_i6lbncsb.RecurringTransaction>>,
          _is.getType<List<_is.UuidValue>?>,
          _is.getType<List<_ijvd4zl8.SpendingRow>>,
          _is.getType<List<_ipz3w5am.BudgetMonthSummary>>,
          _is.getType<List<_i687t6y5.TaxCategoryView>>,
          _is.getType<List<_i4wqhpw2.TransactionRule>>,
          _is.getType<List<_iw07wj0h.TransactionView>>,
          _is.getType<List<_iyod81ld.ImportRow>>,
          _is.getType<List<_igcr1vxe.Wallet>>,
          _is.getType<List<_icu5m6lt.WalletHolding>>,
          _is.getType<List<_imzwq91q.WalletTransaction>>,
          _is.getType<List<_ilgsya0a.WalletTaxYearSummary>>,
          _is.getType<List<String>>,
          _is.getType<List<String>?>,
        ],
        modules: const [
          _iais.Protocol.new,
          _iacs.Protocol.new,
          _ifz8weqz.Protocol.new,
          _isp.Protocol.new,
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
          'AgentProviderSettings',
          'AgentProviderSettingsView',
          'AgentUsageRecord',
          'AgentUsageView',
          'AgentAccessToken',
          'AgentAccessTokenCreated',
          'AgentAccessTokenView',
          'AuditAction',
          'AuditEvent',
          'AuditSubject',
          'Entitlement',
          'EntitlementSource',
          'EntitlementStatus',
          'SolanaBillingChallenge',
          'SolanaPlanView',
          'StripeCustomer',
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
          'FxBackfillFutureCallFetchModel',
          'FxLatestSnapshot',
          'FxProvider',
          'FxQuoteView',
          'FxRate',
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
          'TaxLiabilityView',
          'TaxOpportunityView',
          'TaxProfileRecord',
          'TaxReportLineView',
          'TaxReportView',
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
          'AssetPrice',
          'HoldingPosition',
          'PriceQuality',
          'PriceSource',
          'SpamVerdict',
          'Wallet',
          'WalletHolding',
          'WalletNetworkState',
          'WalletSyncResult',
          'WalletTaxYearSummary',
          'WalletTransaction',
        ],
      );

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'account',
      dartName: 'Account',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'entityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'openbudget_core:AccountKind',
        ),
        _isp.ColumnDefinition(
          name: 'currencyCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'balanceSource',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'openbudget_core:AccountBalanceSource',
        ),
        _isp.ColumnDefinition(
          name: 'balanceMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'onBudget',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'institutionId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'plaidConnectionId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'plaidAccountId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'reportedBalanceMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'reportedBalanceAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'ledgerAccountId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'reconciledThroughDate',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'note',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'sortOrder',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'closedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'account_fk_0',
          columns: ['entityId'],
          referenceTable: 'entity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'account_fk_1',
          columns: ['institutionId'],
          referenceTable: 'institution',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.setNull,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'account_fk_2',
          columns: ['plaidConnectionId'],
          referenceTable: 'plaid_connection',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.setNull,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'account_fk_3',
          columns: ['ledgerAccountId'],
          referenceTable: 'ledger_account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'account_entity_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entityId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sortOrder',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'account_plaid_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'plaidConnectionId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'plaidAccountId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'account_ledger_account_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ledgerAccountId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'account_valuation',
      dartName: 'AccountValuation',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'accountId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'valuationDate',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'valueMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'source',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ValuationSource',
        ),
        _isp.ColumnDefinition(
          name: 'note',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'account_valuation_fk_0',
          columns: ['accountId'],
          referenceTable: 'account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'account_valuation_account_date_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'accountId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'valuationDate',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'agent_access_token',
      dartName: 'AgentAccessToken',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'tokenHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'tokenPrefix',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'canPropose',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'lastUsedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'revokedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'agent_access_token_fk_0',
          columns: ['userId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'agent_access_token_hash_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'tokenHash',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'agent_access_token_user_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'agent_conversation',
      dartName: 'AgentConversation',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'entityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'title',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'agent_conversation_fk_0',
          columns: ['userId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'agent_conversation_fk_1',
          columns: ['entityId'],
          referenceTable: 'entity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'agent_conversation_entity_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entityId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'updatedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'agent_conversation_user_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'agent_message',
      dartName: 'AgentMessage',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'conversationId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'role',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:AgentMessageRole',
        ),
        _isp.ColumnDefinition(
          name: 'content',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'toolCallsJson',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'toolCallId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'agent_message_fk_0',
          columns: ['conversationId'],
          referenceTable: 'agent_conversation',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'agent_message_conversation_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'conversationId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'agent_proposal',
      dartName: 'AgentProposal',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'entityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'conversationId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:AgentProposalKind',
        ),
        _isp.ColumnDefinition(
          name: 'payloadJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'summary',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:AgentProposalStatus',
          columnDefault: '\'pending\'',
        ),
        _isp.ColumnDefinition(
          name: 'rulesVersion',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'resolvedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'agent_proposal_fk_0',
          columns: ['userId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'agent_proposal_fk_1',
          columns: ['entityId'],
          referenceTable: 'entity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'agent_proposal_fk_2',
          columns: ['conversationId'],
          referenceTable: 'agent_conversation',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'agent_proposal_entity_status_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entityId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'status',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'agent_proposal_user_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'agent_provider_settings',
      dartName: 'AgentProviderSettings',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'baseUrl',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'model',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'encryptedApiKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'nonce',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'keyHint',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'agent_provider_settings_fk_0',
          columns: ['userId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'agent_provider_settings_user_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'agent_usage_record',
      dartName: 'AgentUsageRecord',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'conversationId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'provider',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:AgentProvider',
        ),
        _isp.ColumnDefinition(
          name: 'model',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'promptTokens',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'cachedTokens',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'completionTokens',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'costMicroUsd',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'agent_usage_record_fk_0',
          columns: ['userId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'agent_usage_record_fk_1',
          columns: ['conversationId'],
          referenceTable: 'agent_conversation',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'agent_usage_user_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'agent_usage_conversation_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'conversationId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'asset_price',
      dartName: 'AssetPrice',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'network',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'openbudget_core:WalletNetwork',
        ),
        _isp.ColumnDefinition(
          name: 'assetId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'symbol',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'currencyCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'unitPrice',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'source',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:PriceSource',
        ),
        _isp.ColumnDefinition(
          name: 'fetchedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'asset_price_network_asset_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'network',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'assetId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'asset_price_expires_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'expiresAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'audit_event',
      dartName: 'AuditEvent',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'entityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'actorId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'action',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:AuditAction',
        ),
        _isp.ColumnDefinition(
          name: 'subjectType',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:AuditSubject?',
        ),
        _isp.ColumnDefinition(
          name: 'subjectId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'payloadJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'{}\'',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'audit_event_fk_0',
          columns: ['entityId'],
          referenceTable: 'entity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'audit_event_entity_created_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entityId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'budget_template',
      dartName: 'BudgetTemplate',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'entityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'budget_template_fk_0',
          columns: ['entityId'],
          referenceTable: 'entity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'budget_template_entity_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entityId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'budget_template_line',
      dartName: 'BudgetTemplateLine',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'templateId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'envelopeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'allocatedMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'budget_template_line_fk_0',
          columns: ['templateId'],
          referenceTable: 'budget_template',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'budget_template_line_fk_1',
          columns: ['envelopeId'],
          referenceTable: 'envelope',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'budget_template_line_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'templateId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'envelopeId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'category',
      dartName: 'Category',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'entityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sortOrder',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'isHidden',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'category_fk_0',
          columns: ['entityId'],
          referenceTable: 'entity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'category_entity_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entityId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sortOrder',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'entitlement',
      dartName: 'Entitlement',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'source',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:EntitlementSource',
        ),
        _isp.ColumnDefinition(
          name: 'externalId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:EntitlementStatus',
        ),
        _isp.ColumnDefinition(
          name: 'currentPeriodStart',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'currentPeriodEnd',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'entitlement_fk_0',
          columns: ['userId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'entitlement_rail_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'source',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'externalId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'entitlement_user_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'entity',
      dartName: 'Entity',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'ownerId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'openbudget_core:EntityKind',
        ),
        _isp.ColumnDefinition(
          name: 'countryCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'baseCurrencyCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'timeZone',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'accountingMode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'openbudget_core:AccountingMode',
          columnDefault: '\'envelope\'',
        ),
        _isp.ColumnDefinition(
          name: 'fiscalYearEndMonth',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'fiscalYearEndDay',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'includeInNetWorth',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _isp.ColumnDefinition(
          name: 'linkedPersonalEntityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'sortOrder',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'archivedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'entity_fk_0',
          columns: ['ownerId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'entity_fk_1',
          columns: ['linkedPersonalEntityId'],
          referenceTable: 'entity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'entity_owner_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ownerId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sortOrder',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'entity_linked_personal_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'linkedPersonalEntityId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'envelope',
      dartName: 'Envelope',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'entityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'categoryId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sortOrder',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'note',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'taxCategoryCode',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'defaultLedgerAccountId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'isHidden',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'envelope_fk_0',
          columns: ['entityId'],
          referenceTable: 'entity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'envelope_fk_1',
          columns: ['categoryId'],
          referenceTable: 'category',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'envelope_fk_2',
          columns: ['defaultLedgerAccountId'],
          referenceTable: 'ledger_account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'envelope_entity_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entityId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'envelope_category_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'categoryId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sortOrder',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'envelope_goal',
      dartName: 'EnvelopeGoal',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'entityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'envelopeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:EnvelopeGoalKind',
        ),
        _isp.ColumnDefinition(
          name: 'amountMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'targetDate',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'envelope_goal_fk_0',
          columns: ['entityId'],
          referenceTable: 'entity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'envelope_goal_fk_1',
          columns: ['envelopeId'],
          referenceTable: 'envelope',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'envelope_goal_envelope_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'envelopeId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'fx_rate',
      dartName: 'FxRate',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'rateDate',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'currencyCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'rate',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'provider',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:FxProvider',
        ),
        _isp.ColumnDefinition(
          name: 'fetchedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'fx_rate_currency_date_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'currencyCode',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'rateDate',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'fx_rate_date_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'rateDate',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'institution',
      dartName: 'Institution',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'slug',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'website',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'plaidInstitutionId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'isDigitalBank',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'institution_slug_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'slug',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'institution_name_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'name',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'institution_location',
      dartName: 'InstitutionLocation',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'institutionId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'locationCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'isPopular',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'popularityRank',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'institution_location_fk_0',
          columns: ['institutionId'],
          referenceTable: 'institution',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'institution_location_institution_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'institutionId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'institution_location_code_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'locationCode',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'isPopular',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'popularityRank',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'institution_location_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'institutionId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'locationCode',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'journal',
      dartName: 'Journal',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'entityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'date',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'reference',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'\'',
        ),
        _isp.ColumnDefinition(
          name: 'narration',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'openbudget_core:JournalStatus',
          columnDefault: '\'draft\'',
        ),
        _isp.ColumnDefinition(
          name: 'source',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'openbudget_core:JournalSource',
          columnDefault: '\'manual\'',
        ),
        _isp.ColumnDefinition(
          name: 'sourceTransactionId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'sourceRevision',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'postedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'postedBy',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'reversalOfJournalId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'journal_fk_0',
          columns: ['entityId'],
          referenceTable: 'entity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'journal_fk_1',
          columns: ['reversalOfJournalId'],
          referenceTable: 'journal',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'journal_entity_date_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entityId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'date',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'journal_entity_status_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entityId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'status',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'journal_source_transaction_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sourceTransactionId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sourceRevision',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'journal_reversal_of_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'reversalOfJournalId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'journal_line',
      dartName: 'JournalLine',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'journalId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'ledgerAccountId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'description',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'debitMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'creditMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'currencyCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'baseDebitMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'baseCreditMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'fxRate',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'1\'',
        ),
        _isp.ColumnDefinition(
          name: 'fxRateDate',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'fxRateSource',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'openbudget_core:FxRateSource',
          columnDefault: '\'identity\'',
        ),
        _isp.ColumnDefinition(
          name: 'taxCode',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'journal_line_fk_0',
          columns: ['journalId'],
          referenceTable: 'journal',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'journal_line_fk_1',
          columns: ['ledgerAccountId'],
          referenceTable: 'ledger_account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'journal_line_journal_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'journalId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'journal_line_ledger_account_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ledgerAccountId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'ledger_account',
      dartName: 'LedgerAccount',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'entityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'code',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'type',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'openbudget_core:LedgerAccountType',
        ),
        _isp.ColumnDefinition(
          name: 'systemRole',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'openbudget_core:LedgerSystemRole?',
        ),
        _isp.ColumnDefinition(
          name: 'currencyCode',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'taxCategoryCode',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'archivedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'ledger_account_fk_0',
          columns: ['entityId'],
          referenceTable: 'entity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'ledger_account_entity_code_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entityId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'code',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'ledger_account_entity_role_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entityId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'systemRole',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'ledger_period_lock',
      dartName: 'LedgerPeriodLock',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'entityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'lockDate',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'setBy',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'setAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'ledger_period_lock_fk_0',
          columns: ['entityId'],
          referenceTable: 'entity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'ledger_period_lock_entity_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entityId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'monthly_allocation',
      dartName: 'MonthlyAllocation',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'entityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'envelopeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'month',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'allocatedMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'monthly_allocation_fk_0',
          columns: ['entityId'],
          referenceTable: 'entity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'monthly_allocation_fk_1',
          columns: ['envelopeId'],
          referenceTable: 'envelope',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'monthly_allocation_envelope_month_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'envelopeId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'month',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'monthly_allocation_entity_month_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entityId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'month',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'payee',
      dartName: 'Payee',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'entityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'payee_fk_0',
          columns: ['entityId'],
          referenceTable: 'entity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'payee_entity_name_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entityId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'name',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'plaid_connection',
      dartName: 'PlaidConnection',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'entityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'plaidItemId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'accessTokenCiphertext',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'accessTokenNonce',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'plaidInstitutionId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'institutionName',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'transactionsCursor',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'syncStatus',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:SyncStatus',
          columnDefault: '\'pending\'',
        ),
        _isp.ColumnDefinition(
          name: 'lastSyncedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'lastSyncError',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'plaid_connection_fk_0',
          columns: ['entityId'],
          referenceTable: 'entity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'plaid_connection_item_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'plaidItemId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'plaid_connection_entity_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entityId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'recurring_transaction',
      dartName: 'RecurringTransaction',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'entityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'accountId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'payeeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'envelopeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'description',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'memo',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'amountMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'frequency',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'openbudget_core:RecurrenceFrequency',
        ),
        _isp.ColumnDefinition(
          name: 'nextDate',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'endDate',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'isActive',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'recurring_transaction_fk_0',
          columns: ['entityId'],
          referenceTable: 'entity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'recurring_transaction_fk_1',
          columns: ['accountId'],
          referenceTable: 'account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'recurring_transaction_fk_2',
          columns: ['payeeId'],
          referenceTable: 'payee',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.setNull,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'recurring_transaction_fk_3',
          columns: ['envelopeId'],
          referenceTable: 'envelope',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'recurring_transaction_entity_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entityId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'isActive',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'recurring_transaction_due_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'isActive',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'nextDate',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'solana_billing_challenge',
      dartName: 'SolanaBillingChallenge',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'message',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'usedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'solana_billing_challenge_fk_0',
          columns: ['userId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'solana_billing_challenge_user_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'solana_billing_challenge_message_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'message',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'stripe_customer',
      dartName: 'StripeCustomer',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'customerId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'stripe_customer_fk_0',
          columns: ['userId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'stripe_customer_user_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'stripe_customer_customer_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'customerId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'tax_profile',
      dartName: 'TaxProfileRecord',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'entityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'profileJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'tax_profile_fk_0',
          columns: ['entityId'],
          referenceTable: 'entity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'tax_profile_entity_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entityId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'transaction',
      dartName: 'Transaction',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'entityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'accountId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'date',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'amountMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'baseAmountMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'fxRate',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'1\'',
        ),
        _isp.ColumnDefinition(
          name: 'fxRateDate',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'fxRateSource',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'openbudget_core:FxRateSource',
          columnDefault: '\'identity\'',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:TransactionKind',
          columnDefault: '\'standard\'',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:TransactionStatus',
          columnDefault: '\'uncleared\'',
        ),
        _isp.ColumnDefinition(
          name: 'flag',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:TransactionFlag?',
        ),
        _isp.ColumnDefinition(
          name: 'payeeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'description',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'\'',
        ),
        _isp.ColumnDefinition(
          name: 'memo',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'externalId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'recurringTransactionId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'transaction_fk_0',
          columns: ['entityId'],
          referenceTable: 'entity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'transaction_fk_1',
          columns: ['accountId'],
          referenceTable: 'account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'transaction_fk_2',
          columns: ['payeeId'],
          referenceTable: 'payee',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.setNull,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'transaction_fk_3',
          columns: ['recurringTransactionId'],
          referenceTable: 'recurring_transaction',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'transaction_entity_date_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entityId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'date',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'transaction_account_date_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'accountId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'date',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'transaction_payee_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'payeeId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'transaction_recurring_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recurringTransactionId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'transaction_account_external_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'accountId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'externalId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'transaction_line',
      dartName: 'TransactionLine',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'transactionId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'amountMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'baseAmountMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'envelopeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'ledgerAccountId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'taxCategoryCode',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'businessUsePercent',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'salesTaxMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'memo',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'sortOrder',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'transaction_line_fk_0',
          columns: ['transactionId'],
          referenceTable: 'transaction',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'transaction_line_fk_1',
          columns: ['envelopeId'],
          referenceTable: 'envelope',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'transaction_line_fk_2',
          columns: ['ledgerAccountId'],
          referenceTable: 'ledger_account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'transaction_line_transaction_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'transactionId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'transaction_line_envelope_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'envelopeId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'transaction_line_ledger_account_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ledgerAccountId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'transaction_rule',
      dartName: 'TransactionRule',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'entityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'payeeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'envelopeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'enabled',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'transaction_rule_fk_0',
          columns: ['entityId'],
          referenceTable: 'entity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'transaction_rule_fk_1',
          columns: ['payeeId'],
          referenceTable: 'payee',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'transaction_rule_fk_2',
          columns: ['envelopeId'],
          referenceTable: 'envelope',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'transaction_rule_entity_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entityId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'transaction_rule_payee_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'payeeId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'transfer',
      dartName: 'Transfer',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'fromTransactionId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'toTransactionId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'transfer_fk_0',
          columns: ['fromTransactionId'],
          referenceTable: 'transaction',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'transfer_fk_1',
          columns: ['toTransactionId'],
          referenceTable: 'transaction',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'transfer_from_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'fromTransactionId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'transfer_to_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'toTransactionId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'user_settings',
      dartName: 'UserSettings',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'reportingCurrencyCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'user_settings_fk_0',
          columns: ['userId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'user_settings_user_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'wallet',
      dartName: 'Wallet',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'entityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'accountId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'network',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'openbudget_core:WalletNetwork',
        ),
        _isp.ColumnDefinition(
          name: 'address',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'scanNetworks',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'List<openbudget_core:WalletNetwork>?',
        ),
        _isp.ColumnDefinition(
          name: 'descriptorCiphertext',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'descriptorNonce',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'label',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'lastSignature',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'syncStatus',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:SyncStatus',
          columnDefault: '\'pending\'',
        ),
        _isp.ColumnDefinition(
          name: 'lastSyncedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'lastSyncError',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'wallet_fk_0',
          columns: ['entityId'],
          referenceTable: 'entity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'wallet_fk_1',
          columns: ['accountId'],
          referenceTable: 'account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'wallet_account_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'accountId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'wallet_entity_network_address_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entityId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'network',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'address',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'wallet_address_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'address',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'wallet_holding',
      dartName: 'WalletHolding',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'walletId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'network',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'openbudget_core:WalletNetwork',
        ),
        _isp.ColumnDefinition(
          name: 'assetId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'position',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:HoldingPosition',
          columnDefault: '\'available\'',
        ),
        _isp.ColumnDefinition(
          name: 'symbol',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'tokenProgram',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'decimals',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'quantityRaw',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'BigInt',
        ),
        _isp.ColumnDefinition(
          name: 'isNft',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'spamVerdict',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:SpamVerdict',
          columnDefault: '\'clean\'',
        ),
        _isp.ColumnDefinition(
          name: 'priceCurrencyCode',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'unitPrice',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'valueMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'priceSource',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:PriceSource?',
        ),
        _isp.ColumnDefinition(
          name: 'priceQuality',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:PriceQuality',
          columnDefault: '\'unpriced\'',
        ),
        _isp.ColumnDefinition(
          name: 'priceConfidence',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:Confidence?',
        ),
        _isp.ColumnDefinition(
          name: 'priceAsOf',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'costBasisMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'realizedPnlMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'pnlAsOf',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'metadataJson',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'wallet_holding_fk_0',
          columns: ['walletId'],
          referenceTable: 'wallet',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'wallet_holding_wallet_asset_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'walletId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'network',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'assetId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'position',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'wallet_holding_asset_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'network',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'assetId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'wallet_network_state',
      dartName: 'WalletNetworkState',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'walletId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'network',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'openbudget_core:WalletNetwork',
        ),
        _isp.ColumnDefinition(
          name: 'lastReadAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'lastError',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'historyCursor',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'wallet_network_state_fk_0',
          columns: ['walletId'],
          referenceTable: 'wallet',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'wallet_network_state_wallet_network_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'walletId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'network',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'wallet_transaction',
      dartName: 'WalletTransaction',
      schema: 'public',
      module: 'openbudget',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'walletId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'network',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'openbudget_core:WalletNetwork',
        ),
        _isp.ColumnDefinition(
          name: 'signature',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'slot',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'occurredAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'description',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'txType',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'source',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'interpretationConfidence',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:Confidence?',
        ),
        _isp.ColumnDefinition(
          name: 'programsJson',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'nativeTransfersJson',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'tokenTransfersJson',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'pnlCurrencyCode',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'costBasisMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'proceedsMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'realizedPnlMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'category',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'tags',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'List<String>?',
        ),
        _isp.ColumnDefinition(
          name: 'memo',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'rawJson',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'wallet_transaction_fk_0',
          columns: ['walletId'],
          referenceTable: 'wallet',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'wallet_transaction_wallet_signature_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'walletId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'network',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'signature',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'wallet_transaction_wallet_time_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'walletId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'occurredAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._ifz8weqz.Protocol() is _is.DatabaseSerializationManager
        ? (_ifz8weqz.Protocol() as _is.DatabaseSerializationManager)
              .getTargetTableDefinitions()
        : [],
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) =>
      _is.ProtocolDeserialization.readClassName(data);

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    final rawDataClassName = _is.ProtocolDeserialization.readClassName(data);
    final dataClassName = rawDataClassName;
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
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
    if (t == _ipqgbdtd.AgentProviderSettings) {
      return _ipqgbdtd.AgentProviderSettings.fromJson(data) as T;
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
    if (t == _i8betnj7.AgentAccessToken) {
      return _i8betnj7.AgentAccessToken.fromJson(data) as T;
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
    if (t == _iw7l0hzr.SolanaBillingChallenge) {
      return _iw7l0hzr.SolanaBillingChallenge.fromJson(data) as T;
    }
    if (t == _iwxkomal.SolanaPlanView) {
      return _iwxkomal.SolanaPlanView.fromJson(data) as T;
    }
    if (t == _in1nt6tx.StripeCustomer) {
      return _in1nt6tx.StripeCustomer.fromJson(data) as T;
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
    if (t == _iuflqeka.FxBackfillFutureCallFetchModel) {
      return _iuflqeka.FxBackfillFutureCallFetchModel.fromJson(data) as T;
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
    if (t == _i46rvf1t.FxRate) {
      return _i46rvf1t.FxRate.fromJson(data) as T;
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
    if (t == _iw6q2afx.AssetPrice) {
      return _iw6q2afx.AssetPrice.fromJson(data) as T;
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
    if (t == _ipdq2p58.WalletSyncResult) {
      return _ipdq2p58.WalletSyncResult.fromJson(data) as T;
    }
    if (t == _ivsmsmw6.WalletTaxYearSummary) {
      return _ivsmsmw6.WalletTaxYearSummary.fromJson(data) as T;
    }
    if (t == _i6m1jx15.WalletTransaction) {
      return _i6m1jx15.WalletTransaction.fromJson(data) as T;
    }
    if (t == _is.getType<_iz2jf14v.Account?>()) {
      return (data != null ? _iz2jf14v.Account.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i53yl4yp.AccountBalancesView?>()) {
      return (data != null
              ? _i53yl4yp.AccountBalancesView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i87oqvv1.AccountValuation?>()) {
      return (data != null ? _i87oqvv1.AccountValuation.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ig9cy6ku.ValuationSource?>()) {
      return (data != null ? _ig9cy6ku.ValuationSource.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_isfmgqgu.AgentConversation?>()) {
      return (data != null ? _isfmgqgu.AgentConversation.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i769eo9u.AgentEvent?>()) {
      return (data != null ? _i769eo9u.AgentEvent.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iyhb15ax.AgentEventKind?>()) {
      return (data != null ? _iyhb15ax.AgentEventKind.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_inwxyid7.AgentMessage?>()) {
      return (data != null ? _inwxyid7.AgentMessage.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iy2njbiw.AgentMessageRole?>()) {
      return (data != null ? _iy2njbiw.AgentMessageRole.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iqh65hzq.AgentProposal?>()) {
      return (data != null ? _iqh65hzq.AgentProposal.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_idxyy01n.AgentProposalKind?>()) {
      return (data != null ? _idxyy01n.AgentProposalKind.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iksk16ej.AgentProposalStatus?>()) {
      return (data != null
              ? _iksk16ej.AgentProposalStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ic667156.AgentProvider?>()) {
      return (data != null ? _ic667156.AgentProvider.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ipqgbdtd.AgentProviderSettings?>()) {
      return (data != null
              ? _ipqgbdtd.AgentProviderSettings.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i0760q1h.AgentProviderSettingsView?>()) {
      return (data != null
              ? _i0760q1h.AgentProviderSettingsView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_igo4k2bu.AgentUsageRecord?>()) {
      return (data != null ? _igo4k2bu.AgentUsageRecord.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ipqjijih.AgentUsageView?>()) {
      return (data != null ? _ipqjijih.AgentUsageView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i8betnj7.AgentAccessToken?>()) {
      return (data != null ? _i8betnj7.AgentAccessToken.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iis6jewo.AgentAccessTokenCreated?>()) {
      return (data != null
              ? _iis6jewo.AgentAccessTokenCreated.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i4mcrc97.AgentAccessTokenView?>()) {
      return (data != null
              ? _i4mcrc97.AgentAccessTokenView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iqje9mi5.AuditAction?>()) {
      return (data != null ? _iqje9mi5.AuditAction.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ijhj7cd7.AuditEvent?>()) {
      return (data != null ? _ijhj7cd7.AuditEvent.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i2sn5a56.AuditSubject?>()) {
      return (data != null ? _i2sn5a56.AuditSubject.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iq2w1sa5.Entitlement?>()) {
      return (data != null ? _iq2w1sa5.Entitlement.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ipnf4x0i.EntitlementSource?>()) {
      return (data != null ? _ipnf4x0i.EntitlementSource.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_imqwzx9j.EntitlementStatus?>()) {
      return (data != null ? _imqwzx9j.EntitlementStatus.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iw7l0hzr.SolanaBillingChallenge?>()) {
      return (data != null
              ? _iw7l0hzr.SolanaBillingChallenge.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iwxkomal.SolanaPlanView?>()) {
      return (data != null ? _iwxkomal.SolanaPlanView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_in1nt6tx.StripeCustomer?>()) {
      return (data != null ? _in1nt6tx.StripeCustomer.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iouaddet.AllocationInput?>()) {
      return (data != null ? _iouaddet.AllocationInput.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ixyov90t.BudgetMonthSummary?>()) {
      return (data != null ? _ixyov90t.BudgetMonthSummary.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ihanl5km.BudgetMonthView?>()) {
      return (data != null ? _ihanl5km.BudgetMonthView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ii8h2sft.EnvelopeMonthView?>()) {
      return (data != null ? _ii8h2sft.EnvelopeMonthView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i01fne9j.BudgetTemplate?>()) {
      return (data != null ? _i01fne9j.BudgetTemplate.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iagnrffn.BudgetTemplateLine?>()) {
      return (data != null ? _iagnrffn.BudgetTemplateLine.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iwxpkdmg.Category?>()) {
      return (data != null ? _iwxpkdmg.Category.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i4zfq652.Confidence?>()) {
      return (data != null ? _i4zfq652.Confidence.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iynfhhr3.SyncStatus?>()) {
      return (data != null ? _iynfhhr3.SyncStatus.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i03vgs6n.ChangeScope?>()) {
      return (data != null ? _i03vgs6n.ChangeScope.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iamyw1yn.Entity?>()) {
      return (data != null ? _iamyw1yn.Entity.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_is12mxpv.EntityChangedEvent?>()) {
      return (data != null ? _is12mxpv.EntityChangedEvent.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ihqn2h4c.EntitySummaryView?>()) {
      return (data != null ? _ihqn2h4c.EntitySummaryView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ifl4yivq.EnvelopeGoal?>()) {
      return (data != null ? _ifl4yivq.EnvelopeGoal.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i61aeoqs.EnvelopeGoalKind?>()) {
      return (data != null ? _i61aeoqs.EnvelopeGoalKind.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ikt21dfw.Envelope?>()) {
      return (data != null ? _ikt21dfw.Envelope.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iozei2bz.AgentAllowanceExhaustedException?>()) {
      return (data != null
              ? _iozei2bz.AgentAllowanceExhaustedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iurccglg.AgentProviderException?>()) {
      return (data != null
              ? _iurccglg.AgentProviderException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i6p28blo.AgentProviderUnavailableException?>()) {
      return (data != null
              ? _i6p28blo.AgentProviderUnavailableException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_io2kod1y.AuthenticationRequiredException?>()) {
      return (data != null
              ? _io2kod1y.AuthenticationRequiredException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i9zkhl6f.BillingProviderException?>()) {
      return (data != null
              ? _i9zkhl6f.BillingProviderException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i5kq7itn.BillingRailUnavailableException?>()) {
      return (data != null
              ? _i5kq7itn.BillingRailUnavailableException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ik3lny6q.EntitlementRequiredException?>()) {
      return (data != null
              ? _ik3lny6q.EntitlementRequiredException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iha6yc5u.ForbiddenException?>()) {
      return (data != null ? _iha6yc5u.ForbiddenException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_if5umnl3.FxRateUnavailableException?>()) {
      return (data != null
              ? _if5umnl3.FxRateUnavailableException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_izob2ctl.NotFoundException?>()) {
      return (data != null ? _izob2ctl.NotFoundException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i4yu9vcq.TaxRulesUnavailableException?>()) {
      return (data != null
              ? _i4yu9vcq.TaxRulesUnavailableException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_igpdbyom.ValidationException?>()) {
      return (data != null
              ? _igpdbyom.ValidationException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iuflqeka.FxBackfillFutureCallFetchModel?>()) {
      return (data != null
              ? _iuflqeka.FxBackfillFutureCallFetchModel.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i8cxakqz.FxLatestSnapshot?>()) {
      return (data != null ? _i8cxakqz.FxLatestSnapshot.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ifsg8hc8.FxProvider?>()) {
      return (data != null ? _ifsg8hc8.FxProvider.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i8bj7347.FxQuoteView?>()) {
      return (data != null ? _i8bj7347.FxQuoteView.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i46rvf1t.FxRate?>()) {
      return (data != null ? _i46rvf1t.FxRate.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i15udi7x.FxRateQuote?>()) {
      return (data != null ? _i15udi7x.FxRateQuote.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ikgmcjq7.Institution?>()) {
      return (data != null ? _ikgmcjq7.Institution.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iclizrec.InstitutionLocation?>()) {
      return (data != null
              ? _iclizrec.InstitutionLocation.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iqqjzj2w.Journal?>()) {
      return (data != null ? _iqqjzj2w.Journal.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i6l0fo54.JournalLine?>()) {
      return (data != null ? _i6l0fo54.JournalLine.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_id7zp91q.JournalLineInput?>()) {
      return (data != null ? _id7zp91q.JournalLineInput.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ivazbnnp.LedgerAccount?>()) {
      return (data != null ? _ivazbnnp.LedgerAccount.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i7t4btg4.LedgerPeriodLock?>()) {
      return (data != null ? _i7t4btg4.LedgerPeriodLock.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i5gsx3ds.TrialBalanceRowView?>()) {
      return (data != null
              ? _i5gsx3ds.TrialBalanceRowView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i7q128aw.TrialBalanceView?>()) {
      return (data != null ? _i7q128aw.TrialBalanceView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_igdgld5u.MonthlyAllocation?>()) {
      return (data != null ? _igdgld5u.MonthlyAllocation.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ignezpci.Payee?>()) {
      return (data != null ? _ignezpci.Payee.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i1vmvtrm.PlaidConnection?>()) {
      return (data != null ? _i1vmvtrm.PlaidConnection.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i9is7zb8.RecurringTransaction?>()) {
      return (data != null
              ? _i9is7zb8.RecurringTransaction.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ieg4kkwo.NetWorthAccountRow?>()) {
      return (data != null ? _ieg4kkwo.NetWorthAccountRow.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_if6ke1e2.NetWorthCurrencyRow?>()) {
      return (data != null
              ? _if6ke1e2.NetWorthCurrencyRow.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i2p47r1m.NetWorthEntityRow?>()) {
      return (data != null ? _i2p47r1m.NetWorthEntityRow.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iiyi1fdi.NetWorthGranularity?>()) {
      return (data != null
              ? _iiyi1fdi.NetWorthGranularity.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_izpykydm.NetWorthHistoryView?>()) {
      return (data != null
              ? _izpykydm.NetWorthHistoryView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ihwosu5p.NetWorthPoint?>()) {
      return (data != null ? _ihwosu5p.NetWorthPoint.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_idk5va87.NetWorthView?>()) {
      return (data != null ? _idk5va87.NetWorthView.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ijpgwwdu.ReportGrouping?>()) {
      return (data != null ? _ijpgwwdu.ReportGrouping.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ikppksh7.SpendingRow?>()) {
      return (data != null ? _ikppksh7.SpendingRow.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i99f9doz.UserSettings?>()) {
      return (data != null ? _i99f9doz.UserSettings.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ic4zfx3b.TaxBandSliceView?>()) {
      return (data != null ? _ic4zfx3b.TaxBandSliceView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iv5oayw3.TaxCategoryView?>()) {
      return (data != null ? _iv5oayw3.TaxCategoryView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ivss6b81.TaxLiabilityView?>()) {
      return (data != null ? _ivss6b81.TaxLiabilityView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iuft4v7q.TaxOpportunityView?>()) {
      return (data != null ? _iuft4v7q.TaxOpportunityView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i20z9jax.TaxProfileRecord?>()) {
      return (data != null ? _i20z9jax.TaxProfileRecord.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i6llsezf.TaxReportLineView?>()) {
      return (data != null ? _i6llsezf.TaxReportLineView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_inb54q20.TaxReportView?>()) {
      return (data != null ? _inb54q20.TaxReportView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ilbx4erh.TaxSummaryCategoryTotalView?>()) {
      return (data != null
              ? _ilbx4erh.TaxSummaryCategoryTotalView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iok5qj2e.TaxSummaryFxNoteView?>()) {
      return (data != null
              ? _iok5qj2e.TaxSummaryFxNoteView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_it9yyajv.TaxSummarySalesTaxQuarterView?>()) {
      return (data != null
              ? _it9yyajv.TaxSummarySalesTaxQuarterView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iabhnw50.TaxSummarySalesTaxRateView?>()) {
      return (data != null
              ? _iabhnw50.TaxSummarySalesTaxRateView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i5jsilqj.TaxSummaryView?>()) {
      return (data != null ? _i5jsilqj.TaxSummaryView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ij9k0z9z.TaxSummaryWalletView?>()) {
      return (data != null
              ? _ij9k0z9z.TaxSummaryWalletView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i6dj6ji0.TransactionRule?>()) {
      return (data != null ? _i6dj6ji0.TransactionRule.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ibzcfs2k.ImportResult?>()) {
      return (data != null ? _ibzcfs2k.ImportResult.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_isp6bezg.ImportRow?>()) {
      return (data != null ? _isp6bezg.ImportRow.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_igokbqfh.ReconcileResult?>()) {
      return (data != null ? _igokbqfh.ReconcileResult.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iqhl4hru.Transaction?>()) {
      return (data != null ? _iqhl4hru.Transaction.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i4fvctax.TransactionFlag?>()) {
      return (data != null ? _i4fvctax.TransactionFlag.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ipd1rac6.TransactionInput?>()) {
      return (data != null ? _ipd1rac6.TransactionInput.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ioneruif.TransactionKind?>()) {
      return (data != null ? _ioneruif.TransactionKind.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ipio7ws3.TransactionLine?>()) {
      return (data != null ? _ipio7ws3.TransactionLine.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_imsv7m6w.TransactionLineInput?>()) {
      return (data != null
              ? _imsv7m6w.TransactionLineInput.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i7f3q91r.TransactionPage?>()) {
      return (data != null ? _i7f3q91r.TransactionPage.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ioinkgwn.TransactionQuery?>()) {
      return (data != null ? _ioinkgwn.TransactionQuery.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i3rynkdl.TransactionStatus?>()) {
      return (data != null ? _i3rynkdl.TransactionStatus.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ilixdhed.TransactionView?>()) {
      return (data != null ? _ilixdhed.TransactionView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ign516jt.Transfer?>()) {
      return (data != null ? _ign516jt.Transfer.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iah0rmrk.TransferInput?>()) {
      return (data != null ? _iah0rmrk.TransferInput.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i3n9n3ej.TransferPeerView?>()) {
      return (data != null ? _i3n9n3ej.TransferPeerView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iw6q2afx.AssetPrice?>()) {
      return (data != null ? _iw6q2afx.AssetPrice.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iq0sbxsc.HoldingPosition?>()) {
      return (data != null ? _iq0sbxsc.HoldingPosition.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i6j30n20.PriceQuality?>()) {
      return (data != null ? _i6j30n20.PriceQuality.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iu1a5mev.PriceSource?>()) {
      return (data != null ? _iu1a5mev.PriceSource.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i4uehszw.SpamVerdict?>()) {
      return (data != null ? _i4uehszw.SpamVerdict.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ilu5i0rn.Wallet?>()) {
      return (data != null ? _ilu5i0rn.Wallet.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iqqppnaa.WalletHolding?>()) {
      return (data != null ? _iqqppnaa.WalletHolding.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i73xhbar.WalletNetworkState?>()) {
      return (data != null ? _i73xhbar.WalletNetworkState.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ipdq2p58.WalletSyncResult?>()) {
      return (data != null ? _ipdq2p58.WalletSyncResult.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ivsmsmw6.WalletTaxYearSummary?>()) {
      return (data != null
              ? _ivsmsmw6.WalletTaxYearSummary.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i6m1jx15.WalletTransaction?>()) {
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
    if (t == _is.getType<List<_ifz8weqz.WalletNetwork>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_ifz8weqz.WalletNetwork>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == _is.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i3fh9aci.Account>) {
      return (data as List)
              .map((e) => deserialize<_i3fh9aci.Account>(e))
              .toList()
          as T;
    }
    if (t == List<_is.UuidValue>) {
      return (data as List).map((e) => deserialize<_is.UuidValue>(e)).toList()
          as T;
    }
    if (t == List<_itqzh2rv.AccountValuation>) {
      return (data as List)
              .map((e) => deserialize<_itqzh2rv.AccountValuation>(e))
              .toList()
          as T;
    }
    if (t == List<_ihq3j0fx.AgentConversation>) {
      return (data as List)
              .map((e) => deserialize<_ihq3j0fx.AgentConversation>(e))
              .toList()
          as T;
    }
    if (t == List<_ixbh63dx.AgentMessage>) {
      return (data as List)
              .map((e) => deserialize<_ixbh63dx.AgentMessage>(e))
              .toList()
          as T;
    }
    if (t == List<_iqa5uoc4.AgentProposal>) {
      return (data as List)
              .map((e) => deserialize<_iqa5uoc4.AgentProposal>(e))
              .toList()
          as T;
    }
    if (t == List<_i8fy0qox.AgentAccessTokenView>) {
      return (data as List)
              .map((e) => deserialize<_i8fy0qox.AgentAccessTokenView>(e))
              .toList()
          as T;
    }
    if (t == List<_inwbkajl.AllocationInput>) {
      return (data as List)
              .map((e) => deserialize<_inwbkajl.AllocationInput>(e))
              .toList()
          as T;
    }
    if (t == List<_ihbdj8p6.BudgetTemplate>) {
      return (data as List)
              .map((e) => deserialize<_ihbdj8p6.BudgetTemplate>(e))
              .toList()
          as T;
    }
    if (t == List<_iz4ekkcc.BudgetTemplateLine>) {
      return (data as List)
              .map((e) => deserialize<_iz4ekkcc.BudgetTemplateLine>(e))
              .toList()
          as T;
    }
    if (t == List<_iwlneq7u.Category>) {
      return (data as List)
              .map((e) => deserialize<_iwlneq7u.Category>(e))
              .toList()
          as T;
    }
    if (t == List<_if2ry2np.Entity>) {
      return (data as List)
              .map((e) => deserialize<_if2ry2np.Entity>(e))
              .toList()
          as T;
    }
    if (t == List<_im3neacv.EntitySummaryView>) {
      return (data as List)
              .map((e) => deserialize<_im3neacv.EntitySummaryView>(e))
              .toList()
          as T;
    }
    if (t == List<_iuyjld9f.EnvelopeGoal>) {
      return (data as List)
              .map((e) => deserialize<_iuyjld9f.EnvelopeGoal>(e))
              .toList()
          as T;
    }
    if (t == List<_igwnqatb.Envelope>) {
      return (data as List)
              .map((e) => deserialize<_igwnqatb.Envelope>(e))
              .toList()
          as T;
    }
    if (t == List<_izagyfe8.Institution>) {
      return (data as List)
              .map((e) => deserialize<_izagyfe8.Institution>(e))
              .toList()
          as T;
    }
    if (t == List<_iab1c098.LedgerAccount>) {
      return (data as List)
              .map((e) => deserialize<_iab1c098.LedgerAccount>(e))
              .toList()
          as T;
    }
    if (t == List<_in0sxdux.JournalLineInput>) {
      return (data as List)
              .map((e) => deserialize<_in0sxdux.JournalLineInput>(e))
              .toList()
          as T;
    }
    if (t == List<_ixvlhhyv.Journal>) {
      return (data as List)
              .map((e) => deserialize<_ixvlhhyv.Journal>(e))
              .toList()
          as T;
    }
    if (t == List<_icjh3b69.JournalLine>) {
      return (data as List)
              .map((e) => deserialize<_icjh3b69.JournalLine>(e))
              .toList()
          as T;
    }
    if (t == List<_ictk02ka.AuditEvent>) {
      return (data as List)
              .map((e) => deserialize<_ictk02ka.AuditEvent>(e))
              .toList()
          as T;
    }
    if (t == List<_i2xhh3nq.Payee>) {
      return (data as List).map((e) => deserialize<_i2xhh3nq.Payee>(e)).toList()
          as T;
    }
    if (t == List<_iyqk0wcc.PlaidConnection>) {
      return (data as List)
              .map((e) => deserialize<_iyqk0wcc.PlaidConnection>(e))
              .toList()
          as T;
    }
    if (t == List<_i6lbncsb.RecurringTransaction>) {
      return (data as List)
              .map((e) => deserialize<_i6lbncsb.RecurringTransaction>(e))
              .toList()
          as T;
    }
    if (t == _is.getType<List<_is.UuidValue>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_is.UuidValue>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_ijvd4zl8.SpendingRow>) {
      return (data as List)
              .map((e) => deserialize<_ijvd4zl8.SpendingRow>(e))
              .toList()
          as T;
    }
    if (t == List<_ipz3w5am.BudgetMonthSummary>) {
      return (data as List)
              .map((e) => deserialize<_ipz3w5am.BudgetMonthSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_i687t6y5.TaxCategoryView>) {
      return (data as List)
              .map((e) => deserialize<_i687t6y5.TaxCategoryView>(e))
              .toList()
          as T;
    }
    if (t == List<_i4wqhpw2.TransactionRule>) {
      return (data as List)
              .map((e) => deserialize<_i4wqhpw2.TransactionRule>(e))
              .toList()
          as T;
    }
    if (t == List<_iw07wj0h.TransactionView>) {
      return (data as List)
              .map((e) => deserialize<_iw07wj0h.TransactionView>(e))
              .toList()
          as T;
    }
    if (t == List<_iyod81ld.ImportRow>) {
      return (data as List)
              .map((e) => deserialize<_iyod81ld.ImportRow>(e))
              .toList()
          as T;
    }
    if (t == List<_igcr1vxe.Wallet>) {
      return (data as List)
              .map((e) => deserialize<_igcr1vxe.Wallet>(e))
              .toList()
          as T;
    }
    if (t == List<_icu5m6lt.WalletHolding>) {
      return (data as List)
              .map((e) => deserialize<_icu5m6lt.WalletHolding>(e))
              .toList()
          as T;
    }
    if (t == List<_imzwq91q.WalletTransaction>) {
      return (data as List)
              .map((e) => deserialize<_imzwq91q.WalletTransaction>(e))
              .toList()
          as T;
    }
    if (t == List<_ilgsya0a.WalletTaxYearSummary>) {
      return (data as List)
              .map((e) => deserialize<_ilgsya0a.WalletTaxYearSummary>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _is.getType<List<String>?>()) {
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
      } on _is.DeserializationTypeNotFoundException catch (_) {}
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
      _ipqgbdtd.AgentProviderSettings => 'AgentProviderSettings',
      _i0760q1h.AgentProviderSettingsView => 'AgentProviderSettingsView',
      _igo4k2bu.AgentUsageRecord => 'AgentUsageRecord',
      _ipqjijih.AgentUsageView => 'AgentUsageView',
      _i8betnj7.AgentAccessToken => 'AgentAccessToken',
      _iis6jewo.AgentAccessTokenCreated => 'AgentAccessTokenCreated',
      _i4mcrc97.AgentAccessTokenView => 'AgentAccessTokenView',
      _iqje9mi5.AuditAction => 'AuditAction',
      _ijhj7cd7.AuditEvent => 'AuditEvent',
      _i2sn5a56.AuditSubject => 'AuditSubject',
      _iq2w1sa5.Entitlement => 'Entitlement',
      _ipnf4x0i.EntitlementSource => 'EntitlementSource',
      _imqwzx9j.EntitlementStatus => 'EntitlementStatus',
      _iw7l0hzr.SolanaBillingChallenge => 'SolanaBillingChallenge',
      _iwxkomal.SolanaPlanView => 'SolanaPlanView',
      _in1nt6tx.StripeCustomer => 'StripeCustomer',
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
      _iuflqeka.FxBackfillFutureCallFetchModel =>
        'FxBackfillFutureCallFetchModel',
      _i8cxakqz.FxLatestSnapshot => 'FxLatestSnapshot',
      _ifsg8hc8.FxProvider => 'FxProvider',
      _i8bj7347.FxQuoteView => 'FxQuoteView',
      _i46rvf1t.FxRate => 'FxRate',
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
      _ivss6b81.TaxLiabilityView => 'TaxLiabilityView',
      _iuft4v7q.TaxOpportunityView => 'TaxOpportunityView',
      _i20z9jax.TaxProfileRecord => 'TaxProfileRecord',
      _i6llsezf.TaxReportLineView => 'TaxReportLineView',
      _inb54q20.TaxReportView => 'TaxReportView',
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
      _iw6q2afx.AssetPrice => 'AssetPrice',
      _iq0sbxsc.HoldingPosition => 'HoldingPosition',
      _i6j30n20.PriceQuality => 'PriceQuality',
      _iu1a5mev.PriceSource => 'PriceSource',
      _i4uehszw.SpamVerdict => 'SpamVerdict',
      _ilu5i0rn.Wallet => 'Wallet',
      _iqqppnaa.WalletHolding => 'WalletHolding',
      _i73xhbar.WalletNetworkState => 'WalletNetworkState',
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
      case _ipqgbdtd.AgentProviderSettings():
        return 'AgentProviderSettings';
      case _i0760q1h.AgentProviderSettingsView():
        return 'AgentProviderSettingsView';
      case _igo4k2bu.AgentUsageRecord():
        return 'AgentUsageRecord';
      case _ipqjijih.AgentUsageView():
        return 'AgentUsageView';
      case _i8betnj7.AgentAccessToken():
        return 'AgentAccessToken';
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
      case _iw7l0hzr.SolanaBillingChallenge():
        return 'SolanaBillingChallenge';
      case _iwxkomal.SolanaPlanView():
        return 'SolanaPlanView';
      case _in1nt6tx.StripeCustomer():
        return 'StripeCustomer';
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
      case _iuflqeka.FxBackfillFutureCallFetchModel():
        return 'FxBackfillFutureCallFetchModel';
      case _i8cxakqz.FxLatestSnapshot():
        return 'FxLatestSnapshot';
      case _ifsg8hc8.FxProvider():
        return 'FxProvider';
      case _i8bj7347.FxQuoteView():
        return 'FxQuoteView';
      case _i46rvf1t.FxRate():
        return 'FxRate';
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
      case _iw6q2afx.AssetPrice():
        return 'AssetPrice';
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
      case _ipdq2p58.WalletSyncResult():
        return 'WalletSyncResult';
      case _ivsmsmw6.WalletTaxYearSummary():
        return 'WalletTaxYearSummary';
      case _i6m1jx15.WalletTransaction():
        return 'WalletTransaction';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _ifz8weqz.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'openbudget_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
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
    if (dataClassName == 'AgentProviderSettings') {
      return deserialize<_ipqgbdtd.AgentProviderSettings>(data['data']);
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
    if (dataClassName == 'AgentAccessToken') {
      return deserialize<_i8betnj7.AgentAccessToken>(data['data']);
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
    if (dataClassName == 'SolanaBillingChallenge') {
      return deserialize<_iw7l0hzr.SolanaBillingChallenge>(data['data']);
    }
    if (dataClassName == 'SolanaPlanView') {
      return deserialize<_iwxkomal.SolanaPlanView>(data['data']);
    }
    if (dataClassName == 'StripeCustomer') {
      return deserialize<_in1nt6tx.StripeCustomer>(data['data']);
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
    if (dataClassName == 'FxBackfillFutureCallFetchModel') {
      return deserialize<_iuflqeka.FxBackfillFutureCallFetchModel>(
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
    if (dataClassName == 'FxRate') {
      return deserialize<_i46rvf1t.FxRate>(data['data']);
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
    if (dataClassName == 'AssetPrice') {
      return deserialize<_iw6q2afx.AssetPrice>(data['data']);
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
      return _iais.Protocol().deserializeByClassName({
        ...data,
        'className': dataClassName.substring(19),
      });
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      return _iacs.Protocol().deserializeByClassName({
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
    if (dataClassName.startsWith('serverpod.')) {
      return _isp.Protocol().deserializeByClassName({
        ...data,
        'className': dataClassName.substring(10),
      });
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('openbudget', this);
    _iacs.Protocol().registerHostProtocol('openbudget', this);
    _ifz8weqz.Protocol().registerHostProtocol('openbudget', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var protocol = _ifz8weqz.Protocol();
      var table = protocol is _is.DatabaseSerializationManager
          ? (protocol as _is.DatabaseSerializationManager).getTableForType(t)
          : null;
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _iz2jf14v.Account:
        return _iz2jf14v.Account.t;
      case _i87oqvv1.AccountValuation:
        return _i87oqvv1.AccountValuation.t;
      case _isfmgqgu.AgentConversation:
        return _isfmgqgu.AgentConversation.t;
      case _inwxyid7.AgentMessage:
        return _inwxyid7.AgentMessage.t;
      case _iqh65hzq.AgentProposal:
        return _iqh65hzq.AgentProposal.t;
      case _ipqgbdtd.AgentProviderSettings:
        return _ipqgbdtd.AgentProviderSettings.t;
      case _igo4k2bu.AgentUsageRecord:
        return _igo4k2bu.AgentUsageRecord.t;
      case _i8betnj7.AgentAccessToken:
        return _i8betnj7.AgentAccessToken.t;
      case _ijhj7cd7.AuditEvent:
        return _ijhj7cd7.AuditEvent.t;
      case _iq2w1sa5.Entitlement:
        return _iq2w1sa5.Entitlement.t;
      case _iw7l0hzr.SolanaBillingChallenge:
        return _iw7l0hzr.SolanaBillingChallenge.t;
      case _in1nt6tx.StripeCustomer:
        return _in1nt6tx.StripeCustomer.t;
      case _i01fne9j.BudgetTemplate:
        return _i01fne9j.BudgetTemplate.t;
      case _iagnrffn.BudgetTemplateLine:
        return _iagnrffn.BudgetTemplateLine.t;
      case _iwxpkdmg.Category:
        return _iwxpkdmg.Category.t;
      case _iamyw1yn.Entity:
        return _iamyw1yn.Entity.t;
      case _ifl4yivq.EnvelopeGoal:
        return _ifl4yivq.EnvelopeGoal.t;
      case _ikt21dfw.Envelope:
        return _ikt21dfw.Envelope.t;
      case _i46rvf1t.FxRate:
        return _i46rvf1t.FxRate.t;
      case _ikgmcjq7.Institution:
        return _ikgmcjq7.Institution.t;
      case _iclizrec.InstitutionLocation:
        return _iclizrec.InstitutionLocation.t;
      case _iqqjzj2w.Journal:
        return _iqqjzj2w.Journal.t;
      case _i6l0fo54.JournalLine:
        return _i6l0fo54.JournalLine.t;
      case _ivazbnnp.LedgerAccount:
        return _ivazbnnp.LedgerAccount.t;
      case _i7t4btg4.LedgerPeriodLock:
        return _i7t4btg4.LedgerPeriodLock.t;
      case _igdgld5u.MonthlyAllocation:
        return _igdgld5u.MonthlyAllocation.t;
      case _ignezpci.Payee:
        return _ignezpci.Payee.t;
      case _i1vmvtrm.PlaidConnection:
        return _i1vmvtrm.PlaidConnection.t;
      case _i9is7zb8.RecurringTransaction:
        return _i9is7zb8.RecurringTransaction.t;
      case _i99f9doz.UserSettings:
        return _i99f9doz.UserSettings.t;
      case _i20z9jax.TaxProfileRecord:
        return _i20z9jax.TaxProfileRecord.t;
      case _i6dj6ji0.TransactionRule:
        return _i6dj6ji0.TransactionRule.t;
      case _iqhl4hru.Transaction:
        return _iqhl4hru.Transaction.t;
      case _ipio7ws3.TransactionLine:
        return _ipio7ws3.TransactionLine.t;
      case _ign516jt.Transfer:
        return _ign516jt.Transfer.t;
      case _iw6q2afx.AssetPrice:
        return _iw6q2afx.AssetPrice.t;
      case _ilu5i0rn.Wallet:
        return _ilu5i0rn.Wallet.t;
      case _iqqppnaa.WalletHolding:
        return _iqqppnaa.WalletHolding.t;
      case _i73xhbar.WalletNetworkState:
        return _i73xhbar.WalletNetworkState.t;
      case _i6m1jx15.WalletTransaction:
        return _i6m1jx15.WalletTransaction.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

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
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
