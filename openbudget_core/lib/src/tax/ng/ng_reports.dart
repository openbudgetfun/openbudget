part of 'ng_tax_rules.dart';

/// Totals [entries] by category, skipping codes this pack does not know for
/// [kind] and counting them as uncategorized.
///
/// [amountOf] lets a caller decide how much of an entry is allowable, such as
/// adding back input VAT when the business is not registered.
({Map<String, int> amounts, Map<String, int> counts, int uncategorized})
_totals(
  Iterable<TaxEntry> entries,
  EntityKind kind, {
  int Function(TaxEntry entry, TaxCategory category)? amountOf,
}) {
  final amounts = <String, int>{};
  final counts = <String, int>{};
  var uncategorized = 0;
  for (final entry in entries) {
    final category = _NgTaxCategories.byCode[entry.categoryCode];
    if (category == null || !category.entityKinds.contains(kind)) {
      uncategorized += 1;
      continue;
    }
    final amount = amountOf?.call(entry, category) ?? entry.allowableMinor;
    amounts.update(
      entry.categoryCode,
      (sum) => sum + amount,
      ifAbsent: () => amount,
    );
    counts.update(entry.categoryCode, (count) => count + 1, ifAbsent: () => 1);
  }
  return (amounts: amounts, counts: counts, uncategorized: uncategorized);
}

/// Sums the parts of [amounts] whose category has [kind].
int _sumKind(Map<String, int> amounts, TaxCategoryKind kind) {
  var total = 0;
  for (final MapEntry(key: code, value: amount) in amounts.entries) {
    if (_NgTaxCategories.byCode[code]?.kind == kind) {
      total += amount;
    }
  }
  return total;
}

/// The amount of [entry] allowed as a deduction or credit.
///
/// Registered persons reclaim the VAT in [TaxEntry.salesTaxMinor], so only the
/// net amount is allowable. Everyone else bears the VAT, so it is part of the
/// cost.
int _amountFor(
  TaxEntry entry,
  TaxCategory category, {
  required bool reclaimVat,
}) {
  if (reclaimVat) {
    return entry.allowableMinor;
  }
  return switch (category.kind) {
    TaxCategoryKind.expense || TaxCategoryKind.salesTaxPaid =>
      entry.amountMinor * entry.businessUsePercent ~/ 100,
    _ => entry.allowableMinor,
  };
}

/// Category lines in catalog order, skipping zero totals.
Iterable<TaxReportLine> _categoryLines(
  List<TaxCategory> catalog,
  Map<String, int> amounts,
  Map<String, int> counts, {
  required TaxCategoryKind kind,
  bool capital = false,
}) sync* {
  for (final category in catalog) {
    if (category.kind != kind) {
      continue;
    }
    if (_NgTaxCategories.isCapital(category.code) != capital) {
      continue;
    }
    final amount = amounts[category.code];
    if (amount == null || amount == 0) {
      continue;
    }
    yield _lineFor(category, amount, counts[category.code] ?? 0);
  }
}

/// One category total as a report line.
TaxReportLine _lineFor(TaxCategory category, int amountMinor, int entryCount) =>
    TaxReportLine(
      label: category.label,
      amountMinor: amountMinor,
      code: category.code,
      reportReference: category.reportReference,
      entryCount: entryCount,
    );

/// Income tax on [chargeableMinor] under [bands].
int _taxOn(int chargeableMinor, List<TaxBand> bands) =>
    sumBandTax(applyTaxBands(chargeableMinor, bands));

/// Rent relief: 20% of annual rent, capped at N500,000.
int _rentRelief(int annualRentMinor, _NgTaxTable table) {
  if (annualRentMinor <= 0) {
    return 0;
  }
  final relief = annualRentMinor * table.rentReliefBasisPoints ~/ 10000;
  return math.min(relief, table.rentReliefCapMinor);
}

/// Old regime (PITA, secondary): the consolidated relief allowance on
/// [grossMinor] of gross income, the higher of the N200,000 floor or 1% of
/// gross income, plus 20% of gross income. Each part is rounded down to a
/// whole kobo.
int _consolidatedReliefAllowance(int grossMinor, _NgTaxTable table) {
  if (grossMinor <= 0) {
    return 0;
  }
  final percentPart = math.max(
    grossMinor * table.craPercentBasisPoints ~/ 10000,
    table.craFloorMinor,
  );
  return percentPart + grossMinor * table.craShareBasisPoints ~/ 10000;
}

/// A plain naira amount for explanations, without a thousands separator.
String _naira(int minor) {
  final whole = minor ~/ 100;
  final kobo = minor % 100;
  if (kobo == 0) {
    return 'N$whole';
  }
  return 'N$whole.${kobo.toString().padLeft(2, '0')}';
}

/// Assumptions shared by every Nigeria report.
List<String> _baseAssumptions() => [
  'Resident person, taxed on income arising in or derived from Nigeria.',
  'Calendar-year cash basis: entries dated in the year are used, and the Act basis-period rules for trade profits and chargeable gains are not modelled.',
  'No income, gains or reliefs outside OpenBudget.',
  'State and local government levies are excluded.',
];
