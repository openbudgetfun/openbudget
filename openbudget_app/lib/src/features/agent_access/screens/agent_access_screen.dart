import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/agent_access/models/agent_access_state.dart';
import 'package:openbudget_app/src/features/agent_access/providers/agent_access_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Manages the personal access tokens external agents use over MCP.
class AgentAccessScreen extends HookConsumerWidget {
  const AgentAccessScreen({super.key});

  static const nameFieldKey = Key('agent-access-name');
  static const canProposeSwitchKey = Key('agent-access-can-propose');
  static const createButtonKey = Key('agent-access-create');
  static const tokenDialogKey = Key('agent-access-token-dialog');
  static const copyButtonKey = Key('agent-access-copy');

  /// The revoke action for one token, so tests can target a specific row.
  static Key revokeButtonKey(UuidValue id) => Key('agent-access-revoke-$id');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final tokensAsync = ref.watch(agentAccessTokensProvider);
    final name = useTextEditingController();
    final canPropose = useState(true);
    final nameError = useState<String?>(null);
    final actions = ref.read(agentAccessTokensProvider.notifier);
    final state = tokensAsync.asData?.value;
    final failure = state?.failure;

    useEffect(() {
      if (failure == null) return null;
      final message = switch (failure) {
        AgentAccessValidationFailure(:final message) => message,
        AgentAccessUnknownFailure() => l10n.agentAccessFailure,
      };
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        showAppToast(
          context,
          message: message,
          variant: AppToastVariant.error,
        );
        actions.clearFailure();
      });
      return null;
    }, [failure]);

    Future<void> create() async {
      final trimmed = name.text.trim();
      if (trimmed.isEmpty) {
        nameError.value = l10n.agentAccessNameRequired;
        return;
      }
      nameError.value = null;

      final created = await actions.create(
        name: trimmed,
        canPropose: canPropose.value,
      );
      if (created == null || !context.mounted) return;
      name.clear();

      final copied = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => _TokenCreatedDialog(token: created.token),
      );
      if (copied == true && context.mounted) {
        showAppToast(
          context,
          message: l10n.agentAccessCopiedToast,
          variant: AppToastVariant.success,
        );
      }
    }

    Future<void> revoke(AgentAccessTokenView token) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.agentAccessRevokeTitle),
          content: Text(l10n.agentAccessRevokeMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.dialogCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: palette.overspentWash,
                foregroundColor: palette.overspent,
              ),
              child: Text(l10n.agentAccessRevokeConfirm),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;

      final revoked = await actions.revoke(token.id);
      if (!revoked || !context.mounted) return;
      showAppToast(
        context,
        message: l10n.agentAccessRevokedToast,
        variant: AppToastVariant.success,
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            final navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.pop();
            } else {
              context.go(homePath);
            }
          },
          icon: const SkribbleIcon(data: OpenBudgetIcons.back),
        ),
        title: Text(l10n.agentAccessTitle),
      ),
      body: tokensAsync.when(
        loading: () => Center(
          child: ObLoadingPanel(label: l10n.agentAccessLoading),
        ),
        error: (_, _) => ListView(
          padding: const EdgeInsets.all(SpacingTokens.md),
          children: [
            ObStatePanel.problem(
              title: l10n.agentAccessLoadError,
              message: l10n.agentAccessLoadErrorBody,
              action: ObStateAction(
                label: l10n.agentAccessRetry,
                onPressed: () => ref.invalidate(agentAccessTokensProvider),
              ),
            ),
          ],
        ),
        data: (state) => ListView(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.md,
            SpacingTokens.md,
            SpacingTokens.md,
            SpacingTokens.xl,
          ),
          children: [
            Text(
              l10n.agentAccessIntro,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.mutedInk,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            ObCard(
              padding: const EdgeInsets.all(SpacingTokens.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ObTextField(
                    key: nameFieldKey,
                    controller: name,
                    labelText: l10n.agentAccessTokenName,
                    hintText: l10n.agentAccessTokenNameHint,
                    onChanged: (_) {
                      if (nameError.value != null) nameError.value = null;
                    },
                  ),
                  if (nameError.value case final message?) ...[
                    const SizedBox(height: SpacingTokens.xs),
                    Text(
                      message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.overspent,
                      ),
                    ),
                  ],
                  SwitchListTile(
                    key: canProposeSwitchKey,
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.agentAccessCanPropose),
                    subtitle: Text(
                      l10n.agentAccessCanProposeHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.mutedInk,
                      ),
                    ),
                    value: canPropose.value,
                    onChanged: state.isCreating
                        ? null
                        : (value) => canPropose.value = value,
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  ObFilledButton(
                    key: createButtonKey,
                    onPressed: state.isCreating
                        ? null
                        : () => unawaited(create()),
                    isLoading: state.isCreating,
                    loadingLabel: l10n.agentAccessCreating,
                    child: Text(l10n.agentAccessCreate),
                  ),
                ],
              ),
            ),
            ObSectionHeader(
              title: l10n.agentAccessTokensSection,
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.xs,
                SpacingTokens.lg,
                SpacingTokens.xs,
                SpacingTokens.xs,
              ),
            ),
            if (state.tokens.isEmpty)
              ObStatePanel.empty(
                title: l10n.agentAccessEmptyTitle,
                message: l10n.agentAccessEmptyBody,
              )
            else
              for (final token in state.tokens) ...[
                _AgentTokenCard(
                  token: token,
                  isRevoking: state.revokingId == token.id,
                  onRevoke: () => unawaited(revoke(token)),
                ),
                const SizedBox(height: SpacingTokens.sm),
              ],
            ObSectionHeader(
              title: l10n.agentAccessSetupTitle,
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.xs,
                SpacingTokens.lg,
                SpacingTokens.xs,
                SpacingTokens.xs,
              ),
            ),
            Text(
              l10n.agentAccessSetupBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.mutedInk,
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              l10n.agentAccessSetupExample,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                color: palette.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One token in the list, with its prefix, dates and revoke action.
class _AgentTokenCard extends HookWidget {
  const _AgentTokenCard({
    required this.token,
    required this.isRevoking,
    required this.onRevoke,
  });

  final AgentAccessTokenView token;
  final bool isRevoking;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final isRevoked = token.revokedAt != null;
    final mutedStyle = theme.textTheme.bodySmall?.copyWith(
      color: palette.mutedInk,
    );
    final tone = isRevoked ? ObTone.neutral : ObTone.brand;

    return ObCard(
      padding: const EdgeInsets.all(SpacingTokens.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: ObRoughDecoration(
                  color: palette.wash(tone),
                  outline: palette.quietPen,
                  seed: 17,
                ),
                child: SkribbleIcon(
                  data: OpenBudgetIcons.lock,
                  size: 20,
                  color: palette.hue(tone),
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(
                  token.name,
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isRevoked) ObToneChip(label: l10n.agentAccessRevoked),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            l10n.agentAccessTokenPrefix(token.tokenPrefix),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            l10n.agentAccessCreated(_formatDate(token.createdAt)),
            style: mutedStyle,
          ),
          Text(
            token.lastUsedAt == null
                ? l10n.agentAccessNeverUsed
                : l10n.agentAccessLastUsed(_formatDate(token.lastUsedAt!)),
            style: mutedStyle,
          ),
          if (!isRevoked)
            Align(
              alignment: Alignment.centerRight,
              child: ObTextButton(
                key: AgentAccessScreen.revokeButtonKey(token.id),
                onPressed: isRevoking ? null : onRevoke,
                child: Text(
                  isRevoking
                      ? l10n.agentAccessRevoking
                      : l10n.agentAccessRevoke,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime timestamp) =>
      DateFormat.yMMMd().format(timestamp.toLocal());
}

/// Shows a freshly created secret once, with a copy action.
class _TokenCreatedDialog extends HookWidget {
  const _TokenCreatedDialog({required this.token});

  final String token;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    Future<void> copy() async {
      await Clipboard.setData(ClipboardData(text: token));
      if (!context.mounted) return;
      Navigator.of(context).pop(true);
    }

    return AlertDialog(
      key: AgentAccessScreen.tokenDialogKey,
      title: Text(l10n.agentAccessTokenDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkribbleIcon(
                  data: OpenBudgetIcons.warning,
                  size: 20,
                  color: palette.hue(ObTone.underfunded),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(
                    l10n.agentAccessTokenDialogWarning,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.mutedInk,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SpacingTokens.sm),
              decoration: ObRoughDecoration(
                color: palette.wash(ObTone.brand),
                outline: palette.quietPen,
                seed: 29,
              ),
              child: SelectableText(
                token,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.dialogDone),
        ),
        FilledButton(
          key: AgentAccessScreen.copyButtonKey,
          onPressed: () => unawaited(copy()),
          child: Text(l10n.agentAccessCopyToken),
        ),
      ],
    );
  }
}
