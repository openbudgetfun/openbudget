import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/providers/fx_rate_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/utils/date_labels.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The live FX line under an amount field for a foreign-currency account,
/// from `fxRate.quote`: "≈ £78.91" over "1 USD = 0.7891 GBP · Nov 8, 2026 ·
/// market rate".
///
/// When no rate exists the line carries the server's explanation and an
/// action that opens the manual-rate sheet.
class FxRateLine extends HookConsumerWidget {
  const FxRateLine({
    required this.fromCurrencyCode,
    required this.toCurrencyCode,
    required this.date,
    required this.amountMinor,
    this.onSetRate,
    super.key,
  });

  final String fromCurrencyCode;
  final String toCurrencyCode;
  final DateTime date;

  /// The amount in [fromCurrencyCode] shown converted on the line.
  final int? amountMinor;

  /// Opens the manual-rate sheet. Null hides the action, for a form that
  /// offers its own way to pick the rate.
  final VoidCallback? onSetRate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final quoteAsync = ref.watch(
      fxQuoteProvider(fromCurrencyCode, toCurrencyCode, date),
    );

    return quoteAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.only(top: SpacingTokens.xs),
        child: Row(
          children: [
            SkribbleIcon(
              data: OpenBudgetIcons.priceChange,
              size: 14,
              color: palette.mutedInk,
            ),
            const SizedBox(width: SpacingTokens.xs),
            Text(
              l10n.fxRateLoading,
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.mutedInk,
              ),
            ),
          ],
        ),
      ),
      error: (error, _) {
        final message = error is FxRateUnavailableException
            ? error.message
            : error.toString();
        return Padding(
          padding: const EdgeInsets.only(top: SpacingTokens.xs),
          child: Row(
            children: [
              SkribbleIcon(
                data: OpenBudgetIcons.warning,
                size: 14,
                color: palette.overspent,
              ),
              const SizedBox(width: SpacingTokens.xs),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.overspent,
                  ),
                ),
              ),
              if (onSetRate case final onSetRate?)
                TextButton(
                  onPressed: onSetRate,
                  child: Text(l10n.fxRateSetRate),
                ),
            ],
          ),
        );
      },
      data: (quote) {
        final rate = ExactDecimal.tryParse(quote.rate);
        final converted = (amountMinor != null && rate != null)
            ? convertMinorUnits(
                amountMinor: amountMinor!,
                exchangeRate: rate,
                transactionExponent: currencyDecimalsForCode(
                  fromCurrencyCode,
                ),
                functionalExponent: currencyDecimalsForCode(toCurrencyCode),
              )
            : null;
        final convertedLabel = converted == null
            ? null
            : formatMinorForCode(converted, toCurrencyCode);
        // The converted figure is what the eye wants; the rate, its date
        // and where it came from are the footnote under it.
        final provenance = <String>[
          l10n.netWorthRateLine(fromCurrencyCode, quote.rate, toCurrencyCode),
          // Each part keeps to one line: a date split after its comma, or
          // "market" orphaned from "rate", reads badly.
          DateLabels.full(context, quote.rateDate).replaceAll(' ', '\u00a0'),
          fxRateSourceLabel(l10n, quote.source).replaceAll(' ', '\u00a0'),
          if (quote.isStale) l10n.fxRateStale,
        ].join(' \u00b7 ');
        return Padding(
          padding: const EdgeInsets.only(top: SpacingTokens.sm),
          child: Row(
            children: [
              SkribbleIcon(
                data: OpenBudgetIcons.priceChange,
                size: 18,
                color: palette.brand,
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (convertedLabel != null)
                      Text(
                        l10n.fxRateApproximate(convertedLabel),
                        semanticsLabel: l10n.fxRateConvertsTo(convertedLabel),
                        style: ObTextStyles.amount(
                          theme.textTheme.titleSmall,
                        ).copyWith(color: palette.ink),
                      ),
                    Text(
                      provenance,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: quote.isStale
                            ? palette.underfunded
                            : palette.mutedInk,
                      ),
                    ),
                  ],
                ),
              ),
              if (onSetRate case final onSetRate?)
                TextButton(
                  onPressed: onSetRate,
                  child: Text(l10n.fxRateSetRate),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// The localized name of where a rate came from: "market rate", "your
/// rate" and so on, never the raw enum name.
String fxRateSourceLabel(AppLocalizations l10n, FxRateSource source) =>
    switch (source) {
      FxRateSource.identity => l10n.fxRateSourceIdentity,
      FxRateSource.market => l10n.fxRateSourceMarket,
      FxRateSource.implied => l10n.fxRateSourceImplied,
      FxRateSource.manual => l10n.fxRateSourceManual,
    };

/// The manual-rate sheet: the user types the rate, the form carries it as a
/// manual `fxRate` on the transaction.
class ManualRateSheet extends HookConsumerWidget {
  const ManualRateSheet({
    required this.fromCurrencyCode,
    required this.toCurrencyCode,
    required this.onRateChosen,
    this.initialRate,
    this.explanation,
    super.key,
  });

  final String fromCurrencyCode;
  final String toCurrencyCode;

  /// A previous manual rate, pre-filled so it can be confirmed or edited.
  final String? initialRate;

  /// Why the sheet opened, shown when the server refused to price.
  final String? explanation;
  final ValueChanged<String> onRateChosen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rateController = useTextEditingController(text: initialRate ?? '');
    final error = useState<String?>(null);

    return Padding(
      padding: EdgeInsets.only(
        left: SpacingTokens.md,
        right: SpacingTokens.md,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const ObIconBadge(
                icon: SkribbleIcon(data: OpenBudgetIcons.priceChange),
                spot: 2,
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(
                  l10n.fxRateSetRateTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          if (explanation != null) ...[
            const SizedBox(height: SpacingTokens.xs),
            Text(
              explanation!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).ob.overspent,
              ),
            ),
          ],
          const SizedBox(height: SpacingTokens.md),
          TextField(
            key: const Key('manual-rate-field'),
            controller: rateController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: ObTextStyles.amount(Theme.of(context).textTheme.titleLarge),
            decoration: InputDecoration(
              labelText: l10n.fxRateRateField,
              helperText: '1 $fromCurrencyCode = ? $toCurrencyCode',
              errorText: error.value,
              prefixIcon: const ObFieldIcon(data: OpenBudgetIcons.priceChange),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          FilledButton(
            key: const Key('manual-rate-use-button'),
            onPressed: () {
              final text = rateController.text.trim();
              final rate = ExactDecimal.tryParse(text);
              if (rate == null || rate.numerator <= BigInt.zero) {
                error.value = l10n.fxRateInvalidRate;
                return;
              }
              Navigator.of(context).pop();
              onRateChosen(rate.toString());
            },
            child: Text(l10n.fxRateUseThisRate),
          ),
          const SizedBox(height: SpacingTokens.md),
        ],
      ),
    );
  }
}
