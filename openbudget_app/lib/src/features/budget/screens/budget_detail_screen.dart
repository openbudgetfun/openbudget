import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/category_actions_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/credit_card_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/envelope_actions_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/monthly_allocation_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/recent_moves_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/selected_month_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/add_category_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/add_envelope_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/auto_assign_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_template_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/edit_category_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/edit_envelope_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/move_money_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/quick_budget_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/review_transactions_sheet.dart';
import 'package:openbudget_app/src/features/budget/widgets/budget_header.dart';
import 'package:openbudget_app/src/features/budget/widgets/category_group.dart';
import 'package:openbudget_app/src/features/budget/widgets/credit_card_section.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_auto_post_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/providers/theme_mode_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

enum _PlanMenuAction {
  undoLastMove,
  recentMoves,
  toggleSearch,
  toggleHidden,
  reorderCategories,
  saveTemplate,
  toggleTheme,
  collapseExpand,
  hideProgressBars,
  hideAmounts,
  planSettings,
}

enum _PlanOnboardingType { addAccounts, assignMoney, finish }

class BudgetDetailScreen extends HookConsumerWidget {
  const BudgetDetailScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summaryAsync = ref.watch(budgetMonthlySummaryProvider(budgetId));
    final ccPayments = ref.watch(creditCardPaymentsProvider(budgetId));
    final goalsAsync = ref.watch(budgetGoalsProvider(budgetId));
    final dueCountAsync = ref.watch(recurringDueCountProvider(budgetId));
    final isPosting = useState(false);
    final hasAutoPosted = useState(false);
    final isReordering = useState(false);
    final showHidden = useState(false);
    final collapsedCategoryIds = useState<Set<String>>(<String>{});
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final isSearching = useState(false);
    final showSpotlight = useState(false);
    final onboardingComplete = useState(false);
    final selectedEditor = useState<_InlineEditorSelection?>(null);
    final editorInput = useState('');
    final inlineEditorSheetOpen = useState(false);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hideAmounts = ref.watch(hideAmountsProvider);
    final hideProgressBars = ref.watch(hideProgressBarsProvider);
    final recentMoves = ref.watch(recentMovesForBudgetProvider(budgetId));
    final currentThemeMode = ref.watch(themeModeProvider);
    final isDarkMode =
        currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    void navigateAfterMenuClose(VoidCallback callback) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        callback();
      });
    }

    void toggleSearchMode() {
      isSearching.value = !isSearching.value;
      selectedEditor.value = null;
      editorInput.value = '';
      if (!isSearching.value) {
        searchController.clear();
        searchQuery.value = '';
      }
    }

    Widget buildMenuLabel({
      required IconData icon,
      required String label,
      bool checked = false,
    }) => Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(child: Text(label)),
          if (checked) ...[
            const SizedBox(width: SpacingTokens.md),
            const Icon(Icons.check_rounded, size: 18),
          ],
        ],
      );

    // Auto-post due recurring transactions when the budget opens.
    useEffect(() {
      if (hasAutoPosted.value) return null;
      if (!dueCountAsync.hasValue || dueCountAsync.value! <= 0) return null;
      if (!summaryAsync.hasValue) return null;

      hasAutoPosted.value = true;

      Future.microtask(() async {
        isPosting.value = true;
        try {
          final count = await ref
              .read(recurringAutoPostActionsProvider.notifier)
              .postDue(budgetId: budgetId);
          if (context.mounted && count > 0) {
            showAppToast(
              context,
              message: l10n.recurringAutoPosted(count),
              variant: AppToastVariant.success,
            );
          }
        } on Exception catch (_) {
          hasAutoPosted.value = false;
        } finally {
          isPosting.value = false;
        }
      });

      return null;
    }, [dueCountAsync, summaryAsync]);

    useEffect(() {
      if (showSpotlight.value && selectedEditor.value != null) {
        selectedEditor.value = null;
        editorInput.value = '';
      }
      return null;
    }, [showSpotlight.value]);

    useEffect(
      () {
        if (showSpotlight.value) return null;
        if (selectedEditor.value == null) return null;
        if (inlineEditorSheetOpen.value) return null;
        if (!summaryAsync.hasValue) return null;

        final summary = summaryAsync.value!;
        final selection = selectedEditor.value!;
        final currencyCode = CurrencyCode.values.firstWhere(
          (code) => code.code == summary.budget.currencyCode,
          orElse: () => CurrencyCode.usd,
        );
        inlineEditorSheetOpen.value = true;

        Future.microtask(() async {
          if (!context.mounted) return;
          var sheetInput = editorInput.value;

          await showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            backgroundColor: OpenBudgetPalette.transparentFor(
              Theme.of(context),
            ),
            barrierColor: OpenBudgetPalette.overlayScrimFor(
              Theme.of(context),
            ).withAlpha(210),
            builder: (sheetContext) => StatefulBuilder(
              builder: (sheetContext, setSheetState) {
                void setInputValue(String value) {
                  setSheetState(() => sheetInput = value);
                  editorInput.value = value;
                }

                return _InlineAmountEditor(
                  inputValue: sheetInput,
                  amountLabel: hideAmounts
                      ? hiddenAmountPlaceholder
                      : formatCents(
                          _parseEditorCents(sheetInput) ??
                              (selection.monthlyData?.allocatedCents ??
                                  selection.envelope.budgetedAmountCents),
                          currencyCode,
                        ),
                  onAutoAssign: () {
                    Navigator.of(sheetContext).pop();
                    _showQuickBudgetDialog(
                      context,
                      selection.envelope,
                      currencyCode,
                      year: summary.year,
                      month: summary.month,
                    );
                  },
                  onMoveMoney: () {
                    Navigator.of(sheetContext).pop();
                    showDialog<void>(
                      context: context,
                      barrierColor: OpenBudgetPalette.overlayScrimFor(
                        Theme.of(context),
                      ).withAlpha(210),
                      builder: (_) => MoveMoneyDialog(
                        budgetId: budgetId,
                        year: summary.year,
                        month: summary.month,
                        categories: summary.categories,
                      ),
                    );
                  },
                  onDetails: () {
                    final envelopeId = selection.envelope.id?.toString() ?? '';
                    final categoryId = selection.categoryId;
                    if (envelopeId.isEmpty || categoryId.isEmpty) return;
                    Navigator.of(sheetContext).pop();
                    context.pushNamed(
                      categoryDetailRoute,
                      pathParameters: {
                        'id': budgetId,
                        'categoryId': categoryId,
                        'envelopeId': envelopeId,
                      },
                    );
                  },
                  onDigit: (digit) {
                    if (sheetInput.length >= 9) return;
                    setInputValue('$sheetInput$digit');
                  },
                  onBackspace: () {
                    if (sheetInput.isEmpty) return;
                    setInputValue(
                      sheetInput.substring(0, sheetInput.length - 1),
                    );
                  },
                  onNegative: () {
                    final delta = _parseEditorCents(sheetInput);
                    if (delta == null || delta == 0) return;
                    final currentCents =
                        selection.monthlyData?.allocatedCents ??
                        selection.envelope.budgetedAmountCents;
                    final nextDollars = ((currentCents - delta) / 100).round();
                    setInputValue('$nextDollars');
                  },
                  onPositive: () {
                    final delta = _parseEditorCents(sheetInput);
                    if (delta == null || delta == 0) return;
                    final currentCents =
                        selection.monthlyData?.allocatedCents ??
                        selection.envelope.budgetedAmountCents;
                    final nextDollars = ((currentCents + delta) / 100).round();
                    setInputValue('$nextDollars');
                  },
                  onCancel: () => Navigator.of(sheetContext).pop(),
                  onApply: () => _applyInlineAllocation(
                    context: context,
                    ref: ref,
                    selection: selection,
                    year: summary.year,
                    month: summary.month,
                    input: sheetInput,
                    closeEditor: false,
                  ),
                  onDone: () => _applyInlineAllocation(
                    context: context,
                    ref: ref,
                    selection: selection,
                    year: summary.year,
                    month: summary.month,
                    input: sheetInput,
                    closeEditor: true,
                    onCloseEditor: () => Navigator.of(sheetContext).pop(),
                  ),
                );
              },
            ),
          );

          if (!context.mounted) return;
          inlineEditorSheetOpen.value = false;
          selectedEditor.value = null;
          editorInput.value = '';
        });

        return null;
      },
      [
        showSpotlight.value,
        selectedEditor.value,
        summaryAsync,
        hideAmounts,
        inlineEditorSheetOpen.value,
      ],
    );

    return summaryAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.appTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(homePath),
          ),
          title: Text(l10n.appTitle),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: colorScheme.error,
              ),
              const SizedBox(height: SpacingTokens.md),
              Text(
                l10n.budgetLoadError,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
      data: (summary) {
        final currencyCode = CurrencyCode.values.firstWhere(
          (c) => c.code == summary.budget.currencyCode,
          orElse: () => CurrencyCode.usd,
        );
        final goalsMap = goalsAsync.hasValue
            ? goalsAsync.value!
            : <String, EnvelopeGoal>{};

        // Compute total overspent and total activity cents.
        var totalOverspentCents = 0;
        var totalActivityCents = 0;
        for (final cat in summary.categories) {
          if (cat.totalAvailableCents < 0) {
            totalOverspentCents += cat.totalAvailableCents.abs();
          }
          totalActivityCents += cat.totalSpentCents;
        }

        var hiddenCount = 0;
        for (final cat in summary.categories) {
          if (cat.category.isHidden ?? false) {
            hiddenCount++;
          }
          for (final env in cat.envelopes) {
            if (env.isHidden ?? false) hiddenCount++;
          }
        }
        final filteredCategories = _filterCategories(
          summary.categories,
          searchQuery.value,
          showHidden: showHidden.value,
        );
        final overspentEnvelopes = <_OverspentEnvelopeEntry>[];
        for (final categoryWithEnvelopes in summary.categories) {
          final categoryId =
              categoryWithEnvelopes.category.id?.toString() ?? '';
          if (categoryId.isEmpty) continue;
          for (
            var index = 0;
            index < categoryWithEnvelopes.monthlyEnvelopes.length;
            index++
          ) {
            final monthlyData = categoryWithEnvelopes.monthlyEnvelopes[index];
            if (monthlyData.availableCents >= 0) continue;
            final envelopeId = monthlyData.envelope.id?.toString() ?? '';
            if (envelopeId.isEmpty) continue;
            if (monthlyData.envelope.isHidden ?? false) continue;
            overspentEnvelopes.add(
              _OverspentEnvelopeEntry(
                categoryId: categoryId,
                envelopeId: envelopeId,
                envelopeName: monthlyData.envelope.name,
                overspentCents: monthlyData.availableCents.abs(),
                allocatedCents: monthlyData.allocatedCents,
              ),
            );
          }
        }
        final onboardingType = _resolveOnboardingType(
          summary: summary,
          onboardingComplete: onboardingComplete.value,
        );
        final reviewTransactionCount = ref
            .watch(
              monthlyTransactionsProvider(
                budgetId,
                summary.year,
                summary.month,
              ),
            )
            .when(
              data: (transactions) =>
                  transactions.where((t) => !t.cleared && !t.reconciled).length,
              loading: () => 0,
              error: (_, __) => 0,
            );
        final showBudgetHeader =
            showSpotlight.value ||
            onboardingType == null ||
            onboardingType == _PlanOnboardingType.finish;

        return Scaffold(
          backgroundColor: OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
          appBar: AppBar(
            backgroundColor: OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
            surfaceTintColor: OpenBudgetPalette.transparentFor(
              Theme.of(context),
            ),
            scrolledUnderElevation: 0,
            leading: IconButton(
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              icon: const Icon(Icons.close_rounded),
              onPressed: () => context.goNamed(homeRoute),
            ),
            centerTitle: true,
            title: Text(
              summary.budget.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              if (isReordering.value)
                TextButton(
                  onPressed: () => isReordering.value = false,
                  child: Text(l10n.budgetReorderDone),
                ),
              PopupMenuButton<_PlanMenuAction>(
                icon: const Icon(Icons.more_horiz_rounded),
                position: PopupMenuPosition.under,
                offset: const Offset(0, 8),
                onSelected: (action) => switch (action) {
                  _PlanMenuAction.undoLastMove =>
                    ref
                        .read(recentMovesProvider.notifier)
                        .undoLast(budgetId: budgetId),
                  _PlanMenuAction.recentMoves => navigateAfterMenuClose(() {
                    context.pushNamed(
                      recentMovesRoute,
                      pathParameters: {'id': budgetId},
                    );
                  }),
                  _PlanMenuAction.toggleSearch => toggleSearchMode(),
                  _PlanMenuAction.toggleHidden =>
                    showHidden.value = !showHidden.value,
                  _PlanMenuAction.reorderCategories =>
                    isReordering.value = true,
                  _PlanMenuAction.saveTemplate => navigateAfterMenuClose(() {
                    showDialog<void>(
                      context: context,
                      barrierColor: _dialogBarrierColor(context),
                      builder: (_) => BudgetTemplateDialog(budgetId: budgetId),
                    );
                  }),
                  _PlanMenuAction.toggleTheme =>
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(
                          isDarkMode ? ThemeMode.light : ThemeMode.dark,
                        ),
                  _PlanMenuAction.collapseExpand => (() {
                    final visibleIds = filteredCategories
                        .map((entry) => entry.category.id?.toString() ?? '')
                        .where((id) => id.isNotEmpty)
                        .toSet();
                    if (visibleIds.isEmpty) return;

                    final next = Set<String>.from(collapsedCategoryIds.value);
                    final allVisibleCollapsed = visibleIds.every(next.contains);
                    if (allVisibleCollapsed) {
                      next.removeAll(visibleIds);
                    } else {
                      next.addAll(visibleIds);
                    }
                    collapsedCategoryIds.value = next;
                  })(),
                  _PlanMenuAction.hideProgressBars =>
                    ref
                        .read(hideProgressBarsProvider.notifier)
                        .setHideProgressBars(value: !hideProgressBars),
                  _PlanMenuAction.hideAmounts =>
                    ref
                        .read(hideAmountsProvider.notifier)
                        .setHideAmounts(value: !hideAmounts),
                  _PlanMenuAction.planSettings => navigateAfterMenuClose(() {
                    context.goNamed(
                      planSettingsRoute,
                      pathParameters: {'id': budgetId},
                    );
                  }),
                },
                itemBuilder: (context) => [
                  PopupMenuItem<_PlanMenuAction>(
                    value: _PlanMenuAction.recentMoves,
                    child: Row(
                      children: [
                        const Icon(Icons.history_rounded, size: 18),
                        const SizedBox(width: SpacingTokens.sm),
                        Text(l10n.recentMovesTitle),
                      ],
                    ),
                  ),
                  PopupMenuItem<_PlanMenuAction>(
                    value: _PlanMenuAction.undoLastMove,
                    enabled: recentMoves.isNotEmpty,
                    child: Row(
                      children: [
                        const Icon(Icons.undo_rounded, size: 18),
                        const SizedBox(width: SpacingTokens.sm),
                        Text(l10n.undoAction),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<_PlanMenuAction>(
                    value: _PlanMenuAction.toggleSearch,
                    child: buildMenuLabel(
                      icon: Icons.search_rounded,
                      label: l10n.budgetSearchHint,
                      checked: isSearching.value,
                    ),
                  ),
                  PopupMenuItem<_PlanMenuAction>(
                    value: _PlanMenuAction.toggleHidden,
                    child: buildMenuLabel(
                      icon: Icons.visibility_off_rounded,
                      label: showHidden.value
                          ? l10n.budgetShowHidden
                          : hiddenCount > 0
                          ? l10n.budgetHiddenCount(hiddenCount)
                          : l10n.budgetShowHidden,
                      checked: showHidden.value,
                    ),
                  ),
                  PopupMenuItem<_PlanMenuAction>(
                    value: _PlanMenuAction.reorderCategories,
                    enabled: !isReordering.value,
                    child: Row(
                      children: [
                        const Icon(Icons.swap_vert_rounded, size: 18),
                        const SizedBox(width: SpacingTokens.sm),
                        Text(l10n.budgetReorderCategories),
                      ],
                    ),
                  ),
                  PopupMenuItem<_PlanMenuAction>(
                    value: _PlanMenuAction.saveTemplate,
                    child: Row(
                      children: [
                        const Icon(Icons.bookmark_border_rounded, size: 18),
                        const SizedBox(width: SpacingTokens.sm),
                        Text(l10n.templateTitle),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<_PlanMenuAction>(
                    value: _PlanMenuAction.toggleTheme,
                    child: buildMenuLabel(
                      icon: isDarkMode
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      label: isDarkMode ? l10n.themeLight : l10n.themeDark,
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<_PlanMenuAction>(
                    value: _PlanMenuAction.collapseExpand,
                    child: Row(
                      children: [
                        const Icon(Icons.unfold_more_rounded, size: 18),
                        const SizedBox(width: SpacingTokens.sm),
                        Text(l10n.budgetCollapseExpand),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<_PlanMenuAction>(
                    value: _PlanMenuAction.hideProgressBars,
                    child: buildMenuLabel(
                      icon: Icons.linear_scale_rounded,
                      label: l10n.settingsHideProgressBars,
                      checked: hideProgressBars,
                    ),
                  ),
                  PopupMenuItem<_PlanMenuAction>(
                    value: _PlanMenuAction.hideAmounts,
                    child: buildMenuLabel(
                      icon: Icons.visibility_off_rounded,
                      label: l10n.settingsHideAmounts,
                      checked: hideAmounts,
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<_PlanMenuAction>(
                    value: _PlanMenuAction.planSettings,
                    child: Row(
                      children: [
                        const Icon(Icons.settings_outlined, size: 18),
                        const SizedBox(width: SpacingTokens.sm),
                        Text(l10n.settingsPlanSettings),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              final selectedMonth = ref.read(selectedMonthProvider(budgetId));
              ref
                ..invalidate(budgetDetailProvider(budgetId))
                ..invalidate(categoryListProvider(budgetId))
                ..invalidate(transactionListProvider(budgetId))
                ..invalidate(budgetSummaryProvider(budgetId))
                ..invalidate(budgetMonthlySummaryProvider(budgetId))
                ..invalidate(budgetGoalsProvider(budgetId))
                ..invalidate(recurringDueCountProvider(budgetId))
                ..invalidate(
                  monthlyAllocationsProvider(
                    budgetId,
                    selectedMonth.year,
                    selectedMonth.month,
                  ),
                )
                ..invalidate(
                  monthlyTransactionsProvider(
                    budgetId,
                    selectedMonth.year,
                    selectedMonth.month,
                  ),
                );
            },
            child: ListView(
              padding: const EdgeInsets.all(SpacingTokens.md),
              children: [
                _BudgetViewToggle(
                  showSpotlight: showSpotlight.value,
                  onChanged: (value) {
                    showSpotlight.value = value;
                    if (value) {
                      selectedEditor.value = null;
                      editorInput.value = '';
                    }
                  },
                ),
                const SizedBox(height: SpacingTokens.sm),
                if (showBudgetHeader)
                  BudgetHeader(
                    readyToAssignCents: summary.readyToAssignCents,
                    currencyCode: currencyCode,
                    budgetId: budgetId,
                    year: summary.year,
                    month: summary.month,
                    totalOverspentCents: totalOverspentCents,
                    totalIncomeCents: summary.totalIncomeCents,
                    totalBudgetedCents: summary.totalBudgetedCents,
                    totalActivityCents: totalActivityCents,
                    onCopyLastMonth: () => _confirmCopyLastMonth(
                      context,
                      ref,
                      budgetId,
                      summary.year,
                      summary.month,
                    ),
                  ),
                const SizedBox(height: SpacingTokens.md),
                if (!showSpotlight.value && onboardingType != null) ...[
                  _PlanOnboardingCard(
                    type: onboardingType,
                    readyToAssign: hideAmounts
                        ? hiddenAmountPlaceholder
                        : formatCents(summary.readyToAssignCents, currencyCode),
                    onPrimaryAction: () => switch (onboardingType) {
                      _PlanOnboardingType.addAccounts => context.goNamed(
                        addAccountRoute,
                        pathParameters: {'id': budgetId},
                      ),
                      _PlanOnboardingType.assignMoney => _showAutoAssignDialog(
                        context,
                        currencyCode,
                      ),
                      _PlanOnboardingType.finish =>
                        onboardingComplete.value = true,
                    },
                    onSecondaryAction:
                        onboardingType == _PlanOnboardingType.assignMoney
                        ? () => context.goNamed(
                            addAccountRoute,
                            pathParameters: {'id': budgetId},
                          )
                        : null,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                ],
                if (!showSpotlight.value && reviewTransactionCount > 0) ...[
                  _ReviewTransactionsBanner(
                    count: reviewTransactionCount,
                    onTap: () => showReviewTransactionsSheet(
                      context,
                      budgetId: budgetId,
                      year: summary.year,
                      month: summary.month,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                ],
                if (!showSpotlight.value && overspentEnvelopes.isNotEmpty) ...[
                  _CoverOverspentBanner(
                    count: overspentEnvelopes.length,
                    onTap: () => _showCoverOverspendingSheet(
                      context,
                      currencyCode,
                      year: summary.year,
                      month: summary.month,
                      overspentEnvelopes: overspentEnvelopes,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                ],
                if (dueCountAsync.hasValue && dueCountAsync.value! > 0)
                  _DueBanner(
                    count: dueCountAsync.value!,
                    isPosting: isPosting.value,
                    onPost: () => _postDueTransactions(context, ref, isPosting),
                  ),
                if (ccPayments.hasValue && ccPayments.value!.isNotEmpty) ...[
                  CreditCardSection(
                    payments: ccPayments.value!,
                    currencyCode: currencyCode,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                ],
                if (showSpotlight.value)
                  _SpotlightOverview(
                    summary: summary,
                    goalsMap: goalsMap,
                    totalActivityCents: totalActivityCents,
                    currencyCode: currencyCode,
                    hideAmounts: hideAmounts,
                    onEditTargets: () => context.goNamed(
                      editPlanRoute,
                      pathParameters: {'id': budgetId},
                    ),
                    onAssign: () =>
                        _showAutoAssignDialog(context, currencyCode),
                    onReflect: () => context.goNamed(
                      reflectRoute,
                      pathParameters: {'id': budgetId},
                    ),
                  ),
                if (!showSpotlight.value && isSearching.value) ...[
                  TextField(
                    controller: searchController,
                    onChanged: (value) => searchQuery.value = value,
                    decoration: InputDecoration(
                      hintText: l10n.budgetSearchHint,
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                searchController.clear();
                                searchQuery.value = '';
                              },
                            )
                          : null,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.md,
                        vertical: SpacingTokens.sm,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(RadiusTokens.md),
                      ),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                ],
                if (!showSpotlight.value && summary.categories.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: SpacingTokens.xl,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.category_rounded,
                            size: 48,
                            color: colorScheme.outlineVariant,
                          ),
                          const SizedBox(height: SpacingTokens.md),
                          Text(
                            l10n.budgetEmptyTitle,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: SpacingTokens.sm),
                          Text(
                            l10n.budgetEmptySubtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!showSpotlight.value &&
                    isSearching.value &&
                    searchQuery.value.isNotEmpty &&
                    filteredCategories.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: SpacingTokens.xl,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: colorScheme.outlineVariant,
                          ),
                          const SizedBox(height: SpacingTokens.md),
                          Text(
                            l10n.budgetSearchNoResults,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!showSpotlight.value &&
                    isReordering.value &&
                    summary.categories.isNotEmpty)
                  _ReorderableCategoryList(
                    categories: summary.categories,
                    budgetId: budgetId,
                  ),
                if (!showSpotlight.value && !isReordering.value)
                  ...filteredCategories.map(
                    (catWithEnvelopes) => Padding(
                      padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                      child: CategoryGroup(
                        categoryWithEnvelopes: catWithEnvelopes,
                        currencyCode: currencyCode,
                        collapsed: collapsedCategoryIds.value.contains(
                          catWithEnvelopes.category.id?.toString() ?? '',
                        ),
                        onToggleCollapsed: () {
                          final categoryId =
                              catWithEnvelopes.category.id?.toString() ?? '';
                          if (categoryId.isEmpty) return;
                          final next = Set<String>.from(
                            collapsedCategoryIds.value,
                          );
                          if (!next.remove(categoryId)) {
                            next.add(categoryId);
                          }
                          collapsedCategoryIds.value = next;
                        },
                        goalsMap: goalsMap,
                        onAddEnvelope: () => _showAddEnvelopeDialog(
                          context,
                          catWithEnvelopes.category.id?.toString() ?? '',
                          currencyCode,
                          year: summary.year,
                          month: summary.month,
                        ),
                        onEditCategory: () => _showEditCategoryDialog(
                          context,
                          catWithEnvelopes.category.id?.toString() ?? '',
                          catWithEnvelopes.category.name,
                          catWithEnvelopes.envelopes.length,
                          catWithEnvelopes.totalBudgetedCents,
                          currencyCode,
                        ),
                        onDeleteCategory: () => _confirmDeleteCategory(
                          context,
                          ref,
                          catWithEnvelopes,
                          currencyCode,
                        ),
                        onEditEnvelope: (envelope) => _showEditEnvelopeDialog(
                          context,
                          envelope,
                          catWithEnvelopes.category.id?.toString() ?? '',
                          currencyCode,
                          year: summary.year,
                          month: summary.month,
                        ),
                        onDeleteEnvelope: (envelope) => _confirmDeleteEnvelope(
                          context,
                          ref,
                          envelope.id?.toString() ?? '',
                          catWithEnvelopes.category.id?.toString() ?? '',
                          envelope.name,
                        ),
                        onQuickBudget: (envelope) => _showQuickBudgetDialog(
                          context,
                          envelope,
                          currencyCode,
                          year: summary.year,
                          month: summary.month,
                        ),
                        onShowActivity: (envelope, monthlyData, goal) => (() {
                          final categoryId =
                              catWithEnvelopes.category.id?.toString() ?? '';
                          final envelopeId = envelope.id?.toString() ?? '';
                          if (categoryId.isEmpty || envelopeId.isEmpty) {
                            return;
                          }
                          if (selectedEditor.value?.envelope.id?.toString() ==
                              envelopeId) {
                            selectedEditor.value = null;
                            editorInput.value = '';
                            return;
                          }
                          selectedEditor.value = _InlineEditorSelection(
                            categoryId: categoryId,
                            envelope: envelope,
                            monthlyData: monthlyData,
                          );
                          editorInput.value = '';
                        })(),
                        onReorderEnvelopes: (envelopeIds) async {
                          try {
                            await ref
                                .read(envelopeActionsProvider.notifier)
                                .reorderEnvelopes(
                                  categoryId:
                                      catWithEnvelopes.category.id
                                          ?.toString() ??
                                      '',
                                  budgetId: budgetId,
                                  envelopeIds: envelopeIds,
                                );
                          } on Exception catch (_) {
                            // Handled by provider re-fetch.
                          }
                        },
                        showHidden: showHidden.value,
                        selectedEnvelopeId: selectedEditor.value?.envelope.id
                            ?.toString(),
                        onToggleHideCategory: ({required isHidden}) async {
                          try {
                            await ref
                                .read(categoryActionsProvider.notifier)
                                .toggleHidden(
                                  categoryId:
                                      catWithEnvelopes.category.id
                                          ?.toString() ??
                                      '',
                                  budgetId: budgetId,
                                  isHidden: isHidden,
                                );
                          } on Exception catch (_) {
                            // Handled by provider re-fetch.
                          }
                        },
                        onToggleHideEnvelope:
                            (envelope, {required isHidden}) async {
                              try {
                                await ref
                                    .read(envelopeActionsProvider.notifier)
                                    .toggleHidden(
                                      envelopeId: envelope.id?.toString() ?? '',
                                      categoryId:
                                          catWithEnvelopes.category.id
                                              ?.toString() ??
                                          '',
                                      budgetId: budgetId,
                                      isHidden: isHidden,
                                    );
                              } on Exception catch (_) {
                                // Handled by provider re-fetch.
                              }
                            },
                      ),
                    ),
                  ),
                if (!showSpotlight.value) ...[
                  const SizedBox(height: SpacingTokens.sm),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () => _showAddCategoryDialog(
                        context,
                        summary.categories.length,
                      ),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.budgetAddCategory),
                    ),
                  ),
                ],
                const SizedBox(height: SpacingTokens.xxl),
              ],
            ),
          ),
        );
      },
    );
  }

  List<CategoryWithEnvelopes> _filterCategories(
    List<CategoryWithEnvelopes> categories,
    String query, {
    required bool showHidden,
  }) {
    var result = categories;

    // Filter hidden categories and envelopes.
    if (!showHidden) {
      final visible = <CategoryWithEnvelopes>[];
      for (final cat in result) {
        if (cat.category.isHidden ?? false) continue;

        final visibleEnvelopeIndices = <int>[];
        for (var i = 0; i < cat.envelopes.length; i++) {
          if (!(cat.envelopes[i].isHidden ?? false)) {
            visibleEnvelopeIndices.add(i);
          }
        }

        visible.add(
          CategoryWithEnvelopes(
            category: cat.category,
            envelopes: visibleEnvelopeIndices
                .map((i) => cat.envelopes[i])
                .toList(),
            monthlyEnvelopes: visibleEnvelopeIndices
                .where((i) => i < cat.monthlyEnvelopes.length)
                .map((i) => cat.monthlyEnvelopes[i])
                .toList(),
            totalBudgetedCents: cat.totalBudgetedCents,
            totalSpentCents: cat.totalSpentCents,
            totalAvailableCents: cat.totalAvailableCents,
          ),
        );
      }
      result = visible;
    }

    if (query.isEmpty) return result;

    final lowerQuery = query.toLowerCase();
    final filtered = <CategoryWithEnvelopes>[];

    for (final cat in result) {
      // Check if category name matches.
      final categoryMatches = cat.category.name.toLowerCase().contains(
        lowerQuery,
      );

      // Filter matching envelopes.
      final matchingEnvelopeIndices = <int>[];
      for (var i = 0; i < cat.envelopes.length; i++) {
        if (cat.envelopes[i].name.toLowerCase().contains(lowerQuery)) {
          matchingEnvelopeIndices.add(i);
        }
      }

      if (categoryMatches || matchingEnvelopeIndices.isNotEmpty) {
        if (categoryMatches) {
          // Show all envelopes when category name matches.
          filtered.add(cat);
        } else {
          // Only show matching envelopes.
          filtered.add(
            CategoryWithEnvelopes(
              category: cat.category,
              envelopes: matchingEnvelopeIndices
                  .map((i) => cat.envelopes[i])
                  .toList(),
              monthlyEnvelopes: matchingEnvelopeIndices
                  .where((i) => i < cat.monthlyEnvelopes.length)
                  .map((i) => cat.monthlyEnvelopes[i])
                  .toList(),
              totalBudgetedCents: cat.totalBudgetedCents,
              totalSpentCents: cat.totalSpentCents,
              totalAvailableCents: cat.totalAvailableCents,
            ),
          );
        }
      }
    }

    return filtered;
  }

  int? _parseEditorCents(String value) {
    if (value.isEmpty || value == '-') return null;
    final isNegative = value.startsWith('-');
    final digits = value.replaceAll('-', '');
    final dollars = int.tryParse(digits);
    if (dollars == null) return null;
    final cents = dollars * 100;
    return isNegative ? -cents : cents;
  }

  Future<void> _applyInlineAllocation({
    required BuildContext context,
    required WidgetRef ref,
    required _InlineEditorSelection selection,
    required int year,
    required int month,
    required String input,
    required bool closeEditor,
    VoidCallback? onCloseEditor,
  }) async {
    final allocatedCents = _parseEditorCents(input);
    if (allocatedCents == null) {
      if (closeEditor) onCloseEditor?.call();
      return;
    }

    final envelopeId = selection.envelope.id?.toString() ?? '';
    if (envelopeId.isEmpty) {
      if (closeEditor) onCloseEditor?.call();
      return;
    }

    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(monthlyAllocationActionsProvider.notifier)
          .upsertAllocation(
            envelopeId: envelopeId,
            budgetId: budgetId,
            year: year,
            month: month,
            allocatedCents: allocatedCents,
          );
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.budgetAllocationUpdated,
          variant: AppToastVariant.success,
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.budgetAllocationError,
          variant: AppToastVariant.error,
        );
      }
    } finally {
      if (closeEditor) onCloseEditor?.call();
    }
  }

  _PlanOnboardingType? _resolveOnboardingType({
    required BudgetSummary summary,
    required bool onboardingComplete,
  }) {
    if (onboardingComplete) return null;
    if (summary.totalIncomeCents <= 0) return _PlanOnboardingType.addAccounts;
    if (summary.totalBudgetedCents <= 0 && summary.readyToAssignCents > 0) {
      return _PlanOnboardingType.assignMoney;
    }
    if (summary.totalBudgetedCents > 0 && summary.readyToAssignCents > 0) {
      return _PlanOnboardingType.finish;
    }
    return null;
  }

  Color _dialogBarrierColor(BuildContext context) =>
      OpenBudgetPalette.overlayScrimFor(Theme.of(context)).withAlpha(210);

  void _showAutoAssignDialog(BuildContext context, CurrencyCode currencyCode) {
    showDialog<void>(
      context: context,
      barrierColor: _dialogBarrierColor(context),
      builder: (_) =>
          AutoAssignDialog(budgetId: budgetId, currencyCode: currencyCode),
    );
  }

  void _showCoverOverspendingSheet(
    BuildContext context,
    CurrencyCode currencyCode, {
    required int year,
    required int month,
    required List<_OverspentEnvelopeEntry> overspentEnvelopes,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: OpenBudgetPalette.transparentFor(Theme.of(context)),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.9,
        child: _CoverOverspendingSheet(
          budgetId: budgetId,
          year: year,
          month: month,
          currencyCode: currencyCode,
          overspentEnvelopes: overspentEnvelopes,
        ),
      ),
    );
  }

  void _showQuickBudgetDialog(
    BuildContext context,
    Envelope envelope,
    CurrencyCode currencyCode, {
    required int year,
    required int month,
  }) {
    showDialog<void>(
      context: context,
      barrierColor: _dialogBarrierColor(context),
      builder: (_) => QuickBudgetDialog(
        budgetId: budgetId,
        envelopeId: envelope.id?.toString() ?? '',
        envelopeName: envelope.name,
        currencyCode: currencyCode,
        year: year,
        month: month,
      ),
    );
  }

  void _showEditCategoryDialog(
    BuildContext context,
    String categoryId,
    String currentName,
    int envelopeCount,
    int totalAllocatedCents,
    CurrencyCode currencyCode,
  ) {
    showDialog<void>(
      context: context,
      barrierColor: _dialogBarrierColor(context),
      builder: (_) => EditCategoryDialog(
        categoryId: categoryId,
        budgetId: budgetId,
        currentName: currentName,
        envelopeCount: envelopeCount,
        totalAllocatedCents: totalAllocatedCents,
        currencyCode: currencyCode,
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, int nextSortOrder) {
    showDialog<void>(
      context: context,
      barrierColor: _dialogBarrierColor(context),
      builder: (_) =>
          AddCategoryDialog(budgetId: budgetId, nextSortOrder: nextSortOrder),
    );
  }

  void _showAddEnvelopeDialog(
    BuildContext context,
    String categoryId,
    CurrencyCode currencyCode, {
    required int year,
    required int month,
  }) {
    showDialog<void>(
      context: context,
      barrierColor: _dialogBarrierColor(context),
      builder: (_) => AddEnvelopeDialog(
        categoryId: categoryId,
        budgetId: budgetId,
        currencyCode: currencyCode,
        year: year,
        month: month,
      ),
    );
  }

  void _showEditEnvelopeDialog(
    BuildContext context,
    Envelope envelope,
    String categoryId,
    CurrencyCode currencyCode, {
    required int year,
    required int month,
  }) {
    showDialog<void>(
      context: context,
      barrierColor: _dialogBarrierColor(context),
      builder: (_) => EditEnvelopeDialog(
        envelope: envelope,
        categoryId: categoryId,
        budgetId: budgetId,
        currencyCode: currencyCode,
        year: year,
        month: month,
      ),
    );
  }

  Future<void> _confirmDeleteCategory(
    BuildContext context,
    WidgetRef ref,
    CategoryWithEnvelopes categoryWithEnvelopes,
    CurrencyCode currencyCode,
  ) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final categoryId = categoryWithEnvelopes.category.id?.toString() ?? '';
    if (categoryId.isEmpty) return;

    final categoryName = categoryWithEnvelopes.category.name;
    final envelopeCount = categoryWithEnvelopes.envelopes.length;
    final totalAllocated = formatCents(
      categoryWithEnvelopes.totalBudgetedCents,
      currencyCode,
    );
    final envelopeSummary = envelopeCount == 1
        ? '1 envelope'
        : '$envelopeCount envelopes';
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: _dialogBarrierColor(context),
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(
          '${l10n.deleteConfirmMessage}\n\n'
          '"$categoryName"\n\n'
          '$envelopeSummary\n'
          '$totalAllocated allocated',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: Text(l10n.deleteConfirmButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final deleted = await ref
          .read(categoryActionsProvider.notifier)
          .deleteCategory(categoryId: categoryId, budgetId: budgetId);
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.deleteSuccess,
          variant: AppToastVariant.success,
          actionLabel: l10n.undoAction,
          onAction: () => _undoDeleteCategory(context, ref, deleted, l10n),
          duration: const Duration(seconds: 5),
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.deleteError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

  Future<void> _undoDeleteCategory(
    BuildContext context,
    WidgetRef ref,
    Category deleted,
    AppLocalizations l10n,
  ) async {
    try {
      await ref
          .read(categoryActionsProvider.notifier)
          .undoDeleteCategory(deletedCategory: deleted, budgetId: budgetId);
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.undoDeleteSuccess,
          variant: AppToastVariant.success,
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.undoDeleteError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

  Future<void> _postDueTransactions(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> isPosting,
  ) async {
    final l10n = AppLocalizations.of(context);
    isPosting.value = true;
    try {
      final count = await ref
          .read(recurringAutoPostActionsProvider.notifier)
          .postDue(budgetId: budgetId);
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.recurringPostSuccess(count),
          variant: AppToastVariant.success,
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.recurringPostError,
          variant: AppToastVariant.error,
        );
      }
    } finally {
      isPosting.value = false;
    }
  }

  Future<void> _confirmCopyLastMonth(
    BuildContext context,
    WidgetRef ref,
    String budgetId,
    int year,
    int month,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: _dialogBarrierColor(context),
      builder: (ctx) => AlertDialog(
        title: Text(l10n.budgetCopyLastMonth),
        content: Text(l10n.budgetCopyLastMonthConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.content_copy_rounded, size: 16),
            label: Text(l10n.budgetCopyLastMonth),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(monthlyAllocationActionsProvider.notifier)
          .copyPreviousMonth(
            budgetId: budgetId,
            currentYear: year,
            currentMonth: month,
          );
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.budgetCopyLastMonthSuccess,
          variant: AppToastVariant.success,
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.budgetCopyLastMonthError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

  Future<void> _confirmDeleteEnvelope(
    BuildContext context,
    WidgetRef ref,
    String envelopeId,
    String categoryId,
    String envelopeName,
  ) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: _dialogBarrierColor(context),
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text('${l10n.deleteConfirmMessage}\n\n"$envelopeName"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: Text(l10n.deleteConfirmButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final deleted = await ref
          .read(envelopeActionsProvider.notifier)
          .deleteEnvelope(
            envelopeId: envelopeId,
            categoryId: categoryId,
            budgetId: budgetId,
          );
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.deleteSuccess,
          variant: AppToastVariant.success,
          actionLabel: l10n.undoAction,
          onAction: () =>
              _undoDeleteEnvelope(context, ref, deleted, categoryId, l10n),
          duration: const Duration(seconds: 5),
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.deleteError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

  Future<void> _undoDeleteEnvelope(
    BuildContext context,
    WidgetRef ref,
    Envelope deleted,
    String categoryId,
    AppLocalizations l10n,
  ) async {
    try {
      await ref
          .read(envelopeActionsProvider.notifier)
          .undoDeleteEnvelope(
            deletedEnvelope: deleted,
            categoryId: categoryId,
            budgetId: budgetId,
          );
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.undoDeleteSuccess,
          variant: AppToastVariant.success,
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.undoDeleteError,
          variant: AppToastVariant.error,
        );
      }
    }
  }
}

class _PlanOnboardingCard extends HookWidget {
  const _PlanOnboardingCard({
    required this.type,
    required this.readyToAssign,
    required this.onPrimaryAction,
    this.onSecondaryAction,
  });

  final _PlanOnboardingType type;
  final String readyToAssign;
  final VoidCallback onPrimaryAction;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final (
      backgroundColor,
      iconData,
      title,
      body,
      prompt,
      primaryLabel,
    ) = switch (type) {
      _PlanOnboardingType.addAccounts => (
        OpenBudgetPalette.bgAccentFor(Theme.of(context)).withAlpha(70),
        Icons.account_balance_rounded,
        l10n.budgetOnboardingAddAccountsTitle,
        l10n.budgetOnboardingAddAccountsBody,
        null,
        l10n.budgetOnboardingAddAccountsCta,
      ),
      _PlanOnboardingType.assignMoney => (
        OpenBudgetPalette.bgSuccessFor(Theme.of(context)),
        Icons.mail_rounded,
        l10n.budgetOnboardingAssignMoneyTitle(readyToAssign),
        l10n.budgetOnboardingAssignMoneyBody,
        l10n.budgetOnboardingAssignMoneyPrompt,
        l10n.budgetAssignMoney,
      ),
      _PlanOnboardingType.finish => (
        OpenBudgetPalette.bgAccentFor(Theme.of(context)).withAlpha(70),
        Icons.auto_awesome_rounded,
        l10n.budgetOnboardingFinishTitle,
        l10n.budgetOnboardingFinishBody,
        null,
        l10n.budgetOnboardingFinishCta,
      ),
    };

    final primaryButtonColor = type == _PlanOnboardingType.assignMoney
        ? OpenBudgetPalette.fgSuccessStrongFor(Theme.of(context))
        : OpenBudgetPalette.bgBrandFor(Theme.of(context));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(RadiusTokens.lg),
        border: Border.all(
          color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
        ),
      ),
      child: Column(
        children: [
          Icon(
            iconData,
            size: 42,
            color: OpenBudgetPalette.bgBrandFor(Theme.of(context)),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            body,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: OpenBudgetPalette.fgPrimaryEmphasisFor(Theme.of(context)),
            ),
            textAlign: TextAlign.center,
          ),
          if (prompt != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text(
              prompt,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: OpenBudgetPalette.fgPrimaryEmphasisFor(
                  Theme.of(context),
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: SpacingTokens.md),
          FilledButton(
            onPressed: onPrimaryAction,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              backgroundColor: primaryButtonColor,
              foregroundColor: OpenBudgetPalette.fgOnBrandFor(
                Theme.of(context),
              ),
            ),
            child: Text(primaryLabel),
          ),
          if (onSecondaryAction != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            OutlinedButton(
              onPressed: onSecondaryAction,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(42),
                side: BorderSide(
                  color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
                ),
                backgroundColor: OpenBudgetPalette.bgSecondaryFor(
                  Theme.of(context),
                ),
                foregroundColor: OpenBudgetPalette.bgBrandFor(
                  Theme.of(context),
                ),
              ),
              child: Text(l10n.budgetOnboardingAddAnotherAccount),
            ),
          ],
        ],
      ),
    );
  }
}

class _BudgetViewToggle extends HookWidget {
  const _BudgetViewToggle({
    required this.showSpotlight,
    required this.onChanged,
  });

  final bool showSpotlight;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: OpenBudgetPalette.bgTertiaryFor(Theme.of(context)),
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(
          color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: l10n.budgetDetailCategories,
              selected: !showSpotlight,
              onTap: () => onChanged(false),
              theme: theme,
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: l10n.budgetDetailSpotlight,
              selected: showSpotlight,
              onTap: () => onChanged(true),
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends HookWidget {
  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) => Material(
      color: selected
          ? OpenBudgetPalette.bgSecondaryFor(Theme.of(context))
          : OpenBudgetPalette.transparentFor(Theme.of(context)),
      borderRadius: BorderRadius.circular(RadiusTokens.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected
                    ? OpenBudgetPalette.fgPrimaryFor(Theme.of(context))
                    : OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
              ),
            ),
          ),
        ),
      ),
    );
}

class _SpotlightOverview extends HookWidget {
  const _SpotlightOverview({
    required this.summary,
    required this.goalsMap,
    required this.totalActivityCents,
    required this.currencyCode,
    required this.hideAmounts,
    required this.onEditTargets,
    required this.onAssign,
    required this.onReflect,
  });

  final BudgetSummary summary;
  final Map<String, EnvelopeGoal> goalsMap;
  final int totalActivityCents;
  final CurrencyCode currencyCode;
  final bool hideAmounts;
  final VoidCallback onEditTargets;
  final VoidCallback onAssign;
  final VoidCallback onReflect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    var totalTargetsCents = 0;
    var totalUnderfundedCents = 0;

    for (final categoryWithEnvelopes in summary.categories) {
      for (
        var index = 0;
        index < categoryWithEnvelopes.envelopes.length;
        index++
      ) {
        final envelope = categoryWithEnvelopes.envelopes[index];
        final envelopeId = envelope.id?.toString();
        if (envelopeId == null) continue;

        final goal = goalsMap[envelopeId];
        if (goal == null) continue;

        final monthlyData =
            index < categoryWithEnvelopes.monthlyEnvelopes.length
            ? categoryWithEnvelopes.monthlyEnvelopes[index]
            : null;
        final budgetedCents =
            monthlyData?.allocatedCents ?? envelope.budgetedAmountCents;
        final spentCents = monthlyData?.spentCents ?? envelope.spentAmountCents;
        final availableCents =
            monthlyData?.availableCents ?? (budgetedCents - spentCents);

        final targetCents = switch (goal.goalType) {
          'monthly_funding' =>
            goal.monthlyFundingCents ?? goal.targetAmountCents,
          _ => goal.targetAmountCents,
        };

        totalTargetsCents += targetCents;
        totalUnderfundedCents += computeUnderfundedCents(
          goal: goal,
          budgetedCents: budgetedCents,
          availableCents: availableCents,
        );
      }
    }

    final summaryTitle =
        '${_monthLabel(l10n, summary.month)} ${l10n.budgetSpotlightSummarySuffix}';

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(SpacingTokens.md),
          decoration: BoxDecoration(
            color: OpenBudgetPalette.bgSecondaryFor(Theme.of(context)),
            borderRadius: BorderRadius.circular(RadiusTokens.md),
            border: Border.all(
              color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
            ),
          ),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SpotlightPriorityIcon(
                    icon: Icons.shopping_basket_rounded,
                    rotation: -0.12,
                  ),
                  SizedBox(width: SpacingTokens.sm),
                  _SpotlightPriorityIcon(
                    icon: Icons.directions_bus_rounded,
                    rotation: 0.08,
                  ),
                  SizedBox(width: SpacingTokens.sm),
                  _SpotlightPriorityIcon(
                    icon: Icons.local_florist_rounded,
                    rotation: -0.08,
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.md),
              Text(
                l10n.budgetSpotlightTopPriorities,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: SpacingTokens.xs),
              Text(
                l10n.budgetSpotlightTopPrioritiesHint,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              FilledButton.tonal(
                onPressed: () {},
                child: Text(l10n.budgetSpotlightAddPriorities),
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(SpacingTokens.md),
          decoration: BoxDecoration(
            color: OpenBudgetPalette.bgSecondaryFor(Theme.of(context)),
            borderRadius: BorderRadius.circular(RadiusTokens.md),
            border: Border.all(
              color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summaryTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 104,
                      child: _SpotlightMetricTile(
                        icon: Icons.track_changes_rounded,
                        label: l10n.budgetSpotlightTotalTargets,
                        value: hideAmounts
                            ? hiddenAmountPlaceholder
                            : formatCents(totalTargetsCents, currencyCode),
                        actionLabel: l10n.budgetSpotlightEdit,
                        onActionTap: onEditTargets,
                      ),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: SizedBox(
                      height: 104,
                      child: _SpotlightMetricTile(
                        icon: Icons.pie_chart_rounded,
                        label: l10n.budgetSpotlightUnderfunded,
                        value: hideAmounts
                            ? hiddenAmountPlaceholder
                            : formatCents(totalUnderfundedCents, currencyCode),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.sm),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 104,
                      child: _SpotlightMetricTile(
                        icon: Icons.fact_check_rounded,
                        label: l10n.budgetSpotlightAssigned,
                        value: hideAmounts
                            ? hiddenAmountPlaceholder
                            : formatCents(
                                summary.totalBudgetedCents,
                                currencyCode,
                              ),
                        actionLabel: l10n.budgetSpotlightAssign,
                        onActionTap: onAssign,
                      ),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: SizedBox(
                      height: 104,
                      child: _SpotlightMetricTile(
                        icon: Icons.payments_outlined,
                        label: l10n.budgetSpotlightSpent,
                        value: hideAmounts
                            ? hiddenAmountPlaceholder
                            : formatCents(totalActivityCents, currencyCode),
                        actionLabel: l10n.budgetSpotlightReflect,
                        onActionTap: onReflect,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _monthLabel(AppLocalizations l10n, int month) => switch (month) {
    1 => l10n.budgetMonthJanuary,
    2 => l10n.budgetMonthFebruary,
    3 => l10n.budgetMonthMarch,
    4 => l10n.budgetMonthApril,
    5 => l10n.budgetMonthMay,
    6 => l10n.budgetMonthJune,
    7 => l10n.budgetMonthJuly,
    8 => l10n.budgetMonthAugust,
    9 => l10n.budgetMonthSeptember,
    10 => l10n.budgetMonthOctober,
    11 => l10n.budgetMonthNovember,
    12 => l10n.budgetMonthDecember,
    _ => '',
  };
}

class _SpotlightMetricTile extends HookWidget {
  const _SpotlightMetricTile({
    required this.icon,
    required this.label,
    required this.value,
    this.actionLabel,
    this.onActionTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = switch (icon) {
      Icons.track_changes_rounded => OpenBudgetPalette.bgFlagInfoFor(theme),
      Icons.pie_chart_rounded => OpenBudgetPalette.bgFlagCriticalFor(theme),
      Icons.fact_check_rounded => OpenBudgetPalette.bgFlagPositiveFor(theme),
      Icons.payments_outlined => OpenBudgetPalette.bgFlagAccentFor(theme),
      _ => OpenBudgetPalette.bgBrandFor(theme),
    };
    final surfaceColor = Color.alphaBlend(
      accentColor.withAlpha(theme.brightness == Brightness.dark ? 58 : 30),
      OpenBudgetPalette.bgTertiaryFor(theme),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(color: accentColor.withAlpha(150)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withAlpha(
              theme.brightness == Brightness.dark ? 52 : 34,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: OpenBudgetPalette.fgPrimaryFor(theme).withAlpha(16),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            surfaceColor,
            Color.alphaBlend(
              accentColor.withAlpha(
                theme.brightness == Brightness.dark ? 74 : 38,
              ),
              OpenBudgetPalette.bgSecondaryFor(theme),
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SpacingTokens.sm,
          SpacingTokens.sm,
          SpacingTokens.sm,
          SpacingTokens.sm + 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(
                      theme.brightness == Brightness.dark ? 54 : 30,
                    ),
                    borderRadius: BorderRadius.circular(RadiusTokens.sm),
                    border: Border.all(color: accentColor.withAlpha(165)),
                  ),
                  child: Icon(icon, size: 14, color: accentColor),
                ),
                const SizedBox(width: SpacingTokens.xs),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: OpenBudgetPalette.fgSecondaryFor(
                        Theme.of(context),
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (actionLabel != null)
                  TextButton(
                    onPressed: onActionTap,
                    style: TextButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.xs + 2,
                        vertical: 2,
                      ),
                      backgroundColor: accentColor.withAlpha(
                        theme.brightness == Brightness.dark ? 58 : 28,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                        side: BorderSide(color: accentColor.withAlpha(145)),
                      ),
                    ),
                    child: Text(
                      actionLabel!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: SpacingTokens.xs + 2),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpotlightPriorityIcon extends HookWidget {
  const _SpotlightPriorityIcon({required this.icon, required this.rotation});

  final IconData icon;
  final double rotation;

  @override
  Widget build(BuildContext context) => Transform.rotate(
      angle: rotation,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: OpenBudgetPalette.bgBrandFor(Theme.of(context)).withAlpha(26),
          borderRadius: BorderRadius.circular(RadiusTokens.md),
          border: Border.all(
            color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
          ),
        ),
        child: Icon(
          icon,
          color: OpenBudgetPalette.bgBrandFor(Theme.of(context)),
        ),
      ),
    );
}

class _InlineEditorSelection {
  const _InlineEditorSelection({
    required this.categoryId,
    required this.envelope,
    this.monthlyData,
  });

  final String categoryId;
  final Envelope envelope;
  final MonthlyEnvelopeData? monthlyData;
}

class _InlineAmountEditor extends HookWidget {
  const _InlineAmountEditor({
    required this.inputValue,
    required this.amountLabel,
    required this.onAutoAssign,
    required this.onMoveMoney,
    required this.onDetails,
    required this.onDigit,
    required this.onBackspace,
    required this.onNegative,
    required this.onPositive,
    required this.onApply,
    required this.onCancel,
    required this.onDone,
  });

  final String inputValue;
  final String amountLabel;
  final VoidCallback onAutoAssign;
  final VoidCallback onMoveMoney;
  final VoidCallback onDetails;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onNegative;
  final VoidCallback onPositive;
  final VoidCallback onApply;
  final VoidCallback onCancel;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final canApply = inputValue.isNotEmpty && inputValue != '-';
    const actionRowHeight = 70.0;

    Widget key(
      String label, {
      VoidCallback? onPressed,
      bool primary = false,
      bool accent = false,
      Widget? child,
      double minHeight = 48,
    }) => Expanded(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.xs),
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: primary
                  ? OpenBudgetPalette.bgBrandFor(Theme.of(context))
                  : OpenBudgetPalette.bgSecondaryFor(Theme.of(context)),
              foregroundColor: primary
                  ? OpenBudgetPalette.fgOnBrandFor(Theme.of(context))
                  : accent
                  ? OpenBudgetPalette.bgBrandFor(Theme.of(context))
                  : OpenBudgetPalette.fgPrimaryEmphasisFor(Theme.of(context)),
              side: primary
                  ? BorderSide.none
                  : BorderSide(
                      color: OpenBudgetPalette.borderSubtleFor(
                        Theme.of(context),
                      ),
                    ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.sm),
              ),
              fixedSize: Size.fromHeight(minHeight),
              elevation: 0,
            ),
            child: child ?? Text(label),
          ),
        ),
      );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: OpenBudgetPalette.bgTertiaryFor(Theme.of(context)),
        border: Border(
          top: BorderSide(
            color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.sm,
            SpacingTokens.xs,
            SpacingTokens.sm,
            SpacingTokens.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
                child: Text(
                  amountLabel,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: OpenBudgetPalette.bgBrandFor(Theme.of(context)),
                  ),
                ),
              ),
              Row(
                children: [
                  key(
                    l10n.autoAssignButton,
                    onPressed: onAutoAssign,
                    minHeight: actionRowHeight,
                    child: Text(
                      l10n.autoAssignButton,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                  key(
                    l10n.envelopeActionMoveMoney,
                    onPressed: onMoveMoney,
                    minHeight: actionRowHeight,
                    child: Text(
                      l10n.envelopeActionMoveMoney,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                  key(
                    l10n.budgetInlineEditorDetails,
                    onPressed: onDetails,
                    minHeight: actionRowHeight,
                    child: Text(
                      l10n.budgetInlineEditorDetails,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  key('7', onPressed: () => onDigit('7'), accent: true),
                  key('8', onPressed: () => onDigit('8'), accent: true),
                  key('9', onPressed: () => onDigit('9'), accent: true),
                  key('-', onPressed: onNegative, accent: true),
                ],
              ),
              Row(
                children: [
                  key('4', onPressed: () => onDigit('4'), accent: true),
                  key('5', onPressed: () => onDigit('5'), accent: true),
                  key('6', onPressed: () => onDigit('6'), accent: true),
                  key('+', onPressed: onPositive, accent: true),
                ],
              ),
              Row(
                children: [
                  key('1', onPressed: () => onDigit('1'), accent: true),
                  key('2', onPressed: () => onDigit('2'), accent: true),
                  key('3', onPressed: () => onDigit('3'), accent: true),
                  key('=', onPressed: canApply ? onApply : null, accent: true),
                ],
              ),
              Row(
                children: [
                  key(
                    'x',
                    onPressed: onCancel,
                    child: const Icon(Icons.close_rounded),
                  ),
                  key('0', onPressed: () => onDigit('0'), accent: true),
                  key(
                    '',
                    onPressed: onBackspace,
                    child: const Icon(Icons.backspace_outlined),
                  ),
                  key(
                    '',
                    onPressed: onDone,
                    primary: true,
                    child: Tooltip(
                      message: l10n.dialogDone,
                      child: Semantics(
                        button: true,
                        label: l10n.dialogDone,
                        child: const Icon(Icons.keyboard_return_rounded),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DueBanner extends HookWidget {
  const _DueBanner({
    required this.count,
    required this.isPosting,
    required this.onPost,
  });

  final int count;
  final bool isPosting;
  final VoidCallback onPost;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.sm,
        ),
        decoration: BoxDecoration(
          color: ColorTokens.primary.withAlpha(15),
          borderRadius: BorderRadius.circular(RadiusTokens.md),
          border: Border.all(color: ColorTokens.primary.withAlpha(60)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 20,
              color: ColorTokens.primary,
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Text(
                l10n.recurringDueBanner(count),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: ColorTokens.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            FilledButton.icon(
              onPressed: isPosting ? null : onPost,
              icon: isPosting
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: OpenBudgetPalette.fgOnBrandFor(
                          Theme.of(context),
                        ),
                      ),
                    )
                  : const Icon(Icons.play_arrow_rounded, size: 16),
              label: Text(
                isPosting ? l10n.recurringPosting : l10n.recurringPostDue,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: ColorTokens.primary,
                foregroundColor: OpenBudgetPalette.fgOnBrandFor(
                  Theme.of(context),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.xs,
                ),
                textStyle: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewTransactionsBanner extends HookWidget {
  const _ReviewTransactionsBanner({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = count == 1
        ? 'Review 1 transaction'
        : 'Review $count transactions';

    return Material(
      color: OpenBudgetPalette.bgSecondaryFor(Theme.of(context)),
      borderRadius: BorderRadius.circular(RadiusTokens.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(RadiusTokens.md),
            border: Border.all(
              color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: OpenBudgetPalette.bgInfoFor(Theme.of(context)),
                  borderRadius: BorderRadius.circular(RadiusTokens.sm),
                ),
                child: Text(
                  '$count',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: OpenBudgetPalette.bgBrandFor(Theme.of(context)),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverspentEnvelopeEntry {
  const _OverspentEnvelopeEntry({
    required this.categoryId,
    required this.envelopeId,
    required this.envelopeName,
    required this.overspentCents,
    required this.allocatedCents,
  });

  final String categoryId;
  final String envelopeId;
  final String envelopeName;
  final int overspentCents;
  final int allocatedCents;
}

class _CoverOverspentBanner extends HookWidget {
  const _CoverOverspentBanner({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = count == 1
        ? 'Cover 1 overspent category'
        : 'Cover $count overspent categories';

    return Material(
      color: OpenBudgetPalette.bgSecondaryFor(Theme.of(context)),
      borderRadius: BorderRadius.circular(RadiusTokens.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(RadiusTokens.md),
            border: Border.all(
              color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: OpenBudgetPalette.bgErrorFor(Theme.of(context)),
                  borderRadius: BorderRadius.circular(RadiusTokens.sm),
                ),
                child: Text(
                  '$count',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: OpenBudgetPalette.fgErrorFor(Theme.of(context)),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverOverspendingSheet extends HookConsumerWidget {
  const _CoverOverspendingSheet({
    required this.budgetId,
    required this.year,
    required this.month,
    required this.currencyCode,
    required this.overspentEnvelopes,
  });

  final String budgetId;
  final int year;
  final int month;
  final CurrencyCode currencyCode;
  final List<_OverspentEnvelopeEntry> overspentEnvelopes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final remainingItems = useState(
      List<_OverspentEnvelopeEntry>.of(overspentEnvelopes),
    );
    final isApplying = useState(false);

    Future<void> coverEnvelope(_OverspentEnvelopeEntry item) async {
      if (isApplying.value) return;
      isApplying.value = true;
      try {
        await ref
            .read(monthlyAllocationActionsProvider.notifier)
            .upsertAllocation(
              envelopeId: item.envelopeId,
              budgetId: budgetId,
              year: year,
              month: month,
              allocatedCents: item.allocatedCents + item.overspentCents,
            );
        remainingItems.value = remainingItems.value
            .where((candidate) => candidate.envelopeId != item.envelopeId)
            .toList(growable: false);
      } on Exception catch (_) {
        if (!context.mounted) return;
        showAppToast(
          context,
          message: l10n.budgetDetailCoverOverspendingError,
          variant: AppToastVariant.error,
        );
      } finally {
        ref
          ..invalidate(monthlyTransactionsProvider(budgetId, year, month))
          ..invalidate(budgetMonthlySummaryProvider(budgetId));
        isApplying.value = false;
      }
    }

    Future<void> coverAll() async {
      if (isApplying.value || remainingItems.value.isEmpty) return;
      isApplying.value = true;
      final coveredIds = <String>{};
      try {
        for (final item in remainingItems.value) {
          try {
            await ref
                .read(monthlyAllocationActionsProvider.notifier)
                .upsertAllocation(
                  envelopeId: item.envelopeId,
                  budgetId: budgetId,
                  year: year,
                  month: month,
                  allocatedCents: item.allocatedCents + item.overspentCents,
                );
            coveredIds.add(item.envelopeId);
          } on Exception catch (_) {
            // Continue covering the rest even if one update fails.
          }
        }
        remainingItems.value = remainingItems.value
            .where((item) => !coveredIds.contains(item.envelopeId))
            .toList(growable: false);
      } finally {
        ref
          ..invalidate(monthlyTransactionsProvider(budgetId, year, month))
          ..invalidate(budgetMonthlySummaryProvider(budgetId));
        isApplying.value = false;
      }
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(RadiusTokens.lg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: SpacingTokens.xs),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
                borderRadius: BorderRadius.circular(RadiusTokens.md),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.md,
                SpacingTokens.sm,
                SpacingTokens.md,
                SpacingTokens.sm,
              ),
              child: Row(
                children: [
                  const SizedBox(width: 56),
                  Expanded(
                    child: Text(
                      l10n.budgetDetailCoverOverspendingTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 56,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.dialogDone),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: remainingItems.value.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.lg,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 32,
                              color: OpenBudgetPalette.fgSuccessFor(
                                Theme.of(context),
                              ),
                            ),
                            const SizedBox(height: SpacingTokens.md),
                            Text(
                              l10n.budgetDetailAllOverspendingCovered,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(SpacingTokens.md),
                      itemBuilder: (context, index) {
                        final item = remainingItems.value[index];
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            color: OpenBudgetPalette.bgSecondaryFor(
                              Theme.of(context),
                            ),
                            borderRadius: BorderRadius.circular(
                              RadiusTokens.md,
                            ),
                            border: Border.all(
                              color: OpenBudgetPalette.borderSubtleFor(
                                Theme.of(context),
                              ),
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              item.envelopeName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              l10n.budgetDetailNeedsToCover(
                                formatCents(item.overspentCents, currencyCode),
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: OpenBudgetPalette.fgSecondaryFor(
                                  Theme.of(context),
                                ),
                              ),
                            ),
                            trailing: FilledButton(
                              onPressed: isApplying.value
                                  ? null
                                  : () => coverEnvelope(item),
                              child: Text(l10n.budgetDetailCoverButton),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: SpacingTokens.sm),
                      itemCount: remainingItems.value.length,
                    ),
            ),
            if (remainingItems.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  SpacingTokens.md,
                  SpacingTokens.xs,
                  SpacingTokens.md,
                  SpacingTokens.md,
                ),
                child: FilledButton(
                  onPressed: isApplying.value ? null : coverAll,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                  ),
                  child: Text(
                    isApplying.value
                        ? l10n.budgetDetailCovering
                        : l10n.budgetDetailCoverOverspent(
                            remainingItems.value.length,
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReorderableCategoryList extends HookConsumerWidget {
  const _ReorderableCategoryList({
    required this.categories,
    required this.budgetId,
  });

  final List<CategoryWithEnvelopes> categories;
  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final orderedCategories = useState(List.of(categories));

    // Sync with provider state when categories change.
    useEffect(() {
      orderedCategories.value = List.of(categories);
      return null;
    }, [categories]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: SpacingTokens.xs),
              Text(
                l10n.budgetReorderHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ...orderedCategories.value.asMap().entries.map((entry) {
          final index = entry.key;
          final cat = entry.value;
          return _ReorderableCategoryTile(
            key: ValueKey(cat.category.id),
            category: cat,
            index: index,
            total: orderedCategories.value.length,
            onMoveUp: index > 0
                ? () => _swap(orderedCategories, index, index - 1, ref)
                : null,
            onMoveDown: index < orderedCategories.value.length - 1
                ? () => _swap(orderedCategories, index, index + 1, ref)
                : null,
          );
        }),
      ],
    );
  }

  Future<void> _swap(
    ValueNotifier<List<CategoryWithEnvelopes>> orderedCategories,
    int from,
    int to,
    WidgetRef ref,
  ) async {
    final list = List.of(orderedCategories.value);
    final item = list.removeAt(from);
    list.insert(to, item);
    orderedCategories.value = list;

    final categoryIds = list
        .map((c) => c.category.id?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    try {
      await ref
          .read(categoryActionsProvider.notifier)
          .reorderCategories(budgetId: budgetId, categoryIds: categoryIds);
    } on Exception catch (_) {
      // Revert on error handled by provider re-fetch.
    }
  }
}

class _ReorderableCategoryTile extends HookWidget {
  const _ReorderableCategoryTile({
    required this.category,
    required this.index,
    required this.total,
    this.onMoveUp,
    this.onMoveDown,
    super.key,
  });

  final CategoryWithEnvelopes category;
  final int index;
  final int total;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: ListTile(
        leading: Icon(
          Icons.drag_handle_rounded,
          color: colorScheme.onSurfaceVariant,
        ),
        title: Text(
          category.category.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${category.envelopes.length} envelopes',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_upward_rounded),
              onPressed: onMoveUp,
              iconSize: 20,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_downward_rounded),
              onPressed: onMoveDown,
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}
