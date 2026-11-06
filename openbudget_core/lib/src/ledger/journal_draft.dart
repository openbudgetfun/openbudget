import 'package:openbudget_core/src/ledger/exchange_rate.dart';

/// One validation failure found in a journal draft.
class LedgerValidationIssue {
  const LedgerValidationIssue(this.code, this.message, {this.lineIndex});

  /// Stable machine-readable identifier, such as `unbalancedFunctional`.
  final String code;

  /// Human-readable explanation, safe to surface to the user.
  final String message;

  /// The zero-based index of the offending line, or null when the issue is
  /// about the journal as a whole.
  final int? lineIndex;

  @override
  String toString() => '$code: $message';
}

/// One proposed journal line, before it is attached to a journal row.
///
/// Amounts are integers in minor units. A line is one-sided: exactly one of
/// the debit/credit pair is positive and the other is zero, in both the
/// transaction currency and the functional currency. [exchangeRate] is
/// functional per one transaction currency as an exact decimal string, with
/// [rateDate] and [rateSource] recording where it came from.
class JournalLineDraft {
  const JournalLineDraft({
    required this.accountCode,
    required this.debitMinor,
    required this.creditMinor,
    required this.currencyCode,
    required this.functionalDebitMinor,
    required this.functionalCreditMinor,
    required this.exchangeRate,
    required this.rateDate,
    required this.rateSource,
    this.description,
    this.taxCode,
  });

  /// The ledger account's code. Carried for messages and reports only;
  /// nothing keys on a code.
  final String accountCode;

  /// Optional per-line note.
  final String? description;

  /// Debit in transaction-currency minor units, or 0.
  final int debitMinor;

  /// Credit in transaction-currency minor units, or 0.
  final int creditMinor;

  /// The currency the transaction happened in, such as `USD`.
  final String currencyCode;

  /// Debit in functional-currency minor units, or 0.
  final int functionalDebitMinor;

  /// Credit in functional-currency minor units, or 0.
  final int functionalCreditMinor;

  /// Functional per 1 transaction currency, exact decimal string.
  final String exchangeRate;

  /// The calendar date the rate was struck.
  final DateTime rateDate;

  /// Where the rate came from, such as `manual` or a provider name.
  final String rateSource;

  /// Optional sales-tax code applied to this line.
  final String? taxCode;
}

/// A proposed journal: [lines] to be validated against [functionalCurrency].
///
/// Validation enforces the posting invariants: at least two lines, one-sided
/// positive lines, functional amounts that reproduce the stated rate, and
/// balance in the functional currency. When every line shares one foreign
/// currency the draft must also balance in that currency, so a rate cannot
/// hide an imbalance. Journals that mix the functional currency with one or
/// more foreign currencies — a settlement that realises an FX difference,
/// for instance — only owe the functional balance.
class JournalDraft {
  const JournalDraft({
    required this.functionalCurrency,
    required this.lines,
  });

  /// The budget's ISO currency code, the ledger's functional currency.
  final String functionalCurrency;

  /// The proposed lines.
  final List<JournalLineDraft> lines;

  /// Runs every invariant. Returns one issue per failure.
  List<LedgerValidationIssue> validate() {
    final issues = <LedgerValidationIssue>[];

    final functionalExponent = exponentForCurrency(functionalCurrency);
    if (functionalExponent == null) {
      issues.add(
        LedgerValidationIssue(
          'unsupportedFunctionalCurrency',
          'Functional currency "$functionalCurrency" is not supported.',
        ),
      );
      return issues;
    }

    if (lines.length < 2) {
      issues.add(
        const LedgerValidationIssue(
          'atLeastTwoLines',
          'A journal needs at least two lines.',
        ),
      );
    }

    final validated = _validateLines(functionalExponent, issues);
    final currencies = validated.currencies.toSet();
    if (currencies.length == 1) {
      final currency = currencies.first;
      if (currency != functionalCurrency &&
          validated.debitByCurrency[currency] !=
              validated.creditByCurrency[currency]) {
        issues.add(
          LedgerValidationIssue(
            'unbalancedTransactionCurrency',
            'Lines in $currency do not balance: '
                '${validated.debitByCurrency[currency]} Dr vs '
                '${validated.creditByCurrency[currency]} Cr.',
          ),
        );
      }
    }

    var functionalDebit = 0;
    var functionalCredit = 0;
    for (final line in lines) {
      functionalDebit += line.functionalDebitMinor;
      functionalCredit += line.functionalCreditMinor;
    }
    if (functionalDebit != functionalCredit) {
      issues.add(
        LedgerValidationIssue(
          'unbalancedFunctional',
          'Journal does not balance in $functionalCurrency: '
              '$functionalDebit Dr vs $functionalCredit Cr.',
        ),
      );
    }

    return issues;
  }

  /// Validates each line individually, collecting per-currency totals of the
  /// lines that passed.
  _LineTotals _validateLines(
    int functionalExponent,
    List<LedgerValidationIssue> issues,
  ) {
    final currencies = <String>[];
    final debitByCurrency = <String, int>{};
    final creditByCurrency = <String, int>{};

    void addTotal(String currency, (bool, int) side) {
      if (!debitByCurrency.containsKey(currency)) {
        currencies.add(currency);
        debitByCurrency[currency] = 0;
        creditByCurrency[currency] = 0;
      }
      final (isDebit, amount) = side;
      if (isDebit) {
        debitByCurrency[currency] = debitByCurrency[currency]! + amount;
      } else {
        creditByCurrency[currency] = creditByCurrency[currency]! + amount;
      }
    }

    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      final label = 'Line ${index + 1} (${line.accountCode})';

      final side = _sideOf(line.debitMinor, line.creditMinor);
      final functionalSide = _sideOf(
        line.functionalDebitMinor,
        line.functionalCreditMinor,
      );
      if (side == null) {
        issues.add(
          LedgerValidationIssue(
            'lineOneSideRequired',
            '$label must carry a positive debit or a positive credit, '
                'not both and not neither.',
            lineIndex: index,
          ),
        );
        continue;
      }
      if (functionalSide == null) {
        issues.add(
          LedgerValidationIssue(
            'lineOneSideRequired',
            '$label must carry a positive functional debit or credit, '
                'not both and not neither.',
            lineIndex: index,
          ),
        );
        continue;
      }
      if (side.$1 != functionalSide.$1) {
        issues.add(
          LedgerValidationIssue(
            'lineSideMismatch',
            '$label is a ${_direction(side.$1)} in ${line.currencyCode} '
                'but a ${_direction(functionalSide.$1)} in the functional '
                'currency.',
            lineIndex: index,
          ),
        );
        continue;
      }

      final rate = ExactDecimal.tryParse(line.exchangeRate);
      if (rate == null) {
        issues.add(
          LedgerValidationIssue(
            'invalidExchangeRate',
            '$label has exchange rate "${line.exchangeRate}", which is not '
                'a positive decimal string such as "1.234567".',
            lineIndex: index,
          ),
        );
        continue;
      }

      final transactionExponent = exponentForCurrency(line.currencyCode);
      if (transactionExponent == null) {
        issues.add(
          LedgerValidationIssue(
            'unsupportedCurrency',
            '$label uses unsupported currency "${line.currencyCode}".',
            lineIndex: index,
          ),
        );
        continue;
      }

      final expectedFunctional = convertMinorUnits(
        amountMinor: side.$2,
        exchangeRate: rate,
        transactionExponent: transactionExponent,
        functionalExponent: functionalExponent,
      );
      if (functionalSide.$2 != expectedFunctional) {
        issues.add(
          LedgerValidationIssue(
            'functionalMismatch',
            '$label converts ${side.$2} ${line.currencyCode} at '
                '${line.exchangeRate} to $expectedFunctional minor, not '
                '${functionalSide.$2} minor.',
            lineIndex: index,
          ),
        );
        continue;
      }

      addTotal(line.currencyCode, side);
    }

    return (
      currencies: currencies,
      debitByCurrency: debitByCurrency,
      creditByCurrency: creditByCurrency,
    );
  }
}

String _direction(bool isDebit) => isDebit ? 'debit' : 'credit';

(bool isDebit, int amount)? _sideOf(int debit, int credit) {
  if (debit > 0 && credit == 0) {
    return (true, debit);
  }
  if (credit > 0 && debit == 0) {
    return (false, credit);
  }
  return null;
}

typedef _LineTotals = ({
  List<String> currencies,
  Map<String, int> debitByCurrency,
  Map<String, int> creditByCurrency,
});
