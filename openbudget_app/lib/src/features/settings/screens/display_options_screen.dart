import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/display_currency_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/providers/theme_mode_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class DisplayOptionsScreen extends HookConsumerWidget {
  const DisplayOptionsScreen({required this.budgetId, super.key});

  static const List<CurrencyCode> _supportedDisplayCurrencies = [
    CurrencyCode.usd,
    CurrencyCode.eur,
    CurrencyCode.gbp,
    CurrencyCode.jpy,
    CurrencyCode.btc,
  ];

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currentThemeMode = ref.watch(themeModeProvider);
    final isDarkMode =
        currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            theme.brightness == Brightness.dark);
    final currentBalanceStyle = ref.watch(balanceStyleProvider);
    final hideAmounts = ref.watch(hideAmountsProvider);
    final hideProgressBars = ref.watch(hideProgressBarsProvider);
    final budgetAsync = ref.watch(budgetDetailProvider(budgetId));

    return Scaffold(
      backgroundColor: OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
      appBar: AppBar(
        backgroundColor: OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
        surfaceTintColor: OpenBudgetPalette.transparentFor(Theme.of(context)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        leadingWidth: 120,
        leading: TextButton(
          onPressed: () =>
              context.goNamed(settingsRoute, pathParameters: {'id': budgetId}),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
          ),
          child: Row(
            children: [
              Icon(
                Icons.chevron_left_rounded,
                size: 20,
                color: theme.colorScheme.onSurface,
              ),
              Flexible(
                child: Text(
                  l10n.settingsTitle,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          l10n.settingsDisplayOptions,
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
      body: ListView(
        padding: const EdgeInsets.all(SpacingTokens.md),
        children: [
          _SectionLabel(label: l10n.themeTitle),
          _SettingsCard(
            child: _ToggleTile(
              label: l10n.themeTitle,
              subtitle: isDarkMode ? l10n.themeDark : l10n.themeLight,
              value: isDarkMode,
              onChanged: (value) => ref
                  .read(themeModeProvider.notifier)
                  .setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          _SectionLabel(label: l10n.settingsBalanceStyle),
          _SettingsCard(
            child: Column(
              children: [
                _BalanceStyleTile(
                  label: l10n.settingsBalanceStyleDefault,
                  selected: currentBalanceStyle == BalanceStyle.standard,
                  onTap: () => ref
                      .read(balanceStyleProvider.notifier)
                      .setBalanceStyle(BalanceStyle.standard),
                  preview: const _BalanceStylePreview(
                    style: BalanceStyle.standard,
                  ),
                ),
                const Divider(height: 1),
                _BalanceStyleTile(
                  label: l10n.settingsBalanceStyleAccessible,
                  selected:
                      currentBalanceStyle ==
                      BalanceStyle.differentiateWithoutColor,
                  onTap: () => ref
                      .read(balanceStyleProvider.notifier)
                      .setBalanceStyle(BalanceStyle.differentiateWithoutColor),
                  preview: const _BalanceStylePreview(
                    style: BalanceStyle.differentiateWithoutColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          _SectionLabel(label: l10n.settingsDisplayCurrency),
          _SettingsCard(
            child: budgetAsync.when(
              loading: () => ListTile(
                title: Text(l10n.settingsDisplayCurrency),
                trailing: const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, __) => ListTile(
                title: Text(l10n.settingsDisplayCurrency),
                subtitle: Text(l10n.settingsLoadError),
              ),
              data: (budget) => _ValuePickerTile(
                title: l10n.settingsDisplayCurrency,
                value: _displayCurrencyLabel(l10n, budget),
                onTap: () => _selectDisplayCurrency(context, ref, budget),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          _SectionLabel(label: l10n.settingsPrivacySection),
          _SettingsCard(
            child: Column(
              children: [
                _ToggleTile(
                  label: l10n.settingsHideAmounts,
                  subtitle: l10n.settingsHideAmountsHint,
                  value: hideAmounts,
                  onChanged: (value) => ref
                      .read(hideAmountsProvider.notifier)
                      .setHideAmounts(value: value),
                ),
                const Divider(height: 1),
                _ToggleTile(
                  label: l10n.settingsHideProgressBars,
                  subtitle: l10n.settingsHideProgressBarsHint,
                  value: hideProgressBars,
                  onChanged: (value) => ref
                      .read(hideProgressBarsProvider.notifier)
                      .setHideProgressBars(value: value),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Text(
            l10n.settingsDisplayOptionsHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
            ),
          ),
        ],
      ),
    );
  }

  String _displayCurrencyLabel(AppLocalizations l10n, Budget budget) {
    final overrideCode = budget.displayCurrencyCode;
    if (overrideCode == null || overrideCode.isEmpty) {
      return l10n.settingsDisplayCurrencyMatchDefault;
    }

    final currency = parseCurrencyCode(overrideCode);
    return '${currency.displayName} (${currency.code})';
  }

  Future<void> _selectDisplayCurrency(
    BuildContext context,
    WidgetRef ref,
    Budget budget,
  ) async {
    const defaultSelection = '';
    final l10n = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(l10n.settingsDisplayCurrencyMatchDefault),
              trailing: budget.displayCurrencyCode == null
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () => Navigator.of(context).pop(defaultSelection),
            ),
            const Divider(height: 1),
            for (final currency in _supportedDisplayCurrencies) ...[
              ListTile(
                title: Text('${currency.displayName} (${currency.code})'),
                trailing: budget.displayCurrencyCode == currency.code
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.of(context).pop(currency.code),
              ),
              if (currency != _supportedDisplayCurrencies.last)
                const Divider(height: 1),
            ],
          ],
        ),
      ),
    );

    if (selected == null) return;
    final isDefaultSelection = selected == defaultSelection;
    if (isDefaultSelection && budget.displayCurrencyCode == null) return;
    if (!isDefaultSelection && budget.displayCurrencyCode == selected) return;

    try {
      final update = ref.read(updateDisplayCurrencyProvider);
      await update(
        budgetId: budgetId,
        displayCurrencyCode: isDefaultSelection ? null : selected,
        clearDisplayCurrencyCode: isDefaultSelection,
      );
      if (!context.mounted) return;

      showAppToast(
        context,
        message: isDefaultSelection
            ? l10n.settingsDisplayCurrencyDefaultUpdated
            : l10n.settingsDisplayCurrencyUpdated(selected),
        variant: AppToastVariant.success,
      );
    } on Exception {
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.settingsDisplayCurrencyUpdateError,
        variant: AppToastVariant.error,
      );
    }
  }
}

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

class _SectionLabel extends HookWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        left: SpacingTokens.xs,
        bottom: SpacingTokens.xs,
      ),
      child: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BalanceStyleTile extends HookWidget {
  const _BalanceStyleTile({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.preview,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget preview;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: selected
        ? Icon(
            Icons.check_rounded,
            color: OpenBudgetPalette.bgBrandFor(Theme.of(context)),
          )
        : const SizedBox(width: 24),
    title: Text(label),
    subtitle: Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.xs),
      child: preview,
    ),
  );
}

class _BalanceStylePreview extends HookWidget {
  const _BalanceStylePreview({required this.style});

  final BalanceStyle style;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: SpacingTokens.xs,
    runSpacing: SpacingTokens.xs,
    children: [
      _SampleBalancePill(
        label: r'-$10.00',
        color: OpenBudgetPalette.bgTagErrorFor(Theme.of(context)),
        textColor: OpenBudgetPalette.fgTagErrorFor(Theme.of(context)),
        emphasize: style == BalanceStyle.differentiateWithoutColor,
      ),
      _SampleBalancePill(
        label: r'$10.00',
        color: OpenBudgetPalette.bgWarningFor(Theme.of(context)),
        textColor: OpenBudgetPalette.fgTagWarningFor(Theme.of(context)),
      ),
      _SampleBalancePill(
        label: r'$10.00',
        color: OpenBudgetPalette.bgTagSuccessFor(Theme.of(context)),
        textColor: OpenBudgetPalette.fgTagSuccessFor(Theme.of(context)),
      ),
    ],
  );
}

class _ValuePickerTile extends HookWidget {
  const _ValuePickerTile({
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
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
      ),
    );
  }
}

class _ToggleTile extends HookWidget {
  const _ToggleTile({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    value: value,
    onChanged: onChanged,
    title: Text(label),
    subtitle: Text(subtitle),
    activeThumbColor: OpenBudgetPalette.bgBrandFor(Theme.of(context)),
    contentPadding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
  );
}

class _SampleBalancePill extends HookWidget {
  const _SampleBalancePill({
    required this.label,
    required this.color,
    required this.textColor,
    this.emphasize = false,
  });

  final String label;
  final Color color;
  final Color textColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(999),
      border: emphasize
          ? Border.all(
              color: OpenBudgetPalette.fgErrorFor(Theme.of(context)),
              width: 1.5,
            )
          : null,
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w700,
        decoration: emphasize ? TextDecoration.underline : null,
      ),
    ),
  );
}
