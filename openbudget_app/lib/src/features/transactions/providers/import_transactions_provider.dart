import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/utils/money_input.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'import_transactions_provider.g.dart';

/// Imports parsed rows into the chosen target account. Amounts are parsed
/// with the account's own decimals; the server turns them into ordinary
/// postings and reports inserted, duplicate and error counts.
@Riverpod(keepAlive: true)
class ImportTransactions extends _$ImportTransactions {
  @override
  AsyncValue<ImportResult?> build() => const AsyncValue.data(null);

  /// Returns the server's result: inserted, skipped duplicates, errors.
  Future<ImportResult> importRows({
    required String accountId,
    required String currencyCode,
    required List<ImportRow> rows,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final result = await client.transaction.importRows(
        UuidValue.fromString(accountId),
        rows,
      );
      if (ref.mounted) {
        state = AsyncValue.data(result);
      }
      return result;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }
}

/// Parses CSV text into [ImportRow]s for an account in [currencyCode].
///
/// Expects columns: date, description (or payee/memo/name), amount (or
/// inflow/outflow). A non-empty `external id` column is carried through so
/// re-importing the same file dedupes on the server.
List<ImportRow> parseCsvText(String csv, String currencyCode) {
  final lines = csv
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();
  if (lines.length < 2) return const [];

  final header = _splitCsvLine(lines.first)
      .map((h) => h.toLowerCase())
      .toList();
  var dateCol = header.indexWhere((h) => h.contains('date'));
  var descCol = header.indexWhere(
    (h) =>
        h.contains('description') ||
        h.contains('memo') ||
        h.contains('payee') ||
        h.contains('name'),
  );
  var amountCol = header.indexWhere((h) => h.contains('amount'));
  final externalIdCol = header.indexWhere(
    (h) => h.contains('external') && h.contains('id'),
  );
  final inflowCol = header.indexWhere((h) => h.contains('inflow'));
  final outflowCol = header.indexWhere((h) => h.contains('outflow'));

  if (dateCol < 0) dateCol = 0;
  if (descCol < 0) descCol = 1;
  if (amountCol < 0 && (inflowCol < 0 || outflowCol < 0)) amountCol = 2;

  final decimals = currencyDecimalsForCode(currencyCode);
  final rows = <ImportRow>[];
  for (var i = 1; i < lines.length; i++) {
    final cols = _splitCsvLine(lines[i]);
    if (cols.length <= dateCol) continue;

    final date = _parseDate(cols[dateCol]);
    if (date == null) continue;

    final description = descCol < cols.length ? cols[descCol] : '';
    final externalId = externalIdCol >= 0 && externalIdCol < cols.length
        ? cols[externalIdCol].trim()
        : '';

    final int? amountMinor;
    if (amountCol >= 0 && amountCol < cols.length) {
      final amountText = cols[amountCol].replaceAll(RegExp(r'[^\d.\-]'), '');
      amountMinor = parseMoneyInput(
        amountText,
        decimals: decimals,
        allowNegative: true,
      );
    } else if (inflowCol >= 0 && outflowCol >= 0) {
      final inflow = inflowCol < cols.length
          ? parseMoneyInput(
              cols[inflowCol].replaceAll(RegExp(r'[^\d.]'), ''),
              decimals: decimals,
            )
          : null;
      final outflow = outflowCol < cols.length
          ? parseMoneyInput(
              cols[outflowCol].replaceAll(RegExp(r'[^\d.]'), ''),
              decimals: decimals,
            )
          : null;
      if (inflow != null && inflow > 0) {
        amountMinor = inflow;
      } else if (outflow != null && outflow > 0) {
        amountMinor = -outflow;
      } else {
        amountMinor = null;
      }
    } else {
      amountMinor = null;
    }
    if (amountMinor == null || amountMinor == 0) continue;

    rows.add(
      ImportRow(
        date: date,
        amountMinor: amountMinor,
        description: description.isEmpty ? 'Imported transaction' : description,
        externalId: externalId.isEmpty ? null : externalId,
      ),
    );
  }
  return rows;
}

List<String> _splitCsvLine(String line) {
  final result = <String>[];
  final current = StringBuffer();
  var inQuotes = false;
  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (char == '"') {
      inQuotes = !inQuotes;
    } else if (char == ',' && !inQuotes) {
      result.add(current.toString().trim());
      current.clear();
    } else {
      current.write(char);
    }
  }
  result.add(current.toString().trim());
  return result;
}

DateTime? _parseDate(String text) {
  // Common formats: YYYY-MM-DD, MM/DD/YYYY, DD/MM/YYYY.
  final cleaned = text.trim();
  final iso = DateTime.tryParse(cleaned);
  if (iso != null) return DateTime.utc(iso.year, iso.month, iso.day);

  final slashParts = cleaned.split('/');
  if (slashParts.length == 3) {
    final a = int.tryParse(slashParts[0]);
    final b = int.tryParse(slashParts[1]);
    final c = int.tryParse(slashParts[2]);
    if (a != null && b != null && c != null) {
      // YYYY/MM/DD
      if (a > 31) {
        return _civilDate(a, b, c);
      }
      // DD/MM/YYYY
      if (a > 12) {
        return _civilDate(c, b, a);
      }
      // Default to MM/DD/YYYY.
      return _civilDate(c, a, b);
    }
  }
  return null;
}

DateTime? _civilDate(int year, int month, int day) {
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  return DateTime.utc(year, month, day);
}
