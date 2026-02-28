// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

import 'dart:math' as math;

import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/home/providers/budget_list_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart' as formatter;
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'display_currency_provider.g.dart';

@riverpod
Future<CurrencyCode> displayCurrency(Ref ref, String budgetId) async {
  final budget = await ref.watch(budgetDetailProvider(budgetId).future);
  return parseCurrencyCode(budget.displayCurrencyCode ?? budget.currencyCode);
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
  final selectedCurrency = parseCurrencyCode(
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

typedef UpdateDisplayCurrency =
    Future<void> Function({
      required String budgetId,
      required bool clearDisplayCurrencyCode,
      String? displayCurrencyCode,
    });

@riverpod
UpdateDisplayCurrency updateDisplayCurrency(Ref ref) {
  return ({
    required String budgetId,
    required bool clearDisplayCurrencyCode,
    String? displayCurrencyCode,
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
}

class DisplayCurrencyConverter {
  const DisplayCurrencyConverter({
    required this.displayCurrency,
    required this.baseCurrencyCode,
    required Map<String, double> ratesByCode,
  }) : _ratesByCode = ratesByCode;

  final CurrencyCode displayCurrency;
  final String? baseCurrencyCode;
  final Map<String, double> _ratesByCode;

  bool get hasRates => _ratesByCode.isNotEmpty;

  String formatAmount({
    required int amountCents,
    required CurrencyCode sourceCurrency,
  }) {
    final convertedCents = convertCents(
      amountCents: amountCents,
      sourceCurrency: sourceCurrency,
    );

    if (convertedCents == null) {
      return formatter.formatCents(amountCents, sourceCurrency);
    }

    return formatter.formatCents(convertedCents, displayCurrency);
  }

  int? convertCents({
    required int amountCents,
    required CurrencyCode sourceCurrency,
  }) {
    if (sourceCurrency == displayCurrency) return amountCents;

    final sourceRate = _lookupRate(sourceCurrency);
    final targetRate = _lookupRate(displayCurrency);
    if (sourceRate == null || targetRate == null) return null;
    if (sourceRate <= 0 || targetRate <= 0) return null;

    final sourceFactor = _pow10(sourceCurrency.decimals);
    final targetFactor = _pow10(displayCurrency.decimals);

    final amountInSourceUnits = amountCents / sourceFactor;
    final amountInTargetUnits = amountInSourceUnits / sourceRate * targetRate;
    final amountInTargetCents = (amountInTargetUnits * targetFactor).round();
    return amountInTargetCents;
  }

  int? convertTotalsToDisplay(Map<CurrencyCode, int> totalsByCurrency) {
    var total = 0;
    for (final entry in totalsByCurrency.entries) {
      final converted = convertCents(
        amountCents: entry.value,
        sourceCurrency: entry.key,
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

  static int _pow10(int exponent) {
    return math.pow(10, exponent).toInt();
  }
}
