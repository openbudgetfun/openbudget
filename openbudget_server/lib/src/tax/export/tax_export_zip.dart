import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/tax/export/tax_export_csv.dart';
import 'package:openbudget_server/src/tax/tax_summary_service.dart';

/// Builds the tax summary export ZIP: `summary.csv`, `lines.csv` and
/// `README.txt` (docs/tax-jurisdictions.md, section 8.7).
///
/// Every amount is a decimal string at its currency's exponent, computed
/// from minor units, so the lines and the summary can be reconciled in a
/// spreadsheet without a float ever touching the figures.
abstract final class TaxExportZip {
  /// The ZIP bytes for one summary computation.
  static Uint8List build(TaxSummaryComputation computation) {
    final view = computation.view;
    final archive = Archive()
      ..addFile(_textFile('summary.csv', _summaryCsv(view, computation)))
      ..addFile(_textFile('lines.csv', _linesCsv(computation)))
      ..addFile(_textFile('README.txt', _readme(view)));
    return Uint8List.fromList(ZipEncoder().encode(archive));
  }

  static ArchiveFile _textFile(String name, String text) {
    final bytes = Uint8List.fromList(utf8.encode(text));
    return ArchiveFile(name, bytes.length, bytes);
  }

  static int _exponent(String currencyCode) =>
      exponentForCurrency(currencyCode) ?? 2;

  static String _date(DateTime date) {
    final utc = date.toUtc();
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    return '${utc.year}-$month-$day';
  }

  /// The decimal string of a rate per million: 200000 is `20%`,
  /// 99753 is `9.9753%`.
  static String _percent(int? ratePerMillion) {
    if (ratePerMillion == null) return 'unknown rate';
    final percent = minorToDecimalString(ratePerMillion, 4);
    return '$percent%';
  }

  static String _summaryCsv(
    TaxSummaryView view,
    TaxSummaryComputation computation,
  ) {
    final currency = view.currencyCode;
    final exponent = _exponent(currency);
    final buffer = StringBuffer()
      ..write(
        csvRow([
          'section',
          'item',
          'category code',
          'label',
          'amount',
          'currency',
          'detail',
        ]),
      );

    void header(String item, Object? value) => buffer.write(
      csvRow(['header', item, '', '', '', '', value]),
    );
    header('entity kind', view.entityKind.name);
    header('country', view.countryCode);
    header('summary currency', currency);
    header('tax year', view.yearLabel);
    header('year starting in', view.startYear);
    header('period start', _date(view.yearStart));
    header('period end', _date(view.yearEnd));
    header('generated at', view.generatedAt.toUtc().toIso8601String());
    header('rules layer', view.isUniversal ? 'universal' : 'rule pack');
    header('rules version', view.rulesVersion ?? '');
    header(
      'rules verified on',
      view.rulesVerifiedOn == null ? '' : _date(view.rulesVerifiedOn!),
    );
    header('rate sources used', view.rateSourcesUsed.join(' '));
    header('uncategorised lines', view.uncategorizedCount);
    header('disclaimer key', view.disclaimerKey);

    void totals(String section, List<TaxSummaryCategoryTotalView> rows) {
      for (final row in rows) {
        buffer.write(
          csvRow([
            section,
            'total',
            row.categoryCode,
            row.label,
            minorToDecimalString(row.totalMinor, exponent),
            currency,
            '${row.entryCount} ${row.entryCount == 1 ? 'line' : 'lines'}',
          ]),
        );
      }
    }

    totals('income totals', view.incomeTotals);
    totals('expense totals', view.expenseTotals);
    totals('relief totals', view.reliefTotals);
    totals('tax paid totals', view.taxPaidTotals);
    buffer
      ..write(
        csvRow([
          'totals',
          'income',
          '',
          '',
          minorToDecimalString(view.totalIncomeMinor, exponent),
          currency,
          '',
        ]),
      )
      ..write(
        csvRow([
          'totals',
          'expenses',
          '',
          '',
          minorToDecimalString(view.totalExpenseMinor, exponent),
          currency,
          '',
        ]),
      )
      ..write(
        csvRow([
          'totals',
          'reliefs',
          '',
          '',
          minorToDecimalString(view.totalReliefMinor, exponent),
          currency,
          '',
        ]),
      )
      ..write(
        csvRow([
          'totals',
          'tax paid',
          '',
          '',
          minorToDecimalString(view.totalTaxPaidMinor, exponent),
          currency,
          '',
        ]),
      );

    void salesTax(String item, int? collected, int? paid, String detail) {
      if (collected != null) {
        buffer.write(
          csvRow([
            'sales tax',
            item,
            '',
            'collected',
            minorToDecimalString(collected, exponent),
            currency,
            detail,
          ]),
        );
      }
      if (paid != null) {
        buffer.write(
          csvRow([
            'sales tax',
            item,
            '',
            'paid',
            minorToDecimalString(paid, exponent),
            currency,
            detail,
          ]),
        );
      }
    }

    if (view.salesTaxCollectedMinor != 0 || view.salesTaxPaidMinor != 0) {
      salesTax(
        'total',
        view.salesTaxCollectedMinor,
        view.salesTaxPaidMinor,
        'after business-use share',
      );
      for (final rate in view.salesTaxByRate) {
        salesTax(
          _percent(rate.ratePerMillion),
          rate.collectedMinor,
          rate.paidMinor,
          'by the rate each line implies',
        );
      }
      for (final quarter in view.salesTaxByQuarter) {
        salesTax(
          quarter.label,
          quarter.collectedMinor,
          quarter.paidMinor,
          '${_date(quarter.periodStart)} to ${_date(quarter.periodEnd)}',
        );
      }
    }

    for (final wallet in view.wallets) {
      final walletExponent = _exponent(wallet.currencyCode);
      final kind = wallet.transactionCount == 1
          ? 'transaction'
          : 'transactions';
      final detail =
          '${wallet.transactionCount} $kind, '
          'method ${wallet.costBasisMethod}';
      void walletRow(String label, int minor) => buffer.write(
        csvRow([
          'digital assets',
          wallet.label ?? wallet.walletId.uuid,
          '',
          label,
          minorToDecimalString(minor, walletExponent),
          wallet.currencyCode,
          detail,
        ]),
      );
      walletRow('proceeds', wallet.proceedsMinor);
      walletRow('cost', wallet.costBasisMinor);
      walletRow('gain or loss', wallet.gainMinor);
      for (final caveat in wallet.caveats) {
        buffer.write(
          csvRow([
            'digital assets',
            wallet.label ?? wallet.walletId.uuid,
            '',
            'caveat',
            '',
            '',
            caveat,
          ]),
        );
      }
    }

    for (final note in view.fxNotes) {
      final state = note.isStale ? ', stale' : '';
      final lines = note.lineCount == 1 ? 'line' : 'lines';
      final detail =
          'rate ${note.fxRate} on ${_date(note.fxRateDate)} from '
          '${note.fxRateSource.name}$state, ${note.lineCount} $lines';
      buffer.write(
        csvRow([
          'fx notes',
          note.currencyCode,
          '',
          'converted total',
          minorToDecimalString(note.convertedMinor, exponent),
          currency,
          detail,
        ]),
      );
    }

    return buffer.toString();
  }

  static String _linesCsv(TaxSummaryComputation computation) {
    final view = computation.view;
    final currency = computation.currencyCode;
    final exponent = _exponent(currency);

    // The codes the view totals under, with their catalogue labels. A line
    // whose code is absent from here fed no total, whatever its code.
    final labelByCode = {
      for (final totals in [
        view.incomeTotals,
        view.expenseTotals,
        view.reliefTotals,
        view.taxPaidTotals,
      ])
        for (final total in totals) total.categoryCode: total.label,
    };

    // One contributing entry per line, by the line the entry came from.
    final entryIndexByLineId = <String, int>{};
    for (var index = 0; index < computation.entries.length; index++) {
      final sourceId = computation.entries[index].sourceId;
      if (sourceId != null) entryIndexByLineId[sourceId] = index;
    }

    final buffer = StringBuffer()
      ..write(
        csvRow([
          'date',
          'payee',
          'description',
          'amount',
          'currency',
          'base amount',
          'fx rate',
          'fx rate date',
          'fx rate source',
          'category code',
          'category label',
          'business use %',
          'sales tax',
          'envelope',
        ]),
      );

    final lines = computation.sourceLines.values.toList()
      ..sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        if (byDate != 0) return byDate;
        return a.id.uuid.compareTo(b.id.uuid);
      });

    for (final line in lines) {
      if (line.isTransfer) continue;

      var amount = '';
      var baseAmount = '';
      var fxRate = '';
      var fxRateDate = '';
      var fxRateSource = '';
      var categoryCode = '';
      var categoryLabel = '';
      var businessUse = '';
      var salesTax = '';

      final entryIndex = entryIndexByLineId[line.id.toString()];
      if (entryIndex == null) {
        // No category, or a category that fed no total: the line shows its
        // own amount and nothing else, and no total rests on it.
        amount = minorToDecimalString(
          line.amountMinor,
          _exponent(line.currencyCode),
        );
        businessUse = '${line.businessUsePercent ?? 100}';
      } else {
        final entry = computation.entries[entryIndex];
        final contributes = labelByCode.containsKey(entry.categoryCode);
        amount = minorToDecimalString(
          line.amountMinor,
          _exponent(line.currencyCode),
        );
        businessUse = '${entry.businessUsePercent}';
        if (contributes) {
          categoryCode = entry.categoryCode;
          categoryLabel = labelByCode[entry.categoryCode] ?? '';
          baseAmount = minorToDecimalString(entry.allowableMinor, exponent);
          salesTax = minorToDecimalString(entry.salesTaxMinor, exponent);

          final request =
              computation.fxRequests[computation.sourceIndexes[entryIndex]];
          final quote = computation.rates.quoteFor(request);
          if (quote != null && !request.isIdentity) {
            fxRate = quote.rateText;
            fxRateDate = _date(quote.rateDate);
            fxRateSource = quote.source.name;
          }
        }
      }

      buffer.write(
        csvRow([
          _date(line.date),
          line.payeeName ?? '',
          line.description,
          amount,
          line.currencyCode,
          baseAmount,
          fxRate,
          fxRateDate,
          fxRateSource,
          categoryCode,
          categoryLabel,
          businessUse,
          salesTax,
          line.envelopeName ?? '',
        ]),
      );
    }

    return buffer.toString();
  }

  static String _readme(TaxSummaryView view) {
    final rules = view.rulesVersion == null
        ? 'Your country has no detailed rule pack yet, so this summary comes '
              'from the universal layer. The country facts behind it were last '
              'checked against their sources on '
              '${view.rulesVerifiedOn == null ? 'an unknown date' : _date(view.rulesVerifiedOn!)}.'
        : 'The figures follow rule pack ${view.rulesVersion}, last checked '
              'against its sources on '
              '${view.rulesVerifiedOn == null ? 'an unknown date' : _date(view.rulesVerifiedOn!)}.';

    final currency = view.currencyCode;
    final exponent = _exponent(currency);

    return '''
OpenBudget tax summary export
=============================

Period: ${view.yearLabel} (${_date(view.yearStart)} to ${_date(view.yearEnd)})
Country: ${view.countryCode}
Summary currency: $currency
Generated at: ${view.generatedAt.toUtc().toIso8601String()} UTC

What is in this file set
------------------------

summary.csv
    One row per figure of the tax-ready summary: the header facts, income,
    expense, relief and tax-paid totals by category, sales tax collected and
    paid (in total, by the rate each line implies, and by quarter), digital
    asset figures per wallet, and one row per exchange rate the converted
    lines used. The "detail" column holds the line count, date range or rate
    that belongs to the row.

lines.csv
    One row per transaction line dated inside the period. Transfers between
    your own accounts are left out: they are movements, not taxable events.
    The columns are:

    date             The transaction date (UTC).
    payee            Who the transaction was with, when one is set.
    description      The transaction's description.
    amount           The line amount in its own currency, as a decimal
                     string at that currency's exponent.
    currency         The account currency of the amount.
    base amount      What the line added to its category total in the
                     summary currency: net of any sales tax on the line,
                     converted at the transaction date's rate, and cut to
                     the business-use share. Empty for a line that fed no
                     total.
    fx rate          The rate the conversion applied, as summary currency
                     per one unit of the line's currency. Empty when no
                     conversion happened.
    fx rate date     The date of that rate. A rate can fall back up to seven
                     days behind the line when its own day has no stored
                     quote; staleness is reported in summary.csv.
    fx rate source   market, manual or identity.
    category code    The tax category the line is coded to, as your
                     country's rules name it. Empty when the line had no
                     category, or when its universal category has no home in
                     your country's rules - those lines are counted as
                     uncategorised and fed no total.
    category label   The category's name.
    business use %   The share of the line used for business. The base
                     amount is that share of the net amount.
    sales tax        Any sales tax (VAT, GST) included in the line, in the
                     summary currency, always a positive amount. Whether it
                     was charged to customers or paid on purchases follows
                     the line's category.
    envelope         The envelope the line is assigned to, when one is.

README.txt
    This file.

How the amounts are written
---------------------------

Every amount is a decimal string at its currency's exponent - $currency
carries $exponent decimal place${exponent == 1 ? '' : 's'}, so 1234 at exponent 2 is written 12.34 and a
zero-decimal currency never shows one. Nothing here passes through floating
point; summing the base amounts of lines.csv by category code reproduces the
matching total in summary.csv.

How currency conversion works
-----------------------------

A line in another currency is converted once, at the rate stored for its
transaction date: exact decimal arithmetic, rounded half up a single time
into the summary currency's minor units. Rates come from the stored daily
quotes (units of currency per one US dollar, cross-rated through USD), which
is why a rate date can sit up to seven days behind a line and why summary.csv
reports the source and staleness of every rate used.

Which rules these figures follow
--------------------------------

$rules

A company reports under its own financial year; a person reports under the
country's tax year.

The honest small print
----------------------

OpenBudget prepared this summary from the transaction lines you tagged. It
is a guide to help you or your accountant prepare a return - it is not tax
advice, and OpenBudget does not file anything. Wallet figures are FIFO
estimates on stored valuations, not a disposal computation, and your
jurisdiction's cost-basis and matching rules may differ. Check the figures
against your records before you file.
''';
  }
}
