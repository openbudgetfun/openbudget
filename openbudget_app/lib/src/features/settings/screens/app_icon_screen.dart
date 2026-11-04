import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class AppIconScreen extends HookConsumerWidget {
  const AppIconScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final currentStyle = ref.watch(appIconStyleProvider);

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
        title: Text(l10n.settingsAppIcon),
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
          SpacingTokens.md,
          SpacingTokens.md,
          SpacingTokens.xl,
        ),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
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
          const SizedBox(height: SpacingTokens.md),
          Text(
            l10n.settingsAppIconHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.mutedInk,
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
      trailing: Container(
        height: 34,
        width: 34,
        decoration: ObRoughDecoration(
          outline: palette.quietPen,
          radius: 8,
          seed: 19,
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(previewAssetPath, fit: BoxFit.cover),
      ),
    );
  }
}
