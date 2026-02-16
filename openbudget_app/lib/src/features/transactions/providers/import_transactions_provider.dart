import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'import_transactions_provider.g.dart';

@Riverpod(keepAlive: true)
class ImportTransactions extends _$ImportTransactions {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<int> importRows({
    required String budgetId,
    required String currencyCode,
    required List<ImportRow> rows,
    String? accountId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final count = await client.transaction.bulkImport(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(budgetId),
        currencyCode,
        rows,
        accountId: accountId != null
            // Serverpod API requires UuidValue which is experimental in uuid package.
            // ignore: experimental_member_use
            ? UuidValue.fromString(accountId)
            : null,
      );
      if (ref.mounted) {
        ref.invalidate(budgetSummaryProvider(budgetId));
        state = const AsyncValue.data(null);
      }
      return count;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }
}

/// Parses CSV text into a list of [ImportRow] objects.
///
/// Expects CSV with columns: date, description, amount (or inflow/outflow).
/// Supports common bank export formats with header detection.
List<ImportRow> parseCsvText(String csv, CurrencyCode currency) {
  final lines = csv
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();
  if (lines.length < 2) return [];

  // Parse header to detect column positions.
  final header = _splitCsvLine(
    lines.first,
  ).map((h) => h.toLowerCase()).toList();
  var dateCol = header.indexWhere((h) => h.contains('date'));
  var descCol = header.indexWhere(
    (h) =>
        h.contains('description') ||
        h.contains('memo') ||
        h.contains('payee') ||
        h.contains('name'),
  );
  var amountCol = header.indexWhere((h) => h.contains('amount'));

  // Default column mapping if headers not detected.
  if (dateCol < 0) dateCol = 0;
  if (descCol < 0) descCol = 1;
  if (amountCol < 0) amountCol = 2;

  final rows = <ImportRow>[];
  for (var i = 1; i < lines.length; i++) {
    final cols = _splitCsvLine(lines[i]);
    if (cols.length <= amountCol || cols.length <= dateCol) continue;

    final date = _parseDate(cols[dateCol]);
    if (date == null) continue;

    final description = descCol < cols.length
        ? cols[descCol]
        : 'Imported transaction';
    final amountText = cols[amountCol].replaceAll(RegExp(r'[^\d.\-]'), '');
    final amount = double.tryParse(amountText);
    if (amount == null) continue;

    final amountCents = (amount * _pow10(currency.decimals)).round();

    rows.add(
      ImportRow(
        description: description,
        amountCents: amountCents,
        transactionDate: date,
      ),
    );
  }

  return rows;
}

List<String> _splitCsvLine(String line) {
  final result = <String>[];
  var inQuotes = false;
  var current = StringBuffer();

  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (char == '"') {
      inQuotes = !inQuotes;
    } else if (char == ',' && !inQuotes) {
      result.add(current.toString().trim());
      current = StringBuffer();
    } else {
      current.write(char);
    }
  }
  result.add(current.toString().trim());
  return result;
}

DateTime? _parseDate(String text) {
  // Try common formats: YYYY-MM-DD, MM/DD/YYYY, DD/MM/YYYY.
  final cleaned = text.trim();
  final iso = DateTime.tryParse(cleaned);
  if (iso != null) return iso;

  final slashParts = cleaned.split('/');
  if (slashParts.length == 3) {
    final a = int.tryParse(slashParts[0]);
    final b = int.tryParse(slashParts[1]);
    final c = int.tryParse(slashParts[2]);
    if (a != null && b != null && c != null) {
      // MM/DD/YYYY
      if (c > 31) {
        return DateTime.tryParse(
          '$c-${a.toString().padLeft(2, '0')}-${b.toString().padLeft(2, '0')}',
        );
      }
      // DD/MM/YYYY
      if (a > 12) {
        return DateTime.tryParse(
          '$c-${b.toString().padLeft(2, '0')}-${a.toString().padLeft(2, '0')}',
        );
      }
      // Default to MM/DD/YYYY
      return DateTime.tryParse(
        '$c-${a.toString().padLeft(2, '0')}-${b.toString().padLeft(2, '0')}',
      );
    }
  }

  return null;
}

double _pow10(int exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}
