import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_export_provider.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Offers the tax summary as a download for an accountant.
///
/// The button asks the server for a signed link to the summary ZIP and opens
/// it. While the link is made the button shows its busy state; if either step
/// fails the card says so in plain words and the button stays ready to try
/// again.
class TaxExportCard extends HookConsumerWidget {
  const TaxExportCard({required this.entityId, this.startYear, super.key});

  final String entityId;

  /// The tax year to export; null lets the server use the current one.
  final int? startYear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final export = ref.watch(taxExportProvider);
    final failure = export.hasError ? export.error : null;

    return ObCard(
      key: const Key('tax-export-card'),
      raised: true,
      margin: const EdgeInsets.only(bottom: SpacingTokens.xs),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ObIconBadge(
                icon: SkribbleIcon(data: OpenBudgetIcons.download),
                spot: 1,
                seed: 9,
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.taxExportTitle,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Text(
                      l10n.taxExportMessage,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.mutedInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          ObFilledButton(
            key: const Key('tax-export-button'),
            isLoading: export.isLoading,
            loadingLabel: l10n.taxExportPreparing,
            onPressed: () => ref
                .read(taxExportProvider.notifier)
                .exportSummary(entityId: entityId, startYear: startYear),
            child: Text(l10n.taxExportButton),
          ),
          if (failure != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            Semantics(
              liveRegion: true,
              child: Row(
                key: const Key('tax-export-error'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkribbleIcon(
                    data: OpenBudgetIcons.warning,
                    size: 20,
                    color: palette.hue(ObTone.overspent),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Expanded(
                    child: Text(
                      failure is TaxExportOpenException
                          ? l10n.taxExportOpenFailed
                          : l10n.taxExportFailed,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
