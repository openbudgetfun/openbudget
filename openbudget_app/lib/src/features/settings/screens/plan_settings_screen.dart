// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

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
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
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
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
      appBar: AppBar(
        backgroundColor: OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
        surfaceTintColor: OpenBudgetPalette.transparentFor(Theme.of(context)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        leadingWidth: 92,
        leading: TextButton(
          onPressed: () =>
              context.goNamed(settingsRoute, pathParameters: {'id': budgetId}),
          child: Text(
            l10n.dialogCancel,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        title: Text(
          l10n.settingsPlanSettings,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.goNamed(
              settingsRoute,
              pathParameters: {'id': budgetId},
            ),
            child: Text(
              l10n.dialogDone,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: budgetAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(
            l10n.settingsLoadError,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ),
        data: (budget) {
          final currency = parseCurrencyCode(budget.currencyCode);

          return ListView(
            padding: const EdgeInsets.all(SpacingTokens.md),
            children: [
              _SettingsCard(
                child: ListTile(
                  title: Text(
                    budget.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => _showRenameBudgetDialog(context, ref, budget),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              _SettingsCard(
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
              _SettingsCard(
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
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RadiusTokens.md),
                  ),
                  backgroundColor: OpenBudgetPalette.fgErrorFor(
                    Theme.of(context),
                  ).withAlpha(24),
                  foregroundColor: OpenBudgetPalette.fgErrorFor(
                    Theme.of(context),
                  ),
                  elevation: 0,
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
    final controller = TextEditingController(text: budget.name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsRenameBudget),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.createBudgetNameLabel,
            prefixIcon: const Icon(Icons.label_outlined),
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
    final colorScheme = Theme.of(context).colorScheme;
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
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
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
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final option = options[index];
            final selected = option == current;
            return ListTile(
              title: Text(labelBuilder(option)),
              trailing: selected ? const Icon(Icons.check_rounded) : null,
              onTap: () => Navigator.of(context).pop(option),
            );
          },
        ),
      ),
    );
}

String _numberFormatLabel(AppLocalizations l10n, NumberFormatStyle style) => switch (style) {
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

String _dateFormatLabel(AppLocalizations l10n, DateFormatStyle style) => switch (style) {
    DateFormatStyle.monthDayYear => l10n.settingsDateFormatMonthDayYear,
    DateFormatStyle.dayMonthYear => l10n.settingsDateFormatDayMonthYear,
    DateFormatStyle.yearMonthDay => l10n.settingsDateFormatYearMonthDay,
  };

class _SettingsCard extends HookWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
      decoration: BoxDecoration(
        color: OpenBudgetPalette.bgSecondaryFor(Theme.of(context)),
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(
          color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
        ),
      ),
      child: child,
    );
}

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
    return ListTile(
      onTap: onTap,
      title: Text(title),
      subtitle: Text(
        value,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        isNavigation ? Icons.chevron_right_rounded : Icons.unfold_more_rounded,
        color: OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
      ),
    );
  }
}
