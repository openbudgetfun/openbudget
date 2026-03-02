import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/widgets/add_transaction_sheet.dart';

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
        onDestinationSelected: (index) => _onTap(context, index),
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

  void _onTap(BuildContext context, int index) {
    if (index == 2) {
      // "+" tab — show add transaction sheet
      showModalBottomSheet<void>(
        context: context,
        builder: (_) => AddTransactionSheet(budgetId: budgetId),
      );
      return;
    }

    // Map visual tab index back to shell branch index
    final branchIndex = index > 2 ? index - 1 : index;
    // Always navigate to the branch root to avoid stale shell state causing
    // apparent no-op tab taps (especially on first visit to a branch).
    navigationShell.goBranch(branchIndex, initialLocation: true);
  }
}
