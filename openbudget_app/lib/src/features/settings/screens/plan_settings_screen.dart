import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/home/providers/budget_actions_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class PlanSettingsScreen extends HookConsumerWidget {
  const PlanSettingsScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final budgetAsync = ref.watch(budgetDetailProvider(budgetId));
    final numberFormat = ref.watch(numberFormatStyleProvider);
    final currencyPlacement = ref.watch(currencyPlacementStyleProvider);
    final dateFormat = ref.watch(dateFormatStyleProvider);
    final theme = Theme.of(context);
    final palette = theme.ob;

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () =>
              context.goNamed(settingsRoute, pathParameters: {'id': budgetId}),
          child: Text(l10n.dialogCancel),
        ),
        leadingWidth: 92,
        title: Text(l10n.settingsPlanSettings),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.goNamed(
              settingsRoute,
              pathParameters: {'id': budgetId},
            ),
            child: Text(l10n.dialogDone),
          ),
        ],
      ),
      body: budgetAsync.when(
        loading: () => ObLoadingPanel(label: l10n.settingsLoading),
        error: (_, _) => Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: ObStatePanel.problem(title: l10n.settingsLoadError),
        ),
        data: (budget) {
          final currency = parseCurrencyCode(budget.currencyCode);

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.xl,
            ),
            children: [
              ObCard(
                child: ListTile(
                  title: Text(
                    budget.name,
                    style: theme.textTheme.titleMedium,
                  ),
                  trailing: SkribbleIcon(
                    data: OpenBudgetIcons.edit,
                    size: 20,
                    color: palette.mutedInk,
                  ),
                  onTap: () => _showRenameBudgetDialog(context, ref, budget),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _SettingChoiceTile(
                      title: l10n.settingsCurrency,
                      value: '${currency.displayName} - ${currency.code}',
                      isNavigation: true,
                      onTap: () => context.goNamed(
                        currencySettingsRoute,
                        pathParameters: {'id': budgetId},
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingChoiceTile(
                      title: l10n.settingsNumberFormat,
                      value: _numberFormatLabel(l10n, numberFormat),
                      onTap: () => _selectNumberFormat(context, ref),
                    ),
                    const Divider(height: 1),
                    _SettingChoiceTile(
                      title: l10n.settingsCurrencyPlacement,
                      value: _currencyPlacementLabel(l10n, currencyPlacement),
                      onTap: () => _selectCurrencyPlacement(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              Card(
                clipBehavior: Clip.antiAlias,
                child: _SettingChoiceTile(
                  title: l10n.settingsDateFormat,
                  value: _dateFormatLabel(l10n, dateFormat),
                  onTap: () => _selectDateFormat(context, ref),
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),
              FilledButton(
                onPressed: () => _confirmDeletePlan(context, ref, budget),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.overspentWash,
                  foregroundColor: palette.overspent,
                ),
                child: Text(l10n.settingsDeletePlan),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showRenameBudgetDialog(
    BuildContext context,
    WidgetRef ref,
    Budget budget,
  ) async {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    final controller = TextEditingController(text: budget.name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsRenameBudget),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.createBudgetNameLabel,
            prefixIcon: SkribbleIcon(
              data: OpenBudgetIcons.label,
              size: 20,
              color: palette.mutedInk,
            ),
          ),
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => Navigator.of(ctx).pop(true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.dialogSave),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final name = controller.text.trim();
    controller.dispose();
    if (name.isEmpty || name == budget.name) return;

    try {
      final client = ref.read(serverpodClientProvider);
      await client.budget.update(UuidValue.fromString(budgetId), name: name);
      ref.invalidate(budgetDetailProvider(budgetId));
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.settingsRenameSuccess,
        variant: AppToastVariant.success,
      );
    } on Exception catch (_) {
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.settingsRenameError,
        variant: AppToastVariant.error,
      );
    }
  }

  Future<void> _confirmDeletePlan(
    BuildContext context,
    WidgetRef ref,
    Budget budget,
  ) async {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.budgetDeleteTitle),
        content: Text(l10n.budgetDeleteConfirm(budget.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: palette.overspentWash,
              foregroundColor: palette.overspent,
            ),
            child: Text(l10n.budgetDeleteButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(budgetActionsProvider.notifier)
          .deleteBudget(budgetId: budgetId);
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.budgetDeleteSuccess,
          variant: AppToastVariant.success,
        );
        context.go(homePath);
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.budgetDeleteError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

  Future<void> _selectNumberFormat(BuildContext context, WidgetRef ref) async {
    final selected = await _showChoiceBottomSheet<NumberFormatStyle>(
      context,
      options: NumberFormatStyle.values,
      current: ref.read(numberFormatStyleProvider),
      labelBuilder: (option) =>
          _numberFormatLabel(AppLocalizations.of(context), option),
    );
    if (selected == null) return;
    ref.read(numberFormatStyleProvider.notifier).setNumberFormat(selected);
  }

  Future<void> _selectCurrencyPlacement(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final selected = await _showChoiceBottomSheet<CurrencyPlacementStyle>(
      context,
      options: CurrencyPlacementStyle.values,
      current: ref.read(currencyPlacementStyleProvider),
      labelBuilder: (option) =>
          _currencyPlacementLabel(AppLocalizations.of(context), option),
    );
    if (selected == null) return;
    ref
        .read(currencyPlacementStyleProvider.notifier)
        .setCurrencyPlacement(selected);
  }

  Future<void> _selectDateFormat(BuildContext context, WidgetRef ref) async {
    final selected = await _showChoiceBottomSheet<DateFormatStyle>(
      context,
      options: DateFormatStyle.values,
      current: ref.read(dateFormatStyleProvider),
      labelBuilder: (option) =>
          _dateFormatLabel(AppLocalizations.of(context), option),
    );
    if (selected == null) return;
    ref.read(dateFormatStyleProvider.notifier).setDateFormat(selected);
  }

  Future<T?> _showChoiceBottomSheet<T>(
    BuildContext context, {
    required List<T> options,
    required T current,
    required String Function(T option) labelBuilder,
  }) => showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: options.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final option = options[index];
          final selected = option == current;
          return ListTile(
            title: Text(labelBuilder(option)),
            selected: selected,
            trailing: selected
                ? const SkribbleIcon(data: OpenBudgetIcons.check)
                : null,
            onTap: () => Navigator.of(context).pop(option),
          );
        },
      ),
    ),
  );
}

String _numberFormatLabel(AppLocalizations l10n, NumberFormatStyle style) =>
    switch (style) {
      NumberFormatStyle.standard => l10n.settingsNumberFormatStandard,
      NumberFormatStyle.european => l10n.settingsNumberFormatEuropean,
    };

String _currencyPlacementLabel(
  AppLocalizations l10n,
  CurrencyPlacementStyle style,
) => switch (style) {
  CurrencyPlacementStyle.beforeAmount => l10n.settingsCurrencyPlacementBefore,
  CurrencyPlacementStyle.afterAmount => l10n.settingsCurrencyPlacementAfter,
};

String _dateFormatLabel(AppLocalizations l10n, DateFormatStyle style) =>
    switch (style) {
      DateFormatStyle.monthDayYear => l10n.settingsDateFormatMonthDayYear,
      DateFormatStyle.dayMonthYear => l10n.settingsDateFormatDayMonthYear,
      DateFormatStyle.yearMonthDay => l10n.settingsDateFormatYearMonthDay,
    };

class _SettingChoiceTile extends HookWidget {
  const _SettingChoiceTile({
    required this.title,
    required this.value,
    required this.onTap,
    this.isNavigation = false,
  });

  final String title;
  final String value;
  final VoidCallback onTap;
  final bool isNavigation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return ListTile(
      onTap: onTap,
      title: Text(title),
      subtitle: Text(
        value,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: SkribbleIcon(
        data: isNavigation
            ? OpenBudgetIcons.chevronRight
            : OpenBudgetIcons.expand,
        size: 20,
        color: palette.mutedInk,
      ),
    );
  }
}
