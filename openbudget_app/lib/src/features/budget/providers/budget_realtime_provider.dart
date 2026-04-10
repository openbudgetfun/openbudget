import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_transactions_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/solana_wallet_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/age_of_money_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_template_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/envelope_goal_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/monthly_allocation_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_auto_post_provider.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_list_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/display_currency_provider.dart';
import 'package:openbudget_app/src/features/transaction_rules/providers/rule_list_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';

final budgetRealtimeProvider = Provider.autoDispose.family<void, String>((
  ref,
  budgetId,
) {
  final client = ref.watch(serverpodClientProvider);
  var disposed = false;

  Future<void> listenForBudgetChanges() async {
    while (!disposed) {
      try {
        await for (final _ in client.budgetStream.budgetUpdates(
          Stream<UuidValue>.value(
            // Serverpod API requires UuidValue which is experimental in uuid package.
            // ignore: experimental_member_use
            UuidValue.fromString(budgetId),
          ),
        )) {
          if (disposed) return;
          _invalidateBudgetScopedProviders(ref, budgetId);
        }
      } on Object {
        // Reconnect on transient transport errors.
      }

      if (disposed) return;
      await Future<void>.delayed(const Duration(seconds: 2));
    }
  }

  unawaited(listenForBudgetChanges());

  ref.onDispose(() {
    disposed = true;
  });
});

void _invalidateBudgetScopedProviders(Ref ref, String budgetId) {
  ref
    ..invalidate(budgetDetailProvider(budgetId))
    ..invalidate(categoryListProvider(budgetId))
    ..invalidate(transactionListProvider(budgetId))
    ..invalidate(budgetSummaryProvider(budgetId))
    ..invalidate(budgetMonthlySummaryProvider(budgetId))
    ..invalidate(budgetGoalsProvider(budgetId))
    ..invalidate(accountListProvider(budgetId))
    ..invalidate(payeeListProvider(budgetId))
    ..invalidate(ruleListProvider(budgetId))
    ..invalidate(recurringListProvider(budgetId))
    ..invalidate(recurringDueCountProvider(budgetId))
    ..invalidate(budgetTemplateListProvider(budgetId))
    ..invalidate(ageOfMoneyProvider(budgetId))
    ..invalidate(displayCurrencyProvider(budgetId))
    ..invalidate(displayCurrencyConverterProvider(budgetId))
    ..invalidate(envelopeListProvider)
    ..invalidate(envelopeGoalProvider)
    ..invalidate(envelopeGoalsProvider)
    ..invalidate(monthlyAllocationsProvider)
    ..invalidate(monthlyTransactionsProvider)
    ..invalidate(accountTransactionsProvider)
    ..invalidate(accountSolanaWalletProvider)
    ..invalidate(solanaWalletTransactionsProvider)
    ..invalidate(solanaWalletHoldingsProvider)
    ..invalidate(solanaWalletTaxYearSummariesProvider);
}
