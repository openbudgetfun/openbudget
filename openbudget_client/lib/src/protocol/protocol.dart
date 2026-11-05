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
import 'package:openbudget_client/src/protocol/budget_templates/budget_template.dart'
    as _itiojbb0;
import 'package:openbudget_client/src/protocol/budgets/budget.dart'
    as _iro9sz2e;
import 'package:openbudget_client/src/protocol/categories/category.dart'
    as _iels1fku;
import 'package:openbudget_client/src/protocol/envelope_goals/envelope_goal.dart'
    as _ibdhi9gv;
import 'package:openbudget_client/src/protocol/envelopes/envelope.dart'
    as _i29jf3by;
import 'package:openbudget_client/src/protocol/institutions/institution.dart'
    as _i6ysl1a4;
import 'package:openbudget_client/src/protocol/monthly_allocations/monthly_allocation.dart'
    as _iz3b7rge;
import 'package:openbudget_client/src/protocol/payees/payee.dart' as _iaf6ifsb;
import 'package:openbudget_client/src/protocol/recurring_transactions/recurring_transaction.dart'
    as _i41tn6nr;
import 'package:openbudget_client/src/protocol/solana_wallets/solana_wallet.dart'
    as _i1b8tal0;
import 'package:openbudget_client/src/protocol/solana_wallets/solana_wallet_holding.dart'
    as _i7zpyr5z;
import 'package:openbudget_client/src/protocol/solana_wallets/solana_wallet_tax_year_summary.dart'
    as _igj51lwa;
import 'package:openbudget_client/src/protocol/solana_wallets/solana_wallet_transaction.dart'
    as _isudwq84;
import 'package:openbudget_client/src/protocol/tax/tax_category_view.dart'
    as _ic177lol;
import 'package:openbudget_client/src/protocol/transaction_rules/transaction_rule.dart'
    as _iwxd5v0a;
import 'package:openbudget_client/src/protocol/transactions/import_row.dart'
    as _iyud7cy9;
import 'package:openbudget_client/src/protocol/transactions/split_item.dart'
    as _ilmjmphd;
import 'package:openbudget_client/src/protocol/transactions/transaction.dart'
    as _iio3v7fv;
import 'package:openbudget_client/src/protocol/wallets/wallet_holding.dart'
    as _izm3e498;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

import 'accounts/account.dart' as _iz2jf14v;
import 'budget_templates/budget_template.dart' as _i01fne9j;
import 'budgets/budget.dart' as _idtyoogy;
import 'categories/category.dart' as _iwxpkdmg;
import 'envelope_goals/envelope_goal.dart' as _ifl4yivq;
import 'envelopes/envelope.dart' as _ikt21dfw;
import 'fx_rates/fx_latest_snapshot.dart' as _i8cxakqz;
import 'fx_rates/fx_rate_entry.dart' as _i41ek9pv;
import 'fx_rates/fx_rate_quote.dart' as _i15udi7x;
import 'fx_rates/fx_rate_snapshot.dart' as _i4xgo4ij;
import 'institutions/institution.dart' as _ikgmcjq7;
import 'institutions/institution_location.dart' as _iclizrec;
import 'monthly_allocations/monthly_allocation.dart' as _igdgld5u;
import 'payees/payee.dart' as _ignezpci;
import 'plaid/plaid_connection.dart' as _i1vmvtrm;
import 'recurring_transactions/recurring_transaction.dart' as _i9is7zb8;
import 'solana_wallets/solana_wallet.dart' as _iotf4y4d;
import 'solana_wallets/solana_wallet_holding.dart' as _ivqf8i64;
import 'solana_wallets/solana_wallet_sync_result.dart' as _ir1c2di9;
import 'solana_wallets/solana_wallet_tax_year_summary.dart' as _ijmvodfo;
import 'solana_wallets/solana_wallet_transaction.dart' as _iwwk92r1;
import 'tax/tax_band_slice_view.dart' as _ic4zfx3b;
import 'tax/tax_category_view.dart' as _iv5oayw3;
import 'tax/tax_liability_view.dart' as _ivss6b81;
import 'tax/tax_opportunity_view.dart' as _iuft4v7q;
import 'tax/tax_profile.dart' as _i20z9jax;
import 'tax/tax_report_line_view.dart' as _i6llsezf;
import 'tax/tax_report_view.dart' as _inb54q20;
import 'transaction_rules/transaction_rule.dart' as _i6dj6ji0;
import 'transactions/import_row.dart' as _isp6bezg;
import 'transactions/split_item.dart' as _i0jd5x9z;
import 'transactions/transaction.dart' as _iqhl4hru;
import 'wallets/asset_quote_cache.dart' as _i2gu4pwf;
import 'wallets/wallet_connect_result.dart' as _igiy3v19;
import 'wallets/wallet_connection.dart' as _i9uqpb1b;
import 'wallets/wallet_holding.dart' as _iqqppnaa;
export 'accounts/account.dart';
export 'budget_templates/budget_template.dart';
export 'budgets/budget.dart';
export 'categories/category.dart';
export 'envelope_goals/envelope_goal.dart';
export 'envelopes/envelope.dart';
export 'fx_rates/fx_latest_snapshot.dart';
export 'fx_rates/fx_rate_entry.dart';
export 'fx_rates/fx_rate_quote.dart';
export 'fx_rates/fx_rate_snapshot.dart';
export 'institutions/institution.dart';
export 'institutions/institution_location.dart';
export 'monthly_allocations/monthly_allocation.dart';
export 'payees/payee.dart';
export 'plaid/plaid_connection.dart';
export 'recurring_transactions/recurring_transaction.dart';
export 'solana_wallets/solana_wallet.dart';
export 'solana_wallets/solana_wallet_holding.dart';
export 'solana_wallets/solana_wallet_sync_result.dart';
export 'solana_wallets/solana_wallet_tax_year_summary.dart';
export 'solana_wallets/solana_wallet_transaction.dart';
export 'tax/tax_band_slice_view.dart';
export 'tax/tax_category_view.dart';
export 'tax/tax_liability_view.dart';
export 'tax/tax_opportunity_view.dart';
export 'tax/tax_profile.dart';
export 'tax/tax_report_line_view.dart';
export 'tax/tax_report_view.dart';
export 'transaction_rules/transaction_rule.dart';
export 'transactions/import_row.dart';
export 'transactions/split_item.dart';
export 'transactions/transaction.dart';
export 'wallets/asset_quote_cache.dart';
export 'wallets/wallet_connect_result.dart';
export 'wallets/wallet_connection.dart';
export 'wallets/wallet_holding.dart';
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
          _isc.getType<_i01fne9j.BudgetTemplate>,
          _isc.getType<_idtyoogy.Budget>,
          _isc.getType<_iwxpkdmg.Category>,
          _isc.getType<_ifl4yivq.EnvelopeGoal>,
          _isc.getType<_ikt21dfw.Envelope>,
          _isc.getType<_i8cxakqz.FxLatestSnapshot>,
          _isc.getType<_i41ek9pv.FxRateEntry>,
          _isc.getType<_i15udi7x.FxRateQuote>,
          _isc.getType<_i4xgo4ij.FxRateSnapshot>,
          _isc.getType<_ikgmcjq7.Institution>,
          _isc.getType<_iclizrec.InstitutionLocation>,
          _isc.getType<_igdgld5u.MonthlyAllocation>,
          _isc.getType<_ignezpci.Payee>,
          _isc.getType<_i1vmvtrm.PlaidConnection>,
          _isc.getType<_i9is7zb8.RecurringTransaction>,
          _isc.getType<_iotf4y4d.SolanaWallet>,
          _isc.getType<_ivqf8i64.SolanaWalletHolding>,
          _isc.getType<_ir1c2di9.SolanaWalletSyncResult>,
          _isc.getType<_ijmvodfo.SolanaWalletTaxYearSummary>,
          _isc.getType<_iwwk92r1.SolanaWalletTransaction>,
          _isc.getType<_ic4zfx3b.TaxBandSliceView>,
          _isc.getType<_iv5oayw3.TaxCategoryView>,
          _isc.getType<_ivss6b81.TaxLiabilityView>,
          _isc.getType<_iuft4v7q.TaxOpportunityView>,
          _isc.getType<_i20z9jax.TaxProfileRecord>,
          _isc.getType<_i6llsezf.TaxReportLineView>,
          _isc.getType<_inb54q20.TaxReportView>,
          _isc.getType<_i6dj6ji0.TransactionRule>,
          _isc.getType<_isp6bezg.ImportRow>,
          _isc.getType<_i0jd5x9z.SplitItem>,
          _isc.getType<_iqhl4hru.Transaction>,
          _isc.getType<_i2gu4pwf.AssetQuoteCache>,
          _isc.getType<_igiy3v19.WalletConnectResult>,
          _isc.getType<_i9uqpb1b.WalletConnection>,
          _isc.getType<_iqqppnaa.WalletHolding>,
          _isc.getType<_iz2jf14v.Account?>,
          _isc.getType<_i01fne9j.BudgetTemplate?>,
          _isc.getType<_idtyoogy.Budget?>,
          _isc.getType<_iwxpkdmg.Category?>,
          _isc.getType<_ifl4yivq.EnvelopeGoal?>,
          _isc.getType<_ikt21dfw.Envelope?>,
          _isc.getType<_i8cxakqz.FxLatestSnapshot?>,
          _isc.getType<_i41ek9pv.FxRateEntry?>,
          _isc.getType<_i15udi7x.FxRateQuote?>,
          _isc.getType<_i4xgo4ij.FxRateSnapshot?>,
          _isc.getType<_ikgmcjq7.Institution?>,
          _isc.getType<_iclizrec.InstitutionLocation?>,
          _isc.getType<_igdgld5u.MonthlyAllocation?>,
          _isc.getType<_ignezpci.Payee?>,
          _isc.getType<_i1vmvtrm.PlaidConnection?>,
          _isc.getType<_i9is7zb8.RecurringTransaction?>,
          _isc.getType<_iotf4y4d.SolanaWallet?>,
          _isc.getType<_ivqf8i64.SolanaWalletHolding?>,
          _isc.getType<_ir1c2di9.SolanaWalletSyncResult?>,
          _isc.getType<_ijmvodfo.SolanaWalletTaxYearSummary?>,
          _isc.getType<_iwwk92r1.SolanaWalletTransaction?>,
          _isc.getType<_ic4zfx3b.TaxBandSliceView?>,
          _isc.getType<_iv5oayw3.TaxCategoryView?>,
          _isc.getType<_ivss6b81.TaxLiabilityView?>,
          _isc.getType<_iuft4v7q.TaxOpportunityView?>,
          _isc.getType<_i20z9jax.TaxProfileRecord?>,
          _isc.getType<_i6llsezf.TaxReportLineView?>,
          _isc.getType<_inb54q20.TaxReportView?>,
          _isc.getType<_i6dj6ji0.TransactionRule?>,
          _isc.getType<_isp6bezg.ImportRow?>,
          _isc.getType<_i0jd5x9z.SplitItem?>,
          _isc.getType<_iqhl4hru.Transaction?>,
          _isc.getType<_i2gu4pwf.AssetQuoteCache?>,
          _isc.getType<_igiy3v19.WalletConnectResult?>,
          _isc.getType<_i9uqpb1b.WalletConnection?>,
          _isc.getType<_iqqppnaa.WalletHolding?>,
          _isc.getType<List<_i15udi7x.FxRateQuote>>,
          _isc.getType<List<_ic4zfx3b.TaxBandSliceView>>,
          _isc.getType<List<_i6llsezf.TaxReportLineView>>,
          _isc.getType<List<_ivss6b81.TaxLiabilityView>>,
          _isc.getType<List<String>>,
          _isc.getType<List<_iuft4v7q.TaxOpportunityView>>,
          _isc.getType<List<_iqqppnaa.WalletHolding>>,
          _isc.getType<List<_iqudaadl.Account>>,
          _isc.getType<List<_itiojbb0.BudgetTemplate>>,
          _isc.getType<List<_iz3b7rge.MonthlyAllocation>>,
          _isc.getType<List<_iro9sz2e.Budget>>,
          _isc.getType<List<_iels1fku.Category>>,
          _isc.getType<List<_isc.UuidValue>>,
          _isc.getType<List<_ibdhi9gv.EnvelopeGoal>>,
          _isc.getType<List<_i29jf3by.Envelope>>,
          _isc.getType<List<String>>,
          _isc.getType<List<_i6ysl1a4.Institution>>,
          _isc.getType<List<_iaf6ifsb.Payee>>,
          _isc.getType<List<_i41tn6nr.RecurringTransaction>>,
          _isc.getType<List<_i1b8tal0.SolanaWallet>>,
          _isc.getType<List<_isudwq84.SolanaWalletTransaction>>,
          _isc.getType<List<_i7zpyr5z.SolanaWalletHolding>>,
          _isc.getType<List<_igj51lwa.SolanaWalletTaxYearSummary>>,
          _isc.getType<List<_ic177lol.TaxCategoryView>>,
          _isc.getType<List<_iwxd5v0a.TransactionRule>>,
          _isc.getType<List<_iio3v7fv.Transaction>>,
          _isc.getType<List<int>>,
          _isc.getType<List<_ilmjmphd.SplitItem>>,
          _isc.getType<List<_iyud7cy9.ImportRow>>,
          _isc.getType<List<_izm3e498.WalletHolding>>,
        ],
        modules: const [
          _iaic.Protocol.new,
          _iacc.Protocol.new,
        ],
        classNames: const [
          'Account',
          'BudgetTemplate',
          'Budget',
          'Category',
          'EnvelopeGoal',
          'Envelope',
          'FxLatestSnapshot',
          'FxRateEntry',
          'FxRateQuote',
          'FxRateSnapshot',
          'Institution',
          'InstitutionLocation',
          'MonthlyAllocation',
          'Payee',
          'PlaidConnection',
          'RecurringTransaction',
          'SolanaWallet',
          'SolanaWalletHolding',
          'SolanaWalletSyncResult',
          'SolanaWalletTaxYearSummary',
          'SolanaWalletTransaction',
          'TaxBandSliceView',
          'TaxCategoryView',
          'TaxLiabilityView',
          'TaxOpportunityView',
          'TaxProfileRecord',
          'TaxReportLineView',
          'TaxReportView',
          'TransactionRule',
          'ImportRow',
          'SplitItem',
          'Transaction',
          'AssetQuoteCache',
          'WalletConnectResult',
          'WalletConnection',
          'WalletHolding',
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
    if (t == _i01fne9j.BudgetTemplate) {
      return _i01fne9j.BudgetTemplate.fromJson(data) as T;
    }
    if (t == _idtyoogy.Budget) {
      return _idtyoogy.Budget.fromJson(data) as T;
    }
    if (t == _iwxpkdmg.Category) {
      return _iwxpkdmg.Category.fromJson(data) as T;
    }
    if (t == _ifl4yivq.EnvelopeGoal) {
      return _ifl4yivq.EnvelopeGoal.fromJson(data) as T;
    }
    if (t == _ikt21dfw.Envelope) {
      return _ikt21dfw.Envelope.fromJson(data) as T;
    }
    if (t == _i8cxakqz.FxLatestSnapshot) {
      return _i8cxakqz.FxLatestSnapshot.fromJson(data) as T;
    }
    if (t == _i41ek9pv.FxRateEntry) {
      return _i41ek9pv.FxRateEntry.fromJson(data) as T;
    }
    if (t == _i15udi7x.FxRateQuote) {
      return _i15udi7x.FxRateQuote.fromJson(data) as T;
    }
    if (t == _i4xgo4ij.FxRateSnapshot) {
      return _i4xgo4ij.FxRateSnapshot.fromJson(data) as T;
    }
    if (t == _ikgmcjq7.Institution) {
      return _ikgmcjq7.Institution.fromJson(data) as T;
    }
    if (t == _iclizrec.InstitutionLocation) {
      return _iclizrec.InstitutionLocation.fromJson(data) as T;
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
    if (t == _iotf4y4d.SolanaWallet) {
      return _iotf4y4d.SolanaWallet.fromJson(data) as T;
    }
    if (t == _ivqf8i64.SolanaWalletHolding) {
      return _ivqf8i64.SolanaWalletHolding.fromJson(data) as T;
    }
    if (t == _ir1c2di9.SolanaWalletSyncResult) {
      return _ir1c2di9.SolanaWalletSyncResult.fromJson(data) as T;
    }
    if (t == _ijmvodfo.SolanaWalletTaxYearSummary) {
      return _ijmvodfo.SolanaWalletTaxYearSummary.fromJson(data) as T;
    }
    if (t == _iwwk92r1.SolanaWalletTransaction) {
      return _iwwk92r1.SolanaWalletTransaction.fromJson(data) as T;
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
    if (t == _i6dj6ji0.TransactionRule) {
      return _i6dj6ji0.TransactionRule.fromJson(data) as T;
    }
    if (t == _isp6bezg.ImportRow) {
      return _isp6bezg.ImportRow.fromJson(data) as T;
    }
    if (t == _i0jd5x9z.SplitItem) {
      return _i0jd5x9z.SplitItem.fromJson(data) as T;
    }
    if (t == _iqhl4hru.Transaction) {
      return _iqhl4hru.Transaction.fromJson(data) as T;
    }
    if (t == _i2gu4pwf.AssetQuoteCache) {
      return _i2gu4pwf.AssetQuoteCache.fromJson(data) as T;
    }
    if (t == _igiy3v19.WalletConnectResult) {
      return _igiy3v19.WalletConnectResult.fromJson(data) as T;
    }
    if (t == _i9uqpb1b.WalletConnection) {
      return _i9uqpb1b.WalletConnection.fromJson(data) as T;
    }
    if (t == _iqqppnaa.WalletHolding) {
      return _iqqppnaa.WalletHolding.fromJson(data) as T;
    }
    if (t == _isc.getType<_iz2jf14v.Account?>()) {
      return (data != null ? _iz2jf14v.Account.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i01fne9j.BudgetTemplate?>()) {
      return (data != null ? _i01fne9j.BudgetTemplate.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_idtyoogy.Budget?>()) {
      return (data != null ? _idtyoogy.Budget.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iwxpkdmg.Category?>()) {
      return (data != null ? _iwxpkdmg.Category.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ifl4yivq.EnvelopeGoal?>()) {
      return (data != null ? _ifl4yivq.EnvelopeGoal.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ikt21dfw.Envelope?>()) {
      return (data != null ? _ikt21dfw.Envelope.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i8cxakqz.FxLatestSnapshot?>()) {
      return (data != null ? _i8cxakqz.FxLatestSnapshot.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i41ek9pv.FxRateEntry?>()) {
      return (data != null ? _i41ek9pv.FxRateEntry.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i15udi7x.FxRateQuote?>()) {
      return (data != null ? _i15udi7x.FxRateQuote.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i4xgo4ij.FxRateSnapshot?>()) {
      return (data != null ? _i4xgo4ij.FxRateSnapshot.fromJson(data) : null)
          as T;
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
    if (t == _isc.getType<_iotf4y4d.SolanaWallet?>()) {
      return (data != null ? _iotf4y4d.SolanaWallet.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ivqf8i64.SolanaWalletHolding?>()) {
      return (data != null
              ? _ivqf8i64.SolanaWalletHolding.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ir1c2di9.SolanaWalletSyncResult?>()) {
      return (data != null
              ? _ir1c2di9.SolanaWalletSyncResult.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ijmvodfo.SolanaWalletTaxYearSummary?>()) {
      return (data != null
              ? _ijmvodfo.SolanaWalletTaxYearSummary.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iwwk92r1.SolanaWalletTransaction?>()) {
      return (data != null
              ? _iwwk92r1.SolanaWalletTransaction.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ic4zfx3b.TaxBandSliceView?>()) {
      return (data != null ? _ic4zfx3b.TaxBandSliceView.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iv5oayw3.TaxCategoryView?>()) {
      return (data != null ? _iv5oayw3.TaxCategoryView.fromJson(data) : null)
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
    if (t == _isc.getType<_i6dj6ji0.TransactionRule?>()) {
      return (data != null ? _i6dj6ji0.TransactionRule.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_isp6bezg.ImportRow?>()) {
      return (data != null ? _isp6bezg.ImportRow.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i0jd5x9z.SplitItem?>()) {
      return (data != null ? _i0jd5x9z.SplitItem.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iqhl4hru.Transaction?>()) {
      return (data != null ? _iqhl4hru.Transaction.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i2gu4pwf.AssetQuoteCache?>()) {
      return (data != null ? _i2gu4pwf.AssetQuoteCache.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_igiy3v19.WalletConnectResult?>()) {
      return (data != null
              ? _igiy3v19.WalletConnectResult.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i9uqpb1b.WalletConnection?>()) {
      return (data != null ? _i9uqpb1b.WalletConnection.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iqqppnaa.WalletHolding?>()) {
      return (data != null ? _iqqppnaa.WalletHolding.fromJson(data) : null)
          as T;
    }
    if (t == List<_i15udi7x.FxRateQuote>) {
      return (data as List)
              .map((e) => deserialize<_i15udi7x.FxRateQuote>(e))
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
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_iuft4v7q.TaxOpportunityView>) {
      return (data as List)
              .map((e) => deserialize<_iuft4v7q.TaxOpportunityView>(e))
              .toList()
          as T;
    }
    if (t == List<_iqqppnaa.WalletHolding>) {
      return (data as List)
              .map((e) => deserialize<_iqqppnaa.WalletHolding>(e))
              .toList()
          as T;
    }
    if (t == List<_iqudaadl.Account>) {
      return (data as List)
              .map((e) => deserialize<_iqudaadl.Account>(e))
              .toList()
          as T;
    }
    if (t == List<_itiojbb0.BudgetTemplate>) {
      return (data as List)
              .map((e) => deserialize<_itiojbb0.BudgetTemplate>(e))
              .toList()
          as T;
    }
    if (t == List<_iz3b7rge.MonthlyAllocation>) {
      return (data as List)
              .map((e) => deserialize<_iz3b7rge.MonthlyAllocation>(e))
              .toList()
          as T;
    }
    if (t == List<_iro9sz2e.Budget>) {
      return (data as List)
              .map((e) => deserialize<_iro9sz2e.Budget>(e))
              .toList()
          as T;
    }
    if (t == List<_iels1fku.Category>) {
      return (data as List)
              .map((e) => deserialize<_iels1fku.Category>(e))
              .toList()
          as T;
    }
    if (t == List<_isc.UuidValue>) {
      return (data as List).map((e) => deserialize<_isc.UuidValue>(e)).toList()
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
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i6ysl1a4.Institution>) {
      return (data as List)
              .map((e) => deserialize<_i6ysl1a4.Institution>(e))
              .toList()
          as T;
    }
    if (t == List<_iaf6ifsb.Payee>) {
      return (data as List).map((e) => deserialize<_iaf6ifsb.Payee>(e)).toList()
          as T;
    }
    if (t == List<_i41tn6nr.RecurringTransaction>) {
      return (data as List)
              .map((e) => deserialize<_i41tn6nr.RecurringTransaction>(e))
              .toList()
          as T;
    }
    if (t == List<_i1b8tal0.SolanaWallet>) {
      return (data as List)
              .map((e) => deserialize<_i1b8tal0.SolanaWallet>(e))
              .toList()
          as T;
    }
    if (t == List<_isudwq84.SolanaWalletTransaction>) {
      return (data as List)
              .map((e) => deserialize<_isudwq84.SolanaWalletTransaction>(e))
              .toList()
          as T;
    }
    if (t == List<_i7zpyr5z.SolanaWalletHolding>) {
      return (data as List)
              .map((e) => deserialize<_i7zpyr5z.SolanaWalletHolding>(e))
              .toList()
          as T;
    }
    if (t == List<_igj51lwa.SolanaWalletTaxYearSummary>) {
      return (data as List)
              .map((e) => deserialize<_igj51lwa.SolanaWalletTaxYearSummary>(e))
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
    if (t == List<_iio3v7fv.Transaction>) {
      return (data as List)
              .map((e) => deserialize<_iio3v7fv.Transaction>(e))
              .toList()
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<_ilmjmphd.SplitItem>) {
      return (data as List)
              .map((e) => deserialize<_ilmjmphd.SplitItem>(e))
              .toList()
          as T;
    }
    if (t == List<_iyud7cy9.ImportRow>) {
      return (data as List)
              .map((e) => deserialize<_iyud7cy9.ImportRow>(e))
              .toList()
          as T;
    }
    if (t == List<_izm3e498.WalletHolding>) {
      return (data as List)
              .map((e) => deserialize<_izm3e498.WalletHolding>(e))
              .toList()
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
      _i01fne9j.BudgetTemplate => 'BudgetTemplate',
      _idtyoogy.Budget => 'Budget',
      _iwxpkdmg.Category => 'Category',
      _ifl4yivq.EnvelopeGoal => 'EnvelopeGoal',
      _ikt21dfw.Envelope => 'Envelope',
      _i8cxakqz.FxLatestSnapshot => 'FxLatestSnapshot',
      _i41ek9pv.FxRateEntry => 'FxRateEntry',
      _i15udi7x.FxRateQuote => 'FxRateQuote',
      _i4xgo4ij.FxRateSnapshot => 'FxRateSnapshot',
      _ikgmcjq7.Institution => 'Institution',
      _iclizrec.InstitutionLocation => 'InstitutionLocation',
      _igdgld5u.MonthlyAllocation => 'MonthlyAllocation',
      _ignezpci.Payee => 'Payee',
      _i1vmvtrm.PlaidConnection => 'PlaidConnection',
      _i9is7zb8.RecurringTransaction => 'RecurringTransaction',
      _iotf4y4d.SolanaWallet => 'SolanaWallet',
      _ivqf8i64.SolanaWalletHolding => 'SolanaWalletHolding',
      _ir1c2di9.SolanaWalletSyncResult => 'SolanaWalletSyncResult',
      _ijmvodfo.SolanaWalletTaxYearSummary => 'SolanaWalletTaxYearSummary',
      _iwwk92r1.SolanaWalletTransaction => 'SolanaWalletTransaction',
      _ic4zfx3b.TaxBandSliceView => 'TaxBandSliceView',
      _iv5oayw3.TaxCategoryView => 'TaxCategoryView',
      _ivss6b81.TaxLiabilityView => 'TaxLiabilityView',
      _iuft4v7q.TaxOpportunityView => 'TaxOpportunityView',
      _i20z9jax.TaxProfileRecord => 'TaxProfileRecord',
      _i6llsezf.TaxReportLineView => 'TaxReportLineView',
      _inb54q20.TaxReportView => 'TaxReportView',
      _i6dj6ji0.TransactionRule => 'TransactionRule',
      _isp6bezg.ImportRow => 'ImportRow',
      _i0jd5x9z.SplitItem => 'SplitItem',
      _iqhl4hru.Transaction => 'Transaction',
      _i2gu4pwf.AssetQuoteCache => 'AssetQuoteCache',
      _igiy3v19.WalletConnectResult => 'WalletConnectResult',
      _i9uqpb1b.WalletConnection => 'WalletConnection',
      _iqqppnaa.WalletHolding => 'WalletHolding',
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
      case _i01fne9j.BudgetTemplate():
        return 'BudgetTemplate';
      case _idtyoogy.Budget():
        return 'Budget';
      case _iwxpkdmg.Category():
        return 'Category';
      case _ifl4yivq.EnvelopeGoal():
        return 'EnvelopeGoal';
      case _ikt21dfw.Envelope():
        return 'Envelope';
      case _i8cxakqz.FxLatestSnapshot():
        return 'FxLatestSnapshot';
      case _i41ek9pv.FxRateEntry():
        return 'FxRateEntry';
      case _i15udi7x.FxRateQuote():
        return 'FxRateQuote';
      case _i4xgo4ij.FxRateSnapshot():
        return 'FxRateSnapshot';
      case _ikgmcjq7.Institution():
        return 'Institution';
      case _iclizrec.InstitutionLocation():
        return 'InstitutionLocation';
      case _igdgld5u.MonthlyAllocation():
        return 'MonthlyAllocation';
      case _ignezpci.Payee():
        return 'Payee';
      case _i1vmvtrm.PlaidConnection():
        return 'PlaidConnection';
      case _i9is7zb8.RecurringTransaction():
        return 'RecurringTransaction';
      case _iotf4y4d.SolanaWallet():
        return 'SolanaWallet';
      case _ivqf8i64.SolanaWalletHolding():
        return 'SolanaWalletHolding';
      case _ir1c2di9.SolanaWalletSyncResult():
        return 'SolanaWalletSyncResult';
      case _ijmvodfo.SolanaWalletTaxYearSummary():
        return 'SolanaWalletTaxYearSummary';
      case _iwwk92r1.SolanaWalletTransaction():
        return 'SolanaWalletTransaction';
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
      case _i6dj6ji0.TransactionRule():
        return 'TransactionRule';
      case _isp6bezg.ImportRow():
        return 'ImportRow';
      case _i0jd5x9z.SplitItem():
        return 'SplitItem';
      case _iqhl4hru.Transaction():
        return 'Transaction';
      case _i2gu4pwf.AssetQuoteCache():
        return 'AssetQuoteCache';
      case _igiy3v19.WalletConnectResult():
        return 'WalletConnectResult';
      case _i9uqpb1b.WalletConnection():
        return 'WalletConnection';
      case _iqqppnaa.WalletHolding():
        return 'WalletHolding';
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
    if (dataClassName == 'BudgetTemplate') {
      return deserialize<_i01fne9j.BudgetTemplate>(data['data']);
    }
    if (dataClassName == 'Budget') {
      return deserialize<_idtyoogy.Budget>(data['data']);
    }
    if (dataClassName == 'Category') {
      return deserialize<_iwxpkdmg.Category>(data['data']);
    }
    if (dataClassName == 'EnvelopeGoal') {
      return deserialize<_ifl4yivq.EnvelopeGoal>(data['data']);
    }
    if (dataClassName == 'Envelope') {
      return deserialize<_ikt21dfw.Envelope>(data['data']);
    }
    if (dataClassName == 'FxLatestSnapshot') {
      return deserialize<_i8cxakqz.FxLatestSnapshot>(data['data']);
    }
    if (dataClassName == 'FxRateEntry') {
      return deserialize<_i41ek9pv.FxRateEntry>(data['data']);
    }
    if (dataClassName == 'FxRateQuote') {
      return deserialize<_i15udi7x.FxRateQuote>(data['data']);
    }
    if (dataClassName == 'FxRateSnapshot') {
      return deserialize<_i4xgo4ij.FxRateSnapshot>(data['data']);
    }
    if (dataClassName == 'Institution') {
      return deserialize<_ikgmcjq7.Institution>(data['data']);
    }
    if (dataClassName == 'InstitutionLocation') {
      return deserialize<_iclizrec.InstitutionLocation>(data['data']);
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
    if (dataClassName == 'SolanaWallet') {
      return deserialize<_iotf4y4d.SolanaWallet>(data['data']);
    }
    if (dataClassName == 'SolanaWalletHolding') {
      return deserialize<_ivqf8i64.SolanaWalletHolding>(data['data']);
    }
    if (dataClassName == 'SolanaWalletSyncResult') {
      return deserialize<_ir1c2di9.SolanaWalletSyncResult>(data['data']);
    }
    if (dataClassName == 'SolanaWalletTaxYearSummary') {
      return deserialize<_ijmvodfo.SolanaWalletTaxYearSummary>(data['data']);
    }
    if (dataClassName == 'SolanaWalletTransaction') {
      return deserialize<_iwwk92r1.SolanaWalletTransaction>(data['data']);
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
    if (dataClassName == 'TransactionRule') {
      return deserialize<_i6dj6ji0.TransactionRule>(data['data']);
    }
    if (dataClassName == 'ImportRow') {
      return deserialize<_isp6bezg.ImportRow>(data['data']);
    }
    if (dataClassName == 'SplitItem') {
      return deserialize<_i0jd5x9z.SplitItem>(data['data']);
    }
    if (dataClassName == 'Transaction') {
      return deserialize<_iqhl4hru.Transaction>(data['data']);
    }
    if (dataClassName == 'AssetQuoteCache') {
      return deserialize<_i2gu4pwf.AssetQuoteCache>(data['data']);
    }
    if (dataClassName == 'WalletConnectResult') {
      return deserialize<_igiy3v19.WalletConnectResult>(data['data']);
    }
    if (dataClassName == 'WalletConnection') {
      return deserialize<_i9uqpb1b.WalletConnection>(data['data']);
    }
    if (dataClassName == 'WalletHolding') {
      return deserialize<_iqqppnaa.WalletHolding>(data['data']);
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
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('openbudget', this);
    _iacc.Protocol().registerHostProtocol('openbudget', this);
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
