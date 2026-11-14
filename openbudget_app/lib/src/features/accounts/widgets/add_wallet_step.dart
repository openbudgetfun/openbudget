import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/hooks/use_wallet_input.dart';
import 'package:openbudget_app/src/features/accounts/models/add_wallet_state.dart';
import 'package:openbudget_app/src/features/accounts/providers/add_wallet_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/wallet_provider.dart';
import 'package:openbudget_app/src/features/accounts/utils/add_wallet_labels.dart';
import 'package:openbudget_app/src/features/accounts/utils/wallet_holdings_labels.dart';
import 'package:openbudget_app/src/features/accounts/widgets/add_wallet_views.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The paste field, for tests and Patrol page objects.
const addWalletFieldKey = Key('add-wallet-address-field');

/// The "Add wallet" button.
const addWalletSubmitKey = Key('add-wallet-submit');

/// Adds a crypto wallet: one paste field that detects the chain.
///
/// The address is parsed as it is typed, by the same core parser the server
/// checks again. A secret (a private key or a recovery phrase) is refused on
/// the device: the field empties itself and nothing is sent. One address on
/// several chains (an EVM address) is looked ahead at through
/// `wallet.preview` and offered as a picker of chain stamps. The wallet is
/// read for the first time while a "Reading…" state stays on screen, and a
/// wallet whose every chain failed gets a retry.
///
/// Read-only: this screen never asks for a key.
class AddWalletStep extends HookConsumerWidget {
  const AddWalletStep({
    required this.entityId,
    required this.onDone,
    super.key,
  });

  final String entityId;

  /// Called when the person is finished, to leave the flow.
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final controller = useTextEditingController();
    final input = useWalletInput(controller);
    final chosen = useState(0);
    final flow = ref.watch(addWalletFlowProvider);
    final notifier = ref.read(addWalletFlowProvider.notifier);
    // Until the server answers, every chain is assumed to be on.
    final supported = ref.watch(supportedWalletNetworksProvider).value;

    final candidates = input.candidates;
    final candidate = candidates.isEmpty
        ? null
        : candidates[math.min(chosen.value, candidates.length - 1)];
    final readable = candidate == null
        ? const <WalletNetwork>[]
        : [
            for (final network in candidate.networks)
              if (supported == null || supported.contains(network)) network,
          ];
    final preview = flow.preview;
    final previewEmpty =
        preview is WalletPreviewLoaded && preview.preview.networks.isEmpty;
    final unavailable = candidate != null && (readable.isEmpty || previewEmpty);
    final wantsPreview =
        candidate != null && !unavailable && readable.length > 1;
    final previewKey = wantsPreview ? candidate.canonical : null;

    // Look ahead whenever the address changes to one with several networks,
    // and forget the look-ahead when it stops being one.
    useEffect(() {
      scheduleMicrotask(() {
        if (!context.mounted) return;
        if (previewKey == null) {
          notifier.clearPreview();
        } else {
          unawaited(
            notifier.loadPreview(
              entityId: entityId,
              address: controller.text.trim(),
            ),
          );
        }
      });
      return null;
    }, [previewKey]);

    // A new answer to the which-chain question starts from the first.
    useEffect(() {
      chosen.value = 0;
      return null;
    }, [candidates.map((c) => c.canonical).join(',')]);

    final waitingOnPreview =
        wantsPreview &&
        (preview is WalletPreviewIdle || preview is WalletPreviewLoading);
    final canSubmit =
        candidate != null &&
        !unavailable &&
        !waitingOnPreview &&
        (preview is! WalletPreviewLoaded || flow.selected.isNotEmpty);

    Future<void> submit() async {
      final target = candidate;
      if (target == null || !canSubmit) return;
      final text = controller.text.trim();
      await notifier.submit(
        entityId: entityId,
        address: text,
        network: target.networks.first,
        accountName: walletAccountName(l10n, candidate: target, input: text),
      );
    }

    void addAnother() {
      controller.clear();
      notifier.reset();
    }

    final submission = flow.submission;
    switch (submission) {
      case AddWalletReading(:final networks):
        return _Scroll(child: WalletReadingView(networks: networks));
      case AddWalletUnreadable(:final networks, :final reason):
        return _Scroll(
          child: WalletUnreadableView(
            networks: networks,
            reason: reason,
            onRetry: () => notifier.retryRead(entityId: entityId),
            onDone: onDone,
          ),
        );
      case AddWalletAdded(:final accountName, :final networks):
        return _Scroll(
          child: WalletAddedView(
            accountName: accountName,
            networks: networks,
            onDone: onDone,
            onAddAnother: addAnother,
          ),
        );
      case AddWalletIdle() || AddWalletFailed():
        break;
    }

    final refusal = input.refusal;
    final invalidHint = input.invalidHint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _Scroll(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.walletAddIntro,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.ob.mutedInk,
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  l10n.walletAddFieldLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                // A plain field rather than ObTextField: what is pasted here
                // can be a secret, so the keyboard must not learn from it.
                TextField(
                  key: addWalletFieldKey,
                  controller: controller,
                  minLines: 1,
                  maxLines: 3,
                  autocorrect: false,
                  enableSuggestions: false,
                  enableIMEPersonalizedLearning: false,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => notifier.dismissFailure(),
                  decoration: InputDecoration(
                    hintText: l10n.walletAddFieldHint,
                    errorText: invalidHint == null
                        ? null
                        : walletInvalidMessage(l10n, invalidHint),
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                if (refusal != null)
                  _RefusalPanel(refusal: refusal)
                else if (candidate != null)
                  _Detection(
                    candidates: candidates,
                    candidate: candidate,
                    chosen: math.min(chosen.value, candidates.length - 1),
                    onChosen: (index) => chosen.value = index,
                    readable: readable,
                    unavailable: unavailable,
                    preview: preview,
                    selected: flow.selected,
                    onToggle: notifier.toggleNetwork,
                    onRetryPreview: () => notifier.loadPreview(
                      entityId: entityId,
                      address: controller.text.trim(),
                    ),
                  ),
                if (submission case AddWalletFailed(:final message)) ...[
                  const SizedBox(height: SpacingTokens.md),
                  ObStatePanel.problem(
                    title: l10n.walletAddFailedTitle,
                    message: message ?? l10n.walletAddFailedMessage,
                  ),
                ],
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.sm,
              SpacingTokens.md,
              SpacingTokens.md,
            ),
            child: FilledButton(
              key: addWalletSubmitKey,
              onPressed: canSubmit ? submit : null,
              child: Text(l10n.walletAddButton),
            ),
          ),
        ),
      ],
    );
  }
}

class _Scroll extends HookWidget {
  const _Scroll({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(
      SpacingTokens.md,
      SpacingTokens.md,
      SpacingTokens.md,
      SpacingTokens.xl,
    ),
    child: child,
  );
}

/// A refused input, in the overspent tone.
///
/// A secret (a private key or a recovery phrase) gets a lock, because the
/// field was cleared to keep it safe; the other refusals get a warning.
class _RefusalPanel extends HookWidget {
  const _RefusalPanel({required this.refusal});

  final WalletAddressRefusal refusal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final copy = walletRefusalCopy(AppLocalizations.of(context), refusal);
    return Semantics(
      liveRegion: true,
      container: true,
      child: ObCard(
        tone: ObTone.overspent,
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkribbleIcon(
              data: isSecretRefusal(refusal)
                  ? OpenBudgetIcons.lock
                  : OpenBudgetIcons.warning,
              size: 24,
              color: palette.hue(ObTone.overspent),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    copy.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: palette.ink,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    copy.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.mutedInk,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// What the pasted address was detected as, and what to do next with it.
class _Detection extends HookWidget {
  const _Detection({
    required this.candidates,
    required this.candidate,
    required this.chosen,
    required this.onChosen,
    required this.readable,
    required this.unavailable,
    required this.preview,
    required this.selected,
    required this.onToggle,
    required this.onRetryPreview,
  });

  final List<WalletAddressCandidate> candidates;
  final WalletAddressCandidate candidate;
  final int chosen;
  final ValueChanged<int> onChosen;
  final List<WalletNetwork> readable;
  final bool unavailable;
  final WalletPreviewState preview;
  final List<WalletNetwork> selected;
  final void Function(WalletNetwork network, {required bool selected}) onToggle;
  final VoidCallback onRetryPreview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final chain = walletNetworkLabel(l10n, candidate.networks.first);
    final mutedBody = theme.textTheme.bodyMedium?.copyWith(
      color: theme.ob.mutedInk,
    );
    final caption = switch (candidate) {
      WalletAddressCandidate(isHdKey: true) => l10n.walletAddDetectedKey(chain),
      WalletAddressCandidate(networks: final n) when n.length > 1 =>
        l10n.walletAddDetectedEvm(readable.length),
      _ => l10n.walletAddDetectedAddress(chain),
    };
    final stampDetail = candidate.isHdKey
        ? _keyDetail(candidate)
        : candidate.networks.length > 1
        ? l10n.walletAddStampMore(candidate.networks.length - 1)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (candidates.length > 1) ...[
          WalletCandidateQuestion(
            candidates: candidates,
            selectedIndex: chosen,
            onSelected: onChosen,
          ),
          const SizedBox(height: SpacingTokens.md),
        ],
        Semantics(
          liveRegion: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ObChainStamp(
                key: const Key('add-wallet-detected-stamp'),
                family: candidate.family,
                label: chain,
                detail: stampDetail,
                words: walletStampWords(l10n),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(caption, style: mutedBody),
              if (candidate.isScriptTypeAmbiguous) ...[
                const SizedBox(height: SpacingTokens.xs),
                Text(l10n.walletAddScriptTypeUnknown, style: mutedBody),
              ],
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        if (unavailable)
          ObStatePanel.empty(
            title: l10n.walletAddUnavailableTitle(chain),
            message: l10n.walletAddUnavailableMessage,
            doodle: WiredDoodleKind.cloud,
            tone: ObTone.neutral,
          )
        else
          switch (preview) {
            WalletPreviewLoading() => ObLoadingPanel(
              label: l10n.walletAddPreviewLoading(
                walletNetworkListLabel(l10n, readable),
              ),
            ),
            WalletPreviewLoaded(:final preview) => WalletNetworkPicker(
              preview: preview,
              selected: selected,
              onToggle: onToggle,
            ),
            WalletPreviewFailed(:final reason) => ObStatePanel.problem(
              title: l10n.walletAddPreviewFailedTitle,
              message: switch (reason) {
                WalletPreviewFailure.rateLimited =>
                  l10n.walletAddPreviewRateLimitedMessage,
                WalletPreviewFailure.unavailable =>
                  l10n.walletAddPreviewFailedMessage,
              },
              action: ObStateAction(
                label: l10n.walletAddPreviewRetry,
                onPressed: onRetryPreview,
              ),
            ),
            WalletPreviewIdle() => const SizedBox.shrink(),
          },
      ],
    );
  }

  /// The key type lettered under the chain: the form the key was pasted in.
  static String? _keyDetail(WalletAddressCandidate candidate) =>
      switch (candidate.hdScriptType) {
        WalletAddressHdScriptType.wpkh => 'zpub',
        WalletAddressHdScriptType.shWpkh => 'ypub',
        WalletAddressHdScriptType.pkh => 'xpub',
        null => 'xpub',
      };
}
