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

  static const _sectionHeaderPadding = EdgeInsets.fromLTRB(
    SpacingTokens.xs,
    SpacingTokens.lg,
    SpacingTokens.xs,
    SpacingTokens.sm,
  );

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
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
      appBar: AppBar(
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.goNamed(
            settingsRoute,
            pathParameters: {'id': budgetId},
          ),
          icon: const SkribbleIcon(data: OpenBudgetIcons.back),
        ),
        title: Text(l10n.settingsDisplayOptions),
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          SpacingTokens.md,
          0,
          SpacingTokens.md,
          SpacingTokens.xl,
        ),
        children: [
          ObSectionHeader(
            title: l10n.themeTitle,
            padding: _sectionHeaderPadding,
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: _ToggleTile(
              label: l10n.themeTitle,
              subtitle: isDarkMode ? l10n.themeDark : l10n.themeLight,
              value: isDarkMode,
              onChanged: (value) => ref
                  .read(themeModeProvider.notifier)
                  .setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
            ),
          ),
          ObSectionHeader(
            title: l10n.settingsBalanceStyle,
            padding: _sectionHeaderPadding,
          ),
          Card(
            clipBehavior: Clip.antiAlias,
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
          ObSectionHeader(
            title: l10n.settingsDisplayCurrency,
            padding: _sectionHeaderPadding,
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: budgetAsync.when(
              loading: () => ListTile(
                title: Text(l10n.settingsDisplayCurrency),
                trailing: Semantics(
                  label: l10n.settingsLoading,
                  child: WiredLoadingIndicator(
                    size: 20,
                    color: palette.ink,
                  ),
                ),
              ),
              error: (_, _) => ListTile(
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
          ObSectionHeader(
            title: l10n.settingsPrivacySection,
            padding: _sectionHeaderPadding,
          ),
          Card(
            clipBehavior: Clip.antiAlias,
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
          const SizedBox(height: SpacingTokens.md),
          Text(
            l10n.settingsDisplayOptionsHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.mutedInk,
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
              selected: budget.displayCurrencyCode == null,
              trailing: budget.displayCurrencyCode == null
                  ? const SkribbleIcon(data: OpenBudgetIcons.check)
                  : null,
              onTap: () => Navigator.of(context).pop(defaultSelection),
            ),
            const Divider(height: 1),
            for (final currency in _supportedDisplayCurrencies) ...[
              ListTile(
                title: Text('${currency.displayName} (${currency.code})'),
                selected: budget.displayCurrencyCode == currency.code,
                trailing: budget.displayCurrencyCode == currency.code
                    ? const SkribbleIcon(data: OpenBudgetIcons.check)
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
  Widget build(BuildContext context) {
    final palette = Theme.of(context).ob;
    return ListTile(
      onTap: onTap,
      selected: selected,
      leading: selected
          ? SkribbleIcon(
              data: OpenBudgetIcons.check,
              color: palette.brand,
            )
          : const SizedBox(width: 24),
      title: Text(label),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: SpacingTokens.xs),
        child: preview,
      ),
    );
  }
}

class _BalanceStylePreview extends HookWidget {
  const _BalanceStylePreview({required this.style});

  final BalanceStyle style;

  @override
  Widget build(BuildContext context) {
    final emphasize = style == BalanceStyle.differentiateWithoutColor;
    return Wrap(
      spacing: SpacingTokens.xs,
      runSpacing: SpacingTokens.xs,
      children: [
        _SampleBalancePill(
          label: r'-$10.00',
          tone: ObTone.overspent,
          emphasize: emphasize,
        ),
        const _SampleBalancePill(
          label: r'$10.00',
          tone: ObTone.underfunded,
        ),
        const _SampleBalancePill(
          label: r'$10.00',
          tone: ObTone.funded,
        ),
      ],
    );
  }
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
        data: OpenBudgetIcons.chevronRight,
        size: 20,
        color: palette.mutedInk,
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
    contentPadding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
  );
}

class _SampleBalancePill extends HookWidget {
  const _SampleBalancePill({
    required this.label,
    required this.tone,
    this.emphasize = false,
  });

  final String label;
  final ObTone tone;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: ObRoughDecoration(
        color: palette.wash(tone),
        outline: emphasize ? palette.firmPen : palette.quietPen,
        radius: 14,
        strokeWidth: emphasize ? 2.2 : ObPen.strokeWidth,
        seed: 27,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: palette.hue(tone),
          fontWeight: FontWeight.w700,
          decoration: emphasize ? TextDecoration.underline : null,
        ),
      ),
    );
  }
}
