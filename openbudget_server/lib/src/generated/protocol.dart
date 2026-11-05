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
import 'package:openbudget_server/src/generated/accounts/account.dart'
    as _i3fh9aci;
import 'package:openbudget_server/src/generated/budget_templates/budget_template.dart'
    as _ihbdj8p6;
import 'package:openbudget_server/src/generated/budgets/budget.dart'
    as _ihk6o4ea;
import 'package:openbudget_server/src/generated/categories/category.dart'
    as _iwlneq7u;
import 'package:openbudget_server/src/generated/envelope_goals/envelope_goal.dart'
    as _iuyjld9f;
import 'package:openbudget_server/src/generated/envelopes/envelope.dart'
    as _igwnqatb;
import 'package:openbudget_server/src/generated/institutions/institution.dart'
    as _izagyfe8;
import 'package:openbudget_server/src/generated/monthly_allocations/monthly_allocation.dart'
    as _i01zjgtu;
import 'package:openbudget_server/src/generated/payees/payee.dart' as _i2xhh3nq;
import 'package:openbudget_server/src/generated/recurring_transactions/recurring_transaction.dart'
    as _i6lbncsb;
import 'package:openbudget_server/src/generated/solana_wallets/solana_wallet.dart'
    as _ieq0zunc;
import 'package:openbudget_server/src/generated/solana_wallets/solana_wallet_holding.dart'
    as _iry3zuft;
import 'package:openbudget_server/src/generated/solana_wallets/solana_wallet_tax_year_summary.dart'
    as _ik6g6ols;
import 'package:openbudget_server/src/generated/solana_wallets/solana_wallet_transaction.dart'
    as _imyeu1oa;
import 'package:openbudget_server/src/generated/tax/tax_category_view.dart'
    as _i687t6y5;
import 'package:openbudget_server/src/generated/transaction_rules/transaction_rule.dart'
    as _i4wqhpw2;
import 'package:openbudget_server/src/generated/transactions/import_row.dart'
    as _iyod81ld;
import 'package:openbudget_server/src/generated/transactions/split_item.dart'
    as _ii8zyh2l;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as _ioie3qid;
import 'package:openbudget_server/src/generated/wallets/wallet_holding.dart'
    as _icu5m6lt;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;

import 'accounts/account.dart' as _iz2jf14v;
import 'billing/entitlement.dart' as _iq2w1sa5;
import 'billing/entitlement_source.dart' as _ipnf4x0i;
import 'billing/entitlement_status.dart' as _imqwzx9j;
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
export 'billing/entitlement.dart';
export 'billing/entitlement_source.dart';
export 'billing/entitlement_status.dart';
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
          _is.getType<_iq2w1sa5.Entitlement>,
          _is.getType<_ipnf4x0i.EntitlementSource>,
          _is.getType<_imqwzx9j.EntitlementStatus>,
          _is.getType<_i01fne9j.BudgetTemplate>,
          _is.getType<_idtyoogy.Budget>,
          _is.getType<_iwxpkdmg.Category>,
          _is.getType<_ifl4yivq.EnvelopeGoal>,
          _is.getType<_ikt21dfw.Envelope>,
          _is.getType<_i8cxakqz.FxLatestSnapshot>,
          _is.getType<_i41ek9pv.FxRateEntry>,
          _is.getType<_i15udi7x.FxRateQuote>,
          _is.getType<_i4xgo4ij.FxRateSnapshot>,
          _is.getType<_ikgmcjq7.Institution>,
          _is.getType<_iclizrec.InstitutionLocation>,
          _is.getType<_igdgld5u.MonthlyAllocation>,
          _is.getType<_ignezpci.Payee>,
          _is.getType<_i1vmvtrm.PlaidConnection>,
          _is.getType<_i9is7zb8.RecurringTransaction>,
          _is.getType<_iotf4y4d.SolanaWallet>,
          _is.getType<_ivqf8i64.SolanaWalletHolding>,
          _is.getType<_ir1c2di9.SolanaWalletSyncResult>,
          _is.getType<_ijmvodfo.SolanaWalletTaxYearSummary>,
          _is.getType<_iwwk92r1.SolanaWalletTransaction>,
          _is.getType<_ic4zfx3b.TaxBandSliceView>,
          _is.getType<_iv5oayw3.TaxCategoryView>,
          _is.getType<_ivss6b81.TaxLiabilityView>,
          _is.getType<_iuft4v7q.TaxOpportunityView>,
          _is.getType<_i20z9jax.TaxProfileRecord>,
          _is.getType<_i6llsezf.TaxReportLineView>,
          _is.getType<_inb54q20.TaxReportView>,
          _is.getType<_i6dj6ji0.TransactionRule>,
          _is.getType<_isp6bezg.ImportRow>,
          _is.getType<_i0jd5x9z.SplitItem>,
          _is.getType<_iqhl4hru.Transaction>,
          _is.getType<_i2gu4pwf.AssetQuoteCache>,
          _is.getType<_igiy3v19.WalletConnectResult>,
          _is.getType<_i9uqpb1b.WalletConnection>,
          _is.getType<_iqqppnaa.WalletHolding>,
          _is.getType<_iz2jf14v.Account?>,
          _is.getType<_iq2w1sa5.Entitlement?>,
          _is.getType<_ipnf4x0i.EntitlementSource?>,
          _is.getType<_imqwzx9j.EntitlementStatus?>,
          _is.getType<_i01fne9j.BudgetTemplate?>,
          _is.getType<_idtyoogy.Budget?>,
          _is.getType<_iwxpkdmg.Category?>,
          _is.getType<_ifl4yivq.EnvelopeGoal?>,
          _is.getType<_ikt21dfw.Envelope?>,
          _is.getType<_i8cxakqz.FxLatestSnapshot?>,
          _is.getType<_i41ek9pv.FxRateEntry?>,
          _is.getType<_i15udi7x.FxRateQuote?>,
          _is.getType<_i4xgo4ij.FxRateSnapshot?>,
          _is.getType<_ikgmcjq7.Institution?>,
          _is.getType<_iclizrec.InstitutionLocation?>,
          _is.getType<_igdgld5u.MonthlyAllocation?>,
          _is.getType<_ignezpci.Payee?>,
          _is.getType<_i1vmvtrm.PlaidConnection?>,
          _is.getType<_i9is7zb8.RecurringTransaction?>,
          _is.getType<_iotf4y4d.SolanaWallet?>,
          _is.getType<_ivqf8i64.SolanaWalletHolding?>,
          _is.getType<_ir1c2di9.SolanaWalletSyncResult?>,
          _is.getType<_ijmvodfo.SolanaWalletTaxYearSummary?>,
          _is.getType<_iwwk92r1.SolanaWalletTransaction?>,
          _is.getType<_ic4zfx3b.TaxBandSliceView?>,
          _is.getType<_iv5oayw3.TaxCategoryView?>,
          _is.getType<_ivss6b81.TaxLiabilityView?>,
          _is.getType<_iuft4v7q.TaxOpportunityView?>,
          _is.getType<_i20z9jax.TaxProfileRecord?>,
          _is.getType<_i6llsezf.TaxReportLineView?>,
          _is.getType<_inb54q20.TaxReportView?>,
          _is.getType<_i6dj6ji0.TransactionRule?>,
          _is.getType<_isp6bezg.ImportRow?>,
          _is.getType<_i0jd5x9z.SplitItem?>,
          _is.getType<_iqhl4hru.Transaction?>,
          _is.getType<_i2gu4pwf.AssetQuoteCache?>,
          _is.getType<_igiy3v19.WalletConnectResult?>,
          _is.getType<_i9uqpb1b.WalletConnection?>,
          _is.getType<_iqqppnaa.WalletHolding?>,
          _is.getType<List<_i15udi7x.FxRateQuote>>,
          _is.getType<List<_ic4zfx3b.TaxBandSliceView>>,
          _is.getType<List<_i6llsezf.TaxReportLineView>>,
          _is.getType<List<_ivss6b81.TaxLiabilityView>>,
          _is.getType<List<String>>,
          _is.getType<List<_iuft4v7q.TaxOpportunityView>>,
          _is.getType<List<_iqqppnaa.WalletHolding>>,
          _is.getType<List<_i3fh9aci.Account>>,
          _is.getType<List<_ihbdj8p6.BudgetTemplate>>,
          _is.getType<List<_i01zjgtu.MonthlyAllocation>>,
          _is.getType<List<_ihk6o4ea.Budget>>,
          _is.getType<List<_iwlneq7u.Category>>,
          _is.getType<List<_is.UuidValue>>,
          _is.getType<List<_iuyjld9f.EnvelopeGoal>>,
          _is.getType<List<_igwnqatb.Envelope>>,
          _is.getType<List<String>>,
          _is.getType<List<_izagyfe8.Institution>>,
          _is.getType<List<_i2xhh3nq.Payee>>,
          _is.getType<List<_i6lbncsb.RecurringTransaction>>,
          _is.getType<List<_ieq0zunc.SolanaWallet>>,
          _is.getType<List<_imyeu1oa.SolanaWalletTransaction>>,
          _is.getType<List<_iry3zuft.SolanaWalletHolding>>,
          _is.getType<List<_ik6g6ols.SolanaWalletTaxYearSummary>>,
          _is.getType<List<_i687t6y5.TaxCategoryView>>,
          _is.getType<List<_i4wqhpw2.TransactionRule>>,
          _is.getType<List<_ioie3qid.Transaction>>,
          _is.getType<List<int>>,
          _is.getType<List<_ii8zyh2l.SplitItem>>,
          _is.getType<List<_iyod81ld.ImportRow>>,
          _is.getType<List<_icu5m6lt.WalletHolding>>,
        ],
        modules: const [
          _iais.Protocol.new,
          _iacs.Protocol.new,
          _isp.Protocol.new,
        ],
        classNames: const [
          'Account',
          'Entitlement',
          'EntitlementSource',
          'EntitlementStatus',
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
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'accountType',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'balanceCents',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'currencyCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'budgetId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'creatorId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'institutionId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'onBudget',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'sortOrder',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'isClosed',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'sourceType',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'externalAccountId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'connectionId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'lastSyncedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'syncStatus',
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
          constraintName: 'account_fk_0',
          columns: ['budgetId'],
          referenceTable: 'budget',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'account_fk_1',
          columns: ['institutionId'],
          referenceTable: 'institution',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'account_budget_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'budgetId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'account_budget_external_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'budgetId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'externalAccountId',
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
      name: 'asset_quote_cache',
      dartName: 'AssetQuoteCache',
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
          name: 'chain',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
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
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'usdPrice',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'fetchedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
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
          indexName: 'asset_quote_cache_chain_asset_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'chain',
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
          indexName: 'asset_quote_cache_expires_idx',
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
      name: 'budget',
      dartName: 'Budget',
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
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'currencyCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'displayCurrencyCode',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'ownerId',
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
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'budget_owner_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ownerId',
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
          name: 'budgetId',
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
          name: 'allocationData',
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
          columns: ['budgetId'],
          referenceTable: 'budget',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'budget_template_budget_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'budgetId',
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
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'budgetId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'sortOrder',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'isHidden',
          columnType: _isp.ColumnType.boolean,
          isNullable: true,
          dartType: 'bool?',
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
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'category_fk_0',
          columns: ['budgetId'],
          referenceTable: 'budget',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'category_budget_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'budgetId',
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
      foreignKeys: [],
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
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'categoryId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'budgetedAmountCents',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'spentAmountCents',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'currencyCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sortOrder',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
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
          name: 'isHidden',
          columnType: _isp.ColumnType.boolean,
          isNullable: true,
          dartType: 'bool?',
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
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'envelope_fk_0',
          columns: ['categoryId'],
          referenceTable: 'category',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'envelope_category_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'categoryId',
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
          name: 'envelopeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'goalType',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'targetAmountCents',
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
          name: 'monthlyFundingCents',
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
          columns: ['envelopeId'],
          referenceTable: 'envelope',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'envelope_goal_envelope_idx',
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
      name: 'fx_rate_entry',
      dartName: 'FxRateEntry',
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
          name: 'snapshotId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'currencyCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'rate',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
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
          constraintName: 'fx_rate_entry_fk_0',
          columns: ['snapshotId'],
          referenceTable: 'fx_rate_snapshot',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'fx_rate_entry_snapshot_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'snapshotId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'fx_rate_entry_snapshot_currency_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'snapshotId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'currencyCode',
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
      name: 'fx_rate_snapshot',
      dartName: 'FxRateSnapshot',
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
          name: 'provider',
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
          name: 'fetchedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'isLatest',
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
          indexName: 'fx_rate_snapshot_latest_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'provider',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'baseCurrencyCode',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'isLatest',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'fx_rate_snapshot_fetched_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'provider',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'baseCurrencyCode',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'fetchedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'fx_rate_snapshot_provider_base_time_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'provider',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'baseCurrencyCode',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'fetchedAt',
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
          onDelete: _isp.ForeignKeyAction.noAction,
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
          name: 'envelopeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'budgetId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'year',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'month',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'allocatedCents',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'carryoverCents',
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
          columns: ['envelopeId'],
          referenceTable: 'envelope',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'monthly_allocation_fk_1',
          columns: ['budgetId'],
          referenceTable: 'budget',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'monthly_allocation_envelope_idx',
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
          indexName: 'monthly_allocation_budget_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'budgetId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'monthly_allocation_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'envelopeId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'year',
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
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'budgetId',
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
          constraintName: 'payee_fk_0',
          columns: ['budgetId'],
          referenceTable: 'budget',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'payee_budget_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'budgetId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'payee_name_budget_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'budgetId',
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
          name: 'budgetId',
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
          name: 'accessToken',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'institutionName',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'institutionId',
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
        _isp.ColumnDefinition(
          name: 'lastSyncedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'plaid_connection_fk_0',
          columns: ['budgetId'],
          referenceTable: 'budget',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'plaid_connection_budget_item_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'budgetId',
            ),
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
          indexName: 'plaid_connection_budget_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'budgetId',
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
          name: 'description',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'amountCents',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'currencyCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'envelopeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'budgetId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'accountId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'payeeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'frequency',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'nextOccurrence',
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
          columns: ['envelopeId'],
          referenceTable: 'envelope',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'recurring_transaction_fk_1',
          columns: ['budgetId'],
          referenceTable: 'budget',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'recurring_transaction_fk_2',
          columns: ['accountId'],
          referenceTable: 'account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'recurring_transaction_fk_3',
          columns: ['payeeId'],
          referenceTable: 'payee',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'recurring_transaction_budget_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'budgetId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'recurring_transaction_next_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'nextOccurrence',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'recurring_transaction_active_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'budgetId',
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
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'solana_wallet',
      dartName: 'SolanaWallet',
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
          name: 'budgetId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'address',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'label',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'cluster',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'lastSignature',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'lastSyncedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'syncStatus',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
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
          constraintName: 'solana_wallet_fk_0',
          columns: ['accountId'],
          referenceTable: 'account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'solana_wallet_fk_1',
          columns: ['budgetId'],
          referenceTable: 'budget',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'solana_wallet_account_unique',
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
          indexName: 'solana_wallet_budget_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'budgetId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'solana_wallet_address_idx',
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
      name: 'solana_wallet_holding',
      dartName: 'SolanaWalletHolding',
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
          name: 'budgetId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
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
          name: 'balanceRaw',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'balanceUi',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'isNft',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'priceCurrency',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'pricePerToken',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'totalValue',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'estimatedCostBasis',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'estimatedUnrealizedPnl',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'estimatedUnrealizedPnlPercent',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'estimatedRealizedPnl',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'pnlCurrency',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'pnlAsOf',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'priceSource',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'priceQuality',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'priceConfidence',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'isPriceStale',
          columnType: _isp.ColumnType.boolean,
          isNullable: true,
          dartType: 'bool?',
        ),
        _isp.ColumnDefinition(
          name: 'priceAsOf',
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
          constraintName: 'solana_wallet_holding_fk_0',
          columns: ['walletId'],
          referenceTable: 'solana_wallet',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'solana_wallet_holding_fk_1',
          columns: ['budgetId'],
          referenceTable: 'budget',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'solana_wallet_holding_wallet_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'walletId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'solana_wallet_holding_budget_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'budgetId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'solana_wallet_holding_asset_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'assetId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'solana_wallet_holding_wallet_asset_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'walletId',
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
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'solana_wallet_transaction',
      dartName: 'SolanaWalletTransaction',
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
          name: 'budgetId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
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
          dartType: 'String?',
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
          name: 'estimatedCostBasis',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'estimatedProceeds',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'estimatedRealizedPnl',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'pnlCurrency',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'taxYear',
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
          name: 'tagsCsv',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
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
          constraintName: 'solana_wallet_transaction_fk_0',
          columns: ['walletId'],
          referenceTable: 'solana_wallet',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'solana_wallet_transaction_fk_1',
          columns: ['budgetId'],
          referenceTable: 'budget',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'solana_wallet_tx_wallet_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'walletId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'solana_wallet_tx_budget_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'budgetId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'solana_wallet_tx_signature_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'signature',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'solana_wallet_tx_wallet_signature_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'walletId',
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
          name: 'budgetId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'jurisdiction',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'entityKind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'profileJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'linkedBudgetId',
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
          columns: ['budgetId'],
          referenceTable: 'budget',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'tax_profile_budget_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'budgetId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'tax_profile_linked_budget_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'linkedBudgetId',
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
          name: 'description',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'amountCents',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'currencyCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'envelopeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'budgetId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'accountId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'payeeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'transactionDate',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'transferPairId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'parentTransactionId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'memo',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'cleared',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'reconciled',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'flagColor',
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
          name: 'businessUsePercent',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'salesTaxCents',
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
          constraintName: 'transaction_fk_0',
          columns: ['envelopeId'],
          referenceTable: 'envelope',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'transaction_fk_1',
          columns: ['budgetId'],
          referenceTable: 'budget',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'transaction_fk_2',
          columns: ['accountId'],
          referenceTable: 'account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'transaction_fk_3',
          columns: ['payeeId'],
          referenceTable: 'payee',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'transaction_envelope_idx',
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
          indexName: 'transaction_budget_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'budgetId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'transaction_account_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'accountId',
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
          indexName: 'transaction_date_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'transactionDate',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'transaction_parent_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'parentTransactionId',
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
          name: 'budgetId',
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
          name: 'targetEnvelopeId',
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
          columns: ['budgetId'],
          referenceTable: 'budget',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'transaction_rule_fk_1',
          columns: ['payeeId'],
          referenceTable: 'payee',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'transaction_rule_fk_2',
          columns: ['targetEnvelopeId'],
          referenceTable: 'envelope',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'transaction_rule_budget_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'budgetId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'transaction_rule_payee_budget_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'budgetId',
            ),
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
      name: 'wallet_connection',
      dartName: 'WalletConnection',
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
          name: 'budgetId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'chain',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'address',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'label',
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
        _isp.ColumnDefinition(
          name: 'lastSyncedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'syncStatus',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'lastError',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'wallet_connection_fk_0',
          columns: ['budgetId'],
          referenceTable: 'budget',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'wallet_connection_budget_chain_address_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'budgetId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'chain',
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
          indexName: 'wallet_connection_budget_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'budgetId',
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
          name: 'walletConnectionId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'chain',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
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
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'decimals',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'quantityBaseUnits',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'quantityDisplay',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'usdPrice',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'usdValue',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'lastSyncedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'wallet_holding_fk_0',
          columns: ['walletConnectionId'],
          referenceTable: 'wallet_connection',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'wallet_holding_connection_asset_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'walletConnectionId',
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
          indexName: 'wallet_holding_connection_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'walletConnectionId',
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
    if (t == _iq2w1sa5.Entitlement) {
      return _iq2w1sa5.Entitlement.fromJson(data) as T;
    }
    if (t == _ipnf4x0i.EntitlementSource) {
      return _ipnf4x0i.EntitlementSource.fromJson(data) as T;
    }
    if (t == _imqwzx9j.EntitlementStatus) {
      return _imqwzx9j.EntitlementStatus.fromJson(data) as T;
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
    if (t == _is.getType<_iz2jf14v.Account?>()) {
      return (data != null ? _iz2jf14v.Account.fromJson(data) : null) as T;
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
    if (t == _is.getType<_i01fne9j.BudgetTemplate?>()) {
      return (data != null ? _i01fne9j.BudgetTemplate.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_idtyoogy.Budget?>()) {
      return (data != null ? _idtyoogy.Budget.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iwxpkdmg.Category?>()) {
      return (data != null ? _iwxpkdmg.Category.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ifl4yivq.EnvelopeGoal?>()) {
      return (data != null ? _ifl4yivq.EnvelopeGoal.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ikt21dfw.Envelope?>()) {
      return (data != null ? _ikt21dfw.Envelope.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i8cxakqz.FxLatestSnapshot?>()) {
      return (data != null ? _i8cxakqz.FxLatestSnapshot.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i41ek9pv.FxRateEntry?>()) {
      return (data != null ? _i41ek9pv.FxRateEntry.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i15udi7x.FxRateQuote?>()) {
      return (data != null ? _i15udi7x.FxRateQuote.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i4xgo4ij.FxRateSnapshot?>()) {
      return (data != null ? _i4xgo4ij.FxRateSnapshot.fromJson(data) : null)
          as T;
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
    if (t == _is.getType<_iotf4y4d.SolanaWallet?>()) {
      return (data != null ? _iotf4y4d.SolanaWallet.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ivqf8i64.SolanaWalletHolding?>()) {
      return (data != null
              ? _ivqf8i64.SolanaWalletHolding.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ir1c2di9.SolanaWalletSyncResult?>()) {
      return (data != null
              ? _ir1c2di9.SolanaWalletSyncResult.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ijmvodfo.SolanaWalletTaxYearSummary?>()) {
      return (data != null
              ? _ijmvodfo.SolanaWalletTaxYearSummary.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iwwk92r1.SolanaWalletTransaction?>()) {
      return (data != null
              ? _iwwk92r1.SolanaWalletTransaction.fromJson(data)
              : null)
          as T;
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
    if (t == _is.getType<_i6dj6ji0.TransactionRule?>()) {
      return (data != null ? _i6dj6ji0.TransactionRule.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_isp6bezg.ImportRow?>()) {
      return (data != null ? _isp6bezg.ImportRow.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i0jd5x9z.SplitItem?>()) {
      return (data != null ? _i0jd5x9z.SplitItem.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iqhl4hru.Transaction?>()) {
      return (data != null ? _iqhl4hru.Transaction.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i2gu4pwf.AssetQuoteCache?>()) {
      return (data != null ? _i2gu4pwf.AssetQuoteCache.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_igiy3v19.WalletConnectResult?>()) {
      return (data != null
              ? _igiy3v19.WalletConnectResult.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i9uqpb1b.WalletConnection?>()) {
      return (data != null ? _i9uqpb1b.WalletConnection.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iqqppnaa.WalletHolding?>()) {
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
    if (t == List<_i3fh9aci.Account>) {
      return (data as List)
              .map((e) => deserialize<_i3fh9aci.Account>(e))
              .toList()
          as T;
    }
    if (t == List<_ihbdj8p6.BudgetTemplate>) {
      return (data as List)
              .map((e) => deserialize<_ihbdj8p6.BudgetTemplate>(e))
              .toList()
          as T;
    }
    if (t == List<_i01zjgtu.MonthlyAllocation>) {
      return (data as List)
              .map((e) => deserialize<_i01zjgtu.MonthlyAllocation>(e))
              .toList()
          as T;
    }
    if (t == List<_ihk6o4ea.Budget>) {
      return (data as List)
              .map((e) => deserialize<_ihk6o4ea.Budget>(e))
              .toList()
          as T;
    }
    if (t == List<_iwlneq7u.Category>) {
      return (data as List)
              .map((e) => deserialize<_iwlneq7u.Category>(e))
              .toList()
          as T;
    }
    if (t == List<_is.UuidValue>) {
      return (data as List).map((e) => deserialize<_is.UuidValue>(e)).toList()
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
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_izagyfe8.Institution>) {
      return (data as List)
              .map((e) => deserialize<_izagyfe8.Institution>(e))
              .toList()
          as T;
    }
    if (t == List<_i2xhh3nq.Payee>) {
      return (data as List).map((e) => deserialize<_i2xhh3nq.Payee>(e)).toList()
          as T;
    }
    if (t == List<_i6lbncsb.RecurringTransaction>) {
      return (data as List)
              .map((e) => deserialize<_i6lbncsb.RecurringTransaction>(e))
              .toList()
          as T;
    }
    if (t == List<_ieq0zunc.SolanaWallet>) {
      return (data as List)
              .map((e) => deserialize<_ieq0zunc.SolanaWallet>(e))
              .toList()
          as T;
    }
    if (t == List<_imyeu1oa.SolanaWalletTransaction>) {
      return (data as List)
              .map((e) => deserialize<_imyeu1oa.SolanaWalletTransaction>(e))
              .toList()
          as T;
    }
    if (t == List<_iry3zuft.SolanaWalletHolding>) {
      return (data as List)
              .map((e) => deserialize<_iry3zuft.SolanaWalletHolding>(e))
              .toList()
          as T;
    }
    if (t == List<_ik6g6ols.SolanaWalletTaxYearSummary>) {
      return (data as List)
              .map((e) => deserialize<_ik6g6ols.SolanaWalletTaxYearSummary>(e))
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
    if (t == List<_ioie3qid.Transaction>) {
      return (data as List)
              .map((e) => deserialize<_ioie3qid.Transaction>(e))
              .toList()
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<_ii8zyh2l.SplitItem>) {
      return (data as List)
              .map((e) => deserialize<_ii8zyh2l.SplitItem>(e))
              .toList()
          as T;
    }
    if (t == List<_iyod81ld.ImportRow>) {
      return (data as List)
              .map((e) => deserialize<_iyod81ld.ImportRow>(e))
              .toList()
          as T;
    }
    if (t == List<_icu5m6lt.WalletHolding>) {
      return (data as List)
              .map((e) => deserialize<_icu5m6lt.WalletHolding>(e))
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
      } on _is.DeserializationTypeNotFoundException catch (_) {}
    }

    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iz2jf14v.Account => 'Account',
      _iq2w1sa5.Entitlement => 'Entitlement',
      _ipnf4x0i.EntitlementSource => 'EntitlementSource',
      _imqwzx9j.EntitlementStatus => 'EntitlementStatus',
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
      case _iq2w1sa5.Entitlement():
        return 'Entitlement';
      case _ipnf4x0i.EntitlementSource():
        return 'EntitlementSource';
      case _imqwzx9j.EntitlementStatus():
        return 'EntitlementStatus';
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
    if (dataClassName == 'Entitlement') {
      return deserialize<_iq2w1sa5.Entitlement>(data['data']);
    }
    if (dataClassName == 'EntitlementSource') {
      return deserialize<_ipnf4x0i.EntitlementSource>(data['data']);
    }
    if (dataClassName == 'EntitlementStatus') {
      return deserialize<_imqwzx9j.EntitlementStatus>(data['data']);
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
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _iz2jf14v.Account:
        return _iz2jf14v.Account.t;
      case _iq2w1sa5.Entitlement:
        return _iq2w1sa5.Entitlement.t;
      case _i01fne9j.BudgetTemplate:
        return _i01fne9j.BudgetTemplate.t;
      case _idtyoogy.Budget:
        return _idtyoogy.Budget.t;
      case _iwxpkdmg.Category:
        return _iwxpkdmg.Category.t;
      case _ifl4yivq.EnvelopeGoal:
        return _ifl4yivq.EnvelopeGoal.t;
      case _ikt21dfw.Envelope:
        return _ikt21dfw.Envelope.t;
      case _i41ek9pv.FxRateEntry:
        return _i41ek9pv.FxRateEntry.t;
      case _i4xgo4ij.FxRateSnapshot:
        return _i4xgo4ij.FxRateSnapshot.t;
      case _ikgmcjq7.Institution:
        return _ikgmcjq7.Institution.t;
      case _iclizrec.InstitutionLocation:
        return _iclizrec.InstitutionLocation.t;
      case _igdgld5u.MonthlyAllocation:
        return _igdgld5u.MonthlyAllocation.t;
      case _ignezpci.Payee:
        return _ignezpci.Payee.t;
      case _i1vmvtrm.PlaidConnection:
        return _i1vmvtrm.PlaidConnection.t;
      case _i9is7zb8.RecurringTransaction:
        return _i9is7zb8.RecurringTransaction.t;
      case _iotf4y4d.SolanaWallet:
        return _iotf4y4d.SolanaWallet.t;
      case _ivqf8i64.SolanaWalletHolding:
        return _ivqf8i64.SolanaWalletHolding.t;
      case _iwwk92r1.SolanaWalletTransaction:
        return _iwwk92r1.SolanaWalletTransaction.t;
      case _i20z9jax.TaxProfileRecord:
        return _i20z9jax.TaxProfileRecord.t;
      case _i6dj6ji0.TransactionRule:
        return _i6dj6ji0.TransactionRule.t;
      case _iqhl4hru.Transaction:
        return _iqhl4hru.Transaction.t;
      case _i2gu4pwf.AssetQuoteCache:
        return _i2gu4pwf.AssetQuoteCache.t;
      case _i9uqpb1b.WalletConnection:
        return _i9uqpb1b.WalletConnection.t;
      case _iqqppnaa.WalletHolding:
        return _iqqppnaa.WalletHolding.t;
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
