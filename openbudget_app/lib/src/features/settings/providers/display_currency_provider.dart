import 'dart:math' as math;

import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/home/providers/budget_list_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart' as formatter;
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'display_currency_provider.g.dart';

/// The currency the budget displays amounts in, or null when either the
/// display override or the budget's own currency is unsupported.
///
/// A null display currency means conversion is unavailable; call sites format
/// each amount with its raw code instead of assuming dollars.
@riverpod
Future<CurrencyCode?> displayCurrency(Ref ref, String budgetId) async {
  final budget = await ref.watch(budgetDetailProvider(budgetId).future);
  return CurrencyCode.tryParse(
    budget.displayCurrencyCode ?? budget.currencyCode,
  );
}

@riverpod
Future<FxLatestSnapshot?> fxLatestRates(Ref ref) async {
  final client = ref.read(serverpodClientProvider);
  try {
    return await client.fxRate.latest();
  } on Exception {
    return null;
  }
}

@riverpod
Future<DisplayCurrencyConverter> displayCurrencyConverter(
  Ref ref,
  String budgetId,
) async {
  final budget = await ref.watch(budgetDetailProvider(budgetId).future);
  final selectedCurrency = CurrencyCode.tryParse(
    budget.displayCurrencyCode ?? budget.currencyCode,
  );

  final snapshot = await ref.watch(fxLatestRatesProvider.future);
  final ratesByCode = <String, double>{};
  String? baseCurrencyCode;

  if (snapshot != null) {
    baseCurrencyCode = snapshot.baseCurrencyCode;
    for (final quote in snapshot.rates) {
      ratesByCode[quote.currencyCode] = quote.rate;
    }
  }

  return DisplayCurrencyConverter(
    displayCurrency: selectedCurrency,
    baseCurrencyCode: baseCurrencyCode,
    ratesByCode: ratesByCode,
  );
}

typedef UpdateDisplayCurrency = Future<void> Function({
  required String budgetId,
  required bool clearDisplayCurrencyCode,
  String? displayCurrencyCode,
});

@riverpod
UpdateDisplayCurrency updateDisplayCurrency(Ref ref) =>
    ({
      required budgetId,
      required clearDisplayCurrencyCode,
      displayCurrencyCode,
    }) async {
      final client = ref.read(serverpodClientProvider);
      await client.budget.update(
        UuidValue.fromString(budgetId),
        displayCurrencyCode: displayCurrencyCode,
        clearDisplayCurrencyCode: clearDisplayCurrencyCode,
      );

      ref
        ..invalidate(budgetDetailProvider(budgetId))
        ..invalidate(budgetSummaryProvider(budgetId))
        ..invalidate(displayCurrencyProvider(budgetId))
        ..invalidate(displayCurrencyConverterProvider(budgetId))
        ..invalidate(budgetListProvider)
        ..invalidate(fxLatestRatesProvider);
    };

class DisplayCurrencyConverter {
  const DisplayCurrencyConverter({
    required this.displayCurrency,
    required this.baseCurrencyCode,
    required this._ratesByCode,
  });

  /// Null when the budget's display currency is not supported by OpenBudget.
  final CurrencyCode? displayCurrency;
  final String? baseCurrencyCode;
  final Map<String, double> _ratesByCode;

  bool get hasRates => _ratesByCode.isNotEmpty;

  /// Formats an amount in [currencyCode], converting to the display currency
  /// only when both currencies are supported and a rate is available.
  ///
  /// Unsupported source or display codes fall back to the raw code and a
  /// plain two-decimal amount, never to another currency's symbol.
  String formatAmount({
    required int amountCents,
    required String currencyCode,
  }) {
    final source = CurrencyCode.tryParse(currencyCode);
    final converted = source == null
        ? null
        : convertCents(amountCents: amountCents, sourceCurrency: source);
    if (converted == null) {
      return formatter.formatCentsForCode(amountCents, currencyCode);
    }

    return formatter.formatCents(converted, displayCurrency!);
  }

  int? convertCents({
    required int amountCents,
    required CurrencyCode sourceCurrency,
  }) {
    final targetCurrency = displayCurrency;
    if (targetCurrency == null) return null;
    if (sourceCurrency == targetCurrency) return amountCents;

    final sourceRate = _lookupRate(sourceCurrency);
    final targetRate = _lookupRate(targetCurrency);
    if (sourceRate == null || targetRate == null) return null;
    if (sourceRate <= 0 || targetRate <= 0) return null;

    final sourceFactor = _pow10(sourceCurrency.decimals);
    final targetFactor = _pow10(targetCurrency.decimals);

    final amountInSourceUnits = amountCents / sourceFactor;
    final amountInTargetUnits = amountInSourceUnits / sourceRate * targetRate;
    final amountInTargetCents = (amountInTargetUnits * targetFactor).round();
    return amountInTargetCents;
  }

  /// Converts every bucket to the display currency, keyed by raw code.
  ///
  /// Returns null when any code is unsupported or lacks a rate, so the caller
  /// keeps the per-currency breakdown instead of dropping money.
  int? convertTotalsToDisplay(Map<String, int> totalsByCurrency) {
    var total = 0;
    for (final entry in totalsByCurrency.entries) {
      final source = CurrencyCode.tryParse(entry.key);
      if (source == null) return null;
      final converted = convertCents(
        amountCents: entry.value,
        sourceCurrency: source,
      );
      if (converted == null) return null;
      total += converted;
    }
    return total;
  }

  double? _lookupRate(CurrencyCode currency) {
    final direct = _ratesByCode[currency.code];
    if (direct != null) return direct;
    if (baseCurrencyCode == currency.code) return 1;
    return null;
  }

  static int _pow10(int exponent) => math.pow(10, exponent).toInt();
}
