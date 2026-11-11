import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/providers/theme_mode_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class DisplayOptionsScreen extends HookConsumerWidget {
  const DisplayOptionsScreen({required this.entityId, super.key});

  static const _sectionHeaderPadding = EdgeInsets.fromLTRB(
    SpacingTokens.xs,
    SpacingTokens.lg,
    SpacingTokens.xs,
    SpacingTokens.sm,
  );

  final String entityId;

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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.goNamed(
            settingsRoute,
            pathParameters: {'entityId': entityId},
          ),
          icon: const SkribbleIcon(data: OpenBudgetIcons.back),
        ),
        title: Text(l10n.settingsDisplayOptions),
        actions: [
          TextButton(
            onPressed: () => context.goNamed(
              settingsRoute,
              pathParameters: {'entityId': entityId},
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
