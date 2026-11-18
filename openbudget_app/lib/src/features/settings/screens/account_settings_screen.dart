import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class AccountSettingsScreen extends HookWidget {
  const AccountSettingsScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsAccountSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          SpacingTokens.md,
          SpacingTokens.md,
          SpacingTokens.md,
          SpacingTokens.xl,
        ),
        children: [
          ObCard(
            tone: ObTone.underfunded,
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkribbleIcon(
                  data: OpenBudgetIcons.lock,
                  size: 20,
                  color: palette.hue(ObTone.underfunded),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(
                    l10n.accountSettingsReadOnlyNotice,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ObSectionHeader(
            title: l10n.accountSettingsProfile,
            padding: _sectionHeaderPadding,
          ),
          ObCard(
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.accountSettingsFirstName,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: SpacingTokens.xs),
                TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    hintText: l10n.accountSettingsUnavailableFieldHint,
                  ),
                ),
                const SizedBox(height: SpacingTokens.sm),
                Text(
                  l10n.settingsAccountEmail,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: SpacingTokens.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: null,
                    child: Text(l10n.accountSettingsSaveUnavailable),
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  l10n.accountSettingsUnavailableHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
              ],
            ),
          ),
          ObSectionHeader(
            title: l10n.accountSettingsLoginMethods,
            padding: _sectionHeaderPadding,
          ),
          ObCard(
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.accountSettingsEmailPassword,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  l10n.settingsAccountEmail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
                const SizedBox(height: SpacingTokens.sm),
                FilledButton.tonal(
                  onPressed: null,
                  child: Text(l10n.accountSettingsChangeEmailPassword),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  l10n.accountSettingsUnavailableHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  l10n.accountSettingsSocialLoginUnavailable,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
              ],
            ),
          ),
          ObSectionHeader(
            title: l10n.accountSettingsTwoStepVerification,
            padding: _sectionHeaderPadding,
          ),
          ObCard(
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.accountSettingsTwoStepHint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
                const SizedBox(height: SpacingTokens.sm),
                FilledButton.tonal(
                  onPressed: null,
                  child: Text(l10n.accountSettingsSetUp),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  l10n.accountSettingsUnavailableHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
              ],
            ),
          ),
          ObSectionHeader(
            title: l10n.accountDeleteTitle,
            subtitle: l10n.accountSettingsDeleteSectionHint,
            padding: _sectionHeaderPadding,
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: palette.overspentWash,
              foregroundColor: palette.overspent,
            ),
            onPressed: () => context.goNamed(
              deleteAccountRoute,
              pathParameters: {'entityId': entityId},
            ),
            child: Text(l10n.accountDeleteTitle),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            l10n.accountSettingsDeleteUnavailableHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.mutedInk,
            ),
          ),
        ],
      ),
    );
  }

  static const _sectionHeaderPadding = EdgeInsets.fromLTRB(
    SpacingTokens.xs,
    SpacingTokens.lg,
    SpacingTokens.xs,
    SpacingTokens.sm,
  );
}
