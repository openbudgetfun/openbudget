import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_timeline_item.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_proposal_actions_provider.dart';
import 'package:openbudget_app/src/features/assistant/widgets/assistant_text.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

enum _ProposalAction { apply, dismiss }

/// A change the assistant suggests, with the two decisions a person can make.
class AssistantProposalCardView extends HookConsumerWidget {
  const AssistantProposalCardView({
    required this.entityId,
    required this.proposal,
    super.key,
  });

  final String entityId;
  final AssistantProposalCard proposal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final busy = useState<_ProposalAction?>(null);
    final isPending = proposal.status == AgentProposalStatus.pending;

    Future<void> resolve(_ProposalAction action) async {
      if (busy.value != null) return;
      busy.value = action;

      try {
        final actions = ref.read(assistantProposalActionsProvider.notifier);
        if (action == _ProposalAction.apply) {
          await actions.apply(entityId: entityId, proposalId: proposal.id);
        } else {
          await actions.dismiss(entityId: entityId, proposalId: proposal.id);
        }

        if (context.mounted) {
          showAppToast(
            context,
            message: action == _ProposalAction.apply
                ? l10n.assistantProposalAppliedToast
                : l10n.assistantProposalDismissedToast,
            variant: AppToastVariant.success,
          );
        }
      } on Object {
        if (context.mounted) {
          showAppToast(
            context,
            message: l10n.assistantProposalActionError,
            variant: AppToastVariant.error,
          );
        }
      } finally {
        busy.value = null;
      }
    }

    return ObCard(
      tone: isPending ? ObTone.review : null,
      padding: const EdgeInsets.all(SpacingTokens.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: SpacingTokens.xs,
            runSpacing: SpacingTokens.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ObToneChip(
                label: assistantProposalKindLabel(l10n, proposal.kind),
                tone: ObTone.review,
                icon: SkribbleIcon(
                  data: OpenBudgetIcons.sparkle,
                  size: 14,
                  color: palette.review,
                ),
              ),
              if (!isPending)
                ObToneChip(
                  label: assistantProposalStatusLabel(l10n, proposal.status),
                  tone: proposal.status == AgentProposalStatus.applied
                      ? ObTone.funded
                      : ObTone.neutral,
                  icon: SkribbleIcon(
                    data: proposal.status == AgentProposalStatus.applied
                        ? OpenBudgetIcons.checkCircle
                        : OpenBudgetIcons.close,
                    size: 14,
                    color: proposal.status == AgentProposalStatus.applied
                        ? palette.funded
                        : palette.mutedInk,
                  ),
                ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            proposal.summary,
            style: theme.textTheme.bodyLarge?.copyWith(color: palette.ink),
          ),
          if (isPending) ...[
            const SizedBox(height: SpacingTokens.xs),
            Wrap(
              spacing: SpacingTokens.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ObFilledButton(
                  onPressed: busy.value == null
                      ? () => resolve(_ProposalAction.apply)
                      : null,
                  isLoading: busy.value == _ProposalAction.apply,
                  loadingLabel: l10n.assistantApply,
                  child: Text(l10n.assistantApply),
                ),
                ObTextButton(
                  onPressed: busy.value == null
                      ? () => resolve(_ProposalAction.dismiss)
                      : null,
                  child: Text(l10n.assistantDismiss),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
