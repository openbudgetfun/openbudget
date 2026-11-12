import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/category_actions_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/credit_card_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/envelope_actions_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/recent_moves_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/review_queue_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/add_category_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/add_envelope_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/auto_assign_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_template_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/edit_category_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/edit_envelope_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/move_money_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/quick_budget_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/review_transactions_sheet.dart';
import 'package:openbudget_app/src/features/budget/widgets/budget_amount_keypad.dart';
import 'package:openbudget_app/src/features/budget/widgets/budget_header.dart';
import 'package:openbudget_app/src/features/budget/widgets/category_group.dart';
import 'package:openbudget_app/src/features/budget/widgets/credit_card_section.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_actions_provider.dart';
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

/// The plan screen: month header with Ready to Assign, category groups of
/// envelope rows from the server's month view, spotlight, inline allocation
/// editor and the overspending cover sheet.
class BudgetDetailScreen extends HookConsumerWidget {
  const BudgetDetailScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final groupsAsync = ref.watch(budgetMonthGroupsProvider(entityId));
    final viewAsync = ref.watch(budgetMonthProvider(entityId));
    final hideAmounts = ref.watch(hideAmountsProvider);
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

    void toggleSearchMode() {
      isSearching.value = !isSearching.value;
      selectedEditor.value = null;
      editorInput.value = '';
      if (!isSearching.value) {
        searchController.clear();
        searchQuery.value = '';
      }
    }

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
        final view = viewAsync.value;
        if (view == null) return null;

        final selection = selectedEditor.value!;
        final currencyCode = view.currencyCode;
        inlineEditorSheetOpen.value = true;

        unawaited(
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
                        : formatMinorForCode(
                            parseBudgetAmountInputToMinor(
                                  input: sheetInput,
                                  currencyCode: currencyCode,
                                ) ??
                                selection.monthEnvelope.allocatedMinor,
                            currencyCode,
                          ),
                    onAutoAssign: () {
                      Navigator.of(sheetContext).pop();
                      _showQuickBudgetDialog(
                        context,
                        selection.monthEnvelope.envelope,
                        currencyCode,
                        month: view.month,
                      );
                    },
                    onMoveMoney: () {
                      Navigator.of(sheetContext).pop();
                      unawaited(
                        showDialog<void>(
                          context: context,
                          barrierColor: OpenBudgetPalette.overlayScrimFor(
                            Theme.of(context),
                          ).withAlpha(210),
                          builder: (_) => MoveMoneyDialog(
                            entityId: entityId,
                            currencyCode: currencyCode,
                          ),
                        ),
                      );
                    },
                    onDetails: () {
                      final envelopeId =
                          selection.monthEnvelope.envelope.id?.toString() ?? '';
                      final categoryId = selection.categoryId;
                      if (envelopeId.isEmpty || categoryId.isEmpty) return;
                      Navigator.of(sheetContext).pop();
                      unawaited(
                        context.pushNamed(
                          categoryDetailRoute,
                          pathParameters: {
                            'entityId': entityId,
                            'categoryId': categoryId,
                            'envelopeId': envelopeId,
                          },
                        ),
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
                      final delta = parseBudgetAmountInputToMinor(
                        input: sheetInput,
                        currencyCode: currencyCode,
                      );
                      if (delta == null || delta == 0) return;
                      final nextMinor =
                          selection.monthEnvelope.allocatedMinor - delta;
                      setInputValue(
                        budgetAmountInputFromMinor(
                          minor: nextMinor,
                          currencyCode: currencyCode,
                        ),
                      );
                    },
                    onPositive: () {
                      final delta = parseBudgetAmountInputToMinor(
                        input: sheetInput,
                        currencyCode: currencyCode,
                      );
                      if (delta == null || delta == 0) return;
                      final nextMinor =
                          selection.monthEnvelope.allocatedMinor + delta;
                      setInputValue(
                        budgetAmountInputFromMinor(
                          minor: nextMinor,
                          currencyCode: currencyCode,
                        ),
                      );
                    },
                    onCancel: () => Navigator.of(sheetContext).pop(),
                    onApply: () => _applyInlineAllocation(
                      context: context,
                      ref: ref,
                      selection: selection,
                      currencyCode: currencyCode,
                      input: sheetInput,
                      closeEditor: false,
                    ),
                    onDone: () => _applyInlineAllocation(
                      context: context,
                      ref: ref,
                      selection: selection,
                      currencyCode: currencyCode,
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
          }),
        );

        return null;
      },
      [
        showSpotlight.value,
        selectedEditor.value,
        viewAsync,
        hideAmounts,
        inlineEditorSheetOpen.value,
      ],
    );

    return groupsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.appTitle)),
        body: Center(child: ObLoadingPanel(label: l10n.loadingTitle)),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const SkribbleIcon(data: OpenBudgetIcons.back),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => context.go(homePath),
          ),
          title: Text(l10n.appTitle),
        ),
        body: Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: ObStatePanel.problem(
            title: l10n.appTitle,
            message: l10n.budgetLoadError,
          ),
        ),
      ),
      data: (groups) {
        final view = viewAsync.value;
        final summary = view?.summary;
        final currencyCode = view?.currencyCode ?? '';
        final entityAsync = ref.watch(entityDetailProvider(entityId));
        final entityName = entityAsync.value?.name ?? '';

        // This month's overspent total, from the visible groups.
        var totalOverspentMinor = 0;
        for (final group in groups) {
          if (group.availableMinor < 0) {
            totalOverspentMinor += group.availableMinor.abs();
          }
        }

        var hiddenCount = 0;
        for (final group in groups) {
          if (group.category.isHidden) hiddenCount++;
          for (final envelopeView in group.envelopes) {
            if (envelopeView.envelope.isHidden) hiddenCount++;
          }
        }
        final filteredCategories = _filterCategories(
          groups,
          searchQuery.value,
          showHidden: showHidden.value,
        );
        final overspentEnvelopes = <_OverspentEnvelopeEntry>[];
        for (final group in groups) {
          final categoryId = group.category.id?.toString() ?? '';
          if (categoryId.isEmpty) continue;
          for (final envelopeView in group.envelopes) {
            if (envelopeView.availableMinor >= 0) continue;
            final envelopeId = envelopeView.envelope.id?.toString() ?? '';
            if (envelopeId.isEmpty) continue;
            if (envelopeView.envelope.isHidden) continue;
            overspentEnvelopes.add(
              _OverspentEnvelopeEntry(
                categoryId: categoryId,
                envelopeId: envelopeId,
                envelopeName: envelopeView.envelope.name,
                overspentMinor: envelopeView.availableMinor.abs(),
                allocatedMinor: envelopeView.allocatedMinor,
              ),
            );
          }
        }
        final onboardingType = summary == null
            ? null
            : _resolveOnboardingType(
                summary: summary,
                onboardingComplete: onboardingComplete.value,
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
              icon: const SkribbleIcon(data: OpenBudgetIcons.close),
              onPressed: () => context.goNamed(homeRoute),
            ),
            centerTitle: true,
            title: Text(
              entityName,
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
              _BudgetAppBarMenu(
                entityId: entityId,
                isSearching: isSearching.value,
                showHidden: showHidden.value,
                hiddenCount: hiddenCount,
                isReordering: isReordering.value,
                filteredCategories: filteredCategories,
                collapsedCategoryIds: collapsedCategoryIds,
                onToggleSearch: toggleSearchMode,
                onToggleHidden: () => showHidden.value = !showHidden.value,
                onReorderCategories: () => isReordering.value = true,
                onPlanSettings: () {
                  context.goNamed(
                    planSettingsRoute,
                    pathParameters: {'entityId': entityId},
                  );
                },
                onSaveTemplate: () {
                  unawaited(
                    showDialog<void>(
                      context: context,
                      barrierColor: _dialogBarrierColor(context),
                      builder: (_) => BudgetTemplateDialog(entityId: entityId),
                    ),
                  );
                },
                onRecentMoves: () {
                  unawaited(
                    context.pushNamed(
                      recentMovesRoute,
                      pathParameters: {'entityId': entityId},
                    ),
                  );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref
                ..invalidate(budgetMonthProvider(entityId))
                ..invalidate(budgetMonthGroupsProvider(entityId))
                ..invalidate(entityDetailProvider(entityId))
                ..invalidate(recurringDueCountProvider(entityId))
                ..invalidate(reviewQueueProvider(entityId))
                ..invalidate(creditCardPaymentsProvider(entityId));
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
                if (showBudgetHeader && summary != null)
                  BudgetHeader(
                    summary: summary,
                    currencyCode: currencyCode,
                    entityId: entityId,
                    month: view!.month,
                    totalOverspentMinor: totalOverspentMinor,
                    onCopyLastMonth: () => _confirmCopyLastMonth(
                      context,
                      ref,
                      entityId,
                    ),
                  ),
                const SizedBox(height: SpacingTokens.md),
                if (!showSpotlight.value && onboardingType != null) ...[
                  _PlanOnboardingCard(
                    type: onboardingType,
                    readyToAssign: hideAmounts
                        ? hiddenAmountPlaceholder
                        : formatMinorForCode(
                            summary?.readyToAssignMinor ?? 0,
                            currencyCode,
                          ),
                    onPrimaryAction: () => switch (onboardingType) {
                      _PlanOnboardingType.addAccounts => context.goNamed(
                        addAccountRoute,
                        pathParameters: {'entityId': entityId},
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
                            pathParameters: {'entityId': entityId},
                          )
                        : null,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                ],
                if (!showSpotlight.value)
                  _ReviewTransactionsBannerLoader(entityId: entityId),
                if (!showSpotlight.value && overspentEnvelopes.isNotEmpty) ...[
                  _CoverOverspentBanner(
                    count: overspentEnvelopes.length,
                    onTap: () => _showCoverOverspendingSheet(
                      context,
                      currencyCode,
                      overspentEnvelopes: overspentEnvelopes,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                ],
                _DueBannerLoader(entityId: entityId),
                _CreditCardSectionLoader(entityId: entityId),
                if (showSpotlight.value && summary != null)
                  _SpotlightOverview(
                    groups: groups,
                    summary: summary,
                    currencyCode: currencyCode,
                    hideAmounts: hideAmounts,
                    month: view?.month ?? MonthKey.fromDate(DateTime.now()),
                    onEditTargets: () => context.goNamed(
                      editPlanRoute,
                      pathParameters: {'entityId': entityId},
                    ),
                    onAssign: () =>
                        _showAutoAssignDialog(context, currencyCode),
                    onReflect: () => context.goNamed(
                      reflectRoute,
                      pathParameters: {'entityId': entityId},
                    ),
                  ),
                if (!showSpotlight.value && isSearching.value) ...[
                  TextField(
                    controller: searchController,
                    onChanged: (value) => searchQuery.value = value,
                    decoration: InputDecoration(
                      hintText: l10n.budgetSearchHint,
                      prefixIcon: const ObFieldIcon(
                        data: OpenBudgetIcons.search,
                        size: 20,
                      ),
                      suffixIcon: searchQuery.value.isNotEmpty
                          ? IconButton(
                              tooltip: l10n.dialogCancel,
                              icon: const SkribbleIcon(
                                data: OpenBudgetIcons.close,
                                size: 18,
                              ),
                              onPressed: () {
                                searchController.clear();
                                searchQuery.value = '';
                              },
                            )
                          : null,
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                ],
                if (!showSpotlight.value && groups.isEmpty)
                  ObStatePanel.empty(
                    title: l10n.budgetEmptyTitle,
                    message: l10n.budgetEmptySubtitle,
                  ),
                if (!showSpotlight.value &&
                    isSearching.value &&
                    searchQuery.value.isNotEmpty &&
                    filteredCategories.isEmpty)
                  ObStatePanel.empty(
                    title: l10n.budgetSearchNoResults,
                    message: l10n.budgetSearchHint,
                    doodle: WiredDoodleKind.cloud,
                    tone: ObTone.neutral,
                  ),
                if (!showSpotlight.value &&
                    isReordering.value &&
                    groups.isNotEmpty)
                  _ReorderableCategoryList(
                    categories: groups,
                    entityId: entityId,
                  ),
                if (!showSpotlight.value && !isReordering.value)
                  ...filteredCategories.map(
                    (group) => Padding(
                      padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                      child: CategoryGroup(
                        group: group,
                        currencyCode: currencyCode,
                        collapsed: collapsedCategoryIds.value.contains(
                          group.category.id?.toString() ?? '',
                        ),
                        onToggleCollapsed: () {
                          final categoryId =
                              group.category.id?.toString() ?? '';
                          if (categoryId.isEmpty) return;
                          final next = Set<String>.from(
                            collapsedCategoryIds.value,
                          );
                          if (!next.remove(categoryId)) {
                            next.add(categoryId);
                          }
                          collapsedCategoryIds.value = next;
                        },
                        onAddEnvelope: () => _showAddEnvelopeDialog(
                          context,
                          group.category.id?.toString() ?? '',
                          currencyCode,
                          view!.month,
                        ),
                        onEditCategory: () => _showEditCategoryDialog(
                          context,
                          group.category.id?.toString() ?? '',
                          group.category.name,
                          group.envelopes.length,
                          group.allocatedMinor,
                          currencyCode,
                        ),
                        onDeleteCategory: () => _confirmDeleteCategory(
                          context,
                          ref,
                          group,
                          currencyCode,
                        ),
                        onEditEnvelope: (envelope) {
                          final envelopeId = envelope.id?.toString() ?? '';
                          final monthEnvelope = group.envelopes.firstWhere(
                            (view) =>
                                view.envelope.id?.toString() == envelopeId,
                          );
                          _showEditEnvelopeDialog(
                            context,
                            monthEnvelope,
                            group.category.id?.toString() ?? '',
                            currencyCode,
                            view!.month,
                          );
                        },
                        onDeleteEnvelope: (envelope) => _confirmDeleteEnvelope(
                          context,
                          ref,
                          envelope.id?.toString() ?? '',
                          envelope.name,
                        ),
                        onQuickBudget: (envelope) => _showQuickBudgetDialog(
                          context,
                          envelope,
                          currencyCode,
                        ),
                        onShowActivity: (monthEnvelope) => (() {
                          final categoryId =
                              group.category.id?.toString() ?? '';
                          final envelopeId =
                              monthEnvelope.envelope.id?.toString() ?? '';
                          if (categoryId.isEmpty || envelopeId.isEmpty) {
                            return;
                          }
                          if (selectedEditor.value?.monthEnvelope.envelope.id
                                  ?.toString() ==
                              envelopeId) {
                            selectedEditor.value = null;
                            editorInput.value = '';
                            return;
                          }
                          selectedEditor.value = _InlineEditorSelection(
                            categoryId: categoryId,
                            monthEnvelope: monthEnvelope,
                          );
                          editorInput.value = '';
                        })(),
                        onReorderEnvelopes: (envelopeIds) async {
                          try {
                            await ref
                                .read(envelopeActionsProvider.notifier)
                                .reorderEnvelopes(
                                  categoryId:
                                      group.category.id?.toString() ?? '',
                                  envelopeIds: envelopeIds,
                                );
                          } on Exception catch (_) {
                            // Handled by provider re-fetch.
                          }
                        },
                        selectedEnvelopeId: selectedEditor
                            .value
                            ?.monthEnvelope
                            .envelope
                            .id
                            ?.toString(),
                        onToggleHideCategory: ({required isHidden}) async {
                          try {
                            await ref
                                .read(categoryActionsProvider.notifier)
                                .toggleHidden(
                                  categoryId:
                                      group.category.id?.toString() ?? '',
                                  entityId: entityId,
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
                                      entityId: entityId,
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
                        groups.length,
                      ),
                      icon: const SkribbleIcon(data: OpenBudgetIcons.add),
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

  List<CategoryMonthGroup> _filterCategories(
    List<CategoryMonthGroup> categories,
    String query, {
    required bool showHidden,
  }) {
    var result = categories;

    // Filter hidden categories and envelopes.
    if (!showHidden) {
      final visible = <CategoryMonthGroup>[];
      for (final group in result) {
        if (group.category.isHidden) continue;
        final visibleEnvelopes = group.envelopes
            .where((view) => !view.envelope.isHidden)
            .toList();
        visible.add(
          CategoryMonthGroup(
            category: group.category,
            envelopes: visibleEnvelopes,
          ),
        );
      }
      result = visible;
    }

    if (query.isEmpty) return result;

    final lowerQuery = query.toLowerCase();
    final filtered = <CategoryMonthGroup>[];

    for (final group in result) {
      // Check if category name matches.
      final categoryMatches = group.category.name.toLowerCase().contains(
        lowerQuery,
      );

      // Filter matching envelopes.
      final matchingEnvelopes = group.envelopes
          .where(
            (view) => view.envelope.name.toLowerCase().contains(lowerQuery),
          )
          .toList();

      if (categoryMatches || matchingEnvelopes.isNotEmpty) {
        if (categoryMatches) {
          // Show all envelopes when category name matches.
          filtered.add(group);
        } else {
          // Only show matching envelopes.
          filtered.add(
            CategoryMonthGroup(
              category: group.category,
              envelopes: matchingEnvelopes,
            ),
          );
        }
      }
    }

    return filtered;
  }

  Future<void> _applyInlineAllocation({
    required BuildContext context,
    required WidgetRef ref,
    required _InlineEditorSelection selection,
    required String currencyCode,
    required String input,
    required bool closeEditor,
    VoidCallback? onCloseEditor,
  }) async {
    final allocatedMinor = parseBudgetAmountInputToMinor(
      input: input,
      currencyCode: currencyCode,
    );
    if (allocatedMinor == null) {
      if (closeEditor) onCloseEditor?.call();
      return;
    }

    final envelopeId = selection.monthEnvelope.envelope.id?.toString() ?? '';
    if (envelopeId.isEmpty) {
      if (closeEditor) onCloseEditor?.call();
      return;
    }

    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(budgetMonthActionsProvider.notifier)
          .setAllocations(
            entityId: entityId,
            allocations: [
              AllocationInput(
                envelopeId: UuidValue.fromString(envelopeId),
                allocatedMinor: allocatedMinor,
              ),
            ],
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
    required BudgetMonthSummary summary,
    required bool onboardingComplete,
  }) {
    if (onboardingComplete) return null;
    if (summary.incomeMinor <= 0) return _PlanOnboardingType.addAccounts;
    if (summary.allocatedMinor <= 0 && summary.readyToAssignMinor > 0) {
      return _PlanOnboardingType.assignMoney;
    }
    if (summary.allocatedMinor > 0 && summary.readyToAssignMinor > 0) {
      return _PlanOnboardingType.finish;
    }
    return null;
  }

  Color _dialogBarrierColor(BuildContext context) =>
      OpenBudgetPalette.overlayScrimFor(Theme.of(context)).withAlpha(210);

  void _showAutoAssignDialog(BuildContext context, String currencyCode) {
    unawaited(
      showDialog<void>(
        context: context,
        barrierColor: _dialogBarrierColor(context),
        builder: (_) =>
            AutoAssignDialog(entityId: entityId, currencyCode: currencyCode),
      ),
    );
  }

  void _showCoverOverspendingSheet(
    BuildContext context,
    String currencyCode, {
    required List<_OverspentEnvelopeEntry> overspentEnvelopes,
  }) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: OpenBudgetPalette.transparentFor(Theme.of(context)),
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.9,
          child: _CoverOverspendingSheet(
            entityId: entityId,
            currencyCode: currencyCode,
            overspentEnvelopes: overspentEnvelopes,
          ),
        ),
      ),
    );
  }

  void _showQuickBudgetDialog(
    BuildContext context,
    Envelope envelope,
    String currencyCode, {
    int? month,
  }) {
    final selectedMonth = month ?? MonthKey.fromDate(DateTime.now());
    unawaited(
      showDialog<void>(
        context: context,
        barrierColor: _dialogBarrierColor(context),
        builder: (_) => QuickBudgetDialog(
          entityId: entityId,
          envelopeId: envelope.id?.toString() ?? '',
          envelopeName: envelope.name,
          currencyCode: currencyCode,
          month: selectedMonth,
        ),
      ),
    );
  }

  void _showEditCategoryDialog(
    BuildContext context,
    String categoryId,
    String currentName,
    int envelopeCount,
    int totalAllocatedMinor,
    String currencyCode,
  ) {
    unawaited(
      showDialog<void>(
        context: context,
        barrierColor: _dialogBarrierColor(context),
        builder: (_) => EditCategoryDialog(
          categoryId: categoryId,
          entityId: entityId,
          currentName: currentName,
          envelopeCount: envelopeCount,
          totalAllocatedMinor: totalAllocatedMinor,
          currencyCode: currencyCode,
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, int nextSortOrder) {
    unawaited(
      showDialog<void>(
        context: context,
        barrierColor: _dialogBarrierColor(context),
        builder: (_) =>
            AddCategoryDialog(entityId: entityId, nextSortOrder: nextSortOrder),
      ),
    );
  }

  void _showAddEnvelopeDialog(
    BuildContext context,
    String categoryId,
    String currencyCode,
    int month,
  ) {
    unawaited(
      showDialog<void>(
        context: context,
        barrierColor: _dialogBarrierColor(context),
        builder: (_) => AddEnvelopeDialog(
          categoryId: categoryId,
          entityId: entityId,
          currencyCode: currencyCode,
          month: month,
        ),
      ),
    );
  }

  void _showEditEnvelopeDialog(
    BuildContext context,
    EnvelopeMonthView monthEnvelope,
    String categoryId,
    String currencyCode,
    int month,
  ) {
    unawaited(
      showDialog<void>(
        context: context,
        barrierColor: _dialogBarrierColor(context),
        builder: (_) => EditEnvelopeDialog(
          monthEnvelope: monthEnvelope,
          categoryId: categoryId,
          entityId: entityId,
          currencyCode: currencyCode,
          month: month,
        ),
      ),
    );
  }

  Future<void> _confirmDeleteCategory(
    BuildContext context,
    WidgetRef ref,
    CategoryMonthGroup group,
    String currencyCode,
  ) async {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    final categoryId = group.category.id?.toString() ?? '';
    if (categoryId.isEmpty) return;

    final categoryName = group.category.name;
    final envelopeCount = group.envelopes.length;
    final totalAllocated = formatMinorForCode(
      group.allocatedMinor,
      currencyCode,
    );
    final envelopeSummary = l10n.budgetEnvelopeCount(envelopeCount);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: _dialogBarrierColor(context),
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(
          '${l10n.deleteConfirmMessage}\n\n'
          '"$categoryName"\n\n'
          '$envelopeSummary\n'
          '${l10n.budgetCategoryAllocated(totalAllocated)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: palette.overspent,
              foregroundColor: palette.onAction,
            ),
            child: Text(l10n.deleteConfirmButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(categoryActionsProvider.notifier)
          .deleteCategory(categoryId: categoryId, entityId: entityId);
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.deleteSuccess,
          variant: AppToastVariant.success,
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

  Future<void> _confirmCopyLastMonth(
    BuildContext context,
    WidgetRef ref,
    String entityId,
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
            icon: const SkribbleIcon(
              data: OpenBudgetIcons.copy,
              size: 16,
            ),
            label: Text(l10n.budgetCopyLastMonth),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(budgetMonthActionsProvider.notifier)
          .copyPreviousMonth(entityId: entityId);
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
    String envelopeName,
  ) async {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
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
              backgroundColor: palette.overspent,
              foregroundColor: palette.onAction,
            ),
            child: Text(l10n.deleteConfirmButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(envelopeActionsProvider.notifier)
          .deleteEnvelope(envelopeId: envelopeId);
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.deleteSuccess,
          variant: AppToastVariant.success,
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
}

/// Extracted popup-menu widget that independently watches display-option and
/// theme providers so changes to those providers do not rebuild the entire
/// [BudgetDetailScreen] widget tree.
class _BudgetAppBarMenu extends HookConsumerWidget {
  const _BudgetAppBarMenu({
    required this.entityId,
    required this.isSearching,
    required this.showHidden,
    required this.hiddenCount,
    required this.isReordering,
    required this.filteredCategories,
    required this.collapsedCategoryIds,
    required this.onToggleSearch,
    required this.onToggleHidden,
    required this.onReorderCategories,
    required this.onPlanSettings,
    required this.onSaveTemplate,
    required this.onRecentMoves,
  });

  final String entityId;
  final bool isSearching;
  final bool showHidden;
  final int hiddenCount;
  final bool isReordering;
  final List<CategoryMonthGroup> filteredCategories;
  final ValueNotifier<Set<String>> collapsedCategoryIds;
  final VoidCallback onToggleSearch;
  final VoidCallback onToggleHidden;
  final VoidCallback onReorderCategories;
  final VoidCallback onPlanSettings;
  final VoidCallback onSaveTemplate;
  final VoidCallback onRecentMoves;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final hideAmounts = ref.watch(hideAmountsProvider);
    final hideProgressBars = ref.watch(hideProgressBarsProvider);
    final hasRecentMoves = ref.watch(
      recentMovesForBudgetProvider(
        entityId,
      ).select((moves) => moves.isNotEmpty),
    );
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

    Widget buildMenuLabel({
      required WiredSvgIconData icon,
      required String label,
      bool checked = false,
    }) => Row(
      children: [
        SkribbleIcon(data: icon, size: 18, color: theme.ob.ink),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(child: Text(label)),
        if (checked) ...[
          const SizedBox(width: SpacingTokens.md),
          SkribbleIcon(
            data: OpenBudgetIcons.check,
            size: 18,
            color: theme.ob.funded,
          ),
        ],
      ],
    );

    return PopupMenuButton<_PlanMenuAction>(
      key: const Key('budget-plan-menu'),
      icon: SkribbleIcon(data: OpenBudgetIcons.more, color: theme.ob.ink),
      tooltip: l10n.moreTitle,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      onSelected: (action) => switch (action) {
        _PlanMenuAction.undoLastMove =>
          ref.read(recentMovesProvider.notifier).undoLast(entityId: entityId),
        _PlanMenuAction.recentMoves => navigateAfterMenuClose(onRecentMoves),
        _PlanMenuAction.toggleSearch => onToggleSearch(),
        _PlanMenuAction.toggleHidden => onToggleHidden(),
        _PlanMenuAction.reorderCategories => onReorderCategories(),
        _PlanMenuAction.saveTemplate => navigateAfterMenuClose(onSaveTemplate),
        _PlanMenuAction.toggleTheme =>
          ref
              .read(themeModeProvider.notifier)
              .setThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark),
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
        _PlanMenuAction.planSettings => navigateAfterMenuClose(onPlanSettings),
      },
      itemBuilder: (context) => [
        PopupMenuItem<_PlanMenuAction>(
          value: _PlanMenuAction.recentMoves,
          child: buildMenuLabel(
            icon: OpenBudgetIcons.history,
            label: l10n.recentMovesTitle,
          ),
        ),
        PopupMenuItem<_PlanMenuAction>(
          value: _PlanMenuAction.undoLastMove,
          enabled: hasRecentMoves,
          child: buildMenuLabel(
            icon: OpenBudgetIcons.undo,
            label: l10n.undoAction,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<_PlanMenuAction>(
          value: _PlanMenuAction.toggleSearch,
          child: buildMenuLabel(
            icon: OpenBudgetIcons.search,
            label: l10n.budgetSearchHint,
            checked: isSearching,
          ),
        ),
        PopupMenuItem<_PlanMenuAction>(
          value: _PlanMenuAction.toggleHidden,
          child: buildMenuLabel(
            icon: OpenBudgetIcons.hidden,
            label: showHidden
                ? l10n.budgetShowHidden
                : hiddenCount > 0
                ? l10n.budgetHiddenCount(hiddenCount)
                : l10n.budgetShowHidden,
            checked: showHidden,
          ),
        ),
        PopupMenuItem<_PlanMenuAction>(
          value: _PlanMenuAction.reorderCategories,
          enabled: !isReordering,
          child: buildMenuLabel(
            icon: OpenBudgetIcons.sort,
            label: l10n.budgetReorderCategories,
          ),
        ),
        PopupMenuItem<_PlanMenuAction>(
          value: _PlanMenuAction.saveTemplate,
          child: buildMenuLabel(
            icon: OpenBudgetIcons.bookmark,
            label: l10n.templateTitle,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<_PlanMenuAction>(
          value: _PlanMenuAction.toggleTheme,
          child: buildMenuLabel(
            icon: isDarkMode
                ? OpenBudgetIcons.lightMode
                : OpenBudgetIcons.darkMode,
            label: isDarkMode ? l10n.themeLight : l10n.themeDark,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<_PlanMenuAction>(
          value: _PlanMenuAction.collapseExpand,
          child: buildMenuLabel(
            icon: OpenBudgetIcons.expand,
            label: l10n.budgetCollapseExpand,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<_PlanMenuAction>(
          value: _PlanMenuAction.hideProgressBars,
          child: buildMenuLabel(
            icon: OpenBudgetIcons.scale,
            label: l10n.settingsHideProgressBars,
            checked: hideProgressBars,
          ),
        ),
        PopupMenuItem<_PlanMenuAction>(
          value: _PlanMenuAction.hideAmounts,
          child: buildMenuLabel(
            icon: OpenBudgetIcons.hidden,
            label: l10n.settingsHideAmounts,
            checked: hideAmounts,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<_PlanMenuAction>(
          value: _PlanMenuAction.planSettings,
          child: buildMenuLabel(
            icon: OpenBudgetIcons.settings,
            label: l10n.settingsPlanSettings,
          ),
        ),
      ],
    );
  }
}

/// Watches [creditCardPaymentsProvider] independently so credit card data
/// changes do not rebuild the entire budget detail screen.
class _CreditCardSectionLoader extends HookConsumerWidget {
  const _CreditCardSectionLoader({required this.entityId});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ccPayments = ref.watch(creditCardPaymentsProvider(entityId));

    if (!ccPayments.hasValue || ccPayments.value!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.md),
      child: CreditCardSection(payments: ccPayments.value!),
    );
  }
}

/// Watches [recurringDueCountProvider] independently so recurring-due changes
/// do not rebuild the entire budget detail screen. The server posts due
/// transactions itself; tapping goes to the recurring list.
class _DueBannerLoader extends HookConsumerWidget {
  const _DueBannerLoader({required this.entityId});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueCountAsync = ref.watch(recurringDueCountProvider(entityId));

    if (!dueCountAsync.hasValue || dueCountAsync.value! <= 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.md),
      child: _DueBanner(
        count: dueCountAsync.value!,
        onTap: () => unawaited(
          context.pushNamed(
            recurringListRoute,
            pathParameters: {'entityId': entityId},
          ),
        ),
      ),
    );
  }
}

/// Watches [reviewQueueProvider] independently so the review count does not
/// rebuild the entire budget detail screen.
class _ReviewTransactionsBannerLoader extends HookConsumerWidget {
  const _ReviewTransactionsBannerLoader({required this.entityId});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewTransactionCount = ref.watch(
      reviewQueueProvider(entityId).select(
        (asyncValue) => asyncValue.when(
          data: (queue) => queue.length,
          loading: () => 0,
          error: (_, _) => 0,
        ),
      ),
    );

    if (reviewTransactionCount <= 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: _ReviewTransactionsBanner(
        count: reviewTransactionCount,
        onTap: () => showReviewTransactionsSheet(context, entityId: entityId),
      ),
    );
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
    final palette = theme.ob;
    final (tone, icon, title, body, prompt, primaryLabel) = switch (type) {
      _PlanOnboardingType.addAccounts => (
        ObTone.brand,
        OpenBudgetIcons.bank,
        l10n.budgetOnboardingAddAccountsTitle,
        l10n.budgetOnboardingAddAccountsBody,
        null,
        l10n.budgetOnboardingAddAccountsCta,
      ),
      _PlanOnboardingType.assignMoney => (
        ObTone.funded,
        OpenBudgetIcons.envelopeOpen,
        l10n.budgetOnboardingAssignMoneyTitle(readyToAssign),
        l10n.budgetOnboardingAssignMoneyBody,
        l10n.budgetOnboardingAssignMoneyPrompt,
        l10n.budgetAssignMoney,
      ),
      _PlanOnboardingType.finish => (
        ObTone.review,
        OpenBudgetIcons.sparkle,
        l10n.budgetOnboardingFinishTitle,
        l10n.budgetOnboardingFinishBody,
        null,
        l10n.budgetOnboardingFinishCta,
      ),
    };

    return ObCard(
      tone: tone,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        children: [
          SkribbleIcon(data: icon, size: 44, color: palette.hue(tone)),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: palette.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            body,
            style: theme.textTheme.bodyLarge?.copyWith(color: palette.ink),
            textAlign: TextAlign.center,
          ),
          if (prompt != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text(
              prompt,
              style: theme.textTheme.bodyLarge?.copyWith(color: palette.ink),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: SpacingTokens.md),
          FilledButton(
            onPressed: onPrimaryAction,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(primaryLabel),
          ),
          if (onSecondaryAction != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            OutlinedButton(
              onPressed: onSecondaryAction,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
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

    return ObCard(
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: l10n.budgetDetailCategories,
              selected: !showSpotlight,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: l10n.budgetDetailSpotlight,
              selected: showSpotlight,
              onTap: () => onChanged(true),
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
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: ObRoughDecoration(
              color: selected ? palette.highlight : null,
              outline: selected ? palette.quietPen : null,
              radius: 8,
              strokeWidth: 1.4,
              seed: 41,
            ),
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? palette.ink : palette.mutedInk,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpotlightOverview extends HookWidget {
  const _SpotlightOverview({
    required this.groups,
    required this.summary,
    required this.currencyCode,
    required this.hideAmounts,
    required this.month,
    required this.onEditTargets,
    required this.onAssign,
    required this.onReflect,
  });

  final List<CategoryMonthGroup> groups;
  final BudgetMonthSummary summary;
  final String currencyCode;
  final bool hideAmounts;
  final int month;
  final VoidCallback onEditTargets;
  final VoidCallback onAssign;
  final VoidCallback onReflect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    var totalTargetsMinor = 0;
    var totalUnderfundedMinor = 0;

    for (final group in groups) {
      for (final envelopeView in group.envelopes) {
        final goal = envelopeView.goal;
        if (goal == null) continue;
        totalTargetsMinor += goal.amountMinor;
        totalUnderfundedMinor += envelopeView.goalUnderfundedMinor;
      }
    }

    final summaryTitle =
        '${_monthLabel(l10n, month)} ${l10n.budgetSpotlightSummarySuffix}';

    return Column(
      children: [
        ObCard(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SpotlightPriorityIcon(
                    icon: OpenBudgetIcons.groceries,
                    rotation: -0.12,
                  ),
                  SizedBox(width: SpacingTokens.sm),
                  _SpotlightPriorityIcon(
                    icon: OpenBudgetIcons.transport,
                    rotation: 0.08,
                  ),
                  SizedBox(width: SpacingTokens.sm),
                  _SpotlightPriorityIcon(
                    icon: OpenBudgetIcons.flower,
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
                  color: Theme.of(context).ob.mutedInk,
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
        ObCard(
          padding: const EdgeInsets.all(SpacingTokens.md),
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
                        icon: OpenBudgetIcons.goal,
                        label: l10n.budgetSpotlightTotalTargets,
                        tone: ObTone.brand,
                        value: hideAmounts
                            ? hiddenAmountPlaceholder
                            : formatMinorForCode(
                                totalTargetsMinor,
                                currencyCode,
                              ),
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
                        icon: OpenBudgetIcons.pieChart,
                        label: l10n.budgetSpotlightUnderfunded,
                        tone: ObTone.underfunded,
                        value: hideAmounts
                            ? hiddenAmountPlaceholder
                            : formatMinorForCode(
                                totalUnderfundedMinor,
                                currencyCode,
                              ),
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
                        icon: OpenBudgetIcons.checkCircle,
                        label: l10n.budgetSpotlightAssigned,
                        tone: ObTone.funded,
                        value: hideAmounts
                            ? hiddenAmountPlaceholder
                            : formatMinorForCode(
                                summary.allocatedMinor,
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
                        icon: OpenBudgetIcons.payment,
                        label: l10n.budgetSpotlightSpent,
                        tone: ObTone.overspent,
                        value: hideAmounts
                            ? hiddenAmountPlaceholder
                            : formatMinorForCode(
                                summary.activityMinor.abs(),
                                currencyCode,
                              ),
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

  String _monthLabel(AppLocalizations l10n, int month) => switch (month % 100) {
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
    this.tone = ObTone.neutral,
  });

  final WiredSvgIconData icon;
  final String label;
  final String value;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final ObTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;

    return ObCard(
      tone: tone,
      padding: const EdgeInsets.all(SpacingTokens.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkribbleIcon(data: icon, size: 18, color: palette.hue(tone)),
              const SizedBox(width: SpacingTokens.xs),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (actionLabel != null)
                TextButton(
                  onPressed: onActionTap,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.xs + 2,
                      vertical: 2,
                    ),
                  ),
                  child: Text(
                    actionLabel!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.hue(tone),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs + 2),
          ObAmount(
            value,
            tone: tone,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _SpotlightPriorityIcon extends HookWidget {
  const _SpotlightPriorityIcon({required this.icon, required this.rotation});

  final WiredSvgIconData icon;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).ob;
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: ObRoughDecoration(
          color: palette.brandWash,
          outline: palette.quietPen,
          seed: 43,
        ),
        child: SkribbleIcon(data: icon, color: palette.brand),
      ),
    );
  }
}

class _InlineEditorSelection {
  const _InlineEditorSelection({
    required this.categoryId,
    required this.monthEnvelope,
  });

  final String categoryId;
  final EnvelopeMonthView monthEnvelope;
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
    final palette = theme.ob;
    final canApply = inputValue.isNotEmpty && inputValue != '-';
    const actionRowHeight = 70.0;

    Widget key(
      String label, {
      VoidCallback? onPressed,
      bool primary = false,
      Widget? child,
      double minHeight = 48,
    }) => Expanded(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xs),
        child: SizedBox(
          height: minHeight,
          child: primary
              ? FilledButton(
                  onPressed: onPressed,
                  child: child ?? Text(label),
                )
              : OutlinedButton(
                  onPressed: onPressed,
                  child: child ?? Text(label),
                ),
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.line)),
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
                child: ObAmount(
                  amountLabel,
                  style: theme.textTheme.headlineSmall,
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
                  key('7', onPressed: () => onDigit('7')),
                  key('8', onPressed: () => onDigit('8')),
                  key('9', onPressed: () => onDigit('9')),
                  key('-', onPressed: onNegative),
                ],
              ),
              Row(
                children: [
                  key('4', onPressed: () => onDigit('4')),
                  key('5', onPressed: () => onDigit('5')),
                  key('6', onPressed: () => onDigit('6')),
                  key('+', onPressed: onPositive),
                ],
              ),
              Row(
                children: [
                  key('1', onPressed: () => onDigit('1')),
                  key('2', onPressed: () => onDigit('2')),
                  key('3', onPressed: () => onDigit('3')),
                  key('=', onPressed: canApply ? onApply : null),
                ],
              ),
              Row(
                children: [
                  key(
                    '',
                    onPressed: onCancel,
                    child: Tooltip(
                      message: l10n.dialogCancel,
                      child: SkribbleIcon(
                        data: OpenBudgetIcons.close,
                        color: palette.ink,
                      ),
                    ),
                  ),
                  key('0', onPressed: () => onDigit('0')),
                  key(
                    '',
                    onPressed: onBackspace,
                    child: Tooltip(
                      message: l10n.budgetBackspaceLabel,
                      child: SkribbleIcon(
                        data: OpenBudgetIcons.backspace,
                        color: palette.ink,
                      ),
                    ),
                  ),
                  key(
                    '',
                    onPressed: onDone,
                    primary: true,
                    child: Tooltip(
                      message: l10n.dialogDone,
                      child: SkribbleIcon(
                        data: OpenBudgetIcons.enter,
                        color: palette.onAction,
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
  const _DueBanner({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    return ObCard(
      onTap: onTap,
      tone: ObTone.brand,
      padding: const EdgeInsets.all(SpacingTokens.sm),
      child: Row(
        children: [
          SkribbleIcon(
            data: OpenBudgetIcons.recurring,
            size: 20,
            color: palette.brand,
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(
              l10n.recurringDueBanner(count),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.ink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          SkribbleIcon(
            data: OpenBudgetIcons.chevronRight,
            size: 18,
            color: palette.mutedInk,
          ),
        ],
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    return ObCard(
      onTap: onTap,
      padding: const EdgeInsets.all(SpacingTokens.sm),
      child: Row(
        children: [
          ObToneChip(
            label: '$count',
            tone: ObTone.review,
            icon: SkribbleIcon(
              data: OpenBudgetIcons.taskDone,
              size: 14,
              color: palette.review,
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(
              l10n.budgetReviewTransactions(count),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: palette.ink,
              ),
            ),
          ),
          SkribbleIcon(
            data: OpenBudgetIcons.chevronRight,
            size: 18,
            color: palette.mutedInk,
          ),
        ],
      ),
    );
  }
}

class _OverspentEnvelopeEntry {
  const _OverspentEnvelopeEntry({
    required this.categoryId,
    required this.envelopeId,
    required this.envelopeName,
    required this.overspentMinor,
    required this.allocatedMinor,
  });

  final String categoryId;
  final String envelopeId;
  final String envelopeName;
  final int overspentMinor;
  final int allocatedMinor;
}

class _CoverOverspentBanner extends HookWidget {
  const _CoverOverspentBanner({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    return ObCard(
      onTap: onTap,
      padding: const EdgeInsets.all(SpacingTokens.sm),
      child: Row(
        children: [
          ObToneChip(
            label: '$count',
            tone: ObTone.overspent,
            icon: SkribbleIcon(
              data: OpenBudgetIcons.warning,
              size: 14,
              color: palette.overspent,
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(
              l10n.budgetCoverOverspentCategories(count),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: palette.ink,
              ),
            ),
          ),
          SkribbleIcon(
            data: OpenBudgetIcons.chevronRight,
            size: 18,
            color: palette.mutedInk,
          ),
        ],
      ),
    );
  }
}

class _CoverOverspendingSheet extends HookConsumerWidget {
  const _CoverOverspendingSheet({
    required this.entityId,
    required this.currencyCode,
    required this.overspentEnvelopes,
  });

  final String entityId;
  final String currencyCode;
  final List<_OverspentEnvelopeEntry> overspentEnvelopes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final remainingItems = useState(
      List<_OverspentEnvelopeEntry>.of(overspentEnvelopes),
    );
    final isApplying = useState(false);

    Future<void> invalidateMonth() async {
      ref
        ..invalidate(budgetMonthProvider(entityId))
        ..invalidate(budgetMonthGroupsProvider(entityId));
    }

    Future<void> coverEnvelope(_OverspentEnvelopeEntry item) async {
      if (isApplying.value) return;
      isApplying.value = true;
      try {
        await ref
            .read(budgetMonthActionsProvider.notifier)
            .setAllocations(
              entityId: entityId,
              allocations: [
                AllocationInput(
                  envelopeId: UuidValue.fromString(item.envelopeId),
                  allocatedMinor: item.allocatedMinor + item.overspentMinor,
                ),
              ],
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
        await invalidateMonth();
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
                .read(budgetMonthActionsProvider.notifier)
                .setAllocations(
                  entityId: entityId,
                  allocations: [
                    AllocationInput(
                      envelopeId: UuidValue.fromString(item.envelopeId),
                      allocatedMinor: item.allocatedMinor + item.overspentMinor,
                    ),
                  ],
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
        await invalidateMonth();
        isApplying.value = false;
      }
    }

    final isApplyingValue = isApplying.value;
    final items = remainingItems.value;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: SpacingTokens.sm),
            Text(
              l10n.budgetDetailCoverOverspendingTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: palette.ink,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: SpacingTokens.sm),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.dialogDone),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.lg,
                        ),
                        child: ObStatePanel.empty(
                          title: l10n.budgetDetailAllOverspendingCovered,
                          doodle: WiredDoodleKind.flower,
                          tone: ObTone.funded,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(SpacingTokens.md),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ObCard(
                          child: ListTile(
                            title: Text(
                              item.envelopeName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: palette.ink,
                              ),
                            ),
                            subtitle: Text(
                              l10n.budgetDetailNeedsToCover(
                                formatMinorForCode(
                                  item.overspentMinor,
                                  currencyCode,
                                ),
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: palette.mutedInk,
                              ),
                            ),
                            trailing: FilledButton(
                              onPressed: isApplyingValue
                                  ? null
                                  : () => coverEnvelope(item),
                              child: Text(l10n.budgetDetailCoverButton),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: SpacingTokens.sm),
                      itemCount: items.length,
                    ),
            ),
            if (items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  SpacingTokens.md,
                  SpacingTokens.xs,
                  SpacingTokens.md,
                  SpacingTokens.md,
                ),
                child: FilledButton(
                  onPressed: isApplyingValue ? null : coverAll,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(
                    isApplyingValue
                        ? l10n.budgetDetailCovering
                        : l10n.budgetDetailCoverOverspent(items.length),
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
    required this.entityId,
  });

  final List<CategoryMonthGroup> categories;
  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final orderedCategories = useState(List.of(categories));

    // Sync with provider state when categories change.
    useEffect(() {
      orderedCategories.value = List.of(categories);
      return null;
    }, [categories]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ObSectionHeader(
          title: l10n.budgetReorderCategories,
          subtitle: l10n.budgetReorderHint,
          padding: const EdgeInsets.only(
            left: SpacingTokens.xs,
            bottom: SpacingTokens.sm,
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
    ValueNotifier<List<CategoryMonthGroup>> orderedCategories,
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
          .reorderCategories(entityId: entityId, categoryIds: categoryIds);
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

  final CategoryMonthGroup category;
  final int index;
  final int total;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: ObCard(
        child: ListTile(
          leading: SkribbleIcon(
            data: OpenBudgetIcons.drag,
            color: palette.mutedInk,
          ),
          title: Text(
            category.category.name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: palette.ink,
            ),
          ),
          subtitle: Text(
            l10n.budgetEnvelopeCount(category.envelopes.length),
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.mutedInk,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const SkribbleIcon(
                  data: OpenBudgetIcons.chevronUp,
                  size: 20,
                ),
                tooltip: l10n.editPlanMoveUp,
                onPressed: onMoveUp,
              ),
              IconButton(
                icon: const SkribbleIcon(
                  data: OpenBudgetIcons.chevronDown,
                  size: 20,
                ),
                tooltip: l10n.editPlanMoveDown,
                onPressed: onMoveDown,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
