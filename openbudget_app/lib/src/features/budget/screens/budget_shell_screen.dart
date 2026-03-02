import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/widgets/add_transaction_sheet.dart';
import 'package:openbudget_app/src/routing/route_names.dart';

class BudgetShellScreen extends HookWidget {
  const BudgetShellScreen({
    required this.navigationShell,
    required this.budgetId,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final String budgetId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _adjustedIndex(navigationShell.currentIndex),
        onDestinationSelected: (index) => unawaited(_onTap(context, index)),
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

  Future<void> _onTap(BuildContext context, int index) async {
    if (index == 2) {
      // "+" tab — show add transaction sheet
      await showModalBottomSheet<void>(
        context: context,
        builder: (_) => AddTransactionSheet(budgetId: budgetId),
      );
      return;
    }

    if (index == 4 && navigationShell.currentIndex == 3) {
      await _showMoreQuickActions(context);
      return;
    }

    // Map visual tab index back to shell branch index
    final branchIndex = index > 2 ? index - 1 : index;
    // Always navigate to the branch root to avoid stale shell state causing
    // apparent no-op tab taps (especially on first visit to a branch).
    navigationShell.goBranch(branchIndex, initialLocation: true);
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
        context.goNamed(settingsRoute, pathParameters: {'id': budgetId});
      case _MoreQuickAction.recurring:
        context.goNamed(recurringListRoute, pathParameters: {'id': budgetId});
      case _MoreQuickAction.payees:
        context.goNamed(payeeListRoute, pathParameters: {'id': budgetId});
    }
  }
}

enum _MoreQuickAction { settings, recurring, payees }
