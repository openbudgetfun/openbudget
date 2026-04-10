import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_realtime_provider.dart';
import 'package:openbudget_app/src/features/budget/widgets/add_transaction_sheet.dart';
import 'package:openbudget_app/src/routing/route_names.dart';

class BudgetShellScreen extends HookConsumerWidget {
  const BudgetShellScreen({
    required this.navigationShell,
    required this.budgetId,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(budgetRealtimeProvider(budgetId));

    final l10n = AppLocalizations.of(context);
    final tabHistory = useState<List<int>>(<int>[navigationShell.currentIndex]);

    useEffect(() {
      _recordTabVisit(tabHistory, navigationShell.currentIndex);
      return null;
    }, [navigationShell.currentIndex]);

    return BackButtonListener(
      onBackButtonPressed: () => _onBackButtonPressed(context, tabHistory),
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _adjustedIndex(navigationShell.currentIndex),
          onDestinationSelected: (index) =>
              unawaited(_onTap(context, index, tabHistory)),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.savings_outlined),
              selectedIcon: const Icon(Icons.savings_rounded),
              label: l10n.tabPlan,
            ),
            NavigationDestination(
              icon: const Icon(Icons.account_balance_outlined),
              selectedIcon: const Icon(Icons.account_balance_rounded),
              label: l10n.tabAccounts,
            ),
            NavigationDestination(
              icon: const Icon(Icons.add_circle_outline_rounded),
              selectedIcon: const Icon(Icons.add_circle_rounded),
              label: l10n.tabAdd,
            ),
            NavigationDestination(
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: const Icon(Icons.bar_chart_rounded),
              label: l10n.tabReflect,
            ),
            NavigationDestination(
              icon: const Icon(Icons.more_horiz_rounded),
              selectedIcon: const Icon(Icons.more_horiz_rounded),
              label: l10n.tabMore,
            ),
          ],
        ),
      ),
    );
  }

  /// The shell has 4 branches (Plan=0, Accounts=1, Reflect=2, More=3)
  /// but the NavigationBar has 5 destinations (Plan=0, Accounts=1, Add=2,
  /// Reflect=3, More=4). Map the shell index to the visual tab index.
  int _adjustedIndex(int shellIndex) {
    // Shell branches: 0=Plan, 1=Accounts, 2=Reflect, 3=More
    // Visual tabs:    0=Plan, 1=Accounts, 2=Add, 3=Reflect, 4=More
    if (shellIndex <= 1) return shellIndex;
    return shellIndex + 1;
  }

  Future<void> _onTap(
    BuildContext context,
    int index,
    ValueNotifier<List<int>> tabHistory,
  ) async {
    if (index == 2) {
      // "+" tab — show add transaction sheet
      final action = await showModalBottomSheet<AddTransactionAction>(
        context: context,
        showDragHandle: false,
        builder: (_) => AddTransactionSheet(budgetId: budgetId),
      );
      if (!context.mounted || action == null) return;
      switch (action) {
        case AddTransactionAction.income:
          await context.pushNamed(
            addIncomeRoute,
            pathParameters: {'id': budgetId},
          );
        case AddTransactionAction.expense:
          await context.pushNamed(
            addExpenseRoute,
            pathParameters: {'id': budgetId},
          );
        case AddTransactionAction.transfer:
          await context.pushNamed(
            createTransferRoute,
            pathParameters: {'id': budgetId},
          );
      }
      return;
    }

    if (index == 4 && navigationShell.currentIndex == 3) {
      await _showMoreQuickActions(context);
      return;
    }

    // Map visual tab index back to shell branch index
    final branchIndex = index > 2 ? index - 1 : index;
    if (branchIndex != navigationShell.currentIndex) {
      _recordTabVisit(tabHistory, branchIndex);
    }
    // Always navigate to the branch root to avoid stale shell state causing
    // apparent no-op tab taps (especially on first visit to a branch).
    navigationShell.goBranch(branchIndex, initialLocation: true);
  }

  Future<bool> _onBackButtonPressed(
    BuildContext context,
    ValueNotifier<List<int>> tabHistory,
  ) async {
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return false;

    final history = List<int>.from(tabHistory.value);
    if (history.length <= 1) return false;

    history.removeLast();
    final previousBranch = history.last;
    tabHistory.value = history;
    navigationShell.goBranch(previousBranch, initialLocation: true);
    return true;
  }

  void _recordTabVisit(ValueNotifier<List<int>> tabHistory, int branchIndex) {
    final history = List<int>.from(tabHistory.value);
    if (history.isNotEmpty && history.last == branchIndex) return;

    history
      ..remove(branchIndex)
      ..add(branchIndex);
    tabHistory.value = history;
  }

  Future<void> _showMoreQuickActions(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final action = await showModalBottomSheet<_MoreQuickAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n.moreSettings),
              onTap: () => Navigator.of(context).pop(_MoreQuickAction.settings),
            ),
            ListTile(
              leading: const Icon(Icons.repeat_rounded),
              title: Text(l10n.moreRecurring),
              onTap: () =>
                  Navigator.of(context).pop(_MoreQuickAction.recurring),
            ),
            ListTile(
              leading: const Icon(Icons.people_outline_rounded),
              title: Text(l10n.morePayees),
              onTap: () => Navigator.of(context).pop(_MoreQuickAction.payees),
            ),
          ],
        ),
      ),
    );

    if (!context.mounted || action == null) return;

    switch (action) {
      case _MoreQuickAction.settings:
        await context.pushNamed(
          settingsRoute,
          pathParameters: {'id': budgetId},
        );
      case _MoreQuickAction.recurring:
        await context.pushNamed(
          recurringListRoute,
          pathParameters: {'id': budgetId},
        );
      case _MoreQuickAction.payees:
        await context.pushNamed(
          payeeListRoute,
          pathParameters: {'id': budgetId},
        );
    }
  }
}

enum _MoreQuickAction { settings, recurring, payees }
