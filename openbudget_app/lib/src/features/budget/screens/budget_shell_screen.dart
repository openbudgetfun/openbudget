import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/entity_events_provider.dart';
import 'package:openbudget_app/src/features/budget/widgets/add_transaction_sheet.dart';
import 'package:openbudget_app/src/features/whats_new/hooks/use_whats_new_auto_prompt.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class BudgetShellScreen extends HookConsumerWidget {
  const BudgetShellScreen({
    required this.navigationShell,
    required this.entityId,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(entityEventsProvider(entityId));
    useWhatsNewAutoPrompt(context, ref);

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
              icon: const SkribbleIcon(data: OpenBudgetIcons.envelope),
              selectedIcon: const SkribbleIcon(
                data: OpenBudgetIcons.envelopeOpen,
              ),
              label: l10n.tabPlan,
            ),
            NavigationDestination(
              icon: const SkribbleIcon(data: OpenBudgetIcons.wallet),
              selectedIcon: const SkribbleIcon(data: OpenBudgetIcons.bank),
              label: l10n.tabAccounts,
            ),
            NavigationDestination(
              icon: const _AddSticker(),
              selectedIcon: const _AddSticker(),
              label: l10n.tabAdd,
            ),
            NavigationDestination(
              icon: const SkribbleIcon(data: OpenBudgetIcons.barChart),
              selectedIcon: const SkribbleIcon(data: OpenBudgetIcons.pieChart),
              label: l10n.tabReflect,
            ),
            NavigationDestination(
              icon: const SkribbleIcon(data: OpenBudgetIcons.more),
              selectedIcon: const SkribbleIcon(data: OpenBudgetIcons.more),
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
        builder: (_) => AddTransactionSheet(entityId: entityId),
      );
      if (!context.mounted || action == null) return;
      switch (action) {
        case AddTransactionAction.income:
          await context.pushNamed(
            addIncomeRoute,
            pathParameters: {'entityId': entityId},
          );
        case AddTransactionAction.expense:
          await context.pushNamed(
            addExpenseRoute,
            pathParameters: {'entityId': entityId},
          );
        case AddTransactionAction.transfer:
          await context.pushNamed(
            createTransferRoute,
            pathParameters: {'entityId': entityId},
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
              leading: SkribbleIcon(
                data: OpenBudgetIcons.settings,
                color: Theme.of(context).ob.ink,
              ),
              title: Text(l10n.moreSettings),
              onTap: () => Navigator.of(context).pop(_MoreQuickAction.settings),
            ),
            ListTile(
              leading: SkribbleIcon(
                data: OpenBudgetIcons.recurring,
                color: Theme.of(context).ob.ink,
              ),
              title: Text(l10n.moreRecurring),
              onTap: () =>
                  Navigator.of(context).pop(_MoreQuickAction.recurring),
            ),
            ListTile(
              leading: SkribbleIcon(
                data: OpenBudgetIcons.people,
                color: Theme.of(context).ob.ink,
              ),
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
          pathParameters: {'entityId': entityId},
        );
      case _MoreQuickAction.recurring:
        await context.pushNamed(
          recurringListRoute,
          pathParameters: {'entityId': entityId},
        );
      case _MoreQuickAction.payees:
        await context.pushNamed(
          payeeListRoute,
          pathParameters: {'entityId': entityId},
        );
    }
  }
}

enum _MoreQuickAction { settings, recurring, payees }

/// The Add tab's icon: a hot-pink sticker on a hard print shadow, so the
/// one action in the bar stands out from the places it goes.
class _AddSticker extends HookWidget {
  const _AddSticker();

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).ob;
    return Container(
      width: 48,
      height: 34,
      alignment: Alignment.center,
      decoration: ObRoughDecoration(
        color: palette.action,
        outline: palette.ink,
        strokeWidth: 2.2,
        seed: 29,
        shadow: palette.printShadow,
        shadowOffset: const Offset(3, 3),
      ),
      child: SkribbleIcon(
        data: OpenBudgetIcons.add,
        size: 20,
        color: palette.onAction,
      ),
    );
  }
}
