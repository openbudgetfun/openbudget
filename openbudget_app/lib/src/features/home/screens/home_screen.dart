import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/home/providers/entity_actions_provider.dart';
import 'package:openbudget_app/src/features/home/providers/entity_summary_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The front door: one card per entity plus the combined net worth card,
/// all figures from the server.
class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summaries = ref.watch(entitySummariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const SkribbleIcon(data: OpenBudgetIcons.logout),
            tooltip: l10n.homeLogout,
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: summaries.when(
        loading: () => ObLoadingPanel(label: l10n.homeLoadingBudgets),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: ObStatePanel.problem(
            title: l10n.homeLoadError,
            action: ObStateAction(
              label: l10n.homeRetry,
              onPressed: () => ref.invalidate(entitySummariesProvider),
            ),
          ),
        ),
        data: (summaryList) {
          if (summaryList.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(SpacingTokens.xl),
              child: Center(
                child: SingleChildScrollView(
                  child: ObStatePanel.empty(
                    title: l10n.homeNoBudgets,
                    message: l10n.homeNoBudgetsHint,
                    action: ObStateAction(
                      label: l10n.homeCreateBudget,
                      onPressed: () =>
                          unawaited(context.pushNamed(createEntityRoute)),
                    ),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(entitySummariesProvider),
            child: ListView(
              padding: const EdgeInsets.all(SpacingTokens.md),
              children: [
                const _CombinedNetWorthCard(),
                const SizedBox(height: SpacingTokens.md),
                for (final summary in summaryList)
                  _EntityCard(
                    summary: summary,
                    onTap: () {
                      final id = summary.entity.id?.toString() ?? '';
                      if (id.isEmpty) return;
                      unawaited(
                        context.pushNamed(
                          planRoute,
                          pathParameters: {'entityId': id},
                        ),
                      );
                    },
                    onLongPress: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => _DeleteEntityDialog(summary: summary),
                      );
                      if (confirmed != true || !context.mounted) return;
                      await ref
                          .read(entityActionsProvider.notifier)
                          .deleteEntity(
                            entityId: summary.entity.id?.toString() ?? '',
                            confirmName: summary.entity.name,
                          );
                      if (context.mounted) {
                        showAppToast(
                          context,
                          message: l10n.budgetDeleteSuccess,
                          variant: AppToastVariant.success,
                        );
                      }
                    },
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: summaries.maybeWhen(
        data: (list) => list.isNotEmpty
            ? FloatingActionButton(
                tooltip: l10n.homeCreateBudget,
                onPressed: () =>
                    unawaited(context.pushNamed(createEntityRoute)),
                child: const SkribbleIcon(data: OpenBudgetIcons.add),
              )
            : null,
        orElse: () => null,
      ),
    );
  }
}

/// Deleting an entity asks the user to type its exact name.
class _DeleteEntityDialog extends HookWidget {
  const _DeleteEntityDialog({required this.summary});

  final EntitySummaryView summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    final nameController = useTextEditingController();
    final canDelete = useState(
      nameController.text.trim() == summary.entity.name,
    );

    useEffect(() {
      void listener() {
        canDelete.value = nameController.text.trim() == summary.entity.name;
      }

      nameController.addListener(listener);
      return () => nameController.removeListener(listener);
    }, [nameController]);

    return AlertDialog(
      title: Text(l10n.budgetDeleteTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.budgetDeleteConfirm(summary.entity.name)),
          const SizedBox(height: SpacingTokens.md),
          TextField(
            controller: nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.entityDeleteNameField,
              hintText: summary.entity.name,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.dialogCancel),
        ),
        FilledButton(
          onPressed: canDelete.value
              ? () => Navigator.of(context).pop(true)
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: palette.overspentWash,
            foregroundColor: palette.overspent,
          ),
          child: Text(l10n.budgetDeleteButton),
        ),
      ],
    );
  }
}

/// The entity card: Ready to Assign, overspent, uncategorised, due
/// recurring and pending proposals, all in the entity's base currency.
class _EntityCard extends HookConsumerWidget {
  const _EntityCard({
    required this.summary,
    required this.onTap,
    required this.onLongPress,
  });

  final EntitySummaryView summary;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final readyToAssign = summary.readyToAssignMinor;
    final readyTone = readyToAssign == null
        ? ObTone.neutral
        : readyToAssign > 0
        ? ObTone.funded
        : readyToAssign < 0
        ? ObTone.overspent
        : ObTone.neutral;
    final readyLabel = readyToAssign == null
        ? null
        : formatMinorForCode(
            readyToAssign,
            summary.entity.baseCurrencyCode,
          );

    return Card(
      margin: const EdgeInsets.only(bottom: SpacingTokens.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: ObRoughDecoration(
                      color: palette.wash(ObTone.brand),
                      outline: palette.quietPen,
                      seed: 17,
                    ),
                    child: SkribbleIcon(
                      data: OpenBudgetIcons.wallet,
                      color: palette.hue(ObTone.brand),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary.entity.name,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        ObToneChip(label: summary.entity.baseCurrencyCode),
                      ],
                    ),
                  ),
                  SkribbleIcon(
                    data: OpenBudgetIcons.chevronRight,
                    size: 20,
                    color: palette.mutedInk,
                  ),
                ],
              ),
              if (readyLabel != null)
                Padding(
                  padding: const EdgeInsets.only(top: SpacingTokens.sm),
                  child: Row(
                    children: [
                      SkribbleIcon(
                        data: OpenBudgetIcons.autoAssign,
                        size: 16,
                        color: palette.hue(readyTone),
                      ),
                      const SizedBox(width: SpacingTokens.xs),
                      Expanded(
                        child: readyToAssign! > 0
                            ? ObHighlighter(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                child: Text(
                                  l10n.homeBudgetReadyToAssign(readyLabel),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: palette.onHighlighter,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : Text(
                                l10n.homeBudgetReadyToAssign(readyLabel),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: palette.hue(readyTone),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: SpacingTokens.sm),
                child: Wrap(
                  spacing: SpacingTokens.md,
                  runSpacing: SpacingTokens.xs,
                  children: [
                    _SummaryChip(
                      icon: OpenBudgetIcons.warning,
                      label: l10n.homeBudgetOverspent(
                        summary.overspentEnvelopeCount,
                      ),
                      color: summary.overspentEnvelopeCount > 0
                          ? palette.overspent
                          : palette.mutedInk,
                    ),
                    _SummaryChip(
                      icon: OpenBudgetIcons.bank,
                      label: l10n.homeBudgetNetWorthShort(
                        formatMinorForCode(
                          summary.netWorthMinor,
                          summary.entity.baseCurrencyCode,
                        ),
                      ),
                      color: summary.netWorthMinor >= 0
                          ? palette.mutedInk
                          : palette.overspent,
                    ),
                    if (summary.uncategorizedCount > 0)
                      _SummaryChip(
                        icon: OpenBudgetIcons.flag,
                        label: l10n.homeBudgetUncategorised(
                          summary.uncategorizedCount,
                        ),
                        color: palette.hue(ObTone.overspent),
                      ),
                    if (summary.dueRecurringCount > 0)
                      _SummaryChip(
                        icon: OpenBudgetIcons.recurring,
                        label: l10n.homeBudgetDueRecurring(
                          summary.dueRecurringCount,
                        ),
                        color: palette.hue(ObTone.overspent),
                      ),
                    if (summary.pendingProposalCount > 0)
                      _SummaryChip(
                        icon: OpenBudgetIcons.sparkle,
                        label: l10n.homeBudgetPendingProposals(
                          summary.pendingProposalCount,
                        ),
                        color: palette.hue(ObTone.brand),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The combined net worth card across every entity that counts, straight
/// from `report.netWorth` in the reporting currency.
class _CombinedNetWorthCard extends HookConsumerWidget {
  const _CombinedNetWorthCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final netWorthAsync = ref.watch(netWorthProvider);

    return netWorthAsync.whenOrNull(
          data: (view) {
            final label = formatMinorForCode(
              view.netWorthMinor,
              view.currencyCode,
            );
            final tone = view.netWorthMinor >= 0
                ? ObTone.funded
                : ObTone.overspent;

            return ObCard(
              tone: tone,
              raised: true,
              shadow: palette.overprint,
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: Column(
                children: [
                  Row(
                    children: [
                      SkribbleIcon(
                        data: OpenBudgetIcons.wallet,
                        size: 18,
                        color: palette.hue(tone),
                      ),
                      const SizedBox(width: SpacingTokens.xs),
                      Text(
                        l10n.homeNetWorthLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: palette.ink,
                        ),
                      ),
                      const Spacer(),
                      ObToneChip(label: view.currencyCode),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  ObAmount(
                    label,
                    tone: tone,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.netWorthAssetsLabel(
                          formatMinorForCode(
                            view.assetsMinor,
                            view.currencyCode,
                          ),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.mutedInk,
                        ),
                      ),
                      const SizedBox(width: SpacingTokens.md),
                      Text(
                        l10n.netWorthLiabilitiesLabel(
                          formatMinorForCode(
                            view.liabilitiesMinor,
                            view.currencyCode,
                          ),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.mutedInk,
                        ),
                      ),
                    ],
                  ),
                  if (!view.isComplete) ...[
                    const SizedBox(height: SpacingTokens.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SkribbleIcon(
                          data: OpenBudgetIcons.warning,
                          size: 14,
                          color: palette.hue(ObTone.overspent),
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        Flexible(
                          child: Text(
                            l10n.netWorthMissingCurrencies(
                              view.missingCurrencyCodes.join(', '),
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: palette.hue(ObTone.overspent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        ) ??
        const SizedBox.shrink();
  }
}

class _SummaryChip extends HookWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final WiredSvgIconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SkribbleIcon(data: icon, size: 16, color: color),
        const SizedBox(width: SpacingTokens.xs),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: color)),
      ],
    );
  }
}
