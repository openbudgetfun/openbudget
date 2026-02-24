import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class AppIconScreen extends HookConsumerWidget {
  const AppIconScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currentStyle = ref.watch(appIconStyleProvider);

    return Scaffold(
      backgroundColor: OpenBudgetPalette.appBackgroundFor(theme),
      appBar: AppBar(
        backgroundColor: OpenBudgetPalette.appBackgroundFor(theme),
        surfaceTintColor: Colors.transparent,
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
          l10n.settingsAppIcon,
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
          _SettingsCard(
            child: Column(
              children: AppIconStyle.values
                  .map(
                    (style) => _AppIconStyleTile(
                      style: style,
                      label: _styleLabel(l10n, style),
                      previewAssetPath: style.previewAssetPathFor(
                        theme.brightness,
                      ),
                      selected: style == currentStyle,
                      onTap: () => ref
                          .read(appIconStyleProvider.notifier)
                          .setAppIconStyle(style),
                    ),
                  )
                  .expand((tile) sync* {
                    if (tile.style != AppIconStyle.primary) {
                      yield const Divider(height: 1);
                    }
                    yield tile;
                  })
                  .toList(),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Text(
            l10n.settingsAppIconHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: OpenBudgetPalette.mutedTextFor(theme),
            ),
          ),
        ],
      ),
    );
  }

  String _styleLabel(AppLocalizations l10n, AppIconStyle style) =>
      switch (style) {
        AppIconStyle.primary => l10n.settingsAppIconPrimary,
        AppIconStyle.v1 => l10n.settingsAppIconV1,
        AppIconStyle.v2 => l10n.settingsAppIconV2,
        AppIconStyle.v3 => l10n.settingsAppIconV3,
        AppIconStyle.v4 => l10n.settingsAppIconV4,
        AppIconStyle.v5 => l10n.settingsAppIconV5,
      };
}

class _SettingsCard extends HookWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: OpenBudgetPalette.surfaceFor(theme),
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(color: OpenBudgetPalette.dividerFor(theme)),
      ),
      child: child,
    );
  }
}

class _AppIconStyleTile extends HookWidget {
  const _AppIconStyleTile({
    required this.style,
    required this.label,
    required this.previewAssetPath,
    required this.selected,
    required this.onTap,
  });

  final AppIconStyle style;
  final String label;
  final String previewAssetPath;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: selected
          ? const Icon(Icons.check_rounded, color: OpenBudgetPalette.accentBlue)
          : const SizedBox(width: 24),
      title: Text(label),
      trailing: Container(
        height: 34,
        width: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: OpenBudgetPalette.dividerFor(theme)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(previewAssetPath, fit: BoxFit.cover),
      ),
    );
  }
}
