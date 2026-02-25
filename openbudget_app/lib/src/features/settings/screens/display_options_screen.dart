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
    final currentBalanceStyle = ref.watch(balanceStyleProvider);
    final hideAmounts = ref.watch(hideAmountsProvider);
    final hideProgressBars = ref.watch(hideProgressBarsProvider);
    final budgetAsync = ref.watch(budgetDetailProvider(budgetId));

    return Scaffold(
      backgroundColor: OpenBudgetPalette.appBackground,
      appBar: AppBar(
        backgroundColor: OpenBudgetPalette.appBackground,
        surfaceTintColor: Colors.transparent,
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
            child: Column(
              children: [
                _SelectionTile(
                  label: l10n.themeLight,
                  selected: currentThemeMode == ThemeMode.light,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(ThemeMode.light),
                ),
                const Divider(height: 1),
                _SelectionTile(
                  label: l10n.themeDark,
                  selected: currentThemeMode == ThemeMode.dark,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(ThemeMode.dark),
                ),
                const Divider(height: 1),
                _SelectionTile(
                  label: l10n.themeSystem,
                  selected: currentThemeMode == ThemeMode.system,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(ThemeMode.system),
                ),
              ],
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
              color: OpenBudgetPalette.mutedText,
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isDefaultSelection
                ? l10n.settingsDisplayCurrencyDefaultUpdated
                : l10n.settingsDisplayCurrencyUpdated(selected),
          ),
        ),
      );
    } on Exception {
      if (!context.mounted) return;
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsDisplayCurrencyUpdateError),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }
}

class _SettingsCard extends HookWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: OpenBudgetPalette.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(color: OpenBudgetPalette.divider),
      ),
      child: child,
    );
  }
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

class _SelectionTile extends HookWidget {
  const _SelectionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(label),
      leading: selected
          ? const Icon(Icons.check_rounded, color: OpenBudgetPalette.accentBlue)
          : const SizedBox(width: 24),
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
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: selected
          ? const Icon(Icons.check_rounded, color: OpenBudgetPalette.accentBlue)
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
    return Wrap(
      spacing: SpacingTokens.xs,
      runSpacing: SpacingTokens.xs,
      children: [
        _SampleBalancePill(
          label: r'-$10.00',
          color: const Color(0xFFF5B2B6),
          textColor: const Color(0xFF5E1C23),
          emphasize: style == BalanceStyle.differentiateWithoutColor,
        ),
        const _SampleBalancePill(
          label: r'$10.00',
          color: Color(0xFFE8C743),
          textColor: Color(0xFF4B3A00),
        ),
        const _SampleBalancePill(
          label: r'$10.00',
          color: Color(0xFFA6DC57),
          textColor: Color(0xFF234700),
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
    return ListTile(
      onTap: onTap,
      title: Text(title),
      subtitle: Text(
        value,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: OpenBudgetPalette.mutedText,
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
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(label),
      subtitle: Text(subtitle),
      activeThumbColor: OpenBudgetPalette.accentBlue,
      contentPadding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
    );
  }
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: emphasize
            ? Border.all(color: const Color(0xFFC23043), width: 1.5)
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
}
