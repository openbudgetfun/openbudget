import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/assistant/widgets/assistant_text.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The usage header above a conversation.
///
/// It shows how much of the included monthly usage is spent, or says that the
/// user's own provider is answering. The envelope is decoration for the same
/// sentence, so the label always carries the meaning.
class AssistantUsageMeter extends HookWidget {
  const AssistantUsageMeter({
    required this.usage,
    this.pendingProposals = 0,
    this.onOpenProposals,
    super.key,
  });

  final AsyncValue<AgentUsageView> usage;
  final int pendingProposals;
  final VoidCallback? onOpenProposals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    final pendingChip = pendingProposals == 0
        ? null
        : InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onOpenProposals,
            child: ObToneChip(
              label: l10n.assistantPendingProposals(pendingProposals),
              tone: ObTone.review,
              icon: SkribbleIcon(
                data: OpenBudgetIcons.sparkle,
                size: 14,
                color: palette.review,
              ),
            ),
          );

    return ObCard(
      padding: const EdgeInsets.all(SpacingTokens.sm),
      child: usage.when(
        loading: () => _MeterRow(
          label: l10n.assistantUsageLoading,
          fraction: 0,
          tone: ObTone.neutral,
          hint: null,
        ),
        error: (_, _) => _MeterRow(
          label: l10n.assistantUsageUnavailable,
          fraction: 0,
          tone: ObTone.neutral,
          hint: null,
        ),
        data: (view) {
          if (view.provider == AgentProvider.byo) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MeterRow(
                  label: l10n.assistantOwnProviderUsage,
                  fraction: 0,
                  tone: ObTone.neutral,
                  hint: l10n.assistantOwnProviderUsageHint,
                ),
                if (pendingChip case final chip?) ...[
                  const SizedBox(height: SpacingTokens.xs),
                  chip,
                ],
              ],
            );
          }

          final fraction = view.allowanceMicroUsd <= 0
              ? 0.0
              : view.usedMicroUsd / view.allowanceMicroUsd;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MeterRow(
                label: l10n.assistantUsageZen(
                  assistantDollars(view.usedMicroUsd),
                  assistantDollars(view.allowanceMicroUsd),
                ),
                fraction: fraction,
                tone: ObTone.brand,
                hint: switch (view.conversationsLeft) {
                  final int left => l10n.assistantConversationsLeft(left),
                  null => null,
                },
              ),
              if (pendingChip case final chip?) ...[
                const SizedBox(height: SpacingTokens.xs),
                chip,
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MeterRow extends HookWidget {
  const _MeterRow({
    required this.label,
    required this.fraction,
    required this.tone,
    required this.hint,
  });

  final String label;
  final double fraction;
  final ObTone tone;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;

    return Row(
      children: [
        ObEnvelopeGauge(
          fraction: fraction,
          tone: tone,
          width: 40,
          semanticLabel: label,
        ),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: palette.ink,
                ),
              ),
              if (hint case final text?)
                Text(
                  text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
