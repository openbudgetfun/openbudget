import 'package:openbudget_app/src/features/accounts/providers/account_detail_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_proposals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/age_of_money_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/credit_card_provider.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/home/providers/entity_summary_provider.dart';
import 'package:openbudget_app/src/features/ledger/providers/ledger_providers.dart';
import 'package:openbudget_app/src/features/reports/providers/category_trends_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/month_figures_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/multi_month_comparison_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_by_payee_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_report_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_trends_provider.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_providers.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_pages_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'entity_events_provider.g.dart';

/// Subscribes to the entity's change stream and invalidates the providers
/// each [ChangeScope] covers, so open screens refresh when any write lands
/// on the server — including writes made by the assistant or another
/// device. The app shell watches this once per signed-in entity.
@riverpod
Stream<EntityChangedEvent> entityEvents(Ref ref, String entityId) {
  final entityUuid = UuidValue.fromString(entityId);
  final client = ref.read(serverpodClientProvider);

  final subscription = client.entityStream.watch(entityUuid).listen((event) {
    if (event.entityId != entityUuid) return;
    _invalidate(ref, event.scope);
  });
  ref.onDispose(subscription.cancel);

  // The events themselves are not state; the invalidations are the point.
  return const Stream.empty();
}

void _invalidate(Ref ref, ChangeScope scope) {
  switch (scope) {
    case ChangeScope.transactions:
      // The transaction pages, the month views, the accounts, the summaries
      // and every report, including age of money.
      ref
        ..invalidate(transactionPagesProvider)
        ..invalidate(budgetMonthProvider)
        ..invalidate(budgetMonthGroupsProvider)
        ..invalidate(creditCardPaymentsProvider)
        ..invalidate(accountListProvider)
        ..invalidate(accountListAllProvider)
        ..invalidate(accountBalancesProvider)
        ..invalidate(entitySummariesProvider);
      _invalidateReports(ref);
    case ChangeScope.plan:
      ref
        ..invalidate(budgetMonthProvider)
        ..invalidate(budgetMonthGroupsProvider)
        ..invalidate(entitySummariesProvider);
      _invalidateReports(ref);
    case ChangeScope.accounts:
      ref
        ..invalidate(accountListProvider)
        ..invalidate(accountListAllProvider)
        ..invalidate(accountBalancesProvider)
        ..invalidate(accountDetailProvider)
        ..invalidate(netWorthProvider)
        ..invalidate(netWorthForEntitiesProvider)
        ..invalidate(netWorthHistoryProvider)
        ..invalidate(entitySummariesProvider);
    case ChangeScope.ledger:
      ref
        ..invalidate(ledgerAccountsProvider)
        ..invalidate(ledgerJournalsProvider)
        ..invalidate(ledgerJournalLinesProvider)
        ..invalidate(ledgerLockDateProvider)
        ..invalidate(ledgerTrialBalanceProvider);
    case ChangeScope.proposals:
      ref
        ..invalidate(assistantProposalsProvider)
        ..invalidate(entitySummariesProvider);
    case ChangeScope.entity:
      ref
        ..invalidate(entityDetailProvider)
        ..invalidate(taxProfileProvider)
        ..invalidate(taxCategoriesProvider)
        ..invalidate(taxReportProvider)
        ..invalidate(entitySummariesProvider);
  }
}

/// Every provider backed by `report.spending`, `report.monthSummaries` or
/// `report.ageOfMoney`.
void _invalidateReports(Ref ref) {
  ref
    ..invalidate(monthFiguresProvider)
    ..invalidate(spendingReportProvider)
    ..invalidate(spendingReportPresetProvider)
    ..invalidate(spendingByPayeeProvider)
    ..invalidate(categoryTrendsProvider)
    ..invalidate(spendingTrendsProvider)
    ..invalidate(multiMonthComparisonProvider)
    ..invalidate(ageOfMoneyProvider);
}
