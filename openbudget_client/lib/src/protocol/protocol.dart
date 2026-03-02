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
import 'budget_templates/budget_template.dart' as _i3;
import 'budgets/budget.dart' as _i4;
import 'categories/category.dart' as _i5;
import 'envelope_goals/envelope_goal.dart' as _i6;
import 'envelopes/envelope.dart' as _i7;
import 'fx_rates/fx_latest_snapshot.dart' as _i8;
import 'fx_rates/fx_rate_entry.dart' as _i9;
import 'fx_rates/fx_rate_quote.dart' as _i10;
import 'fx_rates/fx_rate_snapshot.dart' as _i11;
import 'monthly_allocations/monthly_allocation.dart' as _i12;
import 'payees/payee.dart' as _i13;
import 'recurring_transactions/recurring_transaction.dart' as _i14;
import 'solana_wallets/solana_wallet.dart' as _i15;
import 'solana_wallets/solana_wallet_holding.dart' as _i16;
import 'solana_wallets/solana_wallet_sync_result.dart' as _i17;
import 'solana_wallets/solana_wallet_tax_year_summary.dart' as _i18;
import 'solana_wallets/solana_wallet_transaction.dart' as _i19;
import 'transaction_rules/transaction_rule.dart' as _i20;
import 'transactions/import_row.dart' as _i21;
import 'transactions/split_item.dart' as _i22;
import 'transactions/transaction.dart' as _i23;
import 'package:openbudget_client/src/protocol/accounts/account.dart' as _i24;
import 'package:openbudget_client/src/protocol/budget_templates/budget_template.dart'
    as _i25;
import 'package:openbudget_client/src/protocol/monthly_allocations/monthly_allocation.dart'
    as _i26;
import 'package:openbudget_client/src/protocol/budgets/budget.dart' as _i27;
import 'package:openbudget_client/src/protocol/categories/category.dart'
    as _i28;
import 'package:openbudget_client/src/protocol/envelope_goals/envelope_goal.dart'
    as _i29;
import 'package:openbudget_client/src/protocol/envelopes/envelope.dart' as _i30;
import 'package:openbudget_client/src/protocol/payees/payee.dart' as _i31;
import 'package:openbudget_client/src/protocol/recurring_transactions/recurring_transaction.dart'
    as _i32;
import 'package:openbudget_client/src/protocol/solana_wallets/solana_wallet.dart'
    as _i33;
import 'package:openbudget_client/src/protocol/solana_wallets/solana_wallet_transaction.dart'
    as _i34;
import 'package:openbudget_client/src/protocol/solana_wallets/solana_wallet_holding.dart'
    as _i35;
import 'package:openbudget_client/src/protocol/transaction_rules/transaction_rule.dart'
    as _i36;
import 'package:openbudget_client/src/protocol/transactions/transaction.dart'
    as _i37;
import 'package:openbudget_client/src/protocol/transactions/split_item.dart'
    as _i38;
import 'package:openbudget_client/src/protocol/transactions/import_row.dart'
    as _i39;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i40;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i41;
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
export 'monthly_allocations/monthly_allocation.dart';
export 'payees/payee.dart';
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
    if (t == _i3.BudgetTemplate) {
      return _i3.BudgetTemplate.fromJson(data) as T;
    }
    if (t == _i4.Budget) {
      return _i4.Budget.fromJson(data) as T;
    }
    if (t == _i5.Category) {
      return _i5.Category.fromJson(data) as T;
    }
    if (t == _i6.EnvelopeGoal) {
      return _i6.EnvelopeGoal.fromJson(data) as T;
    }
    if (t == _i7.Envelope) {
      return _i7.Envelope.fromJson(data) as T;
    }
    if (t == _i8.FxLatestSnapshot) {
      return _i8.FxLatestSnapshot.fromJson(data) as T;
    }
    if (t == _i9.FxRateEntry) {
      return _i9.FxRateEntry.fromJson(data) as T;
    }
    if (t == _i10.FxRateQuote) {
      return _i10.FxRateQuote.fromJson(data) as T;
    }
    if (t == _i11.FxRateSnapshot) {
      return _i11.FxRateSnapshot.fromJson(data) as T;
    }
    if (t == _i12.MonthlyAllocation) {
      return _i12.MonthlyAllocation.fromJson(data) as T;
    }
    if (t == _i13.Payee) {
      return _i13.Payee.fromJson(data) as T;
    }
    if (t == _i14.RecurringTransaction) {
      return _i14.RecurringTransaction.fromJson(data) as T;
    }
    if (t == _i15.SolanaWallet) {
      return _i15.SolanaWallet.fromJson(data) as T;
    }
    if (t == _i16.SolanaWalletHolding) {
      return _i16.SolanaWalletHolding.fromJson(data) as T;
    }
    if (t == _i17.SolanaWalletSyncResult) {
      return _i17.SolanaWalletSyncResult.fromJson(data) as T;
    }
    if (t == _i18.SolanaWalletTaxYearSummary) {
      return _i18.SolanaWalletTaxYearSummary.fromJson(data) as T;
    }
    if (t == _i19.SolanaWalletTransaction) {
      return _i19.SolanaWalletTransaction.fromJson(data) as T;
    }
    if (t == _i20.TransactionRule) {
      return _i20.TransactionRule.fromJson(data) as T;
    }
    if (t == _i21.ImportRow) {
      return _i21.ImportRow.fromJson(data) as T;
    }
    if (t == _i22.SplitItem) {
      return _i22.SplitItem.fromJson(data) as T;
    }
    if (t == _i23.Transaction) {
      return _i23.Transaction.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Account?>()) {
      return (data != null ? _i2.Account.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.BudgetTemplate?>()) {
      return (data != null ? _i3.BudgetTemplate.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.Budget?>()) {
      return (data != null ? _i4.Budget.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.Category?>()) {
      return (data != null ? _i5.Category.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.EnvelopeGoal?>()) {
      return (data != null ? _i6.EnvelopeGoal.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.Envelope?>()) {
      return (data != null ? _i7.Envelope.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.FxLatestSnapshot?>()) {
      return (data != null ? _i8.FxLatestSnapshot.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.FxRateEntry?>()) {
      return (data != null ? _i9.FxRateEntry.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.FxRateQuote?>()) {
      return (data != null ? _i10.FxRateQuote.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.FxRateSnapshot?>()) {
      return (data != null ? _i11.FxRateSnapshot.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.MonthlyAllocation?>()) {
      return (data != null ? _i12.MonthlyAllocation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.Payee?>()) {
      return (data != null ? _i13.Payee.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.RecurringTransaction?>()) {
      return (data != null ? _i14.RecurringTransaction.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i15.SolanaWallet?>()) {
      return (data != null ? _i15.SolanaWallet.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.SolanaWalletHolding?>()) {
      return (data != null ? _i16.SolanaWalletHolding.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i17.SolanaWalletSyncResult?>()) {
      return (data != null ? _i17.SolanaWalletSyncResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i18.SolanaWalletTaxYearSummary?>()) {
      return (data != null
              ? _i18.SolanaWalletTaxYearSummary.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i19.SolanaWalletTransaction?>()) {
      return (data != null ? _i19.SolanaWalletTransaction.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i20.TransactionRule?>()) {
      return (data != null ? _i20.TransactionRule.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.ImportRow?>()) {
      return (data != null ? _i21.ImportRow.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.SplitItem?>()) {
      return (data != null ? _i22.SplitItem.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.Transaction?>()) {
      return (data != null ? _i23.Transaction.fromJson(data) : null) as T;
    }
    if (t == List<_i10.FxRateQuote>) {
      return (data as List)
              .map((e) => deserialize<_i10.FxRateQuote>(e))
              .toList()
          as T;
    }
    if (t == List<_i24.Account>) {
      return (data as List).map((e) => deserialize<_i24.Account>(e)).toList()
          as T;
    }
    if (t == List<_i25.BudgetTemplate>) {
      return (data as List)
              .map((e) => deserialize<_i25.BudgetTemplate>(e))
              .toList()
          as T;
    }
    if (t == List<_i26.MonthlyAllocation>) {
      return (data as List)
              .map((e) => deserialize<_i26.MonthlyAllocation>(e))
              .toList()
          as T;
    }
    if (t == List<_i27.Budget>) {
      return (data as List).map((e) => deserialize<_i27.Budget>(e)).toList()
          as T;
    }
    if (t == List<_i28.Category>) {
      return (data as List).map((e) => deserialize<_i28.Category>(e)).toList()
          as T;
    }
    if (t == List<_i1.UuidValue>) {
      return (data as List).map((e) => deserialize<_i1.UuidValue>(e)).toList()
          as T;
    }
    if (t == List<_i29.EnvelopeGoal>) {
      return (data as List)
              .map((e) => deserialize<_i29.EnvelopeGoal>(e))
              .toList()
          as T;
    }
    if (t == List<_i30.Envelope>) {
      return (data as List).map((e) => deserialize<_i30.Envelope>(e)).toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i31.Payee>) {
      return (data as List).map((e) => deserialize<_i31.Payee>(e)).toList()
          as T;
    }
    if (t == List<_i32.RecurringTransaction>) {
      return (data as List)
              .map((e) => deserialize<_i32.RecurringTransaction>(e))
              .toList()
          as T;
    }
    if (t == List<_i33.SolanaWallet>) {
      return (data as List)
              .map((e) => deserialize<_i33.SolanaWallet>(e))
              .toList()
          as T;
    }
    if (t == List<_i34.SolanaWalletTransaction>) {
      return (data as List)
              .map((e) => deserialize<_i34.SolanaWalletTransaction>(e))
              .toList()
          as T;
    }
    if (t == List<_i35.SolanaWalletHolding>) {
      return (data as List)
              .map((e) => deserialize<_i35.SolanaWalletHolding>(e))
              .toList()
          as T;
    }
    if (t == List<_i36.TransactionRule>) {
      return (data as List)
              .map((e) => deserialize<_i36.TransactionRule>(e))
              .toList()
          as T;
    }
    if (t == List<_i37.Transaction>) {
      return (data as List)
              .map((e) => deserialize<_i37.Transaction>(e))
              .toList()
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<_i38.SplitItem>) {
      return (data as List).map((e) => deserialize<_i38.SplitItem>(e)).toList()
          as T;
    }
    if (t == List<_i39.ImportRow>) {
      return (data as List).map((e) => deserialize<_i39.ImportRow>(e)).toList()
          as T;
    }
    try {
      return _i40.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i41.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.Account => 'Account',
      _i3.BudgetTemplate => 'BudgetTemplate',
      _i4.Budget => 'Budget',
      _i5.Category => 'Category',
      _i6.EnvelopeGoal => 'EnvelopeGoal',
      _i7.Envelope => 'Envelope',
      _i8.FxLatestSnapshot => 'FxLatestSnapshot',
      _i9.FxRateEntry => 'FxRateEntry',
      _i10.FxRateQuote => 'FxRateQuote',
      _i11.FxRateSnapshot => 'FxRateSnapshot',
      _i12.MonthlyAllocation => 'MonthlyAllocation',
      _i13.Payee => 'Payee',
      _i14.RecurringTransaction => 'RecurringTransaction',
      _i15.SolanaWallet => 'SolanaWallet',
      _i16.SolanaWalletHolding => 'SolanaWalletHolding',
      _i17.SolanaWalletSyncResult => 'SolanaWalletSyncResult',
      _i18.SolanaWalletTaxYearSummary => 'SolanaWalletTaxYearSummary',
      _i19.SolanaWalletTransaction => 'SolanaWalletTransaction',
      _i20.TransactionRule => 'TransactionRule',
      _i21.ImportRow => 'ImportRow',
      _i22.SplitItem => 'SplitItem',
      _i23.Transaction => 'Transaction',
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
      case _i3.BudgetTemplate():
        return 'BudgetTemplate';
      case _i4.Budget():
        return 'Budget';
      case _i5.Category():
        return 'Category';
      case _i6.EnvelopeGoal():
        return 'EnvelopeGoal';
      case _i7.Envelope():
        return 'Envelope';
      case _i8.FxLatestSnapshot():
        return 'FxLatestSnapshot';
      case _i9.FxRateEntry():
        return 'FxRateEntry';
      case _i10.FxRateQuote():
        return 'FxRateQuote';
      case _i11.FxRateSnapshot():
        return 'FxRateSnapshot';
      case _i12.MonthlyAllocation():
        return 'MonthlyAllocation';
      case _i13.Payee():
        return 'Payee';
      case _i14.RecurringTransaction():
        return 'RecurringTransaction';
      case _i15.SolanaWallet():
        return 'SolanaWallet';
      case _i16.SolanaWalletHolding():
        return 'SolanaWalletHolding';
      case _i17.SolanaWalletSyncResult():
        return 'SolanaWalletSyncResult';
      case _i18.SolanaWalletTaxYearSummary():
        return 'SolanaWalletTaxYearSummary';
      case _i19.SolanaWalletTransaction():
        return 'SolanaWalletTransaction';
      case _i20.TransactionRule():
        return 'TransactionRule';
      case _i21.ImportRow():
        return 'ImportRow';
      case _i22.SplitItem():
        return 'SplitItem';
      case _i23.Transaction():
        return 'Transaction';
    }
    className = _i40.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i41.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'BudgetTemplate') {
      return deserialize<_i3.BudgetTemplate>(data['data']);
    }
    if (dataClassName == 'Budget') {
      return deserialize<_i4.Budget>(data['data']);
    }
    if (dataClassName == 'Category') {
      return deserialize<_i5.Category>(data['data']);
    }
    if (dataClassName == 'EnvelopeGoal') {
      return deserialize<_i6.EnvelopeGoal>(data['data']);
    }
    if (dataClassName == 'Envelope') {
      return deserialize<_i7.Envelope>(data['data']);
    }
    if (dataClassName == 'FxLatestSnapshot') {
      return deserialize<_i8.FxLatestSnapshot>(data['data']);
    }
    if (dataClassName == 'FxRateEntry') {
      return deserialize<_i9.FxRateEntry>(data['data']);
    }
    if (dataClassName == 'FxRateQuote') {
      return deserialize<_i10.FxRateQuote>(data['data']);
    }
    if (dataClassName == 'FxRateSnapshot') {
      return deserialize<_i11.FxRateSnapshot>(data['data']);
    }
    if (dataClassName == 'MonthlyAllocation') {
      return deserialize<_i12.MonthlyAllocation>(data['data']);
    }
    if (dataClassName == 'Payee') {
      return deserialize<_i13.Payee>(data['data']);
    }
    if (dataClassName == 'RecurringTransaction') {
      return deserialize<_i14.RecurringTransaction>(data['data']);
    }
    if (dataClassName == 'SolanaWallet') {
      return deserialize<_i15.SolanaWallet>(data['data']);
    }
    if (dataClassName == 'SolanaWalletHolding') {
      return deserialize<_i16.SolanaWalletHolding>(data['data']);
    }
    if (dataClassName == 'SolanaWalletSyncResult') {
      return deserialize<_i17.SolanaWalletSyncResult>(data['data']);
    }
    if (dataClassName == 'SolanaWalletTaxYearSummary') {
      return deserialize<_i18.SolanaWalletTaxYearSummary>(data['data']);
    }
    if (dataClassName == 'SolanaWalletTransaction') {
      return deserialize<_i19.SolanaWalletTransaction>(data['data']);
    }
    if (dataClassName == 'TransactionRule') {
      return deserialize<_i20.TransactionRule>(data['data']);
    }
    if (dataClassName == 'ImportRow') {
      return deserialize<_i21.ImportRow>(data['data']);
    }
    if (dataClassName == 'SplitItem') {
      return deserialize<_i22.SplitItem>(data['data']);
    }
    if (dataClassName == 'Transaction') {
      return deserialize<_i23.Transaction>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i40.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i41.Protocol().deserializeByClassName(data);
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
      return _i40.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i41.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
