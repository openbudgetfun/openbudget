// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_app/src/theme/ynab_palette.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class CurrencySettingsScreen extends HookConsumerWidget {
  const CurrencySettingsScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final budgetAsync = ref.watch(budgetDetailProvider(budgetId));
    final numberFormat = ref.watch(numberFormatStyleProvider);
    final currencyPlacement = ref.watch(currencyPlacementStyleProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: YnabPalette.appBackground,
      appBar: AppBar(
        backgroundColor: YnabPalette.appBackground,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.settingsCurrency),
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
          final selectedCurrency = parseCurrencyCode(budget.currencyCode);

          return ListView(
            padding: const EdgeInsets.all(SpacingTokens.md),
            children: [
              _SettingsCard(
                child: Column(
                  children: [
                    _SettingsTile(
                      title: l10n.settingsCurrency,
                      value:
                          '${selectedCurrency.displayName} - ${selectedCurrency.code}',
                      onTap: () =>
                          _selectCurrency(context, ref, selectedCurrency),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      title: l10n.settingsNumberFormat,
                      value: _numberFormatLabel(l10n, numberFormat),
                      onTap: () => _selectNumberFormat(context, ref),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      title: l10n.settingsCurrencyPlacement,
                      value: _currencyPlacementLabel(l10n, currencyPlacement),
                      onTap: () => _selectCurrencyPlacement(context, ref),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _selectCurrency(
    BuildContext context,
    WidgetRef ref,
    CurrencyCode current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<CurrencyCode>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: CurrencyCode.values.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final currency = CurrencyCode.values[index];
            return ListTile(
              title: Text('${currency.displayName} (${currency.code})'),
              trailing: currency == current
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () => Navigator.of(context).pop(currency),
            );
          },
        ),
      ),
    );

    if (selected == null || selected == current || !context.mounted) return;

    final colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final client = ref.read(serverpodClientProvider);
      await client.budget.update(
        UuidValue.fromString(budgetId),
        currencyCode: selected.code,
      );
      ref
        ..invalidate(budgetDetailProvider(budgetId))
        ..invalidate(budgetSummaryProvider(budgetId));

      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsCurrencyUpdated(selected.code))),
      );
    } on Exception catch (_) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.settingsCurrencyUpdateError),
          backgroundColor: colorScheme.error,
        ),
      );
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

  Future<T?> _showChoiceBottomSheet<T>(
    BuildContext context, {
    required List<T> options,
    required T current,
    required String Function(T option) labelBuilder,
  }) {
    return showModalBottomSheet<T>(
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
}

String _numberFormatLabel(AppLocalizations l10n, NumberFormatStyle style) {
  return switch (style) {
    NumberFormatStyle.standard => l10n.settingsNumberFormatStandard,
    NumberFormatStyle.european => l10n.settingsNumberFormatEuropean,
  };
}

String _currencyPlacementLabel(
  AppLocalizations l10n,
  CurrencyPlacementStyle style,
) {
  return switch (style) {
    CurrencyPlacementStyle.beforeAmount => l10n.settingsCurrencyPlacementBefore,
    CurrencyPlacementStyle.afterAmount => l10n.settingsCurrencyPlacementAfter,
  };
}

class _SettingsCard extends HookWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: YnabPalette.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(color: YnabPalette.divider),
      ),
      child: child,
    );
  }
}

class _SettingsTile extends HookWidget {
  const _SettingsTile({
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

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
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}
