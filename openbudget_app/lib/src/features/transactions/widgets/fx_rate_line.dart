import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/providers/fx_rate_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The live FX line under an amount field for a foreign-currency account:
/// "≈ £78.91 · 1 USD = 0.7891 GBP · 8 Nov · market", from `fxRate.quote`.
///
/// When no rate exists the line carries the server's explanation and an
/// action that opens the manual-rate sheet.
class FxRateLine extends HookConsumerWidget {
  const FxRateLine({
    required this.fromCurrencyCode,
    required this.toCurrencyCode,
    required this.date,
    required this.amountMinor,
    required this.onSetRate,
    super.key,
  });

  final String fromCurrencyCode;
  final String toCurrencyCode;
  final DateTime date;

  /// The amount in [fromCurrencyCode] shown converted on the line.
  final int? amountMinor;

  /// Opens the manual-rate sheet.
  final VoidCallback onSetRate;

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
        final parts = <String>[
          if (converted != null)
            l10n.fxRateApproximate(
              formatMinorForCode(converted, toCurrencyCode),
            ),
          '1 $fromCurrencyCode = ${quote.rate} $toCurrencyCode',
          _shortDate(quote.rateDate),
          quote.source.name,
          if (quote.isStale) l10n.fxRateStale,
        ];
        return Padding(
          padding: const EdgeInsets.only(top: SpacingTokens.xs),
          child: Row(
            children: [
              SkribbleIcon(
                data: OpenBudgetIcons.priceChange,
                size: 14,
                color: palette.mutedInk,
              ),
              const SizedBox(width: SpacingTokens.xs),
              Expanded(
                child: Text(
                  parts.join(' \u00b7 '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
              ),
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

  static String _shortDate(DateTime date) =>
      '${date.day} ${_monthAbbr(date.month)} ${date.year}';

  static String _monthAbbr(int month) => switch (month) {
    1 => 'Jan',
    2 => 'Feb',
    3 => 'Mar',
    4 => 'Apr',
    5 => 'May',
    6 => 'Jun',
    7 => 'Jul',
    8 => 'Aug',
    9 => 'Sep',
    10 => 'Oct',
    11 => 'Nov',
    _ => 'Dec',
  };
}

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
          Text(
            l10n.fxRateSetRateTitle,
            style: Theme.of(context).textTheme.titleMedium,
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
            decoration: InputDecoration(
              labelText: l10n.fxRateRateField,
              helperText: '1 $fromCurrencyCode = ? $toCurrencyCode',
              errorText: error.value,
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
