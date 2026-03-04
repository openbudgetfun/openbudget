/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'accounts/account.dart' as _i2;
import 'auth/solana_wallet_auth_account.dart' as _i3;
import 'auth/solana_wallet_auth_challenge.dart' as _i4;
import 'auth/solana_wallet_auth_challenge_response.dart' as _i5;
import 'budget_templates/budget_template.dart' as _i6;
import 'budgets/budget.dart' as _i7;
import 'categories/category.dart' as _i8;
import 'envelope_goals/envelope_goal.dart' as _i9;
import 'envelopes/envelope.dart' as _i10;
import 'fx_rates/fx_latest_snapshot.dart' as _i11;
import 'fx_rates/fx_rate_entry.dart' as _i12;
import 'fx_rates/fx_rate_quote.dart' as _i13;
import 'fx_rates/fx_rate_snapshot.dart' as _i14;
import 'institutions/institution.dart' as _i15;
import 'institutions/institution_location.dart' as _i16;
import 'monthly_allocations/monthly_allocation.dart' as _i17;
import 'payees/payee.dart' as _i18;
import 'plaid/plaid_connection.dart' as _i19;
import 'recurring_transactions/recurring_transaction.dart' as _i20;
import 'solana_wallets/solana_wallet.dart' as _i21;
import 'solana_wallets/solana_wallet_holding.dart' as _i22;
import 'solana_wallets/solana_wallet_sync_result.dart' as _i23;
import 'solana_wallets/solana_wallet_tax_year_summary.dart' as _i24;
import 'solana_wallets/solana_wallet_transaction.dart' as _i25;
import 'transaction_rules/transaction_rule.dart' as _i26;
import 'transactions/import_row.dart' as _i27;
import 'transactions/split_item.dart' as _i28;
import 'transactions/transaction.dart' as _i29;
import 'wallets/asset_quote_cache.dart' as _i30;
import 'wallets/wallet_connect_result.dart' as _i31;
import 'wallets/wallet_connection.dart' as _i32;
import 'wallets/wallet_holding.dart' as _i33;
import 'package:openbudget_client/src/protocol/accounts/account.dart' as _i34;
import 'package:openbudget_client/src/protocol/budget_templates/budget_template.dart'
    as _i35;
import 'package:openbudget_client/src/protocol/monthly_allocations/monthly_allocation.dart'
    as _i36;
import 'package:openbudget_client/src/protocol/budgets/budget.dart' as _i37;
import 'package:openbudget_client/src/protocol/categories/category.dart'
    as _i38;
import 'package:openbudget_client/src/protocol/envelope_goals/envelope_goal.dart'
    as _i39;
import 'package:openbudget_client/src/protocol/envelopes/envelope.dart' as _i40;
import 'package:openbudget_client/src/protocol/institutions/institution.dart'
    as _i41;
import 'package:openbudget_client/src/protocol/payees/payee.dart' as _i42;
import 'package:openbudget_client/src/protocol/recurring_transactions/recurring_transaction.dart'
    as _i43;
import 'package:openbudget_client/src/protocol/solana_wallets/solana_wallet.dart'
    as _i44;
import 'package:openbudget_client/src/protocol/solana_wallets/solana_wallet_transaction.dart'
    as _i45;
import 'package:openbudget_client/src/protocol/solana_wallets/solana_wallet_holding.dart'
    as _i46;
import 'package:openbudget_client/src/protocol/solana_wallets/solana_wallet_tax_year_summary.dart'
    as _i47;
import 'package:openbudget_client/src/protocol/transaction_rules/transaction_rule.dart'
    as _i48;
import 'package:openbudget_client/src/protocol/transactions/transaction.dart'
    as _i49;
import 'package:openbudget_client/src/protocol/transactions/split_item.dart'
    as _i50;
import 'package:openbudget_client/src/protocol/transactions/import_row.dart'
    as _i51;
import 'package:openbudget_client/src/protocol/wallets/wallet_holding.dart'
    as _i52;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i53;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i54;
export 'accounts/account.dart';
export 'auth/solana_wallet_auth_account.dart';
export 'auth/solana_wallet_auth_challenge.dart';
export 'auth/solana_wallet_auth_challenge_response.dart';
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
export 'transaction_rules/transaction_rule.dart';
export 'transactions/import_row.dart';
export 'transactions/split_item.dart';
export 'transactions/transaction.dart';
export 'wallets/asset_quote_cache.dart';
export 'wallets/wallet_connect_result.dart';
export 'wallets/wallet_connection.dart';
export 'wallets/wallet_holding.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(dynamic data, [Type? t]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.Account) {
      return _i2.Account.fromJson(data) as T;
    }
    if (t == _i3.SolanaWalletAuthAccount) {
      return _i3.SolanaWalletAuthAccount.fromJson(data) as T;
    }
    if (t == _i4.SolanaWalletAuthChallenge) {
      return _i4.SolanaWalletAuthChallenge.fromJson(data) as T;
    }
    if (t == _i5.SolanaWalletAuthChallengeResponse) {
      return _i5.SolanaWalletAuthChallengeResponse.fromJson(data) as T;
    }
    if (t == _i6.BudgetTemplate) {
      return _i6.BudgetTemplate.fromJson(data) as T;
    }
    if (t == _i7.Budget) {
      return _i7.Budget.fromJson(data) as T;
    }
    if (t == _i8.Category) {
      return _i8.Category.fromJson(data) as T;
    }
    if (t == _i9.EnvelopeGoal) {
      return _i9.EnvelopeGoal.fromJson(data) as T;
    }
    if (t == _i10.Envelope) {
      return _i10.Envelope.fromJson(data) as T;
    }
    if (t == _i11.FxLatestSnapshot) {
      return _i11.FxLatestSnapshot.fromJson(data) as T;
    }
    if (t == _i12.FxRateEntry) {
      return _i12.FxRateEntry.fromJson(data) as T;
    }
    if (t == _i13.FxRateQuote) {
      return _i13.FxRateQuote.fromJson(data) as T;
    }
    if (t == _i14.FxRateSnapshot) {
      return _i14.FxRateSnapshot.fromJson(data) as T;
    }
    if (t == _i15.Institution) {
      return _i15.Institution.fromJson(data) as T;
    }
    if (t == _i16.InstitutionLocation) {
      return _i16.InstitutionLocation.fromJson(data) as T;
    }
    if (t == _i17.MonthlyAllocation) {
      return _i17.MonthlyAllocation.fromJson(data) as T;
    }
    if (t == _i18.Payee) {
      return _i18.Payee.fromJson(data) as T;
    }
    if (t == _i19.PlaidConnection) {
      return _i19.PlaidConnection.fromJson(data) as T;
    }
    if (t == _i20.RecurringTransaction) {
      return _i20.RecurringTransaction.fromJson(data) as T;
    }
    if (t == _i21.SolanaWallet) {
      return _i21.SolanaWallet.fromJson(data) as T;
    }
    if (t == _i22.SolanaWalletHolding) {
      return _i22.SolanaWalletHolding.fromJson(data) as T;
    }
    if (t == _i23.SolanaWalletSyncResult) {
      return _i23.SolanaWalletSyncResult.fromJson(data) as T;
    }
    if (t == _i24.SolanaWalletTaxYearSummary) {
      return _i24.SolanaWalletTaxYearSummary.fromJson(data) as T;
    }
    if (t == _i25.SolanaWalletTransaction) {
      return _i25.SolanaWalletTransaction.fromJson(data) as T;
    }
    if (t == _i26.TransactionRule) {
      return _i26.TransactionRule.fromJson(data) as T;
    }
    if (t == _i27.ImportRow) {
      return _i27.ImportRow.fromJson(data) as T;
    }
    if (t == _i28.SplitItem) {
      return _i28.SplitItem.fromJson(data) as T;
    }
    if (t == _i29.Transaction) {
      return _i29.Transaction.fromJson(data) as T;
    }
    if (t == _i30.AssetQuoteCache) {
      return _i30.AssetQuoteCache.fromJson(data) as T;
    }
    if (t == _i31.WalletConnectResult) {
      return _i31.WalletConnectResult.fromJson(data) as T;
    }
    if (t == _i32.WalletConnection) {
      return _i32.WalletConnection.fromJson(data) as T;
    }
    if (t == _i33.WalletHolding) {
      return _i33.WalletHolding.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Account?>()) {
      return (data != null ? _i2.Account.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.SolanaWalletAuthAccount?>()) {
      return (data != null ? _i3.SolanaWalletAuthAccount.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i4.SolanaWalletAuthChallenge?>()) {
      return (data != null
              ? _i4.SolanaWalletAuthChallenge.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i5.SolanaWalletAuthChallengeResponse?>()) {
      return (data != null
              ? _i5.SolanaWalletAuthChallengeResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i6.BudgetTemplate?>()) {
      return (data != null ? _i6.BudgetTemplate.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.Budget?>()) {
      return (data != null ? _i7.Budget.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.Category?>()) {
      return (data != null ? _i8.Category.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.EnvelopeGoal?>()) {
      return (data != null ? _i9.EnvelopeGoal.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.Envelope?>()) {
      return (data != null ? _i10.Envelope.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.FxLatestSnapshot?>()) {
      return (data != null ? _i11.FxLatestSnapshot.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.FxRateEntry?>()) {
      return (data != null ? _i12.FxRateEntry.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.FxRateQuote?>()) {
      return (data != null ? _i13.FxRateQuote.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.FxRateSnapshot?>()) {
      return (data != null ? _i14.FxRateSnapshot.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.Institution?>()) {
      return (data != null ? _i15.Institution.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.InstitutionLocation?>()) {
      return (data != null ? _i16.InstitutionLocation.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i17.MonthlyAllocation?>()) {
      return (data != null ? _i17.MonthlyAllocation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.Payee?>()) {
      return (data != null ? _i18.Payee.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.PlaidConnection?>()) {
      return (data != null ? _i19.PlaidConnection.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.RecurringTransaction?>()) {
      return (data != null ? _i20.RecurringTransaction.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i21.SolanaWallet?>()) {
      return (data != null ? _i21.SolanaWallet.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.SolanaWalletHolding?>()) {
      return (data != null ? _i22.SolanaWalletHolding.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i23.SolanaWalletSyncResult?>()) {
      return (data != null ? _i23.SolanaWalletSyncResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i24.SolanaWalletTaxYearSummary?>()) {
      return (data != null
              ? _i24.SolanaWalletTaxYearSummary.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i25.SolanaWalletTransaction?>()) {
      return (data != null ? _i25.SolanaWalletTransaction.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i26.TransactionRule?>()) {
      return (data != null ? _i26.TransactionRule.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.ImportRow?>()) {
      return (data != null ? _i27.ImportRow.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i28.SplitItem?>()) {
      return (data != null ? _i28.SplitItem.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i29.Transaction?>()) {
      return (data != null ? _i29.Transaction.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i30.AssetQuoteCache?>()) {
      return (data != null ? _i30.AssetQuoteCache.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.WalletConnectResult?>()) {
      return (data != null ? _i31.WalletConnectResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i32.WalletConnection?>()) {
      return (data != null ? _i32.WalletConnection.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.WalletHolding?>()) {
      return (data != null ? _i33.WalletHolding.fromJson(data) : null) as T;
    }
    if (t == List<_i13.FxRateQuote>) {
      return (data as List)
              .map((e) => deserialize<_i13.FxRateQuote>(e))
              .toList()
          as T;
    }
    if (t == List<_i33.WalletHolding>) {
      return (data as List)
              .map((e) => deserialize<_i33.WalletHolding>(e))
              .toList()
          as T;
    }
    if (t == List<_i34.Account>) {
      return (data as List).map((e) => deserialize<_i34.Account>(e)).toList()
          as T;
    }
    if (t == List<_i35.BudgetTemplate>) {
      return (data as List)
              .map((e) => deserialize<_i35.BudgetTemplate>(e))
              .toList()
          as T;
    }
    if (t == List<_i36.MonthlyAllocation>) {
      return (data as List)
              .map((e) => deserialize<_i36.MonthlyAllocation>(e))
              .toList()
          as T;
    }
    if (t == List<_i37.Budget>) {
      return (data as List).map((e) => deserialize<_i37.Budget>(e)).toList()
          as T;
    }
    if (t == List<_i38.Category>) {
      return (data as List).map((e) => deserialize<_i38.Category>(e)).toList()
          as T;
    }
    if (t == List<_i1.UuidValue>) {
      return (data as List).map((e) => deserialize<_i1.UuidValue>(e)).toList()
          as T;
    }
    if (t == List<_i39.EnvelopeGoal>) {
      return (data as List)
              .map((e) => deserialize<_i39.EnvelopeGoal>(e))
              .toList()
          as T;
    }
    if (t == List<_i40.Envelope>) {
      return (data as List).map((e) => deserialize<_i40.Envelope>(e)).toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i41.Institution>) {
      return (data as List)
              .map((e) => deserialize<_i41.Institution>(e))
              .toList()
          as T;
    }
    if (t == List<_i42.Payee>) {
      return (data as List).map((e) => deserialize<_i42.Payee>(e)).toList()
          as T;
    }
    if (t == List<_i43.RecurringTransaction>) {
      return (data as List)
              .map((e) => deserialize<_i43.RecurringTransaction>(e))
              .toList()
          as T;
    }
    if (t == List<_i44.SolanaWallet>) {
      return (data as List)
              .map((e) => deserialize<_i44.SolanaWallet>(e))
              .toList()
          as T;
    }
    if (t == List<_i45.SolanaWalletTransaction>) {
      return (data as List)
              .map((e) => deserialize<_i45.SolanaWalletTransaction>(e))
              .toList()
          as T;
    }
    if (t == List<_i46.SolanaWalletHolding>) {
      return (data as List)
              .map((e) => deserialize<_i46.SolanaWalletHolding>(e))
              .toList()
          as T;
    }
    if (t == List<_i47.SolanaWalletTaxYearSummary>) {
      return (data as List)
              .map((e) => deserialize<_i47.SolanaWalletTaxYearSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_i48.TransactionRule>) {
      return (data as List)
              .map((e) => deserialize<_i48.TransactionRule>(e))
              .toList()
          as T;
    }
    if (t == List<_i49.Transaction>) {
      return (data as List)
              .map((e) => deserialize<_i49.Transaction>(e))
              .toList()
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<_i50.SplitItem>) {
      return (data as List).map((e) => deserialize<_i50.SplitItem>(e)).toList()
          as T;
    }
    if (t == List<_i51.ImportRow>) {
      return (data as List).map((e) => deserialize<_i51.ImportRow>(e)).toList()
          as T;
    }
    if (t == List<_i52.WalletHolding>) {
      return (data as List)
              .map((e) => deserialize<_i52.WalletHolding>(e))
              .toList()
          as T;
    }
    try {
      return _i53.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i54.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.Account => 'Account',
      _i3.SolanaWalletAuthAccount => 'SolanaWalletAuthAccount',
      _i4.SolanaWalletAuthChallenge => 'SolanaWalletAuthChallenge',
      _i5.SolanaWalletAuthChallengeResponse =>
        'SolanaWalletAuthChallengeResponse',
      _i6.BudgetTemplate => 'BudgetTemplate',
      _i7.Budget => 'Budget',
      _i8.Category => 'Category',
      _i9.EnvelopeGoal => 'EnvelopeGoal',
      _i10.Envelope => 'Envelope',
      _i11.FxLatestSnapshot => 'FxLatestSnapshot',
      _i12.FxRateEntry => 'FxRateEntry',
      _i13.FxRateQuote => 'FxRateQuote',
      _i14.FxRateSnapshot => 'FxRateSnapshot',
      _i15.Institution => 'Institution',
      _i16.InstitutionLocation => 'InstitutionLocation',
      _i17.MonthlyAllocation => 'MonthlyAllocation',
      _i18.Payee => 'Payee',
      _i19.PlaidConnection => 'PlaidConnection',
      _i20.RecurringTransaction => 'RecurringTransaction',
      _i21.SolanaWallet => 'SolanaWallet',
      _i22.SolanaWalletHolding => 'SolanaWalletHolding',
      _i23.SolanaWalletSyncResult => 'SolanaWalletSyncResult',
      _i24.SolanaWalletTaxYearSummary => 'SolanaWalletTaxYearSummary',
      _i25.SolanaWalletTransaction => 'SolanaWalletTransaction',
      _i26.TransactionRule => 'TransactionRule',
      _i27.ImportRow => 'ImportRow',
      _i28.SplitItem => 'SplitItem',
      _i29.Transaction => 'Transaction',
      _i30.AssetQuoteCache => 'AssetQuoteCache',
      _i31.WalletConnectResult => 'WalletConnectResult',
      _i32.WalletConnection => 'WalletConnection',
      _i33.WalletHolding => 'WalletHolding',
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
      case _i2.Account():
        return 'Account';
      case _i3.SolanaWalletAuthAccount():
        return 'SolanaWalletAuthAccount';
      case _i4.SolanaWalletAuthChallenge():
        return 'SolanaWalletAuthChallenge';
      case _i5.SolanaWalletAuthChallengeResponse():
        return 'SolanaWalletAuthChallengeResponse';
      case _i6.BudgetTemplate():
        return 'BudgetTemplate';
      case _i7.Budget():
        return 'Budget';
      case _i8.Category():
        return 'Category';
      case _i9.EnvelopeGoal():
        return 'EnvelopeGoal';
      case _i10.Envelope():
        return 'Envelope';
      case _i11.FxLatestSnapshot():
        return 'FxLatestSnapshot';
      case _i12.FxRateEntry():
        return 'FxRateEntry';
      case _i13.FxRateQuote():
        return 'FxRateQuote';
      case _i14.FxRateSnapshot():
        return 'FxRateSnapshot';
      case _i15.Institution():
        return 'Institution';
      case _i16.InstitutionLocation():
        return 'InstitutionLocation';
      case _i17.MonthlyAllocation():
        return 'MonthlyAllocation';
      case _i18.Payee():
        return 'Payee';
      case _i19.PlaidConnection():
        return 'PlaidConnection';
      case _i20.RecurringTransaction():
        return 'RecurringTransaction';
      case _i21.SolanaWallet():
        return 'SolanaWallet';
      case _i22.SolanaWalletHolding():
        return 'SolanaWalletHolding';
      case _i23.SolanaWalletSyncResult():
        return 'SolanaWalletSyncResult';
      case _i24.SolanaWalletTaxYearSummary():
        return 'SolanaWalletTaxYearSummary';
      case _i25.SolanaWalletTransaction():
        return 'SolanaWalletTransaction';
      case _i26.TransactionRule():
        return 'TransactionRule';
      case _i27.ImportRow():
        return 'ImportRow';
      case _i28.SplitItem():
        return 'SplitItem';
      case _i29.Transaction():
        return 'Transaction';
      case _i30.AssetQuoteCache():
        return 'AssetQuoteCache';
      case _i31.WalletConnectResult():
        return 'WalletConnectResult';
      case _i32.WalletConnection():
        return 'WalletConnection';
      case _i33.WalletHolding():
        return 'WalletHolding';
    }
    className = _i53.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i54.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
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
      return deserialize<_i2.Account>(data['data']);
    }
    if (dataClassName == 'SolanaWalletAuthAccount') {
      return deserialize<_i3.SolanaWalletAuthAccount>(data['data']);
    }
    if (dataClassName == 'SolanaWalletAuthChallenge') {
      return deserialize<_i4.SolanaWalletAuthChallenge>(data['data']);
    }
    if (dataClassName == 'SolanaWalletAuthChallengeResponse') {
      return deserialize<_i5.SolanaWalletAuthChallengeResponse>(data['data']);
    }
    if (dataClassName == 'BudgetTemplate') {
      return deserialize<_i6.BudgetTemplate>(data['data']);
    }
    if (dataClassName == 'Budget') {
      return deserialize<_i7.Budget>(data['data']);
    }
    if (dataClassName == 'Category') {
      return deserialize<_i8.Category>(data['data']);
    }
    if (dataClassName == 'EnvelopeGoal') {
      return deserialize<_i9.EnvelopeGoal>(data['data']);
    }
    if (dataClassName == 'Envelope') {
      return deserialize<_i10.Envelope>(data['data']);
    }
    if (dataClassName == 'FxLatestSnapshot') {
      return deserialize<_i11.FxLatestSnapshot>(data['data']);
    }
    if (dataClassName == 'FxRateEntry') {
      return deserialize<_i12.FxRateEntry>(data['data']);
    }
    if (dataClassName == 'FxRateQuote') {
      return deserialize<_i13.FxRateQuote>(data['data']);
    }
    if (dataClassName == 'FxRateSnapshot') {
      return deserialize<_i14.FxRateSnapshot>(data['data']);
    }
    if (dataClassName == 'Institution') {
      return deserialize<_i15.Institution>(data['data']);
    }
    if (dataClassName == 'InstitutionLocation') {
      return deserialize<_i16.InstitutionLocation>(data['data']);
    }
    if (dataClassName == 'MonthlyAllocation') {
      return deserialize<_i17.MonthlyAllocation>(data['data']);
    }
    if (dataClassName == 'Payee') {
      return deserialize<_i18.Payee>(data['data']);
    }
    if (dataClassName == 'PlaidConnection') {
      return deserialize<_i19.PlaidConnection>(data['data']);
    }
    if (dataClassName == 'RecurringTransaction') {
      return deserialize<_i20.RecurringTransaction>(data['data']);
    }
    if (dataClassName == 'SolanaWallet') {
      return deserialize<_i21.SolanaWallet>(data['data']);
    }
    if (dataClassName == 'SolanaWalletHolding') {
      return deserialize<_i22.SolanaWalletHolding>(data['data']);
    }
    if (dataClassName == 'SolanaWalletSyncResult') {
      return deserialize<_i23.SolanaWalletSyncResult>(data['data']);
    }
    if (dataClassName == 'SolanaWalletTaxYearSummary') {
      return deserialize<_i24.SolanaWalletTaxYearSummary>(data['data']);
    }
    if (dataClassName == 'SolanaWalletTransaction') {
      return deserialize<_i25.SolanaWalletTransaction>(data['data']);
    }
    if (dataClassName == 'TransactionRule') {
      return deserialize<_i26.TransactionRule>(data['data']);
    }
    if (dataClassName == 'ImportRow') {
      return deserialize<_i27.ImportRow>(data['data']);
    }
    if (dataClassName == 'SplitItem') {
      return deserialize<_i28.SplitItem>(data['data']);
    }
    if (dataClassName == 'Transaction') {
      return deserialize<_i29.Transaction>(data['data']);
    }
    if (dataClassName == 'AssetQuoteCache') {
      return deserialize<_i30.AssetQuoteCache>(data['data']);
    }
    if (dataClassName == 'WalletConnectResult') {
      return deserialize<_i31.WalletConnectResult>(data['data']);
    }
    if (dataClassName == 'WalletConnection') {
      return deserialize<_i32.WalletConnection>(data['data']);
    }
    if (dataClassName == 'WalletHolding') {
      return deserialize<_i33.WalletHolding>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i53.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i54.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

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
      return _i53.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i54.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
