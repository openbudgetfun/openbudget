import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_proposals_provider.dart';
import 'package:openbudget_app/src/features/assistant/widgets/assistant_proposal_card_view.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Every proposal the assistant is waiting on for one budget, plus the ones
/// already resolved.
class AssistantProposalsScreen extends HookConsumerWidget {
  const AssistantProposalsScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final proposals = ref.watch(assistantProposalsProvider(entityId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.assistantProposalsTitle)),
      body: proposals.when(
        loading: () => ObLoadingPanel(label: l10n.assistantProposalsLoading),
        error: (_, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: ObStatePanel.problem(
            title: l10n.assistantProposalsLoadError,
            action: ObStateAction(
              label: l10n.assistantRetry,
              onPressed: () =>
                  ref.invalidate(assistantProposalsProvider(entityId)),
            ),
          ),
        ),
        data: (state) {
          if (state.pending.isEmpty && state.history.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(SpacingTokens.md),
              children: [
                ObStatePanel.empty(
                  title: l10n.assistantProposalsEmptyTitle,
                  message: l10n.assistantProposalsEmptyMessage,
                  doodle: WiredDoodleKind.leaf,
                  tone: ObTone.review,
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              0,
              SpacingTokens.md,
              SpacingTokens.xl,
            ),
            children: [
              ObSectionHeader(
                title: l10n.assistantProposalsPendingSection,
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
              ),
              if (state.pending.isEmpty)
                Text(
                  l10n.assistantProposalsEmptyMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).ob.mutedInk,
                  ),
                )
              else
                for (final proposal in state.pending)
                  Padding(
                    padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                    child: AssistantProposalCardView(
                      entityId: entityId,
                      proposal: proposal,
                    ),
                  ),
              if (state.history.isNotEmpty)
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.assistantProposalsHistorySection,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  children: [
                    for (final proposal in state.history)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: SpacingTokens.xs,
                        ),
                        child: AssistantProposalCardView(
                          entityId: entityId,
                          proposal: proposal,
                        ),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
