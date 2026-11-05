import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/budget_export_provider.dart';
import 'package:openbudget_app/src/features/whats_new/providers/whats_new_providers.dart';
import 'package:openbudget_app/src/features/whats_new/screens/whats_new_sheet.dart';
import 'package:openbudget_app/src/providers/theme_mode_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
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
    final budgetAsync = ref.watch(budgetDetailProvider(budgetId));
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        actions: [
          TextButton(
            onPressed: () =>
                context.goNamed(moreRoute, pathParameters: {'id': budgetId}),
            child: Text(
              l10n.dialogDone,
              style: theme.textTheme.titleMedium,
            ),
          ),
        ],
      ),
      body: budgetAsync.when(
        loading: () => ObLoadingPanel(label: l10n.settingsLoading),
        error: (_, _) => Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: ObStatePanel.problem(title: l10n.settingsLoadError),
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
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              0,
              SpacingTokens.md,
              SpacingTokens.xl,
            ),
            children: [
              _SettingsOverviewCard(
                budgetName: budget.name,
                currencyCode: budget.currencyCode,
                displayCurrencyCode: budget.displayCurrencyCode,
                ownerLabel: accountIdentity,
                lastUpdatedLabel: lastUpdatedLabel,
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: OpenBudgetIcons.sparkle,
                      label: l10n.plusTitle,
                      subtitle: l10n.plusNavSubtitle,
                      onTap: () => context.pushNamed(plusRoute),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: OpenBudgetIcons.lock,
                      label: l10n.agentAccessTitle,
                      subtitle: l10n.agentAccessSettingsSubtitle,
                      onTap: () => context.pushNamed(agentAccessRoute),
                    ),
                  ],
                ),
              ),
              ObSectionHeader(
                title: l10n.settingsNavigationSection,
                padding: _sectionHeaderPadding,
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: OpenBudgetIcons.wallet,
                      label: l10n.accountListTitle,
                      subtitle: l10n.settingsAccountsOverviewHint,
                      onTap: () => context.goNamed(
                        accountListRoute,
                        pathParameters: {'id': budgetId},
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: OpenBudgetIcons.addCircle,
                      label: l10n.accountAddButton,
                      subtitle: l10n.settingsAddAccountHint,
                      onTap: () => context.goNamed(
                        addAccountRoute,
                        pathParameters: {'id': budgetId},
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: OpenBudgetIcons.recurring,
                      label: l10n.recurringListTitle,
                      onTap: () => context.goNamed(
                        recurringListRoute,
                        pathParameters: {'id': budgetId},
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: OpenBudgetIcons.people,
                      label: l10n.morePayees,
                      onTap: () => context.goNamed(
                        payeeListRoute,
                        pathParameters: {'id': budgetId},
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: OpenBudgetIcons.rule,
                      label: l10n.transactionRulesTitle,
                      onTap: () => context.goNamed(
                        transactionRulesRoute,
                        pathParameters: {'id': budgetId},
                      ),
                    ),
                  ],
                ),
              ),
              ObSectionHeader(
                title: l10n.settingsCurrentPlan,
                padding: _sectionHeaderPadding,
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: OpenBudgetIcons.tool,
                      label: l10n.settingsPlanSettings,
                      onTap: () => context.goNamed(
                        planSettingsRoute,
                        pathParameters: {'id': budgetId},
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: OpenBudgetIcons.sparkle,
                      label: l10n.assistantProviderSettingsRow,
                      subtitle: l10n.assistantProviderSettingsHint,
                      onTap: () => context.pushNamed(
                        assistantProviderRoute,
                        pathParameters: {'id': budgetId},
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: OpenBudgetIcons.addCircle,
                      label: l10n.settingsNewPlan,
                      onTap: () => context.goNamed(createBudgetRoute),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: OpenBudgetIcons.folder,
                      label: l10n.settingsOpenPlan,
                      onTap: () => context.go(homePath),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: OpenBudgetIcons.refresh,
                      label: l10n.settingsFreshStart,
                      onTap: () => _confirmFreshStart(context),
                    ),
                  ],
                ),
              ),
              ObSectionHeader(
                title: l10n.settingsAppSection,
                padding: _sectionHeaderPadding,
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: OpenBudgetIcons.sparkle,
                      label: l10n.whatsNewTitle,
                      subtitle: l10n.whatsNewSettingHint,
                      onTap: () => _showWhatsNew(context, ref),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: OpenBudgetIcons.tune,
                      label: l10n.settingsDisplayOptions,
                      onTap: () => context.goNamed(
                        displayOptionsRoute,
                        pathParameters: {'id': budgetId},
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: OpenBudgetIcons.apps,
                      label: l10n.settingsAppIcon,
                      onTap: () => context.goNamed(
                        appIconRoute,
                        pathParameters: {'id': budgetId},
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: OpenBudgetIcons.palette,
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
                      icon: OpenBudgetIcons.bank,
                      label: l10n.settingsManageBankConnections,
                      subtitle: l10n.settingsManageBankConnectionsHint,
                      onTap: () => context.goNamed(
                        addAccountRoute,
                        pathParameters: {'id': budgetId},
                      ),
                    ),
                  ],
                ),
              ),
              ObSectionHeader(
                title: l10n.settingsDataSection,
                padding: _sectionHeaderPadding,
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: OpenBudgetIcons.download,
                      label: l10n.settingsExportData,
                      subtitle: l10n.settingsExportDataHint,
                      onTap: () => _exportBudgetData(context, ref),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: OpenBudgetIcons.upload,
                      label: l10n.moreImport,
                      onTap: () => context.goNamed(
                        importTransactionsRoute,
                        pathParameters: {'id': budgetId},
                      ),
                    ),
                  ],
                ),
              ),
              ObSectionHeader(
                title: l10n.settingsAccountSection,
                padding: _sectionHeaderPadding,
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _AccountIdentityTile(accountIdentity: accountIdentity),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: OpenBudgetIcons.person,
                      label: l10n.settingsAccountSettings,
                      subtitle: l10n.settingsAccountSettingsHint,
                      onTap: () => context.goNamed(
                        accountSettingsRoute,
                        pathParameters: {'id': budgetId},
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: OpenBudgetIcons.logout,
                      label: l10n.settingsLogOut,
                      onTap: () => _confirmLogout(context, ref),
                    ),
                  ],
                ),
              ),
              ObSectionHeader(
                title: l10n.settingsMiscSection,
                padding: _sectionHeaderPadding,
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: OpenBudgetIcons.favorite,
                      label: l10n.settingsWriteAReview,
                      onTap: () =>
                          _showComingSoon(context, l10n.settingsWriteAReview),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: OpenBudgetIcons.send,
                      label: l10n.settingsSendDiagnostics,
                      onTap: () => _showComingSoon(
                        context,
                        l10n.settingsSendDiagnostics,
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: OpenBudgetIcons.document,
                      label: l10n.settingsPrivacyPolicy,
                      onTap: () =>
                          _showComingSoon(context, l10n.settingsPrivacyPolicy),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: OpenBudgetIcons.document,
                      label: l10n.settingsTermsOfService,
                      onTap: () =>
                          _showComingSoon(context, l10n.settingsTermsOfService),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.xl),
              Text(
                l10n.settingsVersion,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.ob.mutedInk,
                ),
              ),
              const SizedBox(height: SpacingTokens.xs),
              Text(
                l10n.settingsLastUpdated(lastUpdatedLabel),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.ob.mutedInk,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static const _sectionHeaderPadding = EdgeInsets.fromLTRB(
    SpacingTokens.xs,
    SpacingTokens.md,
    SpacingTokens.xs,
    SpacingTokens.xs,
  );

  String _resolveAccountIdentity({
    required AuthState authState,
    required Budget budget,
  }) => switch (authState) {
    Authenticated(:final userId) => userId,
    _ => budget.ownerId.toString(),
  };

  String _themeModeLabel({
    required AppLocalizations l10n,
    required ThemeMode themeMode,
  }) => switch (themeMode) {
    ThemeMode.system => l10n.themeSystem,
    ThemeMode.light => l10n.themeLight,
    ThemeMode.dark => l10n.themeDark,
  };

  String _formatDateTime(DateTime timestamp) =>
      DateFormat.yMMMd().add_jm().format(timestamp.toLocal());

  Future<void> _showWhatsNew(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(whatsNewCurrentNotesProvider.future);
    if (!context.mounted) {
      return;
    }
    await showWhatsNewSheet(context, result: result);
  }

  Future<void> _selectThemeMode({
    required BuildContext context,
    required WidgetRef ref,
    required ThemeMode currentThemeMode,
  }) async {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
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
                    style: sheetTheme.textTheme.titleMedium,
                  ),
                ),
              ),
              for (final option in options)
                ListTile(
                  selected: option == currentThemeMode,
                  leading: SkribbleIcon(
                    data: option == currentThemeMode
                        ? OpenBudgetIcons.checkCircle
                        : OpenBudgetIcons.circle,
                    color: option == currentThemeMode
                        ? palette.brand
                        : palette.mutedInk,
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
    final palette = Theme.of(context).ob;
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
              backgroundColor: palette.overspentWash,
              foregroundColor: palette.overspent,
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

class _SettingsOverviewCard extends HookWidget {
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final detailsStyle = theme.textTheme.bodyMedium?.copyWith(
      color: palette.mutedInk,
    );

    return ObCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: ObRoughDecoration(
                  color: palette.wash(ObTone.brand),
                  outline: palette.quietPen,
                  seed: 11,
                ),
                child: SkribbleIcon(
                  data: OpenBudgetIcons.envelope,
                  size: 22,
                  color: palette.hue(ObTone.brand),
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Text(
                  budgetName,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            l10n.settingsPlanCurrencyDetail(currencyCode),
            style: detailsStyle,
          ),
          if (displayCurrencyCode != null &&
              displayCurrencyCode != currencyCode)
            Text(
              l10n.settingsDisplayCurrencyDetail(displayCurrencyCode!),
              style: detailsStyle,
            ),
          const SizedBox(height: SpacingTokens.xs),
          Row(
            children: [
              SkribbleIcon(
                data: OpenBudgetIcons.person,
                size: 16,
                color: palette.mutedInk,
              ),
              const SizedBox(width: SpacingTokens.xs),
              Expanded(
                child: Text(
                  l10n.settingsOwner(ownerLabel),
                  style: detailsStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            children: [
              SkribbleIcon(
                data: OpenBudgetIcons.schedule,
                size: 16,
                color: palette.mutedInk,
              ),
              const SizedBox(width: SpacingTokens.xs),
              Expanded(
                child: Text(
                  l10n.settingsUpdated(lastUpdatedLabel),
                  style: detailsStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountIdentityTile extends HookWidget {
  const _AccountIdentityTile({required this.accountIdentity});

  final String accountIdentity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.md,
        SpacingTokens.md,
        SpacingTokens.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: ObRoughDecoration(
              color: palette.wash(ObTone.brand),
              outline: palette.quietPen,
              radius: RadiusTokens.lg,
              seed: 13,
            ),
            child: SkribbleIcon(
              data: OpenBudgetIcons.person,
              size: 22,
              color: palette.hue(ObTone.brand),
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsLoggedInAs,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  accountIdentity,
                  style: theme.textTheme.titleMedium,
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

class _SettingsTile extends HookWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  final WiredSvgIconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;

    return ListTile(
      leading: SkribbleIcon(data: icon, color: palette.ink),
      title: Text(label, style: theme.textTheme.bodyLarge),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.mutedInk,
              ),
            ),
      trailing: SkribbleIcon(
        data: OpenBudgetIcons.chevronRight,
        size: 20,
        color: palette.mutedInk,
      ),
      onTap: onTap,
    );
  }
}
