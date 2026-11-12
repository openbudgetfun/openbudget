import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/reporting_currency_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class CurrencySettingsScreen extends HookConsumerWidget {
  const CurrencySettingsScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(userSettingsProvider);
    final numberFormat = ref.watch(numberFormatStyleProvider);
    final currencyPlacement = ref.watch(currencyPlacementStyleProvider);

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => context.goNamed(
            planSettingsRoute,
            pathParameters: {'entityId': entityId},
          ),
          child: Text(l10n.dialogCancel),
        ),
        leadingWidth: 92,
        title: Text(l10n.settingsCurrency),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.goNamed(
              planSettingsRoute,
              pathParameters: {'entityId': entityId},
            ),
            child: Text(l10n.dialogDone),
          ),
        ],
      ),
      body: settingsAsync.when(
        loading: () => ObLoadingPanel(label: l10n.settingsLoading),
        error: (_, _) => Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: ObStatePanel.problem(title: l10n.settingsLoadError),
        ),
        data: (settings) {
          final selectedCurrency = CurrencyCode.tryParse(
            settings.reportingCurrencyCode,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.xl,
            ),
            children: [
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _SettingsTile(
                      title: l10n.settingsReportingCurrency,
                      value: selectedCurrency == null
                          ? normalizeCurrencyCode(settings.reportingCurrencyCode)
                          : '${selectedCurrency.displayName} - ${selectedCurrency.code}',
                      isNavigation: true,
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
    CurrencyCode? current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<CurrencyCode>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: CurrencyCode.values.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final currency = CurrencyCode.values[index];
            return ListTile(
              title: Text('${currency.displayName} (${currency.code})'),
              selected: currency == current,
              trailing: currency == current
                  ? const SkribbleIcon(data: OpenBudgetIcons.check)
                  : null,
              onTap: () => Navigator.of(context).pop(currency),
            );
          },
        ),
      ),
    );

    if (selected == null || selected == current || !context.mounted) return;

    try {
      await ref
          .read(reportingCurrencyActionsProvider.notifier)
          .setReportingCurrency(selected.code);
      ref.invalidate(netWorthProvider);

      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.settingsCurrencyUpdated(selected.code),
        variant: AppToastVariant.success,
      );
    } on Exception catch (_) {
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.settingsCurrencyUpdateError,
        variant: AppToastVariant.error,
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

class _SettingsTile extends HookWidget {
  const _SettingsTile({
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
