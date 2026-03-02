import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/budget_export_provider.dart';
import 'package:openbudget_app/src/providers/theme_mode_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
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
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: OpenBudgetPalette.bgPrimaryFor(theme),
      appBar: AppBar(
        backgroundColor: OpenBudgetPalette.bgPrimaryFor(theme),
        surfaceTintColor: OpenBudgetPalette.transparentFor(theme),
        automaticallyImplyLeading: false,
        title: Text(l10n.settingsTitle),
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
        data: (budget) {
          final accountIdentity = _resolveAccountIdentity(
            authState: authState,
            budget: budget,
          );
          final themeModeLabel = _themeModeLabel(
            l10n: l10n,
            themeMode: themeMode,
          );
          final lastUpdatedLabel = _formatDateTime(budget.updatedAt);

          return ListView(
            padding: const EdgeInsets.all(SpacingTokens.md),
            children: [
              _SettingsOverviewCard(
                budgetName: budget.name,
                currencyCode: budget.currencyCode,
                displayCurrencyCode: budget.displayCurrencyCode,
                ownerLabel: accountIdentity,
                lastUpdatedLabel: lastUpdatedLabel,
              ),
              const SizedBox(height: SpacingTokens.lg),
              _SectionTitle(title: l10n.settingsNavigationSection),
              _SettingsCard(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.account_balance_wallet_rounded,
                      label: l10n.accountListTitle,
                      subtitle:
                          'View and organize every account in your budget.',
                      onTap: () => context.goNamed(
                        accountListRoute,
                        pathParameters: {'id': budgetId},
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.add_circle_outline_rounded,
                      label: l10n.accountAddButton,
                      subtitle: 'Add manual accounts, bank links, or wallets.',
                      onTap: () => context.goNamed(
                        addAccountRoute,
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
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),
              _SectionTitle(title: l10n.settingsCurrentPlan),
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
                      icon: Icons.tune_rounded,
                      label: l10n.settingsDisplayOptions,
                      onTap: () => context.goNamed(
                        displayOptionsRoute,
                        pathParameters: {'id': budgetId},
                      ),
                    ),
                    const Divider(height: 1),
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
                      icon: Icons.palette_outlined,
                      label: l10n.themeTitle,
                      subtitle: themeModeLabel,
                      onTap: () => _selectThemeMode(
                        context: context,
                        ref: ref,
                        currentThemeMode: themeMode,
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.account_balance_rounded,
                      label: l10n.settingsManageBankConnections,
                      subtitle: 'Connect Plaid banks or add Solana wallets.',
                      onTap: () => context.goNamed(
                        addAccountRoute,
                        pathParameters: {'id': budgetId},
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),
              _SectionTitle(title: l10n.settingsDataSection),
              _SettingsCard(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.download_rounded,
                      label: l10n.settingsExportData,
                      subtitle: l10n.settingsExportDataHint,
                      onTap: () => _exportBudgetData(context, ref),
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
              _SectionTitle(title: l10n.settingsAccountSection),
              _SettingsCard(
                child: Column(
                  children: [
                    _AccountIdentityTile(accountIdentity: accountIdentity),
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
                      onTap: () => _showComingSoon(
                        context,
                        l10n.settingsSendDiagnostics,
                      ),
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
                    color: OpenBudgetPalette.fgSecondaryFor(theme),
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.xs),
              Center(
                child: Text(
                  'Last updated: $lastUpdatedLabel',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: OpenBudgetPalette.fgSecondaryFor(theme),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _resolveAccountIdentity({
    required AuthState authState,
    required Budget budget,
  }) {
    return switch (authState) {
      Authenticated(:final userId) => userId,
      _ => budget.ownerId.toString(),
    };
  }

  String _themeModeLabel({
    required AppLocalizations l10n,
    required ThemeMode themeMode,
  }) {
    return switch (themeMode) {
      ThemeMode.system => l10n.themeSystem,
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
    };
  }

  String _formatDateTime(DateTime timestamp) {
    return DateFormat.yMMMd().add_jm().format(timestamp.toLocal());
  }

  Future<void> _selectThemeMode({
    required BuildContext context,
    required WidgetRef ref,
    required ThemeMode currentThemeMode,
  }) async {
    final l10n = AppLocalizations.of(context);
    final options = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];

    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final sheetTheme = Theme.of(sheetContext);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  SpacingTokens.md,
                  SpacingTokens.sm,
                  SpacingTokens.md,
                  SpacingTokens.xs,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.themeTitle,
                    style: sheetTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              for (final option in options)
                ListTile(
                  leading: Icon(
                    option == currentThemeMode
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                  ),
                  title: Text(_themeModeLabel(l10n: l10n, themeMode: option)),
                  onTap: () => Navigator.of(sheetContext).pop(option),
                ),
              const SizedBox(height: SpacingTokens.sm),
            ],
          ),
        );
      },
    );

    if (selected == null) return;
    ref.read(themeModeProvider.notifier).setThemeMode(selected);
  }

  Future<void> _exportBudgetData(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);

    try {
      final json = await ref
          .read(budgetExportProvider.notifier)
          .exportBudget(budgetId);
      await Clipboard.setData(ClipboardData(text: json));
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.settingsExportSuccess,
          variant: AppToastVariant.success,
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.settingsExportError,
          variant: AppToastVariant.error,
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
    showAppToast(context, message: l10n.settingsComingSoon(featureName));
  }
}

class _SettingsOverviewCard extends StatelessWidget {
  const _SettingsOverviewCard({
    required this.budgetName,
    required this.currencyCode,
    required this.displayCurrencyCode,
    required this.ownerLabel,
    required this.lastUpdatedLabel,
  });

  final String budgetName;
  final String currencyCode;
  final String? displayCurrencyCode;
  final String ownerLabel;
  final String lastUpdatedLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detailsStyle = theme.textTheme.bodyMedium?.copyWith(
      color: OpenBudgetPalette.fgSecondaryFor(theme),
    );

    return _SettingsCard(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              budgetName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text('Plan currency: $currencyCode', style: detailsStyle),
            if (displayCurrencyCode != null &&
                displayCurrencyCode != currencyCode)
              Text(
                'Display currency: $displayCurrencyCode',
                style: detailsStyle,
              ),
            const SizedBox(height: SpacingTokens.sm),
            Text('Owner: $ownerLabel', style: detailsStyle),
            Text('Updated: $lastUpdatedLabel', style: detailsStyle),
          ],
        ),
      ),
    );
  }
}

class _AccountIdentityTile extends StatelessWidget {
  const _AccountIdentityTile({required this.accountIdentity});

  final String accountIdentity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.md,
        SpacingTokens.md,
        SpacingTokens.sm,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            child: Icon(Icons.person_outline_rounded),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsLoggedInAs,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: OpenBudgetPalette.fgSecondaryFor(theme),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  accountIdentity,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
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
          color: OpenBudgetPalette.fgSecondaryFor(theme),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: OpenBudgetPalette.bgSecondaryFor(theme),
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(color: OpenBudgetPalette.borderSubtleFor(theme)),
      ),
      child: child,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: OpenBudgetPalette.fgSecondaryFor(theme)),
      title: Text(label, style: theme.textTheme.bodyLarge),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: OpenBudgetPalette.fgSecondaryFor(theme),
              ),
            ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: OpenBudgetPalette.fgSecondaryFor(theme),
      ),
      onTap: onTap,
    );
  }
}
