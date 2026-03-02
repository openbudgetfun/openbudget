import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/budget_export_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final budgetAsync = ref.watch(budgetDetailProvider(budgetId));

    return Scaffold(
      backgroundColor: OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
      appBar: AppBar(
        backgroundColor: OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
        surfaceTintColor: OpenBudgetPalette.transparentFor(Theme.of(context)),
        automaticallyImplyLeading: false,
        title: const SizedBox.shrink(),
        actions: [
          TextButton(
            onPressed: () =>
                context.goNamed(moreRoute, pathParameters: {'id': budgetId}),
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
        data: (budget) => ListView(
          padding: const EdgeInsets.all(SpacingTokens.md),
          children: [
            Text(
              l10n.settingsTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            _SectionTitle(title: l10n.settingsCurrentPlan),
            Padding(
              padding: const EdgeInsets.only(
                left: SpacingTokens.xs,
                top: SpacingTokens.xs,
              ),
              child: Text(
                budget.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            _SettingsCard(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.build_outlined,
                    label: l10n.settingsPlanSettings,
                    onTap: () => context.goNamed(
                      planSettingsRoute,
                      pathParameters: {'id': budgetId},
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.add_circle_outline_rounded,
                    label: l10n.settingsNewPlan,
                    onTap: () => context.goNamed(createBudgetRoute),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.folder_open_rounded,
                    label: l10n.settingsOpenPlan,
                    onTap: () => context.go(homePath),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.eco_rounded,
                    label: l10n.settingsFreshStart,
                    onTap: () => _confirmFreshStart(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            _SectionTitle(title: l10n.settingsAppSection),
            _SettingsCard(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.apps_rounded,
                    label: l10n.settingsAppIcon,
                    onTap: () => context.goNamed(
                      appIconRoute,
                      pathParameters: {'id': budgetId},
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.tune_rounded,
                    label: l10n.settingsDisplayOptions,
                    onTap: () => context.goNamed(
                      displayOptionsRoute,
                      pathParameters: {'id': budgetId},
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.repeat_rounded,
                    label: l10n.recurringListTitle,
                    onTap: () => context.goNamed(
                      recurringListRoute,
                      pathParameters: {'id': budgetId},
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.people_outline_rounded,
                    label: l10n.morePayees,
                    onTap: () => context.goNamed(
                      payeeListRoute,
                      pathParameters: {'id': budgetId},
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.rule_rounded,
                    label: l10n.transactionRulesTitle,
                    onTap: () => context.goNamed(
                      transactionRulesRoute,
                      pathParameters: {'id': budgetId},
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.file_upload_outlined,
                    label: l10n.moreImport,
                    onTap: () => context.goNamed(
                      importTransactionsRoute,
                      pathParameters: {'id': budgetId},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            _SectionTitle(title: l10n.settingsDataSection),
            _SettingsCard(
              child: _SettingsTile(
                icon: Icons.download_rounded,
                label: l10n.settingsExportData,
                subtitle: l10n.settingsExportDataHint,
                onTap: () => _exportBudgetData(context, ref),
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            _SectionTitle(title: l10n.settingsAccountSection),
            _SettingsCard(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      SpacingTokens.md,
                      SpacingTokens.md,
                      SpacingTokens.md,
                      SpacingTokens.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.settingsLoggedInAs,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: OpenBudgetPalette.fgSecondaryFor(
                              Theme.of(context),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.settingsAccountEmail,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.person_rounded,
                    label: l10n.settingsAccountSettings,
                    subtitle: l10n.settingsAccountSettingsHint,
                    onTap: () => context.goNamed(
                      accountSettingsRoute,
                      pathParameters: {'id': budgetId},
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.diversity_1_rounded,
                    label: l10n.settingsTogether,
                    onTap: () =>
                        _showComingSoon(context, l10n.settingsTogether),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.account_balance_rounded,
                    label: l10n.settingsManageBankConnections,
                    subtitle: 'Currently unavailable in this build',
                    enabled: false,
                    onTap: null,
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.logout_rounded,
                    label: l10n.settingsLogOut,
                    onTap: () => _confirmLogout(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            _SectionTitle(title: l10n.settingsMiscSection),
            _SettingsCard(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.favorite_rounded,
                    label: l10n.settingsWriteAReview,
                    onTap: () =>
                        _showComingSoon(context, l10n.settingsWriteAReview),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.near_me_rounded,
                    label: l10n.settingsSendDiagnostics,
                    onTap: () =>
                        _showComingSoon(context, l10n.settingsSendDiagnostics),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    label: l10n.settingsLegal,
                    onTap: () => _showComingSoon(context, l10n.settingsLegal),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    label: l10n.settingsPrivacyPolicy,
                    onTap: () =>
                        _showComingSoon(context, l10n.settingsPrivacyPolicy),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    label: l10n.settingsCaliforniaPrivacyPolicy,
                    onTap: () => _showComingSoon(
                      context,
                      l10n.settingsCaliforniaPrivacyPolicy,
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    label: l10n.settingsYourPrivacyChoices,
                    onTap: () => _showComingSoon(
                      context,
                      l10n.settingsYourPrivacyChoices,
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    label: l10n.settingsTermsOfService,
                    onTap: () =>
                        _showComingSoon(context, l10n.settingsTermsOfService),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.xl),
            Center(
              child: Text(
                l10n.settingsVersion,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Center(
              child: Text(
                l10n.settingsLastSynced,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportBudgetData(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    try {
      final json = await ref
          .read(budgetExportProvider.notifier)
          .exportBudget(budgetId);
      await Clipboard.setData(ClipboardData(text: json));
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.settingsExportSuccess)),
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.settingsExportError),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsLogOut),
        content: Text(l10n.settingsLogoutConfirm),
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
            child: Text(l10n.settingsLogOut),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(authProvider.notifier).logout();
  }

  Future<void> _confirmFreshStart(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsFreshStart),
        content: Text(l10n.settingsFreshStartHint),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.settingsFreshStartButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    context.goNamed(createBudgetRoute);
  }

  void _showComingSoon(BuildContext context, String featureName) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsComingSoon(featureName))),
    );
  }
}

class _SectionTitle extends HookWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        left: SpacingTokens.xs,
        bottom: SpacingTokens.xs,
      ),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          color: OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsCard extends HookWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
}

class _SettingsTile extends HookWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? subtitle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleColor = enabled
        ? theme.textTheme.bodyLarge?.color
        : OpenBudgetPalette.fgSecondaryFor(Theme.of(context));

    return ListTile(
      leading: Icon(
        icon,
        color: OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(color: titleColor),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
              ),
            ),
      trailing: Icon(
        enabled ? Icons.chevron_right_rounded : Icons.block_rounded,
        color: OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
      ),
      onTap: enabled ? onTap : null,
    );
  }
}
