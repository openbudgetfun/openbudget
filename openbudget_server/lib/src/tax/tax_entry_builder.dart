import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/tax/tax_fx_rates.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;

/// What one budget's transactions contribute to a tax input.
class TaxEntryBuildResult {
  const TaxEntryBuildResult({
    required this.entries,
    required this.uncategorizedCount,
    required this.convertedCount,
  });

  /// The entries dated inside the tax year, in the report's currency.
  final List<TaxEntry> entries;

  /// Transactions that belonged in the year but had no tax category.
  final int uncategorizedCount;

  /// Entries whose amount was converted from another currency.
  final int convertedCount;
}

/// Turns a budget's transactions into tax entries for [year].
///
/// Transfers are skipped, split parents give way to their children, and a
/// transaction's own category overrides its envelope's default. Transactions
/// without a category are not entries; they are counted so the report can
/// say some figures are missing.
TaxEntryBuildResult buildTaxEntries({
  required List<Transaction> transactions,
  required Map<UuidValue, Envelope> envelopesById,
  required TaxYear year,
  required TaxFxRates rates,
  required String targetCurrencyCode,
}) {
  final splitParentIds = <UuidValue>{
    for (final transaction in transactions)
      if (transaction.parentTransactionId != null)
        transaction.parentTransactionId!,
  };

  final entries = <TaxEntry>[];
  var uncategorizedCount = 0;
  var convertedCount = 0;

  for (final transaction in transactions) {
    if (transaction.transferPairId != null) continue;

    final id = transaction.id;
    if (id != null && splitParentIds.contains(id)) continue;
    if (!year.contains(transaction.transactionDate)) continue;

    final envelope = envelopesById[transaction.envelopeId];
    final categoryCode =
        transaction.taxCategoryCode ?? envelope?.taxCategoryCode;
    if (categoryCode == null || categoryCode.isEmpty) {
      uncategorizedCount++;
      continue;
    }

    final amountMinor = rates.convert(
      amountMinor: transaction.amountCents.abs(),
      fromCurrencyCode: transaction.currencyCode,
      toCurrencyCode: targetCurrencyCode,
      date: transaction.transactionDate,
    );
    final salesTaxMinor = rates.convert(
      amountMinor: transaction.salesTaxCents ?? 0,
      fromCurrencyCode: transaction.currencyCode,
      toCurrencyCode: targetCurrencyCode,
      date: transaction.transactionDate,
    );

    if (transaction.currencyCode != targetCurrencyCode) convertedCount++;

    entries.add(
      TaxEntry(
        date: transaction.transactionDate,
        amountMinor: amountMinor,
        categoryCode: categoryCode,
        businessUsePercent: transaction.businessUsePercent ?? 100,
        salesTaxMinor: salesTaxMinor,
        sourceId: id?.toString(),
        note: transaction.description,
      ),
    );
  }

  return TaxEntryBuildResult(
    entries: entries,
    uncategorizedCount: uncategorizedCount,
    convertedCount: convertedCount,
  );
}
